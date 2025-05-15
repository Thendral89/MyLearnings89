public without sharing class CEMTriggerHandler extends mvSObjectDomain {
    
    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    public CEMTriggerHandler(List<SymphonyLF__Client_Engagement_Model__c> sObjectList) {
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
            if (System.isFuture() || System.isBatch()) {
                cmpRPCEMHandler.cemCreationLegalAssistant(cemRec);
            } else {
                cmpRPCEMHandler.cemCreationLegalAssistantfuture(cemRec);
            }
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
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {}

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
            return new CEMTriggerHandler(sObjectList);
        }
    }
}