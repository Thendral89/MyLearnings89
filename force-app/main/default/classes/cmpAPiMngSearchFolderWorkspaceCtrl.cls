/*
*********************************************************
Apex Class Name    : cmpAPiMngSearchFolderWorkspaceCtrl
Created Date       : July 12, 2023
@description       : API20, get updated folders from workspace
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngSearchFolderWorkspaceCtrl {

    
  @AuraEnabled
  public static string iMngSearchworkspaceFolder(string access_token,string workspaces) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        string iManageFoldersId='';
      	string workspaceId='';
      
      	string iMngreturnresponse='';
      	string iMngAPI5data='';
        string iMngiManageFoldersId='';
      	string iMngworkspaceId='';
      
      
        List<iManage_Setting__c> ObjDocuments = new List<iManage_Setting__c>();
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
                 access_token='';
            }

            if(test.isRunningTest()) {
                returnresponse='{  "data": [    {      "database": "MB_SB",      "default_security": "public",      "description": "MB-PT-100080-US",      "edit_date": "2023-12-19T07:39:02Z",      "folder_type": "regular",      "has_documents": "true",      "has_subfolders": "false",      "id": "MB_SB!20",      "is_container_saved_search": "false",      "is_content_saved_search": "false",      "is_external": "false",      "is_external_as_normal": "false",      "is_hidden": "false",      "name": "MB-PT-100080-US",      "owner": "SYM_SVC",      "owner_description": "Symphony Service Account",      "parent_id": "MB_SB!5",      "view_type": "document",      "workspace_id": "MB_SB!5",      "workspace_name": "iManage Cloud Monitor",      "wstype": "folder"    }  ]}';
                returnresponse=returnresponse.replace('"class"','"class_code"');
            }
            
         List<string> iManageDocumentsIds = new List<string>();
         List<iManage_Setting__c> ObjWorkspaces = cmpAPAPIHeaderCtrl.getiManageSettingsWorkspace(workspaces);
         if (ObjWorkspaces.size()>0) { 
             for(iManage_Setting__c record: ObjWorkspaces){
                 iManageDocumentsIds.add(record.Folder_Id__c);
                 mapworkspace.put(record.Folder_Id__c,record.Id);
             }
         }
            
           cmpAPiMngGetSubFolderWrraper FolderDocWrraper = (cmpAPiMngGetSubFolderWrraper) JSON.deserialize(returnresponse,cmpAPiMngGetSubFolderWrraper.Class);
            for(cmpAPiMngGetSubFolderWrraper.data objResponse : FolderDocWrraper.data ) {
            	iManage_Setting__c imngDocuments = new iManage_Setting__c();
           		imngDocuments.Folder_Id__c=objResponse.id;	//MB_SB
				imngDocuments.Name__c=objResponse.name;	//public
                if(ObjWorkspace.size()>0){
                    imngDocuments.Matter__c=ObjWorkspace[0].custom2__c;	//Sub Folder Created For Demo Purposes
                    imngDocuments.Client__c=ObjWorkspace[0].custom1__c;	//2023-12-11T08:52:42Z
                    imngDocuments.WorkspaceSubcase__c=ObjWorkspace[0].custom10__c;	//2023-12-11T08:52:42Z
                    imngDocuments.Workspaces__c=workspaces;
                    imngDocuments.IsProcessed__c=false;
                }
            	if (mapworkspace.containsKey(objResponse.id)){
                    imngDocuments.Id=mapworkspace.get(objResponse.id); 
                }
                	ObjDocuments.add(imngDocuments);
          }  
            
           if(ObjDocuments.size()>0)
               upsert ObjDocuments;
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API20','Pending',data); 
            if(access_token !=''){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API20','Pending',data);
        }
       
      
      return access_token;
      
    }
}