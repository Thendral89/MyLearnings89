@isTest
public class legalAssistantBatchTest {

    @testSetup
    static void setupData() {
      
        
        SymphonyLF__Office_Agent__c offag = new SymphonyLF__Office_Agent__c(
        Name = 'Agent1',
        SymphonyLF__Type__c = 'Office',
        SymphonyLF__Active__c = true);
        
            insert offag;
          
         SymphonyLF__Currency__c currencyRecord = new SymphonyLF__Currency__c(Name = 'USD');
        INSERT currencyRecord;

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

       
        SymphonyLF__Person__c person3 = new SymphonyLF__Person__c(
            Name = 'Test Person3',
            SymphonyLF__Contact_Type__c = 'Attorney',
            SymphonyLF__Type__c = 'Internal',
            SymphonyLF__Office_Agent__c = offag.id
        );
        insert person3;
        
         SymphonyLF__Client__c clientRecord1 = new SymphonyLF__Client__c(
            Name = 'MCCIP Client11',
            SymphonyLF__Default_Billing_Currency__c = currencyRecord.id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        INSERT clientRecord1;

       
        SymphonyLF__Client_Engagement_Model__c model1 = new SymphonyLF__Client_Engagement_Model__c(
            SymphonyLF__Client__c = clientRecord1.id,
            SymphonyLF__Type__c = 'Working Attorney',
            SymphonyLF__Person__c = person3.Id,
            SymphonyLF__Applicable_to_all_jurisdiction__c = true,
            Is_Active__c = true,
            Is_Default__c = true
        );
        insert model1;

      
      
    }

    @isTest
    static void testBatchExecution() {
        List<SymphonyLF__Person__c> people = [SELECT Id, Name FROM SymphonyLF__Person__c ORDER BY Name];
        Id oldLAId = people[0].Id; 
        Id newLAId = people[1].Id; 
        Id attorneyId = people[2].Id; 

        Map<Id, Id> laToAttorneyMap = new Map<Id, Id>{
            oldLAId => attorneyId,
            newLAId => attorneyId
        };

        legalAssistantBatch batch = new legalAssistantBatch(
            new Set<Id>{oldLAId},
            new Set<Id>{newLAId},
            laToAttorneyMap
        );
        
             SymphonyLF__Currency__c currencyRecord = new SymphonyLF__Currency__c(Name = 'USD');
        INSERT currencyRecord;
      
        SymphonyLF__Client__c cc = [select id from SymphonyLF__Client__c limit 1];
       SymphonyLF__Person__c ps = [select id from SymphonyLF__Person__c limit 1];
        
    SymphonyLF__Client_Engagement_Model__c testCEM = new SymphonyLF__Client_Engagement_Model__c(
    SymphonyLF__Client__c = cc.id,
    SymphonyLF__Type__c = 'Legal Assistant',
    SymphonyLF__Person__c = ps.id, 
    SymphonyLF__Applicable_to_all_jurisdiction__c = true,
    Is_Active__c = false,
    Is_Default__c = true
);
insert testCEM;

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

      
        List<SymphonyLF__Client_Engagement_Model__c> oldCEMs = [
            SELECT Is_Active__c FROM SymphonyLF__Client_Engagement_Model__c 
            WHERE SymphonyLF__Person__c = :oldLAId
        ];
        System.assert(!oldCEMs.isEmpty(), 'Old LA CEM should exist');
        System.assertEquals(false, oldCEMs[0].Is_Active__c, 'Old LA CEM should be inactive');

      
        List<SymphonyLF__Client_Engagement_Model__c> newCEMs = [
            SELECT Is_Active__c FROM SymphonyLF__Client_Engagement_Model__c 
            WHERE SymphonyLF__Person__c = :newLAId
        ];
       System.assert(!newCEMs.isEmpty(), 'New LA CEM should exist');
        System.assertEquals(true, newCEMs[0].Is_Active__c, 'New LA CEM should be active');
    }

    @isTest
    static void testOnlyNewLAProvided() {
        List<SymphonyLF__Person__c> people = [SELECT Id FROM SymphonyLF__Person__c ORDER BY Name];
        Id newLAId = people[2].Id; 
        Id attorneyId = people[0].Id;

        Map<Id, Id> laToAttorneyMap = new Map<Id, Id>{
            newLAId => attorneyId
        };

        legalAssistantBatch batch = new legalAssistantBatch(
            new Set<Id>{newLAId},
            laToAttorneyMap
        );

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        List<SymphonyLF__Client_Engagement_Model__c> newLACEMs = [
            SELECT Is_Active__c 
            FROM SymphonyLF__Client_Engagement_Model__c 
            WHERE SymphonyLF__Person__c = :newLAId
        ];
        
    }
}