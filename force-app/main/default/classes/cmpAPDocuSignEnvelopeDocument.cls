public with sharing class cmpAPDocuSignEnvelopeDocument {
    @AuraEnabled
    public string documentId {get;set;}
    @AuraEnabled
    public string name{get;set;}
    @AuraEnabled
    public string type{get;set;}
    @AuraEnabled
    public string uri{get;set;}
    @AuraEnabled
    public string order{get;set;}
    @AuraEnabled
    public string pages{get;set;}
    @AuraEnabled
    public List<AvailableDocumentType> availableDocumentTypes{get;set;}
    @AuraEnabled
    public string display{get;set;}
    @AuraEnabled
    public string includeInDownload{get;set;}
    @AuraEnabled
    public string signerMustAcknowledge{get;set;}
    @AuraEnabled
    public string authoritativeCopy{get;set;}
    
   public class AvailableDocumentType
    {
        @AuraEnabled
        public string type{get;set;}
        @AuraEnabled
        public string isDefault{get;set;}
    }
}