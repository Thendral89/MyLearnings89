public class docusignTriggerHandler extends mvSObjectDomain{
    
     @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    
    public docusignTriggerHandler(List<DocuSign_Document__c> sObjectList) {
        super(sObjectList);
    }
    
    public override void onAfterInsert() {
        List<Id> recIds = new List<Id>();

        for (DocuSign_Document__c record : (List<DocuSign_Document__c>) records) {
            recIds.add(record.Id);
        }

        if (!recIds.isEmpty()) {
            createSharing(recIds);
        }
    }

    private static void createSharing(List<Id> recIds) {
        if (System.isFuture() || System.isBatch()) {
            cmpAPTrgUtilCtrl.OrgRecordSharing('DocuSign_Document__Share', recIds);
        } else {
            cmpAPTrgUtilCtrl.OrgRecordSharingfuture('DocuSign_Document__Share', recIds);
        }
    }
    
    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new docusignTriggerHandler(sObjectList);
        }
    }
}