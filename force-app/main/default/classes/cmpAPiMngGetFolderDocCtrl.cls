/*
*********************************************************
Apex Class Name    : cmpAPiMngGetFolderDocCtrl
Created Date       : July 12, 2023
@description       : API13, get documents
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngGetFolderDocCtrl {
    
    
  @AuraEnabled
  public static string iMngGetDoc(string access_token, string createdFolderId, string SympManageFoldersId,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        List<iManage_Documents__c> ObjDocuments = new List<iManage_Documents__c>();
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId+ '/documents';
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
                 access_token='success';
            }
          
         List<string> iManageDocumentsIds = new List<string>();
         List<iManage_Documents__c> ObjFolders  = [SELECT Id,id__c
                                                  FROM iManage_Documents__c 
                                                  WHERE iManage_Folders__c =: SympManageFoldersId];
         if (ObjFolders.size()>0) { 
             for(iManage_Documents__c record: ObjFolders){
                 iManageDocumentsIds.add(record.id__c);
             }
         }
            
            if(test.isRunningTest()) 
                returnresponse='{  "data": [    {      "database": "SampleDatabase",      "document_number": "123456",      "version": "1.0",      "name": "Sample Document",      "author": "John Doe",      "operator": "Admin",      "type": "pdf",      "class_code": "A1",      "edit_date": "2024-12-29T10:00:00Z",      "system_edit_date": "2024-12-29T10:00:00Z",      "create_date": "2024-12-01T08:30:00Z",      "create_profile_date": "2024-12-01T08:30:00Z",      "retain_days": "30",      "size": "2048",      "is_declared": "true",      "declared": "true",      "is_related": "false",      "default_security": "high",      "last_user": "Jane Smith",      "is_in_use": "false",      "is_checked_out": "true",      "type_description": "PDF Document",      "class_description": "Document Type A1",      "extension": "pdf",      "content_type": "application/pdf",      "edit_profile_date": "2024-12-29T10:00:00Z",      "is_external": "false",      "is_external_as_normal": "false",      "file_create_date": "2024-12-01T08:30:00Z",      "file_edit_date": "2024-12-29T10:00:00Z",      "is_hipaa": "false",      "workspace_name": "Workspace1",      "is_restorable": "true",      "id": "doc123",      "in_use": "false",      "indexable": "true",      "wstype": "typeA",      "iwl": "true",      "workspace_id": "workspace1_id",      "author_description": "Document Author",      "operator_description": "Admin User",      "last_user_description": "Last User"    }  ]}';
                
            cmpAPiMngGetFolderDocWrraper FolderDocWrraper = (cmpAPiMngGetFolderDocWrraper) JSON.deserialize(returnresponse,cmpAPiMngGetFolderDocWrraper.Class);
            for(cmpAPiMngGetFolderDocWrraper.data objResponse : FolderDocWrraper.data ) {
                iManage_Documents__c imngDocuments = new iManage_Documents__c();
            	imngDocuments.database__c=objResponse.database;	//MB_SB
            	imngDocuments.document_number__c=objResponse.document_number;	//8
				imngDocuments.version__c=objResponse.version;	//1
				imngDocuments.name__c=objResponse.name;	//Michael-Best_thumbnail_MB-LOGO-1024x306
				imngDocuments.author__c=objResponse.author;	//SYM_SVC
				imngDocuments.operator__c=objResponse.operator;	//SYM_SVC
				imngDocuments.type__c=objResponse.type;	//PNG
				imngDocuments.class_code__c=objResponse.class_code;	//DOC
				imngDocuments.edit_date__c=objResponse.edit_date;	//2023-12-13T15:37:40Z
				imngDocuments.system_edit_date__c=objResponse.system_edit_date;	//2023-12-13T15:37:40Z
				imngDocuments.create_date__c=objResponse.create_date;	//2023-12-13T15:37:40Z
				imngDocuments.create_profile_date__c=objResponse.create_profile_date;	//2023-12-13T15:37:40Z
				imngDocuments.retain_days__c=objResponse.retain_days;	//365
				imngDocuments.size__c=objResponse.size;	//40732
				imngDocuments.is_declared__c=objResponse.is_declared;
            	imngDocuments.declared__c=objResponse.declared;
				imngDocuments.default_security__c=objResponse.default_security;	//public
				imngDocuments.last_user__c=objResponse.last_user;	//SYM_SVC
				imngDocuments.is_in_use__c=objResponse.is_in_use;
				imngDocuments.is_checked_out__c=objResponse.is_checked_out;
				imngDocuments.author_description__c=objResponse.author_description;	//Symphony Service Account
				imngDocuments.operator_description__c=objResponse.operator_description;	//Symphony Service Account
				imngDocuments.type_description__c=objResponse.type_description;	//PNG
				imngDocuments.class_description__c=objResponse.class_description;	//Document
				imngDocuments.last_user_description__c=objResponse.last_user_description;	//Symphony Service Account
				imngDocuments.extension__c=objResponse.extension;	//png
				imngDocuments.content_type__c=objResponse.content_type;	//D
				imngDocuments.edit_profile_date__c=objResponse.edit_profile_date;	//2023-12-13T15:37:40Z
				imngDocuments.is_external__c=objResponse.is_external;
				imngDocuments.is_external_as_normal__c=objResponse.is_external_as_normal;
				imngDocuments.file_create_date__c=objResponse.file_create_date;	//2023-12-13T15:37:40Z
				imngDocuments.file_edit_date__c=objResponse.file_edit_date;	//2023-12-13T15:37:40Z
				imngDocuments.is_hipaa__c=objResponse.is_hipaa;
				imngDocuments.workspace_name__c=objResponse.workspace_name;	//OCR Rendition Folder
				imngDocuments.id__c=objResponse.id;	//MB_SB!8.1
				imngDocuments.in_use__c=objResponse.in_use;
				imngDocuments.indexable__c=objResponse.indexable;
				imngDocuments.wstype__c=objResponse.wstype;	//document
				imngDocuments.iwl__c=objResponse.iwl;	//iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=8&&ver=1
				imngDocuments.workspace_id__c=objResponse.workspace_id;	//MB_SB!1
            	imngDocuments.iManage_Folders__c=SympManageFoldersId;
                if (!iManageDocumentsIds.contains(objResponse.id)) 
                    ObjDocuments.add(imngDocuments);
            }
            
            if(ObjDocuments.size()>0){
                insert ObjDocuments;
                Bytedance_IDF_ID=ObjDocuments[0].Id;
            }
                
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API13','Pending',data,Bytedance_IDF_ID); 
            
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
                cmpAPAPIHeaderCtrl.LastSycFolder(SympManageFoldersId);
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API13','Pending',data,Bytedance_IDF_ID);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      
      return access_token;
      
    }
}