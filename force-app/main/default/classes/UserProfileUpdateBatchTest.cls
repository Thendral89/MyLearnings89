@isTest
public class UserProfileUpdateBatchTest {

    @testSetup
    static void setup() {
        // Fetch standard profiles
        Profile oldProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile newProfile = [SELECT Id FROM Profile WHERE Name = 'Marketing User' LIMIT 1];

        // Create test users with old profile
        for (Integer i = 0; i < 2; i++) {
            User u = new User(
                FirstName = 'Test',
                LastName = 'User' + i,
                Email = 'testuser' + i + '@example.com',
                Username = 'testuser' + i + '@example.com.' + System.currentTimeMillis(),
                Alias = 'tusr' + i,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = oldProfile.Id,
                IsActive = true
            );
            insert u;
        }
    }

    @isTest
    static void testUserProfileUpdateBatch_StandardProfiles() {
        UserProfileUpdateBatch.execute(null);
    }
}