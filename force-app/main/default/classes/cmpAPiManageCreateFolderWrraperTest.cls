@isTest
public class cmpAPiManageCreateFolderWrraperTest {
    
    @isTest
    static void testCmpApiManageCreateFolderWrapper() {
        
        cmpAPiManageCreateFolderWrraper.data testData = new cmpAPiManageCreateFolderWrraper.data();
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
        cmpAPiManageCreateFolderWrraper wrapper = new cmpAPiManageCreateFolderWrraper();
        
        
    }
}