/**
 * @description       : 
 * @author            : Nikhil Agarwal
**/
public with sharing class TaskFormHelper {

    public class TaskWithFilesWrapper {
        @AuraEnabled public Task task;
        @AuraEnabled public List<ContentDocumentWrapper> files;

        public TaskWithFilesWrapper(Task task, List<ContentDocumentWrapper> files) {
            this.task = task;
            this.files = files;
        }
    }

    /* public class FinalDocWrapper {
        @AuraEnabled public Patent_Document__c finalDoc;

        public FinalDocWrapper(Patent_Document__c finalDoc) {
            this.finalDoc = finalDoc;
        }
    } */

    public class ContentDocumentWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Title { get; set; }
        @AuraEnabled public String FileType { get; set; }
        @AuraEnabled public Integer ContentSize { get; set; }
        @AuraEnabled public Datetime CreatedDate { get; set; }
        @AuraEnabled public Boolean moveToFinalDocs { get; set; }
    
        public ContentDocumentWrapper(Id Id, String Title, String FileType, Integer ContentSize, Datetime CreatedDate, Boolean moveToFinalDocs) {
            this.Id = Id;
            this.Title = Title + '.' + (FileType != null ? FileType.toLowerCase() : '');
            this.FileType = FileType;
            this.ContentSize = ContentSize;
            this.CreatedDate = CreatedDate;
            this.moveToFinalDocs = moveToFinalDocs;
        }
    }
    
    /* @AuraEnabled
    public static Id saveTask(Map<String, Object> taskFields) {
        Task taskToSave;
        if (taskFields.containsKey('Id')) {
            String taskId = (String)taskFields.get('Id');
            taskToSave = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1];
        } else {
            taskToSave = new Task();
        }

        for (String fieldName : taskFields.keySet()) {
            Object fieldValue = taskFields.get(fieldName);
            if (fieldName == 'ActivityDate' && fieldValue != null) {
                taskToSave.ActivityDate = Date.valueOf((String) fieldValue); 
            } else if (fieldName == 'ReminderDateTime' && fieldValue != null) {
                String reminderDateString = (String) fieldValue;
                reminderDateString = reminderDateString.replace('T', ' ').replace('Z', ''); 
                taskToSave.ReminderDateTime = Datetime.valueOf(reminderDateString);
            } else if (fieldName == 'IsReminderSet' && fieldValue != null) {
                taskToSave.IsReminderSet = (Boolean) fieldValue;
            } else {
                taskToSave.put(fieldName, fieldValue);
            }
        }

        try {
            if (taskToSave.Id == null) {
                insert taskToSave; 
            } else {
                update taskToSave;
            }
            return taskToSave.Id; 
        } catch (DmlException e) {
            throw new AuraHandledException('Error while saving Task: ' + e.getMessage());
        }
    } */

    @AuraEnabled
    public static Id saveTask(Map<String, Object> taskFields) {
        Task taskToSave;
        if (taskFields.containsKey('Id')) {
            taskToSave = [SELECT Id FROM Task WHERE Id = :((String)taskFields.get('Id')) LIMIT 1];
        } else {
            taskToSave = new Task();
        }

        Set<String> allowedTaskFields = new Set<String>{
            'Subject', 'Direction__c', 'Task_Type__c', 'Priority', 'Status', 'Description',
            'IsReminderSet', 'ReminderDateTime', 'ActivityDate', 'OwnerId', 'WhatId'
        };

        for (String fieldName : allowedTaskFields) {
            if (!taskFields.containsKey(fieldName)) continue;

            Object fieldValue = taskFields.get(fieldName);
            if (fieldName == 'ActivityDate' && fieldValue != null) {
                taskToSave.ActivityDate = Date.valueOf((String) fieldValue); 
            } else if (fieldName == 'ReminderDateTime' && fieldValue != null) {
                String reminderDateString = (String) fieldValue;
                reminderDateString = reminderDateString.replace('T', ' ').replace('Z', ''); 
                taskToSave.ReminderDateTime = Datetime.valueOf(reminderDateString);
            } else if (fieldName == 'IsReminderSet' && fieldValue != null) {
                taskToSave.IsReminderSet = (Boolean) fieldValue;
            } else if (fieldName == 'OwnerId' && fieldValue != null) {
                Id ownerId = (Id)fieldValue;
                if (ownerId.getSObjectType() == User.SObjectType) {
                    taskToSave.OwnerId = ownerId;
                } else {
                    throw new AuraHandledException('Invalid OwnerId provided.');
                }
            } else if (fieldName == 'WhatId' && fieldValue != null && !String.isBlank(String.valueOf(fieldValue)) ) {
                //Id whatId = (Id)fieldValue;
                //taskToSave.WhatId = whatId;
                taskToSave.WhatId = (Id)fieldValue;
            } else if (fieldValue != null) {
                taskToSave.put(fieldName, fieldValue);
            }
        }

        try {
            upsert taskToSave;
            return taskToSave.Id; 
        } catch (DmlException e) {
            throw new AuraHandledException('Error while saving Task: ' + e.getMessage());
        }
    }


    @AuraEnabled(cacheable=true)
    public static Object getTaskFieldsData() {
        List<Object> responseList = new List<Object>();

        Map<String, Schema.SObjectField> apiNameVsFieldMap = MyTaskUtility.getFieldsByObjectName('Task');

        for(String field: apiNameVsFieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = apiNameVsFieldMap.get(field).getDescribe();

            if(fieldDescribe.isFilterable()) {
                Map<String, Object> fieldMap = new Map<String, Object> {
                    'label' => fieldDescribe.getLabel(),
                    'value' => fieldDescribe.getName(),
                    'dataType' => fieldDescribe.getType().name()
                };

                if(fieldDescribe.getType() == Schema.DisplayType.REFERENCE ) {
                   List<Map<String, String>> referenceToObjects = new List<Map<String, String>>();
                    for (Schema.SObjectType refType : fieldDescribe.getReferenceTo()) {
                        Map<String, String> referenceObjectMap = new Map<String, String>();
                        referenceObjectMap.put('value', refType.getDescribe().getName());
                        referenceObjectMap.put('label', refType.getDescribe().getLabel()); 
                        referenceToObjects.add(referenceObjectMap);
                    }
                    fieldMap.put('referenceToObjects', referenceToObjects);
                } else if(fieldDescribe.getType() == Schema.DisplayType.PICKLIST || fieldDescribe.getType() == Schema.DisplayType.COMBOBOX) {
                    List<Object> pickListEntryList = new List<Object>();
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        pickListEntryList.add(new Map<String, String> {
                            'label' => entry.getLabel(),
                            'value' => entry.getValue()
                        });
                    }

                    fieldMap.put('picklistValues', pickListEntryList);
                }

                responseList.add(fieldMap);
            }
        }
        return responseList;
    }


    /* @AuraEnabled(cacheable=true)
    public static FinalDocWrapper getFinalDocById(Id docId) {
        if (String.isBlank(docId)) {
            throw new AuraHandledException('Document ID is blank or invalid.');
        }
        
        try {
            Patent_Document__c docRecord = [
                SELECT 
                Id, Name, Document_Type__c, Folder_Name__c, Comments__c
                FROM Patent_Document__c 
                WHERE Id = :docId 
                LIMIT 1
            ];
            return new FinalDocWrapper(docRecord);
        }
        
     catch (Exception e) {
        throw new AuraHandledException('Error fetching Document data: ' + e.getMessage());
    }
    } */
 

    @AuraEnabled(cacheable=true)
    public static TaskWithFilesWrapper getTaskById(Id taskId) {
        if (String.isBlank(taskId)) {
            throw new AuraHandledException('Task ID is blank or invalid.');
        }
        
        try {
            Task taskRecord = [
                SELECT 
                    Id, Subject, OwnerId, Direction__c, Task_Type__c,
                    Priority, Status, Description, Paralegal_Comment__c, Attorney_Comment__c,
                    Agent_Comment__c, IsReminderSet, ReminderDateTime, ActivityDate,WhatId, Owner.Name
                FROM Task 
                WHERE Id = :taskId 
                LIMIT 1
            ];

            List<ContentDocumentWrapper> relatedFiles = new List<ContentDocumentWrapper>();
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :taskId
            ];
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink link : contentDocumentLinks) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
            
            List<ContentDocument> contentDocuments = new List<ContentDocument>();
            if (!contentDocumentIds.isEmpty()) {
                contentDocuments = [
                    SELECT Id, Title, FileType, ContentSize, CreatedDate
                    FROM ContentDocument
                    WHERE Id IN :contentDocumentIds
                ];
            }

            //String relatedLookupField = null;
            Map<Id, Boolean> patentDocMap = new Map<Id, Boolean>();
            // Check if WhatId is present on task
            /* if (taskRecord.WhatId != null) {
                String objectApiName = (taskRecord.WhatId).getSobjectType().toString();
                relatedLookupField = getRelatedLookupField(objectApiName);//fetch lookup field associated with that object in Patent_Document__c
            } */

            if (contentDocuments.size()>0) {
                List<Id> contentDocumentIdList = new List<Id>(contentDocumentIds); // Convert Set<Id> to List<Id>

                List<String> quotedIds = new List<String>();
                for (Id docId : contentDocumentIdList) {
                    quotedIds.add('\'' + String.valueOf(docId) + '\'');
                }

                /* String query = 'SELECT Id, Document_ID__c, ' + relatedLookupField +
                            ' FROM Patent_Document__c WHERE Document_ID__c IN (' +
                            String.join(quotedIds, ',') +
                            ') AND ' + relatedLookupField + ' = \'' + taskRecord.WhatId + '\'';
                
                List<Patent_Document__c> patentDocuments = Database.query(query);

                if(patentDocuments.size()>0){
                    for (Patent_Document__c doc : patentDocuments) {
                        patentDocMap.put(doc.Document_ID__c, true);
                    }
                } */
                
            }
            for (ContentDocument document : contentDocuments) {
                Boolean isLinked = (patentDocMap != null && !patentDocMap.isEmpty()) ? patentDocMap.containsKey(document.Id) : false;
                relatedFiles.add(new ContentDocumentWrapper(
                    document.Id,
                    document.Title,
                    document.FileType,
                    document.ContentSize,
                    document.CreatedDate,
                    isLinked
                ));
            }

            return new TaskWithFilesWrapper(taskRecord, relatedFiles);
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Task data: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Id getLoggedInUser() {
        return UserInfo.getUserId();
    }
    /* @AuraEnabled(cacheable=true)
    public static Id getLoggedInUserInventorId() {
        String clientId = [SELECT Client_Id__c FROM User WHERE Id = :UserInfo.getUserId()].Client_Id__c;
        List<SymphonyIPM__Inventor__c> inventors = [
        SELECT Id 
        FROM SymphonyIPM__Inventor__c 
        WHERE SymphonyIPM__User__c = :UserInfo.getUserId() 
        AND Client_Id__c =: clientId
        LIMIT 1
        ];
        
        if (!inventors.isEmpty()) {
            return inventors[0].Id;
        }
        
        return null;
    } */

    @AuraEnabled
    public static void uploadFilesWithTask(Id taskId, List<Id> fileIds) {
        if (taskId == null || fileIds == null || fileIds.isEmpty()) {
            throw new AuraHandledException('Task ID or file IDs cannot be null or empty.');
        }
    
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        
        for (Id fileId : fileIds) {
            documentLinks.add(new ContentDocumentLink(
                ContentDocumentId = fileId,
                LinkedEntityId = taskId,
                ShareType = 'V' 
            ));
        }
    
        try {
            insert documentLinks;
        } catch (DmlException e) {
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                System.debug('Duplicate value error, some files may already be linked to this task: ' + e.getMessage());
            } else {
                throw e;
            }
        }
    }

    /* @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> checkUserPermissions() {
        Map<String, Boolean> permissions = new Map<String, Boolean>();
        permissions.put('isAgent', Schema.sObjectType.Task.fields.Agent_Comment__c.isUpdateable());
        permissions.put('isAttorney', Schema.sObjectType.Task.fields.Attorney_Comment__c.isUpdateable());
        permissions.put('isParalegal', Schema.sObjectType.Task.fields.Paralegal_Comment__c.isUpdateable());

        return permissions;
                                  
    } */


    /* @AuraEnabled
    public static void createFinalDocuments(String selectedRelatedToObject, List<Map<String, Object>> finalDocumentfiles, String selectedRelatedId) {

        if (String.isBlank(selectedRelatedToObject) || finalDocumentfiles == null || finalDocumentfiles.isEmpty() || String.isBlank(selectedRelatedId)) {
            throw new AuraHandledException('Invalid input parameters.');
        }

        Map<String, Schema.SObjectField> patentDocumentFields = Schema.SObjectType.Patent_Document__c.fields.getMap();

        String relatedLookupField = getRelatedLookupField(selectedRelatedToObject);

        if (relatedLookupField == null) {
            throw new AuraHandledException('No lookup field found on Patent_Document__c related to the selected object: ' + selectedRelatedToObject);
        }
        List<Patent_Document__c> patentDocumentsToInsert = new List<Patent_Document__c>();
        List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();

        for (Map<String, Object> fileData : finalDocumentfiles) {
            String documentId = (String) fileData.get('Id');
            String displayName = (String) fileData.get('displayName');
            String assetType=(String) fileData.get('assetTypeValue');

            Patent_Document__c newDocument = new Patent_Document__c();
            newDocument.Document_ID__c = documentId;
            newDocument.Linked_Content_Id__c = documentId;
            newDocument.Content_Title__c = displayName;
            newDocument.File_Name_Big__c = displayName;
            newDocument.Upload_Date__c = Date.today();
            newDocument.put(relatedLookupField, selectedRelatedId);
            newDocument.Asset_Type__c = assetType;

            patentDocumentsToInsert.add(newDocument);

            ContentDocumentLink newLink = new ContentDocumentLink();
            newLink.ContentDocumentId = documentId;
            newLink.LinkedEntityId = selectedRelatedId; 
            newLink.ShareType = 'V'; 
            contentDocumentLinksToInsert.add(newLink);
    
        }

        try {
            insert patentDocumentsToInsert;
            insert contentDocumentLinksToInsert;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating Patent_Document__c records: ' + e.getMessage());
        }
    } */

    /* private static String getRelatedLookupField(String selectedRelatedToObject) {
        Map<String, Schema.SObjectField> patentDocumentFields = Schema.SObjectType.Patent_Document__c.fields.getMap();
        String relatedLookupField = null;
        
        for (String fieldName : patentDocumentFields.keySet()) {
            Schema.DescribeFieldResult fieldDesc = patentDocumentFields.get(fieldName).getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.Reference) {
                List<Schema.SObjectType> referenceTo = fieldDesc.getReferenceTo();
                for (Schema.SObjectType sObjectType : referenceTo) {
                    if (sObjectType.getDescribe().getName() == selectedRelatedToObject) {
                        relatedLookupField = fieldName;
                        break;
                    }
                }
            }
        }
        return relatedLookupField;
    }*/
}