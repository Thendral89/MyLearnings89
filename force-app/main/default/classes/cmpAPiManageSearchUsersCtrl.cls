/*
*********************************************************
Apex Class Name    : cmpAPiManageSearchUsersCtrl
Created Date       : July 12, 2023
@description       : API5, search users
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/


public class cmpAPiManageSearchUsersCtrl {

    
    
  @AuraEnabled
  public static string iMngSearchUsers(string access_token, string documentsname,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='Access Denied';
      
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
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/users?query=' + documentsname ;
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('GET');  
            req.setHeader('Content-Type', cmpAPiMangUploadDocCtrl.GetContentType(objCSworkday[0].boundarykey__c));
            req.setHeader('X-Auth-Token', access_token);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                 HTTPResponse httpResponse = http.send(req);
                 returnresponse=httpResponse.getBody(); 
                 system.debug('returnresponse' + returnresponse);
                 access_token='success';
            }
            
            if(test.isRunningTest()) 
                returnresponse='{  "data": [    {      "id": "SYM_SVC",      "user_id_ex": "sym_svc",      "full_name": "Symphony Service Account",      "location": "Waukesha",      "allow_logon": "true",      "email": "SYM_SVC@MICHEALBEST.COM",      "user_num": "12",      "doc_server": "DEFSERVER07",      "preferred_library": "MB_SB",      "user_nos": "2",      "pwd_changed_ts": "2024-01-13T22:34:00Z",      "password_never_expire": "false",      "failed_logins": "0",      "force_password_change": "true",      "is_external": "false",      "exch_autodiscover": ":ErrorNonExistentMailbox=8;01/13/2024 22:34:00",      "edit_date": "2023-11-10T20:41:31Z",      "wstype": "user",      "user_id": "SYM_SVC",      "userid": "SYM_SVC",      "preferred_database": "MB_SB",      "login": "SYM_SVC",      "pwd_never_expire": "false",      "database": "mb_sb"    }]}';
            
            cmpAPiManageSearchUsersWrraper FolderDocWrraper = (cmpAPiManageSearchUsersWrraper) JSON.deserialize(returnresponse,cmpAPiManageSearchUsersWrraper.Class);
            if(FolderDocWrraper.data.size()>0) {
            	for(cmpAPiManageSearchUsersWrraper.data objResponse : FolderDocWrraper.data ) {
                	string userid=objResponse.userid;
                    string email=objResponse.email;
                    
                	if(userid.contains(documentsname) || email.contains(documentsname)) {
                    	API5data='Access';
                	}
            	}
            } else {
                API5data='Access Denied';
            }
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API5','Pending',data); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API5','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return API5data;
      
    }
}