@isTest
public class mvlTest { 
     @testSetup
    static void setupData() {
    TestDataFactory.createMasterData();
    TestDataFactory.createClient();
    TestDataFactory.createMatter();
    TestDataFactory.createUser();
        TestDataFactory.createCEM();
        
        	
     	Access_Restriction__c testRestriction = new Access_Restriction__c(
            Client__c = TestDataFactory.clientId,
            User__c = TestDataFactory.userId,
            Revoke_Record_Access__c = true
        );
        insert testRestriction;
        
        SymphonyLF__Copyright__c copyright = new SymphonyLF__Copyright__c(
            Name = 'Test Copyright',
            SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Status__c = 'Application Preparation'
        );
        insert copyright;
        
        SymphonyLF__Copyright__c copyright1 = new SymphonyLF__Copyright__c(
            Name = 'Test Copyright1',
            SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Status__c = 'Application Preparation'
        );
        insert copyright1;
        
        SymphonyLF__Matter_Engagement_Model__c mem = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = TestDataFactory.personId,  
            SymphonyLF__Copyright__c = copyright.Id 
        );
        insert mem;
        
    }
    
    
    @isTest
    static void testGetClientRestrictions() {
        SymphonyLF__Client__c client = [SELECT Id FROM SymphonyLF__Client__c LIMIT 1];
         List<SymphonyLF__Copyright__c> copList = [SELECT Id FROM SymphonyLF__Copyright__c LIMIT 10];
        	List<Id> copId = new List<Id>();

			for (SymphonyLF__Copyright__c record : copList) {
   		 		copId.add(record.Id);
            }

        Test.startTest();
        try{
        List<mvWrapper.clientRestrictionsWrapper> results = mvLawfirmUtilities.getClientRestrictions(client.Id);
        System.assert(results.size() > 0, 'The getClientRestrictions method returned an empty list.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getClientRestrictions: ' + e.getMessage());
        }
        
        try{
        List<mvWrapper.MatterEngagementModelWrapper> result = mvLawfirmUtilities.getMatterEngagementModels(copList[0].Id);
            System.assert(result.size() > 0, 'The getMatterEngagementModels method returned an empty list.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getMatterEngagementModels: ' + e.getMessage());
        }
         
        try{
        mvWrapper.ObjectPermissionsWrapper permissions = mvLawfirmUtilities.getObjectPermission('SymphonyLF__Copyright__c');
            System.assertNotEquals(null, permissions, 'The getObjectPermission method returned null.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getObjectPermission: ' + e.getMessage());
        }
        
        try{
        Map<Id, mvWrapper.RecordPermissionWrapper> recPermissions = mvLawfirmUtilities.getRecordPermissions(copId);
            System.assert(!recPermissions.isEmpty(), 'The getRecordPermissions method returned an empty map.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getRecordPermissions: ' + e.getMessage());
        }
        
        try{
        List<mvWrapper.mvPortfolioWrapper> portfolioRecords = mvLawfirmUtilities.getClientPortfolio(client.Id);
            System.assertNotEquals(null, portfolioRecords, 'The getClientPortfolio method returned null.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getClientPortfolio: ' + e.getMessage());
        }
        
        try{
        List<mvWrapper.ClientEngagementModelWrapper> clientEngagement = mvLawfirmUtilities.getClientEngagementModels(client.Id);
            System.assertNotEquals(null, clientEngagement, 'The getClientEngagementModels method returned null.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getClientEngagementModels: ' + e.getMessage());
        }
        
        try{
        String timezoneOffset = mvLawfirmUtilities.getUserTimezoneOffset();
            System.assertNotEquals(null, timezoneOffset, 'The getUserTimezoneOffset method returned null.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getUserTimezoneOffset: ' + e.getMessage());
        }
        
        try{
        String userLocaleOffset = mvLawfirmUtilities.getUserLocale();
            System.assertNotEquals(null, userLocaleOffset, 'The getUserLocale method returned null.');
        }
        catch (Exception e){
            System.assert(false, 'Error in getUserLocale: ' + e.getMessage());
        }
        Test.stopTest();
    }
  
  
    
    @isTest
	static void testGetClientEngagementModelsToAddForMem() {
    // Get a Copyright record (which is being inserted in setupData)
    SymphonyLF__Copyright__c testCopyright = [SELECT Id FROM SymphonyLF__Copyright__c LIMIT 1];

    Test.startTest();
    try {
        List<mvWrapper.ClientEngagementModelWrapper> results = mvLawfirmUtilities.getClientEngagementModelsToAddForMem(testCopyright.Id);
        System.assertNotEquals(null, results, 'The getClientEngagementModelsToAddForMem method returned null.');
        // Optionally add:
        System.debug('Returned Engagement Models: ' + results);
    } catch (Exception e) {
        System.assert(false, 'Error in getClientEngagementModelsToAddForMem: ' + e.getMessage());
    }
    Test.stopTest();
}
      @isTest
    static void testAddCemsToMems() {
        // Step 1: Setup test data using TestDataFactory

        // Setup necessary records using TestDataFactory
        TestDataFactory.createCEM();

        // Retrieve the created CEM record ID (model2)
        Id cemId = TestDataFactory.cemId;

        // Create a Matter Engagement Model record (replace SymphonyLF__Matter__c with correct object)
        SymphonyLF__Matter_Engagement_Model__c testMem = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Client__c = TestDataFactory.clientId,
            Is_Active__c = true,
            Client_Engagement_Model__c = cemId  // This is the lookup field to the CEM record
        );
        insert testMem;

        // Step 2: Call the method to test
        Test.startTest();
        mvLawfirmUtilities.addCemsToMems(testMem.Id, new List<Id>{cemId});
        Test.stopTest();

        // Step 3: Validate the results by querying the Matter Engagement Models (MEMs)
        List<SymphonyLF__Matter_Engagement_Model__c> mems = [SELECT Id, Client_Engagement_Model__c, SymphonyLF__Assign_to_User__c, SymphonyLF__Type__c
                                                            FROM SymphonyLF__Matter_Engagement_Model__c
                                                            WHERE Client_Engagement_Model__c = :testMem.Id];

        // Assert that the MEMs were created
        System.assertEquals(1, mems.size(), 'One MEM record should have been created.');

        // Check that the MEM is correctly linked to the CEM and the Matter
        SymphonyLF__Matter_Engagement_Model__c mem = mems[0];
        System.assertEquals(cemId, mem.Client_Engagement_Model__c, 'CEM should be linked to MEM.');
        System.assertNotEquals(null, mem.SymphonyLF__Assign_to_User__c, 'CEM should have an assigned user.');
        System.assertNotEquals(null, mem.SymphonyLF__Type__c, 'CEM should have a type.');
    }
}