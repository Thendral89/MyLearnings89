/*
*********************************************************
Apex Class Name    : cmpAPiMngSearchFolderUpdatedBatch
Created Date       : July 12, 2023
@description       : API3, search folders from folder if and uppdate
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

global class cmpAPiMngSearchFolderUpdatedBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Schedulable,Database.Stateful {
    
    //List<string> m_recordId = new List<string>();
    //m_recordId.add('MB_SB!90');
   //cmpAPiMngSearchFolderUpdatedBatch AwardDeclined = NEW cmpAPiMngSearchFolderUpdatedBatch(m_recordId);
   //database.executeBatch(AwardDeclined, 1); 
   public List<string> m_recordId = new List<string>();
   public string query='';
   public string access_token='';
    
    Public cmpAPiMngSearchFolderUpdatedBatch(List<string> recordId) {
        m_recordId=recordId;
     	query='SELECT Id,Class__c,Folder_Id__c,Jurisdiction__c,Name__c,Matter__c,Client__c,Workspaces__c,WorkspaceSubcase__c ';
        query+=' FROM iManage_Setting__c Where Folder_Id__c IN:m_recordId';
        system.debug('query ' + query);
      
        access_token=cmpAPAPIHeaderCtrl.getToken();
  	}
    
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<iManage_Setting__c>  records) {
        if(records.size()>0) {
           for(iManage_Setting__c data :records) { 
               if(data.Folder_Id__c!=null && data.Folder_Id__c!='')
                   cmpAPiMngSearchFolderUpdatedCtrl.iMngUpdatedFolder(access_token,data.Folder_Id__c,data.Id);
            }
       }
      
   }

    global void execute(SchedulableContext ctx)  {
        Database.executeBatch(this);
    }
    
    global void finish(Database.BatchableContext bc) {
        
        
    }
    
    
}