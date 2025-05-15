/*
*********************************************************
Apex Class Name    : cmpAPiMngSearchFolderBatch
Created Date       : July 12, 2023
@description       : API3, search folders from in the workspace
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

global class cmpAPiMngSearchFolderBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Schedulable,Database.Stateful {
    
    //List<string> m_recordId = new List<string>();
    //m_recordId.add('MB_SB!90');
   //cmpAPiMngSearchFolderBatch AwardDeclined = NEW cmpAPiMngSearchFolderBatch(m_recordId);
   //database.executeBatch(AwardDeclined, 1); 
   public List<string> m_recordId = new List<string>();
   public string query='';
   public string access_token='';
    
    Public cmpAPiMngSearchFolderBatch(List<string> recordId) {
        m_recordId=recordId;
     	query='SELECT Id,id__c,custom1__c,custom2__c,custom3__c,custom4__c,custom5__c,custom6__c,custom7__c,custom8__c,custom9__c,custom10__c ';
        query+=' FROM iManage_Workspace__c Where id__c IN:m_recordId AND custom1__c!=null';
        system.debug('query ' + query);
      
        access_token=cmpAPAPIHeaderCtrl.getToken();
  	}
    
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(query);
    }

   
    public void execute(Database.BatchableContext context, List<iManage_Workspace__c>  records) {
        if(records.size()>0) {
           for(iManage_Workspace__c data :records) { 
               if(data.custom1__c!=null && data.custom1__c!='')
                   cmpAPiMngSearchFolderWorkspaceCtrl.iMngSearchworkspaceFolder(access_token,data.id__c);
            }
       }
      
   }

    global void execute(SchedulableContext ctx)  {
        Database.executeBatch(this);
    }
    
    global void finish(Database.BatchableContext bc) {
         List<string> m_recordId = new List<string>();
         List<iManage_Setting__c> ObjWorkspaces = cmpAPAPIHeaderCtrl.getiManageFoldersToBeSynced();
         if (ObjWorkspaces.size()>0) { 
             for(iManage_Setting__c data :ObjWorkspaces) { 
                 m_recordId.add(data.Folder_Id__c);
             }
         }
        
        if(m_recordId.size()>0){
            if(!test.isRunningTest()) {
   				cmpAPiMngSearchFolderUpdatedBatch AwardDeclined = NEW cmpAPiMngSearchFolderUpdatedBatch(m_recordId);
   				database.executeBatch(AwardDeclined, 1); 
            }
        }
        
    }
    
    
}