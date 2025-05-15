@IsTest
public class HelperFileUploadTest {
  @testSetup
    static void setupTestData() {
        // Create a dummy Account to use as a parent object
        SymphonyLF__Country__c testCountry = new SymphonyLF__Country__c(SymphonyLF__Country_Code__c='Test');
        insert testCountry;
        SymphonyLF__Client__c testClient = new SymphonyLF__Client__c(Name='test client',SymphonyLF__Entity_Size__c='Small',Jurisdiction__c=testCountry.id,SymphonyLF__Client_Number_New__c='123');
        insert testClient;
        SymphonyLF__Patent__c testPatent = new SymphonyLF__Patent__c(Name='test patent',SymphonyLF__Client__c=testClient.id,SymphonyLF__Country__c=testCountry.Id,SymphonyLF__Case_Type__c='Primary');
        insert testPatent;    

        ContentVersion cvlist = new Contentversion(); 
		cvlist.Title = 'CZDSTOU'; 
		cvlist.PathOnClient = 'test'; 
		cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cvlist;
        
        List<ContentVersion> cvl = [SELECT Id, ContentDocumentId,Title, PathOnClient,VersionData FROM ContentVersion WHERE Id=:cvlist.Id ];

        // Create a ContentDocumentLink
        ContentDocumentLink contentLink = new ContentDocumentLink(
            LinkedEntityId = testPatent.Id,
            ContentDocumentId = cvl[0].ContentDocumentId,
            ShareType = 'V'
        );
        insert contentLink;
    }
     @isTest
    static void testGetAttachmentsForDocuments() {
        // Fetch 
        SymphonyLF__Patent__c TESTpatent1 = [SELECT Id FROM SymphonyLF__Patent__c LIMIT 1];

        // Test the method
        List<Id> linkedEntityIds = new List<Id>{ TESTpatent1.Id };
        Map<Id, List<ContentVersion>> result = HelperFileUpload.getAttachmentsForDocuments(linkedEntityIds);

        // Assertions
        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey(TESTpatent1.Id), 'Result should contain the test Account ID');
        System.assert(result.get(TESTpatent1.Id).size() > 0, 'The list of ContentVersions should not be empty');
    }
    @isTest
    static void testGetCurrentAttachmentsForDocuments() {
       
         SymphonyLF__Country__c testCountry = new SymphonyLF__Country__c(SymphonyLF__Country_Code__c='Test');
        insert testCountry;
        SymphonyLF__Client__c testClient = new SymphonyLF__Client__c(Name='test client',SymphonyLF__Entity_Size__c='Small',Jurisdiction__c=testCountry.id,SymphonyLF__Client_Number_New__c='123');
        insert testClient;
        SymphonyLF__Patent__c testPatent3 = new SymphonyLF__Patent__c(Name='test patent',SymphonyLF__Client__c=testClient.id,SymphonyLF__Country__c=testCountry.Id,SymphonyLF__Case_Type__c='Primary');
        insert testPatent3;    

        ContentVersion cvlist = new Contentversion(); 
		cvlist.Title = 'CZDSTOU'; 
		cvlist.PathOnClient = 'test'; 
		cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cvlist;
        
        List<ContentVersion> cvl = [SELECT Id, ContentDocumentId,Title, PathOnClient,VersionData FROM ContentVersion WHERE Id=:cvlist.Id ];
         ContentDocumentLink contentLink = new ContentDocumentLink(
            LinkedEntityId = testPatent3.Id,
            ContentDocumentId = cvl[0].ContentDocumentId,
            ShareType = 'V'
        );
        insert contentLink;
        //ContentDocument testContentDoc2 = cvl[0].ContentDocumentId;

        // Test the method
        List<Id> linkedEntityIds = new List<Id>{ testPatent3.Id };
        List<Id> documentIds = new List<Id>{cvl[0].ContentDocumentId};
            //documentIds = [select ContentDocumentId from ContentDocumentLink where LinkedEntityId =: testPatent3.Id LIMIT 1].id;
        Map<Id, List<ContentVersion>> result = HelperFileUpload.getCurrentAttachmentsForDocuments(linkedEntityIds, documentIds);

        // Assertions
        System.assertNotEquals(null, result, 'Result map should not be null');
        //System.assert(result.containsKey(TESTpatent3.Id), 'Result should contain the test Account ID');
        //System.assert(result.get(testContentDoc2.Id).size() > 0, 'The list of ContentVersions should not be empty');
    }
}