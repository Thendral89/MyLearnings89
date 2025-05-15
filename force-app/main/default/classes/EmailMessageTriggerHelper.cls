/**
* EmailMessageTriggerHelper.cls
* Downloads EML and uploads it to iManage.
*/
public with sharing class EmailMessageTriggerHelper {
    
    //@future(callout=true)
    public static void uploadEmailsToIManagefuture(Set<Id> emailMessageIds) {
        EmailMessageTriggerHelper.uploadEmailsToIManage(emailMessageIds);
    }
    
    public static void uploadEmailsToIManage(Set<Id> emailMessageIds) {
        List<Id> contentVersionEmailIds = new List<Id>();
        List<EmailMessage> emailUpdates = new List<EmailMessage>();
        List<EmailMessage> emailsToProcess = [ SELECT Id, Subject, HtmlBody, Sync_to_iManage__c FROM EmailMessage WHERE Id IN :emailMessageIds ];
        
        for (EmailMessage em : emailsToProcess) {
            try {
                String base64Eml = mvEmailUtilities.createEmlFromEmail(em.Id, em.HtmlBody);
                Blob emlBlob = EncodingUtil.base64Decode(base64Eml);
                ContentVersion cv = new ContentVersion(
                    Title        = em.Subject + '_' + System.today().format() + '.eml',
                    PathOnClient = em.Subject + '_' + System.today().format() + '.eml',
                    VersionData  = emlBlob,
                    IsMajorVersion = true
                );
                insert cv; 
                
                
                EmailMessage emUpdate = new EmailMessage(
                    Id                  = em.Id,
                    ContentVersionID__c = cv.Id
                );
                emailUpdates.add(emUpdate);
                
                contentVersionEmailIds.add(em.Id);
                
            } catch (Exception ex) {
                System.debug('Error in uploadEmailsToIManage: ' + ex.getMessage());
            }
        }
        
        
        if (!emailUpdates.isEmpty()) 
            update emailUpdates;
        
        if (!contentVersionEmailIds.isEmpty()) {
            cmpAPiManagDocumentCtrl.UploadDocumentEMLfuture(contentVersionEmailIds);
        }
    }
}