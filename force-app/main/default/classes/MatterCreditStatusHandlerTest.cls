@isTest
public class MatterCreditStatusHandlerTest {
    @isTest
    static void testHandleBeforeInsert() {
        Test.startTest();
        
        SymphonyLF__Client__c testClient = new SymphonyLF__Client__c(Name = 'Test Client', Credit_Status__c = 'Good Standing',SymphonyLF__Entity_Size__c='Small');
        insert testClient;
        
        List<SObject> newMatters = new List<SObject>();
        Schema.SObjectType matterType = Schema.getGlobalDescribe().get('SymphonyLF__Patent__c'); 
        
        SObject testMatter = matterType.newSObject();
        testMatter.put('Name', 'Good Standing');
        testMatter.put('SymphonyLF__Client__c', testClient.Id);
        newMatters.add(testMatter);
        
        MatterCreditStatusHandler.handleBeforeInsert(newMatters, 'SymphonyLF__Patent__c');
        
        System.assertEquals('Good Standing', newMatters[0].get('Credit_Status__c'), 'Credit Status was not copied correctly.');
        
        Test.stopTest();
    }
}