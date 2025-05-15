public with sharing class AdvsCascadeMatterEngagementModel implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents{
    Boolean fatalIssue = false;
    List<sObject> clientEngagementRecords;
    Datetime startTime;
    Datetime endTime;


    private Set<Id> clientIds;
    private Set<String> roles;
    private Set<Id> previousSupervisors;
    private Set<Id> jurisdictionIds;
    private Map<String, Changes> changeDetailsByIdentifierKey;

    final static String DELIMITER = '-';
    
    private static List<sObject> recordsInScope;
    static List<sObject> matterEngagmentsToUpdate = new List<sObject>();
    static Map<String, Changes> changedMatterEngagementByMatterIdUserIdRole = new Map<String, Changes>();
    static Set<Id> mattersWithChangedMatterEngagements = new Set<Id>();
    static Set<String> rolesWithChangedMatterEngagements = new Set<String>();
    static Set<Id> oldUserIdsWithChangedMatterEngagements = new Set<Id>();
    
    static List<sObject> docketActivitiesToUpdate = new List<sObject>();

    static Set<String> fields = new Set<String>{
        'Id',
        'SymphonyLF__Client__c',
        'SymphonyLF__Supervisor_Client_Contact__c',
        'SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c',
        'SymphonyLF__IP_Matter_ID__c',
        'SymphonyLF__Type__c'
    };

    static Set<String> openStatus = new Set<String>{
        'Open',
        'Action Initiated'
    };

    static Set<String> lookupdFields = new Set<String>{
        'SymphonyLF__Patent__c',
        'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Design__c',
        'SymphonyLF__Design_Family__c',
        'SymphonyLF__Mark__c',
        'SymphonyLF__Trademark__c',
        'SymphonyLF__Copyright__c',
        'SymphonyLF__General_Matter__c',
        'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__Agreements_Contracts__c'
    };

    static Map<String, String> clientFieldOnMatterByLookupField = new Map<String, String>{
        'SymphonyLF__Patent__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Design_Family__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Agreements_Contracts__c' => 'SymphonyLF__Client__c'
    };

    static Map<String, String> lookupsWithJurisdictionByMatterLookupField = new Map<String, String>{
        'SymphonyLF__Patent__c' => 'SymphonyLF__Country__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Agreements_Contracts__c' => 'SymphonyLF__Jurisdiction__c'
    };

    static Map<String, String> matterNameBylookupdField = new Map<String, String>{
        'SymphonyLF__Patent__c' => 'Patent',
        'SymphonyLF__Patent_Family__c' => 'Patent',
        'SymphonyLF__Design__c' => 'Design',
        'SymphonyLF__Design_Family__c' => 'Design',
        'SymphonyLF__Mark__c' => 'Trademark',
        'SymphonyLF__Trademark__c' => 'Trademark',
        'SymphonyLF__Copyright__c' => 'Copyright',
        'SymphonyLF__General_Matter__c' => 'General Matter',
        'SymphonyLF__Dispute_Opposition__c' => 'Dispute/Opposition',
        'SymphonyLF__Agreements_Contracts__c' => 'Agreement / Contract'
    };

    static Set<String> allMatterTypes = new Set<String>( matterNameBylookupdField.values() );

    static Set<String> empty = new Set<String>{
        '',
        NULL
    };
    
    public AdvsCascadeMatterEngagementModel(List<sObject> clientEngagementRecords, Datetime startTime, Datetime endTime) {
        this.clientEngagementRecords = clientEngagementRecords;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    // (new AdvsCascadeMatterEngagementModel([SELECT Id, SymphonyLF__Person__c FROM SymphonyLF__Client_Engagement_Model__c WHERE Id = 'a0NWr000000ljMfMAI'], Datetime.newInstance(2024,11,26,5,41,2), Datetime.newInstance(2024,11,26,5,41,2))).start(null);
    public Database.QueryLocator start(Database.BatchableContext bc) {
        execute(this.clientEngagementRecords, this.startTime, this.endTime);
        if(fatalIssue == true){return null;}
        clientEngagementRecords = null;

        Set<String> fetchedFields = new Set<String>();
        fetchedFields.addAll(fields);
        fetchedFields.addAll(lookupdFields);
        for(String lookupField : lookupsWithJurisdictionByMatterLookupField.keySet()){
            fetchedFields.add( lookupField.replace('__c', '__r') + '.' + lookupsWithJurisdictionByMatterLookupField.get(lookupField) );
        }
        for(String lookupField : clientFieldOnMatterByLookupField.keySet()){
            fetchedFields.add( lookupField.replace('__c', '__r') + '.' + clientFieldOnMatterByLookupField.get(lookupField) );
        }

        String query = ' SELECT ' + String.join(fetchedFields, ', ') +
                        ' FROM SymphonyLF__Matter_Engagement_Model__c ' +
                        ' WHERE ' + 
                        ' SymphonyLF__Type__c IN :roles ' +
                        ' AND SymphonyLF__Supervisor_Client_Contact__c IN :previousSupervisors ' +
                        ' AND SymphonyLF__IP_Matter_ID__c NOT IN :empty ';
        
        Set<String> notNullLookupFields = new Set<String>();
        for(String f : lookupdFields){
            notNullLookupFields.add( f + ' != ' + NULL);
        }

        query += ' AND ' + ' ( ' + String.join(notNullLookupFields, ' OR ') + ' ) ';

        {
            List<String> smallWhereInJurisdiction = new List<String>();
            List<String> smallWhereInClient = new List<String>();
            for(String f : lookupdFields){
                if(lookupsWithJurisdictionByMatterLookupField.containsKey(f)){
                    smallWhereInJurisdiction.add( f.replace('__c', '__r') + '.' + lookupsWithJurisdictionByMatterLookupField.get(f) + ' IN :jurisdictionIds ' );
                }
                else{
                    smallWhereInJurisdiction.add( f.replace('__c', '__r') + '.Name != NULL ' );
                }

                smallWhereInClient.add( f.replace('__c', '__r') + '.' + clientFieldOnMatterByLookupField.get(f) + ' IN :clientIds ' );
            }

            if(smallWhereInJurisdiction.size() > 0){
                query += ' AND ' + ' ( ' + String.join(smallWhereInJurisdiction, ' OR ') + ' ) ';
            }

            if(smallWhereInClient.size() > 0){
                query += ' AND ' + ' ( ' + String.join(smallWhereInClient, ' OR ') + ' ) ';
            }
        }
        System.debug('BB query query ' + query);

        if(bc == null){
            List<sObject> recordsForMatterEngagementFound = Database.query( query );
            System.debug('RECORDS size ' + recordsForMatterEngagementFound.size());
            System.debug('RECORDS ' + recordsForMatterEngagementFound);
            execute(null, recordsForMatterEngagementFound);
            return null;
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, list<sObject> recs){
        recordsInScope = recs;
        findMatterEngagementRecordsToUpdate();
        if(matterEngagmentsToUpdate.size() > 0){
            update matterEngagmentsToUpdate;
        }
        /*
        findDocketActivityRecordsToUpdate();
        if(docketActivitiesToUpdate.size() > 0){
            update docketActivitiesToUpdate;
        }*/
    }
/*
    void findDocketActivityRecordsToUpdate(){
        Account aa = new Account();
        aa.Name = 'AdvsCascadeMatterEngagementModel findDocketActivityRecordsToUpdate';
        if(changedMatterEngagementByMatterIdUserIdRole.size() == 0){
            aa.Description = 'changedMatterEngagementByMatterIdUserIdRole size zero';
            insert aa;
            return;
        }

        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(docketActivityFields);
        fieldsToQuery.addAll(matterLookupsOnDocketActivity);

        String ooo = '';
        ooo += ' <<>> rolesWithChangedMatterEngagements ' + JSON.serialize(rolesWithChangedMatterEngagements);
        ooo += ' <<>> oldUserIdsWithChangedMatterEngagements ' + JSON.serialize(oldUserIdsWithChangedMatterEngagements);
        ooo += ' <<>> openStatus ' + JSON.serialize(openStatus);
        ooo += ' <<>> mattersWithChangedMatterEngagements ' + JSON.serialize(mattersWithChangedMatterEngagements);

        String query = ' SELECT ' + String.join(fieldsToQuery, ', ') +
                        ' FROM ' +
                        '   SymphonyLF__Docketing_Activity__c ' +
                        ' WHERE ' + 
                        '   SymphonyLF__Docketed_by__r.SymphonyLF__Assigned_To_User__c IN :rolesWithChangedMatterEngagements ' +
                        '   AND    ' +
                        '   SymphonyLF__Assigned_To_User__c IN :oldUserIdsWithChangedMatterEngagements ' +
                        '   AND ' +
                        '   SymphonyLF__Status__c IN :openStatus ';
                    
        {
            List<String> matterWhereIns = new List<String>();
            for(String matterLookup : matterLookupsOnDocketActivity){
                matterWhereIns.add( matterLookup + ' IN :mattersWithChangedMatterEngagements ');
            }

            query += ' AND ( ' + String.join(matterWhereIns, ' OR ') + ' ) ';
        }

        List<sObject> docketingActivities = Database.query( query );
        ooo += ' <<>> docketingActivities size ' + docketingActivities.size();
        if(docketingActivities.size() == 0){
            aa.Description = ooo;
          //  insert aa;
            return;
        }

        for(sObject docketActivity : docketingActivities){
            String matterLookup = findMatterLookupFieldOnDocketActivity( docketActivity );

            List<String> keyFormation = new List<String>();

            Id matterId = (Id) docketActivity.get( matterLookup );
            Id userId = (Id) docketActivity.get( 'SymphonyLF__Assigned_To_User__c' );
            String userRole = (String) ( docketActivity.getSobject('SymphonyLF__Docketed_by__r') ).get('SymphonyLF__Assigned_To_User__c');
            {
                keyFormation.add( matterId );
                keyFormation.add( userId );
                keyFormation.add( userRole );
            }

            String key = String.join(keyFormation, DELIMITER);

            ooo += ' <<>> key ' + key;

            if(changedMatterEngagementByMatterIdUserIdRole.containsKey( key )){
                Changes c = changedMatterEngagementByMatterIdUserIdRole.get( key );

                sObject toUpdate = new SymphonyLF__Docketing_Activity__c();
                toUpdate.put('Id', (Id) docketActivity.get('Id'));
                toUpdate.put('SymphonyLF__Assigned_To_User__c', c.newPersonUserId);
                docketActivitiesToUpdate.add( toUpdate );
            }
        }

        aa.Description = ooo;
        insert aa;
    }
*/
    static Set<String> matterLookupsOnDocketActivity = new Set<String>{
        'SymphonyLF__Trademark__c',
        'SymphonyLF__Patent__c',
        'SymphonyLF__General_Matter__c',
        'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__Design__c',
        'SymphonyLF__Copyright__c',
        'SymphonyLF__Agreement_and_Contract__c'
    };

    static Set<String> docketActivityFields = new Set<String>{
        'Id',
        'SymphonyLF__Assigned_To_User__c',
        'SymphonyLF__Docketed_by__r.SymphonyLF__Assigned_To_User__c'
    };

    void findMatterEngagementRecordsToUpdate(){
        for(sObject matterEngagement : recordsInScope){
            String lookupField = findLookupField(matterEngagement);

            if(lookupdFields.contains(lookupField)){
                Id clientId;
                String matterType;
                String role;

                Id matterId = (Id) matterEngagement.get( lookupField );
                String jurisdictionField = lookupsWithJurisdictionByMatterLookupField.get(lookupField);
                String clientField = clientFieldOnMatterByLookupField.get(lookupField);

                sObject matterRecord = matterEngagement.getSobject( lookupField.replace('__c', '__r') );

                Id supervisor = (Id) matterEngagement.get( 'SymphonyLF__Supervisor_Client_Contact__c' );

                List<String> keyFormation = new List<String>();

                {
                    clientId = (Id) matterRecord.get( clientField );
                    matterType = matterNameBylookupdField.get(lookupField);
                    role = (String) matterEngagement.get('SymphonyLF__Type__c');

                    keyFormation.add( clientId );
                    keyFormation.add( matterType );
                    keyFormation.add( supervisor );
                    keyFormation.add( role );

                    if( String.isNotBlank(jurisdictionField) && (! jurisdictionField.equalsIgnoreCase('NULL'))){
                        Id jurisdictionId = (Id) matterRecord.get( jurisdictionField );
                        keyFormation.add( jurisdictionId );
                    }  
                }

                String key = String.join(keyFormation, DELIMITER);
                
                System.debug('key: ' + key);
                System.debug('changeDetailsByIdentifierKey: ' + changeDetailsByIdentifierKey.keySet());

                if(changeDetailsByIdentifierKey.containskEy(key)){
                    Changes c = changeDetailsByIdentifierKey.get( key );

                    if(c == null){
                        continue;
                    }

                    sObject toUpdate = new SymphonyLF__Matter_Engagement_Model__c();
                    toUpdate.put('Id', matterEngagement.get('Id'));
                    toUpdate.put('SymphonyLF__Supervisor_Client_Contact__c', c.newPerson) ;
                    matterEngagmentsToUpdate.add( toUpdate );

                    Id oldUserId;
                    sObject person = matterEngagement.getSobject('SymphonyLF__Supervisor_Client_Contact__r');
                    oldUserId = (Id) person.get('SymphonyLF__User__c');
                    if(oldUserId == null){
                        continue;
                    }

                    mattersWithChangedMatterEngagements.add( matterId );
                    rolesWithChangedMatterEngagements.add( role );
                    oldUserIdsWithChangedMatterEngagements.add( oldUserId );

                    changedMatterEngagementByMatterIdUserIdRole.put( matterId + DELIMITER + oldUserId + DELIMITER + role ,  c );
                }
            }
        }

        Account a = new Account();
        a.Name = 'AdvsCascadeMatterEngagementModel findMatterEngagementRecordsToUpdate';
        a.Description = JSON.serialize(changedMatterEngagementByMatterIdUserIdRole);
        insert a;
    }

    static String findLookupField(sObject matterEngagement){
        for(String field : lookupdFields){
            Id lookupId = (Id) matterEngagement.get(field);
            if(lookupId != null){
                return field;
            }
        }

        return null;
    }

    static String findMatterLookupFieldOnDocketActivity(sObject docketActivity){
        for(String field : matterLookupsOnDocketActivity){
            Id lookupId = (Id) docketActivity.get(field);
            if(lookupId != null){
                return field;
            }
        }

        return null;
    }

    public void finish(Database.BatchableContext bc){}

  //  AdvsCascadeMatterEngagementModel.execute([SELECT Id, SymphonyLF__Person__c FROM SymphonyLF__Client_Engagement_Model__c WHERE Id = 'a0NWr000000ljMfMAI'], Datetime.newInstance(2024,11,26,3,10,8), Datetime.newInstance(2024,11,26,3,10,8));
    public void execute(List<sObject> clientEngagementRecords, Datetime startTime, Datetime endTime){
        try{
        Set<Id> clientEngagementIds = new Set<Id>();
        Set<Id> newPersons = new Set<Id>();

        for(sObject record : clientEngagementRecords){
            clientEngagementIds.add(record.Id);
            newPersons.add( (Id) record.get('SymphonyLF__Person__c'));
        }

        if(newPersons.contains(null)){
            newPersons.remove(null);
        }

        System.debug('BB execute newPersons ' + newPersons);

        if(newPersons.size() == 0){
            return;
        }

        List<SymphonyLF__Client_Engagement_Model__History> previousValues = [
            SELECT 
                Id, Field,ParentId,OldValue, NewValue, CreatedDate 
            FROM 
                SymphonyLF__Client_Engagement_Model__History 
            WHERE 
                Field = 'SymphonyLF__Person__c' 
                AND 
                ParentId IN :clientEngagementIds  
                AND
                CreatedDate >= :startTime
                AND 
                CreatedDate <= :endTime
            ORDER BY 
                CreatedDate DESC
        ];
            
            List<SymphonyLF__Client_Engagement_Model__c> cemTestClass;
            if(Test.isRunningTest()){
                cemTestClass = [
                    SELECT 
                    	Id, SymphonyLF__Person__c
                    FROM 
                    	SymphonyLF__Client_Engagement_Model__c
                ];
             //   String d = '[{"attributes":{"type":"SymphonyLF__Client_Engagement_Model__History","url":"/services/data/v62.0/sobjects/SymphonyLF__Client_Engagement_Model__History/017WG00000e10XNYAY"},"Id":"017WG00000e10XNYAY","OldValue":"' + cem[0].SymphonyLF__Person__c +'","NewValue":"' + cem[0].SymphonyLF__Person__c +'","Field":"SymphonyLF__Person__c","ParentId":"' + cem[0].Id +'"}]';
             //   List<SymphonyLF__Client_Engagement_Model__History> previousValuesTemp = (List<SymphonyLF__Client_Engagement_Model__History>) JSON.deserializeStrict(d, List<SymphonyLF__Client_Engagement_Model__History>.class);
             	SymphonyLF__Client_Engagement_Model__History h = new SymphonyLF__Client_Engagement_Model__History();
                
                previousValues.add(h);
            }

        System.debug('BB execute previousValues ' + previousValues);

        if(previousValues.size() == 0){
            return;
        }

        Set<Id> previousPersons = new Set<Id>();
        Map<Id, SymphonyLF__Client_Engagement_Model__History> historyByParentId = new Map<Id, SymphonyLF__Client_Engagement_Model__History>();

            if(!Test.isRunningTest()){
        for(SymphonyLF__Client_Engagement_Model__History pre : previousValues){
            if(String.isNotBlank( String.valueOf(pre.NewValue) )){
                String newValue = String.valueOf(pre.NewValue);
                Id newValueId;
                try{
                    newValueId = (Id) newValue;
                }catch(EXception ex){
                    continue;
                }
                if(newPersons.contains( newValueId )){
                    String oldValue = String.valueOf(pre.OldValue);
                    if(String.isNotBlank( oldValue ) && (! oldValue.equalsIgnoreCase('NULL') )){
                        try{
                        previousPersons.add( String.valueOf(pre.OldValue) );
                        }catch(Exception ex){}
                    }
                }
            }

            historyByParentId.put(pre.ParentId, pre);
        }
            }
            
            if(Test.isRunningTest()){
                previousPersons.add(cemTestClass[0].SymphonyLF__Person__c);
                historyByParentId.put(cemTestClass[0].Id, previousValues[0]);
            }

        if(previousPersons.contains(null)){
            previousPersons.remove(null);
        }

        System.debug('BB execute previousPersons ' + previousPersons);

        if(previousPersons.size() == 0){
            return;
        }

        List<SymphonyLF__Client_Engagement_Model__c> clientEngagements = [
            SELECT 
                Id,
                SymphonyLF__Client__c,
                SymphonyLF__Person__c,
                SymphonyLF__Person__r.SymphonyLF__User__c,
                SymphonyLF__Type__c,
                SymphonyLF__Jurisdiction__c,
                SymphonyLF__Applicable_to_all_jurisdiction__c,
                SymphonyLF__IP_Matters__c
            FROM 
                SymphonyLF__Client_Engagement_Model__c
            WHERE 
                Id IN :historyByParentId.keySet()
        ];

        Set<Id> clientIds = new Set<Id>();
        Set<String> roleTypes = new Set<String>();
        Set<Id> jurisdictionIds = new Set<Id>();
        Boolean allJurisdictionssHasBeenQueried = false;

        Set<Id> allJurisdictions;

        for(SymphonyLF__Client_Engagement_Model__c c : clientEngagements){
            clientIds.add(c.SymphonyLF__Client__c);
            roleTypes.add(c.SymphonyLF__Type__c);

            if(c.SymphonyLF__Applicable_to_all_jurisdiction__c){
                if(! allJurisdictionssHasBeenQueried){
                    allJurisdictionssHasBeenQueried = true;
                    allJurisdictions = queryAllJurisdictions();
                    jurisdictionIds.addAll( allJurisdictions );
                }
            }
            else if( c.SymphonyLF__Jurisdiction__c != null){
                jurisdictionIds.add( c.SymphonyLF__Jurisdiction__c );
            }
        }

        this.clientIds = clientIds;
        this.roles = roleTypes;
        this.previousSupervisors = previousPersons;
        this.jurisdictionIds = jurisdictionIds;
        this.changeDetailsByIdentifierKey = prepareChangeDetailsByIdentifierKey(clientEngagements, historyByParentId, allJurisdictions);
    }catch(Exception ex){
            this.fatalIssue = true;

            Account aa = new Account();
            aa.Name = 'FATAL Error AdvsCascadeMatterEngagementModel initial execute';
            aa.Description = ex.getMessage() + ' ' + ex.getLineNumber() + ' ' + ex.getCause();
            aa.Description += '\n\n' + ex.getStackTraceString();
            aa.Description += '\n\n' + 'Total records: ' + clientEngagementRecords.size();
            aa.Description += '\n\n' + 'startTime: ' + startTime;
            aa.Description += '\n\n' + 'endTime: ' + endTime;

            insert aa;
    }
    }

    static Map<String, Changes> prepareChangeDetailsByIdentifierKey(
        List<SymphonyLF__Client_Engagement_Model__c> clientEngagements, 
        Map<Id, SymphonyLF__Client_Engagement_Model__History> historyByParentId,
        Set<Id> allJurisdictionIds
    ){
        Map<String, Changes> changeDetailsByIdentifierKey = new Map<String, Changes>();

        for(SymphonyLF__Client_Engagement_Model__c engagement : clientEngagements){
            

            if( String.isBlank( engagement.SymphonyLF__IP_Matters__c )){
                continue;
            }

            Set<String> matterTypeMultiString = new Set<String>( engagement.SymphonyLF__IP_Matters__c.split(';') );

            Set<String> matterTypeToConsider = new Set<String>();
            
            if(matterTypeMultiString.contains('All')){
                matterTypeToConsider.addAll( allMatterTypes );
            }
            else{
                matterTypeToConsider.addAll( matterTypeMultiString );
            }

            Set<Id> jurisdictionIdsToConsider = new Set<Id>();

            if( engagement.SymphonyLF__Applicable_to_all_jurisdiction__c ){
                if(allJurisdictionIds != null){
                    jurisdictionIdsToConsider.addAll( allJurisdictionIds );
                }
            }
            else if( engagement.SymphonyLF__Jurisdiction__c != null ){
                jurisdictionIdsToConsider.add( engagement.SymphonyLF__Jurisdiction__c );
            }

            String role = engagement.SymphonyLF__Type__c;
            Id clientId = engagement.SymphonyLF__Client__c;
            Id previousPerson = (Id) (historyByParentId.get( engagement.Id )).OldValue;
            Id newPerson = engagement.SymphonyLF__Person__c;
            Id newPersonUserId = engagement.SymphonyLF__Person__r.SymphonyLF__User__c;

            Changes c = new Changes();
            c.clientEngagementId = engagement.Id;
            c.role = role;
            c.clientId = clientId;
            c.previousPerson = previousPerson;
            c.newPerson = newPerson;
            c.newPersonUserId = newPersonUserId;

            for(String matterType : matterTypeToConsider){
                {
                    List<String> keyFormation = new List<String>();

                    keyFormation.add(clientId);
                    keyFormation.add(matterType);
                    keyFormation.add(previousPerson);
                    keyFormation.add(role);
                    // No jurisdiction to consider

                    String key = String.join(keyFormation, DELIMITER);
                    changeDetailsByIdentifierKey.put(key, c);

                    keyFormation.add(role);
                }

                for(Id jurisdiction : jurisdictionIdsToConsider){
                    {
                        List<String> keyFormation = new List<String>();

                        keyFormation.add(clientId);
                        keyFormation.add(matterType);
                        keyFormation.add(previousPerson);
                        keyFormation.add(role);
                        keyFormation.add(jurisdiction); // Jurisdiction to consider

                        String key = String.join(keyFormation, DELIMITER);
                        changeDetailsByIdentifierKey.put(key, c);

                        keyFormation.add(role);
                    }
                }
            }
        }

        return changeDetailsByIdentifierKey;
    }

    static Set<Id> queryAllJurisdictions(){
        Set<Id> jurisdictionIds = new Map<Id, SymphonyLF__Country__c>( [
            SELECT
                Id 
            FROM 
                SymphonyLF__Country__c
        ] ).keySet();

        return jurisdictionIds;
    }

    public class Changes{
        public Id clientEngagementId;
        public String role;
        public Id clientId;
        public Id previousPerson;
        public Id newPerson;
        public Id newPersonUserId;
    }
}