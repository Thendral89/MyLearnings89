/*
*********************************************************
Apex Class Name    : cmpAPiMngClientCreateFolderBatch
Created Date       : July 12, 2023
@description       : API3, search folders from in the workspace
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

global class cmpAPiMngClientCreateFolderBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Schedulable,Database.Stateful {
    
   //List<string> m_recordId = new List<string>();
   //m_recordId.add('MB_SB!90');
   //cmpAPiMngClientCreateFolderBatch AwardDeclined = NEW cmpAPiMngClientCreateFolderBatch(m_recordId);
   //database.executeBatch(AwardDeclined, 1); 
   
   public string m_recordId='';
   public string query='';
   public string m_access_token='';
   public string m_FolderId='';
   public string m_sObjName='';
   public string m_workspaceId='';
   
    Public cmpAPiMngClientCreateFolderBatch(string access_token, string recordId,string FolderId, string sObjName,string workspaceId) {
        m_access_token=access_token;
        m_recordId=recordId;
        m_FolderId=FolderId;
        m_sObjName=sObjName;
        m_workspaceId=workspaceId;
        system.debug('m_sObjName ' + m_sObjName);
        
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
               if(data.FolderName__c!=null && data.FolderName__c!=''){
                   string Folders=cmpAPiMngClientSearchSubFolderBatchCtrl.iMngCreateFolder(m_access_token,m_recordId,data.FolderName__c,m_workspaceId,m_FolderId);
                   if(Folders=='' || Folders==null)
                       cmpAPiMngClientCreateSubFolderBatchCtrl.iMngCreateFolder(m_access_token,data.FolderName__c,m_recordId,m_FolderId,m_workspaceId);
               }
                   
            }
       }
      
   }

    global void execute(SchedulableContext ctx)  {
        Database.executeBatch(this);
    }
    
    global void finish(Database.BatchableContext bc) {
         
        
    }
    
    
}