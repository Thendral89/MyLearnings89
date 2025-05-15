public with sharing class ConflictCheckTriggerHandler extends mvSObjectDomain{
    Map<Id, Conflict_Check__c> oldMap;
    List<Conflict_Check__c> newRecords;
    Map<Id, Conflict_Check__c> newMap;

    public ConflictCheckTriggerHandler(List<Conflict_Check__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements mvSObjectDomain.IConstructable {
        public mvSObjectDomain construct(List<SObject> sObjectList) {
            return new ConflictCheckTriggerHandler(sObjectList);
        }
    }

    Set<Id> runSearchResult= new Set<Id>();

    public override void onAfterInsert(){
        this.newRecords = (List<Conflict_Check__c>) records;
        this.newMap = new Map<Id, Conflict_Check__c>(this.newRecords);

        for(Conflict_Check__c newRecord : this.newRecords){
            runSearchResult(newRecord, null);
        }

        if(runSearchResult.size() > 0){
            createTasks();
            runSearchResult();
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords){
        this.newRecords = (List<Conflict_Check__c>) records;
        this.newMap = new Map<Id, Conflict_Check__c>(this.newRecords);
        this.oldMap = (Map<Id, Conflict_Check__c>) existingRecords;

        for(Conflict_Check__c newRecord : this.newRecords){
            Conflict_Check__c oldRecord = this.oldMap.get(newRecord.Id);
            runSearchResult(newRecord, oldRecord);
        }

        if(runSearchResult.size() > 0){
            runSearchResult();
        }
    }

    static Set<String> runSearchResultTrackedFiedls = new Set<String>{
        'Adverse_Parties__c',
        'Related_Parties_other_than_client__c',
        'Contributor__c',
        'Keywords__c',
        'Client_Name__c'
    };

    void runSearchResult(Conflict_Check__c newRecord, Conflict_Check__c oldRecord){
        if(
            oldRecord == null
        ){
            runSearchResult.add( newRecord.Id );
            return;
        }

        sObject newR = newRecord;
        sObject oldR = oldRecord;

        for(String field : runSearchResultTrackedFiedls){
            if(newR.get(field) != oldR.get(field)){
                runSearchResult.add( newRecord.Id );
                break;
            }
        }
    }

    void runSearchResult(){
        for(Id i : runSearchResult){
            ConflictCheckSearchResultService c = new ConflictCheckSearchResultService();
            c.setOperationType(ConflictCheckSearchResultService.OperationType.DELETE_AND_SEARCH);
            c.setConflictCheck(this.newmap.get(i));
            c.execute();
        }
    }

    void createTasks(){
        Set<String> userLicenseAllowed = new Set<String>{
            'Salesforce Platform',
            'Salesforce'
        };

        Set<String> profilesNotToInclude = new Set<String>{
            'Account and Finance Team',
            'System Administrator',
            'Client',
            'Chatter Free User',
            'API Only User'
        };
        Set<Id> ccIds = new Set<Id>();
            
        Set<Id> wallUserIds = new Set<Id>();
        for(Conflict_Check__c conflictCheck : this.newRecords){
            ccIds.add(conflictCheck.Id);
        }
        for(Conflict_Check__c conflictCheckRecord: this.newRecords){
            if(conflictCheckRecord.Client_Name__c <> Null){
                wallUserIds.add(conflictCheckRecord.Client_Name__c);}
        }
         if(wallUserIds.size()>0){
            for(Access_Restriction__c wallOfuser : [SELECT id,User__c FROM Access_Restriction__c WHERE Status__c = 'Enforced' and Client__c IN : wallUserIds]){
                if(wallOfuser.User__c <> Null){
                    wallUserIds.add(wallOfuser.User__c);}
            } 
      } 

        List<Task> list_tasks = new List<Task>();

        List<User> list_users = [
            SELECT 
                Id, Profile.Name,Profile.UserLicense.Name,isActive
            FROM 
                User 
            WHERE 
                isActive = true 
                AND 
                Profile.UserLicense.Name IN : userLicenseAllowed 
                AND 
                profile.Name NOT IN :profilesNotToInclude 
                AND 
                ID !=: UserInfo.getUserId()
                AND 
                ID NOT IN : wallUserIds
        ];
           
        if(!list_users.isEmpty()){
            String lockIdValue = 'Conflict check Record Acess To All Users Lock';
            //LockerService.applyLocksAcrossServices(lockIdValue);
            List<Conflict_Check__c> conflictcheck = [Select Id,name,Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c From Conflict_Check__c Where Id IN :ccIds ];
            if(!conflictcheck.isEmpty() ){
            for(Conflict_Check__c conflictCheckRecord: conflictcheck){
                for(User userRecord : list_users){
                    System.debug('conflictCheckRecord---->'+conflictCheckRecord);
                    System.debug('userRecord.Id----->'+userRecord.Id);
                    if(conflictCheckRecord.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c != userRecord.Id){
                        list_tasks.add(
                            new Task(
                                WhatId = conflictCheckRecord.Id,
                                OwnerId = userRecord.id,
                                ForId__c = userRecord.id,
                                Subject = 'Approve / Discuss for the client for this Conflict Check '+conflictCheckRecord.name,
                                Status = 'Not Yet Started',
                                ActivityDate = Date.today() + 13
                            )
                        );
                    }

                   /* ApexSharingService a = new ApexSharingService();
                    a.setModuleName('After create Conflict Check record through Form');
                    a.setShareObject('Conflict_Check__Share');
                    a.setRecordId(conflictCheckRecord.Id);
                    a.setUserIds(new Set<Id>{ userRecord.id });
                    a.setRowCause('Manual');
                    String accessLevel = conflictCheckRecord.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c != userRecord.Id ? 'Read' : 'Edit'; 
                    system.debug('accessLevel++'+ accessLevel);
                    a.setAccessLevel(accessLevel);
                    a.addShare();*/
                }    
            }
        }
            
            //LockerService.releaseLockAcrossServices(lockIdValue);
        }
        if(!list_tasks.isEmpty()){
            insert list_tasks;
        }
    }
}