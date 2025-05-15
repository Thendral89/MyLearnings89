/*
*********************************************************
Apex Class Name    : cmpAPiMngClientSearchSubFolderCtrl
Created Date       : July 12, 2023
@description       : API3, Create new folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngClientSearchSubFolderBatchCtrl {

    
    
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
  public static List<iManage_Folders__c> CreateBatchFolder(string access_token,string recordId, string foldername, string workspaces,string ParentFolderId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
      	string FolderId='';
        List<string> FoldersIds = new List<string>();
        string StatusCode='';
        string ClientWorkspacesId='';
      List<iManage_Folders__c> ObjiMangFolder = new List<iManage_Folders__c>();
      List<iManage_Folders__c> ObjFolder  = [SELECT Id,name__c,iManage_Workspace__c,id__c
                                             FROM iManage_Folders__c 
                                             WHERE recordId__c =: recordId ];
      if(ObjFolder.size()>0){
          for(iManage_Folders__c fata: ObjFolder){
              FoldersIds.add(fata.name__c);   
          }
      }
      
      List<iManage_Workspace__c> ObjWorkspace  = [SELECT Id,recordId__c,Name,name__c,Id__c
                                             FROM iManage_Workspace__c 
                                             WHERE Id__c =: workspaces  limit 1];
      if(ObjWorkspace.size()>0){
          for(iManage_Workspace__c fata: ObjWorkspace){
              ClientWorkspacesId=fata.Id;
          }
      }
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + ParentFolderId +'/children?exclude_docs=true';
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
                 StatusCode= string.valueof(httpResponse.getStatusCode());
                 access_token='success';
            }
            
            
            
            if(test.isRunningTest()) 
               returnresponse='{"data":{"database":"ACTIVE","default_security":"public","description":"Letters","edit_date":"2024-12-20T10:39:17Z","effective_security":"full_access","folder_type":"regular","has_documents":false,"has_subfolders":false,"id":"ACTIVE!1441361","is_container_saved_search":false,"is_content_saved_search":false,"is_external":false,"is_external_as_normal":false,"is_hidden":false,"name":"Letters","owner":"SYMPHONYSANDBOX","owner_description":"Symphony Sandbox","parent_id":"ACTIVE!1441354","profile":{"author":"symphonysandbox","class":"DOC","operator":"symphonysandbox"},"view_type":"document","workspace_id":"ACTIVE!1441354","workspace_name":"10004-065US1","wstype":"folder"}}';
            
           
            if(StatusCode=='200' || StatusCode=='201'){
                cmpAPiMngClientSearchObjectFolderWrraper objResponse = (cmpAPiMngClientSearchObjectFolderWrraper) JSON.deserialize(returnresponse,cmpAPiMngClientSearchObjectFolderWrraper.Class);
                if(objResponse.data.size()>0){
                    for(cmpAPiMngClientSearchObjectFolderWrraper.data objRes : objResponse.data ) {
                        iManage_Folders__c imngDocuments = new iManage_Folders__c();
                        imngDocuments.database__c=objRes.database;	//MB_SB
                        imngDocuments.default_security__c=objRes.default_security;	//public
                        imngDocuments.description__c=objRes.description;	//Sub Folder Created For Demo Purposes
                        imngDocuments.edit_date__c=objRes.edit_date;	//2023-12-11T08:52:42Z
                        imngDocuments.effective_security__c=objRes.effective_security;	//full_access
                        imngDocuments.folder_type__c=objRes.folder_type;	//regular
                        imngDocuments.has_documents__c=objRes.has_documents;
                        imngDocuments.has_subfolders__c=objRes.has_subfolders;
                        imngDocuments.id__c=objRes.id;	//MB_SB!10
                        imngDocuments.is_container_saved_search__c=objRes.is_container_saved_search;
                        imngDocuments.is_content_saved_search__c=objRes.is_content_saved_search;
                        imngDocuments.is_external__c=objRes.is_external;
                        imngDocuments.is_external_as_normal__c=objRes.is_external_as_normal;
                        imngDocuments.is_hidden__c=objRes.is_hidden;
                        imngDocuments.location__c=objRes.location;	//Demoville
                        imngDocuments.name__c=objRes.name;	//Demo Sub Folder
                        imngDocuments.owner__c=objRes.owner;	//SYM_SVC
                        imngDocuments.owner_description__c=objRes.owner_description;	//Symphony Service Account
                        imngDocuments.parent_id__c=objRes.parent_id;	//MB_SB!1
                        imngDocuments.view_type__c=objRes.view_type;	//document
                        imngDocuments.wstype__c=objRes.wstype;	//folder
                        imngDocuments.recordId__c=recordId;	//folder
                        if(foldername==objRes.name){
                            if(!FoldersIds.contains(objRes.name)){ 
                                 List<iManage_Folders__c> ObjiFolders  = [SELECT Id,iManage_Workspace__c,id__c
                                                        FROM iManage_Folders__c 
                                                        WHERE id__c =: objRes.parent_id ];
                                if(ObjiFolders.size()>0)
                                    imngDocuments.ParentId__c=ObjiFolders[0].Id;
                                
                                
                                if(ClientWorkspacesId!='' && ClientWorkspacesId!=null)
                                    imngDocuments.iManage_Workspace__c=ClientWorkspacesId;
                                ObjiMangFolder.add(imngDocuments);
                              
                            }
                        }
                        
                    }
                }
              
            } 
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            //apiIds = cmpAPAPIHeaderCtrl.APIInsert('API3','Pending',data);
            //cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return ObjiMangFolder;
      
      
    }
    
  @AuraEnabled
  public static string iMngCreateFolder(string access_token,string recordId, string foldername, string workspaces,string ParentFolderId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
      	string FolderId='';
        List<string> FoldersIds = new List<string>();
        string StatusCode='';
        string ClientWorkspacesId='';
      List<iManage_Folders__c> ObjiMangFolder = new List<iManage_Folders__c>();
      List<iManage_Folders__c> ObjFolder  = [SELECT Id,name__c,iManage_Workspace__c,id__c
                                             FROM iManage_Folders__c 
                                             WHERE recordId__c =: recordId ];
      if(ObjFolder.size()>0){
          for(iManage_Folders__c fata: ObjFolder){
              FoldersIds.add(fata.name__c);   
          }
      }
      
      List<iManage_Workspace__c> ObjWorkspace  = [SELECT Id,recordId__c,Name,name__c,Id__c
                                             FROM iManage_Workspace__c 
                                             WHERE Id__c =: workspaces  limit 1];
      if(ObjWorkspace.size()>0){
          for(iManage_Workspace__c fata: ObjWorkspace){
              ClientWorkspacesId=fata.Id;
          }
      }
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + ParentFolderId +'/children?exclude_docs=false';
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
                 StatusCode= string.valueof(httpResponse.getStatusCode());
                 access_token='success';
            }
            
            
            
            if(test.isRunningTest()) 
               returnresponse='{"data":{"database":"ACTIVE","default_security":"public","description":"Letters","edit_date":"2024-12-20T10:39:17Z","effective_security":"full_access","folder_type":"regular","has_documents":false,"has_subfolders":false,"id":"ACTIVE!1441361","is_container_saved_search":false,"is_content_saved_search":false,"is_external":false,"is_external_as_normal":false,"is_hidden":false,"name":"Letters","owner":"SYMPHONYSANDBOX","owner_description":"Symphony Sandbox","parent_id":"ACTIVE!1441354","profile":{"author":"symphonysandbox","class":"DOC","operator":"symphonysandbox"},"view_type":"document","workspace_id":"ACTIVE!1441354","workspace_name":"10004-065US1","wstype":"folder"}}';
            
           
            if(StatusCode=='200' || StatusCode=='201'){
                cmpAPiMngClientSearchObjectFolderWrraper objResponse = (cmpAPiMngClientSearchObjectFolderWrraper) JSON.deserialize(returnresponse,cmpAPiMngClientSearchObjectFolderWrraper.Class);
                if(objResponse.data.size()>0){
                    for(cmpAPiMngClientSearchObjectFolderWrraper.data objRes : objResponse.data ) {
                        iManage_Folders__c imngDocuments = new iManage_Folders__c();
                        imngDocuments.database__c=objRes.database;	//MB_SB
                        imngDocuments.default_security__c=objRes.default_security;	//public
                        imngDocuments.description__c=objRes.description;	//Sub Folder Created For Demo Purposes
                        imngDocuments.edit_date__c=objRes.edit_date;	//2023-12-11T08:52:42Z
                        imngDocuments.effective_security__c=objRes.effective_security;	//full_access
                        imngDocuments.folder_type__c=objRes.folder_type;	//regular
                        imngDocuments.has_documents__c=objRes.has_documents;
                        imngDocuments.has_subfolders__c=objRes.has_subfolders;
                        imngDocuments.id__c=objRes.id;	//MB_SB!10
                        imngDocuments.is_container_saved_search__c=objRes.is_container_saved_search;
                        imngDocuments.is_content_saved_search__c=objRes.is_content_saved_search;
                        imngDocuments.is_external__c=objRes.is_external;
                        imngDocuments.is_external_as_normal__c=objRes.is_external_as_normal;
                        imngDocuments.is_hidden__c=objRes.is_hidden;
                        imngDocuments.location__c=objRes.location;	//Demoville
                        imngDocuments.name__c=objRes.name;	//Demo Sub Folder
                        imngDocuments.owner__c=objRes.owner;	//SYM_SVC
                        imngDocuments.owner_description__c=objRes.owner_description;	//Symphony Service Account
                        imngDocuments.parent_id__c=objRes.parent_id;	//MB_SB!1
                        imngDocuments.view_type__c=objRes.view_type;	//document
                        imngDocuments.wstype__c=objRes.wstype;	//folder
                        imngDocuments.recordId__c=recordId;	//folder
                        if(foldername==objRes.name){
                            if(!FoldersIds.contains(objRes.name)){ 
                                 List<iManage_Folders__c> ObjiFolders  = [SELECT Id,iManage_Workspace__c,id__c
                                                        FROM iManage_Folders__c 
                                                        WHERE id__c =: objRes.parent_id ];
                                if(ObjiFolders.size()>0)
                                    imngDocuments.ParentId__c=ObjiFolders[0].Id;
                                
                                
                                if(ClientWorkspacesId!='' && ClientWorkspacesId!=null)
                                    imngDocuments.iManage_Workspace__c=ClientWorkspacesId;
                                ObjiMangFolder.add(imngDocuments);
                              
                            }
                        }
                        
                    }
                }
                
                if(!ObjiMangFolder.IsEmpty()){
                    insert ObjiMangFolder;
                    FolderId='Yes';
                    return FolderId;
                }
                  
            } 
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            //apiIds = cmpAPAPIHeaderCtrl.APIInsert('API3','Pending',data);
            //cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return FolderId;
      
      
    }
}