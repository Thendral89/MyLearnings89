public class imanageDocTriggerHandler extends mvSObjectDomain {

    
    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    
    public imanageDocTriggerHandler(List<iManage_Documents__c> sObjectList) {
        super(sObjectList);
    }
    
    public override void onAfterInsert() {
        List<Id> recIds = new List<Id>();

        for (iManage_Documents__c record : (List<iManage_Documents__c>) records) {
            recIds.add(record.Id);
        }

        if (!recIds.isEmpty()) {
            createSharing(recIds);
        }
    }

    private static void createSharing(List<Id> recIds) {
        if (System.isFuture() || System.isBatch()) {
            cmpAPTrgUtilCtrl.OrgRecordSharing('iManage_Documents__Share', recIds);
        } else {
            cmpAPTrgUtilCtrl.OrgRecordSharingfuture('iManage_Documents__Share', recIds);
        }
    }
    
     public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new imanageDocTriggerHandler(sObjectList);
        }
    }
}