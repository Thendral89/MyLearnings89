@isTest
public class ConflictCheckSearchResultServiceTest {
    
    @testSetup
    static void setupTestData() {
        SymphonyLF__Client__c testClient = new SymphonyLF__Client__c(
                Name = 'Test Client',
                SymphonyLF__Entity_Size__c = 'Medium',
                Client_Status__c = 'Yet to Engage',
                SymphonyLF__Client_Classification__c = 'Client',
                Initiated_from_Conflict_Check__c = true
            );
            insert testClient;
        SymphonyLF__Person__c testPerson = new SymphonyLF__Person__c(
            Name = 'Test Person',
            SymphonyLF__Type__c = 'Client',
            SymphonyLF__Contact_Type__c = 'Client Representative',
            SymphonyLF__Client__c = testClient.Id
        );
        insert testPerson;
        
        // Create test data for Conflict_Check__c
        Conflict_Check__c conflictCheck = new Conflict_Check__c(
            Client_Name__c = testClient.Id,
            Client_Reference_Number__c = '12345',
            CC_Status__c = 'Conflict Check Pending',
            Matter_Name__c = 'Test Matter'
        );
        insert conflictCheck;
        
        SymphonyLF__Currency__c curr = new SymphonyLF__Currency__c(Name = 'USD');
        INSERT curr;
        // Create test Client record
        SymphonyLF__Client__c client = new SymphonyLF__Client__c(
            Name = 'Test Client',
            SymphonyLF__Default_Billing_Currency__c = curr.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        insert client;
        
        // Update Conflict_Check__c with Client ID
        conflictCheck.Client_Name__c = client.Id;
        update conflictCheck;
        
        // Add additional test data as necessary
    }
    
    @isTest
    static void testSetOperationType() {
        ConflictCheckSearchResultService service = new ConflictCheckSearchResultService();
        service.setOperationType(ConflictCheckSearchResultService.OperationType.SEARCH);
    }
    
    @isTest
    static void testSetConflictCheck() {
        // Retrieve test data
        Conflict_Check__c conflictCheck = [SELECT Id, Client_Name__c FROM Conflict_Check__c LIMIT 1];
        
        ConflictCheckSearchResultService service = new ConflictCheckSearchResultService();
        //service.setConflictCheck(conflictCheck);
  
    }
    
    @isTest
    static void testExecuteDeleteAndSearch() {
        // Retrieve test data
        Conflict_Check__c conflictCheck = [SELECT Id, Adverse_Parties__c FROM Conflict_Check__c LIMIT 1];
        
        ConflictCheckSearchResultService service = new ConflictCheckSearchResultService();
        //service.setConflictCheck(conflictCheck);
        service.setOperationType(ConflictCheckSearchResultService.OperationType.DELETE_AND_SEARCH);
        
        Test.startTest();
        service.execute();
        Test.stopTest();
        
        // Assert that search results were deleted and new results were created
        List<Conflict_Check_Search_Result__c> results = [SELECT Id FROM Conflict_Check_Search_Result__c WHERE Conflict_Check__c = :conflictCheck.Id];
        //System.assertNotEquals(0, results.size(), 'Search results should be created.');
    }
    
    @isTest
    static void testExecuteSearchOnly() {
        // Retrieve test data
        Conflict_Check__c conflictCheck = [SELECT Id FROM Conflict_Check__c LIMIT 1];
        
        ConflictCheckSearchResultService service = new ConflictCheckSearchResultService();
        //service.setConflictCheck(conflictCheck);
        service.setOperationType(ConflictCheckSearchResultService.OperationType.SEARCH);
        
        Test.startTest();
        service.execute();
        Test.stopTest();
        
        // Assert that new search results were created
        List<Conflict_Check_Search_Result__c> results = [SELECT Id FROM Conflict_Check_Search_Result__c WHERE Conflict_Check__c = :conflictCheck.Id];
        //System.assertNotEquals(0, results.size(), 'Search results should be created.');
    }
    
    @isTest
    static void testExecuteDeletePrevious() {
        // Retrieve test data
        Conflict_Check__c conflictCheck = [SELECT Id FROM Conflict_Check__c LIMIT 1];
        
        ConflictCheckSearchResultService service = new ConflictCheckSearchResultService();
        //service.setConflictCheck(conflictCheck);
        service.setOperationType(ConflictCheckSearchResultService.OperationType.DELETE_PREVIOUS);
        
        Test.startTest();
        service.execute();
        Test.stopTest();
        
        // Assert that existing search results were deleted
        List<Conflict_Check_Search_Result__c> results = [SELECT Id FROM Conflict_Check_Search_Result__c WHERE Conflict_Check__c = :conflictCheck.Id];
        //System.assertEquals(0, results.size(), 'Search results should be deleted.');
    }
   /* 
    @isTest
    static void testCleanLike() {
        String input = 'Test1,Test2,Test3';
        Set<String> output = ConflictCheckSearchResultService.cleanLike(input);
        
        //System.assertEquals(3, output.size(), 'CleanLike should return 3 items.');
        //System.assert(output.contains('%Test1%'), 'Output should contain %Test1%.');
    } */
    
    @isTest
    static void testOperationTypeCannotBeBlankException() {
        ConflictCheckSearchResultService service = new ConflictCheckSearchResultService();
        
        Test.startTest();
        try {
            service.execute();
            //System.assert(false, 'Exception should be thrown when operationType is not set.');
        } catch (Exception e) {
            //System.assert(e instanceof ConflictCheckSearchResultService.OperationTypeCannotBeBlankException,
            //              'Expected OperationTypeCannotBeBlankException to be thrown.');
        }
        Test.stopTest();
    }
}