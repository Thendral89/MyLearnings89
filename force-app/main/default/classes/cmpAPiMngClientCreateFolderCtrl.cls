/*
*********************************************************
Apex Class Name    : cmpAPiMngClientCreateFolderCtrl
Created Date       : July 12, 2023
@description       : API3, Create new folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngClientCreateFolderCtrl {
    
    
    
    public static string getapi3data(string name, string description, string author){
        string Qstr='';
        Qstr+='{';
        Qstr+='"name": "' + name +'",';
        Qstr+='"description" : "' + description +'",';
        Qstr+='"default_security": "public",';
        Qstr+='"profile": {';
        Qstr+='"class": "DOC",';
        Qstr+='"author":"' + author +'",';
        Qstr+='"operator":"' + author +'"';
        Qstr+='},';
        Qstr+='"is_external" : false,';
        Qstr+='"is_external_as_normal" : false,';
        Qstr+='"is_container_saved_search" : false,';
        Qstr+='"is_content_saved_search" : false';
        Qstr+='}';
        return Qstr;  
    }
    
    @AuraEnabled
    public static string iMngCreateFolder(string access_token,string recordId, string foldername, string workspaces) {
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        List<string> FoldersIds = new List<string>();
        
        
        try {
            
            
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            data = cmpAPiManageCreateFolderCtrl.getapi3data(foldername,foldername,objCSworkday[0].username__c);
            
            string apibody=data;
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/workspaces/' + workspaces +'/folders';
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
                access_token='success';
                
            }
            
            if(test.isRunningTest()) 
                returnresponse='{"data":{"database":"ACTIVE","default_security":"public","description":"Letters","edit_date":"2024-12-20T10:39:17Z","effective_security":"full_access","folder_type":"regular","has_documents":false,"has_subfolders":false,"id":"ACTIVE!1441361","is_container_saved_search":false,"is_content_saved_search":false,"is_external":false,"is_external_as_normal":false,"is_hidden":false,"name":"Letters","owner":"SYMPHONYSANDBOX","owner_description":"Symphony Sandbox","parent_id":"ACTIVE!1441354","profile":{"author":"symphonysandbox","class":"DOC","operator":"symphonysandbox"},"view_type":"document","workspace_id":"ACTIVE!1441354","workspace_name":"10004-065US1","wstype":"folder"}}';
            
            cmpAPiManageCreateFolderWrraper objResponse = (cmpAPiManageCreateFolderWrraper) JSON.deserialize(returnresponse,cmpAPiManageCreateFolderWrraper.Class);
           
            iManage_Configuration__c Configuration = new iManage_Configuration__c();
            Configuration.ObjectName__c=foldername;
            Configuration.FolderId__c=objResponse.data.id;
            Configuration.WorkspaceId__c=workspaces;
            Configuration.recordId__c=recordId;
            List<iManage_Configuration__c> ObjFolders  = [SELECT Id,recordId__c,FolderId__c,ObjectName__c,WorkspaceId__c
                                                          FROM iManage_Configuration__c 
                                                          WHERE ObjectName__c =: foldername];
            if (ObjFolders.IsEmpty()) {
                insert Configuration;
            } else {
                Configuration.Id=ObjFolders[0].Id;
                //update Configuration;
            }
            
            List<iManage_Configuration__c> ObjWorkspaces  = [SELECT Id,name__c,recordId__c,FolderId__c,ObjectName__c,WorkspaceId__c
                                                             FROM iManage_Configuration__c 
                                                             WHERE WorkspaceId__c =: workspaces
                                                             AND ObjectName__c='SymphonyLF__Client__c'];
            if(!ObjWorkspaces.IsEmpty()){
                iManage_Workspace__c iworkspace = new iManage_Workspace__c();
                iworkspace.name__c=ObjWorkspaces[0].name__c;
                iworkspace.id__c=ObjWorkspaces[0].WorkspaceId__c;
                List<iManage_Workspace__c> ObjWorkspace  = [SELECT Id FROM iManage_Workspace__c 
                                                            Where name__c=:ObjWorkspaces[0].name__c];
                if (ObjWorkspace.IsEmpty() ) {
                    insert iworkspace;
                } else {
                    iworkspace.Id=ObjWorkspace[0].Id;
                    //update iworkspace;
                }
            }
            
            
            
            
            
            string WorkspaceSubFolder=foldername.toLowerCase()+'-'+workspaces.toLowerCase();
            System.debug('WorkspaceSubFolder ' + WorkspaceSubFolder);
            access_token=objResponse.data.id;
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            //apiIds = cmpAPAPIHeaderCtrl.APIInsert('API3','Pending',data);
            //cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
        
        return access_token;
        
        
    }
}