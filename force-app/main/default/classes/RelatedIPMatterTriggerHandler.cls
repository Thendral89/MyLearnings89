public with sharing class RelatedIPMatterTriggerHandler extends mvSObjectDomain {
    
    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    
    public RelatedIPMatterTriggerHandler(List<SymphonyLF__Related_IP_Matter__c> sObjectList) {
        super(sObjectList);
    }
    
    public override void onAfterInsert() {
        List<Id> recIds = new List<Id>();

        for (SymphonyLF__Related_IP_Matter__c record : (List<SymphonyLF__Related_IP_Matter__c>) records) {
            recIds.add(record.Id);
        }

        if (!recIds.isEmpty()) {
            createSharing(recIds);
        }
    }

    private static void createSharing(List<Id> recIds) {
        if (System.isFuture() || System.isBatch()) {
            cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Related_IP_Matter__Share', recIds);
        } else {
            cmpAPTrgUtilCtrl.OrgRecordSharingfuture('SymphonyLF__Related_IP_Matter__Share', recIds);
        }
    }
    
     public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new RelatedIPMatterTriggerHandler(sObjectList);
        }
    }
}