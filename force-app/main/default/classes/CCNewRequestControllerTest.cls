@isTest
public class CCNewRequestControllerTest {
    
    @isTest static void testRecords() {
        
        SymphonyLF__Country__c testCountry = new SymphonyLF__Country__c(SymphonyLF__Country_Code__c='Test');
        insert testCountry;
        SymphonyLF__Client__c testClient = new SymphonyLF__Client__c(Name='test client',SymphonyLF__Entity_Size__c='Small',Jurisdiction__c=testCountry.id,SymphonyLF__Client_Number_New__c='123');
        insert testClient;
        Test.startTest();
        CCNewRequestController.getRecordClient(testClient.id);
        Test.stopTest();
        
    }
}