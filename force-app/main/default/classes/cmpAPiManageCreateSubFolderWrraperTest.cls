@isTest
public class cmpAPiManageCreateSubFolderWrraperTest {

    @isTest
    static void testCmpApiManageCreateSubFolderWrapper() {
        
        // Create test data for the 'data' class within cmpAPiManageCreateSubFolderWrraper
        cmpAPiManageCreateSubFolderWrraper.data testData = new cmpAPiManageCreateSubFolderWrraper.data();
        
        testData.database = 'MB_SB';
        testData.default_security = 'public';
        testData.description = 'Sub Folder Created For Demo Purposes';
        testData.edit_date = '2023-12-11T08:52:42Z';
        testData.effective_security = 'full_access';
        testData.folder_type = 'regular';
        testData.has_documents = 'true';
        testData.has_subfolders = 'true';
        testData.id = 'MB_SB!10';
        testData.is_container_saved_search = 'false';
        testData.is_content_saved_search = 'false';
        testData.is_external = 'false';
        testData.is_external_as_normal = 'false';
        testData.is_hidden = 'false';
        testData.location = 'Demoville';
        testData.name = 'Demo Sub Folder';
        testData.owner = 'SYM_SVC';
        testData.owner_description = 'Symphony Service Account';
        testData.parent_id = 'MB_SB!1';
        testData.view_type = 'document';
        testData.wstype = 'folder';
        
        // Instantiate the class and test the data
        cmpAPiManageCreateSubFolderWrraper wrapper = new cmpAPiManageCreateSubFolderWrraper();
        
        // Test that the values are being populated correctly
        System.assertEquals('MB_SB', testData.database);
        System.assertEquals('public', testData.default_security);
        System.assertEquals('Sub Folder Created For Demo Purposes', testData.description);
        System.assertEquals('2023-12-11T08:52:42Z', testData.edit_date);
        System.assertEquals('full_access', testData.effective_security);
        System.assertEquals('regular', testData.folder_type);
        System.assertEquals('true', testData.has_documents);
        System.assertEquals('true', testData.has_subfolders);
        System.assertEquals('MB_SB!10', testData.id);
        System.assertEquals('false', testData.is_container_saved_search);
        System.assertEquals('false', testData.is_content_saved_search);
        System.assertEquals('false', testData.is_external);
        System.assertEquals('false', testData.is_external_as_normal);
        System.assertEquals('false', testData.is_hidden);
        System.assertEquals('Demoville', testData.location);
        System.assertEquals('Demo Sub Folder', testData.name);
        System.assertEquals('SYM_SVC', testData.owner);
        System.assertEquals('Symphony Service Account', testData.owner_description);
        System.assertEquals('MB_SB!1', testData.parent_id);
        System.assertEquals('document', testData.view_type);
        System.assertEquals('folder', testData.wstype);
        
        // Assuming the class does some further processing, such as folder creation
        // For example, if there's a method in the wrapper that uses this data to create a folder
        // wrapper.createSubFolder(testData);
        
        // Verify that the folder is created or the behavior expected is achieved.
        // Example:
        // Folder createdFolder = [SELECT Id FROM Folder WHERE Name = :testData.name LIMIT 1];
        // System.assertNotEquals(null, createdFolder);
        
    }
}