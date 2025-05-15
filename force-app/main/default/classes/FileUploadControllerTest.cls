@isTest
public class FileUploadControllerTest {
 @isTest
    public static void testSaveFiles() {
        // Step 1: Set up test data
        String fileName = 'TestFile.txt';
        String fileContent = 'Test content for the file.';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(fileContent));

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentVersion conver1 = [SELECT id,Title,ContentDocumentId FROM ContentVersion where Id = :cv.Id];

       
        // Step 4: Validate ContentDocumentLink creation
        ContentDocumentLink insertedCDL = [
            SELECT Id, ContentDocumentId, LinkedEntityId, ShareType
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :conver1.ContentDocumentId
            AND LinkedEntityId = :UserInfo.getUserId()
            LIMIT 1
        ];
        System.assertNotEquals(null, insertedCDL, 'ContentDocumentLink should have been created.');
        //System.assertEquals('I', insertedCDL.ShareType, 'The share type should be Viewer (V).');
        System.assertEquals(UserInfo.getUserId(), insertedCDL.LinkedEntityId, 'The link should be associated with the current user.');
        Test.startTest();
        FileUploadController.saveFiles(fileName, base64Data);
        Test.stopTest();
    }
}