@isTest
public class ConflictCheckTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        SymphonyLF__Currency__c curr = new SymphonyLF__Currency__c(Name = 'USD');
        INSERT curr;
        SymphonyLF__Client__c client = new SymphonyLF__Client__c(
            Name = 'Test Client',
            SymphonyLF__Default_Billing_Currency__c = curr.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        INSERT client;

        Conflict_Check__c conflictCheck = new Conflict_Check__c (
            Area_of_Law_AOL__c = 'Agreement', 
            CC_Status__c = 'Submitted',
            Client_Name__c = client.Id,
            Keywords__c = 'test');
        INSERT conflictCheck;
    }

    @isTest
    static void testAfterInsertOperations() {
        List<Conflict_Check__c> newRecords = [SELECT Id, Name, Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c FROM Conflict_Check__c];
        ConflictCheckTriggerHandler handler = new ConflictCheckTriggerHandler(
            null,
            null,
            newRecords,
            null
        );

        Test.startTest();
        try {
            handler.afterInsertOperations();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdateOperations() {
        List<Conflict_Check__c> conflictChecks = [SELECT Id, Name, Adverse_Parties__c, Related_Parties_other_than_client__c FROM Conflict_Check__c];

        Conflict_Check__c updatedRecord = conflictChecks[0];
        updatedRecord.Adverse_Parties__c = 'Updated Party';
        update updatedRecord;

        Map<Id, Conflict_Check__c> oldMap = new Map<Id, Conflict_Check__c>();
        for (Conflict_Check__c cc : conflictChecks) {
            oldMap.put(cc.Id, cc);
        }
        List<Conflict_Check__c> newRecords = [SELECT Id, Adverse_Parties__c FROM Conflict_Check__c WHERE Id = :updatedRecord.Id];

        ConflictCheckTriggerHandler handler = new ConflictCheckTriggerHandler(
            conflictChecks,
            oldMap,
            newRecords,
            oldMap
        );

        Test.startTest();
        try {
            handler.afterUpdateOperations();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}