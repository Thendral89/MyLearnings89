public with sharing class ComponentResponse {
    @AuraEnabled
    public String emailSubject; 
    @AuraEnabled
    public String emailHtmlBody;
    @AuraEnabled
    public List<String> emailToAddressesEmailIds;
    @AuraEnabled
    public List<String> emailToAddressesPersonIds;
    @AuraEnabled
    public List<String> emailCcAddressesPersonIds;

    @AuraEnabled
    public List<String> emailCcAddressesEmailIds;

    @AuraEnabled 
    public List<EmailPreviewFiles> emailPreviewFiles;

    @AuraEnabled 
    public List<String> contentDocumentIds;
    
    public ComponentResponse() {
        
    }
}