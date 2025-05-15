@isTest
public class cmpAPiMngWorkSpaceWrapperTest {

    @isTest
    public static void testParseMethod() {

        // Sample JSON that matches the structure of cmpAPiMngWorkSpaceWrapper
        String json = '{' +
                        '"data": {' +
                            '"results": [' +
                                '{' +
                                    '"default_security": "global",' +
                                    '"name": "US00 (206001-6021)",' +
                                    '"owner": "SYM_SVC",' +
                                    '"description": "IP Test One",' +
                                    '"subtype": "work",' +
                                    '"document_number": "76",' +
                                    '"version": "1",' +
                                    '"has_subfolders": "true",' +
                                    '"is_content_saved_search": "false",' +
                                    '"is_container_saved_search": "false",' +
                                    '"database": "MB_SB",' +
                                    '"is_external": "false",' +
                                    '"is_hidden": "false",' +
                                    '"is_external_as_normal": "false",' +
                                    '"owner_description": "Symphony Service Account",' +
                                    '"workspace_id": "MB_SB!121",' +
                                    '"author": "SYM_SVC",' +
                                    '"operator": "SYM_SVC",' +
                                    '"type": "XML",' +
                                    '"classw": "WEBDOC",' +
                                    '"edit_date": "2024-01-27T21:12:11Z",' +
                                    '"system_edit_date": "2024-01-27T21:12:11Z",' +
                                    '"create_date": "2024-01-27T21:12:11Z",' +
                                    '"create_profile_date": "2024-01-27T21:12:11Z",' +
                                    '"retain_days": "365",' +
                                    '"size": "1",' +
                                    '"is_declared": "true",' +
                                    '"declared": "true",' +
                                    '"location": "76.1",' +
                                    '"last_user": "SYM_SVC",' +
                                    '"is_in_use": "false",' +
                                    '"is_checked_out": "false",' +
                                    '"custom1": "206001",' +
                                    '"custom2": "6021",' +
                                    '"custom3": "6021",' +
                                    '"custom4": "US",' +
                                    '"custom5": "6021",' +
                                    '"custom6": "6021",' +
                                    '"custom7": "1",' +
                                    '"custom8": "1",' +
                                    '"custom9": "1",' +
                                    '"custom10": "US00",' +
                                    '"custom1_description": "Bill Bradley",' +
                                    '"custom2_description": "IP Test One",' +
                                    '"custom3_description": "IP Test One",' +
                                    '"custom4_description": "USPTO",' +
                                    '"custom5_description": "USPTO",' +
                                    '"custom6_description": "USPTO",' +
                                    '"custom7_description": "1",' +
                                    '"custom8_description": "1",' +
                                    '"custom9_description": "1",' +
                                    '"custom10_description": "USPTO",' +
                                    '"content_type": "P",' +
                                    '"edit_profile_date": "2024-01-27T21:13:07Z",' +
                                    '"file_create_date": "2024-01-27T21:12:11Z",' +
                                    '"file_edit_date": "2024-01-27T21:12:11Z",' +
                                    '"is_hipaa": "false",' +
                                    '"in_use": "false",' +
                                    '"indexable": "true",' +
                                    '"iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=&&num=76&&ver=1",' +
                                    '"id": "MB_SB!121",' +
                                    '"wstype": "workspace"' +
                                '}' +
                            ']' +
                        '}' +
                    '}';

        Test.startTest();
        
        // Call the parse method and deserialize the JSON
        cmpAPiMngWorkSpaceWrapper.data deserializedData = cmpAPiMngWorkSpaceWrapper.parse(json);
        
        Test.stopTest();
    }
}