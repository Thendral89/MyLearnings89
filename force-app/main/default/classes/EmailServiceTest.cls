@isTest
public with sharing class EmailServiceTest {
    
    @isTest 
    private static void test(){
        
        Checklist__c checklist = new Checklist__c(
            Name = 'Test checklist',
            Checklist_Code__c = 'checklist'
        );
        insert checklist;
        
        Checklist_Instance__c checklistInstance = new Checklist_Instance__c(
            Checklist__c = checklist.Id
        );
        insert checklistInstance;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User primaryInventorUser = new User(Alias = 'test1', Email='standarduser1@testorg.com', 
                                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                            LocaleSidKey='en_US', ProfileId = p.Id, 
                                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com.foobarious');
        
        User additionalInventorUser = new User(Alias = 'test1', Email='standarduser2@testorg.com', 
                                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                               LocaleSidKey='en_US', ProfileId = p.Id, 
                                               TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com.foobarious');
        
        insert new List<User>{ primaryInventorUser, additionalInventorUser};
            
            SymphonyLF__Person__c primaryInventorPersonRecord = new SymphonyLF__Person__c();
        primaryInventorPersonRecord.SymphonyLF__User__c = primaryInventorUser.Id;
        primaryInventorPersonRecord.SymphonyLF__Email__c = 'standarduser1@testorg.com';
        primaryInventorPersonRecord.First_Name__c='JohnDoe';
        primaryInventorPersonRecord.Last_Name__c='JohnDoe';
        primaryInventorPersonRecord.SymphonyLF__Type__c='Client';
        primaryInventorPersonRecord.SymphonyLF__Contact_Type__c='Author';
        
        SymphonyLF__Person__c additionalInventorPersonRecord = new SymphonyLF__Person__c();
        additionalInventorPersonRecord.SymphonyLF__User__c = additionalInventorUser.Id;
        additionalInventorPersonRecord.SymphonyLF__Email__c = 'standarduser2@testorg.com.foobarious';
        additionalInventorPersonRecord.First_Name__c='JohnDoe';
        additionalInventorPersonRecord.Last_Name__c='JohnDoe';
        additionalInventorPersonRecord.SymphonyLF__Type__c='Client';
        additionalInventorPersonRecord.SymphonyLF__Contact_Type__c='Author';
        
        insert new List<SymphonyLF__Person__c>{ primaryInventorPersonRecord, additionalInventorPersonRecord};
            
            EmailService e = new EmailService();
        e.setCcAddress(primaryInventorUser.Id);
        e.setCcAddress(new List<String>{ primaryInventorUser.Id } );
        e.setToAddresses(additionalInventorUser.Id);
        e.setToAddresses(new List<String>{ additionalInventorUser.Id } );
        e.setToAddresses(new Set<Id>{ additionalInventorUser.Id } );
        //e.setFormattingEmailBody(new List<String>{''});
        //e.setFormattingEmailSubject(new List<String>{''});
        e.prepareEmail();
        e.setEmailTemplate('Secretary_Assignment_Template');
        e.setFinalWhatId(checklistInstance.Id);
        e.prepareEmail();
        e.turnOffStandardEmailLogging();
        e.sendPreparedEmailInThisInstance();
        e.getMailToBeSentInThisInstance();
        e.setCurrentRecursiveIdentifier('');
        
        EmailService.sendPreparedEmailInService();
        EmailService.validateMailDeliveryInService();
        EmailService.getAllMailsToBeSentInService();
        EmailService.setRecursiveCheckInService('');
        EmailService.clearService();
    }
    
    @istest
    static void invocableTest() {
        Checklist__c checklist = new Checklist__c(
            Name = 'Test checklist',
            Checklist_Code__c = 'checklist'
        );
        insert checklist;
        
        Checklist_Instance__c checklistInstance = new Checklist_Instance__c(
            Checklist__c = checklist.Id
        );
        insert checklistInstance;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User primaryInventorUser = new User(Alias = 'test1', Email='standarduser1@testorg.com', 
                                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                            LocaleSidKey='en_US', ProfileId = p.Id, 
                                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com.foobarious');
        
        User additionalInventorUser = new User(Alias = 'test1', Email='standarduser2@testorg.com', 
                                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                               LocaleSidKey='en_US', ProfileId = p.Id, 
                                               TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com.foobarious');
        
        insert new List<User>{ primaryInventorUser, additionalInventorUser};
            
        SymphonyLF__Person__c primaryInventorPersonRecord = new SymphonyLF__Person__c();
        primaryInventorPersonRecord.SymphonyLF__User__c = primaryInventorUser.Id;
        primaryInventorPersonRecord.SymphonyLF__Email__c = 'standarduser1@testorg.com';
        primaryInventorPersonRecord.First_Name__c='JohnDoe';
        primaryInventorPersonRecord.Last_Name__c='JohnDoe';
        primaryInventorPersonRecord.SymphonyLF__Type__c='Client';
        primaryInventorPersonRecord.SymphonyLF__Contact_Type__c='Author';
        
        SymphonyLF__Person__c additionalInventorPersonRecord = new SymphonyLF__Person__c();
        additionalInventorPersonRecord.SymphonyLF__User__c = additionalInventorUser.Id;
        additionalInventorPersonRecord.SymphonyLF__Email__c = 'standarduser2@testorg.com.foobarious';
        additionalInventorPersonRecord.First_Name__c='JohnDoe';
        additionalInventorPersonRecord.Last_Name__c='JohnDoe';
        additionalInventorPersonRecord.SymphonyLF__Type__c='Client';
        additionalInventorPersonRecord.SymphonyLF__Contact_Type__c='Author';
        
        insert new List<SymphonyLF__Person__c>{ primaryInventorPersonRecord, additionalInventorPersonRecord};
            
        EmailService.InvocableRequest request = new EmailService.InvocableRequest();
        request.emailTemplateDeveloperName = 'Secretary_Assignment_Template';
        request.finalWhatId = checklistInstance.Id;
        request.toAddress = additionalInventorUser.Id;
        request.toAddresses = new List<String>{ additionalInventorUser.Id } ;
            
        EmailService.get(new List<EmailService.InvocableRequest> {request}); 
    }
}