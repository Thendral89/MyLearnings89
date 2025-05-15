global class cmpAPiMngSearchWorkspaceBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Schedulable,Database.Stateful {
    
   
   //cmpAPiMngSearchWorkspaceBatch AwardDeclined = NEW cmpAPiMngSearchWorkspaceBatch();
   //database.executeBatch(AwardDeclined, 1); 
   public string query='';
   public string access_token='';
    
    Public cmpAPiMngSearchWorkspaceBatch() {
     	query='SELECT Id,client_id__c';
        query+=' FROM iManageAPIs__mdt limit 1';
        system.debug('query ' + query);
      
        access_token=cmpAPAPIHeaderCtrl.getToken();
  	}
    
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<iManageAPIs__mdt>  records) {
        if(records.size()>0) {
           for(iManageAPIs__mdt data :records) { 
              cmpAPiMngGetWorkSpaceCtrl.iMngGetFolder(access_token);
            }
       }
      
   }

    global void execute(SchedulableContext ctx)  {
        Database.executeBatch(this);
    }
    
    global void finish(Database.BatchableContext bc) {
         List<string> m_recordId = new List<string>();
         List<iManage_Workspace__c> ObjWorkspaces = cmpAPAPIHeaderCtrl.getworkspaces();
         if (ObjWorkspaces.size()>0) { 
             for(iManage_Workspace__c data :ObjWorkspaces) { 
                 m_recordId.add(data.id__c);
             }
         }
        
        if(m_recordId.size()>0){
             if(!test.isRunningTest()) {
   				cmpAPiMngSearchFolderBatch AwardDeclined = NEW cmpAPiMngSearchFolderBatch(m_recordId);
   				database.executeBatch(AwardDeclined, 1);  
             }
        }
   
    }
    
    
}