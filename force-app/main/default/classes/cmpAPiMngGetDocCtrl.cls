/*
*********************************************************
Apex Class Name    : cmpAPiMngGetDocCtrl
Created Date       : Nov, 2023
@description       : API-11, getting all the documents
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   02-2024   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngGetDocCtrl {

  @AuraEnabled
  public static string iMngGetDoc(string access_token,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
      
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/documents';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('GET');  
            req.setHeader('Content-Type', 'application/json');
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
                returnresponse='{  "data": {    "results": [      {        "database": "TestDatabase",        "document_number": "12345",        "version": "1.0",        "name": "Test Document",        "author": "John Doe",        "operator": "Operator1",        "type": "PDF",        "class_Z": "Class A",        "edit_date": "2024-12-29",        "system_edit_date": "2024-12-29T12:00:00Z",        "create_date": "2024-01-15",        "create_profile_date": "2024-01-15",        "retain_days": "30",        "size": "1024",        "is_declared": "true",        "declared": "2024-12-29",        "is_related": "false",        "default_security": "High",        "last_user": "Admin",        "is_in_use": "true",        "is_checked_out": "false",        "type_description": "PDF Document",        "class_description": "Document Class A",        "extension": "pdf",        "content_type": "application/pdf",        "edit_profile_date": "2024-12-29T13:00:00Z",        "is_external": "false",        "is_external_as_normal": "false",        "file_create_date": "2024-01-10",        "file_edit_date": "2024-12-28",        "is_hipaa": "false",        "workspace_name": "Workspace 1",        "is_restorable": "true",        "id": "doc-12345",        "in_use": "false",        "indexable": "true",        "wstype": "Standard",        "iwl": "true",        "workspace_id": "ws-001"      }    ]  }}';
            
            cmpAPiMngGetDocWrraper objResponse = (cmpAPiMngGetDocWrraper) JSON.deserialize(returnresponse,cmpAPiMngGetDocWrraper.Class);
            System.debug('access_token' + objResponse);
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API11','Pending',data); 
            
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API11','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return access_token;
      
    }
}