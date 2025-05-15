@IsTest
public class PersonSelectorTest {
    @IsTest
    static void testSelectByIdOrUserIdsWithValidData() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User userRecord = new User(
            Alias = 'standtss', 
            Email='standardusers@testorgs.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testings', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = profile.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='newusers90099001@testorg.com'
        );
        INSERT userRecord;
        SymphonyLF__Person__c personRecord = new SymphonyLF__Person__c(
            Name = 'inventors',
            SymphonyLF__Email__c = 'test@gmail.com.com',
            SymphonyLF__User__c = userRecord.Id,
            SymphonyLF__Type__c = 'Client',
            SymphonyLF__Contact_Type__c = 'Author'
        );
        INSERT personRecord;

        PersonSelector selector = new PersonSelector();
        selector.setFields(new List<String>{'Id', 'Name', 'SymphonyLF__User__c'});

        Set<Id> recordIds = new Set<Id>{personRecord.Id};
        Set<Id> userIds = new Set<Id>{userRecord.Id};

        Map<Id, SymphonyLF__Person__c> result = selector.selectByIdOrUserIds(null, new Set<Id>());
        Assert.areEqual(0, result.size(), 'Result map size should be 0');

        result = selector.selectByIdOrUserIds(recordIds, userIds);
        Assert.areEqual(1, result.size(), 'Result map size should be 1');
    }

    // @IsTest
    // static void testSelectByIdOrUserIdsWithNoMatches() {
    //     // Arrange
    //     PersonSelector selector = new PersonSelector();
    //     selector.setFields(new List<String>{'Id', 'Name'});

    //     Set<Id> recordIds = new Set<Id>{'001xxxxxxxxxxxxAAA'}; // Non-existent Id
    //     Set<Id> userIds = new Set<Id>{'005xxxxxxxxxxxxCCC'}; // Non-existent User Id

    //     // Act
    //     Map<Id, SymphonyLF__Person__c> result = selector.selectByIdOrUserIds(recordIds, userIds);

    //     // Assert
    //     System.assertEquals(0, result.size(), 'Result map size should be 0 for no matching records');
    // }

    // @IsTest
    // static void testSelectByIdOrUserIdsWithEmptyInputs() {
    //     // Arrange
    //     PersonSelector selector = new PersonSelector();
    //     selector.setFields(new List<String>{'Id', 'Name'});

    //     Set<Id> recordIds = new Set<Id>();
    //     Set<Id> userIds = new Set<Id>();

    //     // Act
    //     Map<Id, SymphonyLF__Person__c> result = selector.selectByIdOrUserIds(recordIds, userIds);

    //     // Assert
    //     System.assertEquals(0, result.size(), 'Result map size should be 0 for empty inputs');
    // }

    // @IsTest
    // static void testSelectByIdOrUserIdsWithNullInputs() {
    //     // Arrange
    //     PersonSelector selector = new PersonSelector();
    //     selector.setFields(new List<String>{'Id', 'Name'});

    //     // Act
    //     Map<Id, SymphonyLF__Person__c> result = selector.selectByIdOrUserIds(null, null);

    //     // Assert
    //     System.assertEquals(0, result.size(), 'Result map size should be 0 for null inputs');
    // }

    // @IsTest
    // static void testSelectByIdOrUserIdsWithPartialFields() {
    //     // Arrange
    //     List<SymphonyLF__Person__c> personRecords = new List<SymphonyLF__Person__c>{
    //         new SymphonyLF__Person__c(Name = 'Test Person', SymphonyLF__User__c = '005xxxxxxxxxxxxDDD')
    //     };
    //     insert personRecords;

    //     PersonSelector selector = new PersonSelector();
    //     selector.setFields(new List<String>{'Id'});

    //     Set<Id> recordIds = new Set<Id>{personRecords[0].Id};

    //     // Act
    //     Map<Id, SymphonyLF__Person__c> result = selector.selectByIdOrUserIds(recordIds, null);

    //     // Assert
    //     System.assertEquals(1, result.size(), 'Result map size should match the number of matching records');
    //     System.assertEquals(personRecords[0].Id, result.get(personRecords[0].Id).Id, 'Result should contain the correct record');
    //     System.assert(result.get(personRecords[0].Id).Name == null, 'Fields not included in the query should be null');
    // }
}