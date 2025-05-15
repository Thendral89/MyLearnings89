public with sharing class PatentFamilyTriggerHandler extends mvSObjectDomain{
    Map<Id, sObject> oldMap;
    List<sObject> newRecords;
    Map<Id, sObject> newMap;

    public PatentFamilyTriggerHandler(List<sObject> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new PatentFamilyTriggerHandler(sObjectList);
        }
    }

    public override void onAfterInsert(){
        this.newRecords = records;
        this.newMap = new Map<Id, sObject>( this.newRecords );
        List<id> PatentFamilyIds= new List<id>();

        for(sObject newRecord : this.newRecords){
            PatentFamilyIds.add((Id)newRecord.get('Id'));
        }

        if(PatentFamilyIds.size()>0) {
            if(System.isFuture() || System.isBatch()){
                mvShareUtilities.OrgRecordSharing('SymphonyLF__Patent_Family__Share',PatentFamilyIds);
            }else{
                mvShareUtilities.OrgRecordSharingfuture('SymphonyLF__Patent_Family__Share',PatentFamilyIds);
            }
        }

    }

}