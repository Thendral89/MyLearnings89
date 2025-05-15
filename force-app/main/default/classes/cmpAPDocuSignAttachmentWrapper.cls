public with sharing class cmpAPDocuSignAttachmentWrapper {
    @AuraEnabled
    public string EnvelopeInfo{get;set;}
    @AuraEnabled
    public string ContentVersionId{get;set;}
    @AuraEnabled
    public string Title{get;set;}
   
   
    public cmpAPDocuSignAttachmentWrapper() {
    }
    
    public cmpAPDocuSignAttachmentWrapper(string vEnvelopeInfo, string vContentVersionId, string vTitle) {
        EnvelopeInfo = vEnvelopeInfo;
        ContentVersionId = vContentVersionId;
        Title = vTitle;
    }
    
}