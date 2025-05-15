@isTest
public class CL_DoubleCheckerEmailNotificationTest {

    @testSetup
    static void setupTestData() {
        Profile paralegalProfile = [SELECT Id FROM Profile WHERE Name = 'Paralegal' LIMIT 1];
        Profile legalAssistantProfile = [SELECT Id FROM Profile WHERE Name = 'Legal Assistant' LIMIT 1];

        User paralegalUser = new User(
            FirstName = 'Test',
            LastName = 'Paralegal',
            Email = 'paralegal@test.com',
            Username = 'paralegal@test.com',
            Alias = 'tp',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = paralegalProfile.Id,
            Double_Checker__c = true,
            IsActive = true
        );
        INSERT paralegalUser;

        User legalAssistantUser = new User(
            FirstName = 'Test',
            LastName = 'LegalAssistant',
            Email = 'legalassistant@test.com',
            Username = 'legalassistant@test.com',
            Alias = 'ta',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = legalAssistantProfile.Id,
            Double_Checker__c = true,
            IsActive = true
        );
        INSERT legalAssistantUser;

        System.runAs(legalAssistantUser) {
                EmailTemplate emailTemplate = new EmailTemplate(
                Name = 'Test Email Template',
                DeveloperName = 'Test_Email_Template',
                TemplateType = 'text',
                Subject = 'Test Email Subject',
                Body = 'This is a test email body.',
                FolderId = UserInfo.getUserId(),
                IsActive = true
            );
            INSERT emailTemplate;
        }

        Account testAccount = new Account(Name = 'Test Account');
        INSERT testAccount;
    }

    @isTest
    static void testSendEmailToDoubleCheckers() {
        Test.startTest();
        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Test_Email_Template' LIMIT 1].Id;
        List<CL_DoubleCheckerEmailNotification.InputClass> inputRecords = new List<CL_DoubleCheckerEmailNotification.InputClass>();

        CL_DoubleCheckerEmailNotification.InputClass input1 = new CL_DoubleCheckerEmailNotification.InputClass();
        input1.emailTemplateId = emailTemplateId;
        input1.recordId = [SELECT Id FROM Account LIMIT 1].Id;
        input1.legalAssistant = true;
        input1.paralegal = false;
        inputRecords.add(input1);

        CL_DoubleCheckerEmailNotification.InputClass input2 = new CL_DoubleCheckerEmailNotification.InputClass();
        input2.emailTemplateId = emailTemplateId;
        input2.recordId = [SELECT Id FROM Account LIMIT 1].Id;
        input2.legalAssistant = false;
        input2.paralegal = true;
        inputRecords.add(input2);

        CL_DoubleCheckerEmailNotification.sendEmail(inputRecords);

        Test.stopTest();
    }
}