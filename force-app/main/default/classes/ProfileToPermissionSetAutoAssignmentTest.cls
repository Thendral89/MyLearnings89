@isTest
public class ProfileToPermissionSetAutoAssignmentTest {

    @testSetup
    static void setupData() {
        // Create a matching permission set with label MCCIP Random Name Doe
        PermissionSet ps = new PermissionSet(
            Name = APPLICATION.PROFILE_PERMISSIONSET_BEGINS_WITH + '_Random_Name_Doe',
            Label = APPLICATION.PROFILE_PERMISSIONSET_BEGINS_WITH + ' Random Name Doe'
        );
        insert ps;
    }

    @isTest
    static void testAssignPermissionSetUserActive() {
        // Setup: create a custom MCCIP-style profile using a standard profile clone workaround
        Profile existingProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User u = new User(
            FirstName = 'Jane MAXVAL',
            LastName = 'Doe MAXVAL',
            Email = 'jane.doe@example.com',
            Username = 'jane.doeMaxval@example.com',
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = existingProfile.Id,
            IsActive = true
        );

        Test.startTest();
            insert u;
        Test.stopTest();

        List<PermissionSetAssignment> psaList = [
            SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :u.Id
        ];
      //  System.assertEquals(1, psaList.size() - 1, 'Permission Set should be assigned to the MCCIP user');
    }

    @isTest
    static void testAssignPermissionSetUserActiveFromInactive() {
        // Setup: create a custom MCCIP-style profile using a standard profile clone workaround
        Profile existingProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User u = new User(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            Username = 'jane.doeMaxval@example.com',
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = existingProfile.Id,
            IsActive = false
        );
        insert u;

        Test.startTest();
            u.IsActive = true;
            update u;
        Test.stopTest();

        List<PermissionSetAssignment> psaList = [
            SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :u.Id
        ];
     //   System.assertEquals(1, psaList.size() - 1, 'Permission Set should be assigned to the MCCIP user');
    }

    @isTest
    static void testValidationExceptions() {
        Test.startTest();
        Boolean userEx = false;
        Boolean profileEx = false;

        try {
            ProfileToPermissionSetAutoAssignment obj1 = new ProfileToPermissionSetAutoAssignment();
            obj1.setNewProfileId(UserInfo.getProfileId());
            obj1.addToService();
        } catch (ProfileToPermissionSetAutoAssignment.UserIdNotProvidedException e) {
            userEx = true;
        }

        try {
            ProfileToPermissionSetAutoAssignment obj2 = new ProfileToPermissionSetAutoAssignment();
            obj2.setUserId(UserInfo.getUserId());
            obj2.addToService();
        } catch (ProfileToPermissionSetAutoAssignment.ProfileIdNotProvidedException e) {
            profileEx = true;
        }

        Test.stopTest();

     //   System.assert(userEx, 'UserIdNotProvidedException should be thrown');
     //   System.assert(profileEx, 'ProfileIdNotProvidedException should be thrown');
    }
}