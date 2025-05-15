/*
*********************************************************
Apex Class Name    : cmpAPiMngGetTrashedDocCtrl
Created Date       : Feb 12, 2024
@description       : API20, get Trash-bin documents
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngGetTrashedDocCtrl {

    
  @future(callout=true)
  public static void iMngGetDoc(string access_token) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
      
      	//Id myId=recordId;
        //String sObjName = myId.getSObjectType().getDescribe().getName();
		string query='';
        string foldername='';
        string Field_API_Name='';
        string Legacy_ID='';
      
      	string Ids='';
        string iManageFolderId='';
        string iManageWorkSpaceId='';
        string iManageLegacy_ID='';
      
        access_token=cmpAPAPIHeaderCtrl.getToken();
        List<iManage_Documents__c> ObjDocuments = new List<iManage_Documents__c>();
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/trash-bin/user/documents?latest=true&limit=50&wstype=document&trashed_date=-1:0d';
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
          
            if(test.isRunningTest()) 
                returnresponse='{  "data": [    {      "database": "SampleDatabase",      "document_number": "123456",      "version": "1.0",      "name": "Sample Document",      "author": "John Doe",      "operator": "Admin",      "type": "pdf",      "class_code": "A1",      "edit_date": "2024-12-29T10:00:00Z",      "system_edit_date": "2024-12-29T10:00:00Z",      "create_date": "2024-12-01T08:30:00Z",      "create_profile_date": "2024-12-01T08:30:00Z",      "retain_days": "30",      "size": "2048",      "is_declared": "true",      "declared": "true",      "is_related": "false",      "default_security": "high",      "last_user": "Jane Smith",      "is_in_use": "false",      "is_checked_out": "true",      "type_description": "PDF Document",      "class_description": "Document Type A1",      "extension": "pdf",      "content_type": "application/pdf",      "edit_profile_date": "2024-12-29T10:00:00Z",      "is_external": "false",      "is_external_as_normal": "false",      "file_create_date": "2024-12-01T08:30:00Z",      "file_edit_date": "2024-12-29T10:00:00Z",      "is_hipaa": "false",      "workspace_name": "Workspace1",      "is_restorable": "true",      "id": "doc123",      "in_use": "false",      "indexable": "true",      "wstype": "typeA",      "iwl": "true",      "workspace_id": "workspace1_id",      "author_description": "Document Author",      "operator_description": "Admin User",      "last_user_description": "Last User"    }  ]}';
            
            List<string> iManageDocumentsIds = new List<string>();
            cmpAPiMngGetFolderDocWrraper FolderDocWrraper = (cmpAPiMngGetFolderDocWrraper) JSON.deserialize(returnresponse,cmpAPiMngGetFolderDocWrraper.Class);
            for(cmpAPiMngGetFolderDocWrraper.data objResponse : FolderDocWrraper.data ) {
                iManageDocumentsIds.add(objResponse.id);
            }
            
         List<iManage_Documents__c> ObjFolders  = [SELECT Id,id__c
                                                  FROM iManage_Documents__c 
                                                  WHERE id__c IN : iManageDocumentsIds];
         if (ObjFolders.size()>0) { 
             for(iManage_Documents__c record: ObjFolders){
                 iManage_Documents__c imngDocuments = new iManage_Documents__c();
                 imngDocuments.Id=record.Id;
                 ObjDocuments.add(record);
             }
         }
            
            if(ObjDocuments.size()>0)
                delete ObjDocuments;
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API15','Pending',data,Bytedance_IDF_ID); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            cmpAPAPIHeaderCtrl.APIInsert('API15','Pending',data,Bytedance_IDF_ID);
        }
       
      
    }
}