/*
*********************************************************
Apex Class Name    : cmpAPiMngDocumentAccessCtrl
Created Date       : July 12, 2023
@description       : API10, get selected document access
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/


public class cmpAPiMngDocumentAccessCtrl {


    
  @AuraEnabled
  public static string iMngDocAccess(string access_token, string documentsname, string users,string recordId) {
      
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
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/documents/' + documentsname + '/users/' + users + '/security' ;
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
                returnresponse='{    "data": {        "access": "full_access"    },    "error": {        "code": "NRC_NO_RECORD",        "code_message": "No record found",        "detailed_error_message": "Get document access failed",        "dms_version": "10.4.7.758",        "function": "getEffectiveAccess"    }}';
            
            iManagedata FolderDocWrraper = (iManagedata) JSON.deserialize(returnresponse,iManagedata.Class);
            if(FolderDocWrraper.error==null){
                if(FolderDocWrraper.data.access!=null){
                	API5data=FolderDocWrraper.data.access;    
                }
            }else if(FolderDocWrraper.error !=null){
                API5data=FolderDocWrraper.error.detailed_error_message;
            }
            system.debug('FolderDocWrraper ' + FolderDocWrraper);
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API10','Pending',data,documentsname); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success','success',recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API10','Pending',data,documentsname);
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