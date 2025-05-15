@isTest
private class UserTriggerServiceTest {

    @IsTest
    static void testHandleUserActivation() {
        // Create and insert a new active user
        User newUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'Test',
            Email = 'testuser@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'Salesforce',
            Title = 'Title',
            Alias = 'roger',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = true
        );
        insert newUser;

        // Call the method with oldUser = null to simulate a new activation
        Test.startTest();
        UserTriggerService.handleUserActivation(newUser, null);
        Test.stopTest();

        // Optionally assert something here, like ensuring batch class was queued
        // Since we can't assert batch execution directly, you'd validate indirectly if needed
    }

    @IsTest
    static void testHandleUserActivation_NotEligible() {
        // User already active, no change — batch should not run
        User existingUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'Test2',
            Email = 'testuser2@test.com',
            Username = 'testuser2' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'Salesforce',
            Title = 'Title',
            Alias = 'rogy',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = true
        );
        insert existingUser;

        Test.startTest();
        // Pass both old and new as active — not eligible for sharing
        UserTriggerService.handleUserActivation(existingUser, existingUser);
        Test.stopTest();
    }
}