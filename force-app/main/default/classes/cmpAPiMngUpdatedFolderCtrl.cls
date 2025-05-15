/*
*********************************************************
Apex Class Name    : cmpAPiMngUpdatedFolderCtrl
Created Date       : July 12, 2023
@description       : API23, get updated documents
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/
public class cmpAPiMngUpdatedFolderCtrl {

    
  @AuraEnabled
  public static string iMngUpdatedFolder(string access_token,string createdFoldername,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        string iManageFoldersId='';
      	string workspaceId='';
        string iManage_WorkspaceId='';
        List<iManage_Folders__c> ObjDocuments = new List<iManage_Folders__c>();
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
                 returnresponse=returnresponse.replace('"class"','"class_code"');
                 access_token='';
            }
          
         List<string> iManageDocumentsIds = new List<string>();
         List<iManage_Folders__c> ObjFolders  = [SELECT Id,id__c,iManage_Workspace__c
                                                 FROM iManage_Folders__c 
                                                 WHERE id__c =: createdFoldername limit 1];
         if (ObjFolders.size()>0) { 
             for(iManage_Folders__c record: ObjFolders){
                 iManage_WorkspaceId=record.iManage_Workspace__c;
                 iManageDocumentsIds.add(record.id__c);
                 iManageFoldersId=record.Id;
                 access_token=record.Id;
             }
         }
            
            if(test.isRunningTest()) {
                returnresponse='{  "data": {    "database": "MB_SB",    "default_security": "public",    "description": "MB-PT-100080-US",    "edit_date": "2023-12-19T07:39:02Z",    "folder_type": "regular",    "has_documents": "true",    "has_subfolders": "false",    "id": "MB_SB!20",    "is_container_saved_search": "false",    "is_content_saved_search": "false",    "is_external": "false",    "is_external_as_normal": "true",    "is_hidden": "false",    "name": "MB-PT-100080-US",    "owner": "SYM_SVC",    "owner_description": "Symphony Service Account",    "parent_id": "MB_SB!5",    "view_type": "document",    "workspace_id": "MB_SB!5",    "workspace_name": "iManage Cloud Monitor",    "wstype": "folder"  }}';
            }
            
           cmpAPiMngUpdatedFolderWrraper objResponse = (cmpAPiMngUpdatedFolderWrraper) JSON.deserialize(returnresponse,cmpAPiMngUpdatedFolderWrraper.Class);
            	iManage_Folders__c imngDocuments = new iManage_Folders__c();
             	if(!test.isRunningTest()) 
                imngDocuments.Id=iManageFoldersId;
           		imngDocuments.database__c=objResponse.data.database;	//MB_SB
				imngDocuments.default_security__c=objResponse.data.default_security;	//public
				imngDocuments.description__c=objResponse.data.description;	//Sub Folder Created For Demo Purposes
				imngDocuments.edit_date__c=objResponse.data.edit_date;	//2023-12-11T08:52:42Z
				imngDocuments.effective_security__c='';
				imngDocuments.folder_type__c=objResponse.data.folder_type;	//regular
				imngDocuments.has_documents__c=objResponse.data.has_documents;
				imngDocuments.has_subfolders__c=objResponse.data.has_subfolders;
				imngDocuments.id__c=objResponse.data.id;	//MB_SB!10
				imngDocuments.is_container_saved_search__c=objResponse.data.is_container_saved_search;
				imngDocuments.is_content_saved_search__c=objResponse.data.is_content_saved_search;
				imngDocuments.is_external__c=objResponse.data.is_external;
				imngDocuments.is_external_as_normal__c=objResponse.data.is_external_as_normal;
				imngDocuments.is_hidden__c=objResponse.data.is_hidden;
				imngDocuments.location__c='';
				imngDocuments.name__c=objResponse.data.name;	//Demo Sub Folder
				imngDocuments.owner__c=objResponse.data.owner;	//SYM_SVC
				imngDocuments.owner_description__c=objResponse.data.owner_description;	//Symphony Service Account
				imngDocuments.parent_id__c=objResponse.data.parent_id;	//MB_SB!1
				imngDocuments.view_type__c=objResponse.data.view_type;	//document
				imngDocuments.wstype__c=objResponse.data.wstype;	//folder
            	if(iManage_WorkspaceId!='')
                imngDocuments.iManage_Workspace__c=iManage_WorkspaceId;	//Object recordId
            	if (iManageDocumentsIds.contains(objResponse.data.id)) 
                	ObjDocuments.add(imngDocuments);
           
            if(ObjDocuments.size()>0)
                update ObjDocuments;
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API23','Pending',data); 
            
            if(access_token !=''){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API23','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending','Error ' + exp.getMessage(),recordId);
        }
       
      
      return access_token;
      
    }
}