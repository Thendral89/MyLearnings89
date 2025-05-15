@IsTest
private class UserTriggerHandlerTest {
    
    @IsTest
    static void testHandleUserActivation() {
        // Create and insert a new active user
        User newUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'Test',
            Email = 'testuser.mccipdeveloper23@test.com',
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

    }
    
    @IsTest
    static void testHandleUserActivationudpate() {
        // Create and insert a new active user
        User newUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'Test',
            Email = 'testuser.mccipdeveloper23@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'Salesforce',
            Title = 'Title',
            Alias = 'roger',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = false
        );
        insert newUser;
		
        newUser.IsActive = true;
        update newUser;
    }
}