public without sharing class UserProfileUpdateBatch {
    public static void execute(Integer batchSize) {
        Set<String> oldProfiles = APPLICATION.OLD_TO_NEW_PROFILE_NAME.keySet();
        if(batchSize == null) batchSize = 10;
        List<User> scope = [
            SELECT 
                Id,
                ProfileId,
                Profile.Name
            FROM
            	User
            WHERE
            	Profile.Name IN :oldProfiles
            LIMIT 10
        ];

        profileInformation();

        for(User u : scope){
            if(APPLICATION.OLD_TO_NEW_PROFILE_NAME.containsKey(u.Profile.Name)){
                Id newProfileId = profileLabelToProfile.get(APPLICATION.OLD_TO_NEW_PROFILE_NAME.get(u.Profile.Name));
                if(newProfileId != null) u.ProfileId = newProfileId;
            }
        }
        update scope;
    }

    static Map<String, Id> profileLabelToProfile = new Map<String, Id>();
    private static void profileInformation(){
        Set<String> allProfiles = new Set<String>();
        allProfiles.addAll(APPLICATION.OLD_TO_NEW_PROFILE_NAME.keySet());
        allProfiles.addAll(APPLICATION.OLD_TO_NEW_PROFILE_NAME.values());
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Name IN:allProfiles]){
            profileLabelToProfile.put(p.Name, p.Id);
        }
    }
}