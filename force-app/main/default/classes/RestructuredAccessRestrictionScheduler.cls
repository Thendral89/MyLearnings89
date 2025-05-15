/**
 * @description       : To grant / revoke access from the User via Access restrictions 
 * @author            : Pranav G
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class RestructuredAccessRestrictionScheduler implements Schedulable {
    private static final String TO_BE_GRANTED = 'To Be Granted';
    private static final String TO_BE_ENFORCED = 'To Be Enforced';
    private static final Integer START = 0;

    global void execute(SchedulableContext SC) {
        List<Access_Restriction__c> accessRecords = [SELECT Id, Status__c, Person__r.SymphonyLF__User__c, Client__c, CreatedBy.Email, Client__r.Name, 
                                                        Lookup_Fields__c, ObjectName__c
                                                    FROM Access_Restriction__c
                                                    WHERE Status__c IN (:TO_BE_GRANTED, :TO_BE_ENFORCED)];

        if (!accessRecords.isEmpty()) {
            Database.executeBatch(new RestructuredClientShareControllerbatch(accessRecords , START), 150);
        }
    }
}