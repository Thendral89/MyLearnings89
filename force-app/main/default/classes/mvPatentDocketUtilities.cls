/**
 * @description       : Patent Docket Tabulator View Class
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class mvPatentDocketUtilities {

    @AuraEnabled
    public Static List<mvWrapper.mvDocketWrapper> getPatentDocketActivities (String recordId) {
        List<mvWrapper.mvDocketWrapper> docketActivities = new List<mvWrapper.mvDocketWrapper>();
        Date currentDate = Date.today();

        Id sObjectRecordId = recordId;
        String sObjectApiName = sObjectRecordId.getSobjectType().getDescribe().getName();

        Set<String> fields = new Set<String>{
            'Id'
            , 'Name'
            , 'SymphonyLF__Assigned_To_User__c'
            , 'SymphonyLF__Assigned_To_User__r.Name'
            , 'SymphonyLF__Event_Name__c'
            , 'SymphonyLF__Comments__c'
            , 'Comments__c'
            , 'Reported__c'
            , 'SymphonyLF__Trigger__c'
            , 'SymphonyLF__Trigger_Type__c'	
            , 'SymphonyLF__Completion_Date__c'
            , 'SymphonyLF__Due_Date__c'
            , 'SymphonyLF__Patent__c'
            , 'SymphonyLF__Trademark__c'
            , 'SymphonyLF__Reason_to_Complete__c'
            , 'SymphonyLF__Reason_to_Close__c'
            , 'SymphonyLF__Is_Closed__c'
            , 'SymphonyLF__Is_Completed__c'
            , 'SymphonyLF__Closed_Date__c'
            , 'SymphonyLF__Status__c'
            , 'SymphonyLF__Docketed_by__c'
        };

        if(
            APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.containsKey(sObjectApiName)
            &&
            APPLICATION.SOBJECT_TO_DOCKET_NUMBER_FIELD.containsKey(sObjectApiName)
        ){
            fields.add( APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(sObjectApiName) );
            fields.add( APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(sObjectApiName).replace('__c', '__r') + '.' + APPLICATION.SOBJECT_TO_DOCKET_NUMBER_FIELD.get(sObjectApiName) );
        }

        List<SymphonyLF__Docketing_Activity__c> assetActivities = new List<SymphonyLF__Docketing_Activity__c>();

        String queryOpen = ' SELECT ' + String.join(fields, ', ') +
                                ', (SELECT id ' +
                                ', name__c ' +
                                ', content_type__c ' +
                                ' FROM iManage_Documents__r) ' +
                            ' FROM SymphonyLF__Docketing_Activity__c ' +
                            ' WHERE ' +
                            '   SymphonyLF__Is_Closed__c = false ';

        queryOpen += ' AND  ' + APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get( sObjectApiName ) + ' =:recordId ';
        queryOpen += ' ORDER BY SymphonyLF__Due_Date__c ASC ';

        assetActivities = Database.query( queryOpen );


        for (SymphonyLF__Docketing_Activity__c eachActivity : assetActivities)  {
            sObject eachActivitySobject = (SObject) eachActivity;
            mvWrapper.mvDocketWrapper docketRecord = new mvWrapper.mvDocketWrapper();

            docketRecord.recordId                     = eachActivity.Id;      
            docketRecord.dueDate                      = eachActivity.SymphonyLF__Due_Date__c;
            docketRecord.docketComments               = eachActivity.SymphonyLF__Comments__c;
            docketRecord.allComments                  = eachActivity.Comments__c;
            docketRecord.docketReporting              = eachActivity.Reported__c;
            docketRecord.assignedToId                 = eachActivity.SymphonyLF__Assigned_To_User__c;
            docketRecord.assignedTo                   = eachActivity.SymphonyLF__Assigned_To_User__r.Name;
            docketRecord.docketAction                 = eachActivity.SymphonyLF__Event_Name__c;
            docketRecord.docketTrigger                = eachActivity.SymphonyLF__Trigger__c;
            docketRecord.docketTriggerType            = eachActivity.SymphonyLF__Trigger_Type__c;
            docketRecord.reasonToComplete             = eachActivity.SymphonyLF__Reason_to_Complete__c;
            docketRecord.reasonToClose                = eachActivity.SymphonyLF__Reason_to_Close__c;
            docketRecord.isClosed                     = eachActivity.SymphonyLF__Is_Closed__c;
            docketRecord.isCompleted                  = eachActivity.SymphonyLF__Is_Completed__c; 
            docketRecord.docketedById                 = eachActivity.SymphonyLF__Docketed_by__c;

            if(
                APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.containsKey(sObjectApiName)
                &&
                APPLICATION.SOBJECT_TO_DOCKET_NUMBER_FIELD.containsKey(sObjectApiName)
            ){
                sObject relatedMatter = eachActivitySobject.getSObject( APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(sObjectApiName).replace('__c', '__r') );
                Id parentAssetId = (Id) eachActivitySobject.get( APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(sObjectApiName) );
                String docketNumber = String.valueOf( relatedMatter.get( APPLICATION.SOBJECT_TO_DOCKET_NUMBER_FIELD.get(sObjectApiName) ) );

                docketRecord.parentAssetId = parentAssetId;
                docketRecord.docketNumber = docketNumber;
            }
            
            docketRecord.recordName                   = eachActivity.Name;
            docketRecord.docketStatus                 = eachActivity.SymphonyLF__Status__c;
            docketRecord.completionDate               = eachActivity.SymphonyLF__Completion_Date__c;
            docketRecord.closedDate                   = eachActivity.SymphonyLF__Closed_Date__c;

            if(eachActivity.iManage_Documents__r != null && eachActivity.iManage_Documents__r.size() > 0){
                List<mvWrapper.documentRecord> docs = new List<mvWrapper.documentRecord>();
                for(iManage_Documents__c i : eachActivity.iManage_Documents__r){
                    mvWrapper.documentRecord m = new mvWrapper.documentRecord();
                    m.documentId = i.Id;
                    m.documentType = i.content_type__c;
                    m.documentTitle = i.name__c;
                    docs.add(m);
                }
                docketRecord.documentRecords = docs;
            }

            if (!eachActivity.SymphonyLF__Is_Closed__c)
                docketRecord.isOpen = true;

            if (currentDate >= docketRecord.dueDate) {
                docketRecord.recordStatus                      = 'PAST';
            } else if (currentDate < docketRecord.dueDate) {
                docketRecord.recordStatus                      = 'FUTURE';
            }
            docketActivities.add (docketRecord);
        }  
        
        String queryClosed = ' SELECT ' + String.join(fields, ', ') +
                                ', (SELECT id ' +
                                ', name__c ' +
                                ', content_type__c ' +
                                ' FROM iManage_Documents__r) ' +
                            ' FROM SymphonyLF__Docketing_Activity__c ' +
                            ' WHERE ' +
                            '   SymphonyLF__Is_Closed__c = true ';

        queryClosed += ' AND  ' + APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get( sObjectApiName ) + ' =:recordId ';
        queryClosed += ' ORDER BY SymphonyLF__Due_Date__c DESC ';

        assetActivities = Database.query( queryClosed );

        for (SymphonyLF__Docketing_Activity__c eachActivity : assetActivities)  {
            sObject eachActivitySobject = (SObject) eachActivity;
            mvWrapper.mvDocketWrapper docketRecord = new mvWrapper.mvDocketWrapper();

            docketRecord.recordId                     = eachActivity.Id;
            docketRecord.dueDate                      = eachActivity.SymphonyLF__Due_Date__c;
            docketRecord.docketComments               = eachActivity.SymphonyLF__Comments__c;
            docketRecord.allComments                  = eachActivity.Comments__c;
            docketRecord.docketReporting              = eachActivity.Reported__c;            
            docketRecord.assignedToId                 = eachActivity.SymphonyLF__Assigned_To_User__c;
            docketRecord.assignedTo                   = eachActivity.SymphonyLF__Assigned_To_User__r.Name;
            docketRecord.docketAction                 = eachActivity.SymphonyLF__Event_Name__c;
            docketRecord.docketTrigger                = eachActivity.SymphonyLF__Trigger__c;
            docketRecord.docketTriggerType            = eachActivity.SymphonyLF__Trigger_Type__c;
            docketRecord.reasonToComplete             = eachActivity.SymphonyLF__Reason_to_Complete__c;
            docketRecord.reasonToClose                = eachActivity.SymphonyLF__Reason_to_Close__c;
            docketRecord.isClosed                     = eachActivity.SymphonyLF__Is_Closed__c;
            docketRecord.isCompleted                  = eachActivity.SymphonyLF__Is_Completed__c;  
            docketRecord.docketedById                 = eachActivity.SymphonyLF__Docketed_by__c;
            docketRecord.docketStatus                 = eachActivity.SymphonyLF__Status__c;
            
            if(
                APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.containsKey(sObjectApiName)
                &&
                APPLICATION.SOBJECT_TO_DOCKET_NUMBER_FIELD.containsKey(sObjectApiName)
            ){
                sObject relatedMatter = eachActivitySobject.getSObject( APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(sObjectApiName).replace('__c', '__r') );
                Id parentAssetId = (Id) eachActivitySobject.get( APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(sObjectApiName) );
                String docketNumber = String.valueOf( relatedMatter.get( APPLICATION.SOBJECT_TO_DOCKET_NUMBER_FIELD.get(sObjectApiName) ) );

                docketRecord.parentAssetId = parentAssetId;
                docketRecord.docketNumber = docketNumber;
            }

            docketRecord.recordName                   = eachActivity.Name;
            docketRecord.completionDate               = eachActivity.SymphonyLF__Completion_Date__c;
            docketRecord.closedDate                   = eachActivity.SymphonyLF__Closed_Date__c;

            if(eachActivity.iManage_Documents__r != null && eachActivity.iManage_Documents__r.size() > 0){
                List<mvWrapper.documentRecord> docs = new List<mvWrapper.documentRecord>();
                for(iManage_Documents__c i : eachActivity.iManage_Documents__r){
                    mvWrapper.documentRecord m = new mvWrapper.documentRecord();
                    m.documentId = i.Id;
                    m.documentType = i.content_type__c;
                    m.documentTitle = i.name__c;
                    docs.add(m);
                }
                docketRecord.documentRecords = docs;
            }

            if (!eachActivity.SymphonyLF__Is_Closed__c){
                docketRecord.isOpen = true;
            }
                

                if (currentDate >= docketRecord.dueDate) {
                    docketRecord.recordStatus                      = 'PAST';
                } 
                else if (currentDate < docketRecord.dueDate) {
                    docketRecord.recordStatus                      = 'FUTURE';
                }
            docketActivities.add (docketRecord);
        }   

        return docketActivities;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfile() {
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.Profile.Name;
    }
}