public with sharing class assetIntakeUtilities {
    
    static Set<String> fieldsClientEngagementModel = new Set<String>{
        'Id',
        'Name',
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
        'Is_Default__c',
        'CreatedDate'
    };

    static Set<String> emptySet = new Set<String>{
        NULL,
        '',
        'null',
        'NULL'
    };

    @AuraEnabled(cacheable=true)
    public static CountryCodes__mdt getCountryCodeByName(String countryName) {
        CountryCodes__mdt countryCodes = [
            SELECT MasterLabel, DeveloperName, Country_Name__c, Country_Code__c
            FROM CountryCodes__mdt
            WHERE Country_Name__c = :countryName
            LIMIT 1
        ];

        return countryCodes;
    }

    @AuraEnabled
    public static Id createNewIntakeRecord(String request){
      //  mvWrapper.IntakeWrapper req = (mvWrapper.IntakeWrapper) JSON.deserializeStrict(request, mvWrapper.IntakeWrapper.class);
        mvWrapper.IntakeWrapper req = (mvWrapper.IntakeWrapper) JSON.deserialize(request, mvWrapper.IntakeWrapper.class);
        system.debug(req.assetType);
        system.debug(req.disputeSubType);
        system.debug(req.disputeType);

        Boolean isNewFamily = String.isNotBlank(req.newFamilyName) ? true : false;
        system.debug(isNewFamily);
        Id existingFamilyId;
        String existingFamilyMemLookup = '';
        String existingChainOfTitleLookup = '';
        String inventorDesignerAuthorLookup = '';
        String classesSpecificationLookup = '';

        Asset_Intake_Form__c a = new Asset_Intake_Form__c();
        a.Client__c = req.clientId;

        if(String.isNotBlank(req.conflictCheckId)){
            a.Conflict_Check__c = req.conflictCheckId;
        }

        if(String.isNotBlank(req.contentId)){
            a.Image_ContentVersion__c = req.contentId;
        }

        System.debug('department>>>>' + req.department + 'contentId>>>' + req.contentId);
        
        if(String.isNotBlank(req.newFamilyName)){
            if( req.assetType == 'New Patent Family' || req.assetType == 'Patent'   ){
                a.New_Patent_Family__c = req.newFamilyName;
                a.Department__c = req.department;
            }
            else if(req.assetType == 'New Mark' || req.assetType == 'Trademark'){
                a.New_Mark_Title__c = req.newFamilyName;
                a.Mark_Type__c = req.department;
                if(!String.isBlank(req.department)){
                    a.Mark_Type__c = req.department;
                }
                if(!String.isBlank(req.contentId)){
                    a.Image_ContentVersion__c = req.contentId;
                }
            }
        }
        else if( String.isNotBlank(req.existingFamilyId) ){
            if( req.assetType == 'Existing Patent Family' || req.assetType == 'Patent'   ){
                a.Patent_Family__c = req.existingFamilyId;
                a.Department__c = req.department;
                existingFamilyId = req.existingFamilyId;
                existingFamilyMemLookup = 'SymphonyLF__Patent_Family__c';
                existingChainOfTitleLookup = 'SymphonyLF__Patent_Family__c';
                inventorDesignerAuthorLookup = 'SymphonyLF__Patent_Family__c';
            }
            else if(req.assetType == 'Existing Mark' || req.assetType == 'Trademark'){
                a.Mark__c = req.existingFamilyId;
                //a.Mark_Type__c = req.department;
                existingFamilyId = req.existingFamilyId;
                existingFamilyMemLookup = 'SymphonyLF__Mark__c';
                existingChainOfTitleLookup = 'SymphonyLF__Mark__c';
                classesSpecificationLookup = 'SymphonyLF__Mark__c';
            }
            
        }
        if(req.assetType == 'Opposition'){
            system.debug(req.assetType);
            a.Dispute_Type__c = req.disputeType;
            a.Dispute_Sub_Type__c = req.disputeSubType;
            a.Title__c = req.newFamilyName;
            existingFamilyMemLookup ='SymphonyLF__Dispute_Opposition__c';
            
        }
        
        a.Asset_Type__c = req.assetType;
        a.Current_Page__c = 'Personnel';

        insert a;

        List<Asset_Intake_Form__c> intakeForm = [
            SELECT 
                Id,
                Asset_Type__c
                , Client__r.Client_Status__c
                , Client__r.Managing_Supervising_Attorney__c
                , Client__r.Originating_Attorney__c
                , Client__r.Responsible_Billing_Attorney__c
                , Client__r.Working_Assigned_Attorney__c
                , Conflict_Check__r.Client_Reference_Number__c
            FROM Asset_Intake_Form__c
            WHERE Id = :a.Id
        ];

        List<Asset_Intake_Personnel__c> intakePersonnelsToCreate = new List<Asset_Intake_Personnel__c>();
        
        if(intakeForm[0].Client__r.Client_Status__c == 'Yet to Engage'){
            Map<String, String> ATTORNEY_TYPE_MAP = new Map<String, String>{
                'Managing_Supervising_Attorney__c' => 'Managing (Supervising) Attorney',
                'Originating_Attorney__c' => 'Originating Attorney',
                'Responsible_Billing_Attorney__c' => 'Responsible (Billing) Attorney',
                'Working_Assigned_Attorney__c' => 'Working Attorney'
            };
            
            sObject intakeFormSobject = (sObject) intakeForm[0];
            for (String fieldApi : ATTORNEY_TYPE_MAP.keySet()) {
                Id personId = (Id) intakeFormSobject.getSobject('Client__r').get(fieldApi);
                if (personId != null) {
                    Asset_Intake_Personnel__c personnel = new Asset_Intake_Personnel__c(
                        Personnel__c = personId,  // The attorney person ID
                        Type__c = ATTORNEY_TYPE_MAP.get(fieldApi),  // The role of the attorney
                        Asset_Intake_Form__c = intakeForm[0].Id  // Associate with the current Asset Intake Form
                    );
                    intakePersonnelsToCreate.add(personnel);
                }
            }
        }
        else{

        
        List<SymphonyLF__Client_Engagement_Model__c> cemRecords = new List<SymphonyLF__Client_Engagement_Model__c>();
      //  if( isNewFamily ){
            Id clientId = req.clientId;

            Set<String> fields = new Set<String>{
                'Id',
                'SymphonyLF__Person__c',
                'SymphonyLF__Type__c'
            };

            String query = ' SELECT ' + String.join(fields, ', ') +
                '   FROM SymphonyLF__Client_Engagement_Model__c ' +
                '   WHERE SymphonyLF__Client__c = :clientId ' ;

            //   query += ' AND Is_Active__c = true ';

            if( isNewFamily ){
                query += ' AND Is_Default__c = true ';
            }
            else{
                query += ' AND Id IN ( SELECT Client_Engagement_Model__c FROM SymphonyLF__Matter_Engagement_Model__c WHERE ' + existingFamilyMemLookup + ' = :existingFamilyId ) ';
            }
            system.debug(query);  
            

            Set<String> cemIpMattes = getRelevantCemIpMatters( intakeForm[0] );

            if(cemIpMattes.size() > 0){
                String cemIpMattesString = '(\'' + String.join(cemIpMattes, '\',\'') + '\')';
                query += ' AND SymphonyLF__IP_Matters__c INCLUDES ' + cemIpMattesString ;
            }

            for(SymphonyLF__Client_Engagement_Model__c cem : Database.query( query ) ){
                cemRecords.add( cem );
            }
      //  }

        

        if( cemRecords.size() > 0){
            for(SymphonyLF__Client_Engagement_Model__c cem : cemRecords ){
                Asset_Intake_Personnel__c aip = new Asset_Intake_Personnel__c();
                aip.Asset_Intake_Form__c = a.Id;
                aip.Client_Engagement_Model__c = cem.Id;
                aip.Personnel__c = cem.SymphonyLF__Person__c;
                //aip.Type__c = cem.SymphonyLF__Type__c;

                intakePersonnelsToCreate.add( aip );
            }
        }

    }

        if(intakePersonnelsToCreate.size() > 0){
            insert intakePersonnelsToCreate;
        }

        String associatedClientsQuery = ' SELECT ' +
                    ' Id ' +
                ' FROM ' + 
                    ' SymphonyLF__Client__c ' + 
                ' WHERE SymphonyLF__Client__c = :clientId ';

        if( isNewFamily ){
            associatedClientsQuery += ' AND Is_Default__c = true ';
        }
        else{
            associatedClientsQuery += ' AND Id IN ( SELECT SymphonyLF__Client__c FROM SymphonyLF__Chain_of_Title__c WHERE ' + existingChainOfTitleLookup + ' = :existingFamilyId ) ';
        }

        List<SymphonyLF__Client__c> associatedClientsDefault = Database.query( associatedClientsQuery );
        System.debug('associatedClientsDefault==========>'+associatedClientsDefault);

        List<Asset_Intake_Applicants__c> intakeApplicantsToCreate = new List<Asset_Intake_Applicants__c>();

        if(associatedClientsDefault.size() > 0){
            for(SymphonyLF__Client__c c : associatedClientsDefault){
                Asset_Intake_Applicants__c aia = new Asset_Intake_Applicants__c();
                aia.Asset_Intake_Form__c = a.Id;
                aia.Applicant__c = c.Id;

                intakeApplicantsToCreate.add(aia);
            }
        }

        if(intakeApplicantsToCreate.size() > 0){
            insert intakeApplicantsToCreate;
        }

        Set<String> contactTypes = new Set<String>{
            'Inventor'
        };

        
            
        List<SymphonyLF__Person__c> defaultPersons = new List<SymphonyLF__Person__c>();

        if( String.isNotBlank(inventorDesignerAuthorLookup)){

            String defaultPersonsQuery = ' SELECT Id ' + 
                ' FROM SymphonyLF__Person__c ' +
                ' WHERE SymphonyLF__Contact_Type__c IN :contactTypes ' +
                '   AND SymphonyLF__Client__c = :clientId ';

            if( ! isNewFamily ){
                defaultPersonsQuery += ' AND Id IN ( SELECT SymphonyLF__Contact__c FROM SymphonyLF__Inventor_Designer_Author__c WHERE ' + inventorDesignerAuthorLookup + ' = :existingFamilyId ) ';
                defaultPersons = Database.query( defaultPersonsQuery );
            }

        }

        List<Asset_Intake_Inventor__c> intakeInventorsToCreate = new List<Asset_Intake_Inventor__c>();

        if(defaultPersons.size() > 0){
            for(SymphonyLF__Person__c c : defaultPersons){
                Asset_Intake_Inventor__c aii = new Asset_Intake_Inventor__c();
                aii.Asset_Intake_Form__c = a.Id;
                aii.Person__c = c.Id;

                intakeInventorsToCreate.add(aii);
            }
        }

        if(intakeInventorsToCreate.size() > 0){
            insert intakeInventorsToCreate;
        }

        //insert asset intake class for enabled classes & goods
        // List<SymphonyLF__Client_Classes_and_Goods_Specification__c> defaultClasses = new List<SymphonyLF__Client_Classes_and_Goods_Specification__c>();
        //  if( String.isNotBlank(classesSpecificationLookup)){

        //     String defaultClassesQuery = ' SELECT Id ' + 
        //         ' FROM SymphonyLF__Client_Classes_and_Goods_Specification__c ' +
        //         ' WHERE Enabled__c = true ' +
        //         '   AND SymphonyLF__Client__c = :clientId ';

        //     if( ! isNewFamily ){
        //         defaultClassesQuery += ' AND Id IN ( SELECT SymphonyLF__Contact__c FROM SymphonyLF__Inventor_Designer_Author__c WHERE ' + inventorDesignerAuthorLookup + ' = :existingFamilyId ) ';
        //         defaultPersons = Database.query( defaultPersonsQuery );
        //     }

        // }

        List<SymphonyLF__Country__c> defaultCountries = [
            SELECT Id
            FROM SymphonyLF__Country__c
            WHERE SymphonyLF__Country_Code__c = 'US'
        ];

        List<Asset_Intake_Jurisdiction__c> assetIntakeJurisdictionsToCreate = new List<Asset_Intake_Jurisdiction__c>();

        if(defaultCountries.size() > 0){
            for(SymphonyLF__Country__c c : defaultCountries){
                Asset_Intake_Jurisdiction__c aij = new Asset_Intake_Jurisdiction__c();
                aij.Asset_Intake_Form__c = a.Id;
                aij.Jurisdiction__c = c.Id;
                aij.CaseType__c = '';
                aij.ClientReferenceNumber__c = intakeForm[0].Conflict_Check__r.Client_Reference_Number__c ;
                aij.Docket_Type__c = 'Soft Docket';
                aij.Event_Date__c = Date.today();
                aij.Assigned_To__c = UserInfo.getUserId();

                assetIntakeJurisdictionsToCreate.add( aij );
            }
        }

        if(assetIntakeJurisdictionsToCreate.size() > 0){
            insert assetIntakeJurisdictionsToCreate;
        }

        List<Asset_Intake_Jurisdiction_Relations__c> jurisdictionRelationToCreate = new List<Asset_Intake_Jurisdiction_Relations__c>();

        for(Asset_Intake_Jurisdiction__c aij : assetIntakeJurisdictionsToCreate){
            for(Asset_Intake_Personnel__c aa : intakePersonnelsToCreate){
                Asset_Intake_Jurisdiction_Relations__c aijr = new Asset_Intake_Jurisdiction_Relations__c();
                aijr.Asset_Intake_Jurisdiction__c = aij.Id;
                aijr.InstanceType__c = 'Asset_Intake_Personnel__c';
                aijr.Asset_Intake_Personnel__c = aa.Id;

                jurisdictionRelationToCreate.add( aijr );
            }

            for(Asset_Intake_Applicants__c aa : intakeApplicantsToCreate){
                Asset_Intake_Jurisdiction_Relations__c aijr = new Asset_Intake_Jurisdiction_Relations__c();
                aijr.Asset_Intake_Jurisdiction__c = aij.Id;
                aijr.InstanceType__c = 'Asset_Intake_Applicants__c';
                aijr.Asset_Intake_Applicant__c = aa.Id;

                jurisdictionRelationToCreate.add( aijr );
            }

            for(Asset_Intake_Inventor__c aa : intakeInventorsToCreate){
                Asset_Intake_Jurisdiction_Relations__c aijr = new Asset_Intake_Jurisdiction_Relations__c();
                aijr.Asset_Intake_Jurisdiction__c = aij.Id;
                aijr.InstanceType__c = 'Asset_Intake_Inventor__c';
                aijr.Asset_Intake_Inventor__c = aa.Id;

                jurisdictionRelationToCreate.add( aijr );
            }
            
        }

        if( jurisdictionRelationToCreate.size() > 0 ){
            insert jurisdictionRelationToCreate;
        }

        return a.Id;
    }

    @AuraEnabled
    public static void cascadeDeltasToJurisdictions(Id assetIntakeId, List<Id> deltaIdsCreated, String section){
        List<Asset_Intake_Jurisdiction_Relations__c> relationsEmpty = [
            SELECT Id
            FROM Asset_Intake_Jurisdiction_Relations__c
            WHERE 
                Asset_Intake_Personnel__c = null
                AND
                Asset_Intake_Applicant__c = null
                AND
                Asset_Intake_Inventor__c = null
                AND
                Asset_Intake_Class__c = null
                AND
                Asset_Intake_Jurisdiction__r.Asset_Intake_Form__c = :assetIntakeId
        ];

        if(relationsEmpty.size() > 0){
            delete relationsEmpty;
        }

        List<Asset_Intake_Jurisdiction_Relations__c> relationsToCreate = new List<Asset_Intake_Jurisdiction_Relations__c>();

        if(deltaIdsCreated.size() > 0){
            List<Asset_Intake_Jurisdiction__c> jurisdictions = [
                SELECT Id
                FROM Asset_Intake_Jurisdiction__c
                WHERE Asset_Intake_Form__c = :assetIntakeId
            ];

            for(Asset_Intake_Jurisdiction__c aij : jurisdictions){
                for(Id i : deltaIdsCreated){
                    Asset_Intake_Jurisdiction_Relations__c aijr = new Asset_Intake_Jurisdiction_Relations__c();
                    aijr.InstanceType__c = section;
                    aijr.Asset_Intake_Jurisdiction__c = aij.Id;
                    if(section == 'Asset_Intake_Personnel__c'){
                        aijr.Asset_Intake_Personnel__c = i;
                    }
                    else if(section == 'Asset_Intake_Applicants__c'){
                        aijr.Asset_Intake_Applicant__c = i;
                    }
                    else if(section == 'Asset_Intake_Inventor__c'){
                        aijr.Asset_Intake_Inventor__c = i;
                    }
                    if(section == 'Asset_Intake_Class__c'){
                        aijr.Asset_Intake_Class__c = i;
                    }

                    relationsToCreate.add(aijr);
                }
            }

            if(relationsToCreate.size() > 0){
                insert relationsToCreate;
            }
            
        }
    }

    @AuraEnabled(cacheable=false)
    public static mvWrapper.clientAddressWrapper getClientAddress(String assetIntakeFormId, String clientId) {
    Asset_Intake_Form__c intakeForm = [
        SELECT Id,
               Name,
               Client__r.SymphonyLF__Address__Street__s,
               Client__r.SymphonyLF__Address__City__s,
               Client__r.SymphonyLF__Address__StateCode__s,
               Client__r.SymphonyLF__Address__PostalCode__s,
               Client__r.SymphonyLF__Address__CountryCode__s
        FROM Asset_Intake_Form__c
        WHERE Id = :assetIntakeFormId
        LIMIT 1
    ];

    mvWrapper.clientAddressWrapper wrapper = new mvWrapper.clientAddressWrapper();
    wrapper.street = intakeForm.Client__r.SymphonyLF__Address__Street__s;
    wrapper.city = intakeForm.Client__r.SymphonyLF__Address__City__s;
    wrapper.stateCode = intakeForm.Client__r.SymphonyLF__Address__StateCode__s;
    wrapper.postal = intakeForm.Client__r.SymphonyLF__Address__PostalCode__s;
    wrapper.countryCode = intakeForm.Client__r.SymphonyLF__Address__CountryCode__s;

    return wrapper;
    }



    @AuraEnabled
    public static List<mvWrapper.ApplicantsWrapper> getApplicants(String assetIntakeFormId, String clientId, Boolean createDefaultApplicants, Boolean fetchOnlySelected){
        // Applicants / Chain of Title / Associated Clients FROM Client
        Map<Id, SymphonyLF__Client__c> associatedClientsForClient = new Map<Id, SymphonyLF__Client__c>();
        if(fetchOnlySelected != true){
            associatedClientsForClient = new Map<Id, SymphonyLF__Client__c>([
                SELECT 
                    Id
                    , Name
                    , SymphonyLF__Address__Street__s
                    , SymphonyLF__Address__City__s
                    , SymphonyLF__Address__StateCode__s
                    , SymphonyLF__Address__PostalCode__s
                    , SymphonyLF__Address__CountryCode__s
                    , SymphonyLF__Client_Classification__c
                    , SymphonyLF__Default_Billing_Currency__c
                    , SymphonyLF__Default_Billing_Currency__r.Name
                    , SymphonyLF__Entity_Size__c
                    , Is_Default__c
                FROM 
                    SymphonyLF__Client__c 
                WHERE SymphonyLF__Client__c = :clientId
                    AND Id NOT IN (SELECT Applicant__c FROM Asset_Intake_Applicants__c WHERE Asset_Intake_Form__c = :assetIntakeFormId)
                ORDER BY Is_Default__c DESC, Name ASC
            ]);
        }

        if(createDefaultApplicants == true){
            List<Asset_Intake_Applicants__c> toInsert = new List<Asset_Intake_Applicants__c>();
            for(SymphonyLF__Client__c client : associatedClientsForClient.values()){
                if(client.Is_Default__c){
                    Asset_Intake_Applicants__c aia = new Asset_Intake_Applicants__c();
                    aia.Asset_Intake_Form__c = assetIntakeFormId;
                    aia.Applicant__c = client.Id;

                    toInsert.add(aia);
                }
            }

            if(toInsert.size() > 0){
                insert toInsert;
            } 
        }

        List<mvWrapper.ApplicantsWrapper> output = new List<mvWrapper.ApplicantsWrapper>();

        List<Asset_Intake_Applicants__c> applicants = [
            SELECT
                Id
                , Name
                , Applicant__c
                , Applicant__r.Name
                , Applicant__r.SymphonyLF__Address__Street__s
                , Applicant__r.SymphonyLF__Address__City__s
                , Applicant__r.SymphonyLF__Address__StateCode__s
                , Applicant__r.SymphonyLF__Address__PostalCode__s
                , Applicant__r.SymphonyLF__Address__CountryCode__s
                , Applicant__r.SymphonyLF__Client_Classification__c
                , Applicant__r.SymphonyLF__Default_Billing_Currency__c
                , Applicant__r.SymphonyLF__Default_Billing_Currency__r.Name
                , Applicant__r.SymphonyLF__Entity_Size__c
                , Applicant_Name__c
                , Applicant_Address__c
                , Applicant_Address__Street__s
                , Applicant_Address__City__s
                , Applicant_Address__StateCode__s
                , Applicant_Address__PostalCode__s
                , Applicant_Address__CountryCode__s
                , Client_Classification__c
                , Currency__c
                , Currency__r.Name
                , US_CA_Entity_Size__c
            FROM 
                Asset_Intake_Applicants__c
            WHERE
                Asset_Intake_Form__c =: assetIntakeFormId
        ];
        
        Set<Id> clientIdsProcessed = new Set<Id>();

        for(Asset_Intake_Applicants__c applicant : applicants) {
            mvWrapper.ApplicantsWrapper aw = new mvWrapper.ApplicantsWrapper();
            aw.recordId = applicant.Id;
            aw.recordName = applicant.Name;
            aw.applicantId = applicant.Applicant__c;

            if(aw.applicantId != null){
                aw.isExistingApplicant = 'Existing';
                associatedClientsForClient.remove(aw.applicantId);
            }
            else{
                aw.isExistingApplicant = 'New';
            }

            aw.name = (aw.isExistingApplicant == 'Existing') ? applicant.Applicant__r.Name : applicant.Applicant_Name__c;
            List<String> addressLines = new List<String>();

            if((aw.isExistingApplicant == 'Existing')){
                if(!String.isBlank(applicant.Applicant__r.SymphonyLF__Address__Street__s)) {
                    addressLines.add(applicant.Applicant__r.SymphonyLF__Address__Street__s);
                    aw.street = applicant.Applicant__r.SymphonyLF__Address__Street__s;
                }
                if(!String.isBlank(applicant.Applicant__r.SymphonyLF__Address__City__s)) {
                    addressLines.add(applicant.Applicant__r.SymphonyLF__Address__City__s);
                    aw.city = applicant.Applicant__r.SymphonyLF__Address__City__s;
                }
                if(!String.isBlank(applicant.Applicant__r.SymphonyLF__Address__StateCode__s)) {
                    addressLines.add(applicant.Applicant__r.SymphonyLF__Address__StateCode__s);
                    aw.stateCode = applicant.Applicant__r.SymphonyLF__Address__StateCode__s;
                }
                if(!String.isBlank(applicant.Applicant__r.SymphonyLF__Address__PostalCode__s)) {
                    addressLines.add(applicant.Applicant__r.SymphonyLF__Address__PostalCode__s);
                    aw.postal = applicant.Applicant__r.SymphonyLF__Address__PostalCode__s;
                }
                if(!String.isBlank(applicant.Applicant__r.SymphonyLF__Address__CountryCode__s)) {
                    addressLines.add(applicant.Applicant__r.SymphonyLF__Address__CountryCode__s);
                    aw.countryCode = applicant.Applicant__r.SymphonyLF__Address__CountryCode__s;
                }

            }
            else{
                if(!String.isBlank(applicant.Applicant_Address__Street__s)) {
                    addressLines.add(applicant.Applicant_Address__Street__s);
                    aw.street = applicant.Applicant_Address__Street__s;
                }
                if(!String.isBlank(applicant.Applicant_Address__City__s)) {
                    addressLines.add(applicant.Applicant_Address__City__s);
                    aw.city = applicant.Applicant_Address__City__s;
                }
                if(!String.isBlank(applicant.Applicant_Address__StateCode__s)) {
                    addressLines.add(applicant.Applicant_Address__StateCode__s);
                    aw.stateCode = applicant.Applicant_Address__StateCode__s;
                }
                if(!String.isBlank(applicant.Applicant_Address__PostalCode__s)) {
                    addressLines.add(applicant.Applicant_Address__PostalCode__s);
                    aw.postal = applicant.Applicant_Address__PostalCode__s;
                }
                if(!String.isBlank(applicant.Applicant_Address__CountryCode__s)) {
                    addressLines.add(applicant.Applicant_Address__CountryCode__s);
                    aw.countryCode = applicant.Applicant_Address__CountryCode__s;
                }

            }
            aw.address = String.join(addressLines, ', ');
            aw.clientClassification = (aw.isExistingApplicant == 'Existing') ? applicant.Applicant__r.SymphonyLF__Client_Classification__c : applicant.Client_Classification__c;
            aw.currencyId = (aw.isExistingApplicant == 'Existing') ? applicant.Applicant__r.SymphonyLF__Default_Billing_Currency__c : applicant.Currency__c;
            aw.currencyCode = (aw.isExistingApplicant == 'Existing') ? applicant.Applicant__r.SymphonyLF__Default_Billing_Currency__r.Name : applicant.Currency__r.Name;
            aw.entitySize = (aw.isExistingApplicant == 'Existing') ? applicant.Applicant__r.SymphonyLF__Entity_Size__c : applicant.US_CA_Entity_Size__c;
            aw.isSelected = true;
            output.add(aw);
        }

        if(associatedClientsForClient.size() > 0){
            for(SymphonyLF__Client__c client : associatedClientsForClient.values()) {
                mvWrapper.ApplicantsWrapper aw = new mvWrapper.ApplicantsWrapper();
                aw.recordId = null;
                aw.recordName = '';
                aw.applicantId = client.Id;
    
                aw.isExistingApplicant = 'Existing';
    
                aw.name = client.Name;
                List<String> addressLines = new List<String>();
    
                if(!String.isBlank(client.SymphonyLF__Address__Street__s)) {
                    addressLines.add(client.SymphonyLF__Address__Street__s);
                }
                if(!String.isBlank(client.SymphonyLF__Address__City__s)) {
                    addressLines.add(client.SymphonyLF__Address__City__s);
                }
                if(!String.isBlank(client.SymphonyLF__Address__PostalCode__s)) {
                    addressLines.add(client.SymphonyLF__Address__PostalCode__s);
                }
                if(!String.isBlank(client.SymphonyLF__Address__CountryCode__s)) {
                    addressLines.add(client.SymphonyLF__Address__CountryCode__s);
                }
    
                aw.address = String.join(addressLines, ', ');
                aw.clientClassification = client.SymphonyLF__Client_Classification__c;
                aw.currencyId = client.SymphonyLF__Default_Billing_Currency__c;
                aw.currencyCode = client.SymphonyLF__Default_Billing_Currency__r.Name;
                aw.entitySize = client.SymphonyLF__Entity_Size__c;
                aw.isSelected = false;
                
                output.add(aw);
            }
        }

        return output;
    }

    @AuraEnabled
    public static List<mvWrapper.InventorsWrapper> getInventors(String assetIntakeFormId, String clientId, Boolean fetchOnlySelected){
        List<mvWrapper.InventorsWrapper> output = new List<mvWrapper.InventorsWrapper>();

        Map<Id, SymphonyLF__Person__c> allClientInventors = new Map<Id, SymphonyLF__Person__c>();
        if(fetchOnlySelected != true){
            allClientInventors = new Map<Id, SymphonyLF__Person__c>([
                SELECT 
                    Id
                    , Name
                    , SymphonyLF__Address__Street__s
                    , SymphonyLF__Address__City__s
                    , SymphonyLF__Address__StateCode__s
                    , SymphonyLF__Address__PostalCode__s
                    , SymphonyLF__Address__CountryCode__s
                    , SymphonyLF__Email__c
                    , SymphonyLF__Nationality__c
                    , SymphonyLF__Phone_Number__c
                FROM 
                    SymphonyLF__Person__c 
                WHERE 
                    SymphonyLF__Contact_Type__c = 'Inventor' 
                    AND SymphonyLF__Client__c = :clientId
                ORDER BY Name ASC
            ]);
        }

        List<Asset_Intake_Inventor__c> inventors = [
            SELECT
                Id
                , Name
                , Person__c
                , Person__r.Name
                , Person__r.SymphonyLF__Address__Street__s
                , Person__r.SymphonyLF__Address__City__s
                , Person__r.SymphonyLF__Address__StateCode__s
                , Person__r.SymphonyLF__Address__PostalCode__s
                , Person__r.SymphonyLF__Address__CountryCode__s
                , Person__r.SymphonyLF__Email__c
                , Person__r.SymphonyLF__Nationality__c
                , Person__r.SymphonyLF__Phone_Number__c
                , Inventor_Designer_Author_Name__c
                , Address__c
                , Address__Street__s
                , Address__City__s
                , Address__StateCode__s
                , Address__PostalCode__s
                , Address__CountryCode__s
                , Email__c
                , Nationality__c
                , Phone__c
                , Primary_Inventor__c
                , Sequence__c
            FROM 
            Asset_Intake_Inventor__c
            WHERE
                Asset_Intake_Form__c =: assetIntakeFormId
        ];
        
        for(Asset_Intake_Inventor__c inventor : inventors) {
            mvWrapper.InventorsWrapper iw = new mvWrapper.InventorsWrapper();
            iw.recordId = inventor.Id;
            iw.recordName = inventor.Name;
            iw.inventorId = inventor.Person__c;

            if(iw.inventorId != null){
                iw.isExistingInventor = 'Existing';
                allClientInventors.remove( iw.inventorId );
            }
            else{
                iw.isExistingInventor = 'New';
            }

            iw.inventorName = (iw.isExistingInventor == 'Existing') ? inventor.Person__r.Name : inventor.Inventor_Designer_Author_Name__c;
            List<String> addressLines = new List<String>();

            if((iw.isExistingInventor == 'Existing')){
                if(!String.isBlank(inventor.Person__r.SymphonyLF__Address__Street__s)) {
                    addressLines.add(inventor.Person__r.SymphonyLF__Address__Street__s);
                    iw.street = inventor.Person__r.SymphonyLF__Address__Street__s;
                }
                if(!String.isBlank(inventor.Person__r.SymphonyLF__Address__City__s)) {
                    addressLines.add(inventor.Person__r.SymphonyLF__Address__City__s);
                    iw.city = inventor.Person__r.SymphonyLF__Address__City__s;
                }
                if(!String.isBlank(inventor.Person__r.SymphonyLF__Address__StateCode__s)) {
                    addressLines.add(inventor.Person__r.SymphonyLF__Address__StateCode__s);
                    iw.stateCode = inventor.Person__r.SymphonyLF__Address__StateCode__s;
                }
                if(!String.isBlank(inventor.Person__r.SymphonyLF__Address__PostalCode__s)) {
                    addressLines.add(inventor.Person__r.SymphonyLF__Address__PostalCode__s);
                    iw.postal = inventor.Person__r.SymphonyLF__Address__PostalCode__s;
                }
                if(!String.isBlank(inventor.Person__r.SymphonyLF__Address__CountryCode__s)) {
                    addressLines.add(inventor.Person__r.SymphonyLF__Address__CountryCode__s);
                    iw.countryCode = inventor.Person__r.SymphonyLF__Address__CountryCode__s;
                }
            }
            else{
                if(!String.isBlank(inventor.Address__Street__s)) {
                    addressLines.add(inventor.Address__Street__s);
                    iw.street = inventor.Address__Street__s;
                }
                if(!String.isBlank(inventor.Address__City__s)) {
                    addressLines.add(inventor.Address__City__s);
                    iw.city = inventor.Address__City__s;
                }
                if(!String.isBlank(inventor.Address__StateCode__s)) {
                    addressLines.add(inventor.Address__StateCode__s);
                    iw.stateCode = inventor.Address__StateCode__s;
                }
                if(!String.isBlank(inventor.Address__PostalCode__s)) {
                    addressLines.add(inventor.Address__PostalCode__s);
                    iw.postal = inventor.Address__PostalCode__s;
                }
                if(!String.isBlank(inventor.Address__CountryCode__s)) {
                    addressLines.add(inventor.Address__CountryCode__s);
                    iw.countryCode = inventor.Address__CountryCode__s;
                }
            }
            iw.address = String.join(addressLines, ', ');
            iw.emailAddress = (iw.isExistingInventor == 'Existing') ? inventor.Person__r.SymphonyLF__Email__c : inventor.Email__c;
            iw.phoneNumber = (iw.isExistingInventor == 'Existing') ? inventor.Person__r.SymphonyLF__Phone_Number__c : inventor.Phone__c;
            iw.nationality = (iw.isExistingInventor == 'Existing') ? inventor.Person__r.SymphonyLF__Nationality__c : inventor.Nationality__c;
            iw.isSelected = true;
            iw.primaryInventor = inventor.Primary_Inventor__c;
            iw.sequence = inventor.Sequence__c;
            output.add(iw);
        }

        if(allClientInventors.size() > 0){
            for(SymphonyLF__Person__c inventor : allClientInventors.values()) {
                mvWrapper.InventorsWrapper iw = new mvWrapper.InventorsWrapper();
                iw.recordId = null;
                iw.recordName = '';
                iw.inventorId = inventor.Id;
    
                iw.isExistingInventor = 'Existing';
    
                iw.inventorName = inventor.Name;
                List<String> addressLines = new List<String>();
    
                if(!String.isBlank(inventor.SymphonyLF__Address__Street__s)) {
                    addressLines.add(inventor.SymphonyLF__Address__Street__s);
                }
                if(!String.isBlank(inventor.SymphonyLF__Address__City__s)) {
                    addressLines.add(inventor.SymphonyLF__Address__City__s);
                }
                if(!String.isBlank(inventor.SymphonyLF__Address__StateCode__s)) {
                    addressLines.add(inventor.SymphonyLF__Address__StateCode__s);
                }
                if(!String.isBlank(inventor.SymphonyLF__Address__PostalCode__s)) {
                    addressLines.add(inventor.SymphonyLF__Address__PostalCode__s);
                }
                if(!String.isBlank(inventor.SymphonyLF__Address__CountryCode__s)) {
                    addressLines.add(inventor.SymphonyLF__Address__CountryCode__s);
                }

                iw.address = String.join(addressLines, ', ');
                iw.emailAddress = inventor.SymphonyLF__Email__c;
                iw.phoneNumber = inventor.SymphonyLF__Phone_Number__c;
                iw.nationality = inventor.SymphonyLF__Nationality__c;
                iw.isSelected = false;
                output.add(iw);
            }
        }
        
        return output;
    }

    @AuraEnabled
    public static List<mvWrapper.AssetIntakeJurisdictionWrapper> getAssetIntakeJurisdictions(Id assetIntakeId, String clientId){
        List<mvWrapper.AssetIntakeJurisdictionWrapper> output = new List<mvWrapper.AssetIntakeJurisdictionWrapper>();
        List<Asset_Intake_Jurisdiction__c> jurisdictions = [
            SELECT
                Id
                , Name
                , Jurisdiction__c
                , Jurisdiction__r.Name
                , CaseType__c
                , ClientReferenceNumber__c
                , Due_Date__c
                , Event_Date__c
                , Assigned_To__c
                , Assigned_To__r.Name
                , Docket_Type__c
                , Event_Name__c
            FROM Asset_Intake_Jurisdiction__c
            WHERE Asset_Intake_Form__c = :assetIntakeId
        ];

        Set<Id> assetJurisdictions = new Map<Id, Asset_Intake_Jurisdiction__c>(jurisdictions).keySet();

        System.debug('BBOO assetIntakeId ' + assetIntakeId);

        List<mvWrapper.ClientEngagementModelWrapper> cemsTemp_Temp = getClientEngagementModels(clientId, assetIntakeId, false, true);
        System.debug('cemsTemp_Temp---->'+cemsTemp_Temp);
        List<mvWrapper.ApplicantsWrapper> applicantsTemp = getApplicants(assetIntakeId, clientId, false, true);
        System.debug('applicants---->'+applicantsTemp);
        List<mvWrapper.InventorsWrapper> inventorsTemp = getInventors(assetIntakeId, clientId, true);
        System.debug('inventors---->'+inventorsTemp);
        List<mvWrapper.ClassesGoodsWrapper> classesAndGoodsTemp = getGoodsSpecifications(assetIntakeId, clientId, false, true);
        List<mvWrapper.ClientEngagementModelWrapper> cemsTemp = new List<mvWrapper.ClientEngagementModelWrapper>();
        for(mvWrapper.ClientEngagementModelWrapper  iw : cemsTemp_Temp) {
            if(iw.assetIntakePersonnelRecordId != null) {
                cemsTemp.add(iw);
                System.debug('cemsTemp---->'+cemsTemp);
            }
        }

        List<Asset_Intake_Jurisdiction_Relations__c> existingRelationsAll = [
            SELECT 
                Id
                , Asset_Intake_Jurisdiction__c
                , InstanceType__c
                , Asset_Intake_Applicant__c
                , Asset_Intake_Inventor__c
                , Asset_Intake_Personnel__c
                , Asset_Intake_Class__c
            FROM Asset_Intake_Jurisdiction_Relations__c
            WHERE Asset_Intake_Jurisdiction__c = :assetJurisdictions
        ];

        Map<Id, List<Asset_Intake_Jurisdiction_Relations__c>> relationsByAssetJurisdiction = new Map<Id, List<Asset_Intake_Jurisdiction_Relations__c>>();
        for(Asset_Intake_Jurisdiction_Relations__c relation : existingRelationsAll) {
            if(relationsByAssetJurisdiction.containsKey(relation.Asset_Intake_Jurisdiction__c)) {
                relationsByAssetJurisdiction.get(relation.Asset_Intake_Jurisdiction__c).add(relation);  
            } else {
                List<Asset_Intake_Jurisdiction_Relations__c> relations = new List<Asset_Intake_Jurisdiction_Relations__c>();
                relations.add(relation);
                relationsByAssetJurisdiction.put(relation.Asset_Intake_Jurisdiction__c, relations);
            }
        }

        for( Asset_Intake_Jurisdiction__c a : jurisdictions) {
            mvWrapper.AssetIntakeJurisdictionWrapper aiw = new mvWrapper.AssetIntakeJurisdictionWrapper();
            aiw.assetIntakeJurisdictionId = a.Id;
            aiw.assetIntakeId = assetIntakeId;
            aiw.recordName = a.Name;
            aiw.jurisdictionId = a.Jurisdiction__c;
            aiw.jurisdictionName = a.Jurisdiction__r.Name;
            aiw.clientReferenceNumber = a.ClientReferenceNumber__c;
            aiw.caseType = a.CaseType__c;

            aiw.docketType = a.Docket_Type__c;
            aiw.assignedToId = a.Assigned_To__c;
            aiw.assignedToName = a.Assigned_To__r.Name;
            aiw.eventDate = a.Event_Date__c;
            aiw.dueDate = a.Due_Date__c<a.Event_Date__c?null:a.Due_Date__c;
            aiw.eventName = a.Event_Name__c;

            aiw.clientEngagementModels = (List<mvWrapper.ClientEngagementModelWrapper>) JSON.deserializeStrict( JSON.serialize(cemsTemp), List<mvWrapper.ClientEngagementModelWrapper>.class );
            aiw.applicants = (List<mvWrapper.ApplicantsWrapper>) JSON.deserializeStrict( JSON.serialize(applicantsTemp), List<mvWrapper.ApplicantsWrapper>.class );
            aiw.inventors = (List<mvWrapper.InventorsWrapper>) JSON.deserializeStrict( JSON.serialize(inventorsTemp), List<mvWrapper.InventorsWrapper>.class );
            aiw.classes = (List<mvWrapper.ClassesGoodsWrapper>) JSON.deserializeStrict( JSON.serialize(classesAndGoodsTemp), List<mvWrapper.ClassesGoodsWrapper>.class );

            if(relationsByAssetJurisdiction.containsKey(a.Id)) {
                List<Asset_Intake_Jurisdiction_Relations__c> existingRelations = relationsByAssetJurisdiction.get(a.Id);

                Map<Id, Id> relationIdToRecordId = new Map<Id, Id>();
                for( Asset_Intake_Jurisdiction_Relations__c aijr : existingRelations ){
                    Id relationId;
                    if(aijr.InstanceType__c == 'Asset_Intake_Inventor__c'){
                        relationId = aijr.Asset_Intake_Inventor__c;
                    }
                    else if(aijr.InstanceType__c == 'Asset_Intake_Applicants__c'){
                        relationId = aijr.Asset_Intake_Applicant__c;
                    }
                    else if(aijr.InstanceType__c == 'Asset_Intake_Personnel__c'){
                        relationId = aijr.Asset_Intake_Personnel__c;
                    }
                    else if(aijr.InstanceType__c == 'Asset_Intake_Class__c'){
                        relationId = aijr.Asset_Intake_Class__c;
                    }
                    relationIdToRecordId.put(relationId , aijr.Id );
                }

                for( mvWrapper.ClientEngagementModelWrapper c : aiw.clientEngagementModels){
                    if( relationIdToRecordId.containsKey( c.assetIntakePersonnelRecordId )){
                        c.assetIntakeJurisdictionRelationRecordId = relationIdToRecordId.get( c.assetIntakePersonnelRecordId );
                    }
                }
        
                for( mvWrapper.ApplicantsWrapper c : aiw.applicants){
                    if( relationIdToRecordId.containsKey( c.recordId )){
                        c.assetIntakeJurisdictionRelationRecordId = relationIdToRecordId.get( c.recordId );
                    }
                }
        
                for( mvWrapper.InventorsWrapper c : aiw.inventors){
                    if( relationIdToRecordId.containsKey( c.recordId )){
                        c.assetIntakeJurisdictionRelationRecordId = relationIdToRecordId.get( c.recordId );
                    }
                }

                for( mvWrapper.ClassesGoodsWrapper c : aiw.classes){
                    if( relationIdToRecordId.containsKey( c.recordId )){
                        c.assetIntakeJurisdictionRelationRecordId = relationIdToRecordId.get( c.recordId );
                    }
                }
            }

            output.add( aiw );
        }
        return output;
    }


    private static Set<String> clientAssetSpecificationFields = new Set<String>{
        'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Jurisdiction__r.Name',
        'SymphonyLF__Languages__c',
        'SymphonyLF__Specification__c',
        'SymphonyLF__Sub_Class__c'
    };

    @AuraEnabled
    public static List<mvWrapper.ClassesGoodsWrapper> getGoodsSpecifications(String assetIntakeFormId, String clientId, Boolean createDefaultApplicants, Boolean fetchOnlySelected){
        List<Asset_Intake_Form__c> intakeForm = [
            SELECT 
                Id,
                Asset_Type__c
            FROM Asset_Intake_Form__c
            WHERE Id = :assetIntakeFormId
        ];

        Map<String, Standard_Classes_and_Goods_Specification__mdt> standardclasses = Standard_Classes_and_Goods_Specification__mdt.getAll();
        System.debug('standardclasses' + standardclasses);
        Map<String, SymphonyLF__Client_Classes_and_Goods_Specification__c> associatedGoodsAndServicesForClient = new Map<String, SymphonyLF__Client_Classes_and_Goods_Specification__c>();

        if(fetchOnlySelected != true){
            List<SymphonyLF__Client_Classes_and_Goods_Specification__c> temp = [
                SELECT 
                    Id
                    , Name
                    , SymphonyLF__Class__c
                    , SymphonyLF__Jurisdiction__c
                    , SymphonyLF__Jurisdiction__r.Name
                    , SymphonyLF__Languages__c
                    , SymphonyLF__Specification__c
                    , SymphonyLF__Sub_Class__c
                    , Enabled__c
                FROM 
                    SymphonyLF__Client_Classes_and_Goods_Specification__c 
                WHERE SymphonyLF__Client__c = :clientId
                    AND Id NOT IN (SELECT Client_Asset_Specification__c FROM Asset_Intake_Class__c WHERE Asset_Intake_Form__c = :assetIntakeFormId)
                ORDER BY SymphonyLF__Class__c ASC
            ];

            for(SymphonyLF__Client_Classes_and_Goods_Specification__c c : temp){
                associatedGoodsAndServicesForClient.put(c.Id, c);
            }
            
        }

        System.debug(' BB associatedGoodsAndServicesForClient ' + associatedGoodsAndServicesForClient.size());

        /*
        if(createDefaultApplicants == true){
            List<Asset_Intake_Applicants__c> toInsert = new List<Asset_Intake_Applicants__c>();
            for(SymphonyLF__Client__c client : associatedGoodsAndServicesForClient.values()){
                if(client.Is_Default__c){
                    Asset_Intake_Applicants__c aia = new Asset_Intake_Applicants__c();
                    aia.Asset_Intake_Form__c = assetIntakeFormId;
                    aia.Applicant__c = client.Id;

                    toInsert.add(aia);
                }
            }

            if(toInsert.size() > 0){
                insert toInsert;
            } 
        }
            */

        List<mvWrapper.ClassesGoodsWrapper> output = new List<mvWrapper.ClassesGoodsWrapper>();

        List<Asset_Intake_Class__c> applicants = [
            SELECT
                Id
                , Name
                , Client_Asset_Specification__r.SymphonyLF__Class__c
                , Client_Asset_Specification__r.SymphonyLF__Jurisdiction__c
                , Client_Asset_Specification__r.SymphonyLF__Jurisdiction__r.Name
                , Client_Asset_Specification__r.SymphonyLF__Languages__c
                , Client_Asset_Specification__r.SymphonyLF__Specification__c
                , Client_Asset_Specification__r.SymphonyLF__Sub_Class__c
                , Class__c
                , Jurisdiction__c
                , Jurisdiction__r.Name
                , Language__c 
                , Specification__c
                , Sub_Class__c
                , Instance_Type__c
                , Client_Asset_Specification__c
                , Standard_Class_Name__c
            FROM 
                Asset_Intake_Class__c
            WHERE
                Asset_Intake_Form__c =: assetIntakeFormId
        ];
        
        Set<Id> clientIdsProcessed = new Set<Id>();

        for(Asset_Intake_Class__c applicant : applicants) {
            mvWrapper.ClassesGoodsWrapper aw = new mvWrapper.ClassesGoodsWrapper();

            aw.recordId = applicant.Id;
            aw.recordName = applicant.Name;

            aw.clientSpecificationId = applicant.Client_Asset_Specification__c;
            aw.instanceType = applicant.Instance_Type__c;

            if( applicant.Instance_Type__c == 'Custom' || applicant.Instance_Type__c == '	Standard' ){
                aw.isExistingClass = 'Existing';
                associatedGoodsAndServicesForClient.remove(aw.clientSpecificationId);
            }
            else{
                aw.isExistingClass = 'New';
            }

            aw.className = (aw.isExistingClass == 'Existing') ? applicant.Client_Asset_Specification__r.SymphonyLF__Class__c : applicant.Class__c;
            aw.subclass = (aw.isExistingClass == 'Existing') ? applicant.Client_Asset_Specification__r.SymphonyLF__Sub_Class__c : applicant.Sub_Class__c;
            aw.jurisdictionId = (aw.isExistingClass == 'Existing') ? applicant.Client_Asset_Specification__r.SymphonyLF__Jurisdiction__c : applicant.Jurisdiction__c;
            aw.jurisdictionName = (aw.isExistingClass == 'Existing') ? applicant.Client_Asset_Specification__r.SymphonyLF__Jurisdiction__r.Name : applicant.Jurisdiction__r.Name;
            aw.languages = (aw.isExistingClass == 'Existing') ? applicant.Client_Asset_Specification__r.SymphonyLF__Languages__c : applicant.Language__c;
            aw.specification = (aw.isExistingClass == 'Existing') ? applicant.Client_Asset_Specification__r.SymphonyLF__Specification__c : applicant.Specification__c;

            aw.isSelected = true;

            output.add(aw);
        }

        //Add standard metadata classes
        /* if(standardclasses.size() > 0){
            for (Standard_Classes_and_Goods_Specification__mdt mdt : standardclasses.values()){
                mvWrapper.ClassesGoodsWrapper aw = new mvWrapper.ClassesGoodsWrapper();

                aw.recordId = null;
                aw.recordName = mdt.Label;
                aw.customMetadataType = mdt.DeveloperName;
                aw.isExistingClass = 'Existing';
                aw.instanceType = 'Standard';
                aw.className = mdt.Class__c;
                aw.subclass = '';
                aw.jurisdictionId = Null;
                aw.jurisdictionName = Null;
                aw.languages = mdt.Languages__c;
                aw.specification = mdt.Specification__c;
                aw.isSelected = false;

                output.add(aw);

            }
        }*/

        if(associatedGoodsAndServicesForClient.size() > 0){
            for(SymphonyLF__Client_Classes_and_Goods_Specification__c client : associatedGoodsAndServicesForClient.values()) {
                mvWrapper.ClassesGoodsWrapper aw = new mvWrapper.ClassesGoodsWrapper();
                aw.recordId = null;
                aw.recordName = '';
                aw.clientSpecificationId = client.Id;
                aw.isExistingClass = 'Existing';
                aw.recordName = client.Name;
                aw.className = client.SymphonyLF__Class__c;
                aw.subclass = client.SymphonyLF__Sub_Class__c;
                aw.jurisdictionId = client.SymphonyLF__Jurisdiction__c;
                aw.jurisdictionName = client.SymphonyLF__Jurisdiction__r.Name;
                aw.languages = client.SymphonyLF__Languages__c;
                aw.specification =  client.SymphonyLF__Specification__c;
                aw.isEnabled= client.Enabled__c;
                aw.isSelected = aw.isEnabled ? true : false;
                
                output.add(aw);
            }
        }
        
        return output;
    }

    @AuraEnabled
    public static List<mvWrapper.AssetIntakeWrapper> getDraftAssetRecords(String clientId, String assetType) {
        List<mvWrapper.AssetIntakeWrapper> output = new List<mvWrapper.AssetIntakeWrapper>();

        Set<String> status = new Set<String>{
            'Draft'
            //'Submitted'
        };

        List<Asset_Intake_Form__c> assetDraftRecords = [SELECT id 
                                                             , Client__c
                                                             , Client__r.Name
                                                             , New_Patent_Family__c
                                                             , Patent_Family__c
                                                             , Patent_Family__r.Name
                                                             , Patent_Family__r.SymphonyLF__Docket_Number__c
                                                             , Mark__c
                                                             , Mark__r.Name
                                                             , Mark__r.SymphonyLF__Docket_Number__c
                                                             , New_Mark_Title__c
                                                             , Status__c
                                                             , Patent_Family_Derived__c
                                                             , Asset_Type__c
                                                             , Current_Page__c
                                                             , CreatedDate
                                                             , CreatedBy.name
                                                             , CreatedById
                                                             , Name
                                                             , Conflict_Check__c
                                                             , Conflict_Check__r.Name
                                                             , Dispute_Sub_Type__c
                                                             , Dispute_Type__c
                                                             , Title__c	
                                                          FROM Asset_Intake_Form__c WHERE Client__c  = :clientId
                                                           AND Status__c = :status
                                                           AND Asset_Type__c = :assetType
                                                         ORDER BY Status__c ASC, CreatedDate DESC];

        for(Asset_Intake_Form__c a : assetDraftRecords){
            mvWrapper.AssetIntakeWrapper o = new mvWrapper.AssetIntakeWrapper();
            o.recordId = a.Id;
            o.recordName = a.Name;
            o.clientId = a.Client__c;
            o.clientName = a.Client__r.Name;
            o.currentPage = a.Current_Page__c;
            o.createdById =  a.CreatedById;
            o.createdByName = a.CreatedBy.Name;
            o.assetType = a.Asset_Type__c;
            o.status = a.Status__c;

            if(a.Conflict_Check__c != null){
                o.conflictCheckId = a.Conflict_Check__c;
                o.conflictCheckName = a.Conflict_Check__r.Name;
            }

            if(a.Asset_Type__c == 'New Patent Family' || a.Asset_Type__c == 'Existing Patent Family' || a.Asset_Type__c == 'Patent'){
                o.familyId = a.Patent_Family__c;
                if(a.Patent_Family__c != null){
                    o.familyDocketNumber = a.Patent_Family__r.SymphonyLF__Docket_Number__c;
                    o.familyTitle = a.Patent_Family__r.Name;
                }
                else{
                    o.familyTitle = a.New_Patent_Family__c;
                }
            }
            else if(a.Asset_Type__c == 'New Design Family' || a.Asset_Type__c == 'Existing Design Family'){

            }
            else if(a.Asset_Type__c == 'New Mark' || a.Asset_Type__c == 'Existing Mark' || a.Asset_Type__c == 'Trademark'){
                o.familyId = a.Mark__c;
                if(a.Patent_Family__c != null){
                    o.familyDocketNumber = a.Mark__r.SymphonyLF__Docket_Number__c;
                    o.familyTitle = a.Mark__r.Name;
                }
                else{
                    o.familyTitle = a.New_Mark_Title__c;
                }
            }else if(a.Asset_Type__c == 'Opposition'){
                o.disputeType = a.Dispute_Type__c;
                o.disputeSubType = a.Dispute_Sub_Type__c;
                o.title = a.Title__c;

            }

            output.add( o );
        }
        

        return output;
    }

    @AuraEnabled
    public static List<mvWrapper.AssetIntakeWrapper> getDraftRecords(String clientId, String assetType) {
        List<mvWrapper.AssetIntakeWrapper> output = new List<mvWrapper.AssetIntakeWrapper>();

        Set<String> status = new Set<String>{
            'Draft'
            //'Submitted'
        };

        List<Asset_Intake_Form__c> assetDraftRecords = [SELECT id 
                                                             , Client__c
                                                             , Client__r.Name
                                                             , New_Patent_Family__c
                                                             , Patent_Family__c
                                                             , Patent_Family__r.Name
                                                             , Patent_Family__r.SymphonyLF__Docket_Number__c
                                                             , Status__c
                                                             , Patent_Family_Derived__c
                                                             , Asset_Type__c
                                                             , Current_Page__c
                                                             , CreatedDate
                                                             , CreatedBy.name
                                                             , CreatedById
                                                             , Name
                                                             , Conflict_Check__c
                                                             , Conflict_Check__r.Name
                                                             , Dispute_Sub_Type__c
                                                             , Dispute_Type__c
                                                             , Title__c	
                                                             
                                                          FROM Asset_Intake_Form__c WHERE Client__c  = :clientId
                                                           AND Status__c = :status
                                                            AND Asset_Type__c = :assetType
                                                         ORDER BY Status__c ASC, CreatedDate DESC];
        system.debug('Asset Draft Records : '+assetDraftRecords);
        System.debug('asset type in get draft recs--->'+assetType);
        System.debug('client id in get draft recs--->'+clientId);
        system.debug(assetDraftRecords.size());

        for(Asset_Intake_Form__c a : assetDraftRecords){
            mvWrapper.AssetIntakeWrapper o = new mvWrapper.AssetIntakeWrapper();
            o.recordId = a.Id;
            o.recordName = a.Name;
            o.clientId = a.Client__c;
            o.clientName = a.Client__r.Name;
            o.currentPage = a.Current_Page__c;
            o.createdById =  a.CreatedById;
            o.createdByName = a.CreatedBy.Name;
            o.assetType = a.Asset_Type__c;
            o.status = a.Status__c;

            if(a.Conflict_Check__c != null){
                o.conflictCheckId = a.Conflict_Check__c;
                o.conflictCheckName = a.Conflict_Check__r.Name;
            }

            if(a.Asset_Type__c == 'New Patent Family' || a.Asset_Type__c == 'Existing Patent Family'){
                o.familyId = a.Patent_Family__c;
                if(a.Patent_Family__c != null){
                    o.familyDocketNumber = a.Patent_Family__r.SymphonyLF__Docket_Number__c;
                    o.familyTitle = a.Patent_Family__r.Name;
                }
                else{
                    o.familyTitle = a.New_Patent_Family__c;
                }
            }
            else if(a.Asset_Type__c == 'New Design Family' || a.Asset_Type__c == 'Existing Design Family'){

            }
            else if(a.Asset_Type__c == 'New Mark' || a.Asset_Type__c == 'Existing Mark'){

            }
            else if(a.Asset_Type__c == 'Opposition'){

                o.disputeSubType = a.Dispute_Sub_Type__c;
                o.disputeType = a.Dispute_Type__c;
                o.title = a.Title__c;

            }

            output.add( o );
        }
        system.debug(output.size());
        

        return output;
    }

    private static Set<String> getRelevantCemIpMatters(Asset_Intake_Form__c form){
        Set<String> output = new Set<String>();
        output.add('All');

        if(
            form.Asset_Type__c == 'New Patent Family' 
            || 
            form.Asset_Type__c == 'Existing Patent Family' 
            ||
            form.Asset_Type__c == 'Patent'
        ){
            output.add( 'Patent' );
        }
        else if(
            form.Asset_Type__c == 'New Mark' 
            || 
            form.Asset_Type__c == 'Existing Mark'
             ||
            form.Asset_Type__c == 'Trademark'
        ){
            output.add( 'Trademark' );
        }

        return output;
    }

@AuraEnabled
public static List<mvWrapper.ClientEngagementModelWrapper> getIntakePersonnelModelsForYetToEngageClients(
    Id recordId,
    String assetIntakeFormId,
    Boolean createDefaultEngagementModels,
    Boolean fetchOnlySelected
) {
    List<mvWrapper.ClientEngagementModelWrapper> output = new List<mvWrapper.ClientEngagementModelWrapper>();
    Map<mvWrapper.ClientEngagementModelWrapper, mvWrapper.ClientEngagementModelWrapper> outputTemp = new Map<mvWrapper.ClientEngagementModelWrapper, mvWrapper.ClientEngagementModelWrapper>();

        // Query inserted records with relationships
        List<Asset_Intake_Personnel__c> assetIntakepersonnels = [
            SELECT Id, Name, Type__c, Personnel__c,
                   Personnel__r.Name,
                   Personnel__r.SymphonyLF__Phone_Number__c,
                   Personnel__r.SymphonyLF__Email__c,
                   Personnel__r.RecordType.DeveloperName
            FROM Asset_Intake_Personnel__c
           WHERE Asset_Intake_Form__c  = :assetIntakeFormId
        ];

        Map<String, Asset_Intake_Personnel__c> assetIntakePersonnelsByPersonRole = new Map<String, Asset_Intake_Personnel__c>();  

        for(Asset_Intake_Personnel__c aip : assetIntakepersonnels){
            assetIntakePersonnelsByPersonRole.put(aip.Personnel__c + '-' + aip.Type__c, aip);
        }

        List<Asset_Intake_Form__c> intakeForm = [
            SELECT 
                Id,
                Asset_Type__c
                , Client__r.Client_Status__c

                , Client__r.Managing_Supervising_Attorney__c
                , Client__r.Managing_Supervising_Attorney__r.Name
                , Client__r.Managing_Supervising_Attorney__r.SymphonyLF__Phone_Number__c
                , Client__r.Managing_Supervising_Attorney__r.SymphonyLF__Email__c
                , Client__r.Managing_Supervising_Attorney__r.RecordType.DeveloperName

                , Client__r.Originating_Attorney__c
                , Client__r.Originating_Attorney__r.Name
                , Client__r.Originating_Attorney__r.SymphonyLF__Phone_Number__c
                , Client__r.Originating_Attorney__r.SymphonyLF__Email__c
                , Client__r.Originating_Attorney__r.RecordType.DeveloperName

                , Client__r.Responsible_Billing_Attorney__c
                , Client__r.Responsible_Billing_Attorney__r.Name
                , Client__r.Responsible_Billing_Attorney__r.SymphonyLF__Phone_Number__c
                , Client__r.Responsible_Billing_Attorney__r.SymphonyLF__Email__c
                , Client__r.Responsible_Billing_Attorney__r.RecordType.DeveloperName

                , Client__r.Working_Assigned_Attorney__c
                , Client__r.Working_Assigned_Attorney__r.Name
                , Client__r.Working_Assigned_Attorney__r.SymphonyLF__Phone_Number__c
                , Client__r.Working_Assigned_Attorney__r.SymphonyLF__Email__c
                , Client__r.Working_Assigned_Attorney__r.RecordType.DeveloperName

            FROM Asset_Intake_Form__c
            WHERE Id = :assetIntakeFormId
        ];

        Map<String, String> ATTORNEY_TYPE_MAP = new Map<String, String>{
            'Managing_Supervising_Attorney__c' => 'Managing (Supervising) Attorney',
            'Originating_Attorney__c' => 'Originating Attorney',
            'Responsible_Billing_Attorney__c' => 'Responsible (Billing) Attorney',
            'Working_Assigned_Attorney__c' => 'Working Attorney'
        };

        for(String field : ATTORNEY_TYPE_MAP.keySet()){
            sObject intakeFormSobject = (sObject) intakeForm[0];

            Id personId = (Id) intakeFormSobject.getSobject('Client__r').get(field);
            String type = ATTORNEY_TYPE_MAP.get(field);

            if (personId != null) {
                SymphonyLF__Person__c person = (SymphonyLF__Person__c) intakeFormSobject.getSobject('Client__r').getSobject(field.replace('__c', '__r'));

                String key = person.Id + '-' + type;
                
                mvWrapper.ClientEngagementModelWrapper single = new mvWrapper.ClientEngagementModelWrapper();
              //  single.recordId = rec.Id;
                single.assetIntakePersonnelRecordId = (assetIntakePersonnelsByPersonRole.containsKey(key)) ? (assetIntakePersonnelsByPersonRole.get( key )).Id : null;
                single.symphonyId = person.Name;
                single.type = type;
                single.contactName = person.Name;
                single.phone = String.isNotBlank( person.SymphonyLF__Phone_Number__c ) ? person.SymphonyLF__Phone_Number__c : '';
                single.email = String.isNotBlank(person.SymphonyLF__Email__c) ? person.SymphonyLF__Email__c : '';
                single.isDefault = true;
                single.contactRecordId = person.Id;
                single.ipMatters = 'All';
                single.contactRecordType = person.RecordTypeId != null
                    ? String.valueOf(person.RecordType.DeveloperName)
                    : '';
                single.isSelected = (assetIntakePersonnelsByPersonRole.containsKey(key)) ? true : false;
                single.jurisdictions = 'All';

                outputTemp.put(single, single);
            }
        }

        Set<mvWrapper.ClientEngagementModelWrapper> keySet = outputTemp.keySet();
        for(mvWrapper.ClientEngagementModelWrapper v : keySet){
            if( v.isSelected == true ){
                output.add( outputTemp.get(v) );
                outputTemp.remove( v );
            }
        }

        if(outputTemp.size() > 0){
            for(mvWrapper.ClientEngagementModelWrapper v : outputTemp.values()){
                output.add(v);
            }
        }

        return output;
    }

    @AuraEnabled
    public static List<mvWrapper.ClientEngagementModelWrapper> getClientEngagementModelsNoIntakeId(Id clientId){


        List<mvWrapper.ClientEngagementModelWrapper> output = new List<mvWrapper.ClientEngagementModelWrapper>();

        List<SymphonyLF__Client__c> client = [
            SELECT 
                Id
                , Client_Status__c
                , Managing_Supervising_Attorney__c
                , Managing_Supervising_Attorney__r.Name
                , Managing_Supervising_Attorney__r.SymphonyLF__Phone_Number__c
                , Managing_Supervising_Attorney__r.SymphonyLF__Email__c
                , Managing_Supervising_Attorney__r.RecordType.DeveloperName

                , Originating_Attorney__c
                , Originating_Attorney__r.Name
                , Originating_Attorney__r.SymphonyLF__Phone_Number__c
                , Originating_Attorney__r.SymphonyLF__Email__c
                , Originating_Attorney__r.RecordType.DeveloperName

                , Responsible_Billing_Attorney__c
                , Responsible_Billing_Attorney__r.Name
                , Responsible_Billing_Attorney__r.SymphonyLF__Phone_Number__c
                , Responsible_Billing_Attorney__r.SymphonyLF__Email__c
                , Responsible_Billing_Attorney__r.RecordType.DeveloperName

                , Working_Assigned_Attorney__c
                , Working_Assigned_Attorney__r.Name
                , Working_Assigned_Attorney__r.SymphonyLF__Phone_Number__c
                , Working_Assigned_Attorney__r.SymphonyLF__Email__c
                , Working_Assigned_Attorney__r.RecordType.DeveloperName
            FROM SymphonyLF__Client__c
            WHERE Id = :clientId
        ];

        if (client[0].Client_Status__c == 'Yet to Engage') {

        Map<String, String> ATTORNEY_TYPE_MAP = new Map<String, String>{
            'Managing_Supervising_Attorney__c' => 'Managing (Supervising) Attorney',
            'Originating_Attorney__c' => 'Originating Attorney',
            'Responsible_Billing_Attorney__c' => 'Responsible (Billing) Attorney',
            'Working_Assigned_Attorney__c' => 'Working Attorney'
        };

        for(String field : ATTORNEY_TYPE_MAP.keySet()){
            sObject clientSobject = (sObject) client[0];

            Id personId = (Id) clientSobject.get(field);
            String type = ATTORNEY_TYPE_MAP.get(field);

            if (personId != null) {
                SymphonyLF__Person__c person = (SymphonyLF__Person__c) clientSobject.getSobject(field.replace('__c', '__r'));

                String key = person.Id + '-' + type;
                
                mvWrapper.ClientEngagementModelWrapper single = new mvWrapper.ClientEngagementModelWrapper();
                single.recordId = person.Id;
                single.symphonyId = person.Name;
                single.type = type;
                single.contactName = person.Name;
                single.phone = String.isNotBlank( person.SymphonyLF__Phone_Number__c ) ? person.SymphonyLF__Phone_Number__c : '';
                single.email = String.isNotBlank(person.SymphonyLF__Email__c) ? person.SymphonyLF__Email__c : '';
                single.isDefault = true;
                single.contactRecordId = person.Id;
                single.ipMatters = 'All';
                single.contactRecordType = person.RecordTypeId != null
                    ? String.valueOf(person.RecordType.DeveloperName)
                    : '';
                single.isSelected = true;
                single.jurisdictions = 'All';

                output.add(single);
            }
        }
}else{

        Set<String> cemIpMattes = new Set<String>{'General Matter', 'All'};

        String sobjectType = clientId.getSobjectType().getDescribe().getName();

        if(! sobjectType.equals(ClientEngagementModelApplication.CLIENT_OBJECT_NAME) ){
            throw new NotValidObjectException('Not valid object ' + sobjectType);
        }

        Map<String, Object> bindMap = new Map<String, Object>();

        bindMap.put('lookupFieldValue', clientId);
     //   bindMap.put('cemIpMattes', cemIpMattersString);
        
         String query = ' SELECT ' + String.join(fieldsClientEngagementModel, ', ') +
            ' FROM SymphonyLF__Client_Engagement_Model__c ' +
            ' WHERE ' + ' SymphonyLF__Client__c = :lookupFieldValue ' + 'AND Is_Active__c = true';

            if(cemIpMattes.size() > 0){
                String cemIpMattesString = '(\'' + String.join(cemIpMattes, '\',\'') + '\')';
                query += ' AND SymphonyLF__IP_Matters__c INCLUDES ' + cemIpMattesString ;
            }

         //   query += ' AND Is_Active__c = true ';
         //   '   AND SymphonyLF__IP_Matters__c includes (' + cemIpMattes + ') ' +
         query += ' ORDER BY Is_Default__c DESC, Sequence__c ASC, SymphonyLF__Person__r.Name ASC NULLS LAST ';

        System.debug('BBB query ' + query);
                

        List<sObject> records = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
        List<Id> recordIds = new List<Id>();
        for(sObject rec : records){
            mvWrapper.ClientEngagementModelWrapper single = new mvWrapper.ClientEngagementModelWrapper();

            single.recordId = (Id) rec.get('Id') ;
            single.symphonyId = String.valueOf( rec.get('Name') );
            single.type = String.valueof( rec.get('SymphonyLF__Type__c') );
            single.contactName = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('Name') );
            single.phone = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Phone_Number__c') );
            single.email = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Email__c') );
            single.isDefault = Boolean.valueOf(rec.get('Is_Default__c'));
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

            single.isSelected = single.isDefault;


            output.add(single);
        }
    }
        return output;
    }


    @AuraEnabled
    public static List<mvWrapper.ClientEngagementModelWrapper> getClientEngagementModels(Id recordId, String assetIntakeFormId, Boolean createDefaultEngagementModels, Boolean fetchOnlySelected){
        System.debug('BBOO assetIntakeFormId ' + assetIntakeFormId);

        List<mvWrapper.ClientEngagementModelWrapper> output = new List<mvWrapper.ClientEngagementModelWrapper>();
        List<mvWrapper.ClientEngagementModelWrapper> tempSelected = new List<mvWrapper.ClientEngagementModelWrapper>();
        List<mvWrapper.ClientEngagementModelWrapper> tempNotSelected = new List<mvWrapper.ClientEngagementModelWrapper>();

        List<Asset_Intake_Form__c> intakeForm = [
            SELECT 
                Id,
                Asset_Type__c,
                Client__c, 
                Client__r.Name, 
                Client__r.Client_Status__c
            FROM Asset_Intake_Form__c
            WHERE Id = :assetIntakeFormId
        ];

        if (!intakeForm.isEmpty() && intakeForm[0].Client__r.Client_Status__c == 'Yet to Engage') {
    output = getIntakePersonnelModelsForYetToEngageClients(recordId, assetIntakeFormId, createDefaultEngagementModels, fetchOnlySelected);
}else{

        Set<String> cemIpMattes = getRelevantCemIpMatters( intakeForm[0] );
      /*  String cemIpMattersString = ''; // '(';
        
        for(String includeValue :cemIpMattes){
            cemIpMattersString += includeValue + ',';
        }
        cemIpMattersString += cemIpMattersString.removeEnd(',');
     //   cemIpMattersString += ')';-

     System.debug('cemIpMattersString  ' + cemIpMattersString);
     */


     /*
        if(createDefaultEngagementModels == true){
            List<SymphonyLF__Client_Engagement_Model__c> defaults = [
                SELECT Id , SymphonyLF__Person__c
                FROM SymphonyLF__Client_Engagement_Model__c
                WHERE Is_Default__c = true 
                   // AND SymphonyLF__IP_Matters__c includes ( :cemIpMattersString )
                    AND Id NOT IN (SELECT Client_Engagement_Model__c FROM Asset_Intake_Personnel__c WHERE Asset_Intake_Form__c =: assetIntakeFormId)
            ];

            if(defaults.size() > 0){
                List<Asset_Intake_Personnel__c> toInsert = new List<Asset_Intake_Personnel__c>();

                for(SymphonyLF__Client_Engagement_Model__c d : defaults){
                    Asset_Intake_Personnel__c aip = new Asset_Intake_Personnel__c();
                    aip.Asset_Intake_Form__c = assetIntakeFormId;
                    aip.Client_Engagement_Model__c = d.Id;
                    aip.Personnel__c = d.SymphonyLF__Person__c;

                    toInsert.add(aip);
                }

                insert toInsert;
            }
        }
            */


        List<Asset_Intake_Personnel__c> assetIntakepersonnels = [
            SELECT
                Id,
                Client_Engagement_Model__c,
                Personnel__c,
                Personnel__r.Name,
                Personnel__r.RecordType.DeveloperName,
                Personnel__r.SymphonyLF__Email__c,
                Personnel__r.SymphonyLF__Phone_Number__c
            FROM 
                 Asset_Intake_Personnel__c 
            WHERE 
                Asset_Intake_Form__c =: assetIntakeFormId
        ];

        Map<Id, Asset_Intake_Personnel__c> assetIntakePersonnelsCemToRecord = new Map<Id, Asset_Intake_Personnel__c>();  

        for(Asset_Intake_Personnel__c aip : assetIntakepersonnels){
            assetIntakePersonnelsCemToRecord.put(aip.Client_Engagement_Model__c, aip);
        }

        
       // Set<Id> processedCems = new Set<Id>();

        String sobjectType = recordId.getSobjectType().getDescribe().getName();

        if(! sobjectType.equals(ClientEngagementModelApplication.CLIENT_OBJECT_NAME) ){
            throw new NotValidObjectException('Not valid object ' + sobjectType);
        }

        Map<String, Object> bindMap = new Map<String, Object>();

        bindMap.put('lookupFieldValue', recordId);
     //   bindMap.put('cemIpMattes', cemIpMattersString);
        
         String query = ' SELECT ' + String.join(fieldsClientEngagementModel, ', ') +
            ' FROM SymphonyLF__Client_Engagement_Model__c ' +
            ' WHERE ' + ' SymphonyLF__Client__c = :lookupFieldValue ' + 'AND Is_Active__c = true';

            if(cemIpMattes.size() > 0){
                String cemIpMattesString = '(\'' + String.join(cemIpMattes, '\',\'') + '\')';
                query += ' AND SymphonyLF__IP_Matters__c INCLUDES ' + cemIpMattesString ;
            }

         //   query += ' AND Is_Active__c = true ';
         //   '   AND SymphonyLF__IP_Matters__c includes (' + cemIpMattes + ') ' +
         query += ' ORDER BY Is_Default__c DESC, Sequence__c ASC, SymphonyLF__Person__r.Name ASC NULLS LAST ';

        System.debug('BBB query ' + query);
                

        List<sObject> records = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
        List<Id> recordIds = new List<Id>();
        for(sObject rec : records){
            mvWrapper.ClientEngagementModelWrapper single = new mvWrapper.ClientEngagementModelWrapper();

            single.recordId = (Id) rec.get('Id') ;
            single.symphonyId = String.valueOf( rec.get('Name') );
            single.type = String.valueof( rec.get('SymphonyLF__Type__c') );
            single.contactName = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('Name') );
            single.phone = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Phone_Number__c') );
            single.email = String.valueof( rec.getSobject('SymphonyLF__Person__r')?.get('SymphonyLF__Email__c') );
            single.isDefault = Boolean.valueOf(rec.get('Is_Default__c'));
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

            if(assetIntakePersonnelsCemToRecord.containsKey( single.recordId )){
                single.isSelected = true;
                single.assetIntakePersonnelRecordId = assetIntakePersonnelsCemToRecord.get( single.recordId ).Id;
            }
            else{
                single.isSelected = false;
            }

            if(single.isSelected == true){
                tempSelected.add(single);
            }
            else{
                tempNotSelected.add(single);
            }

           // output.add(single);

          //  processedCems.add(single.contactRecordId);
            recordIds.add(single.recordId);
        }

        /*
        for(Asset_Intake_Personnel__c rec : assetIntakepersonnels){
            if( ! processedCems.contains(rec.Personnel__c)){
                mvWrapper.ClientEngagementModelWrapper single = new mvWrapper.ClientEngagementModelWrapper();

                single.recordId = rec.Id;
                single.symphonyId = rec.Name;
               // single.type = String.valueof( rec.get('SymphonyLF__Type__c') );
                single.contactName = rec.Personnel__r.Name;
                single.phone = rec.Personnel__r.SymphonyLF__Phone_Number__c;
                single.email = rec.Personnel__r.SymphonyLF__Email__c;
                single.contactRecordId = rec.Personnel__c ;

                single.isSelected = true;
                single.assetIntakePersonnelRecordId = assetIntakePersonnelsCemToRecord.get( single.contactRecordId ).Id;
                
                if(emptySet.contains(single.phone)){
                    single.phone = '';
                }
                if(emptySet.contains(single.email)){
                    single.email = '';
                }

                tempSelected.add(single);

                processedCems.add(single.contactRecordId);
            }
        }
        */

        output.addAll(tempSelected);
        output.addAll(tempNotSelected);
        
    }
        return output;
    }

    public class NotValidObjectException extends Exception{

    }

    public class MattersWrapper{
        @AuraEnabled public Id recordId;
        @AuraEnabled public String label;
        @AuraEnabled public String title;
        @AuraEnabled public String docketNumber;
        @AuraEnabled public String caseType;
        @AuraEnabled public String jurisdiction;
         @AuraEnabled public String familyStatus;
    }

    @AuraEnabled
    public static List<MattersWrapper> submissionGeneralMatter(
        Id clientId
        , Id conflictCheckId
        , String generalMatterTitle
        , String generalMatterReferenceNumber
        , String generalMatterType
        , String generalMatterJurisdiction
        , String generalMatterDescription
        , String generalMatterCreditStatus
        , List<String> personnelRecordIdSelected){
        List<MattersWrapper> output = new List<MattersWrapper>();
        List<SymphonyLF__Client__c> clientStatusToUpdate = new List<SymphonyLF__Client__c>();

        List<SymphonyLF__Client__c> client = [
            SELECT 
                Id
                , Client_Status__c
                , Managing_Supervising_Attorney__c
                , Managing_Supervising_Attorney__r.Name
                , Managing_Supervising_Attorney__r.SymphonyLF__Phone_Number__c
                , Managing_Supervising_Attorney__r.SymphonyLF__Email__c
                , Managing_Supervising_Attorney__r.RecordType.DeveloperName

                , Originating_Attorney__c
                , Originating_Attorney__r.Name
                , Originating_Attorney__r.SymphonyLF__Phone_Number__c
                , Originating_Attorney__r.SymphonyLF__Email__c
                , Originating_Attorney__r.RecordType.DeveloperName

                , Responsible_Billing_Attorney__c
                , Responsible_Billing_Attorney__r.Name
                , Responsible_Billing_Attorney__r.SymphonyLF__Phone_Number__c
                , Responsible_Billing_Attorney__r.SymphonyLF__Email__c
                , Responsible_Billing_Attorney__r.RecordType.DeveloperName

                , Working_Assigned_Attorney__c
                , Working_Assigned_Attorney__r.Name
                , Working_Assigned_Attorney__r.SymphonyLF__Phone_Number__c
                , Working_Assigned_Attorney__r.SymphonyLF__Email__c
                , Working_Assigned_Attorney__r.RecordType.DeveloperName
            FROM SymphonyLF__Client__c
            WHERE Id = :clientId
        ];

        Map<String, Id> cemForJustActiveClients = new Map<String, Id>();
        if(client[0].Client_Status__c == 'Yet to Engage'){
            client[0].Client_Status__c = 'Active';
            
            SymphonyLF__Client__c cli = new SymphonyLF__Client__c();
            cli.Id = client[0].Id;
            cli.Client_Status__c = 'Active';

            clientStatusToUpdate.add(cli);

            if(clientStatusToUpdate.size() > 0){
                update clientStatusToUpdate;

                List<SymphonyLF__Client_Engagement_Model__c> temp = [
                    SELECT Id, SymphonyLF__Person__c, SymphonyLF__Type__c
                    FROM SymphonyLF__Client_Engagement_Model__c 
                    WHERE SymphonyLF__Client__c = :client[0].Id
                ];

                for(SymphonyLF__Client_Engagement_Model__c t : temp){
                    cemForJustActiveClients.put(t.SymphonyLF__Person__c + '-' + t.SymphonyLF__Type__c , t.Id);
                }
            }
        }

        Id generalMatterId;
        SymphonyLF__General_Matter__c gm = new SymphonyLF__General_Matter__c();
        gm.SymphonyLF__Client__c = clientId;
        gm.Name = generalMatterTitle;
        gm.SymphonyLF__Client_Reference__c = generalMatterReferenceNumber;
        gm.SymphonyLF__Type__c = generalMatterType;

        if(String.isNotBlank(generalMatterJurisdiction)){
            gm.SymphonyLF__Jurisdiction__c = generalMatterJurisdiction;
        }
        
        gm.SymphonyLF__Description__c = generalMatterDescription;
        gm.Credit_Status__c = generalMatterCreditStatus;
        insert gm;
        generalMatterId = gm.Id;

        List<SymphonyLF__Matter_Engagement_Model__c> memsToInsert = new List<SymphonyLF__Matter_Engagement_Model__c>();

        Set<Id> cemIds = new Set<Id>();
        if(personnelRecordIdSelected.size() > 0){
            for(String s : personnelRecordIdSelected){
                Integer firstIndex = s.indexOf('-');
                List<String> idAndTypeSplit = s.split('-');
                System.debug('ssss ' + s);
                System.debug('idAndTypeSplit ' + idAndTypeSplit);
                Id i = idAndTypeSplit[0];
                String type = idAndTypeSplit[1];

                if(i.getSobjectType() == SymphonyLF__Client_Engagement_Model__c.sObjectType){
                    cemIds.add( i );
                }
                else{
                    SymphonyLF__Matter_Engagement_Model__c m = new SymphonyLF__Matter_Engagement_Model__c();
                    m.SymphonyLF__Type__c = type;
                    m.SymphonyLF__General_Matter__c = generalMatterId;
                    m.SymphonyLF__Assign_to_User__c = i;
                    m.SymphonyLF__Client__c = clientId;
                    m.Is_Active__c = true;
                    m.Client_Engagement_Model__c = cemForJustActiveClients.get(i + '-' + type);

                    memsToInsert.add( m );
                }
            }
        }

        if(cemIds.size() > 0){
            for(SymphonyLF__Client_Engagement_Model__c c : [
                SELECT Id,SymphonyLF__Type__c,SymphonyLF__Person__c
                FROM SymphonyLF__Client_Engagement_Model__c
                WHERE Id IN :cemIds
            ]){
                SymphonyLF__Matter_Engagement_Model__c m = new SymphonyLF__Matter_Engagement_Model__c();
                m.SymphonyLF__Type__c = c.SymphonyLF__Type__c;
                m.SymphonyLF__General_Matter__c = generalMatterId;
                m.SymphonyLF__Assign_to_User__c = c.SymphonyLF__Person__c;
                m.SymphonyLF__Client__c = clientId;
                m.Client_Engagement_Model__c = c.Id;
                m.Is_Active__c = true;

                memsToInsert.add( m );
            }
        }

        if(memsToInsert.size() > 0){
            insert memsToInsert;
        }
        

        List<Conflict_Check__c> conflictChecksToUpdate = new List<Conflict_Check__c>();
        Conflict_Check__c cc = new Conflict_Check__c();
        cc.Id = conflictCheckId;
        cc.CC_Status__c = 'Matter Created';

        conflictChecksToUpdate.add(cc);

        if(conflictChecksToUpdate.size() > 0){
            update conflictChecksToUpdate;
        }

        List<sObject> newFamilyMatters = Database.query(' SELECT Id, Name, SymphonyLF__Docket_Number__c, SymphonyLF__Jurisdiction__c, SymphonyLF__Jurisdiction__r.Name, SymphonyLF__Type__c FROM SymphonyLF__General_Matter__c WHERE Id = :generalMatterId ');
        for(sObject record : newFamilyMatters){
            MattersWrapper matterWrapper = new MattersWrapper();

            matterWrapper.recordId = (Id) record.get('Id');
            matterWrapper.docketNumber = (String) record.get('SymphonyLF__Docket_Number__c');
            matterWrapper.title = (String) record.get('Name'); 
            matterWrapper.caseType = (String) record.get('SymphonyLF__Type__c'); 
            matterWrapper.jurisdiction = (String) record.getSObject('SymphonyLF__Jurisdiction__r')?.get('Name'); 
            matterWrapper.label = 'General Matter';
            matterWrapper.familyStatus = 'Live';

            output.add(matterWrapper);
        }

        return output;
    }

    @AuraEnabled
    public static List<MattersWrapper> submission(Id intakeId, Id clientId){
        try{
        List<MattersWrapper> output = new List<MattersWrapper>();
        List<SymphonyLF__Client__c> clientStatusToUpdate = new List<SymphonyLF__Client__c>();

        List<Asset_Intake_Form__c> forms = [
            SELECT Id
                , Status__c
                , New_Patent_Family__c
                , Patent_Family__c
                , Client__c
                , Client__r.Client_Status__c
                , Conflict_Check__c
                , New_Mark_Title__c
                , Mark_Type__c
                , Mark__c
                , Image_ContentVersion__c
                , Department__c
            FROM Asset_Intake_Form__c
            WHERE Id =: intakeId LIMIT 1
        ];

        for(Asset_Intake_Form__c form : forms){

            if(form.Client__r.Client_Status__c == 'Yet to Engage'){
                SymphonyLF__Client__c cli = new SymphonyLF__Client__c();
                cli.Id = form.Client__c;
                cli.Client_Status__c = 'Active';

                clientStatusToUpdate.add(cli);
            }
           
        }

         if(clientStatusToUpdate.size() > 0){
            update clientStatusToUpdate;
        }

        List<SymphonyLF__Client__c> createdClients = createAssociatedClient(intakeId, clientId);
        List<SymphonyLF__Person__c> createdInnovators = createClientInnovators(intakeId, clientId);

        System.debug(forms + '<<<:::forms');
        if(!String.isBlank(forms[0].New_Patent_Family__c)){
            System.debug('CreatePatentRecords:::>>>  ENTERED' );
            CreatePatentRecords.createRecords( forms );
        }else if(!String.isBlank(forms[0].Mark__c) || !String.isBlank(forms[0].New_Mark_Title__c)){
            System.debug('CreateTrademarkRecords:::>>>  ENTERED' );
            CreateTrademarkRecords.createRecords( forms );
        }
        

        List<Conflict_Check__c> conflictChecksToUpdate = new List<Conflict_Check__c>();

        for(Asset_Intake_Form__c form : forms){
            form.Status__c = 'Submitted';

            if( form.Conflict_Check__c != null){
                Conflict_Check__c cc = new Conflict_Check__c();
                cc.Id = form.Conflict_Check__c;
                cc.CC_Status__c = 'Matter Created';
    
                conflictChecksToUpdate.add(cc);
            } 

        }

        update forms;

        if(conflictChecksToUpdate.size() > 0){
            update conflictChecksToUpdate;
        }

        List<SymphonyLF__Patent_Family__c> newFamilyRecords = CreatePatentRecords.intakeFormNewPatentFamilyMap.values();
        List<SymphonyLF__Patent__c> newRecords = CreatePatentRecords.patentRecords.values();

        //Added for MARK and TRADEMARK
        //TO BE MADE DYNAMIC ???
        List<SymphonyLF__Mark__c> newMarkRecords = createTrademarkRecords.intakeFormNewPatentFamilyMap.values();
        List<SymphonyLF__Trademark__c> newTrademarkRecords = new List<SymphonyLF__Trademark__c>();//createTrademarkRecords.patentRecords.values();
        if(!createTrademarkRecords.patentRecords.isEmpty()){
            newTrademarkRecords = createTrademarkRecords.patentRecords.values();
         }
         if(!createTrademarkRecords.patentRecordsList.isEmpty()){
             for(String key : createTrademarkRecords.patentRecordsList.keyset()){
                 newTrademarkRecords.addAll(createTrademarkRecords.patentRecordsList.get(key));
             }
         }
        

        Set<Id> newMatterFamilyIds = new Set<Id>();
        for(SymphonyLF__Patent_Family__c record : newFamilyRecords){
            newMatterFamilyIds.add( record.Id );
        }

        //Added for MARK and TRADEMARK
        for(SymphonyLF__Mark__c record : newMarkRecords){
            newMatterFamilyIds.add( record.Id );
        }
        
        Set<Id> newMatterIds = new Set<Id>();
        for(SymphonyLF__Patent__c record : newRecords){
            newMatterIds.add( record.Id );
        }
        for(SymphonyLF__Trademark__c record : newTrademarkRecords){
            newMatterIds.add( record.Id );
        }
        System.debug('newMatterIds' + newMatterIds);

        if(newMatterFamilyIds.size() > 0){
            List<sObject> newFamilyMatters = Database.query(' SELECT Id, Name, SymphonyLF__Docket_Number__c FROM SymphonyLF__Patent_Family__c WHERE Id = :newMatterFamilyIds ');
            for(sObject record : newFamilyMatters){
                MattersWrapper matterWrapper = new MattersWrapper();

                matterWrapper.recordId = (Id) record.get('Id');
                //matterWrapper.docketNumber = (String) record.get('SymphonyLF__Docket_Number__c');
                matterWrapper.title = (String) record.get('Name'); 
                matterWrapper.label = 'Patent Family';
                matterWrapper.familyStatus = 'Live';

                output.add(matterWrapper);
            }
        }

        if(newMatterFamilyIds.size() > 0){
            List<sObject> newFamilyMatters = Database.query(' SELECT Id, Name, SymphonyLF__Docket_Number__c FROM SymphonyLF__Mark__c WHERE Id = :newMatterFamilyIds ');
            for(sObject record : newFamilyMatters){
                MattersWrapper matterWrapper = new MattersWrapper();

                matterWrapper.recordId = (Id) record.get('Id');
                matterWrapper.docketNumber = (String) record.get('SymphonyLF__Docket_Number__c');
                matterWrapper.title = (String) record.get('Name'); 
                matterWrapper.familyStatus = 'Live';
                matterWrapper.label = 'Mark';

                output.add(matterWrapper);
            }
        }
        
        Set<String> matterFields = new Set<String>{
            'Id',
            'Name',
            'SymphonyLF__Docket_Number__c',
            'SymphonyLF__Case_Type__c',
            'SymphonyLF__Country__r.Name'
        };
        Set<String> tmMatterFields = new Set<String>{
            'Id',
            'Name',
            'SymphonyLF__Docket_Number__c',
            'SymphonyLF__Case_Type__c',
            'SymphonyLF__Jurisdiction__r.Name'
        };
        
        List<sObject> newMatters = Database.query(' SELECT ' + String.join(matterFields, ', ') + '  FROM SymphonyLF__Patent__c WHERE Id = :newMatterIds ');
        List<sObject> newTMMatters = Database.query(' SELECT ' + String.join(tmMatterFields, ', ') + '  FROM SymphonyLF__Trademark__c WHERE Id = :newMatterIds ');

        
        if(newMatters.size() > 0){
            for(sObject record : newMatters){
                MattersWrapper matterWrapper = new MattersWrapper();


                matterWrapper.recordId = (Id) record.get('Id');
                matterWrapper.docketNumber = (String) record.get('SymphonyLF__Docket_Number__c');
                matterWrapper.title = (String) record.get('Name'); 
                matterWrapper.caseType = (String) record.get('SymphonyLF__Case_Type__c'); 
                matterWrapper.jurisdiction = (String) record.getSObject('SymphonyLF__Country__r').get('Name'); 
                matterWrapper.label = 'Patent'; 

                output.add(matterWrapper);
            }
        }

        if(newTMMatters.size() > 0){
            for(sObject record : newTMMatters){
                MattersWrapper matterWrapper = new MattersWrapper();


                matterWrapper.recordId = (Id) record.get('Id');
                matterWrapper.docketNumber = (String) record.get('SymphonyLF__Docket_Number__c');
                matterWrapper.title = (String) record.get('Name'); 
                matterWrapper.caseType = (String) record.get('SymphonyLF__Case_Type__c'); 
                matterWrapper.jurisdiction = (String) record.getSObject('SymphonyLF__Jurisdiction__r').get('Name'); 
                matterWrapper.label = 'Trademark'; 

                output.add(matterWrapper);
            }
        }
            // List<SymphonyLF__Client__c> createdClients = createAssociatedClient(intakeId, clientId);
            // List<SymphonyLF__Person__c> createdInnovators = createClientInnovators(intakeId, clientId);

        return output;
    }catch (Exception e) {
        System.debug('e.getMessage() ' + e.getMessage()+'  line no. : '+e.getLineNumber() );
        throw new AuraHandledException('Caught Exception: ' + e.getMessage()+'  line no. : '+e.getLineNumber());
    }
    }

  public static List<SymphonyLF__Client__c> createAssociatedClient(Id assetIntakeFormId, Id clientId) {
    
    List<mvWrapper.ApplicantsWrapper> applicants = getApplicants(assetIntakeFormId, clientId, false, true); 
    List<SymphonyLF__Client__c> associatedClients = new List<SymphonyLF__Client__c>();
    List<Asset_Intake_Applicants__c> applicantsToUpdate = new List<Asset_Intake_Applicants__c>();

    for (mvWrapper.ApplicantsWrapper applicant : applicants) {
        String applicantId = applicant.applicantId;
        String name = applicant.name;
        String clientClassification = applicant.clientClassification;
        String currencyCode = applicant.currencyCode;
        String currencyId = applicant.currencyId;
        String entitySize = applicant.entitySize;
        String isExistingApplicant = applicant.isExistingApplicant;
        Boolean isSelected = applicant.isSelected;
        String recordId = applicant.recordId;
        String recordName = applicant.recordName;
        String street = applicant.street;
        String city = applicant.city;
        String stateCode = applicant.stateCode;
        String postal = applicant.postal;
        String countryCode = applicant.countryCode;

        if(applicant.isExistingApplicant != 'Existing'){
        SymphonyLF__Client__c newClient = new SymphonyLF__Client__c(
            SymphonyLF__Client_Classification__c = clientClassification,  
            SymphonyLF__Default_Billing_Currency__c = currencyId,         
            SymphonyLF__Entity_Size__c = entitySize,                    
            Is_Default__c = false,                                        
            Name = name,                                                   
            SymphonyLF__Client__c = clientId,
            Client_Status__c = 'Active',
            SymphonyLF__Address__Street__s = street,
            SymphonyLF__Address__City__s = city,
            SymphonyLF__Address__StateCode__s = stateCode,
            SymphonyLF__Address__PostalCode__s = postal,
            SymphonyLF__Address__CountryCode__s = countryCode                             
        );

        associatedClients.add(newClient);
        }
    }

    if (!associatedClients.isEmpty()) {
        insert associatedClients;
        List<String> clientIds = new List<String>();
            for (SymphonyLF__Client__c client : associatedClients) {
                clientIds.add(client.Id);
            }
            Integer insertedClientIndex = 0;
            for (Integer i = 0; i < applicants.size(); i++) {
            mvWrapper.ApplicantsWrapper applicant = applicants[i];
            if (applicant.isExistingApplicant != 'Existing') {
                Asset_Intake_Applicants__c applicantRecord = new Asset_Intake_Applicants__c(
                    Id = applicant.recordId,  
                    Applicant__c = clientIds[insertedClientIndex] 
                );
                applicantsToUpdate.add(applicantRecord);
                insertedClientIndex++ ; 
            }
        }
        if (!applicantsToUpdate.isEmpty()) {
            update applicantsToUpdate;
        }
    }

    return associatedClients;
}

    public static List<SymphonyLF__Person__c> createClientInnovators(Id assetIntakeFormId, Id clientId){
        List<mvWrapper.InventorsWrapper> innovatorsList = getInventors(assetIntakeFormId, clientId, true);
        List<SymphonyLF__Person__c> associatedInnovators = new List<SymphonyLF__Person__c>();
        List<Asset_Intake_Inventor__c> inventorsToUpdate = new List<Asset_Intake_Inventor__c>();
        //Id innovatorRecordTypeId = Schema.getGlobalDescribe().get('SymphonyLF__Person__c').getRecordTypeInfosByDeveloperName().get('Innovator').getRecordTypeId();
        Id innovatorRecordTypeId = Schema.sObjectType.SymphonyLF__Person__c.getRecordTypeInfosByDeveloperName().get('Innovator').getRecordTypeId();

        for(mvWrapper.InventorsWrapper inventor :innovatorsList){
         if (inventor.isExistingInventor != 'Existing'){
         SymphonyLF__Person__c newPerson = new SymphonyLF__Person__c(
            Name = inventor.inventorName,       
            SymphonyLF__Email__c = inventor.emailAddress,            
            SymphonyLF__Phone_Number__c = inventor.phoneNumber,      
            SymphonyLF__Nationality__c = inventor.nationality,        
            SymphonyLF__Client__c = clientId,
            SymphonyLF__Type__c = 'Client',
            SymphonyLF__Contact_Type__c = 'Inventor',
            RecordTypeId = innovatorRecordTypeId,
            SymphonyLF__Address__Street__s = inventor.street,
            SymphonyLF__Address__City__s = inventor.city,
            SymphonyLF__Address__StateCode__s = inventor.stateCode,
            SymphonyLF__Address__PostalCode__s = inventor.postal,
            SymphonyLF__Address__CountryCode__s = inventor.countryCode                 
        );

         associatedInnovators.add(newPerson);
         }
    }
        if (!associatedInnovators.isEmpty()) {
            insert associatedInnovators;

            List<String> personIds = new List<String>();
            for (SymphonyLF__Person__c person : associatedInnovators) {
                personIds.add(person.Id);
            }
            Integer personIndex = 0;
            for (Integer i = 0; i < innovatorsList.size(); i++) {
            mvWrapper.InventorsWrapper inventor = innovatorsList[i];
            if (inventor.isExistingInventor != 'Existing') {
                Asset_Intake_Inventor__c inventorRecord = new Asset_Intake_Inventor__c(
                    Id = inventor.recordId,  
                    Person__c = personIds[personIndex] 
                );
                inventorsToUpdate.add(inventorRecord);
                personIndex++;
            }
        }
         if (!inventorsToUpdate.isEmpty()) {
            update inventorsToUpdate;
        }

        }
    
        return associatedInnovators;
    }

    @AuraEnabled
    public static void createDocketActivity(String data){
        Map<String, Object> symphonyRow = (Map<String, Object>)JSON.deserializeUntyped(data);

        sObject docketActivity = (sObject) Type.forName('SymphonyLF__Docketing_Activity__c').newInstance();

        for(String field : symphonyRow.keySet()){
            String val = String.valueOf( symphonyRow.get(field) );

            if(String.isBlank(val) || String.isEmpty(val)){
                continue;
            }

            if(field == 'SymphonyLF__Event_Date__c' || field == 'SymphonyLF__Due_Date__c'){
                docketActivity.put(field, Date.valueOf( String.valueOf( symphonyRow.get(field) ) ) );
            }
            else{
                docketActivity.put(field, symphonyRow.get(field));
            }
            
        }

        insert docketActivity;
    }
}