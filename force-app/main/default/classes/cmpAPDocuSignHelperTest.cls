@isTest
public class cmpAPDocuSignHelperTest {
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
        
         DocuSignReminder__c Reminder = new DocuSignReminder__c(name='Default',
                                         ExpireAfter__c = '2',
                                         ExpireWarn__c='2',
                                         ReminderDelay__c='2',
                                         ReminderFrequency__c='2');
        insert Reminder;
        
        
            
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
        
        
        DocuSignTemplates__c dst = new DocuSignTemplates__c(name='ApplicationDraftFinal',TemplateId__c='c55ed771-66b2-426c-a361-35006107b782');
        insert dst;
        
        EnvelopeInfo__c env = new EnvelopeInfo__c();
        env.EnvelopeId__c ='93bbbb89-827c-431d-92c1-d7c87ec8fd7b';
        env.recordId__c = pat.id;
        env.status__c = 'sent';
        env.Person__c = inv.Id;
        insert env;
        
        DocuSign_Document__c dd = new DocuSign_Document__c(name='test');
        insert dd;
      
        
        List<SymphonyLF__Person__c> objInventors = [SELECT Id, Name, SymphonyLF__Email__c, SymphonyLF__User__r.Email FROM SymphonyLF__Person__c ];
        cmpAPDocuSignRecipient objRecipients = new cmpAPDocuSignRecipient();        
        for(SymphonyLF__Person__c objInventor : objInventors ) {
            objRecipients.recipientName = '';
        	objRecipients.recipientEMailId = objInventor.SymphonyLF__Email__c;
        	objRecipients.recipientRoleName = 'Signer';
        	objRecipients.docketNo = '';
        	objRecipients.applicationNo = '';
        	objRecipients.applicationDate = '';
        	objRecipients.inventionTitle = '';
        	objRecipients.inventorNames = objInventor.Name;
        	objRecipients.inventorNames1 = '';
        	objRecipients.signerName = objInventor.Name;
        	objRecipients.InventorId = objInventor.Id;
           
        }
        
        string fileName='Assignment';
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = blob.valueOf(fileName);
        cv.Title = fileName.replace('pdf','');
        cv.PathOnClient = fileName; 
        insert cv;
        
        test.startTest();
         cmpAPDocuSignHelper.ReplaceWards('ChangeEvent');
         cmpAPDocuSignHelper.getHeader();
         cmpAPDocuSignHelper.CreatedToSent(pat.Id,'1','2');
         cmpAPDocuSignHelper.UseCaseID();
         //cmpAPDocuSignHelper.updateAudit('Insert Success','Patent ChangeEvent','test',true);
         cmpAPDocuSignHelper.getDocument('test','test','test');
         cmpAPDocuSignHelper.getSupplimentalDocument('test','test','test');
         cmpAPDocuSignHelper.getSupplimentalDocuments(pat.id,'test','test');
         cmpAPDocuSignHelper.getSupplimentalDocuments(cv.id,'test','test');
        
         cmpAPDocuSignHelper.getSigner('test', 'SignerName', 'RecipientOrder', 'RoutingOrder', 'Tabs');
         cmpAPDocuSignHelper.getTextTab('test','2','1',2,3);
         cmpAPDocuSignHelper.getSignHereTab('test','2',2,3);
         cmpAPDocuSignHelper.getCheckboxTab('test','2','1',2,3);
         cmpAPDocuSignHelper.getDateSignedTab('test','2',2,3);
         cmpAPDocuSignHelper.resendrequest('1','SignerName','SignerEmail');
         cmpAPDocuSignHelper.getdocusignreminder();
         cmpAPDocuSignHelper.getNotesTab('DocumentId', 'anchorString', 'Value', 0,  0);
         cmpAPDocuSignHelper.getSignatureHereTabAnchorString('DocumentId','anchorString', 'PageNumber', 'XPosition', 'YPosition');
         cmpAPDocuSignHelper.getDateSignedTabAnchorString('DocumentId','anchorString', 'PageNumber', 'XPosition', 'YPosition');
        cmpAPDocuSignHelper.getTextTabValues(pat.Id, 'SymphonyIPM__Patent__c', 'SymphonyIPM__Application_Number__c');
        cmpAPDocuSignHelper.addRecipients('amar.p@maxval.com','Amar Pal','1');
        cmpAPDocuSignHelper.getCC('amar.p@maxval.com','Amar Pal','1','1');
        cmpAPDocuSignHelper.getTextTabAnchorString('1', '1', '#Title', 'Title',1, 1);
        cmpAPDocuSignHelper.getSignHereTabAnchorString('1', '1', '#Title', '1', '1', '1');
        cmpAPDocuSignHelper.getCheckboxTab('1', '1', '1', 1, 1, true, true);
   
        test.stopTest();
        
    }
}