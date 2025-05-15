public class MEMTriggerHandler extends mvSObjectDomain{
    
    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    public MEMTriggerHandler(List<SymphonyLF__Matter_Engagement_Model__c> sObjectList) {
        super(sObjectList);
    }
    
    public static void onBeforeInsert() {
        // Add logic for before insert if needed
    }
    
    public override void onAfterInsert() {
        List<SymphonyLF__Matter_Engagement_Model__c> newRecords = (List<SymphonyLF__Matter_Engagement_Model__c>) this.records;
        System.debug('new records of MEM----->'+newRecords);
        CheckListInitialAssignmentHandler.initialMEMAssignment(newRecords, null);


        MatterEngagementModelDomain m = new MatterEngagementModelDomain();
    
        Set<Id> MEMRec = new Set<Id>();
        for (SObject mem : this.records) {
            MEMRec.add(mem.Id);
        }
        
        if (!MEMRec.isEmpty()) {
            if (System.isFuture() || System.isBatch()) {
                 m.memGroupCalculation(new List<Id>(MEMRec));
                 cmpRPMEMHandler.memCreationLegalAssistant(MEMRec);
               
                
            } else {
                MatterEngagementModelDomain.memGroupCalculationFuture(new List<Id>(MEMRec));
                cmpRPMEMHandler.memCreationLegalAssistantfuture(MEMRec);
                
            }
        }
    }

   
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Set<Id> updateCEMId = new Set<Id>();
        Set<Id> oldPersonIds = new Set<Id>();
        
        Map<Id, SymphonyLF__Matter_Engagement_Model__c> memMap = new Map<Id, SymphonyLF__Matter_Engagement_Model__c>();
    for (Id memId : existingRecords.keySet()) {
        memMap.put(memId, (SymphonyLF__Matter_Engagement_Model__c) existingRecords.get(memId));
    }
        
        for (SObject cem : this.records) {
            SymphonyLF__Matter_Engagement_Model__c newCEM = (SymphonyLF__Matter_Engagement_Model__c) cem;
        SymphonyLF__Matter_Engagement_Model__c oldCEM = memMap.get(newCEM.Id);

          
            if (oldCEM != null && newCEM.Is_Active__c != oldCEM.Is_Active__c) {
            updateCEMId.add(newCEM.Id);
            if (oldCEM.SymphonyLF__Assign_to_User__c != null) {
                oldPersonIds.add(oldCEM.SymphonyLF__Assign_to_User__c);
            }
        }
        }
        if (updateCEMId.size() > 0) {
            if (System.isFuture() || System.isBatch()) {
                cmpRPMEMHandler.updateLegalAssistants(updateCEMId, oldPersonIds);
            } else {
                cmpRPMEMHandler.updateLegalAssistantsfuture(updateCEMId, oldPersonIds);
            }
        }
    }
	
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
     
        List<SymphonyLF__Matter_Engagement_Model__c> newRecords = (List<SymphonyLF__Matter_Engagement_Model__c>) this.records;
        Map<Id, SymphonyLF__Matter_Engagement_Model__c> typedOldRecords = new Map<Id, SymphonyLF__Matter_Engagement_Model__c>();
        for (Id recId : existingRecords.keySet()) {
            typedOldRecords.put(
                recId, 
                (SymphonyLF__Matter_Engagement_Model__c) existingRecords.get(recId)
            );
        }
        CheckListInitialAssignmentHandler.initialMEMAssignment(newRecords, typedOldRecords);
    }
    
    public override void onBeforeDelete() {
        system.debug('processBeforeDelete On Trigger');
        MatterEngagementModelDomain m = new MatterEngagementModelDomain();
        //m.processBeforeDelete(oldRecords);
        
        Set<Id> oldMEMRec = new Set<Id>();
        for (SObject mem : this.records) {
            oldMEMRec.add(mem.Id);
        }
        
        if (!oldMEMRec.isEmpty()) {
            if (System.isFuture() || System.isBatch()) {
                cmpRPMEMHandler.deleteAttorneyandLA(oldMEMRec);
            } else {
                cmpRPMEMHandler.deleteAttorneyandLAfuture(oldMEMRec);
            }
        }
    }


    public override void onAfterDelete() {
        MatterEngagementModelDomain m = new MatterEngagementModelDomain();
       
        Set<Id> MEMRec = new Set<Id>();
        for (SObject mem : this.records) {
            MEMRec.add(mem.Id);
        }

        if (System.isFuture() || System.isBatch()) {
                m.memGroupCalculation(new List<Id>(MEMRec));
                
            } else {
                MatterEngagementModelDomain.memGroupCalculationFuture(new List<Id>(MEMRec));
            }
        
        
    }
    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new MEMTriggerHandler(sObjectList);
        }
    }
}