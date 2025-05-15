@isTest
public class AccessRestrictionHelperTest {

    @testSetup
    static void setupData() {
        // Create a test user
        Profile attorneyProfile = [SELECT Id FROM Profile WHERE Name = 'Attorney' LIMIT 1];
        User u = new User(
            Alias = 'testuser',
            Email = 'Attorneytestuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = attorneyProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser_' + System.currentTimeMillis() + '@example.com'
        );
        insert u;
	
        SymphonyLF__Currency__c usdCurrency = new SymphonyLF__Currency__c(Name = 'USD');
        insert usdCurrency;
        
        SymphonyLF__Client__c client = new SymphonyLF__Client__c(
            Name = 'Test Client',
            SymphonyLF__Default_Billing_Currency__c = usdCurrency.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        insert client;
        
        SymphonyLF__Client__c client2 = new SymphonyLF__Client__c(
            Name = 'Test Client',
            SymphonyLF__Default_Billing_Currency__c = usdCurrency.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '1234567'
        );
        insert client2;

        SymphonyLF__Country__c usaCountry = new SymphonyLF__Country__c(Name = 'United States of America');
        insert usaCountry;
        
        SymphonyLF__Country__c wipoCountry = new SymphonyLF__Country__c(Name = 'World Intellectual Property Organization (WIPO)/PCT');
        insert wipoCountry;

        List<SymphonyLF__Patent__c> patentList = new List<SymphonyLF__Patent__c>();
        patentList.add(new SymphonyLF__Patent__c(
            Name = 'test',
            SymphonyLF__Country__c = usaCountry.Id,
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Case_Type__c = 'Continuation'
        )) ;
        
        patentList.add( new SymphonyLF__Patent__c(
            Name = 'test',
            SymphonyLF__Country__c = usaCountry.Id,
            SymphonyLF__Client__c = client2.Id,
            SymphonyLF__Case_Type__c = 'PCT National'
        ));
        
        insert patentList;

        // Create Access Restriction for GRANT
        Access_Restriction__c grantAccess = new Access_Restriction__c(
            ObjectName__c = 'SymphonyLF__Patent__c',
            Patent__c = patentList[0].Id,
            User__c = u.Id,
            Client__c = client.Id,
            Status__c = 'To Be Granted'
        );
        insert grantAccess;

        // Create Access Restriction for REMOVE
        Access_Restriction__c removeAccess = new Access_Restriction__c(
            ObjectName__c = 'SymphonyLF__Patent__c',
            Patent__c = patentList[1].Id,
            User__c = u.Id,
            Client__c = client2.Id,
            Status__c = 'To Be Enforced'
        );
        insert removeAccess;
        
        Access_Restriction__c enforcedAccess = new Access_Restriction__c(
            ObjectName__c = 'SymphonyLF__Patent__c',
            Patent__c = patentList[1].Id,
            User__c = u.Id,
            Client__c = client2.Id,
            Status__c = 'Enforced'
        );
        insert enforcedAccess;
    }

    
    @isTest
    static void testProcessSharingEnforce() {
        Access_Restriction__c ar = [SELECT Id, Lookup_Fields__c, User__c, ObjectName__c, Status__c FROM Access_Restriction__c WHERE Status__c = 'Enforced' LIMIT 1];
        ar.Status__c = 'To be Granted';
        
        Test.startTest();
        	Update ar;
        Test.stopTest();

        System.assertEquals(0 , [SELECT COUNT() FROM Access_Restriction__c WHERE Id = :ar.Id] , 'Should be updated to Enforced');
    }
}