@isTest
public class CKEditControllerTest {

    @isTest
    static void testCKEditControllerWithParameter() {
        // Set a mock parameter value
        Test.setCurrentPageReference(new PageReference('/apex/ckEditor4Page'));
        ApexPages.currentPage().getParameters().put('p7', 'testValue');

        // Instantiate the controller
        CKEditController controller = new CKEditController();

        // Assert the parameter was set correctly
        System.assertEquals('testValue', controller.Parameter);
    }

    @isTest
    static void testCKEditControllerWithoutParameter() {
        // Clear parameters
        Test.setCurrentPageReference(new PageReference('/apex/ckEditor4Page'));
        ApexPages.currentPage().getParameters().clear();

        // Instantiate the controller
        CKEditController controller = new CKEditController();

        // Assert the parameter is null
        System.assertEquals(null, controller.Parameter);
    }
}