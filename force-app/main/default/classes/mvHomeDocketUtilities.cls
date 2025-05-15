public with sharing class mvHomeDocketUtilities {
    public mvHomeDocketUtilities() {

    }

    private static final Set<String> adminProfiles = new Set<String>{
        'System Administrator',
        'MCCIP Docketing Management',
        'MCCIP Docketer',
        'MCCIP Legal Assistant'
    };

    private static final Set<String> legalAssiatantProfile = new Set<String>{
        'MCCIP Legal Assistant'
    };

    @AuraEnabled
    public Static List<mvWrapper.mvDocketWrapper> getNext7DaysActivities (String recordId, String filterType) {
        List<mvWrapper.mvDocketWrapper> docketActivities = new List<mvWrapper.mvDocketWrapper>();
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        Date currentDate = Date.today();

        addFields();

        List<SymphonyLF__Docketing_Activity__c> assetActivities = new List<SymphonyLF__Docketing_Activity__c>();
        String query = ' SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + 'SymphonyLF__Docketing_Activity__c ';
        query += ' WHERE  SymphonyLF__Is_Closed__c = false ' + 
            ' AND ( SymphonyLF__Due_Date__c <= NEXT_7_DAYS AND SymphonyLF__Due_Date__c >= TODAY ) ';

        if (!adminProfiles.contains(userProfile)) {
            query += ' AND MEM_Group__r.Show_to_User__c = true';
        }

        String queryExtension = queryExtensionForFilterType(filterType);
        if(String.isNotBlank(queryExtension)){
            query += ' AND ( ' + queryExtension + ' ) ';
        }
        query += ' ORDER BY SymphonyLF__Due_Date__c ASC ';
        query += ' LIMIT 20000 ';
        
        assetActivities = Database.query(query);
        System.debug('Asset Activities-->'+assetActivities);


        for (SymphonyLF__Docketing_Activity__c eachActivity : assetActivities)  {
            mvWrapper.mvDocketWrapper docketRecord = new mvWrapper.mvDocketWrapper();

            docketRecord.recordId                     = eachActivity.Id;
          //  docketRecord.parentAssetId                = eachActivity.SymphonyLF__Patent__c;
            docketRecord.dueDate                      = eachActivity.SymphonyLF__Due_Date__c;
            docketRecord.docketComments               = eachActivity.SymphonyLF__Comments__c;
            docketRecord.assignedToId                 = eachActivity.SymphonyLF__Assigned_To_User__c;
            docketRecord.assignedTo                   = eachActivity.SymphonyLF__Assigned_To_User__r.Name;
            docketRecord.docketReporting              = eachActivity.Reported__c;
            docketRecord.docketAction                 = eachActivity.SymphonyLF__Event_Name__c;
            docketRecord.docketTrigger                = eachActivity.SymphonyLF__Trigger__c;
            docketRecord.reasonToComplete             = eachActivity.SymphonyLF__Reason_to_Complete__c;
            docketRecord.reasonToClose                = eachActivity.SymphonyLF__Reason_to_Close__c;
            docketRecord.isClosed                     = eachActivity.SymphonyLF__Is_Closed__c;
            docketRecord.isCompleted                  = eachActivity.SymphonyLF__Is_Completed__c;  
            docketRecord.docketNumber                 = eachActivity.Matter_Docket_Number__c;
            docketRecord.recordName                   = eachActivity.Name;
            docketRecord.completionDate               = eachActivity.SymphonyLF__Completion_Date__c;
            docketRecord.closedDate                   = eachActivity.SymphonyLF__Closed_Date__c;
            docketRecord.docketStatus                 = eachActivity.SymphonyLF__Status__c;
            docketRecord.docketedById                 = eachActivity.SymphonyLF__Docketed_by__c;
            docketRecord.docketedByName               = (eachActivity.SymphonyLF__Docketed_by__c != null) ? eachActivity.SymphonyLF__Docketed_by__r.Name : '';

            docketRecord.assetType = '';
            docketRecord.parentAssetId = '';
            docketRecord.assetTitle = '';
            docketRecord.assetApiName = '';

            SObject eachActivitySobject = (SObject) eachActivity;
            String lookupField = DocketActivityApplication.lookupFieldApiName( eachActivitySobject );
            String lookupFieldTag =  DocketActivityApplication.assetTypeApiNameToTag.get(
                DocketActivityApplication.lookupToSobject.get( lookupField )
            );

            if(String.isNotBlank(lookupField)){
                docketRecord.assetType = lookupFieldTag;
                docketRecord.parentAssetId = (Id) eachActivitySobject.get(lookupField);
                docketRecord.assetApiName = DocketActivityApplication.lookupToSobject.get( lookupField );

                String sobjectApiName = DocketActivityApplication.lookupToSobject.get( lookupField );
                Sobject parentObject = (Sobject) eachActivitySobject.getSobject( lookupField.replace('__c', '__r'));

                docketRecord.docketNumber = String.valueOf( parentObject.get( DocketActivityApplication.assetTypeApiNameToDocketNumberField.get(sobjectApiName) ) );
                docketRecord.assetTitle = String.valueOf( parentObject.get( DocketActivityApplication.assetTypeApiNameToTitleField.get(sobjectApiName) ) );
            }

            if (!eachActivity.SymphonyLF__Is_Closed__c)
                docketRecord.isOpen = true;

            if (currentDate >= docketRecord.dueDate) {
                docketRecord.recordStatus                      = 'PAST';
            }else if (currentDate < docketRecord.dueDate) {
                docketRecord.recordStatus                      = 'FUTURE';
            }
            docketActivities.add (docketRecord);
        }   


        return docketActivities;
        
    }
    @AuraEnabled
    public Static String fetchDocketInfo (String recordId, String filterType, String attorneyIds){
        Map<String, Object> returnMap = new Map<String, Object>();
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if(legalAssiatantProfile.contains(profileName) && String.isBlank(attorneyIds)){
        List<Legal_Assistant__c> legalAssistants = [
            Select 
                  Id
                , Name
                , Legal_Assistant__c
                , Legal_Assistant__r.Name
                , Attorney_Paralegal__c
                , Attorney_Paralegal__r.Name 
            FROM 
                Legal_Assistant__c 
            WHERE
                Legal_Assistant__r.SymphonyLF__User__c = :UserInfo.getUserId()
            ];
            attorneyIds = legalAssistants[0].Attorney_Paralegal__c;
            returnMap.put('attorneyInfo',legalAssistants);
        }
        returnMap.put('profileName',profileName);
        returnMap.put('docketInfo',getHomeDocketActivities(recordId, filterType, attorneyIds,profileName));

        return JSON.serialize(returnMap);
    }

    @AuraEnabled
    public Static List<mvWrapper.mvLegalAssistantWrapper> getAttorneys (){
        List<mvWrapper.mvLegalAssistantWrapper> attorneyList = new List<mvWrapper.mvLegalAssistantWrapper>();

        List<Legal_Assistant__c> legalAssistants = [
            Select 
                  Id
                , Name
                , Legal_Assistant__c
                , Legal_Assistant__r.Name
                , Attorney_Paralegal__c
                , Attorney_Paralegal__r.Name 
            FROM 
                Legal_Assistant__c 
            WHERE
                Legal_Assistant__r.SymphonyLF__User__c = :UserInfo.getUserId()
            ];

        for(Legal_Assistant__c assistant : legalAssistants){
            mvWrapper.mvLegalAssistantWrapper assistantRecord = new mvWrapper.mvLegalAssistantWrapper();   
            assistantRecord.attorneyName = assistant.Attorney_Paralegal__r.Name;
            assistantRecord.attorneyId = assistant.Attorney_Paralegal__c;

            attorneyList.add(assistantRecord);
        }

        return attorneyList;

    }

    @AuraEnabled
    public Static   List<mvWrapper.mvDocketWrapper> getHomeDocketActivities (String recordId, String filterType, String attorneyIds, String profileName) {
        List<mvWrapper.mvDocketWrapper> docketActivities = new List<mvWrapper.mvDocketWrapper>();
        Date currentDate = Date.today();

        addFields();

        List<SymphonyLF__Docketing_Activity__c> assetActivities = new List<SymphonyLF__Docketing_Activity__c>();
        String query = ' SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + 'SymphonyLF__Docketing_Activity__c ';
        query += ' WHERE  SymphonyLF__Is_Closed__c = false ' + 
           // 'AND SymphonyLF__Due_Date__c < NEXT_YEAR ' + 
           // ' AND SymphonyLF__Due_Date__c > LAST_YEAR' +
            ' AND ( SymphonyLF__Due_Date__c <= NEXT_N_DAYS:60  AND SymphonyLF__Due_Date__c >= LAST_N_DAYS:30  ) ';

        if(legalAssiatantProfile.contains(profileName) && String.isNotBlank(attorneyIds)){
            query += ' AND ( ' +
                        'MEM_Group__r.MEM_1__r.SymphonyLF__Assign_to_User__c  = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_2__r.SymphonyLF__Assign_to_User__c  = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_3__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_4__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_5__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_6__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_7__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_8__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_9__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_10__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_11__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_12__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_13__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_14__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_15__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_16__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_17__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_18__r.SymphonyLF__Assign_to_User__c = :attorneyIds OR ' +
                        'MEM_Group__r.MEM_19__r.SymphonyLF__Assign_to_User__c = :attorneyIds )';
        }
        
        if (!adminProfiles.contains(profileName)) {
            query += ' AND MEM_Group__r.Show_to_User__c = true';
        }
        
        String queryExtension = queryExtensionForFilterType(filterType);
        if(String.isNotBlank(queryExtension)){
            query += ' AND ( ' + queryExtension + ' ) ';
        }
        query += ' ORDER BY SymphonyLF__Due_Date__c ASC ';

        query += ' LIMIT 20000 ';
        
        assetActivities = Database.query(query);      

        for (SymphonyLF__Docketing_Activity__c eachActivity : assetActivities)  {
            mvWrapper.mvDocketWrapper docketRecord = new mvWrapper.mvDocketWrapper();

            docketRecord.recordId                     = eachActivity.Id;
          //  docketRecord.parentAssetId                = eachActivity.SymphonyLF__Patent__c;
            docketRecord.dueDate                      = eachActivity.SymphonyLF__Due_Date__c;
            docketRecord.docketComments               = eachActivity.SymphonyLF__Comments__c;
            docketRecord.assignedToId                 = eachActivity.SymphonyLF__Assigned_To_User__c;
            docketRecord.assignedTo                   = eachActivity.SymphonyLF__Assigned_To_User__r.Name;
            docketRecord.docketReporting              = eachActivity.Reported__c;
            docketRecord.docketAction                 = eachActivity.SymphonyLF__Event_Name__c;
            docketRecord.docketTrigger                = eachActivity.SymphonyLF__Trigger__c;
            docketRecord.reasonToComplete             = eachActivity.SymphonyLF__Reason_to_Complete__c;
            docketRecord.reasonToClose                = eachActivity.SymphonyLF__Reason_to_Close__c;
            docketRecord.isClosed                     = eachActivity.SymphonyLF__Is_Closed__c;
            docketRecord.isCompleted                  = eachActivity.SymphonyLF__Is_Completed__c;  
            docketRecord.docketNumber                 = eachActivity.Matter_Docket_Number__c;
            docketRecord.recordName                   = eachActivity.Name;
            docketRecord.completionDate               = eachActivity.SymphonyLF__Completion_Date__c;
            docketRecord.closedDate                   = eachActivity.SymphonyLF__Closed_Date__c;
            docketRecord.docketStatus                 = eachActivity.SymphonyLF__Status__c;
            docketRecord.docketedById                 = eachActivity.SymphonyLF__Docketed_by__c;
            docketRecord.docketedByName               = (eachActivity.SymphonyLF__Docketed_by__c != null) ? eachActivity.SymphonyLF__Docketed_by__r.Name : '';

            docketRecord.assetType = '';
            docketRecord.parentAssetId = '';
            docketRecord.assetTitle = '';
            docketRecord.assetApiName = '';

            SObject eachActivitySobject = (SObject) eachActivity;
            String lookupField = DocketActivityApplication.lookupFieldApiName( eachActivitySobject );
            String lookupFieldTag =  DocketActivityApplication.assetTypeApiNameToTag.get(
                DocketActivityApplication.lookupToSobject.get( lookupField )
            );

            if(String.isNotBlank(lookupField)){
                docketRecord.assetType = lookupFieldTag;
                docketRecord.parentAssetId = (Id) eachActivitySobject.get(lookupField);
                docketRecord.assetApiName = DocketActivityApplication.lookupToSobject.get( lookupField );

                String sobjectApiName = DocketActivityApplication.lookupToSobject.get( lookupField );
                Sobject parentObject = (Sobject) eachActivitySobject.getSobject( lookupField.replace('__c', '__r'));

                docketRecord.docketNumber = String.valueOf( parentObject.get( DocketActivityApplication.assetTypeApiNameToDocketNumberField.get(sobjectApiName) ) );
                docketRecord.assetTitle = String.valueOf( parentObject.get( DocketActivityApplication.assetTypeApiNameToTitleField.get(sobjectApiName) ) );
            }

            if (!eachActivity.SymphonyLF__Is_Closed__c)
                docketRecord.isOpen = true;

            if (currentDate >= docketRecord.dueDate) {
                docketRecord.recordStatus                      = 'PAST';
            }else if (currentDate < docketRecord.dueDate) {
                docketRecord.recordStatus                      = 'FUTURE';
            }
            docketActivities.add (docketRecord);
        }   

        /*
        query = ' SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + 'SymphonyLF__Docketing_Activity__c ';
        query += ' WHERE  SymphonyLF__Is_Closed__c = true ';
        query += ' ORDER BY SymphonyLF__Due_Date__c DESC ';

        assetActivities = Database.query(query);

        for (SymphonyLF__Docketing_Activity__c eachActivity : assetActivities)  {
            mvWrapper.mvDocketWrapper docketRecord = new mvWrapper.mvDocketWrapper();

            docketRecord.recordId                     = eachActivity.Id;
          //  docketRecord.parentAssetId                = eachActivity.SymphonyLF__Patent__c;
            docketRecord.dueDate                      = eachActivity.SymphonyLF__Due_Date__c;
            docketRecord.docketComments               = eachActivity.SymphonyLF__Comments__c;
            docketRecord.assignedToId                 = eachActivity.SymphonyLF__Assigned_To_User__c;
            docketRecord.assignedTo                   = eachActivity.SymphonyLF__Assigned_To_User__r.Name;
            docketRecord.docketAction                 = eachActivity.SymphonyLF__Event_Name__c;
            docketRecord.docketTrigger                = eachActivity.SymphonyLF__Trigger__c;
            docketRecord.reasonToComplete             = eachActivity.SymphonyLF__Reason_to_Complete__c;
            docketRecord.reasonToClose                = eachActivity.SymphonyLF__Reason_to_Close__c;
            docketRecord.isClosed                     = eachActivity.SymphonyLF__Is_Closed__c;
            docketRecord.isCompleted                  = eachActivity.SymphonyLF__Is_Completed__c;  
          //  docketRecord.docketNumber                 = eachActivity.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c;
            docketRecord.recordName                   = eachActivity.Name;
            docketRecord.completionDate               = eachActivity.SymphonyLF__Completion_Date__c;
            docketRecord.closedDate                   = eachActivity.SymphonyLF__Closed_Date__c;

            docketRecord.assetType = '';
            docketRecord.parentAssetId = '';
            docketRecord.docketNumber = '';
            docketRecord.assetTitle = '';
            docketRecord.assetApiName = '';

            SObject eachActivitySobject = (SObject) eachActivity;
            String lookupField = DocketActivityApplication.lookupFieldApiName( eachActivitySobject );
            String lookupFieldTag =  DocketActivityApplication.assetTypeApiNameToTag.get(
                DocketActivityApplication.lookupToSobject.get( lookupField )
            );

            if(String.isNotBlank(lookupField)){
                docketRecord.assetType = lookupFieldTag;
                docketRecord.parentAssetId = (Id) eachActivitySobject.get(lookupField);
                docketRecord.assetApiName = DocketActivityApplication.lookupToSobject.get( lookupField );

                String sobjectApiName = DocketActivityApplication.lookupToSobject.get( lookupField );
                Sobject parentObject = (Sobject) eachActivitySobject.getSobject( lookupField.replace('__c', '__r'));

                docketRecord.docketNumber = String.valueOf( parentObject.get( DocketActivityApplication.assetTypeApiNameToDocketNumberField.get(sobjectApiName) ) );
                docketRecord.assetTitle = String.valueOf( parentObject.get( DocketActivityApplication.assetTypeApiNameToTitleField.get(sobjectApiName) ) );
            }

            if (!eachActivity.SymphonyLF__Is_Closed__c)
                docketRecord.isOpen = true;

                if (currentDate >= docketRecord.dueDate) {
                docketRecord.recordStatus                      = 'PAST';
                } 
                else {
                docketRecord.recordStatus                      = 'FUTURE';
                }
            docketActivities.add (docketRecord);
        }  
            */ 

        return docketActivities;
        
    }

    private static String queryExtensionForFilterType(String filterType){
       if(filterType == 'NEXT7'){
         return '(SymphonyLF__Due_Date__c <= NEXT_N_DAYS:7 AND SymphonyLF__Due_Date__c >= TODAY)';
       }else if(filterType == 'NEXT30') {
        return '(SymphonyLF__Due_Date__c <= NEXT_N_DAYS:30 AND SymphonyLF__Due_Date__c >= TODAY)';
       }
       else if(filterType == 'NEXT60') {
        return '(SymphonyLF__Due_Date__c <= NEXT_N_DAYS:60 AND SymphonyLF__Due_Date__c >= TODAY)';
       }
       else if(filterType == 'TODAY_AND_TOM'){
         return '(SymphonyLF__Due_Date__c IN (TODAY, TOMORROW))';
       }
       else if(filterType == 'PASTDUE') {
        return 'SymphonyLF__Due_Date__c < TODAY';
       }
       else if(filterType == 'ADHOC') {
        return 'SymphonyLF__Trigger_Type__c = \'Event\' AND SymphonyLF__Docketed_by__c = null';
       }
       else if(filterType == 'EVENTS'){
        return 'SymphonyLF__Trigger_Type__c = \'Event\' AND SymphonyLF__Docketed_by__c != null';
       }
       else{
        return '';
       }
    }

    private static void addFields(){
        for( String lookupField : DocketActivityApplication.lookupToSobject.keySet() ){
            String sobjectApiName = DocketActivityApplication.lookupToSobject.get( lookupField );
            fieldsToQuery.add(lookupField);

            String lookupRelationship = lookupField.replace('__c', '__r');

            fieldsToQuery.add( lookupRelationship + '.' + DocketActivityApplication.assetTypeApiNameToDocketNumberField.get(sobjectApiName));
            fieldsToQuery.add( lookupRelationship + '.' + DocketActivityApplication.assetTypeApiNameToTitleField.get(sobjectApiName));
        }
    }

    final static Set<String> fieldsToQuery = new Set<String>{
        'id'
        , 'Name'
        , 'SymphonyLF__Assigned_To_User__c'
        , 'SymphonyLF__Assigned_To_User__r.Name'
        , 'SymphonyLF__Event_Name__c'
        , 'SymphonyLF__Comments__c'
        , 'SymphonyLF__Trigger__c'
        , 'SymphonyLF__Trigger_Type__c'	
        , 'SymphonyLF__Completion_Date__c'
        , 'SymphonyLF__Due_Date__c'
        , 'Reported__c'
        , 'Matter_Docket_Number__c'
        , 'SymphonyLF__IP_Matter_Docket_Number__c'
        , 'SymphonyLF__Reason_to_Complete__c'
        , 'SymphonyLF__Reason_to_Close__c'
        , 'SymphonyLF__Is_Closed__c'
        , 'SymphonyLF__Is_Completed__c'
        , 'SymphonyLF__Closed_Date__c'
        , 'SymphonyLF__Status__c'
        , 'SymphonyLF__Patent__c'
        , 'SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c'
        , 'SymphonyLF__Patent__r.Credit_Status__c'
        , 'SymphonyLF__Docketed_by__c'
        , 'SymphonyLF__Docketed_by__r.Name'
    };

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfile() {
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.Profile.Name;
    }


}