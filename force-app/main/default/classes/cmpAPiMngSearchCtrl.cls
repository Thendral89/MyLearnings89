/*
*********************************************************
Apex Class Name    : cmpAPiMngSearchCtrl
Created Date       : July 12, 2023
@description       : API17, search folders by name
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngSearchCtrl {

    
    
  @AuraEnabled
  public static List<data> iMngSearch(string access_token, string documentsname, string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        List<data> API5data = new List<data>();
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
           
            string apibody='';
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/folders/search?name=*' + documentsname + '*' ;
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('GET');  
            req.setHeader('Content-Type', cmpAPiMangUploadDocCtrl.GetContentType(objCSworkday[0].boundarykey__c));
            req.setHeader('X-Auth-Token', access_token);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                 HTTPResponse httpResponse = http.send(req);
                 returnresponse=httpResponse.getBody(); 
                 access_token='success';
            }
            
            if(test.isRunningTest()) 
                returnresponse='{  "data": [    {      "database": "MB_SB",      "default_security": "public",      "description": "MB-PT-10001122024-US",      "edit_date": "2024-01-15T06:56:02Z",      "folder_type": "regular",      "has_documents": "true",      "has_subfolders": "false",      "id": "MB_SB!37",      "is_container_saved_search": "false",      "is_content_saved_search": "false",      "is_external": "false",      "is_external_as_normal": "false",      "is_hidden": "false",      "name": "MB-PT-10001122024-US",      "owner": "SYM_SVC",      "owner_description": "Symphony Service Account",      "parent_id": "MB_SB!5",      "view_type": "document",      "workspace_id": "MB_SB!5",      "workspace_name": "iManage Cloud Monitor",      "wstype": "folder"    }  ]}';
            
            cmpAPiMngSearchWrraper FolderDocWrraper = (cmpAPiMngSearchWrraper) JSON.deserialize(returnresponse,cmpAPiMngSearchWrraper.Class);
            if(FolderDocWrraper.data.size()>0) {
                for(cmpAPiMngSearchWrraper.data objResponse : FolderDocWrraper.data ) {
                	data objOption = new data();
                    objOption.description=objResponse.description;	//MB-PT-10001122024-US
					objOption.folder_type=objResponse.folder_type;	//regular
					objOption.id=objResponse.id;	//MB_SB!37
					objOption.name=objResponse.name;	//MB-PT-10001122024-US
                    API5data.add(objOption);
                }
               
            } 
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API17','Pending',data); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success','success',recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API17','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      return API5data;
      
    }
    
    
    public class data {
        @AuraEnabled
		public String description;	//MB-PT-10001122024-US
        @AuraEnabled
		public String folder_type;	//regular
        @AuraEnabled
		public String id;	//MB_SB!37
        @AuraEnabled
		public String name;	//MB-PT-10001122024-US
	}
    
}