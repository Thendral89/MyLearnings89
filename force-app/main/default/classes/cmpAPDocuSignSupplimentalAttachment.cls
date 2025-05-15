public with sharing class cmpAPDocuSignSupplimentalAttachment {
    @AuraEnabled
    public Boolean isChecked {get;set;}
    @AuraEnabled
    public String isFinalDoc {get;set;}
    @AuraEnabled
    public String docTitle {get;set;}
    @AuraEnabled
    public String ContentDocumentId {get;set;}    
    @AuraEnabled
    public ContentVersion objContentVersion{get;set;}
    @AuraEnabled
    public String CVId{get;set;}
    
    /*
    public cmpAPDocuSignSupplimentalAttachment (Boolean isChecked, Boolean isFinalDoc, String docTitle, ContentVersion objContentVersion)
    {
        this.isChecked = isChecked;
        this.isFinalDoc = isFinalDoc;
        this.docTitle = docTitle;
        this.objContentVersion = objContentVersion;
    } 
    */
    public cmpAPDocuSignSupplimentalAttachment ()
    {
        this.isChecked = false;
        this.isFinalDoc = '';        
        this.docTitle = '';
        this.objContentVersion = null;
        this.CVId = '';
    }
    
}