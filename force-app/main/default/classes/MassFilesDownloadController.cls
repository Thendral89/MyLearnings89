/**
 * @description       : MassFilesDownloadController
 * @last modified on  : 02-19-2025
**/

public with sharing class MassFilesDownloadController {
    
    @AuraEnabled
    public static List<PicklistOptions> fetchObjectList() {
        List<PicklistOptions> objectList = new List<PicklistOptions>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
            Schema.DescribeSObjectResult describeSObjectRes = objTyp.getDescribe();
            if(describeSObjectRes.isQueryable() && describeSObjectRes.isUpdateable() && describeSObjectRes.isSearchable() && 
            describeSObjectRes.isAccessible() && describeSObjectRes.isCreateable() && !describeSObjectRes.isCustomSetting()) {
                String name = objTyp.getDescribe().getName();
                if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
                 !name.containsignorecase('share') && !name.containsignorecase('feed'))
                {
                    objectList.add( new PicklistOptions(describeSObjectRes.getLabel(), describeSObjectRes.getName()) );
                }
            }
        }
        objectList.sort();
        return objectList;
    }

    /* @AuraEnabled
    public static List<ContentDocumentLink> fetchFiles(String objectName, String recordId, String year, String month) {
        try {
            String query = 'SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize, ContentDocument.LastModifiedDate, ContentDocument.CreatedDate, LinkedEntity.Type FROM ContentDocumentLink ';
            if(String.isNotBlank(objectName)) {
                query += ' where LinkedEntityId in ( SELECT Id FROM '+objectName+') and LinkedEntity.Type =: objectName';
                if(String.isNotBlank(year)) {
                        query += ' AND calendar_year(ContentDocument.LastModifiedDate) = ' + year;
                }
                if(String.isNotBlank(month)) {
                    query += ' AND calendar_month(ContentDocument.LastModifiedDate) = '+month;
                }
            }
            if(String.isNotBlank(recordId)) {
                query += ' where LinkedEntityId = \'' + recordId + '\'';
            }
            return Database.query(query);
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    } */

    @AuraEnabled
    public static List<ContentDocumentLinkWrapper> fetchFiles(String objectName, String recordId, String year, String month) {
        try {
            if (objectName == 'iManage_Documents__c' && String.isNotBlank(recordId)) {
                
                List<iManage_Documents__c> iManageList = [
                    SELECT Id, ContentVersionId__c
                    FROM iManage_Documents__c
                    WHERE DocketingActivityId__c = :recordId
                ];
                
                Set<Id> versionIds = new Set<Id>();
                for (iManage_Documents__c doc : iManageList) {
                    if (doc.ContentVersionId__c != null) {
                        versionIds.add(doc.ContentVersionId__c);
                    }
                }
                if (versionIds.isEmpty()) {
                    return new List<ContentDocumentLinkWrapper>();
                }
                String versionQuery = 'SELECT Id, ContentDocumentId, Title, FileType, ContentSize, '
                                    + '       CreatedDate, LastModifiedDate '
                                    + ' FROM ContentVersion '
                                    + ' WHERE Id IN :versionIds';

                if (String.isNotBlank(year)) {
                    versionQuery += ' AND CALENDAR_YEAR(LastModifiedDate) = ' + year;
                }
                if (String.isNotBlank(month)) {
                    versionQuery += ' AND CALENDAR_MONTH(LastModifiedDate) = ' + month;
                }
                
                List<ContentVersion> versionList = Database.query(versionQuery);
                
                List<ContentDocumentLinkWrapper> wrapperList = new List<ContentDocumentLinkWrapper>();

                for (ContentVersion cv : versionList) {
                    ContentDocumentLinkWrapper cdlWrap = new ContentDocumentLinkWrapper();
                    cdlWrap.ContentDocumentId = cv.ContentDocumentId;
                    
                    cdlWrap.ContentDocument = new ContentDocumentWrapper();
                    cdlWrap.ContentDocument.Id = cv.ContentDocumentId;
                    cdlWrap.ContentDocument.Title = cv.Title;
                    cdlWrap.ContentDocument.FileType = cv.FileType;
                    cdlWrap.ContentDocument.ContentSize = cv.ContentSize;
                    cdlWrap.ContentDocument.CreatedDate = cv.CreatedDate;
                    cdlWrap.ContentDocument.LastModifiedDate = cv.LastModifiedDate;
                    wrapperList.add(cdlWrap);
                }
                return wrapperList;
            } 
            else {
                String query = 'SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, '
                             + '       ContentDocument.ContentSize, ContentDocument.LastModifiedDate, '
                             + '       ContentDocument.CreatedDate, LinkedEntity.Type '
                             + ' FROM ContentDocumentLink';

                if (String.isNotBlank(objectName)) {
                    query += ' WHERE LinkedEntityId IN (SELECT Id FROM ' + objectName + ')'
                           + ' AND LinkedEntity.Type = :objectName';
                    
                    if (String.isNotBlank(year)) {
                        query += ' AND CALENDAR_YEAR(ContentDocument.LastModifiedDate) = ' + year;
                    }
                    if (String.isNotBlank(month)) {
                        query += ' AND CALENDAR_MONTH(ContentDocument.LastModifiedDate) = ' + month;
                    }
                }
                
                if (String.isNotBlank(recordId)) {
                    query += ' WHERE LinkedEntityId = \'' + recordId + '\'';
                }

                List<ContentDocumentLink> cdlList = Database.query(query);

                List<ContentDocumentLinkWrapper> wrapperList = new List<ContentDocumentLinkWrapper>();
                for (ContentDocumentLink link : cdlList) {
                    ContentDocumentLinkWrapper cdlWrap = new ContentDocumentLinkWrapper();
                    cdlWrap.ContentDocumentId = link.ContentDocumentId;
                    cdlWrap.LinkedEntityType  = (link.LinkedEntity != null) ? link.LinkedEntity.Type : null;
                    
                    if (link.ContentDocument != null) {
                        // Use ContentDocumentWrapper (not as a nested class)
                        ContentDocumentWrapper doc = new ContentDocumentWrapper();
                        doc.Id                = link.ContentDocument.Id;
                        doc.Title             = link.ContentDocument.Title;
                        doc.FileType          = link.ContentDocument.FileType;
                        doc.ContentSize       = link.ContentDocument.ContentSize;
                        doc.CreatedDate       = link.ContentDocument.CreatedDate;
                        doc.LastModifiedDate  = link.ContentDocument.LastModifiedDate;
                        
                        // Assign our doc to the wrapper
                        cdlWrap.ContentDocument = doc;
                    }
                    
                    wrapperList.add(cdlWrap);
                }
                return wrapperList;
            }
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }


    public class PicklistOptions implements Comparable {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public Integer compareTo(Object ObjToCompare) {
            return label.CompareTo(((PicklistOptions)ObjToCompare).label);
        }
    }

    public class ContentDocumentLinkWrapper {
        @AuraEnabled public Id ContentDocumentId;
        @AuraEnabled public ContentDocumentWrapper ContentDocument;
        // Maybe also store LinkedEntity.Type if your LWC uses it
        @AuraEnabled public String LinkedEntityType;
    }

    public class ContentDocumentWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Title;
        @AuraEnabled public String FileType;
        @AuraEnabled public Integer ContentSize;
        @AuraEnabled public Datetime CreatedDate;
        @AuraEnabled public Datetime LastModifiedDate;
    }
}