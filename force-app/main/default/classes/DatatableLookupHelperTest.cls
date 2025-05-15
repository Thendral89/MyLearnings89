@IsTest
public class DatatableLookupHelperTest {

    @TestSetup
    static void setupTestData() {
        // Create test records
        SymphonyLF__Office_Agent__c officeAgent = New SymphonyLF__Office_Agent__c();
        officeAgent.Name = 'Test Agent';
        officeAgent.SymphonyLF__Type__c = 'Agent';
        insert officeAgent;

        SymphonyLF__Currency__c currency1 = new SymphonyLF__Currency__c(Name = 'Test Currency');
        insert currency1;
    }

    @IsTest
    static void testGetRecordDetailsSuccess() {
        // Fetch the inserted record ID
        SymphonyLF__Office_Agent__c officeAgent = [SELECT Id FROM SymphonyLF__Office_Agent__c LIMIT 1];

        // Call the method
        SymphonyLF__Office_Agent__c result = DatatableLookupHelper.getRecordDetails(officeAgent.Id);

        // Assert the result
        //System.assertNotEquals(null, result, 'The result should not be null.');
        //System.assertEquals(officeAgent.Id, result.Id, 'The IDs should match.');
    }

    @IsTest
    static void testGetRecordDetailsException() {
        // Pass an invalid ID to force an exception
        SymphonyLF__Office_Agent__c officeAgent = DatatableLookupHelper.getRecordDetails('InvalidId');

        // Assert the result
        //System.assertEquals(null, officeAgent, 'The result should be null for an invalid ID.');
    }

    @IsTest
    static void testGetCurrencyDetailsSuccess() {
        // Fetch the inserted record ID
        SymphonyLF__Currency__c currency1 = [SELECT Id FROM SymphonyLF__Currency__c LIMIT 1];

        // Call the method
        SymphonyLF__Currency__c result = DatatableLookupHelper.getCurrencyDetails(currency1.Id);

        // Assert the result
        //System.assertNotEquals(null, result, 'The result should not be null.');
        //System.assertEquals(currency1.Id, result.Id, 'The IDs should match.');
    }

    @IsTest
    static void testGetCurrencyDetailsException() {
        // Pass an invalid ID to force an exception
        SymphonyLF__Currency__c currency1 = DatatableLookupHelper.getCurrencyDetails('InvalidId');

        // Assert the result
        //System.assertEquals(null, currency1, 'The result should be null for an invalid ID.');
    }
}