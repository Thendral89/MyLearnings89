@isTest
public class mvlawfirmutilitiesTest {   
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
        SymphonyLF__Country__c country = [SELECT Id FROM SymphonyLF__Country__c LIMIT 1];
        
         SymphonyLF__Copyright__c copyright22 = new SymphonyLF__Copyright__c(
            Name = 'Test Copyright',
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Jurisdiction__c = country.Id,
            SymphonyLF__Status__c = 'Application Preparation'
        );
        insert copyright22;
        
         SymphonyLF__Matter_Engagement_Model__c mem22 = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = TestDataFactory.personId,  
            SymphonyLF__Copyright__c = copyright22.Id
            
        );
        insert mem22;
        
        
        
         List<SymphonyLF__Copyright__c> copList = [SELECT Id FROM SymphonyLF__Copyright__c LIMIT 10];
        List<SymphonyLF__Client_Engagement_Model__c> cemList = [SELECT Id FROM SymphonyLF__Client_Engagement_Model__c];
        List<SymphonyLF__Patent__c> ptRec = [SELECT Id FROM SymphonyLF__Patent__c LIMIT 1];
      
      
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
        
         try{
         mvLawfirmUtilities.addCemsToMems(copyright22.Id, new List<Id>{cemList[0].Id});
            //System.assert(true, 'The addCemsToMems method returned null.');
        }
        catch (Exception e){
            System.debug('Error occurred: ' + e.getMessage());
            System.assert(false, e.getMessage());
        }
        Test.stopTest();
    }
}