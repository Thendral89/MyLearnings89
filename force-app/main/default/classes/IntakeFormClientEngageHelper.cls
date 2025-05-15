public without sharing class IntakeFormClientEngageHelper {
    public IntakeFormClientEngageHelper() {

    }
    public static void updateClientRecord(String ClientId, String conflictCheckId){

        Conflict_Check__c conflictCheck =  [SELECT ID, CC_Status__c FROM Conflict_Check__c WHERE ID =: conflictCheckId];
        if(conflictCheck.CC_Status__c == 'Conflict Check Pending' || conflictCheck.CC_Status__c == 'Conflict Check Skipped'){
            conflictCheck.CC_Status__c = 'Conflict Check Completed';
            update conflictCheck;
        }

        SymphonyLF__Client__c clientRecord =  [SELECT ID, Name, Billing_Address__City__s, Billing_Address__CountryCode__s, Billing_Address__PostalCode__s, Billing_Address__StateCode__s, Billing_Address__Street__s, Managing_Supervising_Attorney__c, Originating_Attorney__c, Responsible_Billing_Attorney__c, Working_Assigned_Attorney__c, Originating_Attorney__r.SymphonyLF__User__c, Originating_Attorney__r.SymphonyLF__User__r.Email, Client_Status__c FROM SymphonyLF__Client__c WHERE ID =: ClientId];
        if(clientRecord.Client_Status__c == 'Yet to Engage'){
            clientRecord.Client_Status__c = 'Active';
            clientRecord.SymphonyLF__Active__c = true;
            update clientRecord;

            SymphonyLF__Other_Address__c otherAddressRec = new SymphonyLF__Other_Address__c();
            otherAddressRec.SymphonyLF__Address__City__s = clientRecord.Billing_Address__City__s;
            otherAddressRec.SymphonyLF__Address__CountryCode__s = clientRecord.Billing_Address__CountryCode__s;
            otherAddressRec.SymphonyLF__Address__PostalCode__s = clientRecord.Billing_Address__PostalCode__s;
            otherAddressRec.SymphonyLF__Address__StateCode__s = clientRecord.Billing_Address__StateCode__s;
            otherAddressRec.SymphonyLF__Address__Street__s = clientRecord.Billing_Address__Street__s;
            otherAddressRec.SymphonyLF__Address_Type__c = 'Billing Address';
            otherAddressRec.SymphonyLF__IP_Matters__c = 'All';
            otherAddressRec.SymphonyLF__Correspondence_Type__c = 'Postal Address';
            otherAddressRec.SymphonyLF__Client__c = clientRecord.Id;
            otherAddressRec.Name = clientRecord.Name;
            insert otherAddressRec;

            if(clientRecord.Managing_Supervising_Attorney__c != null){
                createCEM(clientRecord.Managing_Supervising_Attorney__c, clientRecord.Id, 'Managing Partner');
            }
            if(clientRecord.Originating_Attorney__c != null){
               createCEM(clientRecord.Originating_Attorney__c, clientRecord.Id, 'Responsible Partner');
            }
            if(clientRecord.Responsible_Billing_Attorney__c != null){
                createCEM(clientRecord.Responsible_Billing_Attorney__c, clientRecord.Id, 'Responsible Attorney');
            }
            if(clientRecord.Working_Assigned_Attorney__c != null){
                createCEM(clientRecord.Working_Assigned_Attorney__c, clientRecord.Id, 'Working Attorney');
            }
         

        }

        List<String> list_Licencies = new List<String>{'Salesforce','Salesforce Platform'};
        String excludedProfilesString = Label.SharingModel_ExcludedProfile;
        List<String> excludedProfiles = new List<String>();
        if (!String.isBlank(excludedProfilesString)) {
            excludedProfiles = excludedProfilesString.split(',');
        }
        List<User> list_Users= [SELECT Id, Name, Email,Profile.Name,Profile.UserLicense.Name,IsActive FROM User WHERE IsActive = true  AND Profile.UserLicense.Name IN : list_Licencies AND profile.Name NOT IN :excludedProfiles AND Id!=:UserInfo.getUserId()];
        List<SymphonyLF__Client__share> list_ShareRecords = new List<SymphonyLF__Client__share>();
        List<SymphonyLF__Client__share> clientShares = [SELECT ParentId, UserOrGroupId FROM SymphonyLF__Client__share
                                                    WHERE ParentId =: ClientId AND UserOrGroupId IN : list_Users
                                                    ];
        Map<String,SymphonyLF__Client__share> userVsClientShareMap = new  Map<String,SymphonyLF__Client__share>();
        for(SymphonyLF__Client__share rec : clientShares ){
            userVsClientShareMap.put(rec.UserOrGroupId, rec);
        }
        if(!list_Users.isEmpty()){
            
    
            String lockIdValue = 'Client Record Acess To All Users Lock';
            LockerService.applyLocksAcrossServices(lockIdValue);
            for(User u : list_Users){
                if(!userVsClientShareMap.containsKey(u.Id)){
                    if(u.Id != clientRecord.Originating_Attorney__r.SymphonyLF__User__c){
                    
                        ApexSharingService a = new ApexSharingService();
                        a.setModuleName('Client Record Shared With Wall of Users');
                        a.setShareObject('SymphonyLF__Client__share');
                        a.setRecordId(clientRecord.Id);
                        a.setUserIds(new Set<Id>{ u.id });
                        a.setRowCause('Manual');
                        // String accessLevel = clientRecord.Originating_Attorney__r.SymphonyLF__User__c != u.Id ? 'Read' : 'Edit'; 
                        String accessLevel = 'Edit'; 
                        a.setAccessLevel(accessLevel);
                        a.addShare();
                        
                    }
                }
                
            }
            LockerService.releaseLockAcrossServices(lockIdValue);
        }

        List<Task> taskList = [SELECT Id, Status from Task where WhatId =: conflictCheckId AND Status != 'Completed'];
        if(taskList != null){
            for(Task rec : taskList){
                rec.Status = 'Completed';
            }
            update taskList;
        }

    }

    public static void createCEM(String personId, String clientRecordId, String type){
        List<SymphonyLF__Client_Engagement_Model__c> cemList= [SELECT Id from SymphonyLF__Client_Engagement_Model__c where SymphonyLF__Client__c =: clientRecordId AND SymphonyLF__Type__c =: type];
        if(cemList.isEmpty()){
            SymphonyLF__Client_Engagement_Model__c cem = new SymphonyLF__Client_Engagement_Model__c();
            cem.SymphonyLF__Applicable_to_all_jurisdiction__c = true;
            cem.SymphonyLF__IP_Matters__c = 'All';
            cem.SymphonyLF__Client__c = clientRecordId;
            cem.SymphonyLF__Person__c = personId;
            cem.SymphonyLF__Type__c = type;
            insert cem;
        } 
    }
}