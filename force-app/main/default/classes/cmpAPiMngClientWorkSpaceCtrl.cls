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

public class cmpAPiMngClientWorkSpaceCtrl {
    
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
    public static string iMngGetWS(string access_token, string IPMatterNumber,string recordId,string ObjectName,string ClientId) {
        
        string apiIds ='';
        string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
        string API5data='';
        string iManageFoldersId='';
        string iManageFoldersReturnId='';
        List<iManage_Configuration__c> ObjDocuments = new List<iManage_Configuration__c>();
        Set<Id> addedIds = new Set<Id>();
        
        Map<String,String> mapworkspace=new Map<String,String>();
        List<string> FoldersIds = new List<string>();
        string Qstr='';
        Qstr+='{';
        Qstr+='"filters":';
        Qstr+='{';
        Qstr+='"name": "' + IPMatterNumber +'"';
        Qstr+='}';
        Qstr+='}';
        
        Map<Id, iManage_Configuration__c> existingConfigs = new Map<Id, iManage_Configuration__c>();
        for (iManage_Configuration__c config : [
            SELECT Id, recordId__c, WorkspaceId__c
            FROM iManage_Configuration__c
            WHERE ObjectName__c = :ObjectName
        ]) {
            existingConfigs.put(config.recordId__c, config);
        }
        
        system.debug('cmpAPiMngClientWorkSpaceCtrl ' + FoldersIds);
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
            
            
            
            if(test.isRunningTest()) {
                returnresponse='{  "data": {    "results": [      {        "workspace_id": "ws123",        "iwl": "iwl_example_1",        "id": "id_1",        "wstype": "type_1"      },      {        "workspace_id": "ws124",        "iwl": "iwl_example_2",        "id": "id_2",        "wstype": "type_2"      }    ]  },  "overflow": "some_overflow_value"}';
            }
            
            Workspace ObjWrapper = (Workspace) JSON.deserialize(returnresponse,Workspace.Class);
            if(ObjWrapper.data.results!=null)
                for(results objRes : ObjWrapper.data.results ) {
                    
                    iManage_Workspace__c workspace = new iManage_Workspace__c();
                    workspace.name__c=IPMatterNumber;
                    workspace.id__c=objRes.id;
                    List<iManage_Workspace__c> ObjWorkspace  = [SELECT Id FROM iManage_Workspace__c WHERE recordId__c =: recordId AND name__c=:IPMatterNumber];
                    if (ObjWorkspace.Size() >0 ) {
                        workspace.Id=ObjWorkspace[0].Id;
                        update workspace;
                    } else {
                        insert workspace;
                    }
                    
                    iManage_Configuration__c cworkspace = new iManage_Configuration__c();
                    cworkspace.ObjectName__c=ObjectName;
                    cworkspace.WorkspaceId__c=objRes.id;
                    cworkspace.recordId__c=ClientId;
                    cworkspace.name__c=IPMatterNumber;
                    cworkspace.FolderId__c=objRes.id;
                    if (existingConfigs.containsKey(ClientId)) {
                        cworkspace.Id = existingConfigs.get(ClientId).Id;
                    }
                    if (!addedIds.contains(ClientId)) {
                        objDocuments.add(cworkspace);
                        addedIds.add(ClientId);
                    }
                    
                    iManageFoldersId=objRes.id;
                }
            
            if(ObjDocuments.size()>0)
                upsert ObjDocuments;
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('iManageConfiguration','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending','Error ' + exp.getMessage(),recordId);
        }
        
        return iManageFoldersId;
        
    }
}