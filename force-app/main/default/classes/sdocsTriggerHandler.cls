public class sdocsTriggerHandler extends mvSObjectDomain{
    
    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    
    public sdocsTriggerHandler(List<SDOC__SDoc__c> sObjectList) {
        super(sObjectList);
    }
    
    public override void onAfterInsert() {
        List<Id> recIds = new List<Id>();

        for (SDOC__SDoc__c record : (List<SDOC__SDoc__c>) records) {
            recIds.add(record.Id);
        }

        if (!recIds.isEmpty()) {
            createSharing(recIds);
        }
    }

    private static void createSharing(List<Id> recIds) {
        if (System.isFuture() || System.isBatch()) {
            cmpAPTrgUtilCtrl.OrgRecordSharing('SDOC__SDoc__Share', recIds);
        } else {
            cmpAPTrgUtilCtrl.OrgRecordSharingfuture('SDOC__SDoc__Share', recIds);
        }
    }
    
    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new sdocsTriggerHandler(sObjectList);
        }
    }
}