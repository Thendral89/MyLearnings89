/*
*********************************************************
Apex Class Name    : cmpAPiMngSearchFolderUpdatedCtrl
Created Date       : Jan 12, 2024
@description       : API19, search folders in the workspace and get updated folder property
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngSearchFolderUpdatedCtrl {

    
  @AuraEnabled
  public static string iMngUpdatedFolder(string access_token,string createdFoldername,string FolderSettingId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        string iManageFoldersId='';
      	string workspaceId='';
        List<iManage_Setting__c> ObjDocuments = new List<iManage_Setting__c>();
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            workspaceId=cmpAPAPIHeaderCtrl.getworkspaceId(objCSworkday[0].workspaces__c);
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFoldername ;
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
                 returnresponse=returnresponse.replace('"class"','"classw"');
                 access_token='';
            }
            
            if(test.isRunningTest()) {
              	returnresponse='{  "data": {    "default_security": "inherit",    "inherited_default_security": "global",    "name": "700-Case Administration",    "owner": "SYM_SVC",    "description": "700-Case Administration",    "has_subfolders": "true",    "has_documents": "false",    "is_content_saved_search": "false",    "is_container_saved_search": "true",    "database": "MB_SB",    "is_external": "false",    "is_hidden": "false",    "is_external_as_normal": "false",    "edit_date": "2024-01-27T21:13:49Z",    "effective_security": "full_access",    "owner_description": "Symphony Service Account",    "view_type": "document",    "id": "MB_SB!97",    "parent_id": "MB_SB!90",    "workspace_id": "MB_SB!90",    "workspace_name": "US01 (206001-6021)",    "wstype": "folder",    "folder_type": "regular",    "profile": {      "classw": "CASEADMIN",      "class_description": "Case Administration",      "custom1": "206001",      "custom2": "6021",      "custom3": "",      "custom4": "US",      "custom5": "",      "custom6": "",      "custom7": "2",      "custom8": "",      "custom9": "",      "custom10": "US01",      "custom1_description": "Bill Bradley",      "custom2_description": "IP Test One",      "custom3_description": "IP Test One",      "custom4_description": "USPTO",      "custom5_description": "",      "custom6_description": "",      "custom7_description": "2",      "custom8_description": "",      "custom9_description": "",      "custom10_description": "USPTO"    },    "owner_info": {      "allow_logon": "true",      "is_external": "false"    }  }}';
            	returnresponse=returnresponse.replace('"class"','"classw"');
            }
            
           cmpAPiMngSearchFolderUpdatedWrraper objResponse = (cmpAPiMngSearchFolderUpdatedWrraper) JSON.deserialize(returnresponse,cmpAPiMngSearchFolderUpdatedWrraper.Class);
            if(objResponse.data.profile!=null){
            	iManage_Setting__c imngDocuments = new iManage_Setting__c();
                imngDocuments.Id=FolderSettingId;
           		imngDocuments.Class__c=objResponse.data.profile.classw;	//MB_SB
				imngDocuments.Jurisdiction__c=objResponse.data.profile.custom4;	//public	
            	ObjDocuments.add(imngDocuments);
            }           
            
            if(ObjDocuments.size()>0)
                update ObjDocuments;
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API19','Pending',data); 
            
            if(access_token !=''){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API19','Pending',data);
        }
       
      
      return access_token;
      
    }
}