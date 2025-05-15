public class checklistTriggerHandler extends mvSObjectDomain {

     @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    
    public checklistTriggerHandler(List<Checklist__c> sObjectList) {
        super(sObjectList);
    }
    
    public override void onAfterInsert() {
        List<Id> recIds = new List<Id>();

        for (Checklist__c record : (List<Checklist__c>) records) {
            recIds.add(record.Id);
        }

        if (!recIds.isEmpty()) {
            createSharing(recIds);
        }
    }

    private static void createSharing(List<Id> recIds) {
        if (System.isFuture() || System.isBatch()) {
            cmpAPTrgUtilCtrl.OrgRecordSharing('Checklist__Share', recIds);
        } else {
            cmpAPTrgUtilCtrl.OrgRecordSharingfuture('Checklist__Share', recIds);
        }
    }
    
     public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new checklistTriggerHandler(sObjectList);
        }
    }
}