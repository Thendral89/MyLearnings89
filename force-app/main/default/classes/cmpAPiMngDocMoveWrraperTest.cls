@isTest
public class cmpAPiMngDocMoveWrraperTest {

    @isTest
    static void testDataClass() {
        // Create an instance of the wrapper and the data class
        cmpAPiMngDocMoveWrraper wrapper = new cmpAPiMngDocMoveWrraper();
        cmpAPiMngDocMoveWrraper.data docData = new cmpAPiMngDocMoveWrraper.data();
        
        // Set values for the fields in the data class
        docData.access = 'full_access';
        docData.author = 'SYM_SVC';
        docData.author_description = 'Symphony Service Account';
        docData.class_code = 'DOC';
        docData.class_description = 'Document';
        docData.content_type = 'D';
        docData.create_date = '2023-12-16T14:45:54Z';
        docData.create_profile_date = '2023-12-16T14:45:54Z';
        docData.database = 'MB_SB';
        docData.declared = '';
        docData.default_security = 'public';
        docData.document_number = '23';
        docData.edit_date = '2023-12-16T14:45:54Z';
        docData.edit_profile_date = '2024-01-17T17:48:48Z';
        docData.extension = 'txt';
        docData.file_create_date = '2023-12-16T14:45:54Z';
        docData.file_edit_date = '2023-12-16T14:45:54Z';
        docData.id = 'MB_SB!23.1';
        docData.in_use = '';
        docData.indexable = '';
        docData.is_checked_out = '';
        docData.is_declared = '';
        docData.is_external = '';
        docData.is_external_as_normal = '';
        docData.is_hipaa = '';
        docData.is_in_use = '';
        docData.iwl = 'iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=23&&ver=1';
        docData.last_user = 'SYM_SVC';
        docData.last_user_description = 'Symphony Service Account';
        docData.location = '23.1';
        docData.name = 'Updated Name Field';
        docData.operator = 'SYM_SVC';
        docData.operator_description = 'Symphony Service Account';
        docData.retain_days = '365';
        docData.size = '4';
        docData.system_edit_date = '2023-12-16T14:45:54Z';
        docData.type = 'ANSI';
        docData.type_description = 'Windows Ansi Text';
        docData.version = '1';
        docData.workspace_id = 'MB_SB!5';
        docData.workspace_name = 'iManage Cloud Monitor';
        docData.wstype = 'document';
        
        // Assign the data object to the wrapper's data property
        wrapper.data = docData;

        // Assertions to ensure the values are correctly assigned
        System.assertEquals('full_access', wrapper.data.access);
        System.assertEquals('SYM_SVC', wrapper.data.author);
        System.assertEquals('Symphony Service Account', wrapper.data.author_description);
        System.assertEquals('DOC', wrapper.data.class_code);
        System.assertEquals('Document', wrapper.data.class_description);
        System.assertEquals('D', wrapper.data.content_type);
        System.assertEquals('2023-12-16T14:45:54Z', wrapper.data.create_date);
        System.assertEquals('2023-12-16T14:45:54Z', wrapper.data.create_profile_date);
        System.assertEquals('MB_SB', wrapper.data.database);
        System.assertEquals('23', wrapper.data.document_number);
        System.assertEquals('2023-12-16T14:45:54Z', wrapper.data.edit_date);
        System.assertEquals('2024-01-17T17:48:48Z', wrapper.data.edit_profile_date);
        System.assertEquals('txt', wrapper.data.extension);
        System.assertEquals('MB_SB!23.1', wrapper.data.id);
        System.assertEquals('iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=23&&ver=1', wrapper.data.iwl);
        System.assertEquals('SYM_SVC', wrapper.data.last_user);
        System.assertEquals('Updated Name Field', wrapper.data.name);
        System.assertEquals('365', wrapper.data.retain_days);
        System.assertEquals('4', wrapper.data.size);
        System.assertEquals('1', wrapper.data.version);
        System.assertEquals('iManage Cloud Monitor', wrapper.data.workspace_name);
        System.assertEquals('document', wrapper.data.wstype);
    }
}