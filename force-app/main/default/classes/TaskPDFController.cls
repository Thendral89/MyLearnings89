public class TaskPDFController { 
    public List<ContentVersion> contentVersionList { get; set; }
    public Integer contentVersionSize { get; set; }
    public String relatedObjectName { get; set; }
    public String relatedObjectField { get; set; }
    public String relatedObjectRecordId { get; set; }
    public String relatedObjectFieldValue { get; set; }

    public TaskPDFController(ApexPages.StandardController controller) {
        Task tsk = [SELECT Id, Subject, WhatId FROM Task WHERE Id = :controller.getId()];
        
        String fileName = 'Task' + tsk.Subject + '.pdf';
        ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="' + fileName + '"');
        
        List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId = :tsk.Id];
        if (docLinks.isEmpty()) {
            contentVersionList = new List<ContentVersion>();
            contentVersionSize = 0;
        } else {
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink link : docLinks) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
            
            contentVersionList = [SELECT Id, Title, FileExtension, ContentDocumentId, PathOnClient, CreatedDate
                                  FROM ContentVersion
                                  WHERE ContentDocumentId IN :contentDocumentIds
                                  ORDER BY CreatedDate DESC];
            
            contentVersionSize = contentVersionList.size();
        }
        
        if (tsk.WhatId != null) {
        
                relatedObjectName = tsk.WhatId.getSObjectType().getDescribe().getName();
                relatedObjectRecordId = String.valueOf(tsk.WhatId);               
                String query = 'SELECT Name FROM ' + relatedObjectName + ' WHERE Id = :relatedObjectRecordId';
             
                List<SObject> relatedRecords = Database.query(query);
                
                if (!relatedRecords.isEmpty()) {
                    SObject relatedRecord = relatedRecords[0];
                    relatedObjectFieldValue = (String) relatedRecord.get('Name');
                } else {
                    relatedObjectFieldValue = 'Related record not found';
                }
            } 
         else {
            relatedObjectFieldValue = 'No related record';
        }
    }
}