public without sharing class ClientTriggerHandler extends mvSObjectDomain {
    
    @TestVisible
    private static Boolean triggerDisabled {
      get {
        return false;
      }
      set;
    }
    
    public ClientTriggerHandler(List<SymphonyLF__Client__c> sObjectList) {
        super(sObjectList);
    }

    public override void onBeforeInsert() {
        for(Sobject rec : this.records){
            defaultActiveField(rec);
        }
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Map<Id, SymphonyLF__Client__c> oldMap = (Map<Id, SymphonyLF__Client__c>) existingRecords;

        for(Sobject rec : this.records){
            defaultActiveField(rec);
        }

        ClientDomain d = new ClientDomain();
        d.setNewRecords(this.records , oldMap);
        d.actionOnBeforeUpdate();
    }

    public override void onAfterInsert() {
        ClientEngagementHelper.createSharing(this.records);
        ClientEngagementHelper.processClientEngagementModels(this.records , null);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Map<Id, SymphonyLF__Client__c> oldMap = (Map<Id, SymphonyLF__Client__c>) existingRecords;
        ClientEngagementHelper.processClientEngagementModels(this.records , oldMap);
    }

    private void defaultActiveField(sObject rec){
        Id countryId = Label.Default_Jurisdiction_on_Client;
        if( String.valueOf( rec.get('Client_Status__c') ) == 'Active'){
            rec.put('SymphonyLF__Active__c', true);
        }
        else{
            rec.put('SymphonyLF__Active__c', false);
        }
        rec.put('Jurisdiction__c',countryId);
    }
    
    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new ClientTriggerHandler(sObjectList);
        }
    }

}