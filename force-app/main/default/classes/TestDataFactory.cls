@IsTest
public with sharing class TestDataFactory {

    public static String currencyId; 
    public static String jurisdictionId; 
    public static String clientId; 
    public static String designId;
    public static String patentId;
    public static String patentId1;
    public static String copyrightId;
    public static String agreementId;
    public static String generalId;
    public static String disputeId;
    public static String trademarkId;
    public static String designFamilyId;
    public static String personId;
    public static String userId;
    public static String officeAgentId;
    public static String memId;
    public static String cemId;

   public static void createMasterData() {
        /* Create a currency record as this is mandatory in Lawfirm */ 
        SymphonyLF__Currency__c currencyRecord = new SymphonyLF__Currency__c(Name = 'USD');
        INSERT currencyRecord;
        TestDataFactory.currencyId = currencyRecord.Id;

        /* Create a Jurisdiction record as this is mandatory in Lawfirm */ 
        SymphonyLF__Country__c jurisdictionRecord = new SymphonyLF__Country__c(SymphonyLF__Country_Code__c='United States of America');
        insert jurisdictionRecord;
        TestDataFactory.jurisdictionId = jurisdictionRecord.Id;

        	
         SymphonyLF__Office_Agent__c offag = new SymphonyLF__Office_Agent__c(
        Name = 'Agent1',
        SymphonyLF__Type__c = 'Office',
        SymphonyLF__Active__c = true);
        
            insert offag;
            TestDataFactory.officeAgentId = offag.Id;
        
          SymphonyLF__Person__c person = new SymphonyLF__Person__c(
            Name = 'Test Person',
            SymphonyLF__Contact_Type__c = 'Author',
            SymphonyLF__Type__c = 'Client',
            SymphonyLF__Office_Agent__c = offag.id
        );
        insert person;
        TestDataFactory.personId = person.Id;

        
    }

    public static void createUser(){
        User testUser = new User(
            Username = 'testuser4454@example.com',
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    TestDataFactory.userId = testUser.Id;
    }

    public static void createClient() {
        TestDataFactory.createMasterData();
        SymphonyLF__Client__c clientRecord = new SymphonyLF__Client__c(
            Name = 'MCCIP Client',
            SymphonyLF__Default_Billing_Currency__c = currencyId,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        INSERT clientRecord;
        TestDataFactory.clientId = clientRecord.Id;
    }

    public static void createMEM(){
        SymphonyLF__Matter_Engagement_Model__c mem = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Supervisor_Client_Contact__c = TestDataFactory.personId,  
            SymphonyLF__Copyright__c = TestDataFactory.copyrightId 
        );
        insert mem;
        TestDataFactory.memId = mem.Id;

    }

    @IsTest
    public static void createCEM(){

        TestDataFactory.createMasterData();
        SymphonyLF__Client__c clientRecord = new SymphonyLF__Client__c(
            Name = 'MCCIP Client',
            SymphonyLF__Default_Billing_Currency__c = currencyId,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        INSERT clientRecord;
        TestDataFactory.clientId = clientRecord.Id;

        SymphonyLF__Client_Engagement_Model__c model1 = new SymphonyLF__Client_Engagement_Model__c(
            SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Type__c = 'Working Attorney',
            SymphonyLF__Person__c = TestDataFactory.personId,
            SymphonyLF__Applicable_to_all_jurisdiction__c = true,
            Is_Active__c = true,
            Is_Default__c = true
        );
        insert model1;
        
        SymphonyLF__Client_Engagement_Model__c model2 = new SymphonyLF__Client_Engagement_Model__c(
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Type__c = 'Paralegal',
            SymphonyLF__Person__c = TestDataFactory.personId,
            SymphonyLF__Applicable_to_all_jurisdiction__c = false,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            Is_Active__c = true,
            Is_Default__c = false
        );
        insert model2;
        TestDataFactory.cemId = model2.Id;
    }

    
    
    @isTest
    public static void createMatter(){

        TestDataFactory.createMasterData();
        SymphonyLF__Client__c clientRecord = new SymphonyLF__Client__c(
            Name = 'MCCIP Client',
            SymphonyLF__Default_Billing_Currency__c = currencyId,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        INSERT clientRecord;
        TestDataFactory.clientId = clientRecord.Id;

     
     SymphonyLF__Design__c design = new SymphonyLF__Design__c(
            Name = 'Test Design',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Case_Type__c = 'Primary',
         SymphonyLF__Design_Status__c = 'Filed',
         SymphonyLF__Docket_Number__c = 'SYM-DS-100009-IN-P'
        );
        insert design;
        TestDataFactory.designId = design.Id;
    
    SymphonyLF__Patent__c pat = new SymphonyLF__Patent__c(
            Name = 'Test patent',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Country__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Case_Type__c = 'Primary',
        SymphonyLF__Docket_Number__c = 'SYM-DS-100008-IN-P'
        );
        insert pat;
        TestDataFactory.patentId = pat.Id;
        
        SymphonyLF__Patent__c pat1 = new SymphonyLF__Patent__c(
            Name = 'Test patent1',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Country__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Case_Type__c = 'Primary',
        SymphonyLF__Docket_Number__c = 'SYM-DS-200008-IN-P'
        );
        insert pat1;
        TestDataFactory.patentId1 = pat1.Id;
        
        SymphonyLF__Trademark__c trd = new SymphonyLF__Trademark__c(
            Name = 'Test trademark',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
            SymphonyLF__Case_Type__c = 'Primary',
            SymphonyLF__Status__c =  'Pending',
        SymphonyLF__Docket_Number__c = 'SYM-DS-100008-IN-T'
        );
        insert trd;
        TestDataFactory.trademarkId = trd.Id;
    
    SymphonyLF__General_Matter__c gen = new SymphonyLF__General_Matter__c(
            Name = 'Test general',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
        	SymphonyLF__Docket_Number__c = 'SYM-DS-100009-IN-G'
            
        );
        insert gen;
        TestDataFactory.generalId = gen.Id;
    
    SymphonyLF__Dispute_Opposition__c disp = new SymphonyLF__Dispute_Opposition__c(
            Name = 'Test Dispute',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
        	SymphonyLF__Status__c = 'Open',
        SymphonyLF__Dispute_Type__c = 'Opposition',
        SymphonyLF__Dispute_Sub_Type__c = 'Offensive',
        SymphonyLF__Docket_Number__c = 'SYM-DS-100009-IN-D'
            
        );
        insert disp;
        TestDataFactory.disputeId = disp.Id;
    
    SymphonyLF__Agreement_Contract__c agreement = new SymphonyLF__Agreement_Contract__c(
            Name = 'Test agreement',
             SymphonyLF__Client__c = TestDataFactory.clientId,
            SymphonyLF__Jurisdiction__c = TestDataFactory.jurisdictionId,
        	SymphonyLF__Matter_Status__c = 'Draft',
        SymphonyLF__Docket_Number__c = 'SYM-DS-100009-IN-A'
            
        );
        insert agreement;
        TestDataFactory.agreementId = agreement.Id;

    }

    
    }