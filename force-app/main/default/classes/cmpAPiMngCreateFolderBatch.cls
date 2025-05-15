/*
*********************************************************
Apex Class Name    : cmpAPiMngCreateFolderBatch
Created Date       : July 12, 2023
@description       : API3, search folders from in the workspace
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

global class cmpAPiMngCreateFolderBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Schedulable,Database.Stateful {
    
   //List<string> m_recordId = new List<string>();
   //m_recordId.add('MB_SB!90');
   //cmpAPiMngCreateFolderBatch AwardDeclined = NEW cmpAPiMngCreateFolderBatch(m_recordId);
   //database.executeBatch(AwardDeclined, 1); 
   
   public string m_recordId='';
   public string query='';
   public string m_access_token='';
   public string m_workspaces='';
   public string m_workspaceId='';
   public string m_sObjName='';
    
    Public cmpAPiMngCreateFolderBatch(string access_token, string recordId,string workspaces,string workspaceId, string sObjName) {
        m_access_token=access_token;
        m_recordId=recordId;
        m_workspaces=workspaces;
        m_workspaceId=workspaceId;
        m_sObjName=sObjName;
        
     	query='SELECT Id,FolderName__c';
        query+=' FROM iManageTemplates__mdt ';
        query+=' Where ObjectName__c=: m_sObjName';
        
  	}
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(query);
    }

   
    public void execute(Database.BatchableContext context, List<iManageTemplates__mdt>  records) {
        if(records.size()>0) {
           for(iManageTemplates__mdt data :records) { 
               if(data.FolderName__c!=null && data.FolderName__c!='')
                  cmpAPiManageCreateFolderCtrl.iMngCreateFolder(m_access_token,m_recordId,data.FolderName__c,m_workspaces,m_workspaceId);
            }
       }
      
   }

    global void execute(SchedulableContext ctx)  {
        Database.executeBatch(this);
    }
    
    global void finish(Database.BatchableContext bc) {
         
        
    }
    
    
}