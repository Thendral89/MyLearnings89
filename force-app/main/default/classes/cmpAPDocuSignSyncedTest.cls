@isTest
public class cmpAPDocuSignSyncedTest {
  
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
        insert Envelopes;
        
        
        DocuSignAttachment__c DocuSignAttachment = new DocuSignAttachment__c();
        DocuSignAttachment.EnvelopeInfo__c = Envelopes.id;
        insert DocuSignAttachment;
        List<Id> DocrecordIds = new List<Id>();
        DocrecordIds.add(DocuSignAttachment.Id);
        
        DocuSign_Fields__c DocuSignFields = new DocuSign_Fields__c();
        DocuSignFields.recordId__c = pat.id;
        insert DocuSignFields;
        
        string fileName='Assignment';
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = blob.valueOf(fileName);
        cv.Title = fileName.replace('pdf','');
        cv.PathOnClient = fileName; 
        cv.DocuSignAttachment__c=DocuSignAttachment.Id;
        insert cv;
        
        List<EnvelopeInfo__c> EnvelopeInfo = [SELECT Id, EnvelopeId__c,Person__c FROM EnvelopeInfo__c WHERE Id =:Envelopes.Id ];
        system.debug('EnvelopeInfo[0].EnvelopeId__c' + EnvelopeInfo[0].EnvelopeId__c);
        List<Id> recordIds = new List<Id>();
        recordIds.add(EnvelopeInfo[0].Id);
        
		Test.startTest();
        
        	//cmpAPDocuSignSynced.DocuSignSynced(u1.Id);
        	cmpAPDocuSignSynced.DocuSignDocumentsSynced(recordIds);
        	cmpAPDocuSignSynced.EnvelopeAttachment(DocrecordIds);
            cmpAPDocuSignSynced.reviewers('');
        	
        	
        Test.stopTest();
        
    }
    

}