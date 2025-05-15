/*
*********************************************************
Apex Class Name    : cmpAPiMngFailedBatch
Created Date       : 07 Jan, 2024
@description       : re- Sync failed request....
@author            : Amar P
Modification Log:
Ver   Date      Author                               Modification
1.0   01-2024   Amar P                      		 Initial Version
*********************************************************
*/

global class cmpAPiMngFailedBatch implements Database.AllowsCallouts,Database.Batchable<Sobject>,Schedulable,Database.Stateful {
 	public string query{set;get;}
    public string Approval_Status{set;get;}
    public boolean isSuccess;
    
    //cmpAPiMngFailedBatch docuSign=new cmpAPiMngFailedBatch();
    //Database.executeBatch(docuSign,1);
	//System.schedule('cmpAPiMngFailedBatch Every 0th min', '0 0 * * * ?', new cmpAPiMngFailedBatch());
	//System.schedule('cmpAPiMngFailedBatch-Every 15th', '0 1 0 15 * ? *', new cmpAPiMngFailedBatch());
	
    Public cmpAPiMngFailedBatch() {
      
      Approval_Status='Success';
      query='';
      query += ' Select Id,API_Name__c,ContentVersionId__c,createdFolderId__c,iManage_Documents__c,iManageFoldersId__c,';
      query += ' recordId__c,Status__c,Sync_Status__c';
      query += ' From API_Details__c ';
      query += ' Where Status__c!=:Approval_Status Order by CreatedDate DESC Limit 10';
      system.debug('query ' + query);
   
      
  }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext bc, List<API_Details__c> scope) {

            for (API_Details__c data : scope)  {
                if(data.API_Name__c=='API8'){
                    cmpAPiManagDocumentCtrl.UploadDocumentAPIDetailsBatch(data.createdFolderId__c,data.ContentVersionId__c, data.iManageFoldersId__c);
                }     
            }

    }    

    global void execute(SchedulableContext ctx)  {
        Database.executeBatch(this);
    }
    
    global void finish(Database.BatchableContext bc){   
    
    }    

}