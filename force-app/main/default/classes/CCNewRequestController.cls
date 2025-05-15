public without sharing class CCNewRequestController {
    public CCNewRequestController() {
    }
    @AuraEnabled
    public static SymphonyLF__Client__c getRecordClient(String recordId){
        return [SELECT Id, SymphonyLF__Client_Group_Number__c, Client_Status__c FROM 
                SymphonyLF__Client__c WHERE Id =: recordId];
    }
}