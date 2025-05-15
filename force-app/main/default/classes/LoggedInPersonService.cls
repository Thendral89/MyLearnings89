public class LoggedInPersonService {
    // Helper method to check if the user should be bypassed
    public static Boolean isBypassUser() {
        // Get the current user's profile name
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        // Retrieve the custom label and split it into a list
        String bypassProfilesLabel = Label.BypassProfilesForMEMValidation;
        List<String> bypassProfiles = bypassProfilesLabel.split(',');

        // Check if the profile matches
        return bypassProfiles.contains(profileName);
    }
}