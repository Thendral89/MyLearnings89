@isTest
private class MEMTriggerHandlerTest {
    @testSetup
    static void setupData() {
        
         TestDataFactory.createMasterData();
    	 TestDataFactory.createClient();
        
        SymphonyLF__Person__c supervisor = new SymphonyLF__Person__c(
            Name = 'Test Supervisor',
            SymphonyLF__Type__c = 'Attorney',
            SymphonyLF__Contact_Type__c = 'Attorney'
        );
        insert supervisor;
       
        SymphonyLF__Copyright__c copyright = new SymphonyLF__Copyright__c(
            Name = 'Test Copyright',
            SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Status__c = 'Application Preparation'
        );
        insert copyright;
        
        SymphonyLF__Design__c design = new SymphonyLF__Design__c(
            Name = 'Test Design',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Case_Type__c = 'Similar'
        );
        insert design;
        
          SymphonyLF__Matter_Engagement_Model__c newMEM = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = supervisor.Id,
            SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Design__c = design.Id
        );
        insert newMEM;
    }

    @isTest
    static void testOnAfterInsert() {
        SymphonyLF__Client__c client = [SELECT Id FROM SymphonyLF__Client__c LIMIT 1];
        SymphonyLF__Person__c supervisor = [SELECT Id FROM SymphonyLF__Person__c LIMIT 1];
        SymphonyLF__Design__c design = [SELECT Id FROM SymphonyLF__Design__c LIMIT 1];
        
        Test.startTest();
        SymphonyLF__Matter_Engagement_Model__c newMEM = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = supervisor.Id,
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Design__c = design.Id
        );
        insert newMEM;
        Test.stopTest();
        
        System.assertNotEquals(null, newMEM.Id, 'MEM should be inserted successfully');
    }

    @isTest
    static void testOnBeforeUpdate() {
        SymphonyLF__Matter_Engagement_Model__c mem = [SELECT Id FROM SymphonyLF__Matter_Engagement_Model__c LIMIT 1];
        
        Test.startTest();
        mem.Is_Active__c = false;
        update mem;
        Test.stopTest();
        
        SymphonyLF__Matter_Engagement_Model__c updatedMEM = [SELECT Is_Active__c FROM SymphonyLF__Matter_Engagement_Model__c WHERE Id = :mem.Id];
        System.assertEquals(false, updatedMEM.Is_Active__c, 'MEM should be updated successfully');
    }

    @isTest
    static void testOnBeforeDelete() {
        SymphonyLF__Matter_Engagement_Model__c mem = [SELECT Id FROM SymphonyLF__Matter_Engagement_Model__c LIMIT 1];
        
        Test.startTest();
        delete mem;
        Test.stopTest();
        
        Integer count = [SELECT COUNT() FROM SymphonyLF__Matter_Engagement_Model__c WHERE Id = :mem.Id];
        System.assertEquals(0, count, 'MEM should be deleted successfully');
    }
}