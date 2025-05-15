public with sharing class AssetIntakeJurisdictionTriggerHandler extends mvSObjectDomain{
    public AssetIntakeJurisdictionTriggerHandler(List<sObject> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new AssetIntakeJurisdictionTriggerHandler(sObjectList);
        }
    }

    Map<Id, sObject> oldMap;
    List<sObject> newRecords;
    Map<Id, sObject> newMap;

    public override void onAfterUpdate(Map<Id, SObject> existingRecords){
        this.newRecords = (List<sObject>) records;
        this.newMap = new Map<Id, sObject>(this.newRecords);
        this.oldMap = (Map<Id, sObject>) existingRecords;

        for(sObject newRecord : this.newRecords){
            sObject oldRecord = this.oldMap.get(newRecord.Id);
            createRelatedRecordsFromJurisdiction(newRecord, oldRecord);
        }

        if(createRelatedRecordsFromJurisdiction.size() > 0){
            createRelatedRecordsFromJurisdiction();
        }
    }

    Set<String> matterLookupFieldToTrack = new Set<String>{
        'Patent__c'
    };

    Set<Id> createRelatedRecordsFromJurisdiction = new Set<Id>();
    static Set<Id> createRelatedRecordsFromJurisdiction_r = new Set<Id>();

    void createRelatedRecordsFromJurisdiction(sObject newRecord, sObject oldRecord){
        if(createRelatedRecordsFromJurisdiction_r.contains( (Id) newRecord.get('Id'))){
            return;
        }

        for(String field : matterLookupFieldToTrack){
            if(newRecord.get(field) != oldRecord.get(field) && ( (Id) newRecord.get(field) != null )){
                createRelatedRecordsFromJurisdiction.add( (Id) newRecord.get('Id') );
                createRelatedRecordsFromJurisdiction_r.add((Id) newRecord.get('Id'));
                break;
            }
        }
    }

    void createRelatedRecordsFromJurisdiction(){
        for(Id i : createRelatedRecordsFromJurisdiction){
            AssetIntakeMatterCreationService a = new AssetIntakeMatterCreationService();
            a.setAssetIntakeId( (Id) (this.newMap.get(i)).get('Asset_Intake_Form__c') );
            a.setAssetIntakeJurisdictionId( i );
            a.createRelatedRecordsFromJurisdiction();
        }
    }
}