public with sharing class cmpDocuSignOther {
    @AuraEnabled
    public string inventorNames{get;set;}
    @AuraEnabled
    public string DocumentId{get;set;}
    @AuraEnabled
    public string PageNumber{get;set;}
    @AuraEnabled
    public integer XPosition{get;set;}
    @AuraEnabled
    public integer YPosition{get;set;}
   
    public cmpDocuSignOther() {
    }
    
    public cmpDocuSignOther(string vinventorNames, string vDocumentId, string vPageNumber, integer vXPosition, integer vYPosition) {
        inventorNames = vinventorNames;
        DocumentId = vDocumentId;
        PageNumber = vPageNumber;
        XPosition = vXPosition;
        YPosition = vYPosition; 
    }
    
}