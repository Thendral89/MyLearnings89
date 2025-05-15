@IsTest
public with sharing class conflictCheckUtilitiesTest {

    
    @isTest
    static void testGetRecentConflictCheckRequests() {
        test.startTest();
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

            SymphonyLF__Inventor_Designer_Author__c testInventor = new SymphonyLF__Inventor_Designer_Author__c(
                SymphonyLF__Contact_Name__c = 'Test Person',
                SymphonyLF__Contact__c = testPerson.Id
            );
            insert testInventor;

            SymphonyLF__Keyword__c keyword = new SymphonyLF__Keyword__c(
                Name = 'Test Keyword'
            );
            insert keyword;
            SymphonyLF__Keyword_Association__c testKeywordAssociation = new SymphonyLF__Keyword_Association__c(
                SymphonyLF__Keyword__c = keyword.Id
            );
            insert testKeywordAssociation;

            SymphonyLF__Chain_of_Title__c testChainOfTitle = new SymphonyLF__Chain_of_Title__c(
                SymphonyLF__Client__c = testClient.Id
            );
            insert testChainOfTitle;

            SymphonyLF__Entity__c testEntity = new SymphonyLF__Entity__c(
                Name = 'Test Entity',
                SymphonyLF__Primary_Contact__c = testPerson.Id
            );
            insert testEntity;
            
            
            // Create Conflict Check Records
            Conflict_Check__c conflictCheck1 = new Conflict_Check__c(
                Client_Name__c = testClient.Id,
                Client_Reference_Number__c = '12345',
                CC_Status__c = 'Conflict Check Pending',
                Matter_Name__c = 'Test Matter'
            );
            insert conflictCheck1;

            // Create Conflict Check Results Records
            Conflict_Check_Search_Result__c conflictCheckResult1 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Client__c = testClient.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult1;
            Conflict_Check_Search_Result__c conflictCheckResult2 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Inventor_Designer_Author__c = testInventor.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult2;
            Conflict_Check_Search_Result__c conflictCheckResult3 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Keyword_Association__c = testKeywordAssociation.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult3;

            Conflict_Check_Search_Result__c conflictCheckResult4 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Chain_of_Title__c = testChainOfTitle.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult4;

            Conflict_Check_Search_Result__c conflictCheckResult5 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Entity__c = testEntity.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult5;
            
            

            // Call the method
            List<conflictCheckWrapper> results = conflictCheckUtilities.getRecentConflictCheckRequests(conflictCheck1.Id);
            
            // Assertions
            System.assertEquals(1, results.size(), 'Expected 1 conflict check request');
            conflictCheckWrapper ccWrapper = results[0];
            System.assertEquals(conflictCheck1.Id, ccWrapper.recordId, 'Record ID should match');
            System.assertEquals(testClient.Name, ccWrapper.clientName, 'Client Name should match');
            test.stopTest();
    }
    
    // Test method for getConflictCheckRequests without recordId
    @isTest
    static void testGetConflictCheckRequestsWithoutRecordId() {
        test.startTest();
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

            SymphonyLF__Inventor_Designer_Author__c testInventor = new SymphonyLF__Inventor_Designer_Author__c(
                SymphonyLF__Contact_Name__c = 'Test Person',
                SymphonyLF__Contact__c = testPerson.Id
            );
            insert testInventor;

            SymphonyLF__Keyword__c keyword = new SymphonyLF__Keyword__c(
                Name = 'Test Keyword'
            );
            insert keyword;
            SymphonyLF__Keyword_Association__c testKeywordAssociation = new SymphonyLF__Keyword_Association__c(
                SymphonyLF__Keyword__c = keyword.Id
            );
            insert testKeywordAssociation;

            SymphonyLF__Chain_of_Title__c testChainOfTitle = new SymphonyLF__Chain_of_Title__c(
                SymphonyLF__Client__c = testClient.Id
            );
            insert testChainOfTitle;

            SymphonyLF__Entity__c testEntity = new SymphonyLF__Entity__c(
                Name = 'Test Entity',
                SymphonyLF__Primary_Contact__c = testPerson.Id
            );
            insert testEntity;


            // Create Conflict Check Records
            Conflict_Check__c conflictCheck1 = new Conflict_Check__c(
                Client_Name__c = testClient.Id,
                Client_Reference_Number__c = '12345',
                CC_Status__c = 'Conflict Check Pending',
                Matter_Name__c = 'Test Matter'
            );
            insert conflictCheck1;

            // Create Conflict Check Results Records
            Conflict_Check_Search_Result__c conflictCheckResult1 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Client__c = testClient.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult1;
            Conflict_Check_Search_Result__c conflictCheckResult2 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Inventor_Designer_Author__c = testInventor.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult2;
            Conflict_Check_Search_Result__c conflictCheckResult3 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Keyword_Association__c = testKeywordAssociation.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult3;
            Conflict_Check_Search_Result__c conflictCheckResult4 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Chain_of_Title__c = testChainOfTitle.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult4;

            Conflict_Check_Search_Result__c conflictCheckResult5 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Entity__c = testEntity.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult5;

            // Call the method without recordId
            List<conflictCheckWrapper> results = conflictCheckUtilities.getConflictCheckRequests(null);

            // Assertions
            System.assertEquals(1, results.size(), 'Expected 1 conflict check request');
            conflictCheckWrapper ccWrapper = results[0];
            System.assertEquals(conflictCheck1.Id, ccWrapper.recordId, 'Record ID should match');
            System.assertEquals(testClient.Name, ccWrapper.clientName, 'Client Name should match');
            test.stopTest();
    }
    
    // Test method for getConflictCheckRequests with recordId
    @isTest
    static void testGetConflictCheckRequestsWithRecordId() {
        test.startTest();
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

            SymphonyLF__Inventor_Designer_Author__c testInventor = new SymphonyLF__Inventor_Designer_Author__c(
                SymphonyLF__Contact_Name__c = 'Test Person',
                SymphonyLF__Contact__c = testPerson.Id
            );
            insert testInventor;


            // Create Conflict Check Records
            Conflict_Check__c conflictCheck1 = new Conflict_Check__c(
                Client_Name__c = testClient.Id,
                Client_Reference_Number__c = '12345',
                CC_Status__c = 'Conflict Check Pending',
                Matter_Name__c = 'Test Matter'
            );
            insert conflictCheck1;

            // Create Conflict Check Results Records
            Conflict_Check_Search_Result__c conflictCheckResult1 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Client__c = testClient.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult1;
            Conflict_Check_Search_Result__c conflictCheckResult2 = new Conflict_Check_Search_Result__c(
                Conflict_Check__c = conflictCheck1.Id,
                Inventor_Designer_Author__c = testInventor.Id,
                Is_Verified__c = true
            );
            insert conflictCheckResult2;

            // Call the method with recordId
            List<conflictCheckWrapper> results = conflictCheckUtilities.getConflictCheckRequests(conflictCheck1.Id);

            // Assertions
            System.assertEquals(1, results.size(), 'Expected 1 conflict check request');
            conflictCheckWrapper ccWrapper = results[0];
            System.assertEquals(conflictCheck1.Id, ccWrapper.recordId, 'Record ID should match');
            System.assertEquals(testClient.Name, ccWrapper.clientName, 'Client Name should match');
            test.stopTest();
        }
}