@isTest
public class cmpAPiMngLibraryWrapperTest {

    @isTest
    public static void testParseMethod() {
        // Define a sample JSON string
        String jsonResponse = '{  "data": [    {      "id": "123",      "user_id_ex": "user123",      "full_name": "John Doe",      "location": "New York",      "allow_logon": "true",      "email": "johndoe@example.com",      "user_num": 1,      "doc_server": "server01",      "preferred_library": "LibraryA",      "user_nos": 100,      "pwd_changed_ts": "2024-01-01T12:00:00Z",      "password_never_expire": "false",      "failed_logins": 0,      "force_password_change": "false",      "is_external": "false",      "exch_autodiscover": "autodiscover.example.com",      "edit_date": "2024-01-01T12:00:00Z",      "wstype": "user",      "user_id": "user123",      "userid": "user123",      "preferred_database": "DatabaseA",      "login": "john.doe",      "pwd_never_expire": "false",      "database": "DB1"    }  ]}';

        // Call the parse method
        cmpAPiMngLibraryWrapper parsedData = cmpAPiMngLibraryWrapper.parse(jsonResponse);

        
    }
}