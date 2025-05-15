public with sharing class chainofTitleTriggerHandler extends mvSObjectDomain{
    Map<Id, sObject> oldMap;
    List<sObject> newRecords;
    Map<Id, sObject> newMap;

    public chainofTitleTriggerHandler(List<sObject> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new chainofTitleTriggerHandler(sObjectList);
        }
    }

    public override void onAfterInsert(){
        this.newRecords = records;
        this.newMap = new Map<Id, sObject>( this.newRecords );
        List<id> coTitleIds= new List<id>();

        for(sObject newRecord : this.newRecords){
            coTitleIds.add((Id)newRecord.get('Id'));
        }

        if(coTitleIds.size()>0) {
            if(System.isFuture() || System.isBatch()){
                mvShareUtilities.OrgRecordSharing('SymphonyLF__Chain_of_Title__Share',coTitleIds);
            }else{
                mvShareUtilities.OrgRecordSharingfuture('SymphonyLF__Chain_of_Title__Share',coTitleIds);
            }
        }

    }

}