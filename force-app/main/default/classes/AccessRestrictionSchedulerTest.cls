@isTest
private class AccessRestrictionSchedulerTest {
    
    @testSetup
    static void setupTestData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com.' + System.currentTimeMillis(),
            ProfileId = p.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;


        User u1 = [SELECT Id FROM User WHERE Id =: testUser.Id];
        SymphonyLF__Person__c inv = new SymphonyLF__Person__c();
        inv.Name ='inventors';
        inv.SymphonyLF__Email__c='test@gmail.com.com';
        inv.SymphonyLF__User__c =u1.Id;
        inv.SymphonyLF__Type__c='Client';
        inv.SymphonyLF__Contact_Type__c='Author';
        insert inv ;
        
        SymphonyLF__Country__c Country = new SymphonyLF__Country__c();
        Country.SymphonyLF__Active__c=true;
        Country.SymphonyLF__Country_Code__c='IN';
        Country.Name='India';
		insert Country;        
            
        SymphonyLF__Client__c Client = new SymphonyLF__Client__c();
        Client.SymphonyLF__Active__c=true;
        Client.Name='India';
        Client.SymphonyLF__Entity_Size__c='Small';
        Client.SymphonyLF__Client_Number_New__c='000001';
		insert Client;    
        
        SymphonyLF__Patent__c pat = new SymphonyLF__Patent__c();
        pat.SymphonyLF__First_Named_Inventor__c =inv.Id;
        pat.SymphonyLF__Internal_Counsel__c = u1.id;
        pat.SymphonyLF__Patent_Number__c = '123test';
        pat.SymphonyLF__Case_Type__c='Continuation';
        pat.SymphonyLF__Client__c=Client.Id;
        pat.SymphonyLF__Country__c=Country.Id;
        insert pat; 
        

        List<Access_Restriction__c> accessRecords = new List<Access_Restriction__c>();

        Access_Restriction__c grantAccess = new Access_Restriction__c(
            Status__c = 'To Be Granted',
            Person__c = inv.Id,
            Client__c = Client.Id
        );

        Access_Restriction__c enforceAccess = new Access_Restriction__c(
            Status__c = 'To Be Enforced',
            Person__c = inv.Id,
            Client__c = Client.Id
        );

        accessRecords.add(grantAccess);
        accessRecords.add(enforceAccess);
        insert accessRecords;
    }

    @isTest
    static void testAccessRestrictionScheduler() {
        Test.startTest();
        AccessRestrictionScheduler scheduler = new AccessRestrictionScheduler();
        //NewAccessRestrictionScheduler scheduler = new NewAccessRestrictionScheduler();
        scheduler.execute(null);
        Test.stopTest();

        List<Access_Restriction__c> updatedRecords = [SELECT Id, Status__c FROM Access_Restriction__c];
        System.assertEquals(2, updatedRecords.size(), 'There should be 2 updated access restriction records');

        for (Access_Restriction__c record : updatedRecords) {
            System.assert(record.Status__c == 'Enforced' || record.Status__c == 'To Be Granted', 'Status should be updated properly');
        }
    }

    @isTest
    static void testClientShareControllerBatch() {
        List<Access_Restriction__c> accessRecords = [SELECT Id, Status__c, Person__c, Person__r.SymphonyLF__User__c, Client__c, CreatedBy.Email, Client__r.Name, 
                                                        Lookup_Fields__c, ObjectName__c
                                                    FROM Access_Restriction__c];

        Id testUserId = accessRecords[0].Person__c;
        Id testClientId = accessRecords[0].Client__c;
        Integer start = 0;

        ClientShareControllerBatch batchJob = new ClientShareControllerBatch(false, testUserId, testClientId, accessRecords);
		//NewClientShareControllerbatch batchJob = new NewClientShareControllerbatch(accessRecords, start);
        
        Test.startTest();
        Database.executeBatch(batchJob, 100);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM SymphonyLF__Patent__Share WHERE UserOrGroupId = :testUserId], 'Verify that access was updated correctly');
    }
}