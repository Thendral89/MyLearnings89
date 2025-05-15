@isTest
public class DynamicSearchRecordsTest {

    @isTest
    static void testDynamicQueryRecords() {
        
        String query = 'SELECT Id, Name FROM Account';
        
        // Test the method
        Test.startTest();
        List<SObject> results = DynamicSearchRecords.DynamicQueryRecords(query);
        Test.stopTest();

        // Assert that the list is not null and is empty
        System.assert(results != null, 'Results should not be null.');
        System.assertEquals(0, results.size(), 'Results should be an empty list.');
    }

    @isTest
    static void testDynamicSearchRecords() {
        // Test_Parameters
        String objectName = 'Account';
        List<String> searchFields = new List<String>{'Name'};
        String fieldsToFetch = 'Id, Name';
        String searchString = 'Test';
        List<String> selectedRecId = new List<String>{'001XXXXXXXXXXXX'};
        String additionalCond = 'Name != NULL';
        String orderBy = 'Name ASC';
        Integer numOfRecs = 10;
        Boolean hasEncryptedFieldSearch = false;
        String returnUniqueValueFor = '';

        // Test the method
        Test.startTest();
        List<SObject> results = DynamicSearchRecords.DynamicSearchRecords(
            objectName, searchFields, fieldsToFetch, searchString,
            selectedRecId, additionalCond, orderBy, numOfRecs,
            hasEncryptedFieldSearch, returnUniqueValueFor
        );
        Test.stopTest();

        // Assert that the list is not null and is empty
        System.assert(results != null, 'Results should not be null.');
        System.assertEquals(0, results.size(), 'Results should be an empty list.');
    }

    @isTest
    static void testRetrieveQueryRecords() {
        // Sample query
        String query = 'SELECT Id, FirstName, LastName FROM Contact';

        // Test the method
        Test.startTest();
        List<SObject> results = DynamicSearchRecords.RetrieveQueryRecords(query);
        Test.stopTest();

        // Assert that the list is not null and is empty
        System.assert(results != null, 'Results should not be null.');
        System.assertEquals(0, results.size(), 'Results should be an empty list.');
    }

    @isTest
    static void testRetrieveSearchRecords() {
        // Test parameters
        String objectName = 'Contact';
        List<String> searchFields = new List<String>{'FirstName', 'LastName'};
        String fieldsToFetch = 'Id, FirstName, LastName';
        String searchString = 'Test Name';
        List<String> selectedRecId = new List<String>{'003XXXXXXXXXXXX'};
        String additionalCond = 'LastName != NULL';
        String orderBy = 'FirstName DESC';
        Integer numOfRecs = 5;
        Boolean hasEncryptedFieldSearch = true;
        String returnUniqueValueFor = '';

        // Test the method
        Test.startTest();
        List<SObject> results = DynamicSearchRecords.RetrieveSearchRecords(
            objectName, searchFields, fieldsToFetch, searchString,
            selectedRecId, additionalCond, orderBy, numOfRecs,
            hasEncryptedFieldSearch, returnUniqueValueFor
        );
        Test.stopTest();

        // Assert that the list is not null and is empty
        System.assert(results != null, 'Results should not be null.');
        System.assertEquals(0, results.size(), 'Results should be an empty list.');
    }

    /*@isTest
    static void testGetRecords() {
        // Test parameters
        String objectName = 'Contact';
        List<String> searchFields = new List<String>{'FirstName', 'Email'};
            String fieldsToFetch = 'Id, FirstName, Email';
        String searchString = 'test@example.com';
        List<String> selectedRecId = new List<String>{};
            String additionalCond = 'Email != NULL';
        String orderBy = 'FirstName ASC';
        Integer numOfRecs = 20;
        Boolean hasEncryptedFieldSearch = false;
        
        // Test the method
        Test.startTest();
        List<SObject> results = DynamicSearchRecords.getRecords(
            objectName, searchFields, fieldsToFetch, searchString,
            selectedRecId, additionalCond, orderBy, numOfRecs,
            hasEncryptedFieldSearch
        );
        Test.stopTest();
        
        // Assert that the list is not null and is empty
        System.assert(results != null, 'Results should not be null.');
        System.assertEquals(0, results.size(), 'Results should be an empty list.');
    } */
}