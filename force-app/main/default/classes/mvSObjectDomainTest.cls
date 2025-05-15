@isTest
public class mvSObjectDomainTest {
    
    @isTest
    static void testTriggerHandler() {
        // Test data
        Case testCase1 = new Case(
            Subject = 'Trigger Handler Test 1',
            Status = 'New',
            Origin = 'Email'
        );

        Case testCase2 = new Case(
            Subject = 'Trigger Handler Test 2',
            Status = 'New',
            Origin = 'Phone'
        );

        Test.startTest();
        
        // Before insert
        insert new List<Case>{testCase1, testCase2};
        mvSObjectDomain.triggerHandler(mvSObjectDomain.class);

        // After insert and before update
        testCase1.Status = 'In Progress';
        testCase2.Status = 'Closed';
        update new List<Case>{testCase1, testCase2};
        mvSObjectDomain.triggerHandler(mvSObjectDomain.class);

        // After update and before delete
        delete new List<Case>{testCase1, testCase2};
        mvSObjectDomain.triggerHandler(mvSObjectDomain.class);

        // Test undelete
        undelete new List<Case>{testCase1, testCase2};
        mvSObjectDomain.triggerHandler(mvSObjectDomain.class);

        Test.stopTest();
    }

    @isTest
    static void testDomainMethods() {
        // Prepare test data
        Case testCase = new Case(
            Subject = 'Domain Method Test',
            Status = 'New',
            Origin = 'Web'
        );

        insert testCase;

        List<SObject> sObjectList = [SELECT Id, Subject, Status FROM Case WHERE Id = :testCase.Id];

        Test.startTest();
        
        mvSObjectDomain domain = new mvSObjectDomain(sObjectList);

        // Test getters
        System.assertNotEquals(null, domain.getSObjectType(), 'SObjectType should not be null');
        System.assertEquals(sObjectList, domain.getRecords(), 'Record list should match the input list');

        // Test lifecycle methods
        domain.onApplyDefaults();
        domain.onValidate();
        domain.onValidate(new Map<Id, SObject>{testCase.Id => testCase});
        domain.onBeforeInsert();
        domain.onBeforeUpdate(new Map<Id, SObject>{testCase.Id => testCase});
        domain.onBeforeDelete();
        domain.onAfterInsert();
        domain.onAfterUpdate(new Map<Id, SObject>{testCase.Id => testCase});
        domain.onAfterDelete();
        domain.onAfterUndelete();
        domain.handleBeforeDelete();
        domain.handleBeforeInsert();
        domain.handleBeforeUpdate(new Map<Id, SObject>{testCase.Id => testCase});
        domain.handleAfterUndelete();
        domain.handleAfterDelete();
        domain.handleAfterUpdate(new Map<Id, SObject>{testCase.Id => testCase});
	
        // Test error handling
        Schema.DescribeFieldResult fieldDesc = Case.Status.getDescribe();
        Schema.sObjectField field = fieldDesc.getSObjectField();
        
        String errorMessage = 'Sample error';
        String errorResponse = domain.error(errorMessage, testCase);
        System.assertEquals(errorMessage, errorResponse, 'Error message should match');
        
        String fieldErrorResponse = domain.error(errorMessage, testCase, field);
        System.assertEquals(errorMessage, fieldErrorResponse, 'Field error message should match');

        Test.stopTest();
    }

    @isTest
    static void testIConstructableWithCase() {
        // Prepare test Case records
        Case case1 = new Case(Subject = 'Construct Test Case 1', Status = 'New');
        Case case2 = new Case(Subject = 'Construct Test Case 2', Status = 'New');
        insert new List<Case>{case1, case2};

        List<SObject> testRecords = [SELECT Id, Subject, Status FROM Case WHERE Subject LIKE 'Construct Test Case%'];

        // Use the MockConstructable class to call construct
        mvSObjectDomain.IConstructable constructable = new MockConstructable();
        mvSObjectDomain domainInstance = constructable.construct(testRecords);

        // Assert the domain instance was initialized correctly
        System.assertNotEquals(null, domainInstance, 'Domain instance should not be null');
        System.assertEquals(2, domainInstance.records.size(), 'Expected two records in the domain object');
        System.assertEquals('Construct Test Case 1', ((Case)domainInstance.records[0]).Subject, 'First Case Subject mismatch');
        System.assertEquals('Construct Test Case 2', ((Case)domainInstance.records[1]).Subject, 'Second Case Subject mismatch');
    }

    @isTest
    static void testDomainException() {
        // Test DomainException
        Test.startTest();
        try {
            throw new mvSObjectDomain.DomainException('Test exception');
        } catch (Exception e) {
            System.assert(e instanceof mvSObjectDomain.DomainException, 'Exception should be of type DomainException');
            System.assertEquals('Test exception', e.getMessage(), 'Exception message mismatch');
        }
        Test.stopTest();
    }

    // Mock class for IConstructable
    public class MockConstructable implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new mvSObjectDomain(sObjectList);
        }
    }
}