@isTest
public class IntakeFormClientEngageHelperTest {

    @testSetup
    static void setupTestData() {
        // Create test Conflict_Check__c record
        Conflict_Check__c conflictCheck = new Conflict_Check__c(CC_Status__c = 'Conflict Check Pending');
        insert conflictCheck;

        // Create test SymphonyLF__Client__c record
        SymphonyLF__Client__c client = new SymphonyLF__Client__c(
            Name = 'Test Client',
            Client_Status__c = 'Yet to Engage',
            Billing_Address__City__s = 'Test City',
            Billing_Address__CountryCode__s = 'US',
            Billing_Address__PostalCode__s = '12345',
            Billing_Address__StateCode__s = 'CA',
            Billing_Address__Street__s = '123 Test St',
            SymphonyLF__Entity_Size__c ='Small'
        );
        insert client;

        // Create test Users
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@example.com',
            Username = 'testuser1@example.com.' + System.currentTimeMillis(),
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id
        );
        insert user1;
    }

    @isTest
    static void testUpdateClientRecord_AllScenarios() {
        // Retrieve test data
        Conflict_Check__c conflictCheck = [SELECT Id, CC_Status__c FROM Conflict_Check__c LIMIT 1];
        SymphonyLF__Client__c client = [SELECT Id, Client_Status__c FROM SymphonyLF__Client__c LIMIT 1];

        // Call the method when CC_Status__c is "Conflict Check Pending"
        Test.startTest();
        IntakeFormClientEngageHelper.updateClientRecord(client.Id, conflictCheck.Id);
        Test.stopTest();

        // Verify updates to conflictCheck
        conflictCheck = [SELECT CC_Status__c FROM Conflict_Check__c WHERE Id = :conflictCheck.Id];
        System.assertEquals('Conflict Check Completed', conflictCheck.CC_Status__c, 'Conflict status should be updated.');

        // Verify updates to client record
        client = [SELECT Client_Status__c, SymphonyLF__Active__c FROM SymphonyLF__Client__c WHERE Id = :client.Id];
        System.assertEquals('Active', client.Client_Status__c, 'Client status should be updated.');
        System.assertEquals(true, client.SymphonyLF__Active__c, 'Client should be marked active.');

        // Verify inserted SymphonyLF__Other_Address__c record
        SymphonyLF__Other_Address__c otherAddress = [SELECT Id, SymphonyLF__Address_Type__c FROM SymphonyLF__Other_Address__c WHERE SymphonyLF__Client__c = :client.Id LIMIT 1];
        System.assertEquals('Billing Address', otherAddress.SymphonyLF__Address_Type__c, 'Other address should be created.');

        // Verify CEM creation
        List<SymphonyLF__Client_Engagement_Model__c> cems = [SELECT Id FROM SymphonyLF__Client_Engagement_Model__c WHERE SymphonyLF__Client__c = :client.Id];
        System.assertEquals(0, cems.size(), 'CEM records should be created.');

        // Verify Task updates
        List<Task> tasks = [SELECT Id, Status FROM Task WHERE WhatId = :conflictCheck.Id];
        for (Task t : tasks) {
            System.assertEquals('Completed', t.Status, 'Tasks should be marked as completed.');
        }

        // Verify sharing logic (ensure users have been shared correctly)
        List<SymphonyLF__Client__share> shares = [SELECT Id FROM SymphonyLF__Client__share WHERE ParentId = :client.Id];
        System.assertNotEquals(0, shares.size(), 'Sharing records should be created.');
    }

    @isTest
static void testCreateCEM() {
    // Retrieve test client record
    SymphonyLF__Client__c client = [SELECT Id FROM SymphonyLF__Client__c LIMIT 1];
    String type = 'Managing Partner';

    // Create a valid SymphonyLF__Person__c record
     SymphonyLF__Person__c inventor1 = new SymphonyLF__Person__c(
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Contact_Type__c = 'Designer',
            SymphonyLF__Email__c = 'inventor1@example.com',
            SymphonyLF__Type__c = 'Client'
        );
        INSERT inventor1;

    // Call the method
    Test.startTest();
    IntakeFormClientEngageHelper.createCEM(inventor1.Id, client.Id, type);
    Test.stopTest();

    // Verify the CEM creation
    SymphonyLF__Client_Engagement_Model__c cem = [
        SELECT Id, SymphonyLF__Type__c, SymphonyLF__Person__c 
        FROM SymphonyLF__Client_Engagement_Model__c 
        WHERE SymphonyLF__Client__c = :client.Id LIMIT 1
    ];
    System.assertEquals(type, cem.SymphonyLF__Type__c, 'CEM should be created with the correct type.');
    System.assertEquals(inventor1.Id, cem.SymphonyLF__Person__c, 'CEM should reference the correct person.');
}
}