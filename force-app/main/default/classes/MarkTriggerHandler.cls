public with sharing class MarkTriggerHandler extends mvSObjectDomain{

    Map<Id, sObject> oldMap;
    List<sObject> newRecords;
    Map<Id, sObject> newMap;

    public MarkTriggerHandler(List<sObject> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new MarkTriggerHandler(sObjectList);
        }
    }

    public override void onAfterInsert(){
        this.newRecords = records;
        this.newMap = new Map<Id, sObject>( this.newRecords );
        List<id> MarkIds= new List<id>();

        for(sObject newRecord : this.newRecords){
            MarkIds.add((Id)newRecord.get('Id'));
        }

        if(MarkIds.size()>0) {
            if(System.isFuture() || System.isBatch()){
                mvShareUtilities.OrgRecordSharing('SymphonyLF__Mark__Share',MarkIds);
            }else{
                mvShareUtilities.OrgRecordSharingfuture('SymphonyLF__Mark__Share',MarkIds);
            }
        }

    }


}