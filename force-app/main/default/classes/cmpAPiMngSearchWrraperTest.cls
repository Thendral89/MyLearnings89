@isTest
public class cmpAPiMngSearchWrraperTest {

    @isTest
    static void testCmpAPiMngSearchWrraper() {
         List<cmpAPiMngSearchWrraper.data> testDataList = new List<cmpAPiMngSearchWrraper.data>();
        cmpAPiMngSearchWrraper.data testData1 = new cmpAPiMngSearchWrraper.data();
        testData1.database = 'MB_SB';
        testData1.default_security = 'public';
        testData1.description = 'MB-PT-10001122024-US';
        testData1.edit_date = '2024-01-15T06:56:02Z';
        testData1.folder_type = 'regular';
        testData1.has_documents = 'true';
        testData1.has_subfolders = 'false';
        testData1.id = 'MB_SB!37';
        testData1.is_container_saved_search = 'false';
        testData1.is_content_saved_search = 'false';
        testData1.is_external = 'false';
        testData1.is_external_as_normal = 'false';
        testData1.is_hidden = 'false';
        testData1.name = 'MB-PT-10001122024-US';
        testData1.owner = 'SYM_SVC';
        testData1.owner_description = 'Symphony Service Account';
        testData1.parent_id = 'MB_SB!5';
        testData1.view_type = 'document';
        testData1.workspace_id = 'MB_SB!5';
        testData1.workspace_name = 'iManage Cloud Monitor';
        testData1.wstype = 'folder';
        
        testDataList.add(testData1);
        
        // Creating second test data object
        cmpAPiMngSearchWrraper.data testData2 = new cmpAPiMngSearchWrraper.data();
        testData2.database = 'MB_SB';
        testData2.default_security = 'private';
        testData2.description = 'MB-PT-10001122024-UK';
        testData2.edit_date = '2024-01-16T07:00:02Z';
        testData2.folder_type = 'regular';
        testData2.has_documents = 'false';
        testData2.has_subfolders = 'true';
        testData2.id = 'MB_SB!38';
        testData2.is_container_saved_search = 'true';
        testData2.is_content_saved_search = 'true';
        testData2.is_external = 'true';
        testData2.is_external_as_normal = 'true';
        testData2.is_hidden = 'true';
        testData2.name = 'MB-PT-10001122024-UK';
        testData2.owner = 'SYM_SVC';
        testData2.owner_description = 'Symphony Service Account';
        testData2.parent_id = 'MB_SB!6';
        testData2.view_type = 'folder';
        testData2.workspace_id = 'MB_SB!6';
        testData2.workspace_name = 'iManage Cloud Monitor UK';
        testData2.wstype = 'folder';
        
        testDataList.add(testData2);
        
        // Create a mock JSON string to simulate the input
        String jsonResponse = '{            "data": [                {                    "database": "MB_SB",                    "default_security": "public",                    "description": "MB-PT-10001122024-US",                    "edit_date": "2024-01-15T06:56:02Z",                    "folder_type": "regular",                    "has_documents": "true",                    "has_subfolders": "false",                    "id": "MB_SB!37",                    "is_container_saved_search": "false",                    "is_content_saved_search": "false",                    "is_external": "false",                    "is_external_as_normal": "false",                    "is_hidden": "false",                    "name": "MB-PT-10001122024-US",                    "owner": "SYM_SVC",                    "owner_description": "Symphony Service Account",                    "parent_id": "MB_SB!5",                    "view_type": "document",                    "workspace_id": "MB_SB!5",                    "workspace_name": "iManage Cloud Monitor",                    "wstype": "folder"                }            ]        }';
        cmpAPiMngSearchWrraper result = cmpAPiMngSearchWrraper.parse(jsonResponse);

    }
    
     @isTest
    static void CmpAPiMngSearchWrraper() {
        List<cmpAPiMngSearchWrraper.data> testDataList = new List<cmpAPiMngSearchWrraper.data>();
        cmpAPiMngSearchWrraper.data testData1 = new cmpAPiMngSearchWrraper.data();
        testData1.database = 'MB_SB';
        testData1.default_security = 'public';
        testData1.description = 'MB-PT-10001122024-US';
        testData1.edit_date = '2024-01-15T06:56:02Z';
        testData1.folder_type = 'regular';
        testData1.has_documents = 'true';
        testData1.has_subfolders = 'false';
        testData1.id = 'MB_SB!37';
        testData1.is_container_saved_search = 'false';
        testData1.is_content_saved_search = 'false';
        testData1.is_external = 'false';
        testData1.is_external_as_normal = 'false';
        testData1.is_hidden = 'false';
        testData1.name = 'MB-PT-10001122024-US';
        testData1.owner = 'SYM_SVC';
        testData1.owner_description = 'Symphony Service Account';
        testData1.parent_id = 'MB_SB!5';
        testData1.view_type = 'document';
        testData1.workspace_id = 'MB_SB!5';
        testData1.workspace_name = 'iManage Cloud Monitor';
        testData1.wstype = 'folder';
        
        testDataList.add(testData1);
        
        // Creating second test data object
        cmpAPiMngSearchWrraper.data testData2 = new cmpAPiMngSearchWrraper.data();
        testData2.database = 'MB_SB';
        testData2.default_security = 'private';
        testData2.description = 'MB-PT-10001122024-UK';
        testData2.edit_date = '2024-01-16T07:00:02Z';
        testData2.folder_type = 'regular';
        testData2.has_documents = 'false';
        testData2.has_subfolders = 'true';
        testData2.id = 'MB_SB!38';
        testData2.is_container_saved_search = 'true';
        testData2.is_content_saved_search = 'true';
        testData2.is_external = 'true';
        testData2.is_external_as_normal = 'true';
        testData2.is_hidden = 'true';
        testData2.name = 'MB-PT-10001122024-UK';
        testData2.owner = 'SYM_SVC';
        testData2.owner_description = 'Symphony Service Account';
        testData2.parent_id = 'MB_SB!6';
        testData2.view_type = 'folder';
        testData2.workspace_id = 'MB_SB!6';
        testData2.workspace_name = 'iManage Cloud Monitor UK';
        testData2.wstype = 'folder';
        
        testDataList.add(testData2);
        
        cmpAPiMngSearchWrraper wrapper = new cmpAPiMngSearchWrraper();
        wrapper.data = testDataList;
        
    }
    
}