@isTest
private class cmpAPInventorCtrlTest{

    @isTest
    static void test2(){
        
         Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standtss', Email='standardusers@testorgs.com',
        EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='newusers90099001@testorg.com');
        insert u1;
        
         SymphonyLF__Person__c inv = new SymphonyLF__Person__c();
        inv.Name ='inventors';
        inv.SymphonyLF__Email__c='test@gmail.com.com';
        inv.SymphonyLF__User__c =u1.Id;
        inv.SymphonyLF__Type__c='Client';
        inv.SymphonyLF__Contact_Type__c='Author';
        insert inv ;
        
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
        
        DocuSignReviewer__c doc = new DocuSignReviewer__c(recordId__c=objpatent.id,Person__c=inv.id);
        insert doc;
      
        
        
        try{
        
        cmpAPInventorCtrl.getDocuSignePatentsReviewers(objpatent.id);
        cmpAPInventorCtrl.getDocuSignePatentsReviewers(doc.id);
        cmpAPInventorCtrl.FetchPatentData(objpatent.id);
        cmpAPInventorCtrl.RowActionsDelete(objpatent.id);          
            
        }
        catch(QueryException ex){
            system.debug('AddInvTableController ::' + ex);
        }
        
        
        
        
    }
    
}