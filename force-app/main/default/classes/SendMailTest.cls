@isTest
public class SendMailTest {
    
    @isTest
    static void testSendMailMethod() {
        // Create test ContentDocument (which will be referenced by ConDocIDs in MailParameter)
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test Document',
            VersionData = Blob.valueOf('Test file content')
        );
        insert testContentVersion;
        
        // Create an email message
        SendMail.MailParameter mailParam = new SendMail.MailParameter();
        
        // Populate MailParameter values
        mailParam.ConDocIDs = new List<Id>{testContentVersion.ContentDocumentId}; // Attach the test ContentDocumentId
        mailParam.tosub = 'Test Subject';
        mailParam.sendTo = new List<String>{'test@example.com'};
        mailParam.messageBody = 'This is a test email body';
        mailParam.bccAddresses = new List<String>{'bcc@example.com'};
        mailParam.ccAddresses = new List<String>{'cc@example.com'};
        
        // Call the SendMailMethod
        Test.startTest();
        SendMail.SendMailMethod(new List<SendMail.MailParameter>{mailParam});
        Test.stopTest();
        
        // Verify that the email was created and sent
        //List<Messaging.SingleEmailMessage> sentEmails = [SELECT Subject, ToAddresses, BccAddresses, CcAddresses, HtmlBody FROM Messaging.SingleEmailMessage];
        
        //System.assertEquals(1, sentEmails.size(), 'One email should have been sent');
        //System.assertEquals('Test Subject', sentEmails[0].getSubject(), 'The subject should be correct');
        //System.assertEquals('test@example.com', sentEmails[0].getToAddresses()[0], 'The "To" address should be correct');
        //System.assertEquals('bcc@example.com', sentEmails[0].getBccAddresses()[0], 'The "BCC" address should be correct');
        //System.assertEquals('cc@example.com', sentEmails[0].getCcAddresses()[0], 'The "CC" address should be correct');
        //System.assertEquals('This is a test email body', sentEmails[0].getHtmlBody(), 'The body should be correct');
    }
}