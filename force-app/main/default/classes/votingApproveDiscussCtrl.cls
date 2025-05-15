public without sharing class votingApproveDiscussCtrl {
    @AuraEnabled
    public static string taskForApprove(String conflictCheckId){
        try {
            List<Task> tasks = [SELECT Id, WhatId, OwnerId, Subject, Status ,ForId__c
                                FROM Task 
                                WHERE WhatId = :conflictCheckId AND (Status = 'Not Yet Started' OR Status = 'Approve' OR Status = 'Discuss')
                                AND ForId__c = :UserInfo.getUserId()];
            Conflict_Check__c ccRecord = [SELECT ID
                                          , Name
                                          , Client_Name__c
                                          , CreatedById
                                          , Approved_Users__c
                                          , Discuss_Needed_Users__c
                                          , Client_Name__r.Originating_Attorney__c
                                          , Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c
                                          FROM Conflict_Check__c
                                          WHERE Id = : conflictCheckId];
            
            
            
            
            if (!tasks.isEmpty() && tasks[0].Status == 'Not Yet Started') {
                // If no tasks exist, create a new task
                tasks[0].Status = 'Approve';
                tasks[0].OwnerId = ccRecord.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c != null ? ccRecord.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c : ccrecord.CreatedById;
                tasks[0].Subject = UserInfo.getName()+' has Approved this conflict check '+ccRecord.Name;
                //ccRecord.ApprovedUsers__C
                try{
                    update tasks[0];
                    updataConflictCheckOnApprove(ccRecord);
                    return 'Success';
                }catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            
            else if(!tasks.isEmpty() && tasks[0].Status != 'Not Yet Started'){
                if(tasks[0].Status == 'Approve'){
                    return 'Already Approved';
                }
                else if(tasks[0].Status == 'Discuss'){
                    return 'Already Initiated For Discussion';
                }
                else{
                    return 'Task Record Not Found';
                }
            } 
            else{
                return 'Task Record Not Found';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static string taskForDiscuss(String conflictCheckId){
        try {
            system.debug('conflictCheckId '+conflictCheckId);
            List<Task> tasks = [SELECT Id, WhatId, OwnerId, Subject, Status ,ForId__c
                                FROM Task 
                                WHERE WhatId = :conflictCheckId AND  (Status = 'Not Yet Started' OR Status = 'Approve' OR Status = 'Discuss')
                                AND ForId__c = :UserInfo.getUserId()];
            Conflict_Check__c ccRecord = [SELECT ID
                                          , Name
                                          , Client_Name__c
                                          , CreatedById
                                          , Approved_Users__c
                                          , Discuss_Needed_Users__c
                                          , Client_Name__r.Originating_Attorney__c
                                          , Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c
                                          FROM Conflict_Check__c
                                          WHERE Id = : conflictCheckId];
            
            
            if(tasks.isEmpty() || (!tasks.isEmpty() && tasks[0].OwnerId != UserInfo.getUserId())){
                return 'Task Record Not Found';
            }else if(!tasks.isEmpty()){
                if(tasks[0].Status == 'Approve'){
                    return 'Already Approved';
                }
                else if(tasks[0].Status == 'Discuss'){
                    return 'Already Discussion Initiated';
                }else if(tasks[0].Status == 'Not Yet Started'){
                    Conflict_Check_Email_Settings__c customSettingRecord = Conflict_Check_Email_Settings__c.getValues('CC Email Configurations');
                    if(customSettingRecord.Show_Comments_For_Discuss__c) {
                         return 'Show Comment';
                    }
                   
                }
                else{
                    return 'Task Record Not Found';
                }
            }
            return '';
            
        } catch (Exception e) {
            System.debug(' votingApproveDiscussCtrl.taskForDiscuss : '+ e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }   
        
    }
    
    @AuraEnabled
    public static string updateDiscussComments(String conflictCheckId,String comments){
        try {
            
            List<Task> tasks = [SELECT Id, WhatId, OwnerId, Subject, Status ,ForId__c
                                FROM Task 
                                WHERE WhatId = :conflictCheckId AND  (Status = 'Not Yet Started' OR Status = 'Approve' OR Status = 'Discuss')
                                AND ForId__c = :UserInfo.getUserId()];
            Conflict_Check__c ccRecord = [SELECT ID
                                          , Name
                                          , Client_Name__c
                                          , CreatedById
                                          , Approved_Users__c
                                          , Discuss_Needed_Users__c
                                          , Client_Name__r.Originating_Attorney__c
                                          , Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c
                                          FROM Conflict_Check__c
                                          WHERE Id = : conflictCheckId];
            
            
            if (!tasks.isEmpty() && tasks[0].Status == 'Not Yet Started') {
                tasks[0].Status = 'Discuss';
                tasks[0].Subject = UserInfo.getName()+' wants to discuss on this conflict check '+ccRecord.Name;
                tasks[0].Description = comments;
                tasks[0].OwnerId = ccRecord.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c != null ? ccRecord.Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c : ccrecord.CreatedById;
                try{
                    update tasks[0];
                    updataConflictCheck(ccRecord);
                    return 'Success';
                }catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            return 'Failed';
            
        } catch (Exception e) {
            System.debug(' votingApproveDiscussCtrl.taskForDiscuss : '+ e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }   
        
    }
    
    public static string updataConflictCheck(Conflict_Check__c ccRecord){
        
        String discussUsers =ccRecord.Discuss_Needed_Users__c??'';
        String approvedUsers =ccRecord.Approved_Users__c??'';
        if(discussUsers=='' || !discussUsers.contains(UserInfo.getUserId()) ){
            discussUsers = discussUsers!='' ? discussUsers+','+UserInfo.getUserId() : UserInfo.getUserId();
        }
        else{
            if(approvedUsers.contains(UserInfo.getUserId()) ){
                return 'Already Approved';
            }
            else{
                return 'Already Discussion Initiated';
            }
            
        }
        ccRecord.Discuss_Needed_Users__c =  discussUsers ?? '';
        try{
            update ccRecord;
            return 'Success';
        }catch (Exception e) {
            System.debug('taskForApprove ==> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static string updataConflictCheckOnApprove(Conflict_Check__c ccRecord){
        
        String discussUsers =ccRecord.Discuss_Needed_Users__c??'';
        String approvedUsers =ccRecord.Approved_Users__c??'';
        if(approvedUsers=='' || !approvedUsers.contains(UserInfo.getUserId())){
            approvedUsers = approvedUsers!='' ? approvedUsers+','+UserInfo.getUserId() : UserInfo.getUserId();
        }
        else{
            if(discussUsers=='' || discussUsers.contains(UserInfo.getUserId())){
                return 'Already Initiated For Discussion';
            }
            else{
                return 'Already Approved';
            }
            
        }
        ccRecord.Approved_Users__c =  approvedUsers ?? '';
        try{
            update ccRecord;
            return 'Success';
        }catch (Exception e) {
            System.debug('taskForApprove ==> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}