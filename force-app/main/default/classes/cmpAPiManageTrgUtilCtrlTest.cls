@isTest
public class cmpAPiManageTrgUtilCtrlTest {
  
   @isTest
    static void CreateAccountTestWSData() {
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standtss', Email='standardusers@testorgs.com',
        EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='newusers90099001@testorg.com');
        insert u1;
        
        DocuSign__c ds = new DocuSign__c(name='Default',
                                         UserName__c = 'amar.p@maxval.com',
                                         UserPassword__c='f$J6sQ*pa#zt@6.',
                                         EndPoint__c='https://demo.docusign.net/restapi/v2/accounts/',
                                         IntegratorKey__c='97fe8b93-7601-48d2-acf5-e62932febef2');
        insert ds;
        
        SymphonyLF__Person__c inv = new SymphonyLF__Person__c();
        inv.Name ='inventors';
        inv.SymphonyLF__Email__c='test@gmail.com.com';
        inv.SymphonyLF__User__c =u1.Id;
        inv.SymphonyLF__Type__c='Client';
        inv.SymphonyLF__Contact_Type__c='Author';
        insert inv ;
        
        SymphonyLF__Person__c inv1 = new SymphonyLF__Person__c();
        inv1 = inv.clone();
        insert inv1;
        

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
        
        
            
        SymphonyLF__Patent__c pat = new SymphonyLF__Patent__c();
        pat.SymphonyLF__First_Named_Inventor__c =inv.Id;
        pat.SymphonyLF__Internal_Counsel__c = u1.id;
        pat.SymphonyLF__Patent_Number__c = '123test';
        pat.SymphonyLF__Case_Type__c='Continuation';
        pat.SymphonyLF__Client__c=Client.Id;
        pat.SymphonyLF__Country__c=Country.Id;
        insert pat; 
        
        DocuSignReviewer__c Reviewer = new DocuSignReviewer__c();
        Reviewer.Person__c = inv.id;
        Reviewer.recordId__c = pat.id;
        Reviewer.IsDocuSign__c=true;
        insert Reviewer;
        
        SymphonyLF__Patent_Attachments__c Attachments = new SymphonyLF__Patent_Attachments__c();
        Attachments.SymphonyLF__Version__c = 'Final';
        Attachments.SymphonyLF__Document_Type__c='Application Draft';
        Attachments.SymphonyLF__Patent__c = pat.id;
        insert Attachments;
       
        DocuSign_Document__c DocuSignDocument = new DocuSign_Document__c();
        DocuSignDocument.Name='Assignment';
        DocuSignDocument.IsActive__c = true;
        insert DocuSignDocument;
        string DocuSignDocumentId= DocuSignDocument.Id;
        
        ContentVersion cvlist = new Contentversion(); 
		cvlist.Title = 'CZDSTOU'; 
		cvlist.PathOnClient = 'test'; 
		cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cvlist;
        
        List<ContentVersion> cvl = [SELECT Id, ContentDocumentId,Title, PathOnClient,VersionData FROM ContentVersion WHERE Id=:cvlist.Id ];
        string ContentDocumentId = cvl[0].ContentDocumentId;
        
        DocuSignDetails__c DocuSignDetails = new DocuSignDetails__c();
        DocuSignDetails.DocuSign_Document__c=DocuSignDocument.Id;
        DocuSignDetails.recordId__c = pat.id;
        DocuSignDetails.ContentDocumentId__c = cvl[0].ContentDocumentId;
        insert DocuSignDetails;
        string DocuSignedId=DocuSignDetails.Id;
        
        
       
        
        
		
        ContentDocumentLink DocuSigncdl = new ContentDocumentLink();
        DocuSigncdl.ContentDocumentId = cvl[0].ContentDocumentId;
        DocuSigncdl.LinkedEntityId = DocuSignDocument.id;
        insert DocuSigncdl;
        
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cvl[0].ContentDocumentId;
        cdl.LinkedEntityId = Attachments.id;
        insert cdl;
        
        ContentDocumentLink Patentcdl = new ContentDocumentLink();
        Patentcdl.ContentDocumentId = cvl[0].ContentDocumentId;
        Patentcdl.LinkedEntityId = pat.id;
        insert Patentcdl;
        
        iManage_Workspace__c Workspace = new iManage_Workspace__c();
        Workspace.recordId__c = pat.Id;
        Workspace.id__c=pat.Id;
        insert Workspace; 
        
        iManage_Setting__c iSetting = new iManage_Setting__c();
        iSetting.Workspaces__c = Workspace.Id;
        iSetting.Name__c=pat.Id;
        iSetting.IsProcessed__c=false;
        insert iSetting;
        
        iManage_Folders__c Folders = new iManage_Folders__c();
        Folders.id__c = pat.Id;
        Folders.recordId__c = pat.Id;
        Folders.Name__c=pat.Id;
        Folders.IsConfigured__c=false;
        insert Folders;
        
        iManage_Documents__c Documents = new iManage_Documents__c();
        Documents.id__c = pat.Id;
        Documents.ContentVersionId__c = cvlist.Id;
        Documents.Name__c=pat.Id;
        Documents.size__c='200';
        Documents.iManage_Folders__c=Folders.Id;
        insert Documents;
        
        Test.startTest();
        List<string> PatentId = new List<string>();
        PatentId.add(Folders.Id);
        cmpAPiManageTrgUtilCtrl.UpdateParentFolder(PatentId);
        cmpAPiManageTrgUtilCtrl.getParentId(pat.Id);
        
        List<string> DocsPatentId = new List<string>();
        DocsPatentId.add(Documents.Id);
		cmpAPiManageTrgUtilCtrl.CreateiManageDocumentsfuture(DocsPatentId);
        
        cmpAPiManageTrgUtilCtrl.CreateFileExplorerFile(DocsPatentId);
        
            
        List<string> FolderPatentId = new List<string>();
        FolderPatentId.add(Folders.Id);
        cmpAPiManageTrgUtilCtrl.CreateiManageFolderfuture(FolderPatentId);
            
            
      	Test.stopTest();
        
    }
    
  
}