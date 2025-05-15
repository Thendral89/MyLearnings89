public class UserTriggerService {

    public static void handleUserActivation(User newUser, User oldUser) {
        if (!newUser.IsActive) return;

        Boolean isEligible = false;

        if (oldUser == null) {
            isEligible = true; 
        } else if (newUser.IsActive != oldUser.IsActive && newUser.IsActive) {
            isEligible = true;
        }

        if (!isEligible) return;

        List<ShareableObjects__mdt> metadataRecords = [
            SELECT MasterLabel, Share_Object_API_Name__c, Row_Cause__c,
                   isActive__c, Parent_Relationship_Path__c
            FROM ShareableObjects__mdt
            WHERE isActive__c = true
        ];

        for (ShareableObjects__mdt meta : metadataRecords) {
            Database.executeBatch(new UserAccessSharingBatch(newUser.Id, meta), 1000);
        }
    }

}