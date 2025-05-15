/*
*********************************************************
Apex Class Name    : cmpAPiMngSearchWorkSpaceCtrl
Created Date       : July 12, 2023
@description       : API22, search workspace by IP Matter name
@author            : Amar P
Modification Log:
Ver   Date         Author                               Modification
1.0   07-2023   Amar P                      			Initial Version
*********************************************************
*/

public class cmpAPiMngSearchWorkSpaceCtrl {

    public class Workspace{
        public data data;
        public String overflow;
    }
   
	public class results {
		public String workspace_id;
		public String iwl;
		public String id;
		public String wstype;
	}

	public class data {
		public List<results> results;
	}

	public static Workspace parse(String json) {
		return (Workspace) System.JSON.deserialize(json, Workspace.class);
	}
    
  @AuraEnabled
  public static string iMngGetWS(string access_token, string IPMatterNumber,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        string iManageFoldersId='';
        string iManageFoldersReturnId='';
        List<iManage_Workspace__c> ObjDocuments = new List<iManage_Workspace__c>();
        Map<String,String> mapworkspace=new Map<String,String>();
        List<string> FoldersIds = new List<string>();
        string Qstr='';
      	Qstr+='{';
  		Qstr+='"filters":';
  		Qstr+='{';
    	Qstr+='"name": "' + IPMatterNumber +'"';
  		Qstr+='}';
		Qstr+='}';
      
         system.debug('Qstr' + Qstr);
      
       List<iManage_Workspace__c> ObjsFolders  = [SELECT Id,recordId__c,id__c
                                               FROM iManage_Workspace__c 
                                               WHERE recordId__c =: recordId ];
      if (ObjsFolders.Size() >0 ) {
          for(iManage_Workspace__c fata: ObjsFolders){
              FoldersIds.add(fata.id__c);
          }
      }
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/workspaces/search';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('POST');  
            req.setBody(Qstr);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-Auth-Token', access_token);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                 HTTPResponse httpResponse = http.send(req);
                 returnresponse=httpResponse.getBody();
                 access_token= string.valueof(httpResponse.getStatusCode());
            }
          
         system.debug('returnresponse' + returnresponse);
            
         List<string> iManageDocumentsIds = new List<string>();
         List<iManage_Workspace__c> ObjFolders  = [SELECT Id,id__c FROM iManage_Workspace__c Where name__c=:IPMatterNumber];
         if (ObjFolders.size()>0) { 
             for(iManage_Workspace__c record: ObjFolders){
                 iManageDocumentsIds.add(record.id__c);
                 mapworkspace.put(record.id__c,record.Id);
             }
         }
            
            if(test.isRunningTest()) {
                returnresponse='{  "data": {    "results": [      {        "workspace_id": "ws123",        "iwl": "iwl_example_1",        "id": "id_1",        "wstype": "type_1"      },      {        "workspace_id": "ws124",        "iwl": "iwl_example_2",        "id": "id_2",        "wstype": "type_2"      }    ]  },  "overflow": "some_overflow_value"}';
            }
            
           Workspace ObjWrapper = (Workspace) JSON.deserialize(returnresponse,Workspace.Class);
            if(ObjWrapper.data.results!=null)
            for(results objResponse : ObjWrapper.data.results ) {
            	iManage_Workspace__c workspace = new iManage_Workspace__c();
				workspace.name__c=IPMatterNumber;
				workspace.iwl__c=objResponse.iwl;
				workspace.id__c=objResponse.id;
                workspace.recordId__c=recordId;
                workspace.workspace_id__c=objResponse.id;
				workspace.wstype__c=objResponse.wstype;
                if (mapworkspace.containsKey(objResponse.id))
                    workspace.Id=mapworkspace.get(objResponse.id); 
                    
                 if(!FoldersIds.contains(objResponse.id)){
                     ObjDocuments.add(workspace);
                     iManageFoldersId=objResponse.id;
                 }
            }
            
            if(ObjDocuments.size()>0)
                upsert ObjDocuments;
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API15','Pending',data); 
            if(access_token =='200' || access_token =='201'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API15','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending','Error ' + exp.getMessage(),recordId);
        }
       
      return iManageFoldersId;
      
    }
}