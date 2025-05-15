public without sharing class cmpAPTrgUtilCtrl {
 
    
    // Created to check Access_Restriction__c before record sharing
    public static Map<Id, Set<Id>> getWallOffUserMap(List<Id> userIds) {
        Map<Id, Set<Id>> wallOffUserMap = new Map<Id, Set<Id>>();
        
        List<Access_Restriction__c> wallOffRecords = [
            SELECT User__c, Client__c, Patent__c, Design__c, Trademark__c, Copyright__c, 
            Agreement_and_Contract__c, General_Matter__c
            FROM Access_Restriction__c 
            WHERE Revoke_Record_Access__c = true 
            AND User__c IN :userIds
            LIMIT 50000
        ];
        
        // Populate the map only if lookup fields are not null
        for (Access_Restriction__c wallOff : wallOffRecords) {
            addToWallOffUserMap(wallOffUserMap, wallOff.Client__c, wallOff.User__c);
            addToWallOffUserMap(wallOffUserMap, wallOff.Patent__c, wallOff.User__c);
            addToWallOffUserMap(wallOffUserMap, wallOff.Design__c, wallOff.User__c);
            addToWallOffUserMap(wallOffUserMap, wallOff.Trademark__c, wallOff.User__c);
            addToWallOffUserMap(wallOffUserMap, wallOff.Agreement_and_Contract__c, wallOff.User__c);
            addToWallOffUserMap(wallOffUserMap, wallOff.General_Matter__c, wallOff.User__c);
        }
        
        return wallOffUserMap;
    }
    
    private static void addToWallOffUserMap(Map<Id, Set<Id>> wallOffUserMap, Id recordId, Id userId) {
        if (recordId == null) {
            return; // Skip null record IDs
        }
        if (!wallOffUserMap.containsKey(recordId)) {
            wallOffUserMap.put(recordId, new Set<Id>());
        }
        wallOffUserMap.get(recordId).add(userId);
    }// end of code Wall of User check

    
    Public static void PatentCheckList(List<Id> recordIds,string ObjectName) {
        
        /*
        try {
            for(Integer i = 0; i < recordIds.size(); i++) { 
                Map<String, Object> params = new Map<String, Object>();
                params.put('recordId', recordIds[i]);
                params.put('ObjectName',ObjectName);
                Flow.Interview.cmpAP_Generate_DocketNumber yourFlow = new Flow.Interview.cmpAP_Generate_DocketNumber(params);
                yourFlow.start();
            }
        } catch (Exception e) {
            system.debug('e.getMessage() ' + e.getMessage()); 
        } 
       */ 
        
    }
    
    /*
    Public static void objectRecordShareMDT(List<Id> userIds) {
        
        Set<Id> userIdSet = new Set<Id>(userIds);
        String excludedProfilesString = Label.SharingModel_ExcludedProfile;
        List<String> excludedProfiles = new List<String>();
        if (!String.isBlank(excludedProfilesString)) {
            excludedProfiles = excludedProfilesString.split(',');
        }
        
        // Query the users associated with the provided IDs and excluded profiles
        Map<Id, User> usersMap = new Map<Id, User>([
            SELECT Id, Profile.Name
            FROM User
            WHERE Id IN :userIds AND Profile.Name NOT IN :excludedProfiles
        ]);
        
        // Remove excluded users from the userIds set
        for (Id userId : usersMap.keySet()) {
            userIdSet.remove(userId);
        }
        if(userIdSet.isEmpty()){
            return;
        }
        Set<Id> clientIds = new Set<Id>();
        clientUserShareBatch childBatch = new clientUserShareBatch(
            false,
            'SymphonyLF__Client__share',
            'SymphonyLF__Client__c',
            '',
            'Manual',
            'Edit',
            userIdSet, clientIds);
        Database.executeBatch(childBatch);
    }
   */
    
    @future    
    public static void PatentCheckListfuture(List<Id> recordIds,string ObjectName) {
        cmpAPTrgUtilCtrl.PatentCheckList(recordIds,ObjectName);
    }
    
    @future
    public static void ObjectRecordSharingfuture(string ObjectName,List<Id> GroupId ) {
        cmpAPTrgUtilCtrl.ObjectRecordSharing(ObjectName,GroupId);
    }
    
    public static void ObjectRecordSharing(String ObjectName,List<Id> GroupId) {
        List<Id> recordIds = new List<Id>();
        List<Id> clientID = new List<Id>();
        
        String query = 'SELECT Id FROM ' + ObjectName + 
            ' Order By CreatedDate Limit 50000';
        List<sObject> ObjLst = Database.query(query);
        for (sObject data : ObjLst) {
            String parentId = (String)data.get('Id');
            //String clientIds = (String)data.get('SymphonyLF__Client__c');
            //if (!clientID.contains(clientIds)) 
            recordIds.add(parentId);
            
            
        }
        
        ObjectName=ObjectName.replace('__c','__Share');
        query = 'SELECT Id, UserOrGroupId, ParentId FROM ' + ObjectName + 
            ' WHERE ParentId IN :recordIds  Limit 50000 ';
        List<sObject> objList = Database.query(query);
        Set<String> duplicateIds = new Set<String>();
        Map<String, sObject> recordsToUpdate = new Map<String, sObject>();
        for (sObject record : objList) {
            String userOrGroupId = (String)record.get('UserOrGroupId');
            String parentId = (String)record.get('ParentId');
            duplicateIds.add(userOrGroupId + '-' + parentId);
        }
        
        
        for (Id recordId : recordIds) { 
            for(Integer i = 0; i < GroupId.size(); i++) {  
                if (!duplicateIds.contains(GroupId[i] + '-' + recordId)) {
                    sObject newRecord = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                    newRecord.put('UserOrGroupId', GroupId[i]);
                    newRecord.put('ParentId', recordId);
                    newRecord.put('RowCause', 'Manual');
                    newRecord.put('AccessLevel', 'Edit');
                    recordsToUpdate.put(GroupId[i] + '-' + recordId, newRecord);
                }
            }
        }
        
        System.debug('recordsToUpdate: ' + recordsToUpdate);
        
        if (!recordsToUpdate.isEmpty()) {
            try {
                upsert recordsToUpdate.values();
            } catch (Exception e) {
                System.debug('Error during upsert: ' + e.getMessage());
            }
        }
        
        
    }
    
    @future
    public static void ShareFeatureClientMatterObj(string ObjectName,List<Id> recordId, Map<Id, Id> ClientIdMap) {
        cmpAPTrgUtilCtrl.OrgRecordSharing(ObjectName,recordId,ClientIdMap);
    }
    @future
    public static void OrgRecordSharingfuture(string ObjectName,List<Id> recordId) {
        cmpAPTrgUtilCtrl.OrgRecordSharing(ObjectName,recordId, new Map<Id, Id>());
    }
    public static void OrgRecordSharing(String ObjectName, List<Id> recordIds) {
        OrgRecordSharing(ObjectName, recordIds, new Map<Id, Id>());
    }  
    public static void OrgRecordSharing(String ObjectName, List<Id> recordIds, Map<Id, Id> ClientIdMap) {
        List<Id> clientID = new List<Id>();
        List<Id> ClientUsers = new List<Id>();
        List<Id> DplicateIds = new List<Id>();
        Map<String, sObject> recordsObjToUpdate = new Map<String, sObject>();
        Map<String, sObject> recordsToUpdate = new Map<String, sObject>();
        if (clientIdMap == null) {
            clientIdMap = new Map<Id, Id>();}
        List<Id> GroupId= cmpAPTrgUtilCtrl.getActiveUsers();
        if (GroupId.isEmpty()) {
            return; 
        }
        
        
        string SymObject=ObjectName.replace('__Share','__c');
        
        
      Map<Id, Set<Id>> wallOffUserMap = cmpAPTrgUtilCtrl.getWallOffUserMap(GroupId);     
      try {
        for (Id recordId : recordIds) {              
            for(Integer i = 0; i < GroupId.size(); i++) {  
                if(wallOffUserMap != null && clientIdMap!=null){
                    Id clientRecId = ClientIdMap?.get(recordId);
                    if (clientId!=null && wallOffUserMap.containsKey(clientRecId) && wallOffUserMap.get(clientRecId).contains(GroupId[i])) {
                        continue;}
                }
                
                sObject newRecord = Schema.getGlobalDescribe().get(ObjectName).newSObject();  
                newRecord.put('UserOrGroupId', GroupId[i]);
                newRecord.put('ParentId', recordId);
                newRecord.put('RowCause', 'Manual');
                newRecord.put('AccessLevel', 'Edit');
                recordsToUpdate.put(GroupId[i] + '-' + recordId, newRecord);
            }
        }  
      
      } catch (Exception e) {
          System.debug('Error during insert: ' + e.getMessage());
      }
        
        system.debug('recordsToUpdate ' + recordsToUpdate);
    
        
        if (!recordsToUpdate.isEmpty()) {//recordsToUpdate.values()
            try {
                Database.SaveResult[] saveResults = Database.insert(recordsToUpdate.values(), false);
                for (Database.SaveResult sr : saveResults) {
                    if (!sr.isSuccess()) {
                        // If not successful, log the error and the failed record
                        System.debug('Failed to insert record with Id: ' + sr.getId());
                        System.debug('Error message: ' + sr.getErrors()[0].getMessage());
                    }
                }
            } catch (Exception e) {
                System.debug('Error during insert: ' + e.getMessage());
            }
        }
        
        /* Commented these lines as in multiple objects IsProcessedField is not there 
if (!recordsObjToUpdate.isEmpty()) {
try {
upsert recordsObjToUpdate.values();
} catch (Exception e) {
System.debug('Error during recordsObjToUpdate: ' + e.getMessage());
}
}*/
        
        
    }
    
    public static void cmpAPSharedBatch(String ObjectName, List<Id> UserIds, List<Id> recordIds) {
        List<Id> clientID = new List<Id>();
        String query = '';
        
        ObjectName=ObjectName.replace('__c','__Share');
        query = 'SELECT Id, UserOrGroupId, ParentId FROM ' + ObjectName + 
            ' WHERE ParentId IN :recordIds  Limit 50000 ';
        List<sObject> objList = Database.query(query);
        Set<String> duplicateIds = new Set<String>();
        Map<String, sObject> recordsToUpdate = new Map<String, sObject>();
        for (sObject record : objList) {
            String userOrGroupId = (String)record.get('UserOrGroupId');
            String parentId = (String)record.get('ParentId');
            duplicateIds.add(userOrGroupId + '-' + parentId);
        }
        
        
        for (Id recordId : recordIds) { 
            for(Integer i = 0; i < UserIds.size(); i++) {  
                if (!duplicateIds.contains(UserIds[i] + '-' + recordId)) {
                    sObject newRecord = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                    newRecord.put('UserOrGroupId', UserIds[i]);
                    newRecord.put('ParentId', recordId);
                    newRecord.put('RowCause', 'Manual');
                    newRecord.put('AccessLevel', 'Edit');
                    recordsToUpdate.put(UserIds[i] + '-' + recordId, newRecord);
                }
            }
        }
        
        System.debug('recordsToUpdate: ' + recordsToUpdate);
        
        if (!recordsToUpdate.isEmpty()) {
            try {
                upsert recordsToUpdate.values();
            } catch (Exception e) {
                System.debug('Error during upsert: ' + e.getMessage());
            }
        }
        
    }
    
    public static List<Id> getActiveUsers() {
        List<Id> Users = new List<Id>();
        String excludedProfilesString = Label.SharingModel_ExcludedProfile;
        List<String> excludedProfiles = new List<String>();
        if (!String.isBlank(excludedProfilesString)) {
            excludedProfiles = excludedProfilesString.split(',');
        }
        List<String> list_Licencies = new List<String>{'Salesforce','Salesforce Platform'};
            //List<String> lstProfiles = new List<String>{'System Administrator','Docketing Management','Client'};
            
            List<User> ObjUsers= [SELECT Id, Name,IsActive, Email,Profile.Name,Profile.UserLicense.Name 
                                  FROM User WHERE IsActive = true  
                                  AND profile.Name NOT IN : excludedProfiles];
        if(ObjUsers.size()>0){
            for(User data : ObjUsers){
                Users.add(data.Id);   
            }   
        }
        
        return Users;
    }
    
    public static void ReDocektNumber(String ObjectName) {
        List<Id> PatentIds = new List<Id>();
        String query = 'SELECT Id FROM ' + ObjectName + 
            ' Where SymphonyLF__Docket_Number__c=null Order By CreatedDate Limit 200';
        List<sObject> ObjLst = Database.query(query);
        for (sObject data : ObjLst) {
            PatentIds.add(data.Id);
        }
       
         if(PatentIds.size()>0)
             DocektNumber(PatentIds,ObjectName);
     }
    
    public static void DocektNumber(List<Id> recordIds,string ObjectName) {
        
        system.debug('e.DocektNumber() ' + recordIds ); 
        system.debug('e.DocektNumber() ' + ObjectName ); 
        
        try {
            for(Integer i = 0; i < recordIds.size(); i++) { 
                Map<String, Object> params = new Map<String, Object>();
                params.put('recordId', recordIds[i]);
                params.put('ObjectName',ObjectName);
                params.put('ProcessName','GenerateDocketNo');
                Flow.Interview.mvlawfirmParentAutoLaunchFlow yourFlow = new Flow.Interview.mvlawfirmParentAutoLaunchFlow(params);
                yourFlow.start();
            }
        } catch (Exception e) {
            system.debug('e.getMessage() ' + e.getMessage()); 
        }

        
    }
    
    public static void PatentDocektNumber(List<Id> recordIds,string ObjectName) {
        cmpAPTrgUtilCtrl.DocektNumber(recordIds,ObjectName);
    }
    
    @future
    public static void PatentDocektNumberfuture(List<Id> recordIds, string ObjectName) {
        cmpAPTrgUtilCtrl.DocektNumber(recordIds,ObjectName);
    }
    
}