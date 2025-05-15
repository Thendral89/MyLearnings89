/**
 * @description       : 
 * @last modified on  : 05-05-2025
**/
public without sharing class mvCollaborationService {
    static SymphonyLF__Person__c loggedInUserPerson;
    static User loggedInUser;
    static String loggedInUsersEmailDomain;
    static Map<Id, SymphonyLF__Email_Tracker__c> emailTrackerByMessage = new Map<Id, SymphonyLF__Email_Tracker__c>();
    static Set<Id> emailMessageCaseIds = new Set<Id>();
    final static String PROFILE_OUTSIDE_COUNSEL = 'Platform Outside Counsel';
    final static String MULTIPLE_EMAILS_DELIMITER = ';';
    final static String RECORD_TYPE_EMAIL = 'EMAIL';
    final static String RECORD_TYPE_TASK = 'TASK';

    @AuraEnabled
    public static List<mvCollaborationWrapper.collaborationRecord> getCollaborationRecords(String recordId){
        getUsersEmailDomain();
        findLoggedInUser();
        findEmailTracker(recordId);
        List<mvCollaborationWrapper.collaborationRecord> collaborationRecords = new List<mvCollaborationWrapper.collaborationRecord>();
        findEmailMessages(collaborationRecords, recordId);
        findTasks(collaborationRecords, recordId);
        //findFinalDocuments(collaborationRecords, recordId);

        SortCreatedDate compare = new SortCreatedDate();
        collaborationRecords.sort( compare );
        
        return collaborationRecords;

    }

    @AuraEnabled
    public static List<Object> getEmailTrackersByEmailMessageId(Id emailMessageId) {
        List<SymphonyLF__Email_Tracker__c> trackers = [
            SELECT Id, Name, CreatedDate, SymphonyLF__Tracking_Status__c, 
                SymphonyLF__Related_Record_Name__c,
                SymphonyLF__Related_To__c,
                //Matter__c, Asset_Type__c, Asset_Id__c,
                //Invention_Disclosure_New__r.Name,
                Patent__r.Name,
                //TM_Search_Instruction__r.Name,
                SymphonyLF__Client__r.Name,
                SymphonyLF__Collection__r.Name
                //Mark__r.Name,
                //Proposed_Mark__r.Name,
                //Trademark_Search__r.Name,
                //Copyright_Registration__r.Name,
                //Custom_Recordal__r.Name,
                //Trademark_New__r.Name,
                //Copyright__r.Name
            FROM SymphonyLF__Email_Tracker__c
            WHERE SymphonyLF__Email_Message_Id__c = :emailMessageId
            ORDER BY CreatedDate DESC
        ];
        
        List<Object> resultList = new List<Object>();
        for(SymphonyLF__Email_Tracker__c tracker : trackers) {
            // Convert the sObject to a Map<String, Object>
            Map<String, Object> trackerMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(tracker));
            // Override the CreatedDate field with the formatted string.
            trackerMap.put('CreatedDate', tracker.CreatedDate.format('MMM dd, yyyy, hh:mm a'));
            resultList.add(trackerMap);
        }
        return resultList;
    }


    /* @AuraEnabled
    public static List<Object> getFinalDocumentById(Id finalDocumentId) {
        List<Patent_Document__c> docs = [
            SELECT 
                Id, Name, CreatedDate, AttachmentId__c, Linked_Content_Id__c, Document_ID__c, 
                File_Name_Big__c, Content_Title__c, Upload_Date__c, Asset_Type__c, Document_Type__c, 
                Comments__c, isActive__c, Content_URL__c
            FROM Patent_Document__c
            WHERE Id = :finalDocumentId
            ORDER BY CreatedDate DESC
        ];
        
        List<Object> resultList = new List<Object>();
        for(Patent_Document__c doc : docs) {
            Map<String, Object> docMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(doc));
            docMap.put('CreatedDate', doc.CreatedDate.format('MMM dd, yyyy, hh:mm a'));
            resultList.add(docMap);
        }
        return resultList;
    } */


    /* @AuraEnabled
    public static Map<String, String> getContentVersion(Id finalDocumentId) {
        Map<String, String> result = new Map<String, String>();

        // Fetch the final document(s)
        List<Object> documents = getFinalDocumentById(finalDocumentId);
        if (!documents.isEmpty()) {
            Map<String, Object> docMap = (Map<String, Object>) documents[0]; 
            Id contentDocumentId = (Id) docMap.get('Linked_Content_Id__c');

            if (contentDocumentId != null) {
                ContentVersion contentVersion = [
                    SELECT Id, ContentDocument.FileExtension
                    FROM ContentVersion
                    WHERE ContentDocumentId = :contentDocumentId
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                if (contentVersion != null) {
                    result.put('contentVersionId', contentVersion.Id);
                    result.put('fileExtension', contentVersion.ContentDocument.FileExtension);
                }
            }
        }
        return result.isEmpty() ? null : result;
    } */



    /* static void findFinalDocuments(List<mvCollaborationWrapper.collaborationRecord> collaborationRecords, Id recordId) {
        // Map of Object API Names to Final Document Fields
        Map<String, String> finalDocumentFields = new Map<String, String>{
            'SymphonyLF__Patent__c' => 'Patent__c',
            'SymphonyLF__Trademark_New__c' => 'Trademark__c',
            'D_O_Recommendation__c' => 'D_O_Recommendation__c',
            'SymphonyLF__Dispute_Opposition__c' => 'Dispute_Opposition__c',
            'SymphonyLF__Invention_Disclosure_New__c' => 'Invention_Disclosure__c',
            'SymphonyLF__TM_Search_Instruction__c' => 'TM_Search_Instruction_Ref__c',
            'SymphonyLF__Collection__c' => 'Collection__c',
            'Copyright_Registration__c' => 'Copyright_Registration__c',
            'SymphonyLF__Custom_Recordal__c' => 'Custom_Recordal__c',
            'SymphonyLF__Mark__c' => 'Mark__c',
            'SymphonyLF__Proposed_Mark__c' => 'Proposed_Mark__c',
            'SymphonyLF__Trademark_Search__c' => 'Search_Project__c',
            'SymphonyLF__Copyright__c' => 'Copyright__c',
            'Collection__c' => 'Search_Request__c'
        };
    
        // Get the object type of the provided record ID
        String objectApiName = recordId.getSObjectType().getDescribe().getName();
        String fieldName = finalDocumentFields.get(objectApiName);
    
        if (fieldName != null) {
            String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate, AttachmentId__c, Linked_Content_Id__c, Document_ID__c, ' +
                           'File_Name_Big__c, Content_Title__c, Upload_Date__c, Asset_Type__c, ' +
                           'Document_Type__c, Comments__c, isActive__c, Content_URL__c, Folder_Name__c ' +
                           'FROM Patent_Document__c WHERE ' + fieldName + ' = :recordId';
    
            List<Patent_Document__c> finalDocuments = Database.query(query);
            // Query for content versions
            List<Id> contentDocumentIds = new List<Id>();
            for (Patent_Document__c doc : finalDocuments) {
                if (doc.Linked_Content_Id__c != null) {
                    contentDocumentIds.add(doc.Linked_Content_Id__c);
                }
            }

            Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([
                SELECT Id, FileExtension
                FROM ContentDocument
                WHERE Id IN :contentDocumentIds
            ]);
    
            // Add fetched documents to collaboration records
            for (Patent_Document__c doc : finalDocuments) {
                mvCollaborationWrapper.collaborationRecord collaborationRecord = new mvCollaborationWrapper.collaborationRecord();
                collaborationRecord.recordId = doc.Id;
                collaborationRecord.subject = doc.File_Name_Big__c;
                collaborationRecord.createdDate = doc.LastModifiedDate.format('MMM dd, yyyy, hh:mm a');
                ///String documentType = '<strong>Document Type:</strong> ' + (String.isBlank(doc.Document_Type__c) ? 'N/A' : doc.Document_Type__c);
                collaborationRecord.createdBy = doc.Document_Type__c;
                //collaborationRecord.documentDate = doc.Upload_Date__c;
                collaborationRecord.comment = doc.Comments__c;
                collaborationRecord.contentUrl = doc.Content_URL__c;
                collaborationRecord.documentType = doc.Document_Type__c;
                collaborationRecord.linkedContentId = doc.Linked_Content_Id__c;
                // collaborationRecord.isIncoming = 'In'.equalsIgnoreCase(doc.Folder_Name__c);
                collaborationRecord.isIncoming = doc.Folder_Name__c != null ? doc.Folder_Name__c : '';
                collaborationRecord.recordType = 'FINAL_DOCUMENT';
                collaborationRecord.hasAttachment = String.isNotBlank(doc.AttachmentId__c);
                collaborationRecord.isExpanded = false;
                ContentDocument contentDoc = contentDocuments.get(doc.Linked_Content_Id__c);
                collaborationRecord.fileExtension = (contentDoc != null) ? contentDoc.FileExtension : null;
    
                collaborationRecords.add(collaborationRecord);
            }
        }
    } */
    
    @AuraEnabled
    public static Integer taskCount(Id recordId){
        Set<Id> relatedToIds = new Set<Id>();
        relatedToIds.add( recordId );

        List<Task> taskRecords = 
        [
            SELECT 
                Id,Direction__c FROM Task WHERE WhatId IN :relatedToIds AND TaskSubtype != 'Email' ORDER BY CreatedDate DESC
        ];
        return taskRecords.size(); 
    }

    @AuraEnabled(cacheable=true)
    public static Task getTaskDirection(Id taskId) {
        List<Task> taskRecords = [
            SELECT Id, Direction__c 
            FROM Task 
            WHERE Id = :taskId
            LIMIT 1
        ];
        if (!taskRecords.isEmpty()) {
            return taskRecords[0];
        } else {
            throw new AuraHandledException('Task not found');
        }
    }

    @AuraEnabled
    public static Map <Id, EmailMessage> emailCount(Id recordId){
        Set<Id> relatedToIds = new Set<Id>();
        relatedToIds.add( recordId );
        if( emailMessageCaseIds.size() > 0){
            relatedToIds.addAll( emailMessageCaseIds );
        }
        Map <Id, EmailMessage> emailMessages = new Map <Id, EmailMessage> ([SELECT Id, Incoming FROM EmailMessage WHERE ( RelatedToId IN :relatedToIds OR Id IN :emailTrackerByMessage.keySet() )
                                              ORDER BY MessageDate desc]);
        
        return emailMessages;
    }
    
    @AuraEnabled
    public static Object getEmailMessageObject(String trackerId){
        try {
            List<EmailMessage> messages = [
                SELECT Id, CreatedDate, CcAddress, Incoming, HasAttachment, BccAddress,
                    FromName, FromAddress, ToAddress, HtmlBody, TextBody, Subject
                FROM EmailMessage
                WHERE Id = :trackerId
            ];
            if(messages.isEmpty()){
                return null;
            }
            EmailMessage em = messages[0];
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(em));
            result.put('CreatedDate', em.CreatedDate.format('MMM dd, yyyy, hh:mm a'));
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    static void findTasks(List<mvCollaborationWrapper.collaborationRecord> collaborationRecords, Id recordId){
        Set<Id> relatedToIds = new Set<Id>();
        relatedToIds.add( recordId );

        List<Task> taskRecords = 
        [
            SELECT 
                Id, 
                Subject, 
                Priority, 
                Status, 
                TaskSubtype, 
                Type, 
                Description, 
                CreatedDate,
                LastModifiedDate,
                Paralegal_Comment__c, 
                IsReminderSet, 
                CreatedBy.Name, 
                Direction__c, 
                Task_Type__c, 
                Attorney_Comment__c, 
                Agent_Comment__c, 
                Owner.Name
            FROM 
                Task 
            WHERE 
                WhatId IN :relatedToIds 
                AND 
                TaskSubtype != 'Email' 
            ORDER BY 
                CreatedDate DESC
        ];

        if(taskRecords.size() == 0) return;

        Set<Id> taskIds = new Set<Id>();
        for (Task task : taskRecords) {
            taskIds.add(task.Id);
        }

        Set<Id> tasksWithAttachments = new Set<Id>();

        for (ContentDocumentLink link : 
                [
                    SELECT 
                        LinkedEntityId 
                    FROM 
                        ContentDocumentLink 
                    WHERE LinkedEntityId IN :taskIds
                ]
        ) {
            tasksWithAttachments.add(link.LinkedEntityId);
        }

        for (Task task : taskRecords) {
            mvCollaborationWrapper.collaborationRecord collaborationRecord = new mvCollaborationWrapper.collaborationRecord();
            //String title = (task.SymphonyLF__Title__c != null) ? '\n' + task.SymphonyLF__Title__c : '';
            String taskTypeDisplay = (task.Task_Type__c != null) ? '\n' + task.Task_Type__c : '';

            collaborationRecord.recordId = task.Id;
            collaborationRecord.createdBy = task.CreatedBy.Name;
            collaborationRecord.createdDate = task.LastModifiedDate.format('MMM dd, yyyy, hh:mm a');
            collaborationRecord.subject = task.Subject + taskTypeDisplay;
            collaborationRecord.status = task.Status;
            collaborationRecord.recordType = RECORD_TYPE_TASK;
            collaborationRecord.assignedTo = task.Owner.Name;
            // collaborationRecord.isIncoming = 'In'.equalsIgnoreCase(task.Direction__c);
            collaborationRecord.isIncoming = task.Direction__c != null ? task.Direction__c : '';
            //collaborationRecord.paralegalComment = task.Paralegal_Comment__c;
            //collaborationRecord.attorneyComment = task.Attorney_Comment__c;
            collaborationRecord.hasAttachment = tasksWithAttachments.contains( task.Id );
            collaborationRecord.isExpanded = true;
            String combinedComments = '';
            if (!String.isBlank(task.Paralegal_Comment__c)) {
                combinedComments += '<div style="margin:5px 0;">'
                                 + '<strong>Paralegal Comment:</strong><br/>'
                                 + task.Paralegal_Comment__c
                                 + '</div>';
            }
            if (!String.isBlank(task.Attorney_Comment__c)) {
                combinedComments += '<div style="margin:5px 0;">'
                                 + '<strong>Attorney Comment:</strong><br/>'
                                 + task.Attorney_Comment__c
                                 + '</div>';
            }
            collaborationRecord.comment = task.Description;

            collaborationRecords.add(collaborationRecord);
        }
    }

    static void findEmailMessages(List<mvCollaborationWrapper.collaborationRecord> collaborationRecords, Id recordId){
        Set<Id> relatedToIds = new Set<Id>();
        relatedToIds.add( recordId );
        if( emailMessageCaseIds.size() > 0){
            relatedToIds.addAll( emailMessageCaseIds );
        }
        Map <Id, EmailMessage> emailMessages = new Map <Id, EmailMessage> ([SELECT Id 
                                                  , FromAddress
                                                  , FromName
                                                  , subject
                                                  , Status
                                                  , ToAddress
                                                  , MessageDate
                                                  , CreatedBy.Name
                                                  , CcAddress
                                                  , BccAddress
                                                  , HtmlBody
                                                  , HasAttachment
                                                  , Incoming
                                                  , ParentId
                                               FROM EmailMessage
                                              WHERE ( RelatedToId IN :relatedToIds OR Id IN :emailTrackerByMessage.keySet() )
                                              ORDER BY MessageDate desc]);
        
        if (emailMessages.size() > 0 ){
            //String shortId = String.valueOf(recordId).subString(0, 15);
            String shortId = String.valueOf(recordId);
            Map<Id, String> emailTrackerComments = new Map<Id, String>();
            for(SymphonyLF__Email_Tracker__c emailTracker : [SELECT Id, SymphonyLF__Review_Comments__c,SymphonyLF__Email_RelatedToId__c, RelatedTo_ID__c, SymphonyLF__Email_Message_Id__c, Email_Message_Id__c  FROM SymphonyLF__Email_Tracker__c 
                                                WHERE SymphonyLF__Email_RelatedToId__c = :shortId AND SymphonyLF__Email_Message_Id__c IN: emailMessages.keySet()])
            {
                if(!String.isBlank(emailTracker.SymphonyLF__Review_Comments__c))
                    emailTrackerComments.put(emailTracker.SymphonyLF__Email_Message_Id__c, emailTracker.SymphonyLF__Review_Comments__c);
            }

            for(EmailMessage emailMessage : emailMessages.values()){
                Boolean toAdd = checkAccess(emailMessage);
                if(toAdd == false) continue;

                mvCollaborationWrapper.collaborationRecord collaborationRecord = new mvCollaborationWrapper.collaborationRecord();

                collaborationRecord.recordId = emailMessage.Id;
                collaborationRecord.createdBy = emailMessage.FromAddress;
                collaborationRecord.createdDate = emailMessage.MessageDate.format('MMM dd, yyyy, hh:mm a');
                collaborationRecord.subject = emailMessage.subject;
                // collaborationRecord.isIncoming = emailMessage.Incoming;
                collaborationRecord.isIncoming = emailMessage.Incoming ? 'IN' : 'OUT';
                collaborationRecord.recordType = RECORD_TYPE_EMAIL;
                collaborationRecord.assignedTo = emailMessage.ToAddress;
                collaborationRecord.hasAttachment = emailMessage.HasAttachment;
                collaborationRecord.isExpanded = false;
                //collaborationRecord.isRead = EmailMessage.IsOpened;
                collaborationRecord.comment = emailTrackerComments.get(emailMessage.Id) != null ? emailTrackerComments.get(emailMessage.Id) : ''; 

                collaborationRecords.add(collaborationRecord);
            }
        }
    }

    static Boolean checkAccess(EmailMessage message){
        if( loggedInUser.Profile.Name == PROFILE_OUTSIDE_COUNSEL ){
            List<String> allEmails = new List<String>(); 
            if(String.isNotBlank(message.FromAddress)) allEmails.addAll( message.FromAddress.split( MULTIPLE_EMAILS_DELIMITER ) ) ;
            if(String.isNotBlank(message.ToAddress)) allEmails.addAll( message.ToAddress.split( MULTIPLE_EMAILS_DELIMITER ) ) ;
            if(String.isNotBlank(message.CcAddress)) allEmails.addAll( message.CcAddress.split( MULTIPLE_EMAILS_DELIMITER ) ) ;
            if(String.isNotBlank(message.BccAddress)) allEmails.addAll( message.BccAddress.split( MULTIPLE_EMAILS_DELIMITER ) ) ;

            if( allEmails.size() == 0 ) return false;

            Set<String> emailDomains = new Set<String>();
            for(String m : allEmails){
                if(String.isNotBlank(m)){
                    String domain = findEmailDomain( m );
                    if(
                        String.isNotBlank( domain ) 
                        && 
                        domain.equalsIgnoreCase( loggedInUsersEmailDomain )
                    ){
                        return true;
                    }
                    return false;
                }
            }
        }
        
        return true;
    }

    static void findEmailTracker(Id recordId){
        String temp = recordId;

        for(SymphonyLF__Email_Tracker__c record : [
                SELECT 
                    Id, 
                    SymphonyLF__Review_Comments__c,
                    Email_Message_Id__c, 
                    SymphonyLF__Email_Message_Id__c,
                    CreatedDate,
                    CreatedBy.Name, 
                    From_Address__c, 
                    Email_Type__c, 
                    Direction__c,
                    Assigned_To_User__r.Name, 
                    SymphonyLF__Short_Subject__c, 
                    SymphonyLF__Tracking_Status__c, 
                    Attachment_Available__c 
                FROM 
                    SymphonyLF__Email_Tracker__c 
                WHERE 
                    SymphonyLF__Email_RelatedToId__c = :recordId 
                ] 
            ){           
                if(String.isNotBlank(record.SymphonyLF__Email_Message_Id__c)){
                    emailTrackerByMessage.put(record.SymphonyLF__Email_Message_Id__c, record);
                }                
            }
    }

    static void findLoggedInUser(){
        if(loggedInUser != null){
            return;
        }

        loggedInUser = [
            SELECT 
                Profile.Name 
            FROM 
                User 
            WHERE 
                Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }

    static void getUsersEmailDomain(){
        findLoggedInUserPerson();

        String userEmailDomain = findEmailDomain(UserInfo.getUserEmail());
        String personEmailDomain = findEmailDomain(loggedInUserPerson.SymphonyLF__Email__c);

        loggedInUsersEmailDomain = String.isNotBlank(personEmailDomain) ? personEmailDomain : String.isNotBlank(userEmailDomain) ? userEmailDomain : '';
    }

    @AuraEnabled
    public static List<Id> getAttachement(String recordId){
        Set<Id> contentDocIds = new Set<Id>();
        List<Id> contentVersionIds = new List<Id>();

        for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink
                                        WHERE LinkedEntityId=:recordId])
                                        {
                                            contentDocIds.add(cdl.ContentDocumentId);
                                        }
        if(contentDocIds.size()>0){
            for(ContentVersion cv: [SELECT Id FROM ContentVersion 
                                    WHERE ContentDocumentId IN:contentDocIds 
                                    AND isLatest=true])
                                    {
                                        contentVersionIds.add(cv.Id);
                                    }
            return contentVersionIds;
        }
        else{
            return null;
        }
    }

    public static void findLoggedInUserPerson(){
        if(loggedInUserPerson != null){
            return;
        }

        loggedInUserPerson = new SymphonyLF__Person__c();

        List<SymphonyLF__Person__c> ObjPerson  = [
            SELECT 
                Id,
                SymphonyLF__Email__c
            FROM 
                SymphonyLF__Person__c 
            WHERE 
                SymphonyLF__User__c = :UserInfo.getUserId() 
            LIMIT 1
        ];

        if(ObjPerson.size() > 0){
            loggedInUserPerson = ObjPerson[0];
        }
    }

    public static string findEmailDomain(String email) {
        String localPart = '';
        String domainPart = '';
        
        // Ensure the input email is not null or empty
        if (String.isEmpty(email)) {
            System.debug('The email address is empty or null.');
            return '';
        }

        // Split the email address at '@'
        String[] parts = email.split('@');

        // Check if the split resulted in exactly two parts
        if (parts.size() == 2) {
            localPart = parts[0];
            domainPart = parts[1];
            
            System.debug('Local Part: ' + localPart);
            System.debug('Domain Part: ' + domainPart);
        } else {
            System.debug('The email address is not in a valid format.');
        }
        
        return domainPart;
        
    }

    public class SortCreatedDate implements Comparator<mvCollaborationWrapper.collaborationRecord> {
    
        public Integer compare(Object o1, Object o2) {
            mvCollaborationWrapper.collaborationRecord wrapper1 = (mvCollaborationWrapper.collaborationRecord) o1;
            mvCollaborationWrapper.collaborationRecord wrapper2 = (mvCollaborationWrapper.collaborationRecord) o2;

            if (wrapper1.createdDate > wrapper2.createdDate) {
                return -1; 
            } else if (wrapper1.createdDate < wrapper2.createdDate) {
                return 1; 
            } else {
                return 0; 
            }
        }
    }
}