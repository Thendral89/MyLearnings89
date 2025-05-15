public without sharing class ClientEngagementModelTriggerHandler extends mvSObjectDomain {
    
    private Map<Id, SObject> oldMap;
    private Map<Id, SObject> newMap;
    private Set<Id>          cemToDeactivate = new Set<Id>();

    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    public ClientEngagementModelTriggerHandler(List<SymphonyLF__Client_Engagement_Model__c> sObjectList) {
        super(sObjectList);
    }

    public override void onBeforeInsert() {}
    
   public override void onAfterInsert() {
        Set<Id> cemRec = new Set<Id>();
        for (SObject cem : this.records) {
            SymphonyLF__Client_Engagement_Model__c newCEM = (SymphonyLF__Client_Engagement_Model__c) cem;
            if(newCEM.Person_Type__c == 'Attorney' || newCEM.Person_Type__c == 'Paralegal'){
                cemRec.add(cem.Id);
                system.debug('newCEM '+ newCEM);
                system.debug('newCEM SymphonyLF__Type__c '+newCEM.SymphonyLF__Person__r.SymphonyLF__Type__c);
            }
        }
        
        system.debug('cemRec size '+cemRec.size());
        if (cemRec.size() > 0) {
        //    if (System.isFuture() || System.isBatch()) {
        // This is made synchronous by Biswajit Samantaray. 
        // Reason: Legal assistant on CEM and MEM is firing asynchronously and there is timing issue, due to which CEM lookup in MEM is not populating
                cmpRPCEMHandler.cemCreationLegalAssistant(cemRec);
            // } else {
            //     cmpRPCEMHandler.cemCreationLegalAssistantfuture(cemRec);
            // }
        }
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Set<Id> updateCEMId = new Set<Id>();
        Set<Id> oldPersonIds = new Set<Id>();
        
        Map<Id, SymphonyLF__Client_Engagement_Model__c> cemMap = new Map<Id, SymphonyLF__Client_Engagement_Model__c>();
    for (Id cemId : existingRecords.keySet()) {
        cemMap.put(cemId, (SymphonyLF__Client_Engagement_Model__c) existingRecords.get(cemId));
    }
        
        for (SObject cem : this.records) {
            SymphonyLF__Client_Engagement_Model__c newCEM = (SymphonyLF__Client_Engagement_Model__c) cem;
            SymphonyLF__Client_Engagement_Model__c oldCEM = cemMap.get(newCEM.Id);

          
            if (oldCEM != null && newCEM.Is_Active__c != oldCEM.Is_Active__c && 
            (newCEM.Person_Type__c == 'Attorney' || newCEM.Person_Type__c == 'Paralegal')) {
            updateCEMId.add(newCEM.Id);
            if (oldCEM.SymphonyLF__Person__c != null) {
                oldPersonIds.add(oldCEM.SymphonyLF__Person__c);
            }
        }
        }
        if (updateCEMId.size() > 0) {
            if (System.isFuture() || System.isBatch()) {
                cmpRPCEMHandler.updateLegalAssistants(updateCEMId, oldPersonIds);
            } else {
                cmpRPCEMHandler.updateLegalAssistantsfuture(updateCEMId, oldPersonIds);
            }
        }
    }

    /** 
     *  onAfterUpdate 
     * Deactivate any related MEMs when a CEM flips from active→inactive.
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        System.debug('onAfterUpdate is called');
        
        this.oldMap     = existingRecords;
        this.newMap     = new Map<Id,SObject>(this.records);
        this.cemToDeactivate.clear();
        
        for (SObject sob : this.records) {
            SymphonyLF__Client_Engagement_Model__c newCEM =
                (SymphonyLF__Client_Engagement_Model__c) sob;
            SymphonyLF__Client_Engagement_Model__c oldCEM =
                (SymphonyLF__Client_Engagement_Model__c) this.oldMap.get(newCEM.Id);

            // if it was active before and now is inactive, mark for deactivation
            if (oldCEM != null 
                && oldCEM.Is_Active__c 
                && !newCEM.Is_Active__c) {
                cemToDeactivate.add(newCEM.Id);
            }
        }

        if (!cemToDeactivate.isEmpty()) {
            deactivateRelatedMEMs();
        }
    }

    /**
     * Queries all active Matter_Engagement_Model__c under the deactivated CEMs,
     * and flips those whose client matches the CEM’s client.
     */
    private void deactivateRelatedMEMs() {
        // map CEM → its Client__c
        Map<Id, Id> cemClientMap = new Map<Id, Id>();
        for (Id cemId : cemToDeactivate) {
            SymphonyLF__Client_Engagement_Model__c cem =
                (SymphonyLF__Client_Engagement_Model__c) this.newMap.get(cemId);
            cemClientMap.put(cemId, cem.SymphonyLF__Client__c);
        }

        // fetch all active MEMs for these CEMs
        List<SymphonyLF__Matter_Engagement_Model__c> candidates = [
          SELECT Id,
                 Client_Engagement_Model__c,
                 SymphonyLF__Client__c,
                 Is_Active__c
            FROM SymphonyLF__Matter_Engagement_Model__c
           WHERE Client_Engagement_Model__c IN :cemClientMap.keySet()
             AND Is_Active__c = true
        ];

        List<SymphonyLF__Matter_Engagement_Model__c> toUpdate = new List<SymphonyLF__Matter_Engagement_Model__c>();
        for (SymphonyLF__Matter_Engagement_Model__c mem : candidates) {
            // only flip those whose MEM.Client__c equals the CEM’s client
            if (mem.SymphonyLF__Client__c == cemClientMap.get(mem.Client_Engagement_Model__c)) {
                mem.Is_Active__c = false;
                toUpdate.add(mem);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public override void onBeforeDelete() {
        Set<Id> oldCEMRec = new Set<Id>();
      
        
        for (SObject cem : this.records) {
            oldCEMRec.add(cem.Id);
        }

        if (oldCEMRec.size() > 0) {
            if (System.isFuture() || System.isBatch()) {
                cmpRPCEMHandler.deleteAttorneyandLA(oldCEMRec);
            } else {
                cmpRPCEMHandler.deleteAttorneyandLAfuture(oldCEMRec);
            }
        }

        system.debug('before delete triggered 87');
    }
    
    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new ClientEngagementModelTriggerHandler(sObjectList);
        }
    }
}