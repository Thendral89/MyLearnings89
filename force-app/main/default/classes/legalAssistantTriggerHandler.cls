public without sharing class legalAssistantTriggerHandler extends mvSObjectDomain {

    @TestVisible
    private static Boolean triggerDisabled {
        get {
            return false;
        }
        set;
    }

    public legalAssistantTriggerHandler(List<Legal_Assistant__c> sObjectList) {
        super(sObjectList);
    }

    public override void onAfterInsert() {
        Set<Id> newPersonIds = new Set<Id>();
        Map<Id, Id> laToAttorneyMap = new Map<Id, Id>();

        for (Legal_Assistant__c la : (List<Legal_Assistant__c>)records) {
            if (la.Legal_Assistant__c != null && la.Attorney_Paralegal__c != null) {
                newPersonIds.add(la.Legal_Assistant__c);
                laToAttorneyMap.put(la.Legal_Assistant__c, la.Attorney_Paralegal__c);
            }
        }

        if (!newPersonIds.isEmpty() && !laToAttorneyMap.isEmpty()) {
            Database.executeBatch(new legalAssistantBatch(newPersonIds, laToAttorneyMap), 2000);
            
             Database.executeBatch(new MEMLegalAssistantBatch(newPersonIds, laToAttorneyMap), 2000);
        }
    }

    // public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    //     List<Legal_Assistant__c> currentRecs = (List<Legal_Assistant__c>)records;

    //     for (Legal_Assistant__c newLA : currentRecs) {
    //         Legal_Assistant__c oldLA = (Legal_Assistant__c)existingRecords.get(newLA.Id);

    //         if (oldLA.Legal_Assistant__c != newLA.Legal_Assistant__c && oldLA.Legal_Assistant__c != null) {
    //             Id oldPersonId = oldLA.Legal_Assistant__c;
    //             Id newPersonId = newLA.Legal_Assistant__c;
    //             Id attorneyId = oldLA.Attorney_Paralegal__c;

    //             Map<Id, Id> laToAttorneyMap = new Map<Id, Id>{
    //                 oldPersonId => attorneyId
    //             };

    //             Set<Id> oldPersonIds = new Set<Id>{ oldPersonId };
    //             Set<Id> newPersonIds = new Set<Id>{ newPersonId };
				
    //             Database.executeBatch(new legalAssistantBatch(oldPersonIds, newPersonIds, laToAttorneyMap), 2000);
                
    //             Database.executeBatch(new MEMLegalAssistantBatch(oldPersonIds, newPersonIds, laToAttorneyMap), 2000);
    //             System.debug('Invoked MEMLegalAssistantBatch on update');
    //         }
    //     }
    // }

    public override void onAfterDelete() {
    List<Legal_Assistant__c> deletedRecs = (List<Legal_Assistant__c>)records;

    for (Legal_Assistant__c oldLA : deletedRecs) {
        
        if (oldLA.Legal_Assistant__c != null && oldLA.Attorney_Paralegal__c != null) {
            Id oldPersonId = oldLA.Legal_Assistant__c;
            Id attorneyId = oldLA.Attorney_Paralegal__c;

            Map<Id, Id> laToAttorneyMap = new Map<Id, Id>{
                oldPersonId => attorneyId
            };

            Set<Id> oldPersonIds = new Set<Id>{ oldPersonId };
            Set<Id> newPersonIds = new Set<Id>(); // No new person on delete

            Database.executeBatch(new legalAssistantBatch(oldPersonIds, newPersonIds, laToAttorneyMap), 2000);
            Database.executeBatch(new MEMLegalAssistantBatch(oldPersonIds, newPersonIds, laToAttorneyMap), 2000);

            System.debug('Invoked LegalAssistant and MEM batches on delete');
        }
    }
}


    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new legalAssistantTriggerHandler(sObjectList);
        }
    }
}