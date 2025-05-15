/*
*********************************************************
Apex Class Name    : cmpAPiMngSearchFolderWorkspaceIdCtrl
Created Date       : July 12, 2023
@description       : API21, get updated folders from workspace Id
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/
public class cmpAPiMngSearchFolderWorkspaceIdCtrl {

    
  @AuraEnabled
  public static string iMngWSFolder(string access_token,string workspaces,string recordId, string workspaceId) {
      
      	string apiIds ='';
        string data= '';
        string returnresponse='';
        string iManageFoldersId='';
        List<iManage_Folders__c> ObjDocuments = new List<iManage_Folders__c>();
      	Map<String,String> mapworkspace=new Map<String,String>();
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            List<iManage_Workspace__c> ObjWorkspace = cmpAPAPIHeaderCtrl.getworkspaceDetails(workspaces);
            
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/workspaces/' + workspaces + '/children?limit=1000&sort_order=asc' ;
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
            }
          
            if(test.isRunningTest()) {
                returnresponse='{  "data": [    {      "database": "MB_SB",      "default_security": "public",      "description": "MB-PT-100080-US",      "edit_date": "2023-12-19T07:39:02Z",      "folder_type": "regular",      "has_documents": "true",      "has_subfolders": "false",      "id": "MB_SB!20",      "is_container_saved_search": "false",      "is_content_saved_search": "false",      "is_external": "false",      "is_external_as_normal": "false",      "is_hidden": "false",      "name": "MB-PT-100080-US",      "owner": "SYM_SVC",      "owner_description": "Symphony Service Account",      "parent_id": "MB_SB!5",      "view_type": "document",      "workspace_id": "MB_SB!5",      "workspace_name": "iManage Cloud Monitor",      "wstype": "folder"    }  ]}';
                returnresponse=returnresponse.replace('"class"','"class_code"');
            }
            
        List<string> iManageDocumentsIds = new List<string>();
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,id__c FROM iManage_Folders__c 
                                                WHERE recordId__c =: recordId ];
         if (ObjFolders.size()>0) { 
             for(iManage_Folders__c record: ObjFolders){
                 iManageDocumentsIds.add(record.id__c);
                 mapworkspace.put(record.id__c,record.Id);
             }
         }
            
           cmpAPiMngGetSubFolderWrraper FolderDocWrraper = (cmpAPiMngGetSubFolderWrraper) JSON.deserialize(returnresponse,cmpAPiMngGetSubFolderWrraper.Class);
          if(FolderDocWrraper.data.size()>0){
            for(cmpAPiMngGetSubFolderWrraper.data objResponse : FolderDocWrraper.data ) {
            	iManage_Folders__c imngDocuments = new iManage_Folders__c();
           		imngDocuments.database__c=objResponse.database;	//MB_SB
				imngDocuments.default_security__c=objResponse.default_security;	//public
				imngDocuments.description__c=objResponse.description;	//Sub Folder Created For Demo Purposes
				imngDocuments.edit_date__c=objResponse.edit_date;	//2023-12-11T08:52:42Z
				imngDocuments.effective_security__c='';
				imngDocuments.folder_type__c=objResponse.folder_type;	//regular
				imngDocuments.has_documents__c=objResponse.has_documents;
				imngDocuments.has_subfolders__c=objResponse.has_subfolders;
				imngDocuments.id__c=objResponse.id;	//MB_SB!10
				imngDocuments.is_container_saved_search__c=objResponse.is_container_saved_search;
				imngDocuments.is_content_saved_search__c=objResponse.is_content_saved_search;
				imngDocuments.is_external__c=objResponse.is_external;
				imngDocuments.is_external_as_normal__c=objResponse.is_external_as_normal;
				imngDocuments.is_hidden__c=objResponse.is_hidden;
				imngDocuments.location__c='';
				imngDocuments.name__c=objResponse.name;	//Demo Sub Folder
				imngDocuments.owner__c=objResponse.owner;	//SYM_SVC
				imngDocuments.owner_description__c=objResponse.owner_description;	//Symphony Service Account
				imngDocuments.parent_id__c=objResponse.parent_id;	//MB_SB!1
				imngDocuments.view_type__c=objResponse.view_type;	//document
				imngDocuments.wstype__c=objResponse.wstype;	//folder
                imngDocuments.iManage_Workspace__c=workspaceId;	//Object recordId
                imngDocuments.recordId__c=recordId;	//Object recordId
                
            	if (mapworkspace.containsKey(objResponse.id)){
                    imngDocuments.Id=mapworkspace.get(objResponse.id); 
                }
                if (!iManageDocumentsIds.contains(objResponse.id))
                	ObjDocuments.add(imngDocuments);
            }
          } else {
              string foldername = cmpAPiManagDocumentCtrl.getIPMatterNumber(recordId);
              system.debug('foldername ' + foldername);
              
              cmpAPiManageCreateFolderCtrl.iMngCreateFolder(access_token,recordId,foldername,foldername,recordId);
          }
           
            system.debug('ObjDocuments ' + ObjDocuments);
			access_token='';
            if(ObjDocuments.size()>0){
               upsert ObjDocuments; 
               access_token='Success';
            }
               
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API21','Pending',data); 
            if(access_token !=''){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API21','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending','Error ' + exp.getMessage(),recordId);
        }
       
      
      return access_token;
      
    }
}