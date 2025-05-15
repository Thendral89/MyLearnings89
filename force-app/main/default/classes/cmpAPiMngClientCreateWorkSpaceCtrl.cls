/*
*********************************************************
Apex Class Name    : cmpAPiMngClientCreateWorkSpaceCtrl
Created Date       : July 12, 2023
@description       : API3, Create new folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngClientCreateWorkSpaceCtrl {

    
    
    public static string getapi3data(string name){
        string Qstr='';
        Qstr+='{';
  		Qstr+='"name": "' + name +'",';
  		Qstr+='"description" : "' + name +'",';
  		Qstr+='"default_security": "public"';
  		Qstr+='}';
        return Qstr;  
    }
    
  @AuraEnabled
  public static string iMngCreateWorkSpaceCtrl(string access_token,string recordId, string WSName,string ObjectName,string ClientId) {
      
      
      	string apiIds ='';
        string data= '';
        string returnresponse='';
      	string returndata='';
        string workspaceId='';
      	string iManageFoldersId='';
        List<string> FoldersIds = new List<string>();
        List<iManage_Workspace__c> ObjDocuments = new List<iManage_Workspace__c>();
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            data = cmpAPiMngCreateWorkSpaceCtrl.getapi3data(WSName);
            
            system.debug('data' + data);
            string apibody=data;
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/workspaces';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('POST');  
            req.setBody(apibody);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-Auth-Token', access_token);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                 HTTPResponse httpResponse = http.send(req);
                 System.debug('httpResponse.getBody()' + httpResponse.getBody());
                 returnresponse=httpResponse.getBody();
                 returnresponse=returnresponse.replace('"class"','"classw"');
                 returndata='success';
                
            }
            
            if(test.isRunningTest()) {
                returnresponse='{"data":{"author":"SYMPHONYSANDBOX","author_description":"Symphony Sandbox","classw":"WEBDOC","class_description":"infoLink Web Page","content_type":"P","create_date":"2024-12-20T10:39:15Z","create_profile_date":"2024-12-20T10:39:15Z","database":"ACTIVE","declared":false,"default_security":"public","description":"10004-065US1","document_number":3598428,"effective_security":"full_access","extension":"xml","has_subfolders":false,"id":"ACTIVE!1441354","in_use":false,"indexable":false,"inherits_security":"N","is_container_saved_search":false,"is_content_saved_search":false,"is_declared":false,"is_external":false,"is_external_as_normal":false,"is_hidden":false,"is_hipaa":false,"is_in_use":false,"iwl":"iwl:dms=mcciplaw-mobility.imanage.work&&lib=ACTIVE&&num=3598428&&ver=1","last_user":"SYMPHONYSANDBOX","last_user_description":"Symphony Sandbox","location":"3598428.1","name":"10004-065US1","operator":"SYMPHONYSANDBOX","operator_description":"Symphony Sandbox","owner":"SYMPHONYSANDBOX","owner_description":"Symphony Sandbox","retain_days":365,"size":1,"subtype":"work","type":"XML","type_description":"XML","version":1,"workspace_id":"ACTIVE!1441354","wstype":"workspace"}}';
                returndata='success';
            }
            
            if(returndata=='success'){
            	cmpAPiMngCreateWSWrraper objRes = (cmpAPiMngCreateWSWrraper) JSON.deserialize(returnresponse,cmpAPiMngCreateWSWrraper.Class);
                
                iManage_Workspace__c workspace = new iManage_Workspace__c();
                workspace.name__c=WSName;
                workspace.id__c=objRes.data.id;
                List<iManage_Workspace__c> ObjWorkspace  = [SELECT Id FROM iManage_Workspace__c WHERE recordId__c =: recordId AND name__c=:WSName];
                if (ObjWorkspace.Size() >0 ) {
                    workspace.Id=ObjWorkspace[0].Id;
                    update workspace;
                } else {
                    insert workspace;
                }
                
                iManage_Configuration__c cworkspace = new iManage_Configuration__c();
                cworkspace.ObjectName__c=ObjectName;
                cworkspace.WorkspaceId__c=objRes.data.id;
                cworkspace.recordId__c=ClientId;
                cworkspace.name__c=WSName;
                cworkspace.FolderId__c=objRes.data.id;
                
                List<iManage_Configuration__c> ObjsFolders  = [SELECT Id,recordId__c,WorkspaceId__c
                                                               FROM iManage_Configuration__c 
                                                               WHERE ObjectName__c =: ObjectName ];
                if (ObjsFolders.Size() >0 ) {
                    cworkspace.Id=ObjsFolders[0].Id;
                    update cworkspace;
                    iManageFoldersId=ObjsFolders[0].Id;
                } else {
                    insert cworkspace;
                    iManageFoldersId=cworkspace.Id;
                } 
                
                
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('ClientCreateWorkSpaceCtrl','Pending',data);
            //cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return iManageFoldersId;
      
      
    }
}