@isTest
public class  cmpDocuSignCreateEnvelopeCtrlTest {

    
    static testmethod void documentDocuSign(){
        
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
        
      
        
        SymphonyLF__Patent_Attachments__c Attachments = new SymphonyLF__Patent_Attachments__c();
        Attachments.SymphonyLF__Version__c = 'Final';
        Attachments.SymphonyLF__Document_Type__c='Application Draft';
        Attachments.SymphonyLF__Patent__c = pat.id;
        insert Attachments;
        
        DocuSignReviewer__c Reviewer = new DocuSignReviewer__c();
        Reviewer.Person__c = inv.id;
        Reviewer.recordId__c = pat.id;
        Reviewer.IsDocuSign__c=true;
        insert Reviewer;
              
        DocuSign_Document__c DocuSignDocument = new DocuSign_Document__c();
        DocuSignDocument.Name='Assignment';
        DocuSignDocument.IsActive__c = true;
        insert DocuSignDocument;
        
         DocuSign_Document__c DocuSignDocument1 = new DocuSign_Document__c();
        DocuSignDocument1.Name='Other Documents';
        DocuSignDocument1.IsActive__c = true;
        insert DocuSignDocument1;
        
        
        ContentVersion cvlist = new Contentversion(); 
		cvlist.Title = 'CZDSTOU'; 
		cvlist.PathOnClient = 'test'; 
		cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cvlist;
        
        List<ContentVersion> cvl = [SELECT Id, ContentDocumentId,Title, PathOnClient,VersionData FROM ContentVersion WHERE Id=:cvlist.Id ];
		
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
        
        EnvelopeInfo__c Envelopes = new EnvelopeInfo__c();
        Envelopes.EnvelopeId__c ='46433ae3-c5ec-45b8-9f96-fcce8d5d1ab9';
        Envelopes.recordId__c = pat.id;
        Envelopes.status__c = 'not started';
        Envelopes.Receivers__c = 'AmarP' + ' (' + 'amar.p@maxval.com'+ ')';
        Envelopes.Person__c = inv.Id;
        insert Envelopes;
        
        
        DocuSignDetails__c DocuSignDetails = new DocuSignDetails__c();
        DocuSignDetails.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignDetails.recordId__c = pat.id;
        insert DocuSignDetails;
        
        DocuSignDetails__c DocuSignDetails1 = new DocuSignDetails__c();
        DocuSignDetails1.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignDetails1.recordId__c = pat.id;
        insert DocuSignDetails1;
        
        DocuSignTab__c DocuSignTab = new DocuSignTab__c();
        DocuSignTab.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab.pageNumber__c = 1;
        DocuSignTab.Tabs__c = 'signHereTabs';
        DocuSignTab.textTabsField__c = '';
        DocuSignTab.XPosition__c = 0;
        DocuSignTab.YPosition__c = 0; 
        DocuSignTab.Document_Type__c='Yes';
        insert DocuSignTab;
       
         DocuSignTab__c DocuSignTab1 = new DocuSignTab__c();
        DocuSignTab1.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab1.pageNumber__c = 1;
        DocuSignTab1.Tabs__c = 'dateSignedTabs';
        DocuSignTab1.textTabsField__c = '';
        DocuSignTab1.XPosition__c = 0;
        DocuSignTab1.YPosition__c = 0; 
        DocuSignTab1.Document_Type__c='Yes';
        insert DocuSignTab1;
        
         DocuSignTab__c DocuSignTab2 = new DocuSignTab__c();
        DocuSignTab2.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab2.pageNumber__c = 1;
        DocuSignTab2.Tabs__c = 'textTabs';
        DocuSignTab2.textTabsField__c = '';
        DocuSignTab2.XPosition__c = 0;
        DocuSignTab2.YPosition__c = 0; 
        DocuSignTab2.Document_Type__c='Yes';
        insert DocuSignTab2;
        
        DocuSignTab__c DocuSignTab3 = new DocuSignTab__c();
        DocuSignTab3.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab3.pageNumber__c = 1;
        DocuSignTab3.Tabs__c = 'checkboxTabs';
        DocuSignTab3.textTabsField__c = '';
        DocuSignTab3.XPosition__c = 0;
        DocuSignTab3.YPosition__c = 0; 
        DocuSignTab3.Document_Type__c='Yes';
        insert DocuSignTab3;
        
        
         DocuSignTab__c DocuSignTab4 = new DocuSignTab__c();
        DocuSignTab4.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab4.pageNumber__c = 1;
        DocuSignTab4.Tabs__c = 'signHereTabs';
        DocuSignTab4.textTabsField__c = '';
        DocuSignTab4.XPosition__c = 0;
        DocuSignTab4.YPosition__c = 0; 
        DocuSignTab4.Document_Type__c='Yes';
        insert DocuSignTab4;
       
         DocuSignTab__c DocuSignTab5 = new DocuSignTab__c();
        DocuSignTab5.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab5.pageNumber__c = 1;
        DocuSignTab5.Tabs__c = 'dateSignedTabs';
        DocuSignTab5.textTabsField__c = '';
        DocuSignTab5.XPosition__c = 0;
        DocuSignTab5.YPosition__c = 0; 
        DocuSignTab5.Document_Type__c='Yes';
        insert DocuSignTab5;
        
         DocuSignTab__c DocuSignTab6 = new DocuSignTab__c();
        DocuSignTab6.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab6.pageNumber__c = 1;
        DocuSignTab6.Tabs__c = 'textTabs';
        DocuSignTab6.textTabsField__c = '';
        DocuSignTab6.XPosition__c = 0;
        DocuSignTab6.YPosition__c = 0;
        DocuSignTab6.Document_Type__c='Yes';
        insert DocuSignTab6;
        
        DocuSignTab__c DocuSignTab7 = new DocuSignTab__c();
        DocuSignTab7.DocuSign_Document__c = DocuSignDocument.Id;
        DocuSignTab7.pageNumber__c = 1;
        DocuSignTab7.Tabs__c = 'checkboxTabs';
        DocuSignTab7.textTabsField__c = '';
        DocuSignTab7.XPosition__c = 0;
        DocuSignTab7.YPosition__c = 0; 
        DocuSignTab7.Document_Type__c='Yes';
        insert DocuSignTab7;
        
        
        DocuSignTab__c DocuSignTab20 = new DocuSignTab__c();
        DocuSignTab20.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab20.pageNumber__c = 1;
        DocuSignTab20.Tabs__c = 'signHereTabs';
        DocuSignTab20.textTabsField__c = '';
        DocuSignTab20.XPosition__c = 0;
        DocuSignTab20.YPosition__c = 0; 
        DocuSignTab20.Document_Type__c='No';
        insert DocuSignTab20;
       
         DocuSignTab__c DocuSignTab21 = new DocuSignTab__c();
        DocuSignTab21.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab21.pageNumber__c = 1;
        DocuSignTab21.Tabs__c = 'dateSignedTabs';
        DocuSignTab21.textTabsField__c = '';
        DocuSignTab21.XPosition__c = 0;
        DocuSignTab21.YPosition__c = 0; 
        DocuSignTab21.Document_Type__c='No';
        insert DocuSignTab21;
        
         DocuSignTab__c DocuSignTab22 = new DocuSignTab__c();
        DocuSignTab22.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab22.pageNumber__c = 1;
        DocuSignTab22.Tabs__c = 'textTabs';
        DocuSignTab22.textTabsField__c = '';
        DocuSignTab22.XPosition__c = 0;
        DocuSignTab22.YPosition__c = 0; 
        DocuSignTab22.Document_Type__c='No';
        insert DocuSignTab22;
        
        DocuSignTab__c DocuSignTab23 = new DocuSignTab__c();
        DocuSignTab23.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab23.pageNumber__c = 1;
        DocuSignTab23.Tabs__c = 'checkboxTabs';
        DocuSignTab23.textTabsField__c = '';
        DocuSignTab23.XPosition__c = 0;
        DocuSignTab23.YPosition__c = 0; 
        DocuSignTab23.Document_Type__c='No';
        insert DocuSignTab23;
        
        
         DocuSignTab__c DocuSignTab24 = new DocuSignTab__c();
        DocuSignTab24.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab24.pageNumber__c = 1;
        DocuSignTab24.Tabs__c = 'signHereTabs';
        DocuSignTab24.textTabsField__c = '';
        DocuSignTab24.XPosition__c = 0;
        DocuSignTab24.YPosition__c = 0; 
        DocuSignTab24.Document_Type__c='No';
        insert DocuSignTab24;
       
         DocuSignTab__c DocuSignTab25 = new DocuSignTab__c();
        DocuSignTab25.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab25.pageNumber__c = 1;
        DocuSignTab25.Tabs__c = 'dateSignedTabs';
        DocuSignTab25.textTabsField__c = '';
        DocuSignTab25.XPosition__c = 0;
        DocuSignTab25.YPosition__c = 0; 
        DocuSignTab25.Document_Type__c='No';
        insert DocuSignTab25;
        
         DocuSignTab__c DocuSignTab26 = new DocuSignTab__c();
        DocuSignTab26.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab26.pageNumber__c = 1;
        DocuSignTab26.Tabs__c = 'textTabs';
        DocuSignTab26.textTabsField__c = '';
        DocuSignTab26.XPosition__c = 0;
        DocuSignTab26.YPosition__c = 0;
        DocuSignTab26.Document_Type__c='No';
        insert DocuSignTab26;
        
        DocuSignTab__c DocuSignTab27 = new DocuSignTab__c();
        DocuSignTab27.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab27.pageNumber__c = 1;
        DocuSignTab27.Tabs__c = 'checkboxTabs';
        DocuSignTab27.textTabsField__c = '';
        DocuSignTab27.XPosition__c = 0;
        DocuSignTab27.YPosition__c = 0; 
        DocuSignTab27.Document_Type__c='No';
        insert DocuSignTab27;
        
        
        DocuSignTab__c DocuSignTab28 = new DocuSignTab__c();
        DocuSignTab28.DocuSign_Document__c = DocuSignDocument1.Id;
        DocuSignTab28.pageNumber__c = 1;
        DocuSignTab28.Tabs__c = 'noteTabs';
        DocuSignTab28.textTabsField__c = '';
        DocuSignTab28.XPosition__c = 0;
        DocuSignTab28.YPosition__c = 0; 
        DocuSignTab28.Document_Type__c='No';
        insert DocuSignTab28;
        
        
            
        List<EnvelopeInfo__c> EnvelopeInfo = [SELECT Id, EnvelopeId__c,Person__c FROM EnvelopeInfo__c WHERE Id =:Envelopes.Id ];
        system.debug('EnvelopeInfo[0].EnvelopeId__c' + EnvelopeInfo[0].EnvelopeId__c);
        
        cmpAPDocuSignSupplimentalAttachment ddsa = new cmpAPDocuSignSupplimentalAttachment();
        ddsa.isChecked = true;
        ddsa.objContentVersion=cvl[0];
       
        List<Id> SupplimentalAttachmentIds = new List<Id>();
		SupplimentalAttachmentIds.add(cvlist.Id);
        Date Target_FilingDate=null;   
        
        Test.startTest();
           cmpDocuSignCreateEnvelopeCtrl.cmpDocuSignBatchMultipleCtrl(EnvelopeInfo[0].Id,pat.Id,SupplimentalAttachmentIds,'',Target_FilingDate,'','','','',inv.Id,'','amar.p@maxval.com','','','','');
           cmpDocuSignCreateEnvelopeCtrl.reviewers('');
        
        Test.stopTest();
        
    }
}