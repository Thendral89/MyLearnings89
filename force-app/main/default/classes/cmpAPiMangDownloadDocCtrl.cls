/*
*********************************************************
Apex Class Name    : cmpAPiMangDownloadDocCtrl
Created Date       : July 12, 2023
@description       : API7, Download the iManage document
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMangDownloadDocCtrl {

        
  @AuraEnabled
  public static string iMngDownloadDocument(string access_token, string documentsname,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        string contentId='';
      
      	Id myId=recordId;
        String sObjName = myId.getSObjectType().getDescribe().getName();
		string query='';
        string foldername='';
        string Field_API_Name='';
        string Legacy_ID='';
      
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
           
            string apibody='';
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/documents/' + documentsname +'/download';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('GET');  
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
            
            if(test.isRunningTest()) 
               returnresponse=documentsname;
            
             List<iManage_Documents__c> ObjFolders  = [SELECT Id,name__c,ContentVersionId__c,extension__c
                                                  FROM iManage_Documents__c 
                                                  WHERE id__c =: documentsname];
            if (ObjFolders.size()>0) { 
                for(iManage_Documents__c record: ObjFolders){
                    iManage_Documents__c Docs = new iManage_Documents__c();
                    Docs.Id=record.Id;
                    Bytedance_IDF_ID=record.Id;
                    
                    blob csvBlob = Blob.valueOf(returnresponse);
                    ContentVersion cv = new ContentVersion();
            		cv.Title = record.name__c;
            		cv.PathOnClient = record.name__c + '.'+ record.extension__c;
            		cv.VersionData =csvBlob;
            		Insert cv;
                    Id conDocument = cv.Id;
                    
                    Docs.ContentVersionId__c=conDocument;
                    update Docs;
                    
                    contentId=conDocument;
                    
                }
            }
            
            
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API7','Pending',data,Bytedance_IDF_ID); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success','success',recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API7','Pending',data,Bytedance_IDF_ID);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return contentId;
    }

}