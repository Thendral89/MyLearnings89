public with sharing class cmpAPDocuSignRecipient {
    @AuraEnabled
    public string recipientName{get;set;}
    @AuraEnabled
    public string recipientEMailId{get;set;}
    @AuraEnabled
    public string recipientRoleName{get;set;}
    @AuraEnabled
    public string docketNo{get;set;}
    @AuraEnabled
    public string applicationNo{get;set;}
    @AuraEnabled
    public string applicationDate{get;set;}
    @AuraEnabled
    public string inventionTitle{get;set;}
    @AuraEnabled
    public string inventorNames{get;set;}
    @AuraEnabled
    public string inventorNames1{get;set;}
    @AuraEnabled
    public string signerName{get;set;}
     @AuraEnabled
    public string InventorId{get;set;}
    
    public cmpAPDocuSignRecipient() {
    }
    
    public cmpAPDocuSignRecipient(string strRecipientName,string strRecipientEMailId, string strRecipientRoleName, string strDocketNo, string strApplicationNo, string strApplicationDate, string strInventionTitle, string strInventorNames, string strInventorNames1, string strSignerName, string strInventorId) {
        recipientName = strRecipientName;
        recipientEMailId = strRecipientEMailId;
        recipientRoleName = strRecipientRoleName;
        docketNo = strDocketNo;
        applicationNo = strApplicationNo;
        applicationDate = strApplicationDate;
        inventionTitle = strInventionTitle;
        inventorNames = strInventorNames;
        inventorNames1 = strInventorNames1;
        signerName = strSignerName;
        InventorId = strInventorId;
        
    }
    
}