public with sharing class cmpAPDocuSignEnvelopeDocuments{
    @AuraEnabled
    public string envelopeId{get;set;}
    
    @AuraEnabled
    public List<cmpAPDocuSignEnvelopeDocument> envelopeDocuments{get;set;}
}