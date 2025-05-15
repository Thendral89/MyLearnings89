public with sharing class InventorDesignerTriggerHandler extends mvSObjectDomain{
    Map<Id, sObject> oldMap;
    List<sObject> newRecords;
    Map<Id, sObject> newMap;

    public InventorDesignerTriggerHandler(List<sObject> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new InventorDesignerTriggerHandler(sObjectList);
        }
    }

    public override void onAfterInsert(){
        this.newRecords = records;
        this.newMap = new Map<Id, sObject>( this.newRecords );
        List<id> InventorIds= new List<id>();

        for(sObject newRecord : this.newRecords){
            InventorIds.add((Id)newRecord.get('Id'));
        }

        if(InventorIds.size()>0) {
            if(System.isFuture() || System.isBatch()){
                mvShareUtilities.OrgRecordSharing('SymphonyLF__Inventor_Designer_Author__Share',InventorIds);
            }else{
                mvShareUtilities.OrgRecordSharingfuture('SymphonyLF__Inventor_Designer_Author__Share',InventorIds);
            }
        }

    }

}