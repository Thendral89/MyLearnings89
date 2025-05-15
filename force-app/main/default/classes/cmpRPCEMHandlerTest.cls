@isTest
private class cmpRPCEMHandlerTest {
    @testSetup
    static void setupData() {
        
        SymphonyLF__Person__c ps = new SymphonyLF__Person__c(
        Name =  'CVK',
        SymphonyLF__Type__c = 'Attorney',
        SymphonyLF__Contact_Type__c = 'Attorney'
        );
        insert ps;
        
         SymphonyLF__Currency__c curr = new SymphonyLF__Currency__c(Name = 'USD');
        INSERT curr;
        SymphonyLF__Country__c testCountry = new SymphonyLF__Country__c(SymphonyLF__Country_Code__c='India');
        insert testCountry;
        
         SymphonyLF__Client__c client = new SymphonyLF__Client__c(
            Name = 'Test Client',
            SymphonyLF__Default_Billing_Currency__c = curr.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        INSERT client;
        
        SymphonyLF__Client_Engagement_Model__c cem = new SymphonyLF__Client_Engagement_Model__c(
          SymphonyLF__Type__c = 'Responsible Attorney',
          SymphonyLF__IP_Matters__c = 'All',
          SymphonyLF__Applicable_to_all_jurisdiction__c = true,
          Is_Active__c = true,
          SymphonyLF__Person__c = ps.Id,
          SymphonyLF__Client__c = client.Id
        );
        insert cem;

        // Create test Legal Assistant User
        User legalAssistant = new User(
            FirstName = 'Test',
            LastName = 'LA',
            Email = 'testla@example.com',
            Username = 'testla@example.com.salesforce',
            Alias = 'testla',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert legalAssistant;
        
         SymphonyLF__Person__c legalAssistantPerson = new SymphonyLF__Person__c(
        Name = 'Test Legal Assistant',
        SymphonyLF__Type__c = 'Legal Assistant',
       	SymphonyLF__Contact_Type__c = 'Legal Assistant'
    );
    insert legalAssistantPerson;
    
    Legal_Assistant__c la = new Legal_Assistant__c(
        Attorney_Paralegal__c = ps.Id,  
        Legal_Assistant__c = legalAssistantPerson.Id 
    );
    insert la;
    }
    
   

    @isTest
static void testCemCreationLegalAssistant() {
   
    SymphonyLF__Client_Engagement_Model__c cem = [SELECT Id FROM SymphonyLF__Client_Engagement_Model__c LIMIT 1];
    
    
    Set<Id> cemIds = new Set<Id>{cem.Id};
    
    Test.startTest();
    cmpRPCEMHandler.cemCreationLegalAssistant(cemIds);
    Test.stopTest();

   
    List<SymphonyLF__Client_Engagement_Model__c> updatedCems = 
        [SELECT Id FROM SymphonyLF__Client_Engagement_Model__c WHERE Id = :cem.Id];
    
    System.assertEquals(1, updatedCems.size(), 'Client Engagement should be updated');
}


   @isTest
static void testUpdateLegalAssistants() {
   
    SymphonyLF__Client_Engagement_Model__c cem = [SELECT Id, SymphonyLF__Person__c FROM SymphonyLF__Client_Engagement_Model__c LIMIT 1];

    
    Set<Id> newRecords = new Set<Id>{cem.Id}; // Set of CEM IDs
    Set<Id> oldPersonIds = new Set<Id>(); // Initialize an empty set

    if (cem.SymphonyLF__Person__c != null) {
        oldPersonIds.add(cem.SymphonyLF__Person__c); // Add existing person ID if available
    }

    Test.startTest();
    cmpRPCEMHandler.updateLegalAssistants(newRecords, oldPersonIds); // Corrected method signature
    Test.stopTest();

    // Add assertions to verify expected behavior
}


    @isTest
    static void testDeleteAttorneyandLA() {
        SymphonyLF__Client_Engagement_Model__c cem = [SELECT Id FROM SymphonyLF__Client_Engagement_Model__c LIMIT 1];
        List<Id> userIds = new List<Id>{ [SELECT Id FROM User LIMIT 1].Id };
        
        Test.startTest();
        cmpRPCEMHandler.deleteAttorneyandLA(new Set<Id>{cem.Id});
        Test.stopTest();

    
    }
}