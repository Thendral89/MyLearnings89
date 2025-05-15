/*
*********************************************************
Apex Class Name    : cmpAPiManageCreateFolderCtrl
Created Date       : July 12, 2023
@description       : API3, Create new folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiManageCreateFolderCtrl {

    
    
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
  public static string iMngCreateFolder(string access_token,string recordId, string foldername, string workspaces,string SFrecordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        List<string> FoldersIds = new List<string>();
      
        
            
      List<iManage_Folders__c> ObjFolders  = [SELECT Id,recordId__c,id__c
                                               FROM iManage_Folders__c 
                                               WHERE recordId__c =: recordId ];
      if (ObjFolders.Size() >0 ) {
          for(iManage_Folders__c fata: ObjFolders){
              FoldersIds.add(fata.id__c);
          }
      }
      
        try {
            
            system.debug('workspaces' + workspaces);
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            List<iManage_Workspace__c> workspaceId=cmpAPAPIHeaderCtrl.getworkspaceDetails(workspaces);
            if(workspaceId.isempty())
                return returnresponse;
            
            
            data = cmpAPiManageCreateFolderCtrl.getapi3data(foldername,foldername,objCSworkday[0].username__c);
            
            system.debug('data' + workspaceId);
            string apibody=data;
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/workspaces/' + workspaceId[0].Id__c +'/folders';
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
            imngDocuments.recordId__c=recordId;	//Object recordId
            if(workspaceId.size()>0)
                imngDocuments.iManage_Workspace__c=workspaceId[0].Id;	//Object recordId
            
            if(!FoldersIds.contains(objResponse.data.id))
                insert imngDocuments;
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API3','Pending',data); 
            
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
        } catch(Exception exp) {
            access_token='Error';
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API3','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return access_token;
      
      
    }
}