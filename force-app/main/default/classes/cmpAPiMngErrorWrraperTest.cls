@isTest
public class cmpAPiMngErrorWrraperTest {

    @isTest
    static void testCmpAPiMngErrorWrraper() {
        // Step 1: Create an instance of the 'error' class and populate fields
        cmpAPiMngErrorWrraper.error testError = new cmpAPiMngErrorWrraper.error();
        testError.code = 'NRC_INVALID_PARAM';
        testError.code_message = 'Invalid parameter for request';
        testError.detailed_error_message = 'Libraries do not match';
        testError.dms_version = '10.4.7.758';
        testError.function = 'verify_library_id';
        
        // Step 2: Create an instance of cmpAPiMngErrorWrraper and set the 'error' field
        cmpAPiMngErrorWrraper cmpApiMngError = new cmpAPiMngErrorWrraper();
        cmpApiMngError.error = testError;

        // Step 3: Use assertions to verify that the values have been set correctly
        System.assertEquals('NRC_INVALID_PARAM', cmpApiMngError.error.code, 'Error code is not correct');
        System.assertEquals('Invalid parameter for request', cmpApiMngError.error.code_message, 'Error code message is not correct');
        System.assertEquals('Libraries do not match', cmpApiMngError.error.detailed_error_message, 'Detailed error message is not correct');
        System.assertEquals('10.4.7.758', cmpApiMngError.error.dms_version, 'DMS version is not correct');
        System.assertEquals('verify_library_id', cmpApiMngError.error.function, 'Function name is not correct');
    }
}