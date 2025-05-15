public without sharing class cmpAPiManageEventCtrl {
    
    public static void PatentiManageEvent(List<SObject> tnew) {
        List<iManage_Events__c> ObjEvents = new List<iManage_Events__c>();
        Set<String> recordIds = new Set<String>();
        Set<String> iMngRecordIds = new Set<String>();
        
        for (Integer i = 0; i < tnew.size(); i++) {
            SObject newRecord = tnew[i];
            recordIds.add(newRecord.Id);
        }
        
        List<iManage_Events__c> ObjiEvents = [SELECT Id,recordId__c,IsProcessed__c,ObjectName__c 
                                             FROM iManage_Events__c 
                                             Where recordId__c IN : recordIds AND IsProcessed__c=false];
         if(ObjiEvents.size()>0) {
             for(iManage_Events__c data :ObjiEvents) {
               iMngRecordIds.add(data.recordId__c);
             }
         }
        
        for (Integer i = 0; i < tnew.size(); i++) {
            SObject newRecord = tnew[i];
            Id recordId = newRecord.Id;
            String objectName = recordId.getSObjectType().getDescribe().getName();
            iManage_Events__c eventRecord = new iManage_Events__c();
            eventRecord.recordId__c = recordId;
            eventRecord.ObjectName__c = objectName;
            if(!iMngRecordIds.contains(recordId))
                ObjEvents.add(eventRecord);
            
        }
        
        if (!ObjEvents.isEmpty()) {
            insert ObjEvents;
        }
        
        if (!iMngRecordIds.isEmpty()) {
            //cmpAPiManageEventBatch b = new cmpAPiManageEventBatch(iMngRecordIds); 
            //Database.executeBatch(b,1);
        }
    }
    
    
    public static void trgPatentiManageEvent(List<SObject> tnew, List<SObject> told) {
        List<iManage_Events__c> ObjEvents = new List<iManage_Events__c>();
        
        for (Integer i = 0; i < tnew.size(); i++) {
            SObject newRecord = tnew[i];
            SObject oldRecord = told[i];
            
            Id recordId = newRecord.Id;
            String objectName = recordId.getSObjectType().getDescribe().getName();
            
            Boolean newDocket = (Boolean)newRecord.get('IsDocketNumberGenerated__c');
            Boolean oldDocket = (Boolean)oldRecord.get('IsDocketNumberGenerated__c');
            
            if (newDocket==null && newDocket != oldDocket) {
                iManage_Events__c eventRecord = new iManage_Events__c();
                eventRecord.recordId__c = recordId;
                eventRecord.ObjectName__c = objectName;
                ObjEvents.add(eventRecord);
            }
        }
        
        if (!ObjEvents.isEmpty()) {
            insert ObjEvents;
        }
    }
    
    
    
    @AuraEnabled
    public static string CreateWorkSpace(string m_access_token,string m_recordId,string m_workspaces,string m_workspaceId,string m_sObjName) {
        string Status ='';
        List<iManageTemplates__mdt> Folders = [SELECT Id,FolderName__c 
                                               FROM iManageTemplates__mdt 
                                               WHERE ObjectName__c =:m_sObjName];
        if(Folders.size()>0) {
            for(iManageTemplates__mdt data :Folders) { 
                if(data.FolderName__c!=null && data.FolderName__c!='')
                    Status=cmpAPiManageCreateFolderCtrl.iMngCreateFolder(m_access_token,m_recordId,data.FolderName__c,m_workspaces,m_workspaceId);
            }
        }
        
        return Status;
    }
    
    
}