public with sharing class PatentIntakeFormNewHelper {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPicklistValues() {
        Map<String, Object> response = new Map<String, Object>();

        Set<String> clientFieldsToFetch = new Set<String>{
            'SymphonyLF__Client_Classification__c',
            'SymphonyLF__Entity_Size__c'
        };

        List<Object> clientFieldData = new List<Object>();
        Map<String, Schema.SObjectField> clientFieldMap = Schema.SObjectType.SymphonyLF__Client__c.fields.getMap();
        for (String fieldName : clientFieldsToFetch) {
            if (clientFieldMap.containsKey(fieldName)) {
                Schema.DescribeFieldResult fieldDescribe = clientFieldMap.get(fieldName).getDescribe();
                if (fieldDescribe.isFilterable()) {
                    Map<String, Object> fieldMap = new Map<String, Object>{
                        'label' => fieldDescribe.getLabel(),
                        'value' => fieldDescribe.getName(),
                        'dataType' => fieldDescribe.getType().name(),
                        'isMultiSelect' => fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST
                    };
                    if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST || fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST) {
                        List<Object> picklistValues = new List<Object>();
                        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                            picklistValues.add(new Map<String, String>{
                                'label' => entry.getLabel(),
                                'value' => entry.getValue()
                            });
                        }
                        fieldMap.put('picklistValues', picklistValues);
                    }
                    clientFieldData.add(fieldMap);
                }
            }
        }
        response.put('clientFields', clientFieldData);

        List<Object> personFieldData = new List<Object>();
        String nationalityFieldName = 'SymphonyLF__Nationality__c';
        Map<String, Schema.SObjectField> personFieldMap = Schema.SObjectType.SymphonyLF__Person__c.fields.getMap();
        if (personFieldMap.containsKey(nationalityFieldName)) {
            Schema.DescribeFieldResult fieldDescribe = personFieldMap.get(nationalityFieldName).getDescribe();
            if (fieldDescribe.isFilterable()) {
                Map<String, Object> fieldMap = new Map<String, Object>{
                    'label' => fieldDescribe.getLabel(),
                    'value' => fieldDescribe.getName(),
                    'dataType' => fieldDescribe.getType().name(),
                    'isMultiSelect' => fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST
                };
                if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST || fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    List<Object> picklistValues = new List<Object>();
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        picklistValues.add(new Map<String, String>{
                            'label' => entry.getLabel(),
                            'value' => entry.getValue()
                        });
                    }
                    fieldMap.put('picklistValues', picklistValues);
                }
                personFieldData.add(fieldMap);
            }
        }
        response.put('personFields', personFieldData);

        List<Object> patentFieldData = new List<Object>();
        String caseTypeFieldName = 'SymphonyLF__Case_Type__c';
        Map<String, Schema.SObjectField> patentFieldMap = Schema.SObjectType.SymphonyLF__Patent__c.fields.getMap();
        if (patentFieldMap.containsKey(caseTypeFieldName)) {
            Schema.DescribeFieldResult fieldDescribe = patentFieldMap.get(caseTypeFieldName).getDescribe();
            if (fieldDescribe.isFilterable()) {
                Map<String, Object> fieldMap = new Map<String, Object>{
                    'label' => fieldDescribe.getLabel(),
                    'value' => fieldDescribe.getName(),
                    'dataType' => fieldDescribe.getType().name(),
                    'isMultiSelect' => fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST
                };
                if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST || fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    List<Object> picklistValues = new List<Object>();
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        picklistValues.add(new Map<String, String>{
                            'label' => entry.getLabel(),
                            'value' => entry.getValue()
                        });
                    }
                    fieldMap.put('picklistValues', picklistValues);
                }
                patentFieldData.add(fieldMap);
            }
        }
        response.put('patentFields', patentFieldData);

        return response;
    }


    @AuraEnabled(cacheable=false)
    public static Response savePatentFamilyAndEngagements(String jsonString) {
        Savepoint sp = Database.setSavepoint();
        Response response = new Response();

        try {
            if (String.isNotBlank(jsonString)) {
                System.debug('Input JSON: ' + jsonString);

                recordWrapper wrapperRecord = (recordWrapper) JSON.deserialize(jsonString, recordWrapper.class);
                ID patentFamilyID;
                Boolean isExistingFamily = wrapperRecord.patentFamilyId != null;

                System.debug('isExistingFamily:'+isExistingFamily);
                // Create or update the patent family
                SymphonyLF__Patent_Family__c patentFamily;
                if (isExistingFamily) {
                    // Update existing patent family
                    patentFamily = [
                        SELECT Id, Name, SymphonyLF__Invention_Title__c, SymphonyLF__Client__c
                        FROM SymphonyLF__Patent_Family__c
                        WHERE Id = :wrapperRecord.patentFamilyId
                        LIMIT 1
                    ];
                    patentFamily.Name = wrapperRecord.shortTitle;
                    patentFamily.SymphonyLF__Invention_Title__c = wrapperRecord.inventionTitle;
                    patentFamily.SymphonyLF__Client__c = wrapperRecord.clientId;
                    update patentFamily;
                    patentFamilyID = patentFamily.Id;
                } else {
                    // Create new patent family
                    patentFamily = new SymphonyLF__Patent_Family__c(
                        Name = wrapperRecord.shortTitle,
                        SymphonyLF__Invention_Title__c = wrapperRecord.inventionTitle,
                        SymphonyLF__Client__c = wrapperRecord.clientId,
                        SymphonyLF__Active__c = true
                    );
                    insert patentFamily;
                    patentFamilyID = patentFamily.Id;
                }

                // Create new engagement models
                List<SymphonyLF__Matter_Engagement_Model__c> engagementModelsToInsert = new List<SymphonyLF__Matter_Engagement_Model__c>();
                if (wrapperRecord.engagementDetails != null) {
                    for (Map<String, Object> engagementDetail : wrapperRecord.engagementDetails) {
                        // Skip creation if memId is already provided
                        if (engagementDetail.get('memId') != null && String.valueOf(engagementDetail.get('memId')).trim() != '') {
                            continue;
                        }
                        SymphonyLF__Matter_Engagement_Model__c engagementModel = new SymphonyLF__Matter_Engagement_Model__c(
                            SymphonyLF__Client__c = wrapperRecord.clientId,
                            SymphonyLF__Patent_Family__c = patentFamilyID,
                            SymphonyLF__Type__c = (String) engagementDetail.get('type')
                        );
                        if (((String) engagementDetail.get('type')) == 'Foreign Associate') {
                            engagementModel.SymphonyLF__Office_Agent__c = (Id) engagementDetail.get('personId');
                        } else {
                            engagementModel.SymphonyLF__Supervisor_Client_Contact__c = (Id) engagementDetail.get('personId');
                        }
                        engagementModelsToInsert.add(engagementModel);
                    }
                }

                // Delete removed engagement models
                if (wrapperRecord.deletedEngagementDetails != null && !wrapperRecord.deletedEngagementDetails.isEmpty()) {
                    List<SymphonyLF__Matter_Engagement_Model__c> engagementModelsToDelete = [
                        SELECT Id
                        FROM SymphonyLF__Matter_Engagement_Model__c
                        WHERE Id IN :wrapperRecord.deletedEngagementDetails
                    ];
                    if (!engagementModelsToDelete.isEmpty()) {
                        delete engagementModelsToDelete;
                    }
                }

                // Insert new engagement models
                if (!engagementModelsToInsert.isEmpty()) {
                    insert engagementModelsToInsert;
                }

                // Retrieve all updated engagement models linked to the patent family
                List<SymphonyLF__Matter_Engagement_Model__c> updatedEngagementModels = [
                    SELECT Id, SymphonyLF__Type__c, SymphonyLF__Office_Agent__c, SymphonyLF__Supervisor_Client_Contact__c
                    FROM SymphonyLF__Matter_Engagement_Model__c
                    WHERE SymphonyLF__Patent_Family__c = :patentFamilyID
                ];

                // Build response with patent family and updated engagement models
                List<Map<String, Object>> engagementDetails = new List<Map<String, Object>>();
                for (SymphonyLF__Matter_Engagement_Model__c engagementModel : updatedEngagementModels) {
                    engagementDetails.add(new Map<String, Object>{
                        'memId' => engagementModel.Id,
                        'contactRecordId' => engagementModel.SymphonyLF__Supervisor_Client_Contact__c != null 
                                            ? engagementModel.SymphonyLF__Supervisor_Client_Contact__c 
                                            : engagementModel.SymphonyLF__Office_Agent__c,
                        'type'=> engagementModel.SymphonyLF__Type__c
                        
                    });
                }

                response.Status = true;
                response.PatentFamilyID = patentFamilyID;
                response.engagementDetails = engagementDetails; 
            } else {
                throw new AuraHandledException('Invalid input data.');
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            Database.rollback(sp);
            response.Status = false;
            response.message = e.getMessage();
        }

        return response;
    }


    @AuraEnabled(cacheable=true)
    public static List<SymphonyLF__Client__c> searchApplicants(String searchTerm, String clientGroupNumber, List<Id> excludedApplicantIds) {
        try {
            List<SymphonyLF__Client__c> applicants = [
                SELECT Id, Name, SymphonyLF__Address__c ,Email__c
                FROM SymphonyLF__Client__c 
                WHERE SymphonyLF__Client_Group_Number__c = :clientGroupNumber 
                AND SymphonyLF__Client_Classification__c INCLUDES ('Applicant')
                AND Name LIKE :('%' + searchTerm + '%')
                AND Id NOT IN :excludedApplicantIds
                LIMIT 100
            ];
            return applicants;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new List<SymphonyLF__Client__c>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SymphonyLF__Person__c> searchInventors(String searchTerm, string clientId, List<Id> excludedInventorIds) {
        try {
            List<SymphonyLF__Person__c> inventors= [
                SELECT Name,SymphonyLF__Contact_Type__c,SymphonyLF__Email__c,SymphonyLF__Address__c 
                FROM SymphonyLF__Person__c 
                WHERE SymphonyLF__Contact_Type__c='Inventor' 
                AND SymphonyLF__Client__c=:clientId
                AND Name LIKE :('%' + searchTerm + '%')
                AND Id NOT IN :excludedInventorIds
                LIMIT 100
                ];
            return inventors;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new List<SymphonyLF__Person__c>();
        }
    }

    @AuraEnabled
    public static List<ClientResultWrapper> createNewClients(String newClientsJson) {
        List<ClientInputWrapper> inputList = 
            (List<ClientInputWrapper>) JSON.deserialize(newClientsJson, List<ClientInputWrapper>.class);
        List<SymphonyLF__Client__c> clientsToInsert = new List<SymphonyLF__Client__c>();
        
        for (ClientInputWrapper ci : inputList) {
            SymphonyLF__Client__c cl = new SymphonyLF__Client__c();
            cl.Name = ci.name;
            cl.SymphonyLF__Client_Classification__c = ci.classification;
            cl.SymphonyLF__Entity_Size__c = ci.entitySize;
            try {
                cl.SymphonyLF__Default_Billing_Currency__c = ID.valueOf(ci.defaultCurrency);
            } catch (Exception ex) {
                System.debug('error occured:'+ex);
            }
            cl.SymphonyLF__Active__c = false;//make true after submit
            cl.Client_Status__c = 'Active';
            
            if (ci.address != null) {
                cl.SymphonyLF__Address__Street__s = ci.address.street;
                cl.SymphonyLF__Address__City__s = ci.address.city;
                cl.SymphonyLF__Address__StateCode__s = ci.address.state;
                cl.SymphonyLF__Address__CountryCode__s = ci.address.country;
                cl.SymphonyLF__Address__PostalCode__s = ci.address.postalCode;
            }
            clientsToInsert.add(cl);
        }
        
        insert clientsToInsert;
        
        List<ClientResultWrapper> results = new List<ClientResultWrapper>();
        for (Integer i = 0; i < clientsToInsert.size(); i++) {
            SymphonyLF__Client__c c = clientsToInsert[i];
            ClientInputWrapper ci = inputList[i]; 
            ClientResultWrapper res = new ClientResultWrapper();
            res.tempId = ci.tempId;
            res.id = c.Id;
            res.name = c.Name;
            AddressWrapper aw = new AddressWrapper();
            aw.street = c.SymphonyLF__Address__Street__s;
            aw.city = c.SymphonyLF__Address__City__s;
            aw.state = c.SymphonyLF__Address__StateCode__s;
            aw.country = c.SymphonyLF__Address__CountryCode__s;
            aw.postalCode = c.SymphonyLF__Address__PostalCode__s;
            res.address = aw;
            results.add(res);
        }
        return results;
    }

    @AuraEnabled
    public static List<ChainResultWrapper> createChainOfTitleRecords(String chainRecordsJson, 
                                                                       List<String> deletedChainOfTitlesIds, 
                                                                       String patentFamilyID) {
        
        List<ChainRecordWrapper> chainList = 
            (List<ChainRecordWrapper>) JSON.deserialize(chainRecordsJson, List<ChainRecordWrapper>.class);
        
        
        List<SymphonyLF__Chain_of_Title__c> chainsToInsert = new List<SymphonyLF__Chain_of_Title__c>();
        
        
        for (ChainRecordWrapper cr : chainList) {
            SymphonyLF__Chain_of_Title__c chainRec = new SymphonyLF__Chain_of_Title__c();
            chainRec.SymphonyLF__Client__c = cr.clientId;
            chainRec.SymphonyLF__Role__c = 'Applicant';
            chainRec.SymphonyLF__Current__c = true;
            chainRec.SymphonyLF__Patent_Family__c = patentFamilyID;
            chainRec.SymphonyLF__Registered_Applicant__c = cr.Name;
            
            if (cr.addressedit != null) {
                chainRec.SymphonyLF__Address__City__s = cr.addressedit.city;
                if (cr.addressedit.countryCode != null && cr.addressedit.countryCode.trim().length() > 0) {
                    chainRec.SymphonyLF__Address__CountryCode__s = cr.addressedit.countryCode;
                } else {
                    chainRec.SymphonyLF__Address__CountryCode__s = cr.addressedit.country;
                }
                if (cr.addressedit.stateCode != null && cr.addressedit.stateCode.trim().length() > 0) {
                    chainRec.SymphonyLF__Address__StateCode__s = cr.addressedit.stateCode;
                } else{
                    chainRec.SymphonyLF__Address__StateCode__s = cr.addressedit.province;
                }
                chainRec.SymphonyLF__Address__Street__s = cr.addressedit.street;
                chainRec.SymphonyLF__Address__PostalCode__s = cr.addressedit.postalCode;
            }
            chainsToInsert.add(chainRec);
        }
        
        
        insert chainsToInsert;
        
        if (deletedChainOfTitlesIds != null && !deletedChainOfTitlesIds.isEmpty()) {
            List<SymphonyLF__Chain_of_Title__c> chainsToDelete = 
                [SELECT Id FROM SymphonyLF__Chain_of_Title__c WHERE Id IN :deletedChainOfTitlesIds];
            delete chainsToDelete;
        }
        
        
        List<ChainResultWrapper> resultList = new List<ChainResultWrapper>();
        for (SymphonyLF__Chain_of_Title__c chainRec : chainsToInsert) {
            ChainResultWrapper res = new ChainResultWrapper();
            res.clientId = chainRec.SymphonyLF__Client__c;
            res.chainId = chainRec.id;
            resultList.add(res);
        }
        return resultList;
    }
    

    @AuraEnabled
    public static List<PersonResultWrapper> createNewPersons(String newPersonsJson) {
        List<PersonInputWrapper> inputList = (List<PersonInputWrapper>) 
            JSON.deserialize(newPersonsJson, List<PersonInputWrapper>.class);
        List<SymphonyLF__Person__c> personsToInsert = new List<SymphonyLF__Person__c>();
        
        for (PersonInputWrapper pi : inputList) {
            SymphonyLF__Person__c p = new SymphonyLF__Person__c();
            p.Name = pi.personName;
            p.SymphonyLF__Client__c = pi.clientId;
            p.SymphonyLF__User__c = pi.user;
            p.SymphonyLF__Contact_Type__c = pi.contactType;
            p.SymphonyLF__Type__c = pi.Type;
            p.RecordTypeId = pi.recordTypeId;
            p.SymphonyLF__Nationality__c = pi.nationality;
            p.SymphonyLF__Email__c = pi.emailAddress;
            p.SymphonyLF__Phone_Number__c = pi.phone;
            p.SymphonyLF__Active__c = false;//true after submit the form
            
            if (pi.inventorAddress != null) {
                p.SymphonyLF__Address__Street__s = pi.inventorAddress.street;
                p.SymphonyLF__Address__City__s = pi.inventorAddress.city;
                p.SymphonyLF__Address__StateCode__s = pi.inventorAddress.state;
                p.SymphonyLF__Address__CountryCode__s = pi.inventorAddress.country;
                p.SymphonyLF__Address__PostalCode__s = pi.inventorAddress.postalCode;
            }
            personsToInsert.add(p);
        }
        
        insert personsToInsert;
        
        List<PersonResultWrapper> results = new List<PersonResultWrapper>();
        for (Integer i = 0; i < personsToInsert.size(); i++) {
            SymphonyLF__Person__c p = personsToInsert[i];
            PersonInputWrapper pi = inputList[i];
            
            PersonResultWrapper res = new PersonResultWrapper();
            res.tempId = pi.tempId;
            res.id = p.Id;
            res.personName = p.Name;
            res.emailAddress = p.SymphonyLF__Email__c;
            
            AddressWrapper aw = new AddressWrapper();
            aw.street = p.SymphonyLF__Address__Street__s;
            aw.city = p.SymphonyLF__Address__City__s;
            aw.state = p.SymphonyLF__Address__StateCode__s;
            aw.country = p.SymphonyLF__Address__CountryCode__s;
            aw.postalCode = p.SymphonyLF__Address__PostalCode__s;
            res.address = aw;
            
            results.add(res);
        }
        
        return results;
    }

    @AuraEnabled
    public static List<SymphonyLF__Inventor_Designer_Author__c> createPatentInventors(String patentFamilyId, String inventorsJson, List<Id> deletedInventorDesignerIds) {
        if (String.isBlank(patentFamilyId)) {
            throw new AuraHandledException('Patent Family ID cannot be blank.');
        }
        if (String.isBlank(inventorsJson)) {
            throw new AuraHandledException('Inventors data (JSON) cannot be blank.');
        }

        List<InventorWrapper> inventorList = (List<InventorWrapper>) JSON.deserialize(inventorsJson, List<InventorWrapper>.class);
        if (inventorList.isEmpty()) {
            return new List<SymphonyLF__Inventor_Designer_Author__c>();
        }

        if (deletedInventorDesignerIds != null && !deletedInventorDesignerIds.isEmpty()) {
            List<SymphonyLF__Inventor_Designer_Author__c> toDelete = [
                SELECT Id
                FROM SymphonyLF__Inventor_Designer_Author__c
                WHERE Id IN :deletedInventorDesignerIds
            ];
            if (!toDelete.isEmpty()) {
                delete toDelete;
            }
        }

        List<SymphonyLF__Inventor_Designer_Author__c> toUpsert = new List<SymphonyLF__Inventor_Designer_Author__c>();
        for (InventorWrapper inv : inventorList) {
            SymphonyLF__Inventor_Designer_Author__c record = new SymphonyLF__Inventor_Designer_Author__c();
            
            if (!String.isBlank(inv.existingRecId)) {
                record.Id = inv.existingRecId;
            }
            
            record.SymphonyLF__Patent_Family__c = patentFamilyId;
            record.SymphonyLF__Contact__c = inv.contactId;
            record.SymphonyLF__Type__c = 'Inventor';
            
            if (inv.primary != null) {
                record.SymphonyLF__Primary_Inventor__c = inv.primary;
            }
            if (inv.sequence != null) {
                record.Sequence__c = inv.sequence;
            }

            toUpsert.add(record);
        }

        upsert toUpsert;

        return toUpsert;
    }

    @AuraEnabled(cacheable=true)
    public static ExistingPatentFamilyDetailsWrapper getExistingPatentFamilyDetails(String recordId) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('Record ID cannot be blank.');
        }
        
        ExistingPatentFamilyDetailsWrapper wrapper = new ExistingPatentFamilyDetailsWrapper();
        
        wrapper.patentFamily = [
            SELECT Id,
                   SymphonyLF__Invention_Title__c,
                   SymphonyLF__Docket_Number__c,
                   SymphonyLF__Family_Status__c,
                   Name,
                   SymphonyLF__Family_ID__c,
                   Intake_Form_DraftedAt__c
            FROM SymphonyLF__Patent_Family__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        
        wrapper.engagements = [
            SELECT Id,
                   SymphonyLF__Type__c,
                   SymphonyLF__Supervisor_Client_Contact__c,SymphonyLF__Supervisor_Client_Contact__r.Name
            FROM SymphonyLF__Matter_Engagement_Model__c
            WHERE SymphonyLF__Patent_Family__c = :recordId
        ];

        wrapper.chainRecords = [
            SELECT Id,
                   Name,
                   SymphonyLF__Client__c,
                   SymphonyLF__Registered_Applicant__c,
                   SymphonyLF__Address__c
            FROM SymphonyLF__Chain_of_Title__c
            WHERE SymphonyLF__Patent_Family__c = :recordId
        ];
        
        wrapper.inventors =[
            SELECT Id,
                   SymphonyLF__Contact__c,
                   SymphonyLF__Contact__r.Name,
                   SymphonyLF__Contact__r.SymphonyLF__Email__c,
                   SymphonyLF__Contact__r.SymphonyLF__Address__c,
                   SymphonyLF__Primary_Inventor__c,
                   Sequence__c
            FROM SymphonyLF__Inventor_Designer_Author__c 
            WHERE SymphonyLF__Patent_Family__c = :recordId
        ];


        return wrapper;
    }

    @AuraEnabled(cacheable=false)
    public static void updateIntakeFormDraftedAt(String patentFamilyId, String intakeFormDraftedAt) {
        if (String.isBlank(patentFamilyId)) {
            throw new AuraHandledException('Patent Family Id cannot be blank.');
        }
        
        SymphonyLF__Patent_Family__c pf = [
            SELECT Id, Intake_Form_DraftedAt__c 
            FROM SymphonyLF__Patent_Family__c 
            WHERE Id = :patentFamilyId 
            LIMIT 1
        ];
        pf.Intake_Form_DraftedAt__c = intakeFormDraftedAt;
        update pf;
    }

    @AuraEnabled(cacheable=true)
    public static JurisdictionDetail getJurisdictionDetail(String clientId) {
        JurisdictionDetail jurisdictionDetail = new JurisdictionDetail();
        String auditLog = ''; 
        Boolean status;
        
        if(String.isBlank(clientId)) {
            throw new AuraHandledException('Client Id cannot be blank.');
        }
        
        try {
            List<SymphonyLF__Client_Jurisdiction_Group__c> jurisdictionGroup = [
                SELECT Name, Id, SymphonyLF__Jurisdiction_Group_Name_Hyperlink__c  
                FROM SymphonyLF__Client_Jurisdiction_Group__c 
                WHERE SymphonyLF__Client__c = :clientId
            ];
            
            List<SymphonyLF__Country__c> country = [
                SELECT SymphonyLF__Country_Code__c, Name, Id 
                FROM SymphonyLF__Country__c 
                WHERE SymphonyLF__Active__c = true  
             //   ORDER BY Sort_Order__c ASC NULLS LAST, Name ASC
            ];
            
            jurisdictionDetail.jurisdictionGroup = jurisdictionGroup;
            jurisdictionDetail.jurisdictions = country;
        } catch (Exception e) {
           
            throw new AuraHandledException('Error retrieving jurisdiction details.');
        }
        
        return jurisdictionDetail;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> DynamicQueryRecords(String query){
        System.debug('Js Query: '+query);
        List<SObject> recList = Database.Query(query);
        return recList;
    }


    @AuraEnabled
    public static Map<String, Object> createPatentRecordForJurisdiction(
        Id clientId,
        Id patentFamilyId,
        String patentFamilyShortTitle,
        String patentFamilyTitle,
        String defaultCaseTypeValue,
        Id defaultUSJurisdictionId,
        List<Map<String, Object>> selectedEngagementDetails,
        List<Map<String, Object>> applicantData,
        List<Map<String, Object>> inventorData
    ) {
        //  Create the Patent record
        SymphonyLF__Patent__c mainPatent = new SymphonyLF__Patent__c();
        mainPatent.SymphonyLF__Case_Type__c       = defaultCaseTypeValue;
        mainPatent.SymphonyLF__Client__c            = clientId;
        mainPatent.SymphonyLF__Country__c           = defaultUSJurisdictionId;
        mainPatent.Name                             = patentFamilyShortTitle;
        mainPatent.SymphonyLF__Patent_Family__c     = patentFamilyId;
        mainPatent.SymphonyLF__Title__c             = patentFamilyTitle;
        mainPatent.SymphonyLF__Patent_Status__c     = 'Application Preparation';
        mainPatent.SymphonyLF__Active__c            = false;
        insert mainPatent;
        
        //  Create Matter Engagement Model (MEM) records
        List<SymphonyLF__Matter_Engagement_Model__c> memList = new List<SymphonyLF__Matter_Engagement_Model__c>();
        for (Map<String, Object> eng : selectedEngagementDetails) {
            SymphonyLF__Matter_Engagement_Model__c mem = new SymphonyLF__Matter_Engagement_Model__c();
            mem.SymphonyLF__Client__c = clientId;
            String type = (String) eng.get('type');
            Id contactRecordId = (Id) eng.get('contactRecordId');
            if(type == 'Foreign Associate'){
                mem.SymphonyLF__Office_Agent__c = contactRecordId;
            } else {
                mem.SymphonyLF__Supervisor_Client_Contact__c = contactRecordId;
            }
            mem.SymphonyLF__Patent__c = mainPatent.Id;
            mem.SymphonyLF__Type__c   = type;
            memList.add(mem);
        }
        if(!memList.isEmpty()){
            insert memList;
        }
        
        //  Create Applicant (Chain of Title) records
        List<SymphonyLF__Chain_of_Title__c> applicantList = new List<SymphonyLF__Chain_of_Title__c>();
        for (Map<String, Object> app : applicantData) {
            SymphonyLF__Chain_of_Title__c applicant = new SymphonyLF__Chain_of_Title__c();
            applicant.SymphonyLF__Client__c              = clientId;
            applicant.SymphonyLF__Role__c                = 'Applicant';
            applicant.SymphonyLF__Current__c             = true;
            applicant.SymphonyLF__Patent__c              = mainPatent.Id;
            applicant.SymphonyLF__Registered_Applicant__c= (String) app.get('Name');
            
            // Process address details if available
            // Map<String, Object> addr = (Map<String, Object>) app.get('Address');
            Object addrObj = app.get('Address');
            Map<String, Object> addr = null;
            if (addrObj != null) {
                addr = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(addrObj));
            }
            if(addr != null) {
                applicant.SymphonyLF__Address__City__s      = (String) addr.get('city');
                applicant.SymphonyLF__Address__CountryCode__s = (String) addr.get('countryCode');
                applicant.SymphonyLF__Address__StateCode__s   = (String) addr.get('province'); // or 'state' if appropriate
                applicant.SymphonyLF__Address__Street__s      = (String) addr.get('street');
                applicant.SymphonyLF__Address__PostalCode__s  = (String) addr.get('postalCode');
            }
            applicantList.add(applicant);
        }
        if(!applicantList.isEmpty()){
            insert applicantList;
        }
        
        //  Create Inventor records
        List<SymphonyLF__Inventor_Designer_Author__c> inventorList = new List<SymphonyLF__Inventor_Designer_Author__c>();
        for (Map<String, Object> inv : inventorData) {
            SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
            inventor.SymphonyLF__Contact__c = (Id) inv.get('Id');
            inventor.SymphonyLF__Patent__c  = mainPatent.Id;
            inventor.SymphonyLF__Type__c    = 'Inventor';
            if(inv.containsKey('primary')){
                inventor.SymphonyLF__Primary_Inventor__c = (Boolean) inv.get('isPrimary');
            }
            // if(inv.containsKey('sequence')){
            //     inventor.Sequence__c = ((Decimal) inv.get('sequence')).intValue();
            // }
            inventorList.add(inventor);
        }
        if(!inventorList.isEmpty()){
            insert inventorList;
        }
        
        // Return the created records and their fields to JavaScript
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('patent', mainPatent);
        resultMap.put('memRecords', memList);
        resultMap.put('applicantRecords', applicantList);
        resultMap.put('inventorRecords', inventorList);
        
        return resultMap;
    }


    public class JurisdictionDetail
    {
         @AuraEnabled
         public List<SymphonyLF__Client_Jurisdiction_Group__c> jurisdictionGroup{set;get;}
         @AuraEnabled
         public List<SymphonyLF__Country__c> jurisdictions{set;get;}
         @AuraEnabled
         public List<SymphonyLF__Jurisdiction_Group_Detail__c> groupDetail{set;get;}
    }


    public class ExistingPatentFamilyDetailsWrapper {
        @AuraEnabled public SymphonyLF__Patent_Family__c patentFamily;
        @AuraEnabled public List<SymphonyLF__Matter_Engagement_Model__c> engagements;
        @AuraEnabled public List<SymphonyLF__Chain_of_Title__c> chainRecords;
        @AuraEnabled public List<SymphonyLF__Inventor_Designer_Author__c> inventors;
    }

    public class InventorWrapper {
        @AuraEnabled public String contactId;      
        @AuraEnabled public String existingRecId;  
        @AuraEnabled public Boolean primary;     
        @AuraEnabled public Integer sequence;  
    }

    public class PersonInputWrapper {
        @AuraEnabled public String tempId;
        @AuraEnabled public String personName;
        @AuraEnabled public String clientId;
        @AuraEnabled public String user;
        @AuraEnabled public String contactType;
        @AuraEnabled public String Type;
        @AuraEnabled public String recordTypeId;
        @AuraEnabled public String nationality;
        @AuraEnabled public String emailAddress;
        @AuraEnabled public String phone;
        
        @AuraEnabled public AddressWrapper inventorAddress;
    }
    
    public class PersonResultWrapper {
        @AuraEnabled public String tempId;
        @AuraEnabled public Id id;        
        @AuraEnabled public String personName;
        @AuraEnabled public String emailAddress;    
        @AuraEnabled public AddressWrapper address;
    }
    

    public class AddressWrapper {
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String country;
        @AuraEnabled public String countryCode;
        @AuraEnabled public String stateCode;
        @AuraEnabled public String province;
        @AuraEnabled public String postalCode;
    }

    public class ClientInputWrapper {
        @AuraEnabled public String tempId;
        @AuraEnabled public String name;
        @AuraEnabled public String defaultCurrency;
        @AuraEnabled public String entitySize;
        @AuraEnabled public String classification;
        @AuraEnabled public AddressWrapper address;
    }

    public class ClientResultWrapper {
        @AuraEnabled public String tempId;
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public AddressWrapper address;
    }


    public class ChainRecordWrapper {
        @AuraEnabled public String clientId;           
        @AuraEnabled public AddressWrapper addressedit;  
        @AuraEnabled public String Name;
    }

    public class ChainResultWrapper {
        @AuraEnabled public String clientId;
        @AuraEnabled public String chainId;
    }

    public class ErrorDetail {
        @AuraEnabled public String Description;
    }


    // Wrapper class for input data
    public class recordWrapper {
        public String patentFamilyId { get; set; }
        public String shortTitle { get; set; }
        public String inventionTitle { get; set; }
        public String ClientId { get; set; }
        public List<Map<String, String>> engagementDetails { get; set; }
        public List<Id> deletedEngagementDetails { get; set; } 
    
        public recordWrapper() {
            patentFamilyId = '';
            shortTitle = '';
            inventionTitle = '';
            ClientId = '';
            engagementDetails = new List<Map<String, String>>();
            deletedEngagementDetails = new List<Id>();
        }
    }
    

    // Response class to send back results
    public class Response {
        @AuraEnabled public String PatentFamilyID { get; set; }
        @AuraEnabled public Boolean Status { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<ErrorDetail> Errors;
        @AuraEnabled public List<Map<String, String>> Data;
        @AuraEnabled public List<Map<String, Object>> engagementDetails { get; set; } 
        public Response() {
            Status = false;
            message = '';
            Data = new List<Map<String, String>>();
            Errors = new List<ErrorDetail>();
            engagementDetails = new List<Map<String, Object>>();

        }
    }

}