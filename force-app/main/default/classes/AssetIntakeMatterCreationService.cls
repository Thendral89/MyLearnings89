public with sharing class AssetIntakeMatterCreationService {
    Id assetIntakeId;
    Id assetIntakeJurisctionId;

    Boolean doesFamilyExist = true;
    Id familyId;

    Asset_Intake_Jurisdiction__c assetIntakeJurisdiction;

    public AssetIntakeMatterCreationService() {

    }

    public void setAssetIntakeId(Id assetIntakeId) {
        this.assetIntakeId = assetIntakeId;
    }

    public void setAssetIntakeJurisdictionId(Id assetIntakeJurisctionId) {
        this.assetIntakeJurisctionId = assetIntakeJurisctionId;
    }

    public void execute(){
        if(assetIntakeId == null) {
            throw new NoAssetIntakeIdsProvidedException();
        }

        fetchAssetJurisdictionRecord();

        if(assetIntakeJurisdiction == null){
            return;
        }

        extractFieldDetailsFromAssetIntakeJurisdiction();

        createFamilyRecord();

        createMatterRecord();
    }

    Set<String> emptyString = new Set<String>{
        'null',
        'NULL',
        NULL,
        ''
    };

    String assetType;
    String matterLookupFieldOnAssetIntakeJurisdiction = '';
    String familyLookupField;
    String familyNameField;
    String familyObjectName;
    String familyObject;
    String matterObjectName;
    String familyLookupFieldOnMatter;
    Set<String> familyFields = new Set<String>();
    String jurisdictionFieldOnMatter;


    void extractFieldDetailsFromAssetIntakeJurisdiction(){
        this.assetType = (String) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get('Asset_Type__c');
        this.clientId = (Id) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get('Client__c');

        if(assetType == 'New Patent Family' || assetType == 'Existing Patent Family' || assetType == 'Patent'){
            familyLookupField = 'Patent_Family__c';
            familyNameField = 'New_Patent_Family__c';
            familyObjectName = 'SymphonyLF__Patent_Family__c';

            matterLookupFieldOnAssetIntakeJurisdiction = 'Patent__c';

            familyObject = 'SymphonyLF__Patent_Family__c';
            matterObjectName = 'SymphonyLF__Patent__c';
            familyLookupFieldOnMatter = 'SymphonyLF__Patent_Family__c';
            familyFields = new Set<String>{
                'Name'
            };

            jurisdictionFieldOnMatter = 'SymphonyLF__Country__c';
        }
    }

    void createMatterRecord(){
        Boolean doesMatterExist = false;

        System.debug('familyObject ' + familyObject);
        System.debug('familyId ' + familyId);
        String query = ' SELECT ' + String.join(familyFields, ', ') + ' FROM ' + familyObject + ' WHERE Id = :familyId LIMIT 1 ';
        sObject familyRecord = Database.query(query);

        sObject matterRecordToCreate = (Sobject) Type.forName(matterObjectName).newInstance();
        matterRecordToCreate.put(familyLookupFieldOnMatter, familyId);
        matterRecordToCreate.put('Name', familyRecord.get('Name'));
        matterRecordToCreate.put('SymphonyLF__Client__c', (Id) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get('Client__c'));
        matterRecordToCreate.put('SymphonyLF__Case_Type__c', (String) assetIntakeJurisdiction.get('CaseType__c'));
        matterRecordToCreate.put(jurisdictionFieldOnMatter, (Id) assetIntakeJurisdiction.get('Jurisdiction__c'));
        
        matterRecordToCreate.put('SymphonyLF__Client_Reference__c', (Id) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get('Client__c'));
        matterRecordToCreate.put('SymphonyLF__Patent_Status__c', 'Application Preparation');
        matterRecordToCreate.put('SymphonyLF__Active__c', true);

        insert matterRecordToCreate;

        sObject assetIntakeJurisdictionToUpdate = (sObject) Type.forName('Asset_Intake_Jurisdiction__c').newInstance();
        assetIntakeJurisdictionToUpdate.put(matterLookupFieldOnAssetIntakeJurisdiction, matterRecordToCreate.Id);

        update assetIntakeJurisdictionToUpdate;
    }

    void createFamilyRecord(){
        
        Id familyId = (Id) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get(familyLookupField);
        String familyName = (String) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get(familyNameField);

        if((!emptyString.contains(familyName)) && familyId == null){
            doesFamilyExist = false;  
        }
        else{
            doesFamilyExist = true;
            this.familyId = familyId;
        }

        System.debug('doesFamilyExist ' + doesFamilyExist);
        System.debug('familyName ' + familyName);
        System.debug('familyId ' + familyId);
        if(doesFamilyExist) return;

        sObject familyRecordToCreate = (Sobject) Type.forName(familyObjectName).newInstance();
        familyRecordToCreate.put('SymphonyLF__Invention_Title__c', familyName);
        familyRecordToCreate.put('Name', familyName);
        familyRecordToCreate.put('SymphonyLF__Client__c', (Id) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get('Client__c'));
        familyRecordToCreate.put('SymphonyLF__Active__c', true);
        familyRecordToCreate.put('SymphonyLF__Client__c', (Id) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get('Client__c'));

        String department = (String) assetIntakeJurisdiction.getSobject('Asset_Intake_Form__r').get('Department__c');

        if(!emptyString.contains(department)){
            familyRecordToCreate.put('Department__c', department);
        }
       
        insert familyRecordToCreate;

        sObject assetIntakeFormToUpdate =  (Sobject) Type.forName('Asset_Intake_Form__c').newInstance();
        assetIntakeFormToUpdate.put(familyLookupField, familyRecordToCreate.Id);

        update assetIntakeFormToUpdate;

        this.familyId = familyRecordToCreate.Id;
    }

    private void fetchAssetJurisdictionRecord(){
        Set<String> status = new Set<String>{
            'Draft'
        };

        Set<String> fields = new Set<String>();

        for(String s : assetIntakeFields){
            fields.add('Asset_Intake_Form__r.' + s);
        }

       
        fields.addAll(assetIntakeJurisdictionFields);

        String query = ' SELECT '  + String.join(fields, ', ') + 
                        ' FROM Asset_Intake_Jurisdiction__c  ' +
                    ' WHERE Id = :assetIntakeJurisctionId LIMIT 1 ';

        this.assetIntakeJurisdiction = Database.query(query);
    }

    public void createRelatedRecordsFromJurisdiction(){
        fetchJurisdictionRelationRecords();

        if(jurisdictionRelations == null || jurisdictionRelations.size() == 0){
            throw new NoJurisdictionRelationsFoundException();
        }

        segregateJurisdictionRelations();

        clientStatus = (String) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').getSobject('Asset_Intake_Form__r').getSobject('Client__r').get('Client_Status__c');
        clientId = (Id) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').getSobject('Asset_Intake_Form__r').getSobject('Client__r').get('Id');
        String assetType =  (String) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').getSobject('Asset_Intake_Form__r').get('Asset_Type__c');

        if(assetType == 'New Patent Family' || assetType == 'Existing Patent Family' || assetType == 'Patent'){
            matterSobjectType = 'SymphonyLF__Patent__c';
            familySobjectType = 'SymphonyLF__Patent_Family__c';
            matterId = (Id) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').get('Patent__c');
            familyId = (Id) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').getSobject('Asset_Intake_Form__r').get('Patent_Family__c');
        }

        summarizeAndCreateApplicantRecordItselfIfNew();
        summarizeAndCreateInventorIfNew();
        summarizeAndCreatePersonnelIfNew();

        createApplicantAtMatterLevel();
        createInventorAtMatterLevel();
        createPersonnelAtMatterLevel();
        createDocketActivityRecord();
    }

    String clientStatus;
    String clientId;
    String matterId;
//    String familyId;
    String matterSobjectType;
    String familySobjectType;

    Map<String, String> SOBJECT_TO_CHAIN_OF_TITLE_LOOKUP = new Map<String, String>{
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c'
        , 'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Patent_Family__c'
    };

    Map<String, String> SOBJECT_TO_INVENTOR_DESIGNER_AUTHOR_TYPE = new Map<String, String>{
        'SymphonyLF__Patent__c' => 'Inventor'
        , 'SymphonyLF__Patent_Family__c' => 'Inventor'
    };

    Map<String, String> SOBJECT_TO_INVENTOR_DESIGNER_AUTHOR_MATTER_LOOKUP = new Map<String, String>{
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c'
        , 'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Patent_Family__c'
    };

    void createDocketActivityRecord(){
        String eventName = (String) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').get('Event_Name__c');

        if(String.isBlank(eventName)){
            return;
        }

        sObject docketActivity = (sObject) Type.forName('SymphonyLF__Docketing_Activity__c').newInstance();
        docketActivity.put(APPLICATION.DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(matterSobjectType), matterId );
        docketActivity.put('SymphonyLF__Event_Name__c', eventName);
        docketActivity.put('Docket_Type__c', (String) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').get('Docket_Type__c'));
        docketActivity.put('SymphonyLF__Assigned_To_User__c', (String) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').get('Assigned_To__c'));
        docketActivity.put('SymphonyLF__Event_Date__c', (Date) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').get('Event_Date__c'));
        docketActivity.put('SymphonyLF__Due_Date__c', (Date) jurisdictionRelations[0].getSobject('Asset_Intake_Jurisdiction__r').get('Due_Date__c'));

        insert docketActivity;
    }

    void createPersonnelAtMatterLevel(){
        if(assetIntakePersonnelById.size() == 0){
            return;
        }

        List<sObject> matterEngagementModelToInsert = new List<sObject>();
        
        for(Id recId : assetIntakePersonnelById.keySet()){
            sObject assetIntakePersonnel = assetIntakePersonnelById.get(recId);
            Id clientEngagementModelId = (Id) assetIntakePersonnel.get('Client_Engagement_Model__c');

            sObject clientEngagementModelRecord = inventorById.get(clientEngagementModelId);

            if(clientEngagementModelRecord == null){
                continue;
            }

            sObject toInsert = (sObject) Type.forName('SymphonyLF__Matter_Engagement_Model__c').newInstance();
            toInsert.put('Client_Engagement_Model__c', clientEngagementModelRecord.get( 'Id' ));
            toInsert.put(APPLICATION.SOBJECT_TO_MEM_MATTER_LOOKUP_FIELD.get(matterSobjectType), matterId);
            toInsert.put('SymphonyLF__Client__c', clientId);
            toInsert.put('Is_Active__c', clientEngagementModelRecord.get('Is_Active__c'));
            toInsert.put('SymphonyLF__Assign_to_User__c', clientEngagementModelRecord.get('SymphonyLF__Person__c'));
            toInsert.put('SymphonyLF__Type__c', clientEngagementModelRecord.get('SymphonyLF__Type__c'));

            //   toInsert.put(SOBJECT_TO_CHAIN_OF_TITLE_LOOKUP.get(familySobjectType), familyId);

            matterEngagementModelToInsert.add(toInsert);
        }

        if(matterEngagementModelToInsert.size() > 0){
            insert matterEngagementModelToInsert;
        }
    }

    void createInventorAtMatterLevel(){
        if(assetIntakeInventorById.size() == 0){
            return;
        }

        List<sObject> inventorDesignerAuthorToInsert = new List<sObject>();
        
        for(Id recId : assetIntakeInventorById.keySet()){
            sObject assetIntakeInventor = assetIntakeInventorById.get(recId);
            Id inventorId = (Id) assetIntakeInventor.get('Person__c');

            sObject inventorRecord = inventorById.get(inventorId);

            if(inventorRecord == null){
                continue;
            }

            sObject toInsert = (sObject) Type.forName('SymphonyLF__Inventor_Designer_Author__c').newInstance();
            toInsert.put('SymphonyLF__Contact__c', inventorRecord.get( 'Id' ));
            toInsert.put('SymphonyLF__Type__c', SOBJECT_TO_INVENTOR_DESIGNER_AUTHOR_TYPE.get(matterSobjectType));
            toInsert.put('SymphonyLF__Primary_Inventor__c', assetIntakeInventor.get('Primary_Inventor__c'));

            toInsert.put(SOBJECT_TO_INVENTOR_DESIGNER_AUTHOR_MATTER_LOOKUP.get(matterSobjectType) , matterId);

            //   toInsert.put(SOBJECT_TO_CHAIN_OF_TITLE_LOOKUP.get(familySobjectType), familyId);

            inventorDesignerAuthorToInsert.add(toInsert);
        }

        if(inventorDesignerAuthorToInsert.size() > 0){
            insert inventorDesignerAuthorToInsert;
        }
    }

    void createApplicantAtMatterLevel(){
        if(assetIntakeApplicantById.size() == 0){
            return;
        }

        List<sObject> chainOfTitleToInsert = new List<sObject>();
        
        for(Id recId : assetIntakeApplicantById.keySet()){
            sObject assetIntakeApplicant = assetIntakeApplicantById.get(recId);
            Id applicantId = (Id) assetIntakeApplicant.get('Applicant__c');

            sObject applicantRecord = applicantById.get(applicantId);

            if(applicantRecord == null){
                continue;
            }

            sObject toInsert = (sObject) Type.forName('SymphonyLF__Chain_of_Title__c').newInstance();
            toInsert.put('SymphonyLF__Client__c', applicantRecord.get( 'Id' ));
            toInsert.put('SymphonyLF__Role__c', applicantRecord.get('SymphonyLF__Client_Classification__c'));
            toInsert.put('SymphonyLF__Current__c', true);
            toInsert.put('SymphonyLF__Address__City__s', applicantRecord.get('SymphonyLF__Address__City__s'));
            toInsert.put('SymphonyLF__Address__CountryCode__s', applicantRecord.get('SymphonyLF__Address__CountryCode__s'));
            toInsert.put('SymphonyLF__Address__StateCode__s', applicantRecord.get('SymphonyLF__Address__StateCode__s'));
            toInsert.put('SymphonyLF__Address__Street__s', applicantRecord.get('SymphonyLF__Address__Street__s'));
            toInsert.put('SymphonyLF__Address__PostalCode__s', applicantRecord.get('SymphonyLF__Address__PostalCode__s'));

            toInsert.put(SOBJECT_TO_CHAIN_OF_TITLE_LOOKUP.get(matterSobjectType) , matterId);

            //   toInsert.put(SOBJECT_TO_CHAIN_OF_TITLE_LOOKUP.get(familySobjectType), familyId);

            chainOfTitleToInsert.add(toInsert);
        }

        if(chainOfTitleToInsert.size() > 0){
            insert chainOfTitleToInsert;
        }
    }

    void summarizeAndCreatePersonnelIfNew(){
        if(assetIntakePersonnelById.size() == 0){
            return;
        }

        Boolean hasNewPersonnel = false;

        for(Id recId : assetIntakePersonnelById.keySet()){
            sObject assetIntakePersonnel = assetIntakePersonnelById.get(recId);

            if( ( (Id) assetIntakePersonnel.get('Client_Engagement_Model__c') ) == null){
                // Automatically inserted when client status changes to Active.
                hasNewPersonnel = true;
            }
            else{
                personnelById.put((Id) assetIntakePersonnel.get('Client_Engagement_Model__c'), assetIntakePersonnel.getSobject('Client_Engagement_Model__r'));
            }
        }

        if(!hasNewPersonnel){
            return;
        }

        Map<String, sObject> justActivatedClientCemsByTypePersonKey = new Map<String, sObject>();
        if(clientStatus == 'Yet to Engage'){
            sObject clientToActive = (sObject) Type.forName('SymphonyLF__Client__c').newInstance();
            clientToActive.put('Id', clientId);
            clientToActive.put('Client_Status__c', 'Active');

            update clientToActive;
        }

        // ISSUE ON SECOND ITERATION WHEN CLIENT STATUS WILL NO MORE BE YET TO ENGAGE AND SOMEONE NEW COMES IN
        List<sObject> cemsOfActivatedClient = Database.query(' SELECT Id, SymphonyLF__Person__c, SymphonyLF__Type__c FROM SymphonyLF__Client_Engagement_Model__c WHERE SymphonyLF__Client__c = :clientId ');

        for(sObject rec : cemsOfActivatedClient){
            String key = (String) rec.get('SymphonyLF__Type') + '-' + (String) rec.get('SymphonyLF__Person__c');
            justActivatedClientCemsByTypePersonKey.put(key, rec);
        }

        List<sObject> AssetIntakePersonnelsToUpdate = new List<sObject>();

        for(Id recId : assetIntakePersonnelById.keySet()){
            String key = (String) assetIntakePersonnelById.get(recId).get('Type__c') + '-' + (String) assetIntakePersonnelById.get(recId).get('Personnel__c');

            if(!justActivatedClientCemsByTypePersonKey.containsKey(key)){
                continue;
            }

            if(assetIntakePersonnelById.get(recId).get('Client_Engagement_Model__c') == null ){
                continue;
            }

            sObject toUpdate = (sObject) Type.forName('Asset_Intake_Personnel__c').newInstance();
            toUpdate.put('Id', recId);
            toUpdate.put('Client_Engagement_Model__c', (justActivatedClientCemsByTypePersonKey.get(key)).get('Id'));

            AssetIntakePersonnelsToUpdate.add(toUpdate);

            assetIntakePersonnelById.get(recId).put('Client_Engagement_Model__c', (justActivatedClientCemsByTypePersonKey.get(key)).get('Id'));
            personnelById.put((Id) (justActivatedClientCemsByTypePersonKey.get(key)).get('Id'), justActivatedClientCemsByTypePersonKey.get(key) ); 
        }

        if(AssetIntakePersonnelsToUpdate.size() > 0){
            update AssetIntakePersonnelsToUpdate;
        }
    }

    void summarizeAndCreateInventorIfNew(){
        if(assetIntakeInventorById.size() == 0){
            return;
        }

        List<sObject> inventorsToCreate = new List<sObject>();

        Map<Id, sObject> assetIntakeInventorToInventorToCreate = new Map<Id, sObject>();

        Id inventorRecordType = Schema.getGlobalDescribe().get('SymphonyLF__Person__c').getDescribe().getRecordTypeInfosByName().get('Innovator').getRecordTypeId();
        for(Id recId : assetIntakeInventorById.keySet()){
            sObject assetIntakeInventor = assetIntakeInventorById.get(recId);

            if( ( (Id) assetIntakeInventor.get('Person__c') ) == null){
                sObject inventorToInsert = (sObject) Type.forName('SymphonyLF__Person__c').newInstance();
                inventorToInsert.put('Name', assetIntakeInventor.get('Inventor_Designer_Author_Name__c'));
                inventorToInsert.put('SymphonyLF__Type__c', 'Client');
                inventorToInsert.put('SymphonyLF__Contact_Type__c', 'Inventor');
                inventorToInsert.put('RecordTypeId', inventorRecordType);
                inventorToInsert.put('SymphonyLF__Email__c',  assetIntakeInventor.get('Email__c'));
                inventorToInsert.put('SymphonyLF__Phone_Number__c',  assetIntakeInventor.get('Phone__c'));
                inventorToInsert.put('SymphonyLF__Nationality__c',  assetIntakeInventor.get('Nationality__c'));
                inventorToInsert.put('SymphonyLF__Client__c',  assetIntakeInventor.get( clientId ));     

                inventorToInsert.put('SymphonyLF__Address__City__s', assetIntakeInventor.get('Address__City__s'));
                inventorToInsert.put('SymphonyLF__Address__CountryCode__s', assetIntakeInventor.get('Address__CountryCode__s'));
                inventorToInsert.put('SymphonyLF__Address__StateCode__s', assetIntakeInventor.get('Address__StateCode__s'));
                inventorToInsert.put('SymphonyLF__Address__Street__s', assetIntakeInventor.get('Address__Street__s'));
                inventorToInsert.put('SymphonyLF__Address__PostalCode__s', assetIntakeInventor.get('Address__PostalCode__s'));

                inventorsToCreate.add(inventorToInsert);
                assetIntakeInventorToInventorToCreate.put(recId, inventorToInsert);
            }
            else{
                inventorById.put((Id) assetIntakeInventor.get('Person__c'), assetIntakeInventor.getSobject('Person__r'));
            }
        }

        if(inventorsToCreate.size() == 0){
            return;
        }

        insert inventorsToCreate;

        List<sObject> assetIntakeInventorsToUpdate = new List<sObject>();

        for(Id recId : assetIntakeInventorById.keySet()){
            sObject toUpdate = (sObject) Type.forName('Asset_Intake_Inventor__c').newInstance();
            toUpdate.put('Id', recId);
            toUpdate.put('Person__c', assetIntakeInventorToInventorToCreate.get(recId).get('Id'));

            assetIntakeInventorsToUpdate.add(toUpdate);

            assetIntakeInventorById.get(recId).put('Person__c', assetIntakeInventorToInventorToCreate.get(recId).get('Id'));
            inventorById.put((Id) (assetIntakeInventorToInventorToCreate.get(recId)).get('Id'), assetIntakeInventorToInventorToCreate.get(recId));
        }

        if(assetIntakeInventorsToUpdate.size() > 0){
            update assetIntakeInventorsToUpdate;
        }
    }

    void summarizeAndCreateApplicantRecordItselfIfNew(){
        if(assetIntakeApplicantById.size() == 0){
            return;
        }

        List<sObject> applicantsToCreate = new List<sObject>();

        Map<Id, sObject> assetIntakeApplicantToClientToCreate = new Map<Id, sObject>();

        for(Id recId : assetIntakeApplicantById.keySet()){
            sObject assetIntakeApplicant = assetIntakeApplicantById.get(recId);

            if( ( (Id) assetIntakeApplicant.get('Applicant__c') ) == null){
                sObject applicantToInsert = (sObject) Type.forName('SymphonyLF__Client__c').newInstance();
                applicantToInsert.put('Name', assetIntakeApplicant.get('Applicant_Name__c'));
                applicantToInsert.put('SymphonyLF__Client_Classification__c', assetIntakeApplicant.get('Client_Classification__c'));
                applicantToInsert.put('SymphonyLF__Entity_Size__c', assetIntakeApplicant.get('US_CA_Entity_Size__c'));
                applicantToInsert.put('SymphonyLF__Default_Billing_Currency__c', assetIntakeApplicant.get('Currency__c'));

                applicantToInsert.put('SymphonyLF__Address__City__s', assetIntakeApplicant.get('Applicant_Address__City__s'));
                applicantToInsert.put('SymphonyLF__Address__CountryCode__s', assetIntakeApplicant.get('Applicant_Address__CountryCode__s'));
                applicantToInsert.put('SymphonyLF__Address__StateCode__s', assetIntakeApplicant.get('Applicant_Address__StateCode__s'));
                applicantToInsert.put('SymphonyLF__Address__Street__s', assetIntakeApplicant.get('Applicant_Address__Street__s'));
                applicantToInsert.put('SymphonyLF__Address__PostalCode__s', assetIntakeApplicant.get('Applicant_Address__PostalCode__s'));

                applicantsToCreate.add(applicantToInsert);
                assetIntakeApplicantToClientToCreate.put(recId, applicantToInsert);
            }
            else{
                applicantById.put((Id) assetIntakeApplicant.get('Applicant__c'), assetIntakeApplicant.getSobject('Applicant__r'));
            }
        }

        if(applicantsToCreate.size() == 0){
            return;
        }

        insert applicantsToCreate;

        List<sObject> applicantsToUpdate = new List<sObject>();

        for(Id recId : assetIntakeApplicantById.keySet()){
            sObject toUpdate = (sObject) Type.forName('Asset_Intake_Applicants__c').newInstance();
            toUpdate.put('Id', recId);
            toUpdate.put('SymphonyLF__Client__c', assetIntakeApplicantToClientToCreate.get(recId).get('Id'));

            applicantsToUpdate.add(toUpdate);

            assetIntakeApplicantById.get(recId).put('Applicant__c', assetIntakeApplicantToClientToCreate.get(recId).get('Id'));
            applicantById.put((Id) (assetIntakeApplicantToClientToCreate.get(recId)).get('Id'), assetIntakeApplicantToClientToCreate.get(recId));
        }

        if(applicantsToUpdate.size() > 0){
            update applicantsToUpdate;
        }
    }

    Map<Id, sObject> assetIntakeInventorById = new Map<Id, sObject>();
    Map<Id, sObject> assetIntakeApplicantById = new Map<Id, sObject>();
    Map<Id, sObject> assetIntakePersonnelById = new Map<Id, sObject>();

    Map<Id, sObject> inventorById = new Map<Id, sObject>();
    Map<id, sObject> applicantById = new Map<Id, sObject>();
    Map<Id, sObject> personnelById = new Map<Id, sObject>();
    

    void segregateJurisdictionRelations(){
        for(sObject s : jurisdictionRelations){
            String instance = (String) s.get('InstanceType__c');

            if(instance == 'Asset_Intake_Inventor__c' && ( (Id) s.get('Asset_Intake_Inventor__c') != null) ){
                assetIntakeInventorById.put((Id) s.get('Asset_Intake_Inventor__c') ,  s.getSobject('Asset_Intake_Inventor__r'));
            }
            else if(instance == 'Asset_Intake_Applicants__c' && ( (Id) s.get('Asset_Intake_Applicant__c') != null) ){
                assetIntakeApplicantById.put((Id) s.get('Asset_Intake_Applicant__c') ,  s.getSobject('Asset_Intake_Applicant__r'));
            }
            else if(instance == 'Asset_Intake_Personnel__c' && ( (Id) s.get('Asset_Intake_Personnel__c') != null) ){
                assetIntakePersonnelById.put((Id) s.get('Asset_Intake_Personnel__c') ,  s.getSobject('Asset_Intake_Personnel__r'));
            }
        }
    }

    List<sObject> jurisdictionRelations;
    void fetchJurisdictionRelationRecords(){
        Set<String> fields = new Set<String>();

        fields.addAll(assetIntakeJurisdictionRelationsFields);

        for(String s : assetIntakeJurisdictionFields){
            fields.add('Asset_Intake_Jurisdiction__r.' + s);
        }

        for(String s : assetIntakeFields){
            fields.add('Asset_Intake_Jurisdiction__r.' + 'Asset_Intake_Form__r.' + s);
        }

        for(String s : assetIntakePersonnelFields){
            fields.add('Asset_Intake_Personnel__r.' + s);
        }

        for(String s : assetIntakeInventorFields){
            fields.add('Asset_Intake_Inventor__r.' + s);
        }

        for(String s : assetIntakeApplicantFields){
            fields.add('Asset_Intake_Applicant__r.' + s);
        }

        String query = ' SELECT ' + String.join(fields, ', ') +
                        ' FROM Asset_Intake_Jurisdiction_Relations__c ' +
                        ' WHERE Asset_Intake_Jurisdiction__c = :assetIntakeJurisctionId';
        
        jurisdictionRelations = Database.query( query );
    }

    public class NoJurisdictionRelationsFoundException extends Exception{}

    Set<String> assetIntakeFields = new Set<String>{
        'Id'
        , 'Asset_Type__c'
        , 'Client__c'
        , 'Conflict_Check__c'
        , 'Dispute_Sub_Type__c'
        , 'Dispute_Type__c'
        , 'Mark__c'
        , 'Image_ContentVersion__c'
        , 'Mark_Type__c'
        , 'New_Mark_Title__c'
        , 'New_Patent_Family__c'
        , 'Patent_Family__c'
        , 'Status__c'
        , 'Title__c'
        , 'Department__c'

        , 'Client__c'
        , 'Client__r.Client_Status__c'
        , 'Client__r.Working_Assigned_Attorney__c'
        , 'Client__r.Responsible_Billing_Attorney__c'
        , 'Client__r.Originating_Attorney__c'
        , 'Client__r.Managing_Supervising_Attorney__c'
    };

    Set<String> assetIntakePersonnelFields = new Set<String>{
        'Id'
        , 'Asset_Intake_Form__c'
        , 'Client_Engagement_Model__c'
        , 'Personnel__c'
        , 'Type__c'

        , 'Client_Engagement_Model__r.SymphonyLF__Person__c'
        , 'Client_Engagement_Model__r.SymphonyLF__Type__c'
        , 'Client_Engagement_Model__r.Is_Active__c'
    };

    Set<String> assetIntakeApplicantFields = new Set<String>{
        'Id'
        , 'Asset_Intake_Form__c'

        , 'Applicant__c'

        , 'Applicant_Name__c'
        , 'Applicant_Address__c'
        , 'Client_Classification__c'
        , 'Currency__c'
        , 'US_CA_Entity_Size__c'

        , 'Applicant__r.Name'
        , 'Applicant__r.SymphonyLF__Client_Classification__c'
        , 'Applicant__r.SymphonyLF__Entity_Size__c'
        , 'Applicant__r.SymphonyLF__Default_Billing_Currency__c'
        , 'Applicant__r.SymphonyLF__Address__City__s'
        , 'Applicant__r.SymphonyLF__Address__CountryCode__s'
        , 'Applicant__r.SymphonyLF__Address__StateCode__s'
        , 'Applicant__r.SymphonyLF__Address__Street__s'
        , 'Applicant__r.SymphonyLF__Address__PostalCode__s'
    };

    Set<String> assetIntakeInventorFields = new Set<String>{
        'Id'
        , 'Asset_Intake_Form__c'

        , 'Person__c'

        , 'Inventor_Designer_Author_Name__c'
        , 'Email__c'
        , 'Address__c'
        , 'Nationality__c'
        , 'Phone__c'
        , 'Primary_Inventor__c'

        , 'Person__r.Name'
        , 'Person__r.SymphonyLF__Type__c'
        , 'Person__r.SymphonyLF__Contact_Type__c'
        , 'Person__r.RecordTypeId'
        , 'Person__r.SymphonyLF__Email__c'
        , 'Person__r.SymphonyLF__Phone_Number__c'
        , 'Person__r.SymphonyLF__Nationality__c'
        , 'Person__r.SymphonyLF__Client__c'
        , 'Person__r.SymphonyLF__Address__City__s'
        , 'Person__r.SymphonyLF__Address__CountryCode__s'
        , 'Person__r.SymphonyLF__Address__StateCode__s'
        , 'Person__r.SymphonyLF__Address__Street__s'
        , 'Person__r.SymphonyLF__Address__PostalCode__s'
    };

    Set<String> assetIntakeJurisdictionFields = new Set<String>{
        'Id'
        , 'Asset_Intake_Form__c'
        , 'Jurisdiction__c'
        , 'CaseType__c'
        , 'ClientReferenceNumber__c'

        , 'Docket_Type__c'
        , 'Event_Name__c'
        , 'Event_Date__c'
        , 'Due_Date__c'
        , 'Assigned_To__c'

        , 'Patent__c'
        , 'Trademark__c'
    };

    Set<String> assetIntakeJurisdictionRelationsFields = new Set<String>{
        'Id'
        , 'InstanceType__c'
        , 'Asset_Intake_Jurisdiction__c'
        , 'Asset_Intake_Personnel__c'
        , 'Asset_Intake_Applicant__c'
        , 'Asset_Intake_Inventor__c'
        , 'Asset_Intake_Class__c'
    };

    public class NoAssetIntakeIdsProvidedException extends Exception{

    }
}