/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-19-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class RelatedRecordController {
    @AuraEnabled(cacheable=true)
    public static String getRelatedRecordId(Id recordId) {
        String objectApiName = recordId.getSObjectType().getDescribe().getName();
        
        if (objectApiName == 'SymphonyLF__Email_Tracker__c') {
            SymphonyLF__Email_Tracker__c emailTracker = [
                SELECT RelatedTo_ID__c 
                FROM SymphonyLF__Email_Tracker__c 
                WHERE Id = :recordId
                LIMIT 1
            ];
            return emailTracker.RelatedTo_ID__c;
        }
        return null; 
    }
}