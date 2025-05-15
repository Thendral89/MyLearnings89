public without sharing class cmpAPAPIHeaderCtrl {
    
    public static void LastSycFolder(string recordId) {
        List<iManage_Folders__c> Workdas = [SELECT Id
                                            FROM iManage_Folders__c
                                            Where Id =:recordId];
        if(!Workdas.IsEmpty()){
            iManage_Folders__c iFolder = new iManage_Folders__c();
            iFolder.Id=recordId;
            Update iFolder;
        }
        
    }  
    
     public static void SetEmailMessage(string EmailMessageId,string iManageDocumentId) {
    	EmailMessage APIDetails = new EmailMessage();
        APIDetails.Id=EmailMessageId;
        APIDetails.iManageDocumentId__c=iManageDocumentId;
        update APIDetails;
    }  
    
    public static List<iManageTemplates__mdt> iManageTemplatesEmailSetting( string ObjectName) {
        List<iManageTemplates__mdt> Workdas = [SELECT Id,FolderName__c,
                                               IsDocketing__c,IsDocuSign__c,IsEmails__c
                                               FROM iManageTemplates__mdt
                                               Where ObjectName__c =:ObjectName 
                                               AND IsEmails__c=true LIMIT 1];
        return Workdas;
    }
    
   @AuraEnabled
   public static void UpdateDocketDocuments(string PatentId,string iManageEmailObjectId) {
       List<iManage_Documents__c> ObjDoc = new List<iManage_Documents__c>();
       List<iManage_Documents__c> ObjContents = [SELECT Id FROM iManage_Documents__c 
                                                 Where Id=:PatentId Order by CreatedDate Desc];
        if(ObjContents.size()>0){
            for(iManage_Documents__c Version: ObjContents){
                iManage_Documents__c cv = new iManage_Documents__c();
                cv.Id = Version.Id;
                cv.DocketingActivityId__c = iManageEmailObjectId;
                ObjDoc.add(cv);
            }
        }
       
       if(ObjDoc.size()>0)
           update ObjDoc;
       
      
      
    }
    
     public static List<iManage__mdt> getiManage() {
        List<iManage__mdt> Workdas = [SELECT Id,IsDocuSign__c,IsEmail__c,IsSDocs__c,IsDocuSignToiManage__c
                                      FROM iManage__mdt];
       
        return Workdas;
    }
    
   @AuraEnabled
   public static void CreateContentVersion(string Json, string recordId) {
       
       //Create Document
		ContentVersion cv = new ContentVersion();
		cv.Title = 'json';
		cv.PathOnClient = 'json.txt';
		cv.VersionData = Blob.valueOf(Json);
		cv.IsMajorVersion = true;
		Insert cv;
 
		//Get Content Documents
		Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
		//Create ContentDocumentLink 
		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = recordId;
		cdl.ContentDocumentId = conDocId;
		cdl.shareType = 'V';
		Insert cdl;
       
    }
    
   @AuraEnabled
   public static string getiManageApexClass(string APIName) {
        string ApexClass='';
        List<iManage_API_Discription__mdt> Workdas = [SELECT Id,ApexClass__c FROM iManage_API_Discription__mdt 
                                                      Where DeveloperName =:APIName];
        if(Workdas.size()>0)
            ApexClass=Workdas[0].ApexClass__c;
       
       return ApexClass;
    }
    
   @AuraEnabled
   public static string getDeleteContentDocuments(string PatentId) {
       List<string> ContentVersionIds = new List<string>();
       List<ContentVersion> ObjContents = [SELECT Id,ContentDocumentId,iManagedStatus__c
                                           FROM ContentVersion 
                                           Where iManagedStatus__c='Success' Order by CreatedDate Desc];
        if(ObjContents.size()>0){
            for(ContentVersion Version: ObjContents){
                ContentVersionIds.add(Version.ContentDocumentId);
            }
        }
       
        List<ContentDocument> Workdas = [SELECT Id FROM ContentDocument Where Id IN :ContentVersionIds];
        system.debug('Workdas' + Workdas);
        if(Workdas.size()>0)
            delete Workdas;
      
       return '';
    }
    
    public static void getDeleteContentVersion(List<string> ContentDocumentId) {
        List<ContentDocument> Workdas = [SELECT Id FROM ContentDocument Where Id IN :ContentDocumentId];
        system.debug('Workdas' + Workdas);
        if(Workdas.size()>0)
            delete Workdas;
        
    }
    
    public static void ContentVersionId(string ContentVersionId,boolean IsiManageDocument) {
    	ContentVersion APIDetails = new ContentVersion();
        APIDetails.Id=ContentVersionId;
        APIDetails.IsiManageDocument__c=IsiManageDocument;
        if(IsiManageDocument==false)
        APIDetails.iManagedStatus__c='Success';
        
        update APIDetails;
    }  
    
    public static string getworkspaceId(string WorkspaceId) {
        List<iManage_Workspace__c> Workdas = [SELECT Id,id__c,custom1__c,
                                              custom2__c,custom10__c 
                                              FROM iManage_Workspace__c Where id__c=:WorkspaceId];
        if(Workdas.size()>0)
            WorkspaceId=Workdas[0].Id;
       
        system.debug('WorkspaceId ' + WorkspaceId);
        return WorkspaceId;
    }
    
     public static string getClientId(string ClientId) {
        List<SymphonyLF__Client__c> Workdas = [SELECT Id,SymphonyLF__Client_Number_New__c
                                              FROM SymphonyLF__Client__c 
                                              Where Id=:ClientId 
                                              AND SymphonyLF__Client_Number_New__c!=null];
         if(Workdas.size()>0){
            ClientId=Workdas[0].SymphonyLF__Client_Number_New__c; 
         } else {
             ClientId='';
         }
                    
        return ClientId;
    }
    
    
  
    
    public static List<iManage_Workspace__c> getworkspaces() {
        List<iManage_Workspace__c> Workdas = [SELECT Id,id__c,custom1__c,custom2__c,custom10__c 
                                              FROM iManage_Workspace__c];
       
        return Workdas;
    }
    
     public static List<iManage_Workspace__c> getworkspaceDetails(string WorkspaceId) {
        List<iManage_Workspace__c> Workdas = [SELECT Id,id__c,custom1__c,custom2__c,custom10__c 
                                              FROM iManage_Workspace__c Where id__c=:WorkspaceId];
       
        return Workdas;
    }
    
    public static List<iManage_Setting__c> getiManageConfiguredFolders() {
        List<iManage_Setting__c> Workdas = [SELECT Id,Class__c,Folder_Id__c,Jurisdiction__c,Name__c,
                                            Matter__c,Client__c,Workspaces__c,WorkspaceSubcase__c
                                            FROM iManage_Setting__c ];
        return Workdas;
    }
    
    public static List<iManage_Setting__c> getiManageSettingsWorkspace(string Workspaces) {
        List<iManage_Setting__c> Workdas = [SELECT Id,Class__c,Folder_Id__c,Jurisdiction__c,Name__c,
                                                     Matter__c,Client__c,Workspaces__c,WorkspaceSubcase__c
                                                     FROM iManage_Setting__c
                                                     Where Workspaces__c=:Workspaces LIMIT 49999];
        return Workdas;
    }
    
    public static List<iManage_Setting__c> getiManageFoldersToBeSynced() {
        List<iManage_Setting__c> Workdas = [SELECT Id,Class__c,Folder_Id__c,Jurisdiction__c,Name__c,
                                                     Matter__c,Client__c,Workspaces__c,WorkspaceSubcase__c
                                                     FROM iManage_Setting__c Where IsProcessed__c=false ];
        return Workdas;
    }
    
     public static List<iManage_Setting__c> getiManageSettings(string Name) {
        List<iManage_Setting__c> Workdas = [SELECT Id,Class__c,Folder_Id__c,Jurisdiction__c,Name__c,
                                            Matter__c,Client__c,Workspaces__c,WorkspaceSubcase__c
                                            FROM iManage_Setting__c
                                            Where Name__c=:Name LIMIT 1];
        return Workdas;
    }
   
     public static List<iManage_Setting__c> getiManageSettings(string Name,string Workspaces) {
        List<iManage_Setting__c> Workdas = [SELECT Id,Class__c,Folder_Id__c,Jurisdiction__c,Name__c,
                                            Matter__c,Client__c,Workspaces__c,WorkspaceSubcase__c
                                            FROM iManage_Setting__c
                                            Where Name__c=:Name
                                            AND Workspaces__c=:Workspaces LIMIT 1];
        return Workdas;
    }
    
	Public static boolean isRecordId(string recordId){
    	try {
        	return string.isNotBlank(recordId) && ((Id)recordId.trim()).getSObjectType() != null;
    	} catch(Exception ex) {
        	return false;
    	}
	}
    
    public static string APIInsert(string API,string Status,string APIJson,string iManageDocId) {
     	string apiIds='';   
    	API_Details__c APIDetails = new API_Details__c();
        APIDetails.API_Name__c=API;
        APIDetails.Status__c=Status;
        APIDetails.JsonDetails__c=APIJson;
        APIDetails.ApexClass__c=cmpAPAPIHeaderCtrl.getiManageApexClass(API);
        if(iManageDocId!='' && iManageDocId !=null){
            if(cmpAPAPIHeaderCtrl.isRecordId(iManageDocId)==true)
                APIDetails.iManage_Documents__c=iManageDocId;
            
        }
        
          try {
              insert APIDetails;
          } catch(Exception exp) {
          }
        apiIds=APIDetails.Id;
        
      return apiIds;
    }  
    
    public static string APIInsert(string API,string Status,string APIJson) {
     	string apiIds='';   
    	API_Details__c APIDetails = new API_Details__c();
        APIDetails.API_Name__c=API;
        APIDetails.Status__c=Status;
        APIDetails.JsonDetails__c=APIJson;
        APIDetails.ApexClass__c=cmpAPAPIHeaderCtrl.getiManageApexClass(API);
        insert APIDetails;
        apiIds=APIDetails.Id;
        
      return apiIds;
    }  
 
     public static string APIUpdate (string apiIds,string Status,string APIJson,string recordId,string iManageFoldersId,string createdFolderId,string ContentVersionId) {
    	API_Details__c APIDetails = new API_Details__c();
        APIDetails.Id=apiIds;
        APIDetails.Status__c=Status;
        APIDetails.APIResponse__c=APIJson;
        APIDetails.recordId__c=recordId;
        if(!test.isRunningTest()) {
        APIDetails.iManageFoldersId__c=iManageFoldersId;
        APIDetails.createdFolderId__c=createdFolderId;
        APIDetails.ContentVersionId__c=ContentVersionId;
        }
        update APIDetails;
        apiIds=APIDetails.Id;
        
        return apiIds;
    } 
    
    public static string APIUpdate (string apiIds,string Status,string APIJson,string recordId) {
    	API_Details__c APIDetails = new API_Details__c();
        APIDetails.Id=apiIds;
        APIDetails.Status__c=Status;
        APIDetails.APIResponse__c=APIJson;
        APIDetails.recordId__c=recordId;
        
         try {
              update APIDetails;
          } catch(Exception exp) {
          }
        
        apiIds=APIDetails.Id;
        
        return apiIds;
    } 
    
    public static string APIUpdate (string apiIds,string Status,string APIJson) {
    	API_Details__c APIDetails = new API_Details__c();
        APIDetails.Id=apiIds;
        APIDetails.Status__c=Status;
        APIDetails.APIResponse__c=APIJson;
        update APIDetails;
        apiIds=APIDetails.Id;
        
        return apiIds;
    } 
 
    public static List<iManageFolder__mdt> iManageFolderSetting( string ObjectName) {
        List<iManageFolder__mdt> Workdas = [SELECT Id,Folder_Field_API_Name__c,
                                            ObjectName__c,Legacy_ID__c,ClientId__c
                                            FROM iManageFolder__mdt
                                            Where ObjectName__c =:ObjectName LIMIT 1];
        return Workdas;
    }
    
     public static List<iManageTemplates__mdt> iManageTemplatesSetting( string ObjectName) {
        List<iManageTemplates__mdt> Workdas = [SELECT Id,FolderName__c,
                                            IsDocketing__c,IsDocuSign__c,IsEmails__c
                                            FROM iManageTemplates__mdt
                                            Where ObjectName__c =:ObjectName AND IsDocketing__c=true LIMIT 1];
        return Workdas;
    }
    
    
    public static List<iManageAPIs__mdt> getiManageHeader() {
        List<iManageAPIs__mdt> Workdas = [SELECT Id,client_id__c,client_secret__c,DataUrl__c,grant_type__c,
                                          libraries__c,password__c,scope__c,TokenUrl__c,username__c,
                                          customers__c,createdFolderId__c,boundarykey__c,workspaces__c,WorkspacesName__c
                                   FROM iManageAPIs__mdt LIMIT 1];
        return Workdas;
    }
    
  public class TokenResult {
    public String access_token {get;set;}
    public String expires_in {get;set;}
    public String token_type {get;set;}
    public String scope {get;set;}
    public String refresh_token {get;set;}
    
  }
    

    
    public static string getToken() {
        try 
        {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            string apibody='';
            string access_token='';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(objCSworkday[0].TokenUrl__c );
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            apibody = 'username='+ objCSworkday[0].username__c +'&password='+ objCSworkday[0].password__c +'&grant_type='+ objCSworkday[0].grant_type__c +'&client_id='+ objCSworkday[0].client_id__c +'&client_secret='+ objCSworkday[0].client_secret__c +'&scope='+ objCSworkday[0].scope__c + '';
            //system.debug('apibody'+ apibody);
            req.setBody(apibody);
            req.setMethod('POST');
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                HTTPResponse httpResponse = http.send(req);
                //System.debug('httpResponse.getBody()' + httpResponse.getBody());
                if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                     TokenResult objResponse = (TokenResult) JSON.deserializeStrict(httpResponse.getBody(),TokenResult.Class);
                     access_token=objResponse.access_token;
                    //System.debug('objResponse ' +   objResponse.access_token);
                }
            }
            
            //System.debug('access_token' + access_token);
            return access_token;
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    
}