public class cmpAPiMngDocketingEmailsSendTable {

    public static String generateHTMLTable(List<String> iManageDocumentIds) {
        List<SymphonyLF__Docketing_Activity__c > documents = [SELECT Id,SymphonyLF__Event_Name__c,SymphonyLF__Comments__c,
                                                              SymphonyLF__Due_Date__c,SymphonyLF__Badge_For_Due_Date__c
                                                              FROM SymphonyLF__Docketing_Activity__c 
                                                              WHERE Id IN :iManageDocumentIds
                                                              ORDER BY CreatedDate DESC
                                                              LIMIT 100];
        String htmlTable = '<table border="1" cellpadding="5" cellspacing="0">';
        htmlTable += '<thead><tr>';
        htmlTable += '<th>Flag</th>';
        htmlTable += '<th>Event Name</th>';
        htmlTable += '<th>Comments</th>';
        htmlTable += '<th>Created Date</th>';
        htmlTable += '</tr></thead>';

        htmlTable += '<tbody>';
        for (SymphonyLF__Docketing_Activity__c  doc : documents) {
            htmlTable += '<tr>';
            htmlTable += '<td>' + doc.SymphonyLF__Badge_For_Due_Date__c + '</td>';
            htmlTable += '<td>' + doc.SymphonyLF__Event_Name__c + '</td>';
            htmlTable += '<td>' + (doc.SymphonyLF__Comments__c != null ? doc.SymphonyLF__Comments__c : '') + '</td>';
            htmlTable += '<td>' + (doc.SymphonyLF__Due_Date__c != null ? doc.SymphonyLF__Due_Date__c.format() : 'N/A') + '</td>';
            htmlTable += '</tr>';
        }
        htmlTable += '</tbody>';
        htmlTable += '</table>';
        
        return htmlTable;
    }
    
    @AuraEnabled 
    public static EmailMsg getTemplateDetails(string templateId, String whoId, String whatId,List<String> contentDocumentIds,List<String> iManageDocumentIds){
        List<FileAttachmentWrapper> fawList = new List<FileAttachmentWrapper>();
        List<string> cvIds = new List<string>();
        
        List<iManage_Documents__c> ObjDocuments = new List<iManage_Documents__c>();
        ObjDocuments=[SELECT Id, id__c, ContentVersionId__c
                     From iManage_Documents__c
                     Where Id IN :contentDocumentIds];
         if (ObjDocuments.size() > 0) {
             for (iManage_Documents__c rData : ObjDocuments) {
               cvIds.add(rData.ContentVersionId__c);  
             }
         }
        
        EmailTemplate[] owea = new List<EmailTemplate>([SELECT Subject,Id, Name,DeveloperName FROM EmailTemplate Where DeveloperName=: templateId]);
        if ( owea.size() > 0 ) {
            templateId=owea[0].Id;
        }
        string DocketingActivitiesTable=cmpAPiMngDocketingEmailsSendTable.generateHTMLTable(iManageDocumentIds);
        
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, WhatId,Messaging.AttachmentRetrievalOption.METADATA_ONLY);
        EmailMsg msg = new EmailMsg();
        msg.subject = email.getSubject();
        string HtmlBody=email.getHtmlBody();
        HtmlBody=HtmlBody.replace('#DocketingTable',DocketingActivitiesTable);
        msg.body = HtmlBody;
        
        
        for(ContentVersion cv : [SELECT Id, Title, FileType, FileExtension,VersionData, isLatest, ContentDocumentId FROM ContentVersion
                                 WHERE isLatest = true AND 
                                 (Id IN :cvIds OR ContentDocumentId IN :cvIds) ]){
                                     FileAttachmentWrapper faw = new FileAttachmentWrapper();
                                     faw.attachId = cv.ContentDocumentId;
                                     faw.isContentDocument = true;                               
                                     faw.filename = cv.title+'.'+cv.fileextension;
                                     fawList.add(faw);
            } 
        
        system.debug('fawList ' + fawList);
        
        msg.fileattachments = fawList;
        if(String.isblank(msg.body)){
	        msg.body = email.getPlainTextBody();
            if(String.isNotBlank(msg.body)){
                msg.body = msg.body.replace('\n', '<br/>');
            }
        }
        return msg;   
    }
    
    public class FileAttachmentWrapper{
        @AuraEnabled public String attachId;
        @AuraEnabled public String fileName;
        @AuraEnabled public boolean isContentDocument;
    }
    
	public class EmailMsg{
        @AuraEnabled public string subject;
        @AuraEnabled public string body;        
        @AuraEnabled public List<FileAttachmentWrapper> fileAttachments;
    }
    
}