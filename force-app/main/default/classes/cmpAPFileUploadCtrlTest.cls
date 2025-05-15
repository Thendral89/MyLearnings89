@isTest
private class cmpAPFileUploadCtrlTest{

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
       
        List<string> convid = new List<string>();
        convid.add(cv.Id);
        
       
      
        
        
        try{
        
       
        cmpAPFileUploadCtrl.delDups(new List<Id>{conver1.ContentDocumentId},new List<String>{'Test Document'}); 
        cmpAPFileUploadCtrl.deleteAttachment(cv.Id);       
        cmpAPFileUploadCtrl.deleteAttachmentFromFlow(convid);
        cmpAPFileUploadCtrl.SRUpdateRecord(NUll,Null,Null,Null);
        cmpAPFileUploadCtrl.deletecontentversion(Null);
        cmpAPFileUploadCtrl.getprofile(objpatent.Id);
        cmpAPFileUploadCtrl.UpdatePriorArtSearch(objpatent.Id,new List<Id>{conver1.ContentDocumentId});
        cmpAPFileUploadCtrl.SRUpdateRecord(objpatent.Id,'SymphonyLF__Case_Type__c','Continuation','SymphonyLF__Patent__c');
        cmpAPFileUploadCtrl.getAttachedDocuments(objpatent.id);
        cmpAPFileUploadCtrl.cmpAPAttachmentPPM(objpatent.id,false,100);
        cmpAPFileUploadCtrl.cmpAPAttachment(objpatent.id,false,100);
        cmpAPFileUploadCtrl.getcmpAPAttachedDocuments(objpatent.id,false,100);
        cmpAPFileUploadCtrl.getcmpAPDocuSignAttachedDocuments(objpatent.id,false);
        cmpAPFileUploadCtrl.getcmpAPFileUploadAttachedDocuments(objpatent.id,false);
        cmpAPFileUploadCtrl.getcmpAPFileUploadCurrentAttachedDocumentsPPM(objpatent.id,new List<Id>{conver1.ContentDocumentId},ObjContentVersion,false);
        cmpAPFileUploadCtrl.getcmpAPFileUploadCurrentAttachedDocuments(objpatent.id,new List<Id>{conver1.ContentDocumentId},ObjContentVersion,false);
        cmpAPFileUploadCtrl.getcmpAPInnovationCurrentAttachedDocuments(objpatent.id,new List<Id>{conver1.ContentDocumentId},ObjContentVersion,false);
        cmpAPFileUploadCtrl.getcmpAPInnovationAttachedDocuments(objpatent.id,false);
        cmpAPFileUploadCtrl.getInnovationSubmissionDocuments(objpatent.id,new List<Id>{conver1.ContentDocumentId},'');
        cmpAPFileUploadCtrl.getPatentBotDocuments(objpatent.id,new List<Id>{conver1.ContentDocumentId},'');
        cmpAPFileUploadCtrl.UpdateNOADocuments(objpatent.id,new List<Id>{conver1.ContentDocumentId},ObjContentVersion);
        cmpAPFileUploadCtrl.getNOACurrentAttachedDocuments(objpatent.id,conver1.ContentDocumentId,ObjContentVersion);
        cmpAPFileUploadCtrl.getCurrentAttachedDocuments(objpatent.id,new List<Id>{conver1.ContentDocumentId},ObjContentVersion);
		cmpAPFileUploadCtrl.reviewers(objpatent.id);            
            
            
        }
        catch(QueryException ex){
            system.debug('AddInvTableController ::' + ex);
        }
        
        
        
        
    }
    
}