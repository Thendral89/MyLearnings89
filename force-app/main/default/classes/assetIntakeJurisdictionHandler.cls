public with sharing class assetIntakeJurisdictionHandler extends mvSObjectDomain {
    Map<Id, sObject>  oldMap;
    List<sObject>     newRecords;
    Map<Id, sObject>  newMap;

    @TestVisible
    private static Boolean triggerDisabled {
        get {
          return false;
        }
        set;
    }

    public assetIntakeJurisdictionHandler(List<sObject> sObjectList) {
      super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new assetIntakeJurisdictionHandler(sObjectList);
        }
    }

    public override void onBeforeInsert() {}

    public override void onAfterUpdate(Map<Id, SObject> existingRecords){
      this.newRecords = records;
      this.newMap = new Map<Id, sObject>( this.newRecords );
      this.oldMap = existingRecords;
    }  
    
}