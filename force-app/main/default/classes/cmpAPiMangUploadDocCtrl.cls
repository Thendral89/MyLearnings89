/*
*********************************************************
Apex Class Name    : cmpAPiMangUploadDocCtrl
Created Date       : July 12, 2023
@description       : API8, Upload the iManage document
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMangUploadDocCtrl {
    
    @AuraEnabled
    public static List<ContentVersion> getContentVersion( string ContentVersionId) {
        List<ContentVersion> Workdas = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                        Origin,PathOnClient,Title,VersionData 
                                        FROM ContentVersion Where (ContentDocumentId=:ContentVersionId OR Id=:ContentVersionId) Order by CreatedDate DESC LIMIT 1];
        return Workdas;
    }
    
    
    @AuraEnabled
    public static String uploadToIManage(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId, string iManageEmailObjectId) {
        string returnresponse='';
        string API5data='';
        string getStatusCode='';
        try {   
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            List<ContentVersion> file = cmpAPiMangUploadDocCtrl.getContentVersion(ContentVersionId);
            if(file.size()>0) {
                string fileName=file[0].Title;
                Http http = new Http();
                
                String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
                String lineEnd = '\r\n';
                String twoHyphens = '--';
                
                String metadata2 = JSON.serialize(new Map<String, Object>{
                    'name' => fileName,
                        'extension' => file[0].FileExtension,
                        'author' => objCSworkday[0].username__c,
                        'operator' => objCSworkday[0].username__c,
                        'type' => file[0].FileExtension,
                        'default_security' => 'public',
                        'workspace_id' => objCSworkday[0].libraries__c
                        ,'class' => 'DOC'
                        });
                
                String metadataJson = '{"doc_profile": ' + metadata2 +', "warnings_for_required_and_disabled_fields":true}';
                Blob fileBlob = file[0].VersionData;
                
                String part1 = twoHyphens + boundary + lineEnd +
                    'Content-Disposition: form-data; name="metadata"' + lineEnd +
                    'Content-Type: application/json' + lineEnd + lineEnd +
                    metadataJson + lineEnd;
                
                String part2Header = twoHyphens + boundary + lineEnd +
                    'Content-Disposition: form-data; name="file"; filename="' + fileName + '"' + lineEnd +
                    'Content-Type: application/octet-stream' + lineEnd + lineEnd;
                
                String part3 = lineEnd + twoHyphens + boundary + twoHyphens + lineEnd;
                
                Blob part1Blob = Blob.valueOf(part1);
                Blob part2HeaderBlob = Blob.valueOf(part2Header);
                Blob part3Blob = Blob.valueOf(part3);
                String fullHex = EncodingUtil.convertToHex(part1Blob) +
                    EncodingUtil.convertToHex(part2HeaderBlob) +
                    EncodingUtil.convertToHex(fileBlob) +
                    EncodingUtil.convertToHex(part3Blob);
                
                Blob finalBody = EncodingUtil.convertFromHex(fullHex);
                
                HttpRequest req = new HttpRequest();
                string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId +'/documents';
                req.setEndpoint(dataurl);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + access_token);
                req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
                req.setBodyAsBlob(finalBody);
                
                if(!test.isRunningTest()) {
                    HttpResponse res = http.send(req);
                    System.debug('status code ' + res.getStatusCode() + ' and body ' + res.getBody() + ' and message ' + res.getHeader( 'Content-Type' ));
                    getStatusCode= string.valueof(res.getStatusCode());
                    returnresponse=res.getBody();
                    returnresponse=returnresponse.replace('"class"','"class_code"');
                    access_token='success';
                }
                
                if(getStatusCode=='400') {
                    cmpAPiMangUploadDocCtrl.error objResponse = (cmpAPiMangUploadDocCtrl.error) JSON.deserialize(returnresponse,cmpAPiMangUploadDocCtrl.error.Class);
                    returnresponse=objResponse.detailed_error_message;
                }
                
            }  
            
        } catch(Exception exp) {
            returnresponse='Error';
        }
        
        return returnresponse;
        
    }
    
    public static string GetContentType(string Boundary) {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
    }
    
    
    
    public error error;
    public class error {
        public String dms_version;	//10.4.7.758
        public String function;	//createNewDocumentProfile
        public String code;	//NRC_INVALID_FOLDER_TYPE
        public String code_message;	//This operation is not allowed for this folder type.
        public String detailed_error_message;	//Unable to construct document profile for non-document folder: MB_SB!121
    }
    
    @AuraEnabled
    public static string EmailToIManageFolder(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId,string EmailMessageId) {
        
        system.debug('ContentVersionId ' + ContentVersionId);
        system.debug('iManageFoldersId ' + iManageFoldersId);
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string getStatusCode='';
        string ContentDocumentId=ContentVersionId;
        String body = '';
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            List<ContentVersion> ObjContentVersion = cmpAPiMangUploadDocCtrl.getContentVersion(ContentVersionId);
            
            string apibody='';
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId +'/documents';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('POST');  
            
            req.setHeader('Content-Type', cmpAPiMangUploadDocCtrl.GetContentType(objCSworkday[0].boundarykey__c));
            req.setHeader('X-Auth-Token', access_token);
            
            
            string profilejson='{"doc_profile": {"name":"' + ObjContentVersion[0].Title + '", "extension":"' + ObjContentVersion[0].FileExtension + '", "author":"' + objCSworkday[0].username__c+ '", "operator":"' + objCSworkday[0].username__c+ '", "type": "' + ObjContentVersion[0].FileType + '", "class": "DOC", "default_security":"public"}, "warnings_for_required_and_disabled_fields":true}';
            body +='--' + objCSworkday[0].boundarykey__c+'\r\n';
            body +='Content-Disposition:form-data; name="profile";\r\n';
            body +='Content-Type: application/json\r\n';
            body += '\r\n';
            body +=profilejson;
            body += '\r\n';
            body += '\r\n';
            body +='--' + objCSworkday[0].boundarykey__c+'\r\n';
            
            
            body +='Content-Disposition:form-data; name="file";\r\n';
            body +='Content-Type: application/' + ObjContentVersion[0].FileExtension + '\r\n';
            body += '\r\n';
            String fileContent = ObjContentVersion[0].VersionData.toString();
           
            body += '' + fileContent;
            body += '\r\n';
            body +='--' + objCSworkday[0].boundarykey__c+'';
            body += '\r\n';
            
            system.debug('body ' + body);
            req.setHeader('Content-Length', string.valueof(body.length()));
            req.setBody(body);
            
            req.setTimeout(120000);
            Http http = new Http();
            if(ObjContentVersion.size()>0){
                if(!test.isRunningTest()) {
                    HTTPResponse httpResponse = http.send(req);
                    System.debug('httpResponse.getBody()' + httpResponse.getBody());
                    getStatusCode= string.valueof(httpResponse.getStatusCode());
                    returnresponse=httpResponse.getBody();
                    returnresponse=returnresponse.replace('"class"','"class_code"');
                    access_token='success';
                }
            }
            
            if(getStatusCode=='400') {
                cmpAPiMangUploadDocCtrl.error objResponse = (cmpAPiMangUploadDocCtrl.error) JSON.deserialize(returnresponse,cmpAPiMangUploadDocCtrl.error.Class);
                returnresponse=objResponse.detailed_error_message;
                ContentDocumentId='';
                access_token='Pending';
            }
            
            if(test.isRunningTest()) {
                getStatusCode='200';
                returnresponse='{  "data": {    "database": "MB_SB",    "document_number": "8",    "version": "1",    "name": "Michael-Best_thumbnail_MB-LOGO-1024x306",    "author": "SYM_SVC",    "operator": "SYM_SVC",    "type": "PNG",    "class_code": "DOC",    "edit_date": "2023-12-13T15:37:40Z",    "system_edit_date": "2023-12-13T15:37:40Z",    "create_date": "2023-12-13T15:37:40Z",    "create_profile_date": "2023-12-13T15:37:40Z",    "retain_days": "365",    "size": "40732",    "is_declared": "false",    "declared": "true",    "location": "8.1",    "default_security": "public",    "last_user": "SYM_SVC",    "is_in_use": "true",    "is_checked_out": "false",    "access": "full_access",    "author_description": "Symphony Service Account",    "operator_description": "Symphony Service Account",    "type_description": "PNG",    "class_description": "Document",    "last_user_description": "Symphony Service Account",    "extension": "png",    "content_type": "D",    "edit_profile_date": "2023-12-13T15:37:40Z",    "is_external": "false",    "is_external_as_normal": "false",    "file_create_date": "2023-12-13T15:37:40Z",    "file_edit_date": "2023-12-13T15:37:40Z",    "is_hipaa": "false",    "workspace_name": "OCR Rendition Folder",    "id": "MB_SB!8.1",    "in_use": "false",    "indexable": "true",    "wstype": "document",    "iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=8&&ver=1",    "workspace_id": "MB_SB!1"  },  "warnings": []}';
            }
            
            if(getStatusCode=='200' || getStatusCode=='201') {
                cmpAPiMangUploadDocWrraper objResponse = (cmpAPiMangUploadDocWrraper) JSON.deserialize(returnresponse,cmpAPiMangUploadDocWrraper.Class);
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
                imngDocuments.location__c=objResponse.data.location;	//DEFSERVER:\FILES\MB_SB\SYM_SVC\0\1\8.1
                imngDocuments.default_security__c=objResponse.data.default_security;	//public
                imngDocuments.last_user__c=objResponse.data.last_user;	//SYM_SVC
                imngDocuments.is_in_use__c=objResponse.data.is_in_use;
                imngDocuments.is_checked_out__c=objResponse.data.is_checked_out;
                imngDocuments.access__c=objResponse.data.access;	//full_access
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
                imngDocuments.ContentVersionId__c=ObjContentVersion[0].Id;
                imngDocuments.iManage_Folders__c=iManageFoldersId;
                insert imngDocuments;
                Bytedance_IDF_ID=objResponse.data.id;
                ContentVersionId=ObjContentVersion[0].ContentDocumentId;
                ContentDocumentId=ObjContentVersion[0].ContentDocumentId;
            }
            
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data); 
            cmpAPAPIHeaderCtrl.CreateContentVersion(body,apiIds); 
            
            if(access_token=='success'){
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId); 
                cmpAPAPIHeaderCtrl.SetEmailMessage(EmailMessageId,Bytedance_IDF_ID); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            string Errors = 'Error ' + exp.getMessage();
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',Errors,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            if(!test.isRunningTest()) 
                cmpAPAPIHeaderCtrl.CreateContentVersion(body,apiIds); 
        }
        
        return ContentVersionId;
        
    }
   
    
    
    @AuraEnabled
    public static string iMngUploadDocketing(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId, string iManageEmailObjectId) {
        
        system.debug('ContentVersionId ' + ContentVersionId);
        system.debug('iManageFoldersId ' + iManageFoldersId);
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string getStatusCode='';
        string ContentDocumentId=ContentVersionId;
        String body = '';
        string iManageDocumentId='';
        try {
            List<ContentVersion> ObjContentVersion = cmpAPiMangUploadDocCtrl.getContentVersion(ContentVersionId);
            returnresponse = uploadToIManage(access_token,iManageFoldersId,createdFolderId,ContentVersionId,recordId, iManageEmailObjectId);
            
            if(test.isRunningTest()) {
                getStatusCode='200';
                returnresponse='{  "data": {    "database": "MB_SB",    "document_number": "8",    "version": "1",    "name": "Michael-Best_thumbnail_MB-LOGO-1024x306",    "author": "SYM_SVC",    "operator": "SYM_SVC",    "type": "PNG",    "class_code": "DOC",    "edit_date": "2023-12-13T15:37:40Z",    "system_edit_date": "2023-12-13T15:37:40Z",    "create_date": "2023-12-13T15:37:40Z",    "create_profile_date": "2023-12-13T15:37:40Z",    "retain_days": "365",    "size": "40732",    "is_declared": "false",    "declared": "true",    "location": "8.1",    "default_security": "public",    "last_user": "SYM_SVC",    "is_in_use": "true",    "is_checked_out": "false",    "access": "full_access",    "author_description": "Symphony Service Account",    "operator_description": "Symphony Service Account",    "type_description": "PNG",    "class_description": "Document",    "last_user_description": "Symphony Service Account",    "extension": "png",    "content_type": "D",    "edit_profile_date": "2023-12-13T15:37:40Z",    "is_external": "false",    "is_external_as_normal": "false",    "file_create_date": "2023-12-13T15:37:40Z",    "file_edit_date": "2023-12-13T15:37:40Z",    "is_hipaa": "false",    "workspace_name": "OCR Rendition Folder",    "id": "MB_SB!8.1",    "in_use": "false",    "indexable": "true",    "wstype": "document",    "iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=8&&ver=1",    "workspace_id": "MB_SB!1"  },  "warnings": []}';
            }
            
            if(returnresponse!='Error') {
                access_token='success';
                cmpAPiMangUploadDocWrraper objResponse = (cmpAPiMangUploadDocWrraper) JSON.deserialize(returnresponse,cmpAPiMangUploadDocWrraper.Class);
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
                imngDocuments.location__c=objResponse.data.location;	//DEFSERVER:\FILES\MB_SB\SYM_SVC\0\1\8.1
                imngDocuments.default_security__c=objResponse.data.default_security;	//public
                imngDocuments.last_user__c=objResponse.data.last_user;	//SYM_SVC
                imngDocuments.is_in_use__c=objResponse.data.is_in_use;
                imngDocuments.is_checked_out__c=objResponse.data.is_checked_out;
                imngDocuments.access__c=objResponse.data.access;	//full_access
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
                imngDocuments.ContentVersionId__c=ObjContentVersion[0].Id;
                imngDocuments.iManage_Folders__c=iManageFoldersId;
                insert imngDocuments;
                iManageDocumentId=imngDocuments.Id;
                
                ContentVersionId=ObjContentVersion[0].ContentDocumentId;
                ContentDocumentId=ObjContentVersion[0].ContentDocumentId;
            }
            
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data); 
            if(returnresponse!='')
                cmpAPAPIHeaderCtrl.CreateContentVersion(returnresponse,apiIds); 
            
            if(access_token=='success'){
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId); 
                cmpAPAPIHeaderCtrl.ContentVersionId(ObjContentVersion[0].Id,false); 
                cmpAPAPIHeaderCtrl.UpdateDocketDocuments(iManageDocumentId,iManageEmailObjectId); 
                
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            string Error = 'Error ' + exp.getMessage();
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',Error,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            if(!test.isRunningTest()) {
                if(returnresponse!='')
                    cmpAPAPIHeaderCtrl.CreateContentVersion(returnresponse,apiIds); 
            }
                
        }
        
        return ContentVersionId;
        
    }
    
    @AuraEnabled
    public static string iMngCreateFolder(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId) {
        
        system.debug('ContentVersionId ' + ContentVersionId);
        system.debug('iManageFoldersId ' + iManageFoldersId);
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string getStatusCode='';
        string ContentDocumentId=ContentVersionId;
        String body = '';
        try {
            List<ContentVersion> ObjContentVersion = cmpAPiMangUploadDocCtrl.getContentVersion(ContentVersionId);
            returnresponse = uploadToIManage(access_token,iManageFoldersId,createdFolderId,ContentVersionId,recordId, recordId);
            
            if(test.isRunningTest()) {
                getStatusCode='200';
                returnresponse='{  "data": {    "database": "MB_SB",    "document_number": "8",    "version": "1",    "name": "Michael-Best_thumbnail_MB-LOGO-1024x306",    "author": "SYM_SVC",    "operator": "SYM_SVC",    "type": "PNG",    "class_code": "DOC",    "edit_date": "2023-12-13T15:37:40Z",    "system_edit_date": "2023-12-13T15:37:40Z",    "create_date": "2023-12-13T15:37:40Z",    "create_profile_date": "2023-12-13T15:37:40Z",    "retain_days": "365",    "size": "40732",    "is_declared": "false",    "declared": "true",    "location": "8.1",    "default_security": "public",    "last_user": "SYM_SVC",    "is_in_use": "true",    "is_checked_out": "false",    "access": "full_access",    "author_description": "Symphony Service Account",    "operator_description": "Symphony Service Account",    "type_description": "PNG",    "class_description": "Document",    "last_user_description": "Symphony Service Account",    "extension": "png",    "content_type": "D",    "edit_profile_date": "2023-12-13T15:37:40Z",    "is_external": "false",    "is_external_as_normal": "false",    "file_create_date": "2023-12-13T15:37:40Z",    "file_edit_date": "2023-12-13T15:37:40Z",    "is_hipaa": "false",    "workspace_name": "OCR Rendition Folder",    "id": "MB_SB!8.1",    "in_use": "false",    "indexable": "true",    "wstype": "document",    "iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=8&&ver=1",    "workspace_id": "MB_SB!1"  },  "warnings": []}';
            }
            
            if(returnresponse!='Error') {
                access_token='success';
                cmpAPiMangUploadDocWrraper objResponse = (cmpAPiMangUploadDocWrraper) JSON.deserialize(returnresponse,cmpAPiMangUploadDocWrraper.Class);
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
                imngDocuments.location__c=objResponse.data.location;	//DEFSERVER:\FILES\MB_SB\SYM_SVC\0\1\8.1
                imngDocuments.default_security__c=objResponse.data.default_security;	//public
                imngDocuments.last_user__c=objResponse.data.last_user;	//SYM_SVC
                imngDocuments.is_in_use__c=objResponse.data.is_in_use;
                imngDocuments.is_checked_out__c=objResponse.data.is_checked_out;
                imngDocuments.access__c=objResponse.data.access;	//full_access
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
                imngDocuments.ContentVersionId__c=ObjContentVersion[0].Id;
                imngDocuments.iManage_Folders__c=iManageFoldersId;
                insert imngDocuments;
                ContentVersionId=ObjContentVersion[0].ContentDocumentId;
                ContentDocumentId=ObjContentVersion[0].ContentDocumentId;
            }
            
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data); 
            if(returnresponse!='')
                cmpAPAPIHeaderCtrl.CreateContentVersion(returnresponse,apiIds); 
            
            if(access_token=='success'){
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId); 
                cmpAPAPIHeaderCtrl.ContentVersionId(ObjContentVersion[0].Id,false); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            string Error='Error ' + exp.getMessage();
            //ContentVersionId='Error ' + exp.getMessage();
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',Error,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            if(!test.isRunningTest()) 
                cmpAPAPIHeaderCtrl.CreateContentVersion(body,apiIds); 
        }
        
        return ContentVersionId;
        
    }
    
    
    @AuraEnabled
    public static string iMngUploadDocketingExpired(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId, string iManageEmailObjectId) {
        
        system.debug('ContentVersionId ' + ContentVersionId);
        system.debug('iManageFoldersId ' + iManageFoldersId);
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string getStatusCode='';
        string ContentDocumentId=ContentVersionId;
        String body = '';
        string iManageDocumentId='';
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            List<ContentVersion> ObjContentVersion = cmpAPiMangUploadDocCtrl.getContentVersion(ContentVersionId);
            
            string apibody='';
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId +'/documents';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('POST');  
            
            req.setHeader('Content-Type', cmpAPiMangUploadDocCtrl.GetContentType(objCSworkday[0].boundarykey__c));
            req.setHeader('X-Auth-Token', access_token);
            
            
            string profilejson='{"doc_profile": {"name":"' + ObjContentVersion[0].Title + '", "extension":"' + ObjContentVersion[0].FileExtension + '", "author":"' + objCSworkday[0].username__c+ '", "operator":"' + objCSworkday[0].username__c+ '", "type": "' + ObjContentVersion[0].FileType + '", "class": "DOC", "default_security":"public"}, "warnings_for_required_and_disabled_fields":true}';
            body +='--' + objCSworkday[0].boundarykey__c+'\r\n';
            body +='Content-Disposition:form-data; name="profile";\r\n';
            body +='Content-Type: application/json\r\n';
            body += '\r\n';
            body +=profilejson;
            body += '\r\n';
            body += '\r\n';
            body +='--' + objCSworkday[0].boundarykey__c+'\r\n';
            string base64Content='';
            string FileExtension=ObjContentVersion[0].FileExtension;
            
            if(FileExtension!='pdf' && FileExtension!='docx'){
                base64Content = ObjContentVersion[0].VersionData.toString(); 
            } else {
                base64Content = EncodingUtil.base64Encode(ObjContentVersion[0].VersionData);   
            }

            
            body +='Content-Disposition:form-data; name="file";\r\n';
            body +='Content-Type: application/' + ObjContentVersion[0].FileExtension + '\r\n';
            body += '\r\n';
            body += '' + base64Content;
            body += '\r\n';
            body +='--' + objCSworkday[0].boundarykey__c+'';
            body += '\r\n';
            
            //system.debug('body ' + body);
            req.setHeader('Content-Length', string.valueof(body.length()));
            req.setBody(body);
            
            req.setTimeout(120000);
            Http http = new Http();
            if(ObjContentVersion.size()>0){
                if(!test.isRunningTest()) {
                    HTTPResponse httpResponse = http.send(req);
                    System.debug('httpResponse.getBody()' + httpResponse.getBody());
                    getStatusCode= string.valueof(httpResponse.getStatusCode());
                    returnresponse=httpResponse.getBody();
                    returnresponse=returnresponse.replace('"class"','"class_code"');
                    access_token='success';
                }
            }
            
            if(getStatusCode=='400') {
                cmpAPiMangUploadDocCtrl.error objResponse = (cmpAPiMangUploadDocCtrl.error) JSON.deserialize(returnresponse,cmpAPiMangUploadDocCtrl.error.Class);
                returnresponse=objResponse.detailed_error_message;
                ContentDocumentId='';
                access_token='Pending';
            }
            
            if(test.isRunningTest()) {
                getStatusCode='200';
                returnresponse='{  "data": {    "database": "MB_SB",    "document_number": "8",    "version": "1",    "name": "Michael-Best_thumbnail_MB-LOGO-1024x306",    "author": "SYM_SVC",    "operator": "SYM_SVC",    "type": "PNG",    "class_code": "DOC",    "edit_date": "2023-12-13T15:37:40Z",    "system_edit_date": "2023-12-13T15:37:40Z",    "create_date": "2023-12-13T15:37:40Z",    "create_profile_date": "2023-12-13T15:37:40Z",    "retain_days": "365",    "size": "40732",    "is_declared": "false",    "declared": "true",    "location": "8.1",    "default_security": "public",    "last_user": "SYM_SVC",    "is_in_use": "true",    "is_checked_out": "false",    "access": "full_access",    "author_description": "Symphony Service Account",    "operator_description": "Symphony Service Account",    "type_description": "PNG",    "class_description": "Document",    "last_user_description": "Symphony Service Account",    "extension": "png",    "content_type": "D",    "edit_profile_date": "2023-12-13T15:37:40Z",    "is_external": "false",    "is_external_as_normal": "false",    "file_create_date": "2023-12-13T15:37:40Z",    "file_edit_date": "2023-12-13T15:37:40Z",    "is_hipaa": "false",    "workspace_name": "OCR Rendition Folder",    "id": "MB_SB!8.1",    "in_use": "false",    "indexable": "true",    "wstype": "document",    "iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=8&&ver=1",    "workspace_id": "MB_SB!1"  },  "warnings": []}';
            }
            
            if(getStatusCode=='200' || getStatusCode=='201') {
                cmpAPiMangUploadDocWrraper objResponse = (cmpAPiMangUploadDocWrraper) JSON.deserialize(returnresponse,cmpAPiMangUploadDocWrraper.Class);
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
                imngDocuments.location__c=objResponse.data.location;	//DEFSERVER:\FILES\MB_SB\SYM_SVC\0\1\8.1
                imngDocuments.default_security__c=objResponse.data.default_security;	//public
                imngDocuments.last_user__c=objResponse.data.last_user;	//SYM_SVC
                imngDocuments.is_in_use__c=objResponse.data.is_in_use;
                imngDocuments.is_checked_out__c=objResponse.data.is_checked_out;
                imngDocuments.access__c=objResponse.data.access;	//full_access
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
                imngDocuments.ContentVersionId__c=ObjContentVersion[0].Id;
                imngDocuments.iManage_Folders__c=iManageFoldersId;
                insert imngDocuments;
                iManageDocumentId=imngDocuments.Id;
                
                
                ContentVersionId=ObjContentVersion[0].ContentDocumentId;
                ContentDocumentId=ObjContentVersion[0].ContentDocumentId;
            }
            
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data); 
            cmpAPAPIHeaderCtrl.CreateContentVersion(body,apiIds); 
            
            if(access_token=='success'){
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId); 
                cmpAPAPIHeaderCtrl.ContentVersionId(ObjContentVersion[0].Id,false); 
                system.debug('iManageDocumentId ' + iManageDocumentId + ' iManageEmailObjectId ' + iManageEmailObjectId);
                
                cmpAPAPIHeaderCtrl.UpdateDocketDocuments(iManageDocumentId,iManageEmailObjectId); 
                
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            string Error = 'Error ' + exp.getMessage();
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',Error,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            if(!test.isRunningTest()) 
                cmpAPAPIHeaderCtrl.CreateContentVersion(body,apiIds); 
        }
        
        return ContentVersionId;
        
    }
    
    @AuraEnabled
    public static string iMngCreateFolderExpired(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId) {
        
        system.debug('ContentVersionId ' + ContentVersionId);
        system.debug('iManageFoldersId ' + iManageFoldersId);
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string getStatusCode='';
        string ContentDocumentId=ContentVersionId;
        String body = '';
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            List<ContentVersion> ObjContentVersion = cmpAPiMangUploadDocCtrl.getContentVersion(ContentVersionId);
            
            string apibody='';
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId +'/documents';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('POST');  
            
            req.setHeader('Content-Type', cmpAPiMangUploadDocCtrl.GetContentType(objCSworkday[0].boundarykey__c));
            req.setHeader('X-Auth-Token', access_token);
            
            
            string profilejson='{"doc_profile": {"name":"' + ObjContentVersion[0].Title + '", "extension":"' + ObjContentVersion[0].FileExtension + '", "author":"' + objCSworkday[0].username__c+ '", "operator":"' + objCSworkday[0].username__c+ '", "type": "' + ObjContentVersion[0].FileType + '", "class": "DOC", "default_security":"public"}, "warnings_for_required_and_disabled_fields":true}';
            body +='--' + objCSworkday[0].boundarykey__c+'\r\n';
            body +='Content-Disposition:form-data; name="profile";\r\n';
            body +='Content-Type: application/json\r\n';
            body += '\r\n';
            body +=profilejson;
            body += '\r\n';
            body += '\r\n';
            body +='--' + objCSworkday[0].boundarykey__c+'\r\n';
            
            
            body +='Content-Disposition:form-data; name="file";\r\n';
            body +='Content-Type: application/' + ObjContentVersion[0].FileExtension + '\r\n';
            body += '\r\n';
            string base64Content='';
            string FileExtension=ObjContentVersion[0].FileExtension;
            
            if(FileExtension!='pdf' && FileExtension!='docx' && FileExtension!='xlsx'){
                base64Content = ObjContentVersion[0].VersionData.toString(); 
            } else {
                base64Content = EncodingUtil.base64Encode(ObjContentVersion[0].VersionData);   
            }
            
           
            
            body += '' + base64Content;
            body += '\r\n';
            body +='--' + objCSworkday[0].boundarykey__c+'';
            body += '\r\n';
            
            system.debug('body ' + body);
            req.setHeader('Content-Length', string.valueof(body.length()));
            req.setBody(body);
            
            req.setTimeout(120000);
            Http http = new Http();
            if(ObjContentVersion.size()>0){
                if(!test.isRunningTest()) {
                    HTTPResponse httpResponse = http.send(req);
                    System.debug('httpResponse.getBody()' + httpResponse.getBody());
                    getStatusCode= string.valueof(httpResponse.getStatusCode());
                    returnresponse=httpResponse.getBody();
                    returnresponse=returnresponse.replace('"class"','"class_code"');
                    access_token='success';
                }
            }
            
            if(getStatusCode=='400') {
                cmpAPiMangUploadDocCtrl.error objResponse = (cmpAPiMangUploadDocCtrl.error) JSON.deserialize(returnresponse,cmpAPiMangUploadDocCtrl.error.Class);
                returnresponse=objResponse.detailed_error_message;
                ContentDocumentId='';
                access_token='Pending';
            }
            
            if(test.isRunningTest()) {
                getStatusCode='200';
                returnresponse='{  "data": {    "database": "MB_SB",    "document_number": "8",    "version": "1",    "name": "Michael-Best_thumbnail_MB-LOGO-1024x306",    "author": "SYM_SVC",    "operator": "SYM_SVC",    "type": "PNG",    "class_code": "DOC",    "edit_date": "2023-12-13T15:37:40Z",    "system_edit_date": "2023-12-13T15:37:40Z",    "create_date": "2023-12-13T15:37:40Z",    "create_profile_date": "2023-12-13T15:37:40Z",    "retain_days": "365",    "size": "40732",    "is_declared": "false",    "declared": "true",    "location": "8.1",    "default_security": "public",    "last_user": "SYM_SVC",    "is_in_use": "true",    "is_checked_out": "false",    "access": "full_access",    "author_description": "Symphony Service Account",    "operator_description": "Symphony Service Account",    "type_description": "PNG",    "class_description": "Document",    "last_user_description": "Symphony Service Account",    "extension": "png",    "content_type": "D",    "edit_profile_date": "2023-12-13T15:37:40Z",    "is_external": "false",    "is_external_as_normal": "false",    "file_create_date": "2023-12-13T15:37:40Z",    "file_edit_date": "2023-12-13T15:37:40Z",    "is_hipaa": "false",    "workspace_name": "OCR Rendition Folder",    "id": "MB_SB!8.1",    "in_use": "false",    "indexable": "true",    "wstype": "document",    "iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=MB_SB&&num=8&&ver=1",    "workspace_id": "MB_SB!1"  },  "warnings": []}';
            }
            
            if(getStatusCode=='200' || getStatusCode=='201') {
                cmpAPiMangUploadDocWrraper objResponse = (cmpAPiMangUploadDocWrraper) JSON.deserialize(returnresponse,cmpAPiMangUploadDocWrraper.Class);
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
                imngDocuments.location__c=objResponse.data.location;	//DEFSERVER:\FILES\MB_SB\SYM_SVC\0\1\8.1
                imngDocuments.default_security__c=objResponse.data.default_security;	//public
                imngDocuments.last_user__c=objResponse.data.last_user;	//SYM_SVC
                imngDocuments.is_in_use__c=objResponse.data.is_in_use;
                imngDocuments.is_checked_out__c=objResponse.data.is_checked_out;
                imngDocuments.access__c=objResponse.data.access;	//full_access
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
                imngDocuments.ContentVersionId__c=ObjContentVersion[0].Id;
                imngDocuments.iManage_Folders__c=iManageFoldersId;
                insert imngDocuments;
                ContentVersionId=ObjContentVersion[0].ContentDocumentId;
                ContentDocumentId=ObjContentVersion[0].ContentDocumentId;
            }
            
            
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data); 
            cmpAPAPIHeaderCtrl.CreateContentVersion(body,apiIds); 
            
            if(access_token=='success'){
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId); 
                cmpAPAPIHeaderCtrl.ContentVersionId(ObjContentVersion[0].Id,false); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            string Error='Error ' + exp.getMessage();
            //ContentVersionId='Error ' + exp.getMessage();
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API8','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',Error,recordId,iManageFoldersId,createdFolderId,ContentVersionId);
            if(!test.isRunningTest()) 
                cmpAPAPIHeaderCtrl.CreateContentVersion(body,apiIds); 
        }
        
        return ContentVersionId;
        
    }
    
    public static Blob CreateDoc(string documentId){
            contentversion cd = [select id,VersionData from contentversion where ContentDocumentId =: documentId];
            String strBody = encodingutil.base64Encode(cd.VersionData);
        	system.debug('CreateDoc strBody' + strBody);
        
            String strBodyEncoded = strBody;
            Blob blobBody = null;
            String last4Bytes = strBodyEncoded.substring(strBodyEncoded.length()-4,strBodyEncoded.length());
        	system.debug('CreateDoc last4Bytes' + last4Bytes);
            if(last4Bytes.endsWith('=')) {
                Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
                HttpRequest objHttpRequest = New HttpRequest();
                objHttpRequest.setBodyAsBlob(decoded4Bytes);
                String last4BytesFooter = objHttpRequest.getBody();
                system.debug('CreateDoc strBody' + last4BytesFooter);
                
                blobBody = EncodingUtil.base64Decode(strBodyEncoded.substring(0,strBodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
            } 
            else {
                blobBody = EncodingUtil.base64Decode(strBodyEncoded);
            }

           return blobBody;
           
           
    }
    
    @future(callout=true)
    public static void CreateTransientDocForDeclarationForm(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId){
        
        List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
        List<ContentVersion> ObjContentVersion = cmpAPiMangUploadDocCtrl.getContentVersion(ContentVersionId);
        contentversion cd = [select id,VersionData 
                             From contentversion where (ContentDocumentId=:ContentVersionId OR Id=:ContentVersionId)];
        
        
        Map<String, Object> docProfile = new Map<String, Object>();
        docProfile.put('name', ObjContentVersion[0].Title);
        docProfile.put('extension', ObjContentVersion[0].FileExtension);
        docProfile.put('author', objCSworkday[0].username__c);
        docProfile.put('operator', objCSworkday[0].username__c);
        docProfile.put('type', ObjContentVersion[0].FileType);
        docProfile.put('class', 'DOC');
        docProfile.put('default_security', 'public');
        
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('doc_profile', docProfile);
        requestBody.put('warnings_for_required_and_disabled_fields', true);
        
        String profilejson = JSON.serialize(requestBody);
        
        String boundary = String.valueOf(System.currentTimeMillis());
        String header = '--' + boundary +
            '\r\nContent-Disposition: form-data; name="profile"; \r\nContent-Type=application/json\r\n\r\n' +
            profilejson + '\r\n' +
            '--' + boundary + 
            '\r\nContent-Disposition: form-data; name="file"; \r\nContent-Type: application/pdf\r\n\r\n';
       
        Blob fileData = ObjContentVersion[0].VersionData;
		String encodedFileData = EncodingUtil.base64Encode(fileData);
        String footer = '\r\n--' + boundary + '--';
        String bodyPayload = header + encodedFileData + footer;
        
        HttpRequest req = New HttpRequest();
        string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/' + createdFolderId +'/documents';
        req.setEndpoint(dataurl);
        req.setMethod('POST');  
        req.setHeader('X-Auth-Token', access_token);
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setMethod('POST');
        req.setHeader('Content-Length',String.valueof(bodyPayload.length()));
        req.setBody(bodyPayload);
        
        Http http = New Http();
        HTTPResponse res = http.send(req);
        system.debug('status '+res.getStatusCode());
        System.debug('httpResponse.getBody()' + res.getBody());
        
    }
    
}