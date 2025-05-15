@IsTest
public class layoutUtilitiesTest {

    @testSetup
    static void setupTestData() {
       
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
        
        
        SymphonyLF__Patent__c patent = new SymphonyLF__Patent__c(
            SymphonyLF__Title__c = 'test',
            SymphonyLF__Country__c =testCountry.id,
            SymphonyLF__Client__c = client.id,
            SymphonyLF__Case_Type__c ='Divisional',
            Name = 'test'
        );
        insert patent;
        
        // Create related keyword association record
        SymphonyLF__Keyword__c testKeyword = new SymphonyLF__Keyword__c(Name = 'Test Keyword');
        insert testKeyword;
        
        SymphonyLF__Keyword_Association__c keywordAssociation = new SymphonyLF__Keyword_Association__c(
            SymphonyLF__Keyword__c = testKeyword.Id,
            SymphonyLF__Patent__c = patent.Id
        );
        insert keywordAssociation;
    }

    @IsTest
    static void testGetFieldSetData() {
         SymphonyLF__Patent__c patent = [SELECT Id, SymphonyLF__Title__c, name FROM SymphonyLF__Patent__c LIMIT 1];

        Test.startTest();
        layoutUtilities.Response response = layoutUtilities.getFieldSetData(
            'SymphonyLF__Patent__c', 'SymphonyLF__Quick_Create', patent.Id, 'Client_Number__c', 'name'
        );
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.objectLabel, 'Object label should not be null');
        System.assertEquals('test', response.subHeaderValue, 'Header value should match Patent Name');
    }



     @isTest
    static void testHasRecordEditAccessIndirectly() {
        SymphonyLF__Patent__c patent = [SELECT Id, SymphonyLF__Title__c, name FROM SymphonyLF__Patent__c LIMIT 1];

        Test.startTest();
        layoutUtilities.Response response = layoutUtilities.getFieldSetData(
            'SymphonyLF__Patent__c', 'SymphonyLF__Quick_Create', patent.Id, 'Client_Number__c', 'name'
        );
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testKeywords() {
        SymphonyLF__Patent__c patent = [SELECT Id, SymphonyLF__Title__c, name FROM SymphonyLF__Patent__c LIMIT 1];

        Test.startTest();
        List<layoutUtilities.Keyword> keywords = layoutUtilities.keywords('SymphonyLF__Patent__c', patent.Id);
        Test.stopTest();

        System.assertEquals(1, keywords.size(), 'One keyword should be returned');
        System.assertEquals('Test Keyword', keywords[0].keywordName, 'Keyword name should match');
    }

    @isTest
    static void testGetFieldSetDataAccordion() {
        SymphonyLF__Patent__c patent = [SELECT Id, SymphonyLF__Title__c, name FROM SymphonyLF__Patent__c LIMIT 1];

        Test.startTest();
        List<layoutUtilities.AccordionFieldSet> fieldSets = layoutUtilities.getFieldSetDataAccordion(
            'SymphonyLF__Patent__c', 'SymphonyLF__Quick_Create', patent.Id
        );
        Test.stopTest();

        System.assertNotEquals(null, fieldSets, 'Accordion field sets should not be null');
        System.assert(fieldSets.size() > 0, 'Field set data should be returned');
    }
}