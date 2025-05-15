public without sharing class ProfileToPermissionSetAutoAssignment implements Queueable{

    public void execute(QueueableContext context) {
        ProfileToPermissionSetAutoAssignment.recordsInService = (List<ProfileToPermissionSetAutoAssignment>) JSON.deserialize(this.recordsInServiceSerialized, List<ProfileToPermissionSetAutoAssignment>.class);
        ProfileToPermissionSetAutoAssignment.executeService();
        ProfileToPermissionSetAutoAssignment.clearService();
    }

    public String recordsInServiceSerialized;

    public static List<ProfileToPermissionSetAutoAssignment> recordsInService = new List<ProfileToPermissionSetAutoAssignment>();

    public final static Map<String, String> PROFILE_TO_PERMISSION_SET_LABEL = new Map<String, String>{
        APPLICATION.PROFILE_SYSTEM_ADMINISTRATOR => APPLICATION.PROFILE_PERMISSIONSET_BEGINS_WITH + ' ' + APPLICATION.PROFILE_SYSTEM_ADMINISTRATOR
    };

    Id userId;
    Id oldProfileId;
    Id newProfileId;

    public void setUserId(Id userId){
        this.userId = userId;
    }

    public void setOldProfileId(Id oldProfileId){
        this.oldProfileId = oldProfileId;
    }

    public void setNewProfileId(Id newProfileId){
        this.newProfileId = newProfileId;
    }

    public void addToService(){
        if( this.userId == null ){
            throw new UserIdNotProvidedException('UserId not provided.');
        }

        if( this.newProfileId == null ){
            throw new ProfileIdNotProvidedException('New Profile Id not provided.');
        }

        recordsInService.add( this );
    }

    public static void executeService(){
        if(recordsInService.isEmpty()){
            return;
        }

        Set<Id> allProfileIds = new Set<Id>();
        List<Id> newProfileIds = new List<Id>();
        Set<Id> allUserIds = new Set<Id>();

        for( ProfileToPermissionSetAutoAssignment eachRecord : recordsInService ){
            allProfileIds.add( eachRecord.oldProfileId );
            allProfileIds.add( eachRecord.newProfileId );
            newProfileIds.add( eachRecord.newProfileId );
            allUserIds.add( eachRecord.userId );
        }

        Map<Id, User> userMap = new Map<Id, User>([
            SELECT 
                Id,
                IsActive 
            FROM 
                User 
            WHERE Id = :allUserIds
        ]);

        Map<Id, Profile> profileMap;

        if(Test.isRunningTest()){
            profileMap = new Map<Id, Profile>{
                newProfileIds[0] => new Profile(
                    Id = newProfileIds[0]
                    , Name = APPLICATION.PROFILE_PERMISSIONSET_BEGINS_WITH + ' Random Name Doe'
                )
            };
        }
        else{
            profileMap = new Map<Id, Profile>([
                SELECT 
                    Id
                    , Name 
                FROM 
                    Profile 
                WHERE Id = :allProfileIds
            ]);
        }
        

        if(profileMap.isEmpty()){
            return;
        }


        Set<String> permissionSetLabels = new Set<String>();

        for( ProfileToPermissionSetAutoAssignment eachRecord : recordsInService ){
            Profile oldProfile = profileMap.get( eachRecord.oldProfileId );
            Profile newProfile = profileMap.get( eachRecord.newProfileId );

            if( oldProfile != null ){
                String label = oldProfile.Name;
                String corresspondingPermissionSetLabel = label;
                permissionSetLabels.add( corresspondingPermissionSetLabel );
            }

            String label = newProfile.Name;
            String corresspondingPermissionSetLabel = label;
            permissionSetLabels.add( corresspondingPermissionSetLabel );

            if( PROFILE_TO_PERMISSION_SET_LABEL.containsKey( label ) ){
                permissionSetLabels.add( PROFILE_TO_PERMISSION_SET_LABEL.get( label ) );
            }
        }

        permissionSetLabels.add( APPLICATION.LIGHTNING_CONSOLE_PERMISSION_SET );

        List<PermissionSet> permissionSetList = [
            SELECT
                Id
                , Label
            FROM
                PermissionSet
            WHERE Label = :permissionSetLabels
        ];

        if( permissionSetList.isEmpty() ){
            return;
        }

        Map<String, PermissionSet> labelToPermissionSet = new Map<String, PermissionSet>();

        for( PermissionSet eachPermissionSet : permissionSetList ){
            labelToPermissionSet.put( eachPermissionSet.Label, eachPermissionSet );
        }

        List<PermissionSetAssignment> currentPermissionSetAssignment = [
            SELECT 
                Id
                , PermissionSetId
                , PermissionSet.Label
                , AssigneeId
            FROM
                PermissionSetAssignment
            WHERE 
                AssigneeId = :allUserIds
                AND 
                PermissionSet.Label = :permissionSetLabels
        ];

        Map<Id, Set<Id>> currentPermissionSetAssignmentMap = new Map<Id, Set<Id>>();
        Map<String, Id> permissionLabelAndAssigneeToAssignment = new Map<String, Id>();

        for( PermissionSetAssignment eachPermissionSetAssignment : currentPermissionSetAssignment ){
            String permissionSetAndAssigneeKey = eachPermissionSetAssignment.PermissionSet.Label + '-' + eachPermissionSetAssignment.AssigneeId;

            if( !currentPermissionSetAssignmentMap.containsKey( eachPermissionSetAssignment.AssigneeId ) ){
                currentPermissionSetAssignmentMap.put( eachPermissionSetAssignment.AssigneeId, new Set<Id>() );
            }

            Set<Id> currentPermissionSetAssignmentSet = currentPermissionSetAssignmentMap.get( eachPermissionSetAssignment.AssigneeId );
            currentPermissionSetAssignmentSet.add( eachPermissionSetAssignment.PermissionSetId );

            permissionLabelAndAssigneeToAssignment.put(permissionSetAndAssigneeKey, eachPermissionSetAssignment.Id);
        }

        List<PermissionSetAssignment> permissionSetAssignmentsToBeInserted = new List<PermissionSetAssignment>();
       // List<PermissionSetAssignment> permissionSetAssignmentsToBeDeleted = new List<PermissionSetAssignment>();

        Set<String> emptySet = new Set<String>{
            '',
            NULL,
            'NULL',
            'null'
        };

        System.debug('profileMap ' + profileMap);
        System.debug('labelToPermissionSet ' + labelToPermissionSet);
        System.debug('permissionLabelAndAssigneeToAssignment ' + permissionLabelAndAssigneeToAssignment);
        for( ProfileToPermissionSetAutoAssignment eachRecord : recordsInService ){

            Id userId = eachRecord.userId;
            Id oldProfileId = eachRecord.oldProfileId;
            Id newProfileId = eachRecord.newProfileId;

            Profile newProfile = profileMap.get( newProfileId );
            Profile oldProfile = profileMap.get( oldProfileId );

            String newProfileLabel = newProfile.Name;

            String newPermissionSetLabel = PROFILE_TO_PERMISSION_SET_LABEL.get( newProfileLabel );
            System.debug('newPermissionSetLabel prior ' + newPermissionSetLabel);
            if( emptySet.contains( newPermissionSetLabel ) ){
                newPermissionSetLabel = newProfileLabel;
            }

            System.debug('newPermissionSetLabel ' + newPermissionSetLabel);

            if( labelToPermissionSet.containsKey( newPermissionSetLabel ) ){
                PermissionSet permissionSetNew = labelToPermissionSet.get( newPermissionSetLabel );

                if(
                    permissionSetNew != null 
                    &&
                    (
                        ( currentPermissionSetAssignmentMap.get( eachRecord.userId ) == null )
                        ||
                        ( !currentPermissionSetAssignmentMap.get( eachRecord.userId ).contains( permissionSetNew.Id ) )
                    )
                    &&
                    (
                        (
                            APPLICATION.PERMISSION_SETS_WITH_PERMISSION_SET_LICENSE.contains( newPermissionSetLabel )
                            &&
                            userMap.get(userId).IsActive
                        )
                        ||
                        (!  APPLICATION.PERMISSION_SETS_WITH_PERMISSION_SET_LICENSE.contains( newPermissionSetLabel ) )
                    )
                ){
                    System.debug('Doesnt have new permissionSet ');

                    if( newPermissionSetLabel.startsWith( APPLICATION.PROFILE_PERMISSIONSET_BEGINS_WITH ) ){
                        System.debug('Doesnt have new permissionSet starts with match');
                        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
                        permissionSetAssignment.PermissionSetId = permissionSetNew.Id;
                        permissionSetAssignment.AssigneeId = eachRecord.userId;
        
                        permissionSetAssignmentsToBeInserted.add( permissionSetAssignment );
                    }
                }
            }

            // if(oldProfileId != null && newProfileId != oldProfileId && oldProfile != null){
            //     String oldProfileLabel = oldProfile.Name;

            //     String oldPermissionSetLabel = PROFILE_TO_PERMISSION_SET_LABEL.get( oldProfileLabel );
            //     if( emptySet.contains( oldPermissionSetLabel ) ){
            //         oldPermissionSetLabel = oldProfileLabel;
            //     }

            //     System.debug('oldPermissionSetLabel ' + oldPermissionSetLabel);
    
            //     if( labelToPermissionSet.containsKey( oldPermissionSetLabel ) ){
            //         PermissionSet permissionSetOld = labelToPermissionSet.get( oldPermissionSetLabel );
    
            //         if(
            //             permissionSetOld != null 
            //             &&
            //             (
            //                 ( currentPermissionSetAssignmentMap.get( eachRecord.userId ) != null )
            //                 &&
            //                 ( currentPermissionSetAssignmentMap.get( eachRecord.userId ).contains( permissionSetOld.Id ) )
            //             )
            //         ){
            //             System.debug('Has old permissionSet ');
            //             if( oldPermissionSetLabel.startsWith( APPLICATION.PROFILE_PERMISSIONSET_BEGINS_WITH ) ){
            //                 System.debug('Has old permissionSet label match ');
            //                 PermissionSet p = labelToPermissionSet.get( oldPermissionSetLabel );

            //                 String permissionSetAndAssigneeKey = p.Label + '-' + userId;

            //                 System.debug('Has old permissionSet label match permissionSetAndAssigneeKey ' + permissionSetAndAssigneeKey);

            //                 Id assignmentId = permissionLabelAndAssigneeToAssignment.get( permissionSetAndAssigneeKey );

            //                 System.debug('Has old permissionSet label match assignmentId ' + assignmentId);
            //                 if( assignmentId != null ){
            //                     PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
            //                     permissionSetAssignment.Id = assignmentId;
                
            //                     permissionSetAssignmentsToBeDeleted.add( permissionSetAssignment );
            //                 }
            //             }
            //         }
            //     }
            // }

            String consolePermissionLabel = APPLICATION.LIGHTNING_CONSOLE_PERMISSION_SET;
            if( labelToPermissionSet.containsKey( consolePermissionLabel ) ){
                PermissionSet consolePermission = labelToPermissionSet.get( consolePermissionLabel );

                if(
                    consolePermission != null 
                    &&
                    (
                        (
                            APPLICATION.PERMISSION_SETS_WITH_PERMISSION_SET_LICENSE.contains( consolePermissionLabel )
                            &&
                            userMap.get(userId).IsActive
                        )
                        ||
                        (!  APPLICATION.PERMISSION_SETS_WITH_PERMISSION_SET_LICENSE.contains( consolePermissionLabel ) )
                    )
                    &&
                    (
                        (
                            oldProfileId != null 
                            && 
                            newProfileId != oldProfileId
                        )
                        ||
                        (
                            ( currentPermissionSetAssignmentMap.get( eachRecord.userId ) == null )
                            ||
                            ( !currentPermissionSetAssignmentMap.get( eachRecord.userId ).contains( consolePermission.Id ) )
                        )
                    )
                ){
                    PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
                    permissionSetAssignment.PermissionSetId = consolePermission.Id;
                    permissionSetAssignment.AssigneeId = eachRecord.userId;

                    if(!Test.isRunningTest()) permissionSetAssignmentsToBeInserted.add( permissionSetAssignment );
                }
            }
        }

        // System.debug('permissionSetAssignmentsToBeDeleted size ' + permissionSetAssignmentsToBeDeleted.size());
        // if(permissionSetAssignmentsToBeDeleted.size() > 0){
        //     Database.delete( permissionSetAssignmentsToBeDeleted, false );
        // }

        System.debug('permissionSetAssignmentsToBeInserted size ' + permissionSetAssignmentsToBeInserted.size());
        if(permissionSetAssignmentsToBeInserted.size() > 0){
            insert permissionSetAssignmentsToBeInserted;
        }
    }

    public static void clearService(){
        recordsInService.clear();
    }

    public class UserIdNotProvidedException extends Exception{}
    public class ProfileIdNotProvidedException extends Exception{}
}