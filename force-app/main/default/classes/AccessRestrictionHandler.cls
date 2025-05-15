public without sharing class AccessRestrictionHandler extends mvSObjectDomain {
	
    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    public AccessRestrictionHandler(List<Access_Restriction__c> sObjectList) {
        super(sObjectList);
    }

    public override void onBeforeInsert() {}
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {}

    public override void onAfterInsert() {
        System.debug('ENTERED HANDLER');
        AccessRestrictionHelper.processSharing(this.records , Null);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Map<Id, Access_Restriction__c> oldMap = (Map<Id, Access_Restriction__c>) existingRecords;
        AccessRestrictionHelper.processSharing(this.records , oldMap);
    }
    
    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new AccessRestrictionHandler(sObjectList);
        }
    }

}