/*
*********************************************************
Apex Class Name    : cmpAPiManageEventFolderBatch
Created Date       : July 12, 2023
@description       : Create iManage Sub Folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

global class cmpAPiManageEventFolderBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Schedulable,Database.Stateful {
   public string query='';
   Set<String> i_recordIds = new Set<String>();
   public string m_recordId='';
    
    Public cmpAPiManageEventFolderBatch() {
     	query='Select Id,FolderId__c,IsProcessed__c,recordId__c,workspaceId__c';
        query+=' FROM iManage_FolderConfig__c ';
        query+=' Where IsProcessed__c=false limit 200';
        
  	}
    
    Public cmpAPiManageEventFolderBatch(Set<String> recordIds) {
        i_recordIds=recordIds;
     	query='Select Id,FolderId__c,IsProcessed__c,recordId__c,workspaceId__c';
        query+=' FROM iManage_FolderConfig__c ';
        query+=' Where IsProcessed__c=false and recordId__c IN :i_recordIds';
        
  	}
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(query);
    }

   
    public void execute(Database.BatchableContext context, List<iManage_FolderConfig__c>  records) {
        List<iManage_FolderConfig__c> ObjiMngFolders = new List<iManage_FolderConfig__c>();
        List<iManage_Folders__c> MngFolders = new List<iManage_Folders__c>();
        List<iManage_Folders__c> MngUpdatedFolders = new List<iManage_Folders__c>();
        
        List<iManage_Folders__c> MngSubFolders = new List<iManage_Folders__c>();
        List<iManage_Folders__c> MngSubUpdatedFolders = new List<iManage_Folders__c>();
        
        
        if(records.size()>0) {
            string sObjectName='';
            string m_access_token=cmpAPAPIHeaderCtrl.getToken();
            
               
            for(iManage_FolderConfig__c idata :records) { 
                  List<String> SubFolderIds = new List<String>();
                
                Id recordId=idata.recordId__c;
                string m_FolderId=idata.FolderId__c;
                string m_workspaceId=idata.workspaceId__c;
                
                iManage_FolderConfig__c imngFolder = new iManage_FolderConfig__c();
                imngFolder.Id=idata.Id;
                imngFolder.IsProcessed__c=true;
                ObjiMngFolders.add(imngFolder);
                sObjectName = recordId.getSObjectType().getDescribe().getName();
                
                  List<iManage_Folders__c> ObjSubFolder  = [SELECT Id,name__c
                                                               FROM iManage_Folders__c 
                                                               WHERE recordId__c =: recordId limit 1];
                
                for(iManage_Folders__c fdata :ObjSubFolder) { 
                    SubFolderIds.add(fdata.name__c);
                } 
                
                List<iManageTemplates__mdt> ObjiFolders = [SELECT Id,FolderName__c,Sub_Folder__c
                                                           FROM iManageTemplates__mdt 
                                                           WHERE ObjectName__c=:sObjectName AND Sub_Folder__c=null Order by FolderName__c];
                
                for(iManageTemplates__mdt data :ObjiFolders) { 
                    if(data.FolderName__c!=null && data.FolderName__c!=''){
                        if(!SubFolderIds.contains(data.FolderName__c)){
                            string FolderName=data.FolderName__c;
                            List<iManage_Folders__c> ObjCreatedFolders =cmpAPiMngClientCreateSubFolderBatchCtrl.CreateBatchFolder(m_access_token,FolderName,recordId,m_FolderId,m_workspaceId);
                            if(!ObjCreatedFolders.IsEmpty()){
                                MngFolders.addAll(ObjCreatedFolders);
                            }
                        }
                    }   
                }
                
                if(!MngUpdatedFolders.IsEmpty())
                    insert MngUpdatedFolders; 
                
                if(!MngFolders.IsEmpty()){
                    insert MngFolders; 
                }
                
               
               /*********** CREATE SUB FOLDER******************/ 
               /*********** CREATE SUB FOLDER******************/
                
                List<iManageTemplates__mdt> ObjSubFolders = [SELECT Id,FolderName__c,Sub_Folder__c
                                                           FROM iManageTemplates__mdt 
                                                           WHERE ObjectName__c=:sObjectName AND Sub_Folder__c!=null Order by FolderName__c];
                
                for(iManageTemplates__mdt data :ObjSubFolders) { 
                    if(data.Sub_Folder__c!=null && data.Sub_Folder__c!=''){
                        string FolderName=data.Sub_Folder__c;
                        string p_FolderId=m_FolderId;
                        
                        List<iManage_Folders__c> ObjmFolders = [SELECT Id,id__c 
                                                                From iManage_Folders__c
                                                                Where recordId__c=:recordId and name__c=:data.FolderName__c];
                        if(!ObjmFolders.IsEmpty()){
                            p_FolderId=ObjmFolders[0].id__c;
                            if(!SubFolderIds.contains(data.Sub_Folder__c)){
                                List<iManage_Folders__c> ObjCreatedFolders =cmpAPiMngClientCreateSubFolderBatchCtrl.CreateBatchFolder(m_access_token,FolderName,recordId,p_FolderId,m_workspaceId);
                                if(!ObjCreatedFolders.IsEmpty()){
                                    MngSubFolders.addAll(ObjCreatedFolders);
                                }
                            }
                        }
                    }   
                }
                
              /*********** CREATE SUB FOLDER******************/ 
              /*********** CREATE SUB FOLDER******************/  
                
                
            }
            
        }
        
        
        if(!MngSubUpdatedFolders.IsEmpty())
            insert MngSubUpdatedFolders; 
        
        if(!MngSubFolders.IsEmpty())
            insert MngSubFolders; 
        
        if(!ObjiMngFolders.IsEmpty())
            update ObjiMngFolders;
        
        
      
   }

    global void execute(SchedulableContext ctx)  {
         cmpAPiManageEventFolderBatch AwardDeclined = new cmpAPiManageEventFolderBatch();
   		 database.executeBatch(AwardDeclined, 1); 
    }
    
    global void finish(Database.BatchableContext bc) {
         
        
    }
    
    
}