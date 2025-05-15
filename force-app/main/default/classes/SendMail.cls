Global class SendMail {   
     
     public class MailParameter{
        @InvocableVariable
        public List<Id> ConDocIDs;
        @InvocableVariable(required=true)
        public String tosub;
         @InvocableVariable(required=true)
        public List<String> sendTo;
        @InvocableVariable(required=true)
        public String messageBody;
        @InvocableVariable
        public List<String> bccAddresses;
        @InvocableVariable
        public List<String> ccAddresses;  
         
        @InvocableVariable(required=false)
        public String whatId;
        
         
             
    }
    
    @InvocableMethod
    public static void SendMailMethod(MailParameter [] mailParameters) {      
                List<Messaging.SingleEmailMessage> myListofMails = NEW List<Messaging.SingleEmailMessage>();
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage(); 
                if(MailParameters[0].ConDocIDs != Null) {
                List<ContentVersion> Contentversionlist = [select id,VersionData,Title,PathOnClient,ContentDocumentId from ContentVersion where (ContentDocumentId IN:MailParameters[0].ConDocIDs OR Id IN:MailParameters[0].ConDocIDs)];
                for (ContentVersion document: Contentversionlist) {
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setBody(document.VersionData); 
                    attachment.setFileName(document.Title);
                    attachments.add(attachment);
                }
                semail.setFileAttachments(attachments);
                }
                
                semail.setSubject(MailParameters[0].tosub);  
        
        		if(MailParameters[0].whatId!=null)
        		semail.setWhatId(MailParameters[0].whatId);
        
                semail.setToAddresses(MailParameters[0].sendTo);
                if(MailParameters[0].bccAddresses != Null && !MailParameters[0].bccAddresses.contains(null))
                {
                semail.setBccAddresses(MailParameters[0].bccAddresses);
                }
                if(MailParameters[0].ccAddresses!= Null && !MailParameters[0].ccAddresses.contains(null))
                {
                semail.setCcAddresses(MailParameters[0].ccAddresses);
                }
                system.debug(semail);
                semail.setHtmlBody(MailParameters[0].messageBody); 
                myListofMails.add(semail);            
                    System.debug('myListofMails'+ myListofMails.size());
                    if(myListofMails.size()>0) 
                    {
                        try {
                            Messaging.reserveSingleEmailCapacity(myListofMails.size());
                            Messaging.sendEmail(myListofMails);
                            System.debug('Your done! Mail sent successfully');
                        } catch (Exception e) {
                            System.debug('You have used up your daily allowance of mails');
                        }
                    }
    }               
}