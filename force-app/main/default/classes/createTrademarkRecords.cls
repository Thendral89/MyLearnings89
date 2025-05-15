public without sharing class createTrademarkRecords {
    public static Map<String, SymphonyLF__Mark__c > intakeFormNewPatentFamilyMap = new Map<String, SymphonyLF__Mark__c >();
    public static Map<String, SymphonyLF__Trademark__c> patentRecords = new Map<String, SymphonyLF__Trademark__c>();
    public static Map<String, List<SymphonyLF__Trademark__c>> patentRecordsList = new Map<String, List<SymphonyLF__Trademark__c>>();
    public static Map<String, SymphonyLF__Docketing_Activity__c> jurisdictionToDocketActivity = new Map<String, SymphonyLF__Docketing_Activity__c>();
    public static Map<Id, Id> patentVsJurisdictionIdMap = new Map<Id, Id>();


    public static void createRecords(List<Asset_Intake_Form__c> assetIntakeFormList ){

        Set<Id> intakeFormIds = new Set<Id>();
        Set<Id> jurisdictionIds = new Set<Id>();
        Set<String> personalIds = new Set<String>();
        Set<String> applicantIds = new Set<String>();
        Set<String> inventorIds = new Set<String>();
        Set<String> classIds  = new Set<String>();


        List< Asset_Intake_Form__c > assetIntakeFormUpdList = new List<Asset_Intake_Form__c >();
        List< Asset_Intake_Jurisdiction__c > intakeJurisdictionList = new List<Asset_Intake_Jurisdiction__c >();
        List<Asset_Intake_Jurisdiction_Relations__c> intakeJurisdictionRelations = new List<Asset_Intake_Jurisdiction_Relations__c>();

        Map<String, List<Asset_Intake_Jurisdiction__c>> intakeFormVsJurisdictions = new Map<String, List<Asset_Intake_Jurisdiction__c>>();
        Map<String, List<Asset_Intake_Jurisdiction_Relations__c>> jurisdictionVsRelations = new Map<String, List<Asset_Intake_Jurisdiction_Relations__c>>();

        Map<String, List<SymphonyLF__Matter_Engagement_Model__c>> memRecords = new Map<String, List<SymphonyLF__Matter_Engagement_Model__c>>();
        Map<String, List<SymphonyLF__Chain_of_Title__c>> chainOfTitleRecords = new Map<String, List<SymphonyLF__Chain_of_Title__c>>();
        Map<String, List<SymphonyLF__Inventor_Designer_Author__c>> inventorRecords = new Map<String, List<SymphonyLF__Inventor_Designer_Author__c>>();
        Map<String, List<SymphonyLF__Asset_Classification__c>> classificationRecords = new Map<String, List<SymphonyLF__Asset_Classification__c>>();
        Map<String, SymphonyLF__Docketing_Activity__c> docketActivityRecords = new Map<String, SymphonyLF__Docketing_Activity__c>();



        Map<String, Asset_Intake_Personnel__c > intakePersonnelMap;
        Map<String, Asset_Intake_Inventor__c > intakeInventorMap;
        Map<String, Asset_Intake_Applicants__c > intakeApplicantMap;
        Map<String, Asset_Intake_Class__c> intakeClassMap;

        

        Set<String> newPatentIds = new Set<String>();
        List<SymphonyLF__Matter_Engagement_Model__c> memToBeInserted = new List<SymphonyLF__Matter_Engagement_Model__c>();
        List<SymphonyLF__Chain_of_Title__c> chainOfTitleToBeInserted = new List<SymphonyLF__Chain_of_Title__c>();
        List<SymphonyLF__Inventor_Designer_Author__c> inventorsToBeInserted = new List<SymphonyLF__Inventor_Designer_Author__c>();
        List<SymphonyLF__Asset_Classification__c> classToBeInserted =  new List<SymphonyLF__Asset_Classification__c>();
        List<SymphonyLF__Docketing_Activity__c> docketActivitiesToBeInserted = new List<SymphonyLF__Docketing_Activity__c>();




        for(Asset_Intake_Form__c intakeForm : assetIntakeFormList){
            System.debug(intakeForm.New_Mark_Title__c + '<<<>>>' + intakeForm.Mark_Type__c);
            if(intakeForm.New_Mark_Title__c != '' && intakeForm.New_Mark_Title__c <> null){
                SymphonyLF__Mark__c patentFamily = new SymphonyLF__Mark__c();
                patentFamily.SymphonyLF__Client__c = intakeForm.Client__c;
                patentFamily.Name = intakeForm.New_Mark_Title__c;
                patentFamily.SymphonyLF__Mark_Type__c = intakeForm.Mark_Type__c;
                patentFamily.SymphonyLF__Active__c = true;
                if(!String.isBlank(intakeForm.Image_ContentVersion__c)){
                    ContentVersion cv = [SELECT Id, ContentDocumentId 
                     FROM ContentVersion 
                     WHERE Id =: intakeForm.Image_ContentVersion__c 
                     LIMIT 1];

                    System.debug('Content Document Id: ' + cv.ContentDocumentId);
                    patentFamily.SymphonyLF__TM_Image_ID__c = cv.ContentDocumentId;
                }
                
                intakeFormNewPatentFamilyMap.put(String.valueOf(intakeForm.Id), patentFamily);
                
            }
            System.debug('intakeFormNewPatentFamilyMap:::>>>' + intakeFormNewPatentFamilyMap);
            intakeFormIds.add(intakeForm.Id);
        }
        
        if(!intakeFormNewPatentFamilyMap.isEmpty()){
            Insert intakeFormNewPatentFamilyMap.values();
            System.debug('intakeFormNewPatentFamilyMap ' + intakeFormNewPatentFamilyMap);
            for(String key: intakeFormNewPatentFamilyMap.keyset()){
                Asset_Intake_Form__c intakeFormUpd = new Asset_Intake_Form__c();
                intakeFormUpd.Id = key;
                intakeFormUpd.Mark__c = intakeFormNewPatentFamilyMap.get(key).Id;
                System.debug(intakeFormNewPatentFamilyMap.get(key).Id);
                assetIntakeFormUpdList.add(intakeFormUpd);
            }
            
            if(!assetIntakeFormUpdList.isEmpty()){
                Update assetIntakeFormUpdList;
            }

        }
        
        // person abased
        if(intakeFormIds.isEmpty()) return;

        intakeJurisdictionList = [
            SELECT 
                Id
                , Name
                , CaseType__c
                , ClientReferenceNumber__c
                , Jurisdiction__c
                , Jurisdiction__r.SymphonyLF__TM_Single_Class_Application_Reqd__c
                , Asset_Intake_Form__c
                , Event_Name__c
                , Docket_Type__c
                , Event_Date__c
                , Due_Date__c
                , Assigned_To__c
                , Asset_Intake_Form__r.Client__c
                , Asset_Intake_Form__r.Patent_Family__c
                , Asset_Intake_Form__r.Patent_Family__r.Name 
                , Asset_Intake_Form__r.Mark__c
                , Asset_Intake_Form__r.Mark__r.Name
                , Asset_Intake_Form__r.Image_ContentVersion__c
                //, Asset_Intake_Form__r.Image_ContentVersion__c
            FROM Asset_Intake_Jurisdiction__c 
            WHERE Asset_Intake_Form__c IN: intakeFormIds
        ];
        
        if(intakeJurisdictionList.isEmpty()) return;

        for(Asset_Intake_Jurisdiction__c record : intakeJurisdictionList){
            jurisdictionIds.add(record.Id);
            if(intakeFormVsJurisdictions.containskey(record.Asset_Intake_Form__c)){
                intakeFormVsJurisdictions.get(record.Asset_Intake_Form__c).add(record);
            }else{
                intakeFormVsJurisdictions.put(record.Asset_Intake_Form__c, new List<Asset_Intake_Jurisdiction__c>{record});
            }
            
        }
        
        intakeJurisdictionRelations = [
            SELECT 
                ID
                , Asset_Intake_Jurisdiction__c
                , Asset_Intake_Jurisdiction__r.Asset_Intake_Form__r.Client__c
                , Asset_Intake_Applicant__c
                , Asset_Intake_Inventor__c
                , Asset_Intake_Personnel__c
                , Asset_Intake_Class__c
                , InstanceType__c 
            FROM Asset_Intake_Jurisdiction_Relations__c 
            WHERE Asset_Intake_Jurisdiction__c IN: jurisdictionIds
        ];
        
            
        for(Asset_Intake_Jurisdiction_Relations__c record : intakeJurisdictionRelations){
            if(jurisdictionVsRelations.containskey(record.Asset_Intake_Jurisdiction__c)){
                jurisdictionVsRelations.get(record.Asset_Intake_Jurisdiction__c).add(record);
            }else{
                jurisdictionVsRelations.put(record.Asset_Intake_Jurisdiction__c, new List<Asset_Intake_Jurisdiction_Relations__c>{record});
            }
            if(record.InstanceType__c == 'Asset_Intake_Personnel__c'){
                personalIds.add(record.Asset_Intake_Personnel__c);
            }
            if(record.InstanceType__c == 'Asset_Intake_Inventor__c'){
                inventorIds.add(record.Asset_Intake_Inventor__c);
            }
            if(record.InstanceType__c == 'Asset_Intake_Applicants__c'){
                applicantIds.add(record.Asset_Intake_Applicant__c);
            }
            if(record.InstanceType__c == 'Asset_Intake_Class__c'){
                classIds.add(record.Asset_Intake_Class__c);
            }  
            
        }
        if(!personalIds.isEmpty() || !intakeFormNewPatentFamilyMap.isEmpty()){
            intakePersonnelMap = new Map<String, Asset_Intake_Personnel__c >(
                [
                    SELECT 
                        Id
                        , Client_Engagement_Model__c
                        ,  Client_Engagement_Model__r.SymphonyLF__Type__c
                        , Asset_Intake_Form__c
                        , Asset_Intake_Form__r.Client__c
                        , Personnel__c
                        , Asset_Intake_Form__r.Patent_Family__c 
                        , Asset_Intake_Form__r.Mark__c
                    FROM Asset_Intake_Personnel__c 
                    WHERE 
                        ID IN: personalIds 
                        OR 
                        Asset_Intake_Form__c IN: intakeFormNewPatentFamilyMap.keyset()
                ]
            );
        
        }
        System.debug('intakePersonnelMap of trademark--->'+intakePersonnelMap);
        if(!inventorIds.isEmpty() || !intakeFormNewPatentFamilyMap.isEmpty()){
            intakeInventorMap = new Map<String, Asset_Intake_Inventor__c >(
                [
                    SELECT 
                        Id
                        , Inventor_Designer_Author__c
                        ,  Inventor_Designer_Author__r.SymphonyLF__Contact__c
                        ,  Inventor_Designer_Author__r.SymphonyLF__Type__c
                        , Inventor_Designer_Author__r.Sequence__c
                        , Inventor_Designer_Author__r.SymphonyLF__Primary_Inventor__c
                        , Asset_Intake_Form__r.Patent_Family__c
                        , Asset_Intake_Form__r.Mark__c
                    FROM Asset_Intake_Inventor__c 
                    WHERE 
                        ID IN: inventorIds 
                        OR 
                        Asset_Intake_Form__c IN: intakeFormNewPatentFamilyMap.keyset()
                ]
            );
        }

        if(!applicantIds.isEmpty() || !intakeFormNewPatentFamilyMap.isEmpty()){
            intakeApplicantMap = new Map<String, Asset_Intake_Applicants__c >(
                [
                    SELECT 
                        Id
                        , Client_Classification__c
                        , Applicant__c
                        , US_CA_Entity_Size__c
                        , Applicant_Address__City__s
                        , Applicant_Address__CountryCode__s
                        , Applicant_Address__PostalCode__s
                        , Applicant_Address__StateCode__s
                        , Applicant_Address__Street__s
                        , Asset_Intake_Form__r.Client__c
                        , Asset_Intake_Form__r.Patent_Family__c
                        , Asset_Intake_Form__r.Mark__c 
                    FROM 
                    Asset_Intake_Applicants__c 
                    WHERE 
                        ID IN: applicantIds 
                        OR Asset_Intake_Form__c IN: intakeFormNewPatentFamilyMap.keyset() 
                ]
            ); 
        }
        if(!classIds.isEmpty() || !intakeFormNewPatentFamilyMap.isEmpty()){
            intakeClassMap =  new Map<String, Asset_Intake_Class__c>([
                Select 
                Id
                , Name
                , Asset_Intake_Form__c
                , Class__c
                , Client_Asset_Specification__c
                , Instance_Type__c
                , Jurisdiction__c
                , Language__c
                , Specification__c
                , Standard_Class_Name__c
                , Sub_Class__c 
                FROM 
                Asset_Intake_Class__c 
                WHERE 
                    ID IN: classIds 
                    OR Asset_Intake_Form__c IN: intakeFormNewPatentFamilyMap.keyset()
            ]);  
        }

        if(!intakeFormNewPatentFamilyMap.isEmpty()){
            for(String key: intakeFormNewPatentFamilyMap.keyset()){
                if(!intakePersonnelMap.isEmpty()){
                    for(Asset_Intake_Personnel__c personRecord: intakePersonnelMap.values()){
                        if(personRecord.Asset_Intake_Form__c == key ){
                            SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
                            memMO.SymphonyLF__Client__c = personRecord.Asset_Intake_Form__r.Client__c;
                            // if(personRecord.Client_Engagement_Model__r.SymphonyLF__Type__c == 'Foreign Associate'){
                            //     memMO.SymphonyLF__Office_Agent__c = personRecord.Personnel__c;
                            // }else{
                            //     memMO.SymphonyLF__Supervisor_Client_Contact__c = personRecord.Personnel__c;
                            // }
                            memMO.Client_Engagement_Model__c = personRecord.Client_Engagement_Model__c;
                            System.debug('personRecord.Client_Engagement_Model__c--->'+personRecord.Client_Engagement_Model__c);
                            memMO.SymphonyLF__Assign_to_User__c = personRecord.Personnel__c;
                            memMO.SymphonyLF__Mark__c = intakeFormNewPatentFamilyMap.get(key).Id;
                            memMO.SymphonyLF__Type__c = personRecord.Client_Engagement_Model__r.SymphonyLF__Type__c;
                            memToBeInserted.add(memMO);
                        }
                        
                    }
                }
                //To be removed for Trademarks
                if(!intakeInventorMap.isEmpty()){
                    for(Asset_Intake_Inventor__c inventorRec: intakeInventorMap.values()){
                        if(inventorRec.Asset_Intake_Form__c == key ){
                            SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                            inventor.SymphonyLF__Contact__c = inventorRec.Inventor_Designer_Author__r.SymphonyLF__Contact__c;
                            inventor.SymphonyLF__Type__c = 'Inventor';
                            inventor.SymphonyLF__Primary_Inventor__c = inventorRec.Inventor_Designer_Author__r.SymphonyLF__Primary_Inventor__c;
                            inventor.Sequence__c = inventorRec.Inventor_Designer_Author__r.Sequence__c;
                            inventor.SymphonyLF__Patent_Family__c = intakeFormNewPatentFamilyMap.get(key).Id;
                            //inventorsToBeInserted.add(inventor);
                        }
                    }
                }
                if(!intakeApplicantMap.isEmpty()){
                    for(Asset_Intake_Applicants__c applicantRec: intakeApplicantMap.values()){
                        
                        if(applicantRec.Asset_Intake_Form__c == key ){
                            SymphonyLF__Chain_of_Title__c applicant = new SymphonyLF__Chain_of_Title__c();
                            applicant.SymphonyLF__Client__c = 	applicantRec.Applicant__c;
                            applicant.SymphonyLF__Role__c = applicantRec.Client_Classification__c;
                            applicant.SymphonyLF__Current__c = true;
                            applicant.SymphonyLF__Address__City__s=applicantRec.Applicant_Address__City__s;
                            applicant.SymphonyLF__Address__CountryCode__s=applicantRec.Applicant_Address__CountryCode__s;
                            applicant.SymphonyLF__Address__StateCode__s=applicantRec.Applicant_Address__StateCode__s;
                            applicant.SymphonyLF__Address__Street__s=applicantRec.Applicant_Address__Street__s;
                            applicant.SymphonyLF__Address__PostalCode__s=applicantRec.Applicant_Address__PostalCode__s;
                            applicant.SymphonyLF__Mark__c = (intakeFormNewPatentFamilyMap.get(key)).Id;
                            chainOfTitleToBeInserted.add(applicant);
                        }
                    }
                }
                if(!intakeClassMap.isEmpty()){
                    for(Asset_Intake_Class__c classRec : intakeClassMap.values()){
                        if(classRec.Asset_Intake_Form__c == key ){
                            SymphonyLF__Asset_Classification__c classRecord = new SymphonyLF__Asset_Classification__c();
                            classRecord.SymphonyLF__Mark__c = (intakeFormNewPatentFamilyMap.get(key)).Id;
                            classRecord.SymphonyLF__Class_No__c = classRec.Class__c;
                            classRecord.SymphonyLF__Sub_Class__c = classRec.Sub_Class__c;
                            classRecord.SymphonyLF__Specification__c = classRec.Specification__c;
                            classRecord.SymphonyLF__Language__c = classRec.Language__c;
                            classToBeInserted.add(classRecord);
                    }
                }
            }
                
            }
            
        }
        
       
        for(String assetIntake : intakeFormVsJurisdictions.keyset()){
            if(intakeFormVsJurisdictions.containskey(assetIntake)){
                for(Asset_Intake_Jurisdiction__c jurisdiction : intakeFormVsJurisdictions.get(assetIntake) ){
                    System.debug('jurisdiction ID : '+jurisdiction.Id);
                    memRecords.put(jurisdiction.Name, new List<SymphonyLF__Matter_Engagement_Model__c>());
                    chainOfTitleRecords.put(jurisdiction.Name, new List<SymphonyLF__Chain_of_Title__c>());
                    inventorRecords.put(jurisdiction.Name, new List<SymphonyLF__Inventor_Designer_Author__c>());
                    classificationRecords.put(jurisdiction.Name, new List<SymphonyLF__Asset_Classification__c>());

                    if(jurisdiction.Jurisdiction__r.SymphonyLF__TM_Single_Class_Application_Reqd__c == false ){
                    SymphonyLF__Trademark__c mainPatent = new SymphonyLF__Trademark__c();
                    mainPatent.SymphonyLF__Case_Type__c = jurisdiction.CaseType__c;
                    mainPatent.SymphonyLF__Client__c = jurisdiction.Asset_Intake_Form__r.Client__c;
                    mainPatent.SymphonyLF__Jurisdiction__c = jurisdiction.Jurisdiction__c;
                    mainPatent.Name = jurisdiction.Asset_Intake_Form__r.Mark__r.Name;
                    mainPatent.SymphonyLF__Mark__c = jurisdiction.Asset_Intake_Form__r.Mark__c;
                    mainPatent.SymphonyLF__Client_Reference__c = jurisdiction.ClientReferenceNumber__c;
                    mainPatent.SymphonyLF__Status__c = 'Application Preparation';
                    if(!String.isBlank(jurisdiction.Asset_Intake_Form__r.Image_ContentVersion__c)){
                        ContentVersion cv = [SELECT Id, ContentDocumentId 
                        FROM ContentVersion 
                        WHERE Id =: jurisdiction.Asset_Intake_Form__r.Image_ContentVersion__c
                        LIMIT 1];

                        System.debug('Content Document Id: ' + cv.ContentDocumentId);
                        mainPatent.SymphonyLF__TM_Image_ID__c = cv.ContentDocumentId;
                    }
                    mainPatent.SymphonyLF__Active__c = true;

                    //mainPatent.SymphonyLF__TM_Image_ID__c = jurisdiction.Asset_Intake_Form__r.Image_ContentVersion__c;
                    
                    patentRecords.put(jurisdiction.Name, mainPatent);
                    patentVsJurisdictionIdMap.put(mainPatent.Id, jurisdiction.Id);
                    SymphonyLF__Docketing_Activity__c docketActivity = new SymphonyLF__Docketing_Activity__c();
                    docketActivity.SymphonyLF__Event_Name__c = 	jurisdiction.Event_Name__c;
                    docketActivity.SymphonyLF__Event_Date__c = jurisdiction.Event_Date__c;
                    docketActivity.SymphonyLF__Assigned_To_User__c = jurisdiction.Assigned_To__c;
                    docketActivity.SymphonyLF__Due_Date__c  = jurisdiction.Due_Date__c ;
                    docketActivity.Docket_Type__c=jurisdiction.Docket_Type__c;
                    docketActivityRecords.put(jurisdiction.Name, docketActivity);



                    if(jurisdictionVsRelations.containskey(jurisdiction.Id)){

                        for(Asset_Intake_Jurisdiction_Relations__c record : jurisdictionVsRelations.get(jurisdiction.Id)){
                            System.debug(record + ' ---- record');
                            if(record.InstanceType__c == 'Asset_Intake_Personnel__c' && intakePersonnelMap != null && intakePersonnelMap.containskey(record.Asset_Intake_Personnel__c)){
                                Asset_Intake_Personnel__c personnelRec =  intakePersonnelMap.get(record.Asset_Intake_Personnel__c);
                                SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
                                memMO.SymphonyLF__Client__c = personnelRec.Asset_Intake_Form__r.Client__c;
                                if(personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c == 'Foreign Associate'){
                                    memMO.SymphonyLF__Office_Agent__c = personnelRec.Personnel__c;
                                }else{
                                    memMO.SymphonyLF__Supervisor_Client_Contact__c = personnelRec.Personnel__c;
                                }
                                memMO.SymphonyLF__Assign_to_User__c = personnelRec.Personnel__c;
                                memMO.SymphonyLF__Type__c = personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c;
                                memRecords.get(jurisdiction.Name).add(memMO);
                            }
                            if(record.InstanceType__c == 'Asset_Intake_Applicants__c' && intakeApplicantMap != null && intakeApplicantMap.containskey(record.Asset_Intake_Applicant__c)){
                                Asset_Intake_Applicants__c applicantRec =  intakeApplicantMap.get(record.Asset_Intake_Applicant__c);
                                SymphonyLF__Chain_of_Title__c applicant = new SymphonyLF__Chain_of_Title__c();
                                applicant.SymphonyLF__Client__c = 	applicantRec.Applicant__c;
                                applicant.SymphonyLF__Role__c = applicantRec.Client_Classification__c;
                                applicant.SymphonyLF__Current__c = true;
                                applicant.SymphonyLF__Address__City__s=applicantRec.Applicant_Address__City__s;
                                applicant.SymphonyLF__Address__CountryCode__s=applicantRec.Applicant_Address__CountryCode__s;
                                applicant.SymphonyLF__Address__StateCode__s=applicantRec.Applicant_Address__StateCode__s;
                                applicant.SymphonyLF__Address__Street__s=applicantRec.Applicant_Address__Street__s;
                                applicant.SymphonyLF__Address__PostalCode__s=applicantRec.Applicant_Address__PostalCode__s;
                                chainOfTitleRecords.get(jurisdiction.Name).add(applicant);
                            }
                            if(record.InstanceType__c == 'Asset_Intake_Inventor__c' && intakeInventorMap != null && intakeInventorMap.containskey(record.Asset_Intake_Inventor__c)){
                                Asset_Intake_Inventor__c inventorRec =  intakeInventorMap.get(record.Asset_Intake_Inventor__c);
                                SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                                inventor.SymphonyLF__Contact__c = inventorRec.Inventor_Designer_Author__r.SymphonyLF__Contact__c;
                                inventor.SymphonyLF__Type__c = 'Inventor';
                                inventor.SymphonyLF__Primary_Inventor__c = inventorRec.Inventor_Designer_Author__r.SymphonyLF__Primary_Inventor__c;
                                inventor.Sequence__c = inventorRec.Inventor_Designer_Author__r.Sequence__c;
                                inventorRecords.get(jurisdiction.Name).add(inventor);   
                            }
                            System.debug('intakeClassMap.containskey(record.Asset_Intake_Class__c) '+intakeClassMap.containskey(record.Asset_Intake_Class__c));
                            if(record.InstanceType__c == 'Asset_Intake_Class__c' && intakeClassMap != null && intakeClassMap.containskey(record.Asset_Intake_Class__c)){
                                Asset_Intake_Class__c classRecord =  intakeClassMap.get(record.Asset_Intake_Class__c);
                                SymphonyLF__Asset_Classification__c classificationRec = new SymphonyLF__Asset_Classification__c();
                                classificationRec.SymphonyLF__Class_No__c = classRecord.Class__c;
                                classificationRec.SymphonyLF__Sub_Class__c = classRecord.Sub_Class__c;
                                classificationRec.SymphonyLF__Specification__c = classRecord.Specification__c;
                                classificationRec.SymphonyLF__Language__c = classRecord.Language__c;    
                                classificationRecords.get(jurisdiction.Name).add(classificationRec);
                            }
                        }
                    }
                }else{
                   for(Id classId : classIds){
                    System.debug('classIds size : '+classIds.size());
                    SymphonyLF__Trademark__c mainPatent = new SymphonyLF__Trademark__c();
                    mainPatent.SymphonyLF__Case_Type__c = jurisdiction.CaseType__c;
                    mainPatent.SymphonyLF__Client__c = jurisdiction.Asset_Intake_Form__r.Client__c;
                    mainPatent.SymphonyLF__Jurisdiction__c = jurisdiction.Jurisdiction__c;
                    mainPatent.Name = jurisdiction.Asset_Intake_Form__r.Mark__r.Name;
                    mainPatent.SymphonyLF__Mark__c = jurisdiction.Asset_Intake_Form__r.Mark__c;
                    mainPatent.SymphonyLF__Client_Reference__c = jurisdiction.ClientReferenceNumber__c;
                    mainPatent.SymphonyLF__Status__c = 'Application Preparation';
                    if(!String.isBlank(jurisdiction.Asset_Intake_Form__r.Image_ContentVersion__c)){
                        ContentVersion cv = [SELECT Id, ContentDocumentId 
                        FROM ContentVersion 
                        WHERE Id =: jurisdiction.Asset_Intake_Form__r.Image_ContentVersion__c
                        LIMIT 1];

                        System.debug('Content Document Id: ' + cv.ContentDocumentId);
                        mainPatent.SymphonyLF__TM_Image_ID__c = cv.ContentDocumentId;
                    }
                    mainPatent.SymphonyLF__Active__c = true;
                    
                    //mainPatent.SymphonyLF__TM_Image_ID__c = jurisdiction.Asset_Intake_Form__r.Image_ContentVersion__c;
                    
                    if(!patentRecordsList.containsKey(jurisdiction.Name)){
                        patentRecordsList.put(jurisdiction.Name,new List<SymphonyLF__Trademark__c>());
                    }

                    patentRecordsList.get(jurisdiction.Name).add(mainPatent);
                    System.debug('patentRecordsList put : '+patentRecordsList);
                    patentVsJurisdictionIdMap.put(mainPatent.Id, jurisdiction.Id);
                    SymphonyLF__Docketing_Activity__c docketActivity = new SymphonyLF__Docketing_Activity__c();
                    docketActivity.SymphonyLF__Event_Name__c = 	jurisdiction.Event_Name__c;
                    docketActivity.SymphonyLF__Event_Date__c = jurisdiction.Event_Date__c;
                    docketActivity.SymphonyLF__Assigned_To_User__c = jurisdiction.Assigned_To__c;
                    docketActivity.SymphonyLF__Due_Date__c  = jurisdiction.Due_Date__c ;
                    docketActivity.Docket_Type__c=jurisdiction.Docket_Type__c;
                    docketActivityRecords.put(jurisdiction.Name, docketActivity);

                

                    //patentRecords.put(jurisdiction.Name, mainPatent);
                    
                    if(jurisdictionVsRelations.containskey(jurisdiction.Id)){

                        for(Asset_Intake_Jurisdiction_Relations__c record : jurisdictionVsRelations.get(jurisdiction.Id)){
                            System.debug(record + ' ---- record');
                            if(record.InstanceType__c == 'Asset_Intake_Personnel__c' && intakePersonnelMap != null && intakePersonnelMap.containskey(record.Asset_Intake_Personnel__c)){
                                Asset_Intake_Personnel__c personnelRec =  intakePersonnelMap.get(record.Asset_Intake_Personnel__c);
                                SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
                                memMO.SymphonyLF__Client__c = personnelRec.Asset_Intake_Form__r.Client__c;
                                if(personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c == 'Foreign Associate'){
                                    memMO.SymphonyLF__Office_Agent__c = personnelRec.Personnel__c;
                                }else{
                                    memMO.SymphonyLF__Supervisor_Client_Contact__c = personnelRec.Personnel__c;
                                }
                                memMO.SymphonyLF__Assign_to_User__c = personnelRec.Personnel__c;
                                memMO.SymphonyLF__Type__c = personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c;
                                memRecords.get(jurisdiction.Name).add(memMO);
                            }
                            if(record.InstanceType__c == 'Asset_Intake_Applicants__c' && intakeApplicantMap != null && intakeApplicantMap.containskey(record.Asset_Intake_Applicant__c)){
                                Asset_Intake_Applicants__c applicantRec =  intakeApplicantMap.get(record.Asset_Intake_Applicant__c);
                                SymphonyLF__Chain_of_Title__c applicant = new SymphonyLF__Chain_of_Title__c();
                                applicant.SymphonyLF__Client__c = 	applicantRec.Applicant__c;
                                applicant.SymphonyLF__Role__c = applicantRec.Client_Classification__c;
                                applicant.SymphonyLF__Current__c = true;
                                applicant.SymphonyLF__Address__City__s=applicantRec.Applicant_Address__City__s;
                                applicant.SymphonyLF__Address__CountryCode__s=applicantRec.Applicant_Address__CountryCode__s;
                                applicant.SymphonyLF__Address__StateCode__s=applicantRec.Applicant_Address__StateCode__s;
                                applicant.SymphonyLF__Address__Street__s=applicantRec.Applicant_Address__Street__s;
                                applicant.SymphonyLF__Address__PostalCode__s=applicantRec.Applicant_Address__PostalCode__s;
                                chainOfTitleRecords.get(jurisdiction.Name).add(applicant);
                            }
                            if(record.InstanceType__c == 'Asset_Intake_Inventor__c' && intakeInventorMap != null && intakeInventorMap.containskey(record.Asset_Intake_Inventor__c)){
                                Asset_Intake_Inventor__c inventorRec =  intakeInventorMap.get(record.Asset_Intake_Inventor__c);
                                SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                                inventor.SymphonyLF__Contact__c = inventorRec.Inventor_Designer_Author__r.SymphonyLF__Contact__c;
                                inventor.SymphonyLF__Type__c = 'Inventor';
                                inventor.SymphonyLF__Primary_Inventor__c = inventorRec.Inventor_Designer_Author__r.SymphonyLF__Primary_Inventor__c;
                                inventor.Sequence__c = inventorRec.Inventor_Designer_Author__r.Sequence__c;
                                inventorRecords.get(jurisdiction.Name).add(inventor);   
                            }
                            if(record.InstanceType__c == 'Asset_Intake_Class__c' && intakeClassMap != null && intakeClassMap.containskey(record.Asset_Intake_Class__c)){
                                Asset_Intake_Class__c classRecord =  intakeClassMap.get(record.Asset_Intake_Class__c);
                                SymphonyLF__Asset_Classification__c classificationRec = new SymphonyLF__Asset_Classification__c();
                                classificationRec.SymphonyLF__Class_No__c = classRecord.Class__c;
                                classificationRec.SymphonyLF__Sub_Class__c = classRecord.Sub_Class__c;
                                classificationRec.SymphonyLF__Specification__c = classRecord.Specification__c;
                                classificationRec.SymphonyLF__Language__c = classRecord.Language__c;    
                                classificationRecords.get(jurisdiction.Name).add(classificationRec);
                            }
                        }
                    }
                }
                   
                }
                    
                }
            }
            
        }
        System.debug('patentRecords' + patentRecords);
        System.debug('classificationRecords  :  '+classificationRecords);
        if(patentRecords.isEmpty() && patentRecordsList.isEmpty()) return;

        Insert patentRecords.values();
        List<SymphonyLF__Trademark__c> tmRecordList = new List<SymphonyLF__Trademark__c>();

        if(!patentRecordsList.isEmpty()){
            for(String key : patentRecordsList.keyset()){
                tmRecordList.addAll(patentRecordsList.get(key));
            }
            if(!tmRecordList.isEmpty()) insert tmRecordList;
            System.debug('tmRecordList :::: '+tmRecordList);
        }
    
        if(!patentRecords.isEmpty()){
            for(String key: patentRecords.keyset()){
                String patentId = patentRecords.get(key).Id;
                newPatentIds.add(patentId);
                for(SymphonyLF__Matter_Engagement_Model__c mems : memRecords.get(key)){
                    mems.SymphonyLF__Trademark__c = patentId;
                    memToBeInserted.add(mems);
                    system.debug('memToBeInserted : for single record'+mems);
                }
                for(SymphonyLF__Chain_of_Title__c chainOfTitle : chainOfTitleRecords.get(key)){
                    chainOfTitle.SymphonyLF__Trademark__c = patentId;
                    chainOfTitleToBeInserted.add(chainOfTitle);
                    system.debug('chainOfTitleToBeInserted : for single record'+chainOfTitle);
                }
                System.debug('key : '+key);
                System.debug('classificationRecords.get(key) : '+classificationRecords.get(key));
                for(SymphonyLF__Asset_Classification__c assetClass : classificationRecords.get(key) ){
                    assetClass.SymphonyLF__Trademark__c = patentId;
                    classToBeInserted.add(assetClass);
                    system.debug('classToBeInserted : for single record'+assetClass);
                }
                if(docketActivityRecords.containskey(key) && docketActivityRecords.get(key) != null){
                    SymphonyLF__Docketing_Activity__c docket = docketActivityRecords.get(key);
                        docket.SymphonyLF__Trademark__c = patentId;
                        docketActivitiesToBeInserted.add(docket);
               }
            }
        }
        if(!patentRecordsList.isEmpty()){
            Set<SymphonyLF__Matter_Engagement_Model__c> engSet = new Set<SymphonyLF__Matter_Engagement_Model__c>();
            Integer i = 0;
    
            for (String key : patentRecordsList.keySet()) {
                if (i > tmRecordList.size()) break; // safety check
    
                SymphonyLF__Trademark__c newRecord = tmRecordList[i];
                List<SymphonyLF__Matter_Engagement_Model__c> memList = memRecords.get(key);
    
                for (SymphonyLF__Matter_Engagement_Model__c mem : memRecords.get(key)) {
                    mem.SymphonyLF__Trademark__c = newRecord.Id;
                    memToBeInserted.add(mem);
                }
                
                for(SymphonyLF__Chain_of_Title__c chainOfTitle : chainOfTitleRecords.get(key)){
                    chainOfTitle.SymphonyLF__Trademark__c = newRecord.Id;
                    chainOfTitleToBeInserted.add(chainOfTitle);
                }
                if(docketActivityRecords.containskey(key) && docketActivityRecords.get(key) != null){
                    SymphonyLF__Docketing_Activity__c docket = docketActivityRecords.get(key);
                        docket.SymphonyLF__Trademark__c = newRecord.Id;
                        docketActivitiesToBeInserted.add(docket);
               }
                i++; 
                List<SymphonyLF__Asset_Classification__c> classRec = classificationRecords.get(key);
                if (classRec != null) {
                    for (Integer j = 0; j < classRec.size(); j++) {
                        if (j >= tmRecordList.size()) break; 
                        SymphonyLF__Asset_Classification__c classItem = classRec[j];
                        classItem.SymphonyLF__Trademark__c = tmRecordList[j].Id;
                        classToBeInserted.add(classItem);
                    }
                }
            }
            
        }
    
        
        
        // for(String key: patentRecords.keyset()){
        //     String patentId = patentRecords.get(key).Id;
        //     newPatentIds.add(patentId);
        //     for(SymphonyLF__Matter_Engagement_Model__c mems : memRecords.get(key)){
        //         System.debug('mems ' + mems);
        //         mems.SymphonyLF__Trademark__c = patentId;
        //         memToBeInserted.add(mems);
        //     }
        //     for(SymphonyLF__Chain_of_Title__c chainOfTitle : chainOfTitleRecords.get(key)){
        //         System.debug('chainOfTitle ' + chainOfTitle);
        //         chainOfTitle.SymphonyLF__Trademark__c = patentId;
        //         chainOfTitleToBeInserted.add(chainOfTitle);
        //     }
            /* for(SymphonyLF__Inventor_Designer_Author__c inventor : inventorRecords.get(key)){
                System.debug('inventor ' + inventor);
                inventor.SymphonyLF__Trademark__c = patentId;
                inventorsToBeInserted.add(inventor);
            } */
        //}
        
        List<SymphonyLF__Matter_Engagement_Model__c> existingMEMs = [
            SELECT 
                Id 
            FROM SymphonyLF__Matter_Engagement_Model__c 
            WHERE SymphonyLF__Trademark__c IN: newPatentIds
        ];
       
        if(!existingMEMs.isEmpty()){
            DELETE existingMEMs;
        }
        
        if(!memToBeInserted.isEmpty()){
            Insert memToBeInserted;
        }
        
        if(!chainOfTitleToBeInserted.isEmpty()){
            Insert chainOfTitleToBeInserted;
        }
        
        if(!inventorsToBeInserted.isEmpty()){
            //Insert inventorsToBeInserted;
        }

        if(!classToBeInserted.isEmpty()){
            Insert classToBeInserted;
        }

        if(!docketActivitiesToBeInserted.isEmpty())
            insert docketActivitiesToBeInserted;
        
    
        

        System.debug('memToBeInserted ' + memToBeInserted.size());
        //System.debug('inventorsToBeInserted ' + inventorsToBeInserted.size());
        System.debug('chainOfTitleToBeInserted ' + chainOfTitleToBeInserted.size());
        
        
    }

    @AuraEnabled
    public static String fetchContentFromMark(String markId){
        String contentId = '';

        if(String.isBlank(markId)){
           return contentId;
        }
        SymphonyLF__Mark__c existingMark = [SELECT 
                                                Id,
                                                SymphonyLF__TM_Image_ID__c
                                                FROM
                                                SymphonyLF__Mark__c
                                                WHERE Id =: markId];
        if(!String.isBlank(existingMark.SymphonyLF__TM_Image_ID__c)){
            ContentVersion contentVersion = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: existingMark.SymphonyLF__TM_Image_ID__c LIMIT 1];
            contentId = String.valueOf(contentVersion.Id);
        }
        System.debug('contentId' + contentId);
        return contentId;   
    }

    @AuraEnabled
    public static String fetchTypeFromMark(String markId){
        String contentId = '';

        if(String.isBlank(markId)){
           return contentId;
        }
        SymphonyLF__Mark__c existingMark = [SELECT 
                                                Id,
                                                SymphonyLF__Mark_Type__c
                                                FROM
                                                SymphonyLF__Mark__c
                                                WHERE Id =: markId];
        if(!String.isBlank(existingMark.SymphonyLF__Mark_Type__c)){
            contentId = existingMark.SymphonyLF__Mark_Type__c;
        }
        System.debug('contentId' + contentId);
        return contentId;   
    }


    // private static SymphonyLF__Matter_Engagement_Model__c createPersonnel(SymphonyLF__Matter_Engagement_Model__c personnelRec){
        
    //     SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
    //     memMO.SymphonyLF__Client__c = personnelRec.Asset_Intake_Form__r.Client__c;
    //     if(personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c == 'Foreign Associate'){
    //         memMO.SymphonyLF__Office_Agent__c = personnelRec.Personnel__c;
    //     }else{
    //         memMO.SymphonyLF__Supervisor_Client_Contact__c = personnelRec.Personnel__c;
    //     }
    //     memMO.SymphonyLF__Assign_to_User__c = personnelRec.Personnel__c;
    //     memMO.SymphonyLF__Patent_Family__c = personnelRec.Asset_Intake_Form__r.Patent_Family__c;
    //     memMO.SymphonyLF__Type__c = personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c;
        
    //     return memMO;
    // }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objectApiName, String fieldApiName) {
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectApiName)
            .getDescribe()
            .fields.getMap().get(fieldApiName)
            .getDescribe();

        List<Map<String, String>> picklistValues = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            Map<String, String> picklistOption = new Map<String, String>{
                'label' => entry.getLabel(),
                'value' => entry.getValue()
            };
            picklistValues.add(picklistOption);
        }
        return picklistValues;
    }
}