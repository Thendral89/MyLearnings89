/*
*********************************************************
Apex Class Name    : cmpAPiMngLibraryAccessCtrl
Created Date       : Feb 12, 2023
@description       : API24, get selected Library access
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   02-2024   Amar P                      			Initial Version
*********************************************************
*/


public class cmpAPiMngLibraryAccessCtrl {


    
  @AuraEnabled
  public static string iMngDocAccess(string access_token,string users,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='Access Denied';
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
           
            string apibody='';
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/users?query=' + users ;
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
                returnresponse='{  "data": [    {      "id": "123",      "user_id_ex": "user123",      "full_name": "John Doe",      "location": "New York",      "allow_logon": "true",      "email": "johndoe@example.com",      "user_num": 1,      "doc_server": "server01",      "preferred_library": "LibraryA",      "user_nos": 100,      "pwd_changed_ts": "2024-01-01T12:00:00Z",      "password_never_expire": "false",      "failed_logins": 0,      "force_password_change": "false",      "is_external": "false",      "exch_autodiscover": "autodiscover.example.com",      "edit_date": "2024-01-01T12:00:00Z",      "wstype": "user",      "user_id": "user123",      "userid": "user123",      "preferred_database": "DatabaseA",      "login": "john.doe",      "pwd_never_expire": "false",      "database": "DB1"    }  ]}';
            
            cmpAPiMngLibraryWrapper FolderDocWrraper = (cmpAPiMngLibraryWrapper) JSON.deserialize(returnresponse,cmpAPiMngLibraryWrapper.Class);
            if(FolderDocWrraper.data==null){
                API5data='Access denied';    
            }else if(FolderDocWrraper.data !=null){
                API5data='Access';
            }
            
            system.debug('FolderDocWrraper ' + FolderDocWrraper);
            
            /*
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API24','Pending',data); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success','success',recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
          */  
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API24','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return API5data;
      
    }
    
    
    public class iManagedata {
        public data data;
        public error error;
    }
    public class data {
        public String access;	//full_access
    }
    
    public class error {
		public String code;	//NRC_NO_RECORD
		public String code_message;	//No record found
		public String detailed_error_message;	//Get document access failed
		public String dms_version;	//10.4.7.758
		public String function;	//getEffectiveAccess
	}
    
}