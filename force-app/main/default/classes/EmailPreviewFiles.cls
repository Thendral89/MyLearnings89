public with sharing class EmailPreviewFiles {
    public EmailPreviewFiles() {

    }

    @AuraEnabled
    public String fileName;
    @AuraEnabled
    public Id documentId;
    @AuraEnabled
    public Id documentVersionId;
}