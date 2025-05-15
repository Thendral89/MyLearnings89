/*
*********************************************************
Apex Class Name    : cmpAPiManageCreateSubFolderCtrl
Created Date       : July 12, 2023
@description       : API4, Create new Subfolder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngClientCreateSubFolderCtrl {
    
    
    public class iManageCreateFolder {
        public string name  {get;set;}
        public String description {get;set;} 
        public String location {get;set;} 
        public String default_security {get;set;} 
        public boolean is_external {get;set;} 
        public boolean is_external_as_normal {get;set;} 
        public boolean is_container_saved_search {get;set;} 
        public boolean is_content_saved_search {get;set;} 
    }
    
    
    public static iManageCreateFolder getapi3data(string name) {
        iManageCreateFolder objOptions = new iManageCreateFolder();
        objOptions.name=name;
        objOptions.description=name;
        objOptions.default_security='public';
        objOptions.is_external=false;
        objOptions.is_external_as_normal=false;
        objOptions.is_container_saved_search=false;
        objOptions.is_content_saved_search=false;
        
        return objOptions;
        
        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> iMngBatchCreateFolder(string access_token, string foldername,string recordId, string createdFolderId, string ParentworkspaceId) {
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string workspaceId='';
        string ClientWorkspacesId='';
        string ParentId='';
        List<iManage_Folders__c> ObjiMngFolder = new List<iManage_Folders__c>();
        List<iManage_Workspace__c> ObjWorkspace  = [SELECT Id,recordId__c,Name,name__c,Id__c
                                                    FROM iManage_Workspace__c 
                                                    WHERE Id__c =: ParentworkspaceId  limit 1];
        if(ObjWorkspace.size()>0){
            for(iManage_Workspace__c fata: ObjWorkspace){
                ClientWorkspacesId=fata.Id;
            }
        }
        
        List<iManage_Folders__c> ObjFolder  = [SELECT Id,iManage_Workspace__c,id__c
                                               FROM iManage_Folders__c 
                                               WHERE id__c =: createdFolderId AND ParentId__c=null limit 1 ];
        if(ObjFolder.size()>0){
            ParentId=ObjFolder[0].Id;
        }
        
        //System.debug('cmpAPiMngClientCreateSubFolderCtrl ClientWorkspacesId ' + ClientWorkspacesId);
        //System.debug('cmpAPiMngClientCreateSubFolderCtrl ParentworkspaceId ' + ParentworkspaceId);
        //System.debug('cmpAPiMngClientCreateSubFolderCtrl foldername ' + foldername);
        
        
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            workspaceId=cmpAPAPIHeaderCtrl.getworkspaceId(objCSworkday[0].workspaces__c);
            iManageCreateFolder objOptions = cmpAPiMngClientCreateSubFolderCtrl.getapi3data(foldername);
            data=  JSON.serialize(objOptions) ;
            system.debug('data' + data);
            string apibody=data;
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId +'/subfolders';
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
                System.debug('cmpAPiMngClientCreateSubFolderCtrl getBody' + httpResponse.getBody());
                returnresponse=httpResponse.getBody();
                access_token='success';
                
            }
            
            if(test.isRunningTest()) 
                returnresponse='{"data":{"database":"ACTIVE","default_security":"public","description":"Letters","edit_date":"2024-12-20T10:39:17Z","effective_security":"full_access","folder_type":"regular","has_documents":false,"has_subfolders":false,"id":"ACTIVE!1441361","is_container_saved_search":false,"is_content_saved_search":false,"is_external":false,"is_external_as_normal":false,"is_hidden":false,"name":"Letters","owner":"SYMPHONYSANDBOX","owner_description":"Symphony Sandbox","parent_id":"ACTIVE!1441354","profile":{"author":"symphonysandbox","class":"DOC","operator":"symphonysandbox"},"view_type":"document","workspace_id":"ACTIVE!1441354","workspace_name":"10004-065US1","wstype":"folder"}}';
            
            cmpAPiManageCreateSubFolderWrraper objResponse = (cmpAPiManageCreateSubFolderWrraper) JSON.deserialize(returnresponse,cmpAPiManageCreateSubFolderWrraper.Class);
            iManage_Folders__c imngDocuments = new iManage_Folders__c();
            imngDocuments.database__c=objResponse.data.database;	//MB_SB
            imngDocuments.default_security__c=objResponse.data.default_security;	//public
            imngDocuments.description__c=objResponse.data.description;	//Sub Folder Created For Demo Purposes
            imngDocuments.edit_date__c=objResponse.data.edit_date;	//2023-12-11T08:52:42Z
            imngDocuments.effective_security__c=objResponse.data.effective_security;	//full_access
            imngDocuments.folder_type__c=objResponse.data.folder_type;	//regular
            imngDocuments.has_documents__c=objResponse.data.has_documents;
            imngDocuments.has_subfolders__c=objResponse.data.has_subfolders;
            imngDocuments.id__c=objResponse.data.id;	//MB_SB!10
            imngDocuments.is_container_saved_search__c=objResponse.data.is_container_saved_search;
            imngDocuments.is_content_saved_search__c=objResponse.data.is_content_saved_search;
            imngDocuments.is_external__c=objResponse.data.is_external;
            imngDocuments.is_external_as_normal__c=objResponse.data.is_external_as_normal;
            imngDocuments.is_hidden__c=objResponse.data.is_hidden;
            imngDocuments.location__c=objResponse.data.location;	//Demoville
            imngDocuments.name__c=objResponse.data.name;	//Demo Sub Folder
            imngDocuments.owner__c=objResponse.data.owner;	//SYM_SVC
            imngDocuments.owner_description__c=objResponse.data.owner_description;	//Symphony Service Account
            imngDocuments.parent_id__c=objResponse.data.parent_id;	//MB_SB!1
            imngDocuments.view_type__c=objResponse.data.view_type;	//document
            imngDocuments.wstype__c=objResponse.data.wstype;	//folder
            imngDocuments.recordId__c=recordId;	//folder
            if(ParentId!='' && ParentId!=null)
                imngDocuments.ParentId__c=ParentId;
            
            if(ClientWorkspacesId!='' && ClientWorkspacesId!=null)
                imngDocuments.iManage_Workspace__c=ClientWorkspacesId;
            
            //insert imngDocuments;
            //createdFolderId=imngDocuments.Id;
            ObjiMngFolder.add(imngDocuments);
                
            
        } catch(Exception exp) {
            System.debug('cmpAPiMngClientCreateSubFolderCtrl Error ' + exp.getMessage());
            //apiIds = cmpAPAPIHeaderCtrl.APIInsert('API4','Pending',data,recordId);
        }
        
        return ObjiMngFolder;
        
    }
    
    @AuraEnabled
    public static string iMngCreateFolder(string access_token, string foldername,string recordId, string createdFolderId, string ParentworkspaceId) {
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string workspaceId='';
        string ClientWorkspacesId='';
        string ParentId='';
        List<iManage_Workspace__c> ObjWorkspace  = [SELECT Id,recordId__c,Name,name__c,Id__c
                                                    FROM iManage_Workspace__c 
                                                    WHERE Id__c =: ParentworkspaceId  limit 1];
        if(ObjWorkspace.size()>0){
            for(iManage_Workspace__c fata: ObjWorkspace){
                ClientWorkspacesId=fata.Id;
            }
        }
        
        List<iManage_Folders__c> ObjFolder  = [SELECT Id,iManage_Workspace__c,id__c
                                               FROM iManage_Folders__c 
                                               WHERE id__c =: createdFolderId AND ParentId__c=null limit 1 ];
        if(ObjFolder.size()>0){
            ParentId=ObjFolder[0].Id;
        }
        
        System.debug('cmpAPiMngClientCreateSubFolderCtrl ClientWorkspacesId ' + ClientWorkspacesId);
        System.debug('cmpAPiMngClientCreateSubFolderCtrl ParentworkspaceId ' + ParentworkspaceId);
        System.debug('cmpAPiMngClientCreateSubFolderCtrl foldername ' + foldername);
        
        
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            workspaceId=cmpAPAPIHeaderCtrl.getworkspaceId(objCSworkday[0].workspaces__c);
            iManageCreateFolder objOptions = cmpAPiMngClientCreateSubFolderCtrl.getapi3data(foldername);
            data=  JSON.serialize(objOptions) ;
            system.debug('data' + data);
            string apibody=data;
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId +'/subfolders';
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
                System.debug('cmpAPiMngClientCreateSubFolderCtrl getBody' + httpResponse.getBody());
                returnresponse=httpResponse.getBody();
                access_token='success';
                
            }
            
            if(test.isRunningTest()) 
                returnresponse='{"data":{"database":"ACTIVE","default_security":"public","description":"Letters","edit_date":"2024-12-20T10:39:17Z","effective_security":"full_access","folder_type":"regular","has_documents":false,"has_subfolders":false,"id":"ACTIVE!1441361","is_container_saved_search":false,"is_content_saved_search":false,"is_external":false,"is_external_as_normal":false,"is_hidden":false,"name":"Letters","owner":"SYMPHONYSANDBOX","owner_description":"Symphony Sandbox","parent_id":"ACTIVE!1441354","profile":{"author":"symphonysandbox","class":"DOC","operator":"symphonysandbox"},"view_type":"document","workspace_id":"ACTIVE!1441354","workspace_name":"10004-065US1","wstype":"folder"}}';
            
            cmpAPiManageCreateSubFolderWrraper objResponse = (cmpAPiManageCreateSubFolderWrraper) JSON.deserialize(returnresponse,cmpAPiManageCreateSubFolderWrraper.Class);
            iManage_Folders__c imngDocuments = new iManage_Folders__c();
            imngDocuments.database__c=objResponse.data.database;	//MB_SB
            imngDocuments.default_security__c=objResponse.data.default_security;	//public
            imngDocuments.description__c=objResponse.data.description;	//Sub Folder Created For Demo Purposes
            imngDocuments.edit_date__c=objResponse.data.edit_date;	//2023-12-11T08:52:42Z
            imngDocuments.effective_security__c=objResponse.data.effective_security;	//full_access
            imngDocuments.folder_type__c=objResponse.data.folder_type;	//regular
            imngDocuments.has_documents__c=objResponse.data.has_documents;
            imngDocuments.has_subfolders__c=objResponse.data.has_subfolders;
            imngDocuments.id__c=objResponse.data.id;	//MB_SB!10
            imngDocuments.is_container_saved_search__c=objResponse.data.is_container_saved_search;
            imngDocuments.is_content_saved_search__c=objResponse.data.is_content_saved_search;
            imngDocuments.is_external__c=objResponse.data.is_external;
            imngDocuments.is_external_as_normal__c=objResponse.data.is_external_as_normal;
            imngDocuments.is_hidden__c=objResponse.data.is_hidden;
            imngDocuments.location__c=objResponse.data.location;	//Demoville
            imngDocuments.name__c=objResponse.data.name;	//Demo Sub Folder
            imngDocuments.owner__c=objResponse.data.owner;	//SYM_SVC
            imngDocuments.owner_description__c=objResponse.data.owner_description;	//Symphony Service Account
            imngDocuments.parent_id__c=objResponse.data.parent_id;	//MB_SB!1
            imngDocuments.view_type__c=objResponse.data.view_type;	//document
            imngDocuments.wstype__c=objResponse.data.wstype;	//folder
            imngDocuments.recordId__c=recordId;	//folder
            if(ParentId!='' && ParentId!=null)
                imngDocuments.ParentId__c=ParentId;
            
            if(ClientWorkspacesId!='' && ClientWorkspacesId!=null)
                imngDocuments.iManage_Workspace__c=ClientWorkspacesId;
            
            insert imngDocuments;
            createdFolderId=imngDocuments.Id;
            
            
        } catch(Exception exp) {
            System.debug('cmpAPiMngClientCreateSubFolderCtrl Error ' + exp.getMessage());
            //apiIds = cmpAPAPIHeaderCtrl.APIInsert('API4','Pending',data,recordId);
        }
        
        return createdFolderId;
        
    }
}