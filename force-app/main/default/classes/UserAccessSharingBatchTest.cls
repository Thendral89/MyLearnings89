@isTest
public class UserAccessSharingBatchTest {

    @isTest
    static void testBatchWithValidMetadata() {
        // Create test User
        User testUser = new User(
            LastName = 'outside Counsel 1',
            Username = 'testuser.mccipdeveloper1@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        SymphonyLF__Country__c Country = new SymphonyLF__Country__c();
        Country.Name = 'Test';
        insert Country;

        // Create Client
        SymphonyLF__Client__c testClient = new SymphonyLF__Client__c(Name = 'Test Client', SymphonyLF__Entity_Size__c = 'Medium', 
                                            SymphonyLF__Client_Number_New__c = '12345');
        insert testClient;

        // Create some data records to be shared
        SymphonyLF__Patent__c record1 = new SymphonyLF__Patent__c(Name = 'Record 1', SymphonyLF__Client__c = testClient.Id, 
                                            SymphonyLF__Case_Type__c = 'Primary', SymphonyLF__Country__c= Country.id);
        insert record1;

        // Create Custom Metadata (mocked via Custom Metadata Loader or mocking tool if needed)
        ShareableObjects__mdt meta = new ShareableObjects__mdt(
            MasterLabel = 'SymphonyLF__Patent__c',
            Share_Object_API_Name__c = 'SymphonyLF__Patent__Share',
            Row_Cause__c = 'Manual',
            isActive__c = true,
            Parent_Relationship_Path__c = 'SymphonyLF__Client__c'
        );

        Test.startTest();
        UserAccessSharingBatch batch = new UserAccessSharingBatch(testUser.Id, meta);
        Database.executeBatch(batch, 200);
        Test.stopTest();

    }

    @isTest
    static void testBatchWithRestrictedAccess() {
        // Create test User
        User testUser = new User(
            LastName = 'outside Counsel 1',
            Username = 'restricteduser.mccipdeveloper1@example.com',
            Email = 'restricteduser@example.com',
            Alias = 'ruser',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        SymphonyLF__Country__c Country = new SymphonyLF__Country__c();
        Country.Name = 'Test';
        insert Country;

        // Create Client
        SymphonyLF__Client__c restrictedClient = new SymphonyLF__Client__c(Name = 'Restricted Client', SymphonyLF__Entity_Size__c = 'Medium',
                                                SymphonyLF__Client_Number_New__c = '12345');
        insert restrictedClient;

        // Create data record
        SymphonyLF__Patent__c restrictedRecord = new SymphonyLF__Patent__c(Name = 'Restricted Record', SymphonyLF__Client__c = restrictedClient.Id, 
                                                     SymphonyLF__Case_Type__c = 'Primary', SymphonyLF__Country__c= Country.id);
        insert restrictedRecord;

        // Create Access_Restriction__c
        insert new Access_Restriction__c(Client__c = restrictedClient.Id, User__c = testUser.Id);

        // Create Custom Metadata mock
        ShareableObjects__mdt meta = new ShareableObjects__mdt(
            MasterLabel = 'SymphonyLF__Patent__c',
            Share_Object_API_Name__c = 'SymphonyLF__Patent__Share',
            Row_Cause__c = 'Manual',
            isActive__c = true,
            Parent_Relationship_Path__c = 'SymphonyLF__Client__c'
        );

        Test.startTest();
        UserAccessSharingBatch batch = new UserAccessSharingBatch(testUser.Id, meta);
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }

}