/*
*********************************************************
Apex Class Name    : cmpAPiMngGetWorkSpaceCtrl
Created Date       : July 12, 2023
@description       : API16, search all workspace
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngGetWorkSpaceCtrl {

    
  @AuraEnabled
  public static string iMngGetFolder(string access_token) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        string iManageFoldersId='';
        string iManageFoldersReturnId='';
        List<iManage_Workspace__c> ObjDocuments = new List<iManage_Workspace__c>();
        Map<String,String> mapworkspace=new Map<String,String>();
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/workspaces?limit=1000&sort_order=asc';
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
                 returnresponse=returnresponse.replace('"class"','"classw"');
                 access_token='success';
            }
          
         if(test.isRunningTest()) 
             returnresponse='{  "data": {    "results": [      {        "default_security": "global",        "name": "US00 (206001-6021)",        "owner": "SYM_SVC",        "description": "IP Test One",        "subtype": "work",        "document_number": "76",        "version": "1",        "has_subfolders": "true",        "is_content_saved_search": "false",        "is_container_saved_search": "false",        "database": "MB_SB",        "is_external": "false",        "is_hidden": "false",        "is_external_as_normal": "false",        "owner_description": "Symphony Service Account",        "workspace_id": "MB_SB!121",        "author": "SYM_SVC",        "operator": "SYM_SVC",        "type": "XML",        "classw": "WEBDOC",        "edit_date": "2024-01-27T21:12:11Z",        "system_edit_date": "2024-01-27T21:12:11Z",        "create_date": "2024-01-27T21:12:11Z",        "create_profile_date": "2024-01-27T21:12:11Z",        "retain_days": "365",        "size": "1",        "is_declared": "true",        "declared": "true",        "location": "76.1",        "last_user": "SYM_SVC",        "is_in_use": "false",        "is_checked_out": "false",        "custom1": "206001",        "custom2": "6021",        "custom3": "6021",        "custom4": "US",        "custom5": "6021",        "custom6": "6021",        "custom7": "1",        "custom8": "1",        "custom9": "1",        "custom10": "US00",        "custom1_description": "Bill Bradley",        "custom2_description": "IP Test One",        "custom3_description": "IP Test One",        "custom4_description": "USPTO",        "custom5_description": "USPTO",       "custom6_description": "USPTO",        "custom7_description": "1",        "custom8_description": "1",        "custom9_description": "1",        "custom10_description": "USPTO",        "content_type": "P",        "edit_profile_date": "2024-01-27T21:13:07Z",        "file_create_date": "2024-01-27T21:12:11Z",        "file_edit_date": "2024-01-27T21:12:11Z",        "is_hipaa": "false",        "in_use": "false",        "indexable": "true",        "iwl": "iwl:dms=michaelbest-mobility.imanage.work&&lib=&&num=76&&ver=1",        "id": "MB_SB!121",        "wstype": "workspace"      }    ]  }}';
            
         List<string> iManageDocumentsIds = new List<string>();
         List<iManage_Workspace__c> ObjFolders  = [SELECT Id,id__c FROM iManage_Workspace__c limit 49999];
         if (ObjFolders.size()>0) { 
             for(iManage_Workspace__c record: ObjFolders){
                 iManageDocumentsIds.add(record.id__c);
                 mapworkspace.put(record.id__c,record.Id);
             }
         }
            
            cmpAPiMngWorkSpaceWrapper ObjWrapper = (cmpAPiMngWorkSpaceWrapper) JSON.deserialize(returnresponse,cmpAPiMngWorkSpaceWrapper.Class);
            for(cmpAPiMngWorkSpaceWrapper.results objResponse : ObjWrapper.data.results ) {
            	iManage_Workspace__c workspace = new iManage_Workspace__c();
           		workspace.default_security__c=objResponse.default_security;
				workspace.name__c=objResponse.name;
				workspace.owner__c=objResponse.owner;
				workspace.description__c=objResponse.description;
				workspace.subtype__c=objResponse.subtype;
				workspace.document_number__c=objResponse.document_number;
				workspace.version__c=objResponse.version;
				workspace.has_subfolders__c=objResponse.has_subfolders;
				workspace.is_content_saved_search__c=objResponse.is_content_saved_search;
				workspace.is_container_saved_search__c=objResponse.is_container_saved_search;
				workspace.database__c=objResponse.database;
				workspace.is_external__c=objResponse.is_external;
				workspace.is_hidden__c=objResponse.is_hidden;
				workspace.is_external_as_normal__c=objResponse.is_external_as_normal;
				workspace.owner_description__c=objResponse.owner_description;
				workspace.workspace_id__c=objResponse.workspace_id;
				workspace.author__c=objResponse.author;
				workspace.operator__c=objResponse.operator;
				workspace.type__c=objResponse.type;
				workspace.class__c=objResponse.classw;
				workspace.edit_date__c=objResponse.edit_date;
				workspace.system_edit_date__c=objResponse.system_edit_date;
				workspace.create_date__c=objResponse.create_date;
				workspace.create_profile_date__c=objResponse.create_profile_date;
				workspace.retain_days__c=objResponse.retain_days;
				workspace.size__c=objResponse.size;
				workspace.is_declared__c=objResponse.is_declared;
				workspace.declared__c=objResponse.declared;
				workspace.location__c=objResponse.location;
				workspace.last_user__c=objResponse.last_user;
				workspace.is_in_use__c=objResponse.is_in_use;
				workspace.is_checked_out__c=objResponse.is_checked_out;
				workspace.custom1__c=objResponse.custom1;
				workspace.custom2__c=objResponse.custom2;
                workspace.custom3__c=objResponse.custom3;
				workspace.custom4__c=objResponse.custom4;
                workspace.custom5__c=objResponse.custom5;
                workspace.custom6__c=objResponse.custom6;
				workspace.custom7__c=objResponse.custom7;
                workspace.custom8__c=objResponse.custom8;
                workspace.custom9__c=objResponse.custom9;
				workspace.custom10__c=objResponse.custom10;
				workspace.custom1_description__c=objResponse.custom1_description;
				workspace.custom2_description__c=objResponse.custom2_description;
                workspace.custom3_description__c=objResponse.custom3_description;
				workspace.custom4_description__c=objResponse.custom4_description;
                workspace.custom5_description__c=objResponse.custom5_description;
                workspace.custom6_description__c=objResponse.custom6_description;
				workspace.custom7_description__c=objResponse.custom7_description;
                workspace.custom8_description__c=objResponse.custom8_description;
                workspace.custom9_description__c=objResponse.custom9_description;
				workspace.custom10_description__c=objResponse.custom10_description;
				workspace.content_type__c=objResponse.content_type;
				workspace.edit_profile_date__c=objResponse.edit_profile_date;
				workspace.file_create_date__c=objResponse.file_create_date;
				workspace.file_edit_date__c=objResponse.file_edit_date;
				workspace.is_hipaa__c=objResponse.is_hipaa;
				workspace.in_use__c=objResponse.in_use;
				workspace.indexable__c=objResponse.indexable;
				workspace.iwl__c=objResponse.iwl;
				workspace.id__c=objResponse.id;
				workspace.wstype__c=objResponse.wstype;
                if (mapworkspace.containsKey(objResponse.id)){
                    workspace.Id=mapworkspace.get(objResponse.id); 
                }
                    
            	ObjDocuments.add(workspace);
            }
            
            if(ObjDocuments.size()>0)
                upsert ObjDocuments;
            
            iManageFoldersId=ObjDocuments[0].Id;
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API16','Pending',data); 
            if(access_token !=''){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API16','Pending',data);
        }
       
      return access_token;
      
    }
}