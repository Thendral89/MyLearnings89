@isTest
public class cmpAPiMngGetDocWrraperTest {

    @isTest
    static void testCmpAPiMngGetDocWrraper() {
        // Step 1: Create an instance of the 'results' class and populate it with test data
        cmpAPiMngGetDocWrraper.results testResult = new cmpAPiMngGetDocWrraper.results();
        testResult.database = 'TestDatabase';
        testResult.document_number = '12345';
        testResult.version = '1.0';
        testResult.name = 'Test Document';
        testResult.author = 'John Doe';
        testResult.operator = 'Operator1';
        testResult.type = 'PDF';
        testResult.class_Z = 'Class A';
        testResult.edit_date = '2024-12-29';
        testResult.system_edit_date = '2024-12-29T12:00:00Z';
        testResult.create_date = '2024-01-15';
        testResult.create_profile_date = '2024-01-15';
        testResult.retain_days = '30';
        testResult.size = '1024';
        testResult.is_declared = 'true';
        testResult.declared = '2024-12-29';
        testResult.is_related = 'false';
        testResult.default_security = 'High';
        testResult.last_user = 'Admin';
        testResult.is_in_use = 'true';
        testResult.is_checked_out = 'false';
        testResult.type_description = 'PDF Document';
        testResult.class_description = 'Document Class A';
        testResult.extension = 'pdf';
        testResult.content_type = 'application/pdf';
        testResult.edit_profile_date = '2024-12-29T13:00:00Z';
        testResult.is_external = 'false';
        testResult.is_external_as_normal = 'false';
        testResult.file_create_date = '2024-01-10';
        testResult.file_edit_date = '2024-12-28';
        testResult.is_hipaa = 'false';
        testResult.workspace_name = 'Workspace 1';
        testResult.is_restorable = 'true';
        testResult.id = 'doc-12345';
        testResult.in_use = 'false';
        testResult.indexable = 'true';
        testResult.wstype = 'Standard';
        testResult.iwl = 'true';
        testResult.workspace_id = 'ws-001';
        
        // Step 2: Create an instance of the 'data' class and add the 'results' instance to the list
        cmpAPiMngGetDocWrraper.data testData = new cmpAPiMngGetDocWrraper.data();
        testData.results = new List<cmpAPiMngGetDocWrraper.results>{testResult};

        // Step 3: Create an instance of cmpAPiMngGetDocWrraper and set the 'data' field
        cmpAPiMngGetDocWrraper cmpApiMngGetDoc = new cmpAPiMngGetDocWrraper();
        cmpApiMngGetDoc.data = testData;
    }
}