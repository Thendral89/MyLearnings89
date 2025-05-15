@isTest
private class cmpAPAPIHeaderCtrlTest{

    @isTest
    static void test2(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
         SymphonyLF__Country__c Country = new SymphonyLF__Country__c();
        Country.SymphonyLF__Active__c=true;
        Country.SymphonyLF__Country_Code__c='IN';
        Country.Name='India';
		insert Country;   
        
         SymphonyLF__Client__c Client = new SymphonyLF__Client__c();
        Client.SymphonyLF__Active__c=true;
        Client.Name='India';
        Client.SymphonyLF__Entity_Size__c='Small';
        Client.SymphonyLF__Client_Number_New__c='000001';
		insert Client; 
        
      	SymphonyLF__Patent__c objpatent = new SymphonyLF__Patent__c();
        objpatent.SymphonyLF__Patent_Number__c = '123test';
        objpatent.SymphonyLF__Case_Type__c='Continuation';
        objpatent.SymphonyLF__Client__c=Client.Id;
        objpatent.SymphonyLF__Country__c=Country.Id;
        insert objpatent; 
        
        ContentVersion conver1 = [SELECT id,Title,ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=objpatent.id;
        contentlink2.ShareType= 'V';
        contentlink2.ContentDocumentId=conver1.ContentDocumentId;
        insert contentlink2;
        List<ContentVersion> ObjContentVersion = new List<ContentVersion>();
        ObjContentVersion.add(conver1);
       
        List<string> ContentDocumentIds = new List<string>();
        ContentDocumentIds.add(conver1.ContentDocumentId);
        
        List<string> convid = new List<string>();
        convid.add(cv.Id);

        iManage_Workspace__c Workspace = new iManage_Workspace__c();
        Workspace.recordId__c = objpatent.Id;
        Workspace.id__c=objpatent.Id;
        insert Workspace; 
        
        iManage_Setting__c iSetting = new iManage_Setting__c();
        iSetting.Workspaces__c = Workspace.Id;
        iSetting.Name__c=objpatent.Id;
        iSetting.IsProcessed__c=false;
        insert iSetting;
        
        try{       
            
        cmpAPAPIHeaderCtrl.iManageFolderSetting('SymphonyLF__Patent__c');
        cmpAPAPIHeaderCtrl.getiManageHeader();
        cmpAPAPIHeaderCtrl.getToken();
            
        cmpAPAPIHeaderCtrl.getiManage();
        cmpAPAPIHeaderCtrl.CreateContentVersion('Amar',objpatent.Id);
        cmpAPAPIHeaderCtrl.getiManageApexClass('cmpAPiManageCreateFolderCtrl');
        cmpAPAPIHeaderCtrl.getDeleteContentDocuments(objpatent.Id);
        
        cmpAPAPIHeaderCtrl.ContentVersionId(cv.Id,true);
        cmpAPAPIHeaderCtrl.getworkspaces();
        cmpAPAPIHeaderCtrl.getworkspaceDetails(objpatent.Id);
        cmpAPAPIHeaderCtrl.getiManageConfiguredFolders();
        cmpAPAPIHeaderCtrl.getiManageSettingsWorkspace(Workspace.Id);  
        cmpAPAPIHeaderCtrl.getiManageFoldersToBeSynced();
        cmpAPAPIHeaderCtrl.getiManageSettings(objpatent.Id,Workspace.Id);
        cmpAPAPIHeaderCtrl.getiManageSettings(objpatent.Id);
            
        cmpAPAPIHeaderCtrl.APIInsert('API1','Success','','');
        string apiIds = cmpAPAPIHeaderCtrl.APIInsert('API1','Success','');
        cmpAPAPIHeaderCtrl.APIUpdate (apiIds,'Success','',objpatent.Id);
        cmpAPAPIHeaderCtrl.APIUpdate (apiIds,'Success','');
        cmpAPAPIHeaderCtrl.getDeleteContentVersion(ContentDocumentIds); 
        cmpAPAPIHeaderCtrl.APIUpdate (apiIds,'Success','',objpatent.Id,'','','');
            
            
        
        }
        catch(QueryException ex){
            system.debug('AddInvTableController ::' + ex);
        }
        
        
        
        
    }
    
}