/*
*********************************************************
Apex Class Name    : cmpAPiMngDocMoveCtrl
Created Date       : July 12, 2023
@description       : API9, move selected document to another folder
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngDocMoveCtrl {

    
  @AuraEnabled
  public static string iMngDocMove(string access_token,string FolderId, string documentsId, string destinationId,string iManageFoldersId,string iManageDocId,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
      
    	data=' {';
    	data+=' "destination_id" : "' +destinationId+ '",';
    	data+=' "UpdateProfile" : true,';
    	data+=' "UpdateSecurity" : true,';
    	data+=' "audit": {';
    	data+=' "comments": "Moved document"';
    	data+=' }';
		data+=' }';
      
        system.debug('data ' + data);
      
        List<iManage_Documents__c> ObjDocuments = new List<iManage_Documents__c>();
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + FolderId+ '/documents/' + documentsId + '/move';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('POST');  
            req.setBody(data);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-Auth-Token', access_token);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                 HTTPResponse httpResponse = http.send(req);
                 System.debug('httpResponse.getBody()' + httpResponse.getBody());
                 returnresponse=httpResponse.getBody();
                 returnresponse=returnresponse.replace('"class"','"class_code"');
                 if(httpResponse.getStatusCode()==200){
                    access_token='success';
                 } else {
                   cmpAPiMngErrorWrraper objError = (cmpAPiMngErrorWrraper) JSON.deserialize(returnresponse,cmpAPiMngErrorWrraper.Class);
                   access_token= 'error ' + objError.error.code_message + ', ' +  objError.error.detailed_error_message;
                 }
                    
                
            }
          
            if(test.isRunningTest()){
                access_token='success';
                returnresponse='{  "data": {    "access": "full_access",    "author": "SYM_SVC",    "author_description": "Symphony Service Account",    "class_code": "DOC",    "class_description": "Document",    "content_type": "D",    "create_date": "2023-12-16T14:45:54Z",    "create_profile_date": "2023-12-16T14:45:54Z",    "database": "MB_SB",    "declared": "",    "default_security": "public",    "document_number": "23",    "edit_date": "2023-12-16T14:45:54Z",    "edit_profile_date": "2024-01-17T17:48:48Z",    "extension": "txt",    "file_create_date": "2023-12-16T14:45:54Z",    "file_edit_date": "2023-12-16T14:45:54Z",    "id": "MB_SB!23.1",    "in_use": "",    "indexable": "",    "is_checked_out": "",    "is_declared": "",    "is_external": "",    "is_external_as_normal": "",    "is_hipaa": "",    "is_in_use": "",    "iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=23&&ver=1",    "last_user": "SYM_SVC",    "last_user_description": "Symphony Service Account",    "location": "23.1",    "name": "Updated Name Field",    "operator": "SYM_SVC",    "operator_description": "Symphony Service Account",    "retain_days": "365",    "size": "4",    "system_edit_date": "2023-12-16T14:45:54Z",    "type": "ANSI",    "type_description": "Windows Ansi Text",    "version": "1",    "workspace_id": "MB_SB!5",    "workspace_name": "iManage Cloud Monitor",    "wstype": "document"  },  "warnings": []}';
                
            } 
           
        
            cmpAPiMngDocMoveWrraper objResponse = (cmpAPiMngDocMoveWrraper) JSON.deserialize(returnresponse,cmpAPiMngDocMoveWrraper.Class);
            if (objResponse.data!=null ) {
                iManage_Documents__c imngDocuments = new iManage_Documents__c();
            	imngDocuments.database__c=objResponse.data.database;	//MB_SB
            	imngDocuments.document_number__c=objResponse.data.document_number;	//8
				imngDocuments.version__c=objResponse.data.version;	//1
				imngDocuments.name__c=objResponse.data.name;	//Michael-Best_thumbnail_MB-LOGO-1024x306
				imngDocuments.author__c=objResponse.data.author;	//SYM_SVC
				imngDocuments.operator__c=objResponse.data.operator;	//SYM_SVC
				imngDocuments.type__c=objResponse.data.type;	//PNG
				imngDocuments.class_code__c=objResponse.data.class_code;	//DOC
				imngDocuments.edit_date__c=objResponse.data.edit_date;	//2023-12-13T15:37:40Z
				imngDocuments.system_edit_date__c=objResponse.data.system_edit_date;	//2023-12-13T15:37:40Z
				imngDocuments.create_date__c=objResponse.data.create_date;	//2023-12-13T15:37:40Z
				imngDocuments.create_profile_date__c=objResponse.data.create_profile_date;	//2023-12-13T15:37:40Z
				imngDocuments.retain_days__c=objResponse.data.retain_days;	//365
				imngDocuments.size__c=objResponse.data.size;	//40732
				imngDocuments.is_declared__c=objResponse.data.is_declared;
            	imngDocuments.declared__c=objResponse.data.declared;
				imngDocuments.default_security__c=objResponse.data.default_security;	//public
				imngDocuments.last_user__c=objResponse.data.last_user;	//SYM_SVC
				imngDocuments.is_in_use__c=objResponse.data.is_in_use;
				imngDocuments.is_checked_out__c=objResponse.data.is_checked_out;
				imngDocuments.author_description__c=objResponse.data.author_description;	//Symphony Service Account
				imngDocuments.operator_description__c=objResponse.data.operator_description;	//Symphony Service Account
				imngDocuments.type_description__c=objResponse.data.type_description;	//PNG
				imngDocuments.class_description__c=objResponse.data.class_description;	//Document
				imngDocuments.last_user_description__c=objResponse.data.last_user_description;	//Symphony Service Account
				imngDocuments.extension__c=objResponse.data.extension;	//png
				imngDocuments.content_type__c=objResponse.data.content_type;	//D
				imngDocuments.edit_profile_date__c=objResponse.data.edit_profile_date;	//2023-12-13T15:37:40Z
				imngDocuments.is_external__c=objResponse.data.is_external;
				imngDocuments.is_external_as_normal__c=objResponse.data.is_external_as_normal;
				imngDocuments.file_create_date__c=objResponse.data.file_create_date;	//2023-12-13T15:37:40Z
				imngDocuments.file_edit_date__c=objResponse.data.file_edit_date;	//2023-12-13T15:37:40Z
				imngDocuments.is_hipaa__c=objResponse.data.is_hipaa;
				imngDocuments.workspace_name__c=objResponse.data.workspace_name;	//OCR Rendition Folder
				imngDocuments.id__c=objResponse.data.id;	//MB_SB!8.1
				imngDocuments.in_use__c=objResponse.data.in_use;
				imngDocuments.indexable__c=objResponse.data.indexable;
				imngDocuments.wstype__c=objResponse.data.wstype;	//document
				imngDocuments.iwl__c=objResponse.data.iwl;	//iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=8&&ver=1
				imngDocuments.workspace_id__c=objResponse.data.workspace_id;	//MB_SB!1
            	imngDocuments.iManage_Folders__c=iManageFoldersId;
                imngDocuments.Id=iManageDocId;
                ObjDocuments.add(imngDocuments);
            }
            if(ObjDocuments.size()>0)
                update ObjDocuments;
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API9','Pending',data,iManageDocId); 
            
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API9','Pending',data,iManageDocId);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      	return access_token;
      
    }
}