public with sharing class UserTriggerHandler extends mvSObjectDomain{
    Map<Id, sObject> oldMap;
    List<sObject> newRecords;
    Map<Id, sObject> newMap;

    public UserTriggerHandler(List<sObject> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new UserTriggerHandler(sObjectList);
        }
    }

    public override void onAfterInsert(){
        this.newRecords = records;
        this.newMap = new Map<Id, sObject>( this.newRecords );

        for(sObject newRecord : this.newRecords){
            profileAutoAssignemnt(newRecord, null);
            shareRecordswithActivatedUsers(newRecord, null);
        }

        profileAutoAssignemnt();
        shareRecordswithActivatedUsers();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords){
        this.newRecords = records;
        this.newMap = new Map<Id, sObject>( this.newRecords );
        this.oldMap = existingRecords;

        for(sObject newRecord : this.newRecords){
            sObject oldRecord = this.oldMap.get( (Id) newRecord.get('Id') );
            profileAutoAssignemnt(newRecord, oldRecord);
            shareRecordswithActivatedUsers(newRecord, oldRecord);
        }

        System.debug('profileAutoAssignemnt_r => ' + profileAutoAssignemnt_r);
        System.debug('profileAutoAssignemnt => ' + profileAutoAssignemnt);


        profileAutoAssignemnt();
        shareRecordswithActivatedUsers();
    }

    Set<Id> profileAutoAssignemnt = new Set<Id>();
    static Set<Id> profileAutoAssignemnt_r = new Set<Id>();
    Set<Id> profileAutoAssignemnt_UserActive = new Set<Id>();
    Set<Id> profileAutoAssignemnt_ProfileChanged = new Set<Id>();

    private void profileAutoAssignemnt(sObject newRecord, sObject oldRecord){
        Id i = (Id) newRecord.get('Id');

        if(profileAutoAssignemnt_r.contains(i)){
            return;
        }

        Boolean isActive = (Boolean) newRecord.get('IsActive');
        
        if(
            ( oldRecord == null && isActive == true ) 
            ||
            ( 
                oldRecord != null 
                 && 
                 isActive == true
                &&
                ( 
                    ( oldRecord.get('IsActive') != newRecord.get('IsActive') )
                    ||
                    oldRecord.get('ProfileId') != newRecord.get('ProfileId')
                )
            )
        ){
            profileAutoAssignemnt.add(i);
            profileAutoAssignemnt_r.add(i);

            if(oldRecord == null){
                profileAutoAssignemnt_UserActive.add( i );
            }
            else if( oldRecord.get('ProfileId') != newRecord.get('ProfileId') ){
                profileAutoAssignemnt_ProfileChanged.add( i );
            }
            else{
                profileAutoAssignemnt_UserActive.add( i );
            }
        }
    }

    private void profileAutoAssignemnt(){

        if(profileAutoAssignemnt.size() == 0){
            System.debug('profileAutoAssignemnt empty');
            return;
        }

        if(profileAutoAssignemnt_UserActive.size() > 0){
            for(Id userId : profileAutoAssignemnt_UserActive){
                sObject newUser = this.newMap.get( userId ); 
    
                ProfileToPermissionSetAutoAssignment p = new ProfileToPermissionSetAutoAssignment();
                p.setUserId(userId);
                p.setNewProfileId( (Id) newUser.get('ProfileId') );
    
                if(
                    oldMap != null
                ){
                    sObject oldUser = this.oldMap.get( userId );
                    p.setOldProfileId( (Id) oldUser.get('ProfileId') );
                }
    
                p.addToService();
            }
    
            ProfileToPermissionSetAutoAssignment pp = new ProfileToPermissionSetAutoAssignment();
            pp.recordsInServiceSerialized = JSON.serialize( ProfileToPermissionSetAutoAssignment.recordsInService );
            System.enqueueJob(pp);
    
            ProfileToPermissionSetAutoAssignment.clearService();
        }
        
        if(profileAutoAssignemnt_ProfileChanged.size() > 0){
            for(Id userId : profileAutoAssignemnt_ProfileChanged){
                sObject newUser = this.newMap.get( userId ); 
    
                ProfileToPermissionSetAutoAssignment p = new ProfileToPermissionSetAutoAssignment();
                p.setUserId(userId);
                p.setNewProfileId( (Id) newUser.get('ProfileId') );
    
                if(
                    oldMap != null
                ){
                    sObject oldUser = this.oldMap.get( userId );
                    p.setOldProfileId( (Id) oldUser.get('ProfileId') );
                }
    
                p.addToService();
            }
    
            ProfileToPermissionSetAutoAssignment ppp = new ProfileToPermissionSetAutoAssignment();
            ppp.recordsInServiceSerialized = JSON.serialize( ProfileToPermissionSetAutoAssignment.recordsInService );
            System.enqueueJob(ppp, 1); // Delay factor 1 in case profile is changed
    
            ProfileToPermissionSetAutoAssignment.clearService();
        }
        
    }

    Set<Id> activatedUsers = new Set<Id>();

    private void shareRecordswithActivatedUsers(sObject newRecord, sObject oldRecord) {
        Id userId = (Id)newRecord.get('Id');
        Boolean isActive = (Boolean)newRecord.get('IsActive');

        if (
            (oldRecord == null && isActive) 
            ||
            (
                oldRecord != null 
                && 
                isActive 
                && 
                oldRecord.get('IsActive') != newRecord.get('IsActive'))
            ) {
            activatedUsers.add(userId);
        }
    }

    private void shareRecordswithActivatedUsers() {
        if (activatedUsers.isEmpty()) {
            return;
        }

        List<ShareableObjects__mdt> metadataRecords = [
            SELECT MasterLabel, Share_Object_API_Name__c, Row_Cause__c,
                   isActive__c, Parent_Relationship_Path__c
            FROM ShareableObjects__mdt
            WHERE isActive__c = true
        ];

        for (Id userId : activatedUsers) {
            User newUser = (User) this.newMap.get(userId);
            for (ShareableObjects__mdt meta : metadataRecords) {
                Database.executeBatch(new UserAccessSharingBatch(newUser.Id, meta), 1000);
            }
        }
    }
}