@isTest
private class cmpAPiMngSearchFolderUpdatedWrraperTest {
    
    // Method to create test JSON data for parsing
    private static String createTestJson() {
        return '{  "data": {    "default_security": "inherit",    "inherited_default_security": "global",    "name": "700-Case Administration",    "owner": "SYM_SVC",    "description": "700-Case Administration",    "has_subfolders": "true",    "has_documents": "false",    "is_content_saved_search": "false",    "is_container_saved_search": "true",    "database": "MB_SB",    "is_external": "false",    "is_hidden": "false",    "is_external_as_normal": "false",    "edit_date": "2024-01-27T21:13:49Z",    "effective_security": "full_access",    "owner_description": "Symphony Service Account",    "view_type": "document",    "id": "MB_SB!97",    "parent_id": "MB_SB!90",    "workspace_id": "MB_SB!90",    "workspace_name": "US01 (206001-6021)",    "wstype": "folder",    "folder_type": "regular",    "profile": {      "classw": "CASEADMIN",      "class_description": "Case Administration",      "custom1": "206001",      "custom2": "6021",      "custom3": "",      "custom4": "US",      "custom5": "",      "custom6": "",      "custom7": "2",      "custom8": "",      "custom9": "",      "custom10": "US01",      "custom1_description": "Bill Bradley",      "custom2_description": "IP Test One",      "custom3_description": "IP Test One",      "custom4_description": "USPTO",      "custom5_description": "",      "custom6_description": "",      "custom7_description": "2",      "custom8_description": "",      "custom9_description": "",      "custom10_description": "USPTO"    },    "owner_info": {      "allow_logon": "true",      "is_external": "false"    }  }}';
    }

    // Test method to validate parsing functionality of cmpAPiMngSearchFolderUpdatedWrraper
    @isTest
    static void testParseMethod() {
        // Arrange: Create the test JSON string
        String testJson = createTestJson();
        
        // Act: Deserialize the JSON string into the wrapper class
        cmpAPiMngSearchFolderUpdatedWrraper wrapper = cmpAPiMngSearchFolderUpdatedWrraper.parse(testJson);
        
    }
}