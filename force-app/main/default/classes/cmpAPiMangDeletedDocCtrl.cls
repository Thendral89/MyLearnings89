/*
*********************************************************
Apex Class Name    : cmpAPiMangDeletedDocCtrl
Created Date       : July 12, 2023
@description       : API6, delete the imanage document
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/


public class cmpAPiMangDeletedDocCtrl {

    
  @AuraEnabled
  public static string iMngDeletedDocument(string access_token, string documentsname,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
      
        Id myId=recordId;
        String sObjName = myId.getSObjectType().getDescribe().getName();
		string query='';
        string foldername='';
        string Field_API_Name='';
        string Legacy_ID='';
        string workspaceId='';
      
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
           
            string apibody='';
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/documents/' + documentsname ;
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('DELETE');  
            req.setHeader('Content-Type', cmpAPiMangUploadDocCtrl.GetContentType(objCSworkday[0].boundarykey__c));
            req.setHeader('X-Auth-Token', access_token);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                 HTTPResponse httpResponse = http.send(req);
                 System.debug('httpResponse.getBody()' + httpResponse.getBody());
                 returnresponse=httpResponse.getBody();
                 access_token='success';
            }
            
            List<iManage_Documents__c> ObjFolders  = [SELECT Id,name__c,ContentVersionId__c,extension__c
                                                  FROM iManage_Documents__c 
                                                  WHERE id__c =: documentsname];
            if (ObjFolders.size()>0) { 
                for(iManage_Documents__c record: ObjFolders){
                    iManage_Documents__c Docs = new iManage_Documents__c();
                    Docs.Id=record.Id;
                    delete Docs;
                    
                    system.debug('record.ContentVersionId__c' + record.ContentVersionId__c);
                    
                    
                    if(record.ContentVersionId__c!=null && record.ContentVersionId__c!='') {
                    List<ContentVersion> ObjContentVersion  = [SELECT Id,ContentDocumentId
                                                  FROM ContentVersion 
                                                  WHERE (ContentDocumentId=:record.ContentVersionId__c) limit 1 ];
                    
                    if (ObjContentVersion.size()>0) { 
                        for(ContentVersion cvrecord: ObjContentVersion){
                            ContentDocument CDocs = new ContentDocument();
                    		CDocs.Id=cvrecord.Id;
                    		delete CDocs;
                        }
                    }
                  }
                    
                }
            }
            
            
            
           /* 
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API6','Pending',data,documentsname); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success','success',recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
          */
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API6','Pending',data,documentsname);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return access_token;
      
    }
}