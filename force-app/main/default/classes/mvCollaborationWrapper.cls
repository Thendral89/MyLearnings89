/**
 * @description       : mvCollaborationWrapper
 * @last modified on  : 02-05-2025
**/
public without sharing class mvCollaborationWrapper {

    @AuraEnabled public List<collaborationRecord> collaborationRecords = new List<collaborationRecord> ();
    public class collaborationCounts{
        @AuraEnabled public Integer aggregateCollaborations        = 0;
        @AuraEnabled public Integer aggregateEmails                = 0;
        @AuraEnabled public Integer aggregateTasks                 = 0;
        @AuraEnabled public Integer aggregateEmailReceived         = 0;
        @AuraEnabled public Integer aggregateEmailsOut             = 0;
        @AuraEnabled public Integer aggregateFinalDocument         = 0;
    }

    public class collaborationRecord {
        @AuraEnabled public String recordId;
        @AuraEnabled public String createdDate;
        @AuraEnabled public String createdBy;
        @AuraEnabled public String subject;
        @AuraEnabled public String priority;
        @AuraEnabled public String direction;
        @AuraEnabled public String assignedTo;
        @AuraEnabled public String comment;
        @AuraEnabled public String status;
        @AuraEnabled public Boolean hasAttachment;
        @AuraEnabled public String paralegalComment;
        @AuraEnabled public String attorneyComment;
        @AuraEnabled public String agentComment;
        @AuraEnabled public String isIncoming;
        @AuraEnabled public String recordType;
        @AuraEnabled public Boolean isExpanded;
        @AuraEnabled public Boolean isRead;  

        //FinalDocument
        @AuraEnabled public datetime documentDate;
        @AuraEnabled public String documentType;
        @AuraEnabled public String name;
        @AuraEnabled public String matterId;
        @AuraEnabled public String contentUrl;
        @AuraEnabled public String fileExtension;
        @AuraEnabled public String linkedContentId;
    }
}