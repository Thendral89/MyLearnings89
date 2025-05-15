/*
*********************************************************
Apex Class Name    : cmpAPiManageEventBatch
Created Date       : 07 Jan, 2024
@description       : Createi Manage Folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   01-2024   Amar P                      			Initial Version
*********************************************************
*/

global class cmpAPiManageEventBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Schedulable,Database.Stateful {
    public string query{set;get;}
    public Set<String> m_recordIds = new Set<String>();
    
    //cmpAPiManageEventBatch docuSign=new cmpAPiManageEventBatch();
    //Database.executeBatch(docuSign,1);UserTriggerHandler
    
    
    Public cmpAPiManageEventBatch() {
        ///recordId='a19Wr000001dKRJIA2';
        query='SELECT Id,recordId__c,IsProcessed__c,ObjectName__c FROM iManage_Events__c Where IsProcessed__c=false Order by CreatedDate DESC  LIMIT 100';
        system.debug('query ' + query);
        
        
    }
    
    Public cmpAPiManageEventBatch(Set<String> recordIds) {
        m_recordIds=recordIds;
        query='SELECT Id,recordId__c,IsProcessed__c,ObjectName__c FROM iManage_Events__c Where recordId__c IN:m_recordIds AND IsProcessed__c=false Order by CreatedDate DESC  LIMIT 100';
        system.debug('query ' + query);
        
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<iManage_Events__c>  records) {
        List<iManage_Events__c> ObjEventsQueue = new List<iManage_Events__c>();
        List<iManage_FolderConfig__c> ObjiMngFolders = new List<iManage_FolderConfig__c>();
        
        //try {
        if(records.size()>0) {
            string m_access_token=cmpAPAPIHeaderCtrl.getToken();
            
            for(iManage_Events__c Queue :records) {
                iManage_Events__c Events = new iManage_Events__c();
                string m_sObjName=Queue.ObjectName__c;
                string Status='';
                string recordId=Queue.recordId__c;
                m_recordIds.add(Queue.recordId__c);
                string workspaceId='';
                string FolderId='';
                string name='';
                List<iManage_Configuration__c> Configuration=cmpAPiManagDocumentCtrl.getWorkspaceId(recordId);
                //system.debug('cmpAPiManageEventBatch Configuration ' + Configuration);
               
                if(!Configuration.IsEmpty()){
                    workspaceId=Configuration[0].WorkspaceId__c;
                    
                    //system.debug('cmpAPiManageEventBatch workspaceId ' + workspaceId);
                    
                    if(workspaceId!='' && workspaceId!=null){
                        List<iManage_Configuration__c> FolderIds = cmpAPiManagDocumentCtrl.getClientObjectWorkspaceId(recordId,workspaceId,m_access_token);
                        //system.debug('cmpAPiManageEventBatch FolderIds ' + FolderIds);
                        
                        if(FolderIds.size()>0){
                            FolderId=FolderIds[0].FolderId__c;
                            //system.debug('cmpAPiManageEventBatch FolderId ' + FolderId);
                            
                            List<cmpAPiManagDocumentCtrl.Workspace> ws=cmpAPiManagDocumentCtrl.getIPMatterNumberWorkSpaceId(recordId);
                            if(ws.size()>0) 
                                name=ws[0].name;       
                            
                            if(name!='' && name!=null){
                                List<iManage_Folders__c> SubFolders= cmpAPiManagDocumentCtrl.CreateBatchClientWorkspaceFolders(recordId,FolderId,m_access_token,workspaceId);
                                if(!SubFolders.IsEmpty()){
                                    
                                    List<iManage_Folders__c> ObjiMngSubFolders=cmpAPiMngClientSearchSubFolderCtrl.iMngSearchSubFolder(m_access_token,recordId, name, workspaceId,SubFolders[0].Id__c);         
                                    if(!ObjiMngSubFolders.IsEmpty())
                                        upsert ObjiMngSubFolders;
                                    
                                    iManage_FolderConfig__c imngFolder = new iManage_FolderConfig__c();
                                    imngFolder.recordId__c=recordId;
                                    imngFolder.FolderId__c=SubFolders[0].Id__c;
                                    imngFolder.workspaceId__c=workspaceId;
                                    ObjiMngFolders.add(imngFolder);
                                    
                                    Events.Id=Queue.Id;
                                    Events.IsProcessed__c=true;
                                    ObjEventsQueue.add(Events);
                                }
                            } else {
                                Events.Id=Queue.Id;
                                Events.IsProcessed__c=true;
                                ObjEventsQueue.add(Events);
                            }
                            
                        }
                        
                        
                    }
                    
                }
            }
        }
        
        
        if(!ObjEventsQueue.IsEmpty())
            update ObjEventsQueue;
        
        if(!ObjiMngFolders.IsEmpty())
            insert ObjiMngFolders;
        
        
        //} catch (Exception e) {
        
        //}
        
        
    }
    
    global void execute(SchedulableContext ctx)  {
        cmpAPiManageEventBatch b = new cmpAPiManageEventBatch(); 
        Database.executeBatch(b,1);
        
    }
    
    
    global void finish(Database.BatchableContext bc) {
        cmpAPiManageEventFolderBatch AwardDeclined = new cmpAPiManageEventFolderBatch(m_recordIds);
        database.executeBatch(AwardDeclined, 1); 
    }  
    
}