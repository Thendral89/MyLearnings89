@isTest
private class cmpAPiMngSearchFolderWrraperTest {
    
    private static List<cmpAPiMngSearchFolderWrraper.data> createTestData() {
        List<cmpAPiMngSearchFolderWrraper.data> testDataList = new List<cmpAPiMngSearchFolderWrraper.data>();
        
        cmpAPiMngSearchFolderWrraper.data testData1 = new cmpAPiMngSearchFolderWrraper.data();
        testData1.database = 'MB_SB';
        testData1.default_security = 'public';
        testData1.description = 'MB-PT-100080-US';
        testData1.edit_date = '2023-12-19T07:39:02Z';
        testData1.folder_type = 'regular';
        testData1.has_documents = 'true';
        testData1.has_subfolders = 'false';
        testData1.id = 'MB_SB!20';
        testData1.is_container_saved_search = 'false';
        testData1.is_content_saved_search = 'false';
        testData1.is_external = 'false';
        testData1.is_external_as_normal = 'false';
        testData1.is_hidden = 'false';
        testData1.name = 'MB-PT-100080-US';
        testData1.owner = 'SYM_SVC';
        testData1.owner_description = 'Symphony Service Account';
        testData1.parent_id = 'MB_SB!5';
        testData1.view_type = 'document';
        testData1.workspace_id = 'MB_SB!5';
        testData1.workspace_name = 'iManage Cloud Monitor';
        testData1.wstype = 'folder';
        testDataList.add(testData1);
        
        cmpAPiMngSearchFolderWrraper.data testData2 = new cmpAPiMngSearchFolderWrraper.data();
        testData2.database = 'MB_SB';
        testData2.default_security = 'private';
        testData2.description = 'MB-PT-100081-US';
        testData2.edit_date = '2023-12-20T08:39:02Z';
        testData2.folder_type = 'regular';
        testData2.has_documents = 'false';
        testData2.has_subfolders = 'true';
        testData2.id = 'MB_SB!21';
        testData2.is_container_saved_search = 'true';
        testData2.is_content_saved_search = 'true';
        testData2.is_external = 'true';
        testData2.is_external_as_normal = 'true';
        testData2.is_hidden = 'true';
        testData2.name = 'MB-PT-100081-US';
        testData2.owner = 'SYM_SVC';
        testData2.owner_description = 'Symphony Service Account';
        testData2.parent_id = 'MB_SB!6';
        testData2.view_type = 'folder';
        testData2.workspace_id = 'MB_SB!6';
        testData2.workspace_name = 'iManage Cloud Monitor UK';
        testData2.wstype = 'folder';
        
        testDataList.add(testData2);
        
        return testDataList;
    }

    @isTest
    static void testCmpAPiMngSearchFolderWrraper() {
        List<cmpAPiMngSearchFolderWrraper.data> testData = createTestData();
        cmpAPiMngSearchFolderWrraper wrapper = new cmpAPiMngSearchFolderWrraper();
        wrapper.data = testData;
        
    }
}