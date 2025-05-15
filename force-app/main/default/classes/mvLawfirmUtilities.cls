/***************************************************************
* Class Name   : mvLawfirmUtilities
* Purpose      : Common utilities for Lawfirm
* Created By   : Siva Nekkalapudi
* Created On   : Feb 08, 2025
* Version History  : 
* --------------------------------------------------------------
  No   Date         Changes
* --------------------------------------------------------------
  1    08-FEB-2025  Initial Version
* **************************************************************/
public with sharing class mvLawfirmUtilities {
    static Set<String> emptySet = new Set<String>{
        NULL,
        '',
        'null',
        'NULL'
    };
    

    @AuraEnabled
    public static List<mvWrappers.clientRestrictionsWrapper> getClientRestrictions(Id recordId){
        List<mvWrappers.clientRestrictionsWrapper> output = new List<mvWrappers.clientRestrictionsWrapper>();
        Map<Schema.SObjectType, String> fieldMap = new Map<Schema.SObjectType, String>{
        SymphonyLF__Patent__c.SObjectType => 'Patent__c',
        SymphonyLF__Client__c.SObjectType => 'Client__c',
        SymphonyLF__Trademark__c.SObjectType => 'Trademark__c',
        SymphonyLF__Design__c.SObjectType => 'Design__c',
        SymphonyLF__Copyright__c.SObjectType => 'Copyright__c',
        SymphonyLF__Agreement_Contract__c.SObjectType => 'Agreement_and_Contract__c',
        SymphonyLF__Dispute_Opposition__c.SObjectType => 'Dispute_Opposition__c',
             SymphonyLF__Patent_Family__c.SObjectType => 'Patent_Family__c',
             SymphonyLF__Design_Family__c.SObjectType => 'Design_Family__c',
             SymphonyLF__Mark__c.SObjectType => 'Mark__c'
        };

        String sobjectType = 'Access_Restriction__c';        
        
        Map<String, Object> bindMap = new Map<String, Object>();
        
        bindMap.put('lookupFieldValue', recordId);
        //ID RecordId = Id.valueOf(clientId);
        Schema.SObjectType GivensobjectType = recordId.getSObjectType();
        String query ='';
        String fieldName = fieldMap.get(GivensobjectType);
        if (fieldName != null) {
            query = 'SELECT ' + String.join(clientRestrictions, ', ') +
                ' FROM Access_Restriction__c ' +
                ' WHERE ' + fieldName + ' = :lookupFieldValue ' +
                ' ORDER BY CreatedDate';
        }
        
        System.debug('result26'+query);

        List<sObject> records = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
        List<Id> recordIds = new List<Id>();
        for(sObject rec : records){
            
            mvWrappers.clientRestrictionsWrapper single = new mvWrappers.clientRestrictionsWrapper();

            single.recordId = (Id) rec.get('Id') ;
            single.symphonyId = String.valueOf( rec.get('Name') );
            single.type = String.valueof( rec.getSobject('Person__r')?.get('SymphonyLF__Type__c') );
            single.contactName = String.valueof( rec.getSobject('Person__r')?.get('Name') );
            single.phone = String.valueof( rec.getSobject('Person__r')?.get('SymphonyLF__Phone_Number__c') );
            single.email = String.valueof( rec.getSobject('Person__r')?.get('SymphonyLF__Email__c') );
            single.contactRecordId = (Id) rec.get('Person__c') ;
            single.userId = (Id) rec.get('User__c') ;
            single.status = String.valueOf( rec.get('Status__c') );

            if(emptySet.contains(single.phone)){
                single.phone = '';
            }
            if(emptySet.contains(single.email)){
                single.email = '';
            }

            output.add(single);
            recordIds.add(single.recordId);
        }

        Map<Id, mvWrappers.RecordPermissionWrapper> recordAccess = getRecordPermissions(recordIds);

        for(mvWrappers.clientRestrictionsWrapper single : output){
            single.recordPermission = recordAccess.get(single.recordId);
        }

        return output;
    }


    @AuraEnabled
    public static List<mvWrappers.MatterEngagementModelWrapper> getMatterEngagementModels(Id recordId){
        List<mvWrappers.MatterEngagementModelWrapper> output = new List<mvWrappers.MatterEngagementModelWrapper>();

        String sobjectType = recordId.getSobjectType().getDescribe().getName();

        if(!mvConstants.sObjectToLookupField.containsKey( sobjectType )){
            throw new NotValidObjectException('Not valid object ' + sobjectType);
        }

        String lookupField = mvConstants.sObjectToLookupField.get(sobjectType);
        
        
        Map<String, Object> bindMap = new Map<String, Object>();

        bindMap.put('lookupFieldValue', recordId);
        

        
        String query = ' SELECT ' + String.join(fieldsMatterEngagementModels, ', ') +
            ' FROM SymphonyLF__Matter_Engagement_Model__c ' +
            ' WHERE ' + lookupField + ' = :lookupFieldValue ' +
            ' ORDER BY Is_Active__c DESC, Is_Default__c DESC, Sequence__c, SymphonyLF__Supervisor_Client_Contact__r.Name ASC NULLS LAST ';
                

        List<sObject> records = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
        List<Id> recordIds = new List<Id>();
        for(sObject rec : records){
            mvWrappers.MatterEngagementModelWrapper single = new mvWrappers.MatterEngagementModelWrapper();

            single.recordId = (Id) rec.get('Id') ;
            single.symphonyId = String.valueOf( rec.get('Name') );
            single.type = String.valueof( rec.get('SymphonyLF__Type__c') );
            single.contactName = String.valueof( rec.getSobject('SymphonyLF__Assign_to_User__r')?.get('Name') );
            single.phone = String.valueof( rec.getSobject('SymphonyLF__Assign_to_User__r')?.get('SymphonyLF__Phone_Number__c') );
            single.email = String.valueof( rec.getSobject('SymphonyLF__Assign_to_User__r')?.get('SymphonyLF__Email__c') );
            single.contactRecordId = (Id) rec.get('SymphonyLF__Assign_to_User__c') ;
            single.sequence = String.valueOf( rec.get('Sequence__c') );
            single.isDefault = Boolean.valueOf( rec.get('Is_Default__c') );
            single.isActive = Boolean.valueOf( rec.get('Is_Active__c') );

            single.contactRecordType = '';
            sObject person = rec.getSobject('SymphonyLF__Assign_to_User__r');
            if(person != null){
                sObject recordType = person.getSobject('RecordType');
                if(recordType != null){
                    String recordTypeValue = String.valueOf(recordType.get('DeveloperName'));
                    single.contactRecordType = recordTypeValue;
                }
            }

            if(emptySet.contains(single.phone)){
                single.phone = '';
            }
            if(emptySet.contains(single.email)){
                single.email = '';
            }

            output.add(single);

            recordIds.add(single.recordId);
        }

        Map<Id, mvWrappers.RecordPermissionWrapper> recordAccess = getRecordPermissions(recordIds);

        for(mvWrappers.MatterEngagementModelWrapper single : output){
            single.recordPermission = recordAccess.get(single.recordId);
        }

        return output;
    }

    @AuraEnabled
    public static List<mvWrappers.ClientEngagementModelWrapper> getClientEngagementModelsToAddForMem(Id recordId){
        List<mvWrappers.ClientEngagementModelWrapper> output = new List<mvWrappers.ClientEngagementModelWrapper>();

        String sobjectType = recordId.getSobjectType().getDescribe().getName();

        if(!APPLICATION.SOBJECT_TO_MEM_MATTER_LOOKUP_FIELD.containsKey( sobjectType )){
            throw new NotValidObjectException('Not valid object ' + sobjectType);
        }

        Set<String> matterFields = new Set<String>{
            'Id'
            , APPLICATION.SOBJECT_TO_CLIENT_ID_FIELD.get( sobjectType )
        };

        if( APPLICATION.SOBJECT_TO_JURISDICTION_LOOKUP_FIELD.containsKey( sobjectType )){
            matterFields.add( APPLICATION.SOBJECT_TO_JURISDICTION_LOOKUP_FIELD.get( sobjectType) );
        }

        String matterQuery = ' SELECT ' + String.join( matterFields, ', ') +
                            '  FROM ' + sobjectType +
                            '  WHERE Id = :recordId';
        
        List<sObject> matterRecord = Database.query( matterQuery );

        if(matterRecord.size() == 0){
            return null;
        }

        Id clientId = null;
        Id jurisdictionId = null;
        String matterEngagementModelMatterLookup = APPLICATION.SOBJECT_TO_MEM_MATTER_LOOKUP_FIELD.get( sobjectType );

        clientId = (Id) matterRecord[0].get( APPLICATION.SOBJECT_TO_CLIENT_ID_FIELD.get( sobjectType ) );
        if( APPLICATION.SOBJECT_TO_JURISDICTION_LOOKUP_FIELD.containsKey( sobjectType )){
            jurisdictionId = (Id) matterRecord[0].get( APPLICATION.SOBJECT_TO_JURISDICTION_LOOKUP_FIELD.get( sobjectType ) );
        }
        
        
        Map<String, Object> bindMap = new Map<String, Object>();

        bindMap.put('clientId', clientId);
        bindMap.put('jurisdictionId', jurisdictionId);
        bindMap.put('recordId', recordId);

        Set<String> cemIpMattes = APPLICATION.SOBJECT_TO_CEM_IP_MATTER.get( sobjectType );
        

        
        String query = ' SELECT ' + String.join(fieldsClientEngagementModel, ', ') +
            ' FROM SymphonyLF__Client_Engagement_Model__c ' +
            ' WHERE ' + 
                ' SymphonyLF__Client__c ' + ' = :clientId ' +
                ' AND Is_Active__c = true ' +
                ' AND Id NOT IN ' +
                    ' ( ' + 
                        ' SELECT Client_Engagement_Model__c ' + 
                        ' FROM SymphonyLF__Matter_Engagement_Model__c ' +
                        ' WHERE ' + matterEngagementModelMatterLookup + ' = :recordId ' +
                    ' ) ';

        if(jurisdictionId != null){
            query += ' AND ( SymphonyLF__Applicable_to_all_jurisdiction__c = true OR SymphonyLF__Jurisdiction__c = :jurisdictionId )';
        }

        if(cemIpMattes != null && cemIpMattes.size() > 0){
            String cemIpMattersString = '(\'' + String.join(cemIpMattes, '\',\'') + '\')';
            query += ' AND SymphonyLF__IP_Matters__c INCLUDES ' + cemIpMattersString ;
        }

        query += ' ORDER BY Is_Default__c DESC, Sequence__c ASC, SymphonyLF__Person__r.Name ASC NULLS LAST ';
                

        List<sObject> records = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);

        for(sObject rec : records){
            mvWrappers.ClientEngagementModelWrapper single = new mvWrappers.ClientEngagementModelWrapper();

            single.recordId = (Id) rec.get('Id') ;
            single.symphonyId = String.valueOf( rec.get('Name') );
            single.type = String.valueof( rec.get('SymphonyLF__Type__c') );
            single.contactName = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('Name') );
            single.phone = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Phone_Number__c') );
            single.email = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Email__c') );
            single.isDefault = Boolean.valueOf(rec.get('Is_Default__c'));
            single.isActive = Boolean.valueOf( rec.get('Is_Active__c') );
            single.contactRecordId = (Id) rec.get('SymphonyLF__Person__c') ;
            single.ipMatters = String.valueOf( rec.get('SymphonyLF__IP_Matters__c') );

            Set<String> jurisdictions = new Set<String>();

            Boolean allJurisdictions = Boolean.valueOf( rec.get('SymphonyLF__Applicable_to_all_jurisdiction__c') );
            
            single.createdDateTime = DateTime.valueOf( rec.get('CreatedDate') );
            if(allJurisdictions == true){
                jurisdictions.add( 'All' );
            }
            else{
                String jurisdictionName = String.valueof( rec.getSobject('SymphonyLF__Jurisdiction__r')?.get('Name') );
                if(emptySet.contains(jurisdictionName)){
                    jurisdictionName = '';
                }
                jurisdictions.add( jurisdictionName );
            }
            single.jurisdictions = String.join(jurisdictions, ', ');

            single.contactRecordType = '';
            sObject person = rec.getSobject('SymphonyLF__Person__r');
            if(person != null){
                sObject recordType = person.getSobject('RecordType');
                if(recordType != null){
                    String recordTypeValue = String.valueOf(recordType.get('DeveloperName'));
                    single.contactRecordType = recordTypeValue;
                }
            }

            if(emptySet.contains(single.phone)){
                single.phone = '';
            }
            if(emptySet.contains(single.email)){
                single.email = '';
            }

            output.add( single );
        }

        return output;
    }

    @AuraEnabled
    public static void addCemsToMems(Id recordId, List<Id> cemIds){
        if(
            cemIds == null 
            ||
            cemIds.size() == 0
        ){
            return;
        }

        String sobjectType = recordId.getSobjectType().getDescribe().getName();

        Set<String> matterFields = new Set<String>{
            'Id'
            , APPLICATION.SOBJECT_TO_CLIENT_ID_FIELD.get( sobjectType )
        };

        if( APPLICATION.SOBJECT_TO_JURISDICTION_LOOKUP_FIELD.containsKey( sobjectType )){
            matterFields.add( APPLICATION.SOBJECT_TO_JURISDICTION_LOOKUP_FIELD.get( sobjectType) );
        }

        String matterQuery = ' SELECT ' + String.join( matterFields, ', ') +
                            '  FROM ' + sobjectType +
                            '  WHERE Id = :recordId';

        List<sObject> matterRecord = Database.query( matterQuery );

        Id clientId = (Id) matterRecord[0].get( APPLICATION.SOBJECT_TO_CLIENT_ID_FIELD.get( sobjectType ) );

        String matterEngagementModelMatterLookup = APPLICATION.SOBJECT_TO_MEM_MATTER_LOOKUP_FIELD.get( sobjectType );

        Set<String> memFields = new Set<String>{
            'Id'
            , 'Is_Active__c'
            , 'Client_Engagement_Model__c'
            , 'SymphonyLF__Type__c'
            , 'SymphonyLF__Assign_to_User__c'
        };

        String existingMemQuery = ' SELECT ' + String.join( new List<String>(memFields) , ',') +
                            ' FROM SymphonyLF__Matter_Engagement_Model__c ' +
                            ' WHERE ' + matterEngagementModelMatterLookup + ' = :recordId ';

        List<sObject> existingMemList = Database.query( existingMemQuery );

        Map<String, sObject> CemIdOrTypeAndAssignedToExistingMem = new Map<String, sObject>();

        for(sObject mem : existingMemList){
            String cemId = String.valueOf( mem.get('Client_Engagement_Model__c') );
            String typeAndPersonId = String.valueOf( mem.get('SymphonyLF__Type__c') ) + '-' + String.valueOf( mem.get('SymphonyLF__Assign_to_User__c') );

            CemIdOrTypeAndAssignedToExistingMem.put( cemId, mem );
            CemIdOrTypeAndAssignedToExistingMem.put( typeAndPersonId, mem );
        }

        String cemQuery = ' SELECT ' + String.join( fieldsClientEngagementModel , ', ') +
                        ' FROM SymphonyLF__Client_Engagement_Model__c ' +
                        ' WHERE ' + 
                            ' Id in :cemIds ';

        List<sObject> cemRecords = Database.query( cemQuery );

        List<sObject> memsToAdd = new List<sObject>();

        for(sObject cem : cemRecords){
            String cemId = String.valueOf( cem.get('Id') );
            String typeAndPersonId = String.valueOf( cem.get('SymphonyLF__Type__c') ) + '-' + String.valueOf( cem.get('SymphonyLF__Person__c') );

            if( 
                CemIdOrTypeAndAssignedToExistingMem.containsKey(cemId) 
                ||
                CemIdOrTypeAndAssignedToExistingMem.containsKey(typeAndPersonId)
            ){
                continue;
            }

            sObject toCreate = (sObject) Type.forName('SymphonyLF__Matter_Engagement_Model__c').newInstance();
            toCreate.put('Client_Engagement_Model__c', cemId );
            toCreate.put('Is_Active__c', true );
            toCreate.put(matterEngagementModelMatterLookup, recordId);
            toCreate.put('SymphonyLF__Client__c', clientId );
            toCreate.put('SymphonyLF__Assign_to_User__c', cem.get('SymphonyLF__Person__c'));
            toCreate.put('SymphonyLF__Type__c', cem.get('SymphonyLF__Type__c') );

            memsToAdd.add( toCreate );
        }

        if( memsToAdd.size() > 0 ){
            insert memsToAdd;
        }

    }

    @AuraEnabled(cacheable=true)
    public static mvWrappers.ObjectPermissionsWrapper getObjectPermission(String objectApiName){
        mvWrappers.ObjectPermissionsWrapper permissions = new mvWrappers.ObjectPermissionsWrapper();
        sObject s = (sObject) Type.forName(objectApiName).newInstance();
        Schema.DescribeSObjectResult res = s.getSObjectType().getDescribe();

        permissions.canRead = res.isAccessible();
        permissions.canCreate = res.isCreateable();
        permissions.canEdit = res.isUpdateable();
        permissions.canDelete = res.isDeletable();

        return permissions;
    }

    @AuraEnabled 
    public static Map<Id,mvWrappers.RecordPermissionWrapper> getRecordPermissions(List<Id> recordIds){
        Map<Id,mvWrappers.RecordPermissionWrapper> permissions = new Map<Id,mvWrappers.RecordPermissionWrapper>();

        List<UserRecordAccess> overAll = new List<UserRecordAccess>();

        Integer chunkSize = 200;

        for (Integer i = 0; i < recordIds.size(); i += chunkSize) {
            List<Id> chunk = new List<Id>();
            
            // Loop to manually extract a sublist
            for (Integer j = i; j < Math.min(i + chunkSize, recordIds.size()); j++) {
                chunk.add(recordIds[j]);
            }
        
            // Process the chunk
            System.debug('Processing chunk: ' + chunk);

            List<UserRecordAccess> recordAcceses = [
                SELECT 
                    RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess, MaxAccessLevel
                FROM 
                    UserRecordAccess
                WHERE 
                    RecordId IN :chunk
                    AND 
                    UserId = :UserInfo.getUserId()
            ];

            overAll.addAll(recordAcceses);
        }

        

        for(UserRecordAccess u : overAll){
            mvWrappers.RecordPermissionWrapper r = new mvWrappers.RecordPermissionWrapper();
            r.canRead = u.HasReadAccess;
            r.canCreate = u.HasEditAccess;
            r.canEdit = u.HasEditAccess;
            r.canDelete = u.HasDeleteAccess;

            permissions.put(u.RecordId,r);
        }
        return permissions;
    }

    @AuraEnabled
    public static List<mvWrappers.ClientEngagementModelWrapper> getClientEngagementModels(Id recordId){
        List<mvWrappers.ClientEngagementModelWrapper> output = new List<mvWrappers.ClientEngagementModelWrapper>();

        String sobjectType = recordId.getSobjectType().getDescribe().getName();

        if(! sobjectType.equals(mvConstants.CLIENT_OBJECT_NAME) ){
            throw new NotValidObjectException('Not valid object ' + sobjectType);
        }

        Map<String, Object> bindMap = new Map<String, Object>();

        bindMap.put('lookupFieldValue', recordId);
        
        String query = ' SELECT ' + String.join(fieldsClientEngagementModel, ', ') +
            ' FROM SymphonyLF__Client_Engagement_Model__c ' +
            ' WHERE ' + ' SymphonyLF__Client__c = :lookupFieldValue ' +
            ' ORDER BY Is_Active__c DESC, Is_Default__c DESC, Sequence__c ASC, SymphonyLF__Person__r.Name ASC NULLS LAST ';
                

        List<sObject> records = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
        List<Id> recordIds = new List<Id>();
        for(sObject rec : records){
            mvWrappers.ClientEngagementModelWrapper single = new mvWrappers.ClientEngagementModelWrapper();

            single.recordId = (Id) rec.get('Id') ;
            single.symphonyId = String.valueOf( rec.get('Name') );
            single.type = String.valueof( rec.get('SymphonyLF__Type__c') );
            single.contactName = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('Name') );
            single.phone = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Phone_Number__c') );
            single.email = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Email__c') );
            single.contactRecordId = (Id) rec.get('SymphonyLF__Person__c') ;
            single.ipMatters = String.valueOf( rec.get('SymphonyLF__IP_Matters__c') );
            single.isDefault = Boolean.valueOf( rec.get('Is_Default__c') );
            single.isActive = Boolean.valueOf( rec.get('Is_Active__c') );

            Set<String> jurisdictions = new Set<String>();

            Boolean allJurisdictions = Boolean.valueOf( rec.get('SymphonyLF__Applicable_to_all_jurisdiction__c') );
            
            single.createdDateTime = DateTime.valueOf( rec.get('CreatedDate') );
            if(allJurisdictions == true){
                jurisdictions.add( 'All' );
            }
            else{
                String jurisdictionName = String.valueof( rec.getSobject('SymphonyLF__Jurisdiction__r')?.get('Name') );
                if(emptySet.contains(jurisdictionName)){
                    jurisdictionName = '';
                }
                jurisdictions.add( jurisdictionName );
            }
            single.jurisdictions = String.join(jurisdictions, ', ');

            single.contactRecordType = '';
            sObject person = rec.getSobject('SymphonyLF__Person__r');
            if(person != null){
                sObject recordType = person.getSobject('RecordType');
                if(recordType != null){
                    String recordTypeValue = String.valueOf(recordType.get('DeveloperName'));
                    single.contactRecordType = recordTypeValue;
                }
            }

            if(emptySet.contains(single.phone)){
                single.phone = '';
            }
            if(emptySet.contains(single.email)){
                single.email = '';
            }

            output.add(single);

            recordIds.add(single.recordId);
        }

        Map<Id, mvWrappers.RecordPermissionWrapper> recordAccess = getRecordPermissions(recordIds);

        for(mvWrappers.ClientEngagementModelWrapper single : output){
            single.recordPermission = recordAccess.get(single.recordId);
        }

        return output;
    }

    // .getUserTimezoneOffset;
    @AuraEnabled(cacheable=true)
    public static String getUserTimezoneOffset() {
        User u = [SELECT TimeZoneSidKey, LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug(u.TimeZoneSidKey);
        return u.TimeZoneSidKey;
    }

    @AuraEnabled(cacheable=true)
    public static String getUserLocale() {
        User u = [SELECT TimeZoneSidKey, LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug(u.LocaleSidKey);
        return u.LocaleSidKey;
    }

    static Set<String> fieldsMatterEngagementModels = new Set<String>{
        'Name',
        'Sequence__c',
        'Id',
        'SymphonyLF__Type__c',
        'Is_Active__c',
        'Is_Default__c',
        'Client_Engagement_Model__c',
        'Client_Engagement_Model__r.Name',
        'SymphonyLF__Assign_to_User__r.SymphonyLF__Type__c',
        'SymphonyLF__Assign_to_User__c',
        'SymphonyLF__Assign_to_User__r.Name',
        'SymphonyLF__Assign_to_User__r.RecordType.DeveloperName',
        'SymphonyLF__Assign_to_User__r.SymphonyLF__Email__c',
        'SymphonyLF__Assign_to_User__r.SymphonyLF__Phone_Number__c'
    };

    static Set<String> clientRestrictions = new Set<String>{
        'Name',
        'Client__c',
        'Id',
        'Revoke_Record_Access__c',
        'Person__r.SymphonyLF__Type__c',
        'Person__c',
        'Person__r.Name',
        'Person__r.RecordType.DeveloperName',
        'Person__r.SymphonyLF__Email__c',
        'Person__r.SymphonyLF__Phone_Number__c',
        'User__c'
        , 'Status__c'
        
    };

    static Set<String> fieldsClientEngagementModel = new Set<String>{
        'Id',
        'Name',
        'Is_Default__c',
        'Is_Active__c',
        'SymphonyLF__Person__c',
        'SymphonyLF__Person__r.Name',
        'SymphonyLF__Person__r.RecordType.DeveloperName',
        'SymphonyLF__Person__r.SymphonyLF__Email__c',
        'SymphonyLF__Person__r.SymphonyLF__Phone_Number__c',
        'SymphonyLF__Type__c',
        'SymphonyLF__IP_Matters__c',
        'SymphonyLF__Applicable_to_all_jurisdiction__c',
        'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Jurisdiction__r.Name',
        'CreatedDate'
    };

    @AuraEnabled
    public static List<mvWrappers.mvPortfolioWrapper> getClientPortfolio(Id recordId){
        List<mvWrappers.mvPortfolioWrapper> porfolioRecords = new List<mvWrappers.mvPortfolioWrapper>();

        

        List <SymphonyLF__Patent__c> patentRecords = new List<SymphonyLF__Patent__c> ();
        patentRecords = [SELECT Id
                              , SymphonyLF__Case_Type__c 
                              , SymphonyLF__Docket_Number__c
                              , SymphonyLF__Country__r.Name
                              , SymphonyLF__Title__c
                              , SymphonyLF__Patent_Status__c
                           FROM SymphonyLF__Patent__c 
                          WHERE SymphonyLF__Client__c =:recordId
                           WITH SECURITY_ENFORCED];

        for (SymphonyLF__Patent__c eachRecord : patentRecords) { 
            mvWrappers.mvPortfolioWrapper portfolioRecord = new mvWrappers.mvPortfolioWrapper();
            portfolioRecord.recordId = eachRecord.Id; 
            portfolioRecord.assetJurisdiction = eachRecord.SymphonyLF__Country__r.Name;
            portfolioRecord.assetCaseType = eachRecord.SymphonyLF__Case_Type__c;
            portfolioRecord.assetStatus = eachRecord.SymphonyLF__Patent_Status__c;
            portfolioRecord.assetTitle = eachRecord.SymphonyLF__Title__c;
            portfolioRecord.docketNumber = eachRecord.SymphonyLF__Docket_Number__c;
            portfolioRecord.assetType = 'Patent';
            porfolioRecords.add(portfolioRecord);
        }

        List <SymphonyLF__Trademark__c> trademarkRecords = new List<SymphonyLF__Trademark__c> ();
        trademarkRecords = [SELECT Id
                              , SymphonyLF__Case_Type__c 
                              , SymphonyLF__Docket_Number__c
                              , SymphonyLF__Jurisdiction__r.Name
                              , Name
                              , SymphonyLF__Status__c
                           FROM SymphonyLF__Trademark__c 
                          WHERE SymphonyLF__Client__c =:recordId
                           WITH SECURITY_ENFORCED];

        for (SymphonyLF__Trademark__c eachRecord : trademarkRecords) { 
            mvWrappers.mvPortfolioWrapper portfolioRecord = new mvWrappers.mvPortfolioWrapper();
            portfolioRecord.recordId = eachRecord.Id; 
            portfolioRecord.assetJurisdiction = eachRecord.SymphonyLF__Jurisdiction__r.Name;
            portfolioRecord.assetCaseType = eachRecord.SymphonyLF__Case_Type__c;
            portfolioRecord.assetStatus = eachRecord.SymphonyLF__Status__c;
            portfolioRecord.assetTitle = eachRecord.Name;
            portfolioRecord.docketNumber = eachRecord.SymphonyLF__Docket_Number__c;
            portfolioRecord.assetType = 'Trademark';
            porfolioRecords.add(portfolioRecord);
        }

        List <SymphonyLF__Design__c> designRecords = new List<SymphonyLF__Design__c> ();
        designRecords = [SELECT Id
                              , SymphonyLF__Case_Type__c 
                              , SymphonyLF__Docket_Number__c
                              , SymphonyLF__Jurisdiction__r.Name
                              , Name
                              , SymphonyLF__Design_Status__c
                           FROM SymphonyLF__Design__c 
                          WHERE SymphonyLF__Client__c =:recordId
                           WITH SECURITY_ENFORCED];

        for (SymphonyLF__Design__c eachRecord : designRecords) { 
            mvWrappers.mvPortfolioWrapper portfolioRecord = new mvWrappers.mvPortfolioWrapper();
            portfolioRecord.recordId = eachRecord.Id; 
            portfolioRecord.assetJurisdiction = eachRecord.SymphonyLF__Jurisdiction__r.Name;
            portfolioRecord.assetCaseType = eachRecord.SymphonyLF__Case_Type__c;
            portfolioRecord.assetStatus = eachRecord.SymphonyLF__Design_Status__c;
            portfolioRecord.assetTitle = eachRecord.Name;
            portfolioRecord.docketNumber = eachRecord.SymphonyLF__Docket_Number__c;
            portfolioRecord.assetType = 'Design';
            porfolioRecords.add(portfolioRecord);
        }

        List <SymphonyLF__Dispute_Opposition__c> disputeRecords = new List<SymphonyLF__Dispute_Opposition__c> ();
        disputeRecords = [SELECT Id
                              , SymphonyLF__Dispute_Type__c 
                              , SymphonyLF__Docket_Number__c
                              , SymphonyLF__Jurisdiction__r.Name
                              , Name
                              , SymphonyLF__Status__c	
                           FROM SymphonyLF__Dispute_Opposition__c 
                          WHERE SymphonyLF__Client__c =:recordId
                           WITH SECURITY_ENFORCED];

        for (SymphonyLF__Dispute_Opposition__c eachRecord : disputeRecords) { 
            mvWrappers.mvPortfolioWrapper portfolioRecord = new mvWrappers.mvPortfolioWrapper();
            portfolioRecord.recordId = eachRecord.Id; 
            portfolioRecord.assetJurisdiction = eachRecord.SymphonyLF__Jurisdiction__r.Name;
            portfolioRecord.assetCaseType = eachRecord.SymphonyLF__Dispute_Type__c;
            portfolioRecord.assetStatus = eachRecord.SymphonyLF__Status__c;
            portfolioRecord.assetTitle = eachRecord.Name;
            portfolioRecord.docketNumber = eachRecord.SymphonyLF__Docket_Number__c;
            portfolioRecord.assetType = 'Disputes';
            porfolioRecords.add(portfolioRecord);
        }

        List <SymphonyLF__Copyright__c> copyrightRecords = new List<SymphonyLF__Copyright__c> ();
        copyrightRecords = [SELECT Id
                              , SymphonyLF__Work_Type__c 
                              , SymphonyLF__Docket_Number__c
                              , SymphonyLF__Jurisdiction__r.Name
                              , Name
                              , SymphonyLF__Status__c	
                           FROM SymphonyLF__Copyright__c 
                          WHERE SymphonyLF__Client__c =:recordId
                           WITH SECURITY_ENFORCED];

        for (SymphonyLF__Copyright__c eachRecord : copyrightRecords) { 
            mvWrappers.mvPortfolioWrapper portfolioRecord = new mvWrappers.mvPortfolioWrapper();
            portfolioRecord.recordId = eachRecord.Id;
            portfolioRecord.assetJurisdiction = eachRecord.SymphonyLF__Jurisdiction__r.Name;
            portfolioRecord.assetCaseType = eachRecord.SymphonyLF__Work_Type__c; // ??Siva
            portfolioRecord.assetStatus = eachRecord.SymphonyLF__Status__c;
            portfolioRecord.assetTitle = eachRecord.Name;
            portfolioRecord.docketNumber = eachRecord.SymphonyLF__Docket_Number__c;
            portfolioRecord.assetType = 'Copyright';
            porfolioRecords.add(portfolioRecord);
        }

        List <SymphonyLF__Agreement_Contract__c> agreementContractRecords = new List<SymphonyLF__Agreement_Contract__c> ();
        agreementContractRecords = [SELECT Id
                              , SymphonyLF__Agreement_Type__c 
                              , SymphonyLF__Docket_Number__c
                              , SymphonyLF__Jurisdiction__r.Name
                              , Name
                              , SymphonyLF__Matter_Status__c	
                           FROM SymphonyLF__Agreement_Contract__c 
                          WHERE SymphonyLF__Client__c =:recordId
                           WITH SECURITY_ENFORCED];

        for (SymphonyLF__Agreement_Contract__c eachRecord : agreementContractRecords) { 
            mvWrappers.mvPortfolioWrapper portfolioRecord = new mvWrappers.mvPortfolioWrapper();
            portfolioRecord.recordId = eachRecord.Id;
            portfolioRecord.assetJurisdiction = eachRecord.SymphonyLF__Jurisdiction__r.Name;
            portfolioRecord.assetCaseType = eachRecord.SymphonyLF__Agreement_Type__c;
            portfolioRecord.assetStatus = eachRecord.SymphonyLF__Matter_Status__c;
            portfolioRecord.assetTitle = eachRecord.Name;
            portfolioRecord.docketNumber = eachRecord.SymphonyLF__Docket_Number__c;
            portfolioRecord.assetType = 'Agreement';
            porfolioRecords.add(portfolioRecord);
        }

        List <SymphonyLF__General_Matter__c> generalMatterRecords = new List<SymphonyLF__General_Matter__c> ();
        generalMatterRecords = [SELECT Id
                                , SymphonyLF__Type__c 
                                , SymphonyLF__Docket_Number__c
                                , SymphonyLF__Jurisdiction__r.Name
                                , Name
                                , SymphonyLF__Matter_Status__c	
                            FROM SymphonyLF__General_Matter__c 
                            WHERE SymphonyLF__Client__c =:recordId
                            WITH SECURITY_ENFORCED];

        for (SymphonyLF__General_Matter__c eachRecord : generalMatterRecords) { 
            mvWrappers.mvPortfolioWrapper portfolioRecord = new mvWrappers.mvPortfolioWrapper();
            portfolioRecord.recordId = eachRecord.Id;
            portfolioRecord.assetJurisdiction = eachRecord.SymphonyLF__Jurisdiction__r.Name;
            portfolioRecord.assetCaseType = eachRecord.SymphonyLF__Type__c;
            portfolioRecord.assetStatus = eachRecord.SymphonyLF__Matter_Status__c;
            portfolioRecord.assetTitle = eachRecord.Name;
            portfolioRecord.docketNumber = eachRecord.SymphonyLF__Docket_Number__c;
            portfolioRecord.assetType = 'General Matter';
            porfolioRecords.add(portfolioRecord);
        } 

        return porfolioRecords;
    }

    @AuraEnabled(cacheable = true)
    public static Boolean hadFieldEditAccess(String objectName, String fieldName){
        Schema.DescribeSObjectResult DescribeSObjectResultObj = ( (sObject) Type.forname( objectName ).newInstance() ).getSobjectType().getDescribe();

        Boolean hasObjectEditAccess = DescribeSObjectResultObj.isUpdateable();
        Map<String, Schema.SObjectField> fieldsMap = DescribeSObjectResultObj.fields.getMap();
        Boolean isFieldUpdateable = fieldsMap.get( fieldName ).getDescribe().isUpdateable();

        return hasObjectEditAccess && isFieldUpdateable;
    }

    @AuraEnabled(cacheable = true)
    public static Boolean hasRecordEditAccess(Id recordId){
        if(recordId == null) return true;

        Boolean hasEditAccess = false;
        UserRecordAccess userRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =: recordId];
        hasEditAccess = userRecordAccess.HasEditAccess;

        return hasEditAccess;
    }

    public class NotValidObjectException extends Exception{

    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfile() {
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.Profile.Name;
    }
}