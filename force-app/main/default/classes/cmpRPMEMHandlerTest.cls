@isTest
public class cmpRPMEMHandlerTest {
    
    @testSetup
    static void setupData() {
    TestDataFactory.createMasterData();
    TestDataFactory.createClient();
        
         SymphonyLF__Office_Agent__c offag = new SymphonyLF__Office_Agent__c(
        Name = 'Agent1',
        SymphonyLF__Type__c = 'Office',
        SymphonyLF__Active__c = true);
        
            insert offag;
        // Create Person (with Legal Assistant)
         SymphonyLF__Person__c person = new SymphonyLF__Person__c(
            Name = 'Test Person',
            SymphonyLF__Contact_Type__c = 'Attorney',
            SymphonyLF__Type__c = 'Internal',
            SymphonyLF__Office_Agent__c = offag.id
        );
        insert person;
        SymphonyLF__Person__c person1 = new SymphonyLF__Person__c(
            Name = 'Test Person 1',
            SymphonyLF__Contact_Type__c = 'Attorney',
            SymphonyLF__Type__c = 'Internal',
            SymphonyLF__Office_Agent__c = offag.id
        );
        insert person1;
        
        SymphonyLF__Person__c legalAssistantPerson = new SymphonyLF__Person__c(
            Name = 'Test Legal Assistant',
            SymphonyLF__Contact_Type__c = 'Attorney',
            SymphonyLF__Type__c = 'Internal',
            SymphonyLF__Office_Agent__c = offag.id
        );
        insert legalAssistantPerson;

        Legal_Assistant__c la = new Legal_Assistant__c(
        Attorney_Paralegal__c = person.id,
        Legal_Assistant__c = legalAssistantPerson.id);
        insert la;
        
        
        
        SymphonyLF__Copyright__c copyright = new SymphonyLF__Copyright__c(
            Name = 'Test Copyright',
            SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Status__c = 'Application Preparation'
        );
        insert copyright;
        
        // Create a Design record (related to the MEM record)
        SymphonyLF__Design__c design = new SymphonyLF__Design__c(
            Name = 'Test Design',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Case_Type__c = 'Similar'
        );
        insert design;

        // Create a Matter Engagement Model (MEM) record for person
        SymphonyLF__Matter_Engagement_Model__c mem = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = person.Id,  
            SymphonyLF__Copyright__c = copyright.Id 
        );
        insert mem;
}

    @isTest
    static void testMemCreationLegalAssistant() {
        // Create Person (with Legal Assistant)
        
       SymphonyLF__Matter_Engagement_Model__c mem = [SELECT Id FROM SymphonyLF__Matter_Engagement_Model__c LIMIT 1];
    
        Legal_Assistant__c la = [SELECT Id FROM Legal_Assistant__c LIMIT 1];
    	SymphonyLF__Copyright__c copyright = [SELECT Id FROM SymphonyLF__Copyright__c LIMIT 1];
        
    Set<Id> memIds = new Set<Id>{mem.Id};
        Test.startTest();
        cmpRPMEMHandler.memCreationLegalAssistant(memIds);
        Test.stopTest();
        
    }
    
    @isTest
    static void testupdateMem() {
        
        Set<Id> newRecordId = new Set<Id>();
        Set<Id> oldRecordId = new Set<Id>();
        
        SymphonyLF__Person__c person = [SELECT Id FROM SymphonyLF__Person__c LIMIT 1];
        Legal_Assistant__c la = [SELECT Id FROM Legal_Assistant__c LIMIT 1];
		SymphonyLF__Copyright__c copyright = [SELECT Id FROM SymphonyLF__Copyright__c LIMIT 1];
        // Create a Matter Engagement Model (MEM) record for person (this will trigger creation of a Legal Assistant MEM)
        // 
        SymphonyLF__Matter_Engagement_Model__c mem = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = person.Id, 
            SymphonyLF__Copyright__c = copyright.Id 
        );
        insert mem;

         List<SymphonyLF__Matter_Engagement_Model__c> existingMEM = [
            SELECT Id, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Type__c, SymphonyLF__Copyright__c
            FROM SymphonyLF__Matter_Engagement_Model__c
            WHERE SymphonyLF__Copyright__c = :copyright.Id
        ];
          Map<Id, SymphonyLF__Matter_Engagement_Model__c> oldMap = new Map<Id, SymphonyLF__Matter_Engagement_Model__c>();
        for (SymphonyLF__Matter_Engagement_Model__c oldmem : existingMEM) {
            oldMap.put(oldmem.Id, oldmem);
            oldRecordId.add(oldmem.Id);
        }
        List<SymphonyLF__Matter_Engagement_Model__c> newRecords = new List<SymphonyLF__Matter_Engagement_Model__c>();
        for (SymphonyLF__Matter_Engagement_Model__c mem1 : existingMEM) {
            newRecords.add(new SymphonyLF__Matter_Engagement_Model__c(
                Id = mem1.Id,
                SymphonyLF__Supervisor_Client_Contact__c = person.Id,
                SymphonyLF__Type__c = 'Attorney'  // Update Type
            ));
            newRecordId.add(mem1.Id);
        }
        
        
        Test.startTest();
        cmpRPMEMHandler.updateLegalAssistants(newRecordId, oldRecordId);
        Test.stopTest();
    }
    
    
 @isTest
    static void testdeleteMem() {
        
        Set<Id> oldRecordId = new Set<Id>();
        
	SymphonyLF__Person__c person = [SELECT Id FROM SymphonyLF__Person__c LIMIT 1];
    SymphonyLF__Client__c client =   [SELECT Id FROM SymphonyLF__Client__c LIMIT 1];
        SymphonyLF__Country__c jurisdiction = [SELECT Id FROM SymphonyLF__Country__c LIMIT 1];
        // Create a Copyright record
        SymphonyLF__Copyright__c copyright = new SymphonyLF__Copyright__c(
            Name = 'Test Copyright',
             SymphonyLF__Client__c = client.Id,
            SymphonyLF__Jurisdiction__c = jurisdiction.Id,
            SymphonyLF__Status__c = 'Application Preparation'
        );
        insert copyright;

        // Create a Matter Engagement Model (MEM) record for person (this will trigger creation of a Legal Assistant MEM)
        SymphonyLF__Matter_Engagement_Model__c mem = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = person.Id, 
            SymphonyLF__Copyright__c = copyright.Id 
        );
        insert mem;

         List<SymphonyLF__Matter_Engagement_Model__c> existingMEM = [
            SELECT Id, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Type__c, SymphonyLF__Copyright__c, SymphonyLF__Design__c, SymphonyLF__Agreements_Contracts__c, SymphonyLF__Dispute_Opposition__c, SymphonyLF__General_Matter__c, SymphonyLF__Patent__c, SymphonyLF__Trademark__c
            FROM SymphonyLF__Matter_Engagement_Model__c
            WHERE SymphonyLF__Copyright__c = :copyright.Id
        ];
        /*  Map<Id, SymphonyLF__Matter_Engagement_Model__c> oldMap = new Map<Id, SymphonyLF__Matter_Engagement_Model__c>();
        for (SymphonyLF__Matter_Engagement_Model__c oldmem : existingMEM) {
            oldMap.put(oldmem.Id, oldmem);
        }*/
        List<SymphonyLF__Matter_Engagement_Model__c> oldRecords = new List<SymphonyLF__Matter_Engagement_Model__c>();
        for (SymphonyLF__Matter_Engagement_Model__c mem1 : existingMEM) {
            oldRecords.add(mem1);
            oldRecordId.add(mem1.Id);
        }
        Test.startTest();
        cmpRPMEMHandler.deleteAttorneyandLA(oldRecordId);
        Test.stopTest();
    }
}