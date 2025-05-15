/*
*********************************************************
Apex Class Name    : cmpAPiMngCreateWorkSpaceCtrl
Created Date       : July 12, 2023
@description       : API3, Create new folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngCreateWorkSpaceCtrl {

    
    
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
  public static string iMngCreateWorkSpaceCtrl(string access_token,string recordId, string WSName) {
      
      
      	string apiIds ='';
        string data= '';
        string returnresponse='';
      	string returndata='';
        string workspaceId='';
        List<string> FoldersIds = new List<string>();
        List<iManage_Workspace__c> ObjDocuments = new List<iManage_Workspace__c>();
      
      List<iManage_Workspace__c> ObjFolders  = [SELECT Id,recordId__c,id__c
                                               FROM iManage_Workspace__c 
                                               WHERE recordId__c =: recordId ];
      if (ObjFolders.Size() >0 ) {
          for(iManage_Workspace__c fata: ObjFolders){
              FoldersIds.add(fata.id__c);
          }
      }
      
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
           		workspace.default_security__c=objRes.data.default_security;
				workspace.name__c=objRes.data.name;
				workspace.owner__c=objRes.data.owner;
				workspace.description__c=objRes.data.description;
				workspace.subtype__c=objRes.data.subtype;
				workspace.document_number__c=objRes.data.document_number;
				workspace.version__c=objRes.data.version;
				workspace.has_subfolders__c=objRes.data.has_subfolders;
				workspace.is_content_saved_search__c=objRes.data.is_content_saved_search;
				workspace.is_container_saved_search__c=objRes.data.is_container_saved_search;
				workspace.database__c=objRes.data.database;
				workspace.is_external__c=objRes.data.is_external;
				workspace.is_hidden__c=objRes.data.is_hidden;
				workspace.is_external_as_normal__c=objRes.data.is_external_as_normal;
				workspace.owner_description__c=objRes.data.owner_description;
				workspace.workspace_id__c=objRes.data.workspace_id;
				workspace.author__c=objRes.data.author;
				workspace.operator__c=objRes.data.operator;
				workspace.type__c=objRes.data.type;
				workspace.class__c=objRes.data.classw;
				workspace.create_date__c=objRes.data.create_date;
				workspace.create_profile_date__c=objRes.data.create_profile_date;
				workspace.retain_days__c=objRes.data.retain_days;
				workspace.size__c=objRes.data.size;
				workspace.is_declared__c=objRes.data.is_declared;
				workspace.declared__c=objRes.data.declared;
				workspace.location__c=objRes.data.location;
				workspace.last_user__c=objRes.data.last_user;
				workspace.is_in_use__c=objRes.data.is_in_use;
				workspace.content_type__c=objRes.data.content_type;
				workspace.is_hipaa__c=objRes.data.is_hipaa;
				workspace.in_use__c=objRes.data.in_use;
				workspace.indexable__c=objRes.data.indexable;
				workspace.iwl__c=objRes.data.iwl;
				workspace.id__c=objRes.data.id;
				workspace.wstype__c=objRes.data.wstype;
                workspace.recordId__c=recordId;
                if(!FoldersIds.contains(objRes.data.id)){
            		insert workspace;
                	access_token=workspace.Id;
                }
            }
            
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('iMngCreateWorkSpace','Pending',data); 
            
            if(returndata=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('iMngCreateWorkSpace','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return access_token;
      
      
    }
}