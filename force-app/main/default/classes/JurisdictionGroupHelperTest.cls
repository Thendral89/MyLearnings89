@isTest
public class JurisdictionGroupHelperTest {

    // Helper method to create test data for Country
    public static void createTestCountryData() {
        List<SymphonyLF__Country__c> countries = new List<SymphonyLF__Country__c>();
        
        countries.add(new SymphonyLF__Country__c(Name = 'Country 1', SymphonyLF__Active__c = true, SymphonyLF__Country_Code__c = 'C1'));
        countries.add(new SymphonyLF__Country__c(Name = 'Country 2', SymphonyLF__Active__c = true, SymphonyLF__Country_Code__c = 'C2'));
        
        insert countries;
    }

    // Helper method to create test data for Client Jurisdiction Group
    public static void createTestClientJurisdictionGroupData(String clientId) {
        
        
        List<SymphonyLF__Client_Jurisdiction_Group__c> jurisdictionGroups = new List<SymphonyLF__Client_Jurisdiction_Group__c>();
        jurisdictionGroups.add(new SymphonyLF__Client_Jurisdiction_Group__c(
            SymphonyLF__Client__c = clientId, 
            Name = 'Jurisdiction Group 1'
        ));
        
        insert jurisdictionGroups;
    }

    // Helper method to create test data for Jurisdiction Group Detail
    public static void createTestJurisdictionGroupDetailData(String jurisdictionGroupId, String countryId) {
        List<SymphonyLF__Jurisdiction_Group_Detail__c> groupDetails = new List<SymphonyLF__Jurisdiction_Group_Detail__c>();
        
        groupDetails.add(new SymphonyLF__Jurisdiction_Group_Detail__c(
            SymphonyLF__Jurisdiction_Group__c = jurisdictionGroupId,
            SymphonyLF__Jurisdiction__c = countryId
        ));
        
        insert groupDetails;
    }

    @isTest
    public static void testGetJurisdictionDetail() {
        // Create test data
        createTestCountryData();
        SymphonyLF__Client__c Client = new SymphonyLF__Client__c();
        Client.SymphonyLF__Active__c=true;
        Client.Name='India';
        Client.SymphonyLF__Entity_Size__c='Small';
        Client.SymphonyLF__Client_Number_New__c='000001';
		insert Client;    
        string clientId=Client.Id;
        createTestClientJurisdictionGroupData(Client.Id);
        
        Test.startTest();
        JurisdictionGroupHelper.JurisdictionDetail result = JurisdictionGroupHelper.GetJurisdictionDetail(clientId, 'Agreements');
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(result, null);
        //System.assertNotEquals(result.jurisdictionGroup.size(), 0);
        //System.assertNotEquals(result.jurisdictions.size(), 0);
    }

    @isTest
    public static void testGetJurisdictionGroupDetail() {
        // Create test data
        createTestCountryData();
        SymphonyLF__Client__c Client = new SymphonyLF__Client__c();
        Client.SymphonyLF__Active__c=true;
        Client.Name='India';
        Client.SymphonyLF__Entity_Size__c='Small';
        Client.SymphonyLF__Client_Number_New__c='000001';
		insert Client; 
        createTestClientJurisdictionGroupData(Client.Id);
        
        List<String> jurisdictionGroupId = new List<String>{'testGroupId'}; // Replace with valid Group IDs if needed
        List<String> jurisdictionId = new List<String>{'testCountryId'};  // Replace with valid Country IDs if needed
        
        Test.startTest();
        JurisdictionGroupHelper.JurisdictionDetail result = JurisdictionGroupHelper.GetJurisdictionGroupDetail(jurisdictionGroupId, jurisdictionId, 'Agreements');
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(result, null);
        //System.assertNotEquals(result.groupDetail.size(), 0);
        //System.assertNotEquals(result.jurisdictions.size(), 0);
    }

    @isTest
    public static void testGetJurisdictions() {
        // Create test data
        createTestCountryData();
        
        Test.startTest();
        List<SymphonyLF__Country__c> result = JurisdictionGroupHelper.GetJurisdictions();
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(result, null);
        //System.assertNotEquals(result.size(), 0);
    }
}