@isTest
public class cmpAPDocuSignCtrlTest {
  
    
    static testmethod void documentDocuSignDashboard(){
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
        
        DateTime dt = DateTime.now();
        String batchInstanceId = UserInfo.getUserId()+dt.format('yyyyMMddhhmmss');
        EnvelopeInfo__c Envelopes = new EnvelopeInfo__c();
        Envelopes.EnvelopeId__c ='46433ae3-c5ec-45b8-9f96-fcce8d5d1ab9';
        Envelopes.recordId__c = pat.id;
        Envelopes.status__c = 'created';
        Envelopes.Person__c = inv.Id;
        Envelopes.batchInstanceId__c=batchInstanceId;
        Envelopes.Receivers__c = inv.Id;
        insert Envelopes;
        
        DocuSign_Fields__c DocuSignFields = new DocuSign_Fields__c();
        DocuSignFields.recordId__c = pat.id;
        insert DocuSignFields;
        
        
        List<EnvelopeInfo__c> EnvelopeInfo = [SELECT Id, EnvelopeId__c,Person__c FROM EnvelopeInfo__c WHERE Id =:Envelopes.Id ];
        system.debug('EnvelopeInfo[0].EnvelopeId__c' + EnvelopeInfo[0].EnvelopeId__c);
        
              
        List<Id> EnvelopeIds = new List<Id>();
        EnvelopeIds.add(EnvelopeInfo[0].Id);
        cmpAPDocuSignCtrl.UpdatebatchInstanceId(EnvelopeIds);
        cmpAPDocuSignCtrl.deleteAttachment(cvlist.id,pat.Id);
        cmpAPDocuSignCtrl.SelectDocuSignedFromFiles(cvlist.Id,pat.Id);
            
        
    }
    
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
        
         DocuSignReminder__c DocuSignReminder = new DocuSignReminder__c(name='Default',
                                         ExpireAfter__c = '2',
                                         ExpireWarn__c='2',
                                         ReminderDelay__c='2',
                                         ReminderFrequency__c='2');
        insert DocuSignReminder;
        
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
        Envelopes.status__c = 'sent';
        Envelopes.Person__c = inv.Id;
        Envelopes.Receivers__c = inv.Id;
        insert Envelopes;
        
        DocuSign_Fields__c DocuSignFields = new DocuSign_Fields__c();
        DocuSignFields.recordId__c = pat.id;
        insert DocuSignFields;
        
        
        List<EnvelopeInfo__c> EnvelopeInfo = [SELECT Id, EnvelopeId__c,Person__c FROM EnvelopeInfo__c WHERE Id =:Envelopes.Id ];
        system.debug('EnvelopeInfo[0].EnvelopeId__c' + EnvelopeInfo[0].EnvelopeId__c);
        
        
        cmpAPDocuSignCtrl.UpdateDocuSignRecord(EnvelopeInfo[0].Id,'Status__c','Completed');
        cmpAPDocuSignCtrl.OnDeleted(pat.Id, EnvelopeInfo[0].EnvelopeId__c);
        cmpAPDocuSignCtrl.getReminder(pat.Id);
        cmpAPDocuSignCtrl.setReminder(pat.Id,'2','2','2','2');
        cmpAPDocuSignCtrl.getProcessingJobStatus(pat.Id);
        List<cmpAPDocuSignSupplimentalAttachment> Filttachments = cmpAPDocuSignCtrl.GetDocuSigned(pat.Id);
        cmpAPDocuSignCtrl.EditAttachment(Filttachments,pat.Id);
        cmpAPDocuSignCtrl.SelectDocuSignedFromFiles(cvl[0].Id,cvl[0].ContentDocumentId);
     	cmpAPDocuSignCtrl.ContentVersionUpdate(cvl[0].Id,'DocuSign');
        
        cmpAPDocuSignCtrl.deleteAttachment(cvlist.id,pat.Id);
        
        
        cmpAPDocuSignCtrl.getEnvelopeIdStatus(EnvelopeInfo[0].id);
        cmpAPDocuSignCtrl.DocuSignSyncedRequest(EnvelopeInfo[0].id);
        
        cmpAPDocuSignCtrl.getemailbody('Patent');
        cmpAPDocuSignCtrl.getEnvelopes(pat.id);
        //cmpAPDocuSignCtrl.resubmitDocumentForSignatureAPI(pat.id);
        cmpAPDocuSignCtrl.getSupplimentalAttachments(pat.id);
        
        
        //cmpAPDocuSignCtrl.OnDeleted(pat.id,EnvelopeInfo[0].EnvelopeId__c);
        cmpAPDocuSignCtrl.getEnvelopeStatusForAll(pat.id);
        cmpAPDocuSignCtrl.getEnvelopeStatus(EnvelopeInfo[0].EnvelopeId__c);
        cmpAPDocuSignCtrl.EnvelopeIdUpdateStatus('sent',EnvelopeInfo[0].EnvelopeId__c);
        //cmpAPDocuSignCtrl.getEnvelopeAttachments(EnvelopeInfo[0].EnvelopeId__c);
        //cmpAPDocuSignCtrl.getEnvelopeAttachment(EnvelopeInfo[0].EnvelopeId__c, EnvelopeInfo[0].Id,'1','fileName');
        //cmpAPDocuSignCtrl.getEnvelopeDocuments(EnvelopeInfo[0].EnvelopeId__c, Envelopes.Id,'1','fileName');
        //cmpAPDocuSignCtrl.getEnvelopeStatusEnvelopeId(pat.id,EnvelopeInfo[0].EnvelopeId__c);
        cmpAPDocuSignCtrl.getEnvelopecertificates(pat.id,EnvelopeInfo[0].EnvelopeId__c);
        cmpAPDocuSignCtrl.Sendingview(pat.id,EnvelopeInfo[0].EnvelopeId__c);
        
        cmpAPDocuSignCtrl.UnSelectedInventors(pat.id,true);
        cmpAPDocuSignCtrl.SelectInventors(EnvelopeInfo[0].Person__c,pat.id,true);
        cmpAPDocuSignCtrl.getEnvelopesInventors(pat.id);
      
        cmpAPDocuSignCtrl.GetDocuSigned(pat.id);
        cmpAPDocuSignCtrl.DeletedDocuSignedId(DocuSignDocument.Id,pat.id);
        //cmpAPDocuSignCtrl.UpdateDocuSignRecord(Envelopes.Id,'status__c','sent');
        cmpAPDocuSignCtrl.UpdateRecord(pat.Id,'SymphonyIPM__Patent_Number__c','US712837');
        cmpAPDocuSignCtrl.OnDocuSignReview(Envelopes.Id,'');
        cmpAPDocuSignCtrl.ValidateDocuSignFields(pat.Id);
        //cmpAPDocuSignCtrl.UpdateDateRecord(pat.Id,'Application_No__c',Date.newInstance(2016, 11, 9));
        cmpAPDocuSignCtrl.getIsReviewBeforeSend('Patent');
        //cmpAPDocuSignCtrl.reviewers('created');
        
    }
    
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
        
        EnvelopeInfo__c Envelopes = new EnvelopeInfo__c();
        Envelopes.EnvelopeId__c ='46433ae3-c5ec-45b8-9f96-fcce8d5d1ab9';
        Envelopes.recordId__c = pat.id;
        Envelopes.status__c = 'sent';
        Envelopes.Person__c = inv.Id;
        Envelopes.Receivers__c = inv.Id;
        insert Envelopes;
        
        List<EnvelopeInfo__c> EnvelopeInfo = [SELECT Id, EnvelopeId__c,Person__c FROM EnvelopeInfo__c WHERE Id =:Envelopes.Id ];
        system.debug('EnvelopeInfo[0].EnvelopeId__c' + EnvelopeInfo[0].EnvelopeId__c);
      
        cmpAPDocuSignSupplimentalAttachment ddsa = new cmpAPDocuSignSupplimentalAttachment();
        ddsa.isChecked = true;
        ddsa.objContentVersion=cvl[0];
        
        Test.startTest();
        	string AppDate= string.valueof(Date.newInstance(2016, 11, 9));
        	cmpAPDocuSignCtrl.UpdateDateRecord(pat.Id,'Application_No__c',AppDate);
        	cmpAPDocuSignCtrl.DocuSignAttachment (EnvelopeInfo[0].EnvelopeId__c,cvlist.Id,'Amar');
            cmpAPDocuSignCtrl.SelectDocuSignedId(ContentDocumentId, DocuSignDocumentId,pat.Id);
        	string Sendingview = cmpAPDocuSignCtrl.Sendingview(pat.id,EnvelopeInfo[0].EnvelopeId__c);
        	cmpAPDocuSignCtrl.ReSending(EnvelopeInfo[0].EnvelopeId__c);
        	cmpAPDocuSignCtrl.deleteAttachment(cvlist.id,pat.Id);
        	cmpAPDocuSignCtrl.SelectDocuSignedFromFiles(cvlist.Id,pat.Id);
        	//(String PatentID, List<cmpAPDocuSignSupplimentalAttachment> SupplimentalAttachments, String emailBody, boolean IsPatent, String IsStatus, boolean IsMultipleSignatures,string ExpireAfter,string ExpireWarn,string ReminderDelay,string ReminderFrequency) {
        	cmpAPDocuSignCtrl.SubmitMultipleSignaturesAPI(pat.id,new list<cmpAPDocuSignSupplimentalAttachment>{ddsa}, 'Docusign',true, 'sent',false,'2','2','2','2');
      	Test.stopTest();
        
    }
}