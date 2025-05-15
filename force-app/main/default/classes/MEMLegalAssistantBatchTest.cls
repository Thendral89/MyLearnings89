@isTest
private class MEMLegalAssistantBatchTest {

    @testSetup
    static void setupTestData() {
        
        SymphonyLF__Office_Agent__c offag = new SymphonyLF__Office_Agent__c(
        Name = 'Agent1',
        SymphonyLF__Type__c = 'Office',
        SymphonyLF__Active__c = true);
        
            insert offag;
           
         SymphonyLF__Currency__c currencyRecord = new SymphonyLF__Currency__c(Name = 'USD');
        INSERT currencyRecord;
		
         SymphonyLF__Country__c jurisdictionRecord = new SymphonyLF__Country__c(SymphonyLF__Country_Code__c='United States of America');
        insert jurisdictionRecord;
        
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
        
         SymphonyLF__Design__c design = new SymphonyLF__Design__c(
            Name = 'Test Design',
             SymphonyLF__Client__c = clientRecord1.id,
            SymphonyLF__Jurisdiction__c = jurisdictionRecord.id,
            SymphonyLF__Case_Type__c = 'Primary',
         SymphonyLF__Design_Status__c = 'Filed',
         SymphonyLF__Docket_Number__c = 'SYM-DS-100009-IN-P'
        );
        insert design;
        
   
        
    SymphonyLF__Patent__c pat = new SymphonyLF__Patent__c(
            Name = 'Test patent',
             SymphonyLF__Client__c = clientRecord1.id,
            SymphonyLF__Country__c = jurisdictionRecord.id,
            SymphonyLF__Case_Type__c = 'Primary',
        SymphonyLF__Docket_Number__c = 'SYM-DS-100008-IN-P'
        );
        insert pat;
       
        
        SymphonyLF__Patent__c pat1 = new SymphonyLF__Patent__c(
            Name = 'Test patent1',
             SymphonyLF__Client__c = clientRecord1.id,
            SymphonyLF__Country__c = jurisdictionRecord.id,
            SymphonyLF__Case_Type__c = 'Primary',
        SymphonyLF__Docket_Number__c = 'SYM-DS-200008-IN-P'
        );
        insert pat1;
      

      
        SymphonyLF__Matter_Engagement_Model__c attorneyMEM = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Type__c = 'Responsible Attorney',
            SymphonyLF__Assign_to_User__c = person3.Id,
            SymphonyLF__Supervisor_Client_Contact__c = person3.Id,
            SymphonyLF__Client__c = clientRecord1.Id,
            SymphonyLF__Patent__c = pat.id,
            SymphonyLF__Design__c = design.id,
            Is_Active__c = true
        );
        insert attorneyMEM;

       
        SymphonyLF__Matter_Engagement_Model__c oldLAMEM = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Type__c = 'Legal Assistant',
            SymphonyLF__Assign_to_User__c = person3.Id,
            SymphonyLF__Supervisor_Client_Contact__c = person3.Id,
            SymphonyLF__Client__c = clientRecord1.Id,
            SymphonyLF__Patent__c = pat.id,
            SymphonyLF__Design__c = design.id,
            Is_Active__c = true
        );
        insert oldLAMEM;

       
    }

    @isTest
    static void test_MEMLegalAssistantBatch_DeactivateOld_InsertOrUpdateNew() {
        
        List<SymphonyLF__Person__c> people = [SELECT Id, Name FROM SymphonyLF__Person__c ORDER BY Name];
        Id oldLAId = people[0].Id; 
        Id newLAId = people[1].Id; 
        Id attorneyId = people[2].Id; 


        Set<Id> oldLAs = new Set<Id>{ oldLAId };
        Set<Id> newLAs = new Set<Id>{ newLAId };
        Map<Id, Id> laToAttorney = new Map<Id, Id>{ newLAId => attorneyId };

        Test.startTest();
        MEMLegalAssistantBatch batch = new MEMLegalAssistantBatch(oldLAs, newLAs, laToAttorney);
        Database.executeBatch(batch, 1);
        Test.stopTest();

        
        List<SymphonyLF__Matter_Engagement_Model__c> deactivatedMEMs = [
            SELECT Id, Is_Active__c 
            FROM SymphonyLF__Matter_Engagement_Model__c 
            WHERE SymphonyLF__Type__c = 'Legal Assistant' 
            AND SymphonyLF__Assign_to_User__c = :oldLAId
        ];
        
        List<SymphonyLF__Matter_Engagement_Model__c> newLAMEMs = [
            SELECT Id, Is_Active__c, SymphonyLF__Patent__c, SymphonyLF__Design__c, SymphonyLF__Copyright__c
            FROM SymphonyLF__Matter_Engagement_Model__c 
            WHERE SymphonyLF__Type__c = 'Legal Assistant'
            AND SymphonyLF__Assign_to_User__c = :newLAId
        ];
       
    }
}