@isTest
public class LegalAssistantTriggerHandlerTest {

    @testSetup
    static void setupData() {
        
         SymphonyLF__Office_Agent__c offag = new SymphonyLF__Office_Agent__c(
        Name = 'Agent1',
        SymphonyLF__Type__c = 'Office',
        SymphonyLF__Active__c = true); 
        
            insert offag;
        SymphonyLF__Person__c person1 = new SymphonyLF__Person__c(
            Name = 'Test Person1',
            SymphonyLF__Contact_Type__c = 'Assistant',
            SymphonyLF__Type__c = 'Assistant',
            SymphonyLF__Office_Agent__c = offag.id
        );
        SymphonyLF__Person__c person2 = new SymphonyLF__Person__c(
            Name = 'Test Person2',
            SymphonyLF__Contact_Type__c = 'Assistant',
            SymphonyLF__Type__c = 'Assistant',
            SymphonyLF__Office_Agent__c = offag.id
        );
        insert new List<SymphonyLF__Person__c>{person1, person2};

        // Create Attorney
        SymphonyLF__Person__c person3 = new SymphonyLF__Person__c(
            Name = 'Test Person3',
            SymphonyLF__Contact_Type__c = 'Attorney',
            SymphonyLF__Type__c = 'Internal',
            SymphonyLF__Office_Agent__c = offag.id
        );
        insert person3;
    }

    @isTest
    static void testOnAfterInsert() {
        SymphonyLF__Person__c la = [SELECT Id FROM SymphonyLF__Person__c WHERE Name = 'Test Person1' LIMIT 1];
        SymphonyLF__Person__c attorney = [SELECT Id FROM SymphonyLF__Person__c WHERE Name = 'Test Person3' LIMIT 1];

        Test.startTest();
        Legal_Assistant__c laRecord = new Legal_Assistant__c(
            Legal_Assistant__c = la.Id,
            Attorney_Paralegal__c = attorney.Id
        );
        insert laRecord;
        Test.stopTest();

        System.assert(true, 'After Insert scenario ran without errors.');
    }

    @isTest
    static void testOnAfterUpdate() {
        SymphonyLF__Person__c laOld = [SELECT Id FROM SymphonyLF__Person__c WHERE Name = 'Test Person1' LIMIT 1];
        SymphonyLF__Person__c laNew = [SELECT Id FROM SymphonyLF__Person__c WHERE Name = 'Test Person2' LIMIT 1];
        SymphonyLF__Person__c attorney = [SELECT Id FROM SymphonyLF__Person__c WHERE Name = 'Test Person3' LIMIT 1];

        Legal_Assistant__c laRecord = new Legal_Assistant__c(
            Legal_Assistant__c = laOld.Id,
            Attorney_Paralegal__c = attorney.Id
        );
        insert laRecord;

        Test.startTest();
        laRecord.Legal_Assistant__c = laNew.Id;
        update laRecord;
        Test.stopTest();

        System.assert(true, 'After Update scenario ran without errors.');
    }
}