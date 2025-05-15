public with sharing class cmpAPDocuSignResponse {
    @AuraEnabled
    public string envelopeId {get;set;}
    @AuraEnabled
    public string uri {get;set;}
    
    @AuraEnabled
    public string statusDateTime {get;set;}
    @AuraEnabled
    public string errorMessage {get;set;}
    
    @AuraEnabled
    public string errorCode {get;set;}
    @AuraEnabled
    public string message {get;set;}
    
    @AuraEnabled
    public string status {get;set;}
    @AuraEnabled
    public string documentsUri{get;set;}
    @AuraEnabled
    public string recipientsUri{get;set;}
    @AuraEnabled
    public string attachmentsUri{get;set;}
    @AuraEnabled
    public string envelopeUri{get;set;}
    @AuraEnabled
    public string emailSubject{get;set;}
    @AuraEnabled
    public string emailBlurb{get;set;}
    @AuraEnabled
    public string customFieldsUri{get;set;}
    @AuraEnabled
    public string autoNavigation{get;set;}
    @AuraEnabled
    public string envelopeIdStamping{get;set;}
    @AuraEnabled
    public string notificationUri{get;set;}
    @AuraEnabled
    public string enableWetSign{get;set;}
    @AuraEnabled
    public string allowMarkup{get;set;}
    @AuraEnabled
    public string allowReassign{get;set;}
    @AuraEnabled
    public string createdDateTime{get;set;}
    @AuraEnabled
    public string lastModifiedDateTime{get;set;}
    @AuraEnabled
    public string deliveredDateTime{get;set;}
    @AuraEnabled
    public string initialSentDateTime{get;set;}
    @AuraEnabled
    public string sentDateTime{get;set;}
    @AuraEnabled
    public string completedDateTime{get;set;}
    @AuraEnabled
    public string statusChangedDateTime{get;set;}
    @AuraEnabled
    public string documentsCombinedUri{get;set;}
    @AuraEnabled
    public string certificateUri{get;set;}
    @AuraEnabled
    public string templatesUri{get;set;}
    @AuraEnabled
    public string brandId{get;set;}
    @AuraEnabled
    public string purgeState{get;set;}
    @AuraEnabled
    public string is21CFRPart11{get;set;}
    @AuraEnabled
    public string signerCanSignOnMobile{get;set;}
    @AuraEnabled
    public string isSignatureProviderEnvelope{get;set;}
    @AuraEnabled
    public string allowViewHistory{get;set;}
    @AuraEnabled
    public string voidedDateTime{get;set;}
    @AuraEnabled
    public string voidedReason{get;set;}
    @AuraEnabled
    public string declinedDateTime{get;set;}
    @AuraEnabled
    public string disableResponsiveDocument{get;set;}
}