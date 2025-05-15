@isTest
public class SnowFieldVisibilityTest {
    @testSetup
    static void setup() {
        // Create a UserRole for testing
        UserRole role = new UserRole(Name = 'IPSU - Client Operations Support (COS)');
        insert role;

        // Create a User for testing
        User user = new User(
            Alias = 'testusr',
            Email = 'testuser111@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserRoleId = role.Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            Username = 'testuser1111@test.com.test'
        );
        insert user;

        // Create a Client__c record for testing
        /*Client__c client = new Client__c(
            Is_IPSU_Client__c = true,
            ServiceNow_Integration_Required__c = true
        );
        insert client;*/
    }

    @isTest
    static void testCheckServiceNowAccessWithValidClientId() {
        Test.startTest();
            String clientId = '001000000000000'; 
            List<Boolean> result = SnowFieldVisibility.CheckServiceNowAccess(clientId);
        Test.stopTest();
    }

    @isTest
    static void testCheckServiceNowAccessWithException() {
        Test.startTest();
            String invalidClientId = '001INVALID0000000';
            try {
                List<Boolean> result = SnowFieldVisibility.CheckServiceNowAccess(invalidClientId);
            } catch (Exception e) {
            }
        Test.stopTest();
    }
}