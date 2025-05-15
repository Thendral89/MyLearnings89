/*
Created Date    : 06/17/2024
Created By      : Jagadeeswara Rao Kusumuru
#JIRA           : MCC-243
Scheduler       : ConflictCheckEmailRemainders_Schedule
Test Class      : Yet to create
Custom Seting   : Conflict_Check_Email_Settings__c
*/
public with sharing class ConflictCheckEmailRemainders_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {

        // Retrieve all the conflict check records where the CC Status = "Conflict Check Pending" 
        return Database.getQueryLocator([
            SELECT Id, 
                   OwnerId, 
                   Name , 
                   CC_Status__c, 
                   CreatedDate,
                   CreatedById,
                   Client_Name__c,
                   Client_Name__r.Originating_Attorney__c,
                   Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c,
                   Client_Name__r.Originating_Attorney__r.SymphonyLF__Email__c,
                   Client_Name__r.Originating_Attorney__r.SymphonyLF__Active__c,
            	   Client_Name__r.Client_Status__c
            FROM Conflict_Check__c 
            WHERE CC_Status__c = 'Conflict Check Pending'
            LIMIT 5000000]);
        
        // AND CreatedDate <= :Date.today().addDays(-7)
    }

    public void execute(Database.BatchableContext BC, List<Conflict_Check__c> conflictCheckRecords) {

        // List to store all the conflict check records to delete at the end.
        List<Conflict_Check__c> list_CCRecords_Delete = new List<Conflict_Check__c>();

        // List to store all the client records to delete at the end.
        List<SymphonyLF__Client__c> list_ClientRecords_Delete = new lIst<SymphonyLF__Client__c>(); 

        // Set Of UserIDs to send Remiander Bell Notification on  7th day
        Set<String> list_remainderEmailReciepients = new Set<String>();

        // Set Of UserIDs to send Remiander Bell Notification on 13th day 
        Set<String> list_FinalEmailReciepients = new Set<String>();

        // Retrieve Custom setting "CC Email Configurations"
        Conflict_Check_Email_Settings__c customSettingRecord = Conflict_Check_Email_Settings__c.getValues('CC Email Configurations');
        
        // If Custom setting not avaialable in the system return the process.
        if(customSettingRecord == null){
            return;
        }
        system.debug('customSettingRecord ::: '+customSettingRecord);

        //CustomNotificationType customNotificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'CC_Email_Bell_Notifications'];
        // List to strore all the preparec bell notification records to insert to the System
        List<Messaging.CustomNotification> List_bellNotifications_Insert = new List<Messaging.CustomNotification>();
        
        // Iterate all the Conflict Check records that are coming from the Start Method.
        for (Conflict_Check__c conflictCheck : conflictCheckRecords) {
            /*
            1. Conflict check should associate to the client record.
            2. Associated client should have Originating Attorney.
            3. originating Attorney should associate with the User Record.
            4. Originating Attorney should have valid Email.
            5. Originating Atoorney should be Active.
            */
            if(conflictCheck.Client_Name__c != null 
                && conflictCheck.Client_Name__r.Originating_Attorney__c != null 
                && conflictCheck.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c != null 
                && conflictCheck.Client_Name__r.Originating_Attorney__r.SymphonyLF__Email__c!=null
                && conflictCheck.Client_Name__r.Originating_Attorney__r.SymphonyLF__Active__c
            ){
                
                System.debug('Record Found !!');
                //Convert Date time to Date to calculate the days difference between the CreatedDate from Today
                Date createdDate = ((DateTime)conflictCheck.get('CreatedDate')).date();
                Integer daysBetween = createdDate.daysBetween(Date.today());
                System.debug('Days Between: ' + daysBetween);

                /*
                 	EmailService email = new EmailService();
                    email.setEmailTemplate( customSettingRecord.Remainder_Classic_Email_API__c ); // 'Conflict_Check_Notification_after_7days' ==> Remainder_Classic_Email_API__c
                    email.setToAddresses('amar.p@maxval.com');
                    email.setToAddresses( conflictCheck.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c );  //conflictCheck.OwnerId OR CreatedById
                    email.setToAddresses( conflictCheck.CreatedById );  //conflictCheck.OwnerId OR CreatedById
                    email.setWhatId( conflictCheck.Id );  // Conflict Check recored ID
                    email.prepareEmail();
                */
                
                // This block will prepare remainder emails for 7 Days
                if(daysBetween == customSettingRecord.CC_Email_Remainder_Days__c
                    && customSettingRecord.CC_Remainder_Emails_Enable__c
                ){ 
                    
                    EmailService e = new EmailService();
                    e.setEmailTemplate( customSettingRecord.Remainder_Classic_Email_API__c ); // 'Conflict_Check_Notification_after_7days' ==> Remainder_Classic_Email_API__c
                    e.setToAddresses('amar.p@maxval.com');
                    // e.setToAddresses('manish.y@maxval.com');
                    e.setToAddresses( conflictCheck.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c );  //conflictCheck.OwnerId OR CreatedById
                    e.setToAddresses( conflictCheck.CreatedById );  //conflictCheck.OwnerId OR CreatedById
                    e.setWhatId( conflictCheck.Id );  // Conflict Check recored ID
                    e.prepareEmail();

                }

                // This block will prepare remainder emails for 13 Days
                else if(daysBetween == customSettingRecord.CC_Final_Email_Remainder_Day__c 
                        && customSettingRecord.CC_Remainder_Emails_Enable__c)
                {  
                    
                    EmailService e = new EmailService();
                    e.setEmailTemplate( customSettingRecord.Final_Classic_Email_API__c ); // 'Conflict_Check_Notification_after_7days' ==>  Final_Classic_Email_API
                    e.setToAddresses('amar.p@maxval.com');
                    // e.setToAddresses('manish.y@maxval.com');
                    e.setToAddresses( conflictCheck.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c );  //conflictCheck.OwnerId OR CreatedById
                    e.setToAddresses( conflictCheck.CreatedById );  //conflictCheck.OwnerId OR CreatedById
                    e.setWhatId( conflictCheck.Id );  // Conflict Check recored ID
                    e.prepareEmail();


                } else if(daysBetween >= customSettingRecord.CC_Records_Delete_On_Day__c){  
                   
                    system.debug('CC_Records_Delete_On_Day__c ' + string.valueof(daysBetween <= customSettingRecord.CC_Records_Delete_On_Day__c));
                    list_CCRecords_Delete.add(conflictCheck);
                    // Do not want to delete associate Client Records uncheck field "CC Client Records Delete" in Custom setting "Conflict Check Email Settings"
                    
                    if(conflictCheck.Client_Name__r.Client_Status__c == 'Yet to Engage' && customSettingRecord.CC_Client_Records_Delete__c ){ 
                        SymphonyLF__Client__c client = new SymphonyLF__Client__c(Id = conflictCheck.Client_Name__c);
                        list_ClientRecords_Delete.add(client);
                    }

                } 
                /*
                else if(customSettingRecord.CC_Client_Records_Delete__c==true){ 
					
                    system.debug('CC_Client_Records_Delete__c ' + string.valueof(daysBetween <= customSettingRecord.CC_Records_Delete_On_Day__c));
                    
                    if(conflictCheck.Client_Name__r.Client_Status__c == 'Yet to Engage'){ 
                        SymphonyLF__Client__c client = new SymphonyLF__Client__c(Id = conflictCheck.Client_Name__c);
                        list_ClientRecords_Delete.add(client);
                    }

                }
*/
                
                
            } 
        }

        // Send Prepared emails all at once.
        EmailService.sendPreparedEmailInService();
        EmailService.clearService(); 
        
        if(!list_CCRecords_Delete.isEmpty()){
            System.debug('list_CCRecords_Delete ::: '+list_CCRecords_Delete);
            delete list_CCRecords_Delete;
        }
        if(!list_ClientRecords_Delete.isEmpty()){
            System.debug('list_ClientRecords_Delete ::: '+list_ClientRecords_Delete);
            delete list_ClientRecords_Delete;
        }

    }

    public void finish(Database.BatchableContext BC) {
        System.debug('BC ==> '+BC);
    }
}


/*

    Pre-Requisite: The Users have saved the CC record as Draft and the CC status = “Conflict Check Pending”

    Acceptance Criteria: 

    System should notify the User initiating the CC and the Originating Attorney listed on the CC when the CC has been in “Conflict Check Pending” Status for 7 days - “If no action is taken within 7 days, system will purge the CC and the related record details”

    System should also send an Alert notification on the 13th day - “Conflict Check pending for 13 days already. Please take action or system will purge the CC and the related record details”

    On the 14th day post creation of the CC record, system should check the status of the associated Client record:

    If Yet to Engage, purge the Client record and the CC record

    If Active, purge the CC record


Questions :
=======================
1. What if the Originating attorney doesnot have email and is not active, 
   if it matches the criteria are we going to delete the CC record as well as client record
2. 
*/