public class CreatePatentRecords {
    public static Map<String, SymphonyLF__Patent_Family__c > intakeFormNewPatentFamilyMap = new Map<String, SymphonyLF__Patent_Family__c >();
    public static Map<String, SymphonyLF__Patent__c> patentRecords = new Map<String, SymphonyLF__Patent__c>();
    public static Map<String, SymphonyLF__Docketing_Activity__c> jurisdictionToDocketActivity = new Map<String, SymphonyLF__Docketing_Activity__c>();
    public static Map<Id, Id> patentVsJurisdictionIdMap = new Map<Id, Id>();

    public static void createRecords(List<Asset_Intake_Form__c> assetIntakeFormList ){

        Set<Id> intakeFormIds = new Set<Id>();
        Set<Id> jurisdictionIds = new Set<Id>();
        Set<String> personalIds = new Set<String>();
        Set<String> applicantIds = new Set<String>();
        Set<String> inventorIds = new Set<String>();

        List< Asset_Intake_Form__c > assetIntakeFormUpdList = new List<Asset_Intake_Form__c >();
        List< Asset_Intake_Jurisdiction__c > intakeJurisdictionList = new List<Asset_Intake_Jurisdiction__c >();
        List<Asset_Intake_Jurisdiction_Relations__c> intakeJurisdictionRelations = new List<Asset_Intake_Jurisdiction_Relations__c>();

        Map<String, List<Asset_Intake_Jurisdiction__c>> intakeFormVsJurisdictions = new Map<String, List<Asset_Intake_Jurisdiction__c>>();
        Map<String, List<Asset_Intake_Jurisdiction_Relations__c>> jurisdictionVsRelations = new Map<String, List<Asset_Intake_Jurisdiction_Relations__c>>();

        Map<String, List<SymphonyLF__Matter_Engagement_Model__c>> memRecords = new Map<String, List<SymphonyLF__Matter_Engagement_Model__c>>();
        Map<String, List<SymphonyLF__Chain_of_Title__c>> chainOfTitleRecords = new Map<String, List<SymphonyLF__Chain_of_Title__c>>();
        Map<String, List<SymphonyLF__Inventor_Designer_Author__c>> inventorRecords = new Map<String, List<SymphonyLF__Inventor_Designer_Author__c>>();
        Map<String, SymphonyLF__Docketing_Activity__c> docketActivityRecords = new Map<String, SymphonyLF__Docketing_Activity__c>();

        Map<String, Asset_Intake_Personnel__c > intakePersonnelMap;
        Map<String, Asset_Intake_Inventor__c > intakeInventorMap;
        Map<String, Asset_Intake_Applicants__c > intakeApplicantMap;
        Map<String, Asset_Intake_Jurisdiction__c > intakeJurisdictionMap;
        

        Set<String> newPatentIds = new Set<String>();
        List<SymphonyLF__Matter_Engagement_Model__c> memToBeInserted = new List<SymphonyLF__Matter_Engagement_Model__c>();
        List<SymphonyLF__Chain_of_Title__c> chainOfTitleToBeInserted = new List<SymphonyLF__Chain_of_Title__c>();
        List<SymphonyLF__Inventor_Designer_Author__c> inventorsToBeInserted = new List<SymphonyLF__Inventor_Designer_Author__c>();
        List<SymphonyLF__Docketing_Activity__c> docketActivitiesToBeInserted = new List<SymphonyLF__Docketing_Activity__c>();
        //List<SymphonyLF__Docketing_Activity__c> docketActivityRecords = new List<SymphonyLF__Docketing_Activity__c>();
		List<SymphonyLF__Person__c> personsToBeInserted = new List<SymphonyLF__Person__c>();
		List<SymphonyLF__Client__c> clientsToBeInserted = new List<SymphonyLF__Client__c>();
        
        for(Asset_Intake_Form__c intakeForm : assetIntakeFormList){
            if(intakeForm.New_Patent_Family__c != '' && intakeForm.Patent_Family__c == null){
                SymphonyLF__Patent_Family__c patentFamily = new SymphonyLF__Patent_Family__c();
                patentFamily.SymphonyLF__Client__c = intakeForm.Client__c;
                patentFamily.SymphonyLF__Invention_Title__c = intakeForm.New_Patent_Family__c;
                patentFamily.Department__c = intakeForm.Department__c;
                patentFamily.Name = intakeForm.New_Patent_Family__c;
                patentFamily.SymphonyLF__Active__c = true;
                intakeFormNewPatentFamilyMap.put(intakeForm.Id, patentFamily);
                
            }
            intakeFormIds.add(intakeForm.Id);
        }
        
        if(!intakeFormNewPatentFamilyMap.isEmpty()){
            Insert intakeFormNewPatentFamilyMap.values();
            System.debug('intakeFormNewPatentFamilyMap ' + intakeFormNewPatentFamilyMap);
            for(String key: intakeFormNewPatentFamilyMap.keyset()){
                Asset_Intake_Form__c intakeFormUpd = new Asset_Intake_Form__c();
                intakeFormUpd.Id = key;
                intakeFormUpd.Patent_Family__c = intakeFormNewPatentFamilyMap.get(key).Id;
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
                , Asset_Intake_Form__c
                , Event_Name__c
                , Docket_Type__c
                , Event_Date__c
                , Due_Date__c
                , Assigned_To__c
                , Asset_Intake_Form__r.Client__c
                , Asset_Intake_Form__r.Patent_Family__c
                , Asset_Intake_Form__r.Patent_Family__r.Name 
                , Asset_Intake_Form__r.New_Patent_Family__c
                , Asset_Intake_Form__r.Department__c
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
                        , Type__c
                    FROM Asset_Intake_Personnel__c 
                    WHERE 
                        ID IN: personalIds 
                        OR 
                        Asset_Intake_Form__c IN: intakeFormNewPatentFamilyMap.keyset()
                ]
            );
            System.debug('intakePersonnelMap--->'+intakePersonnelMap);
        
        }
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
                        , Email__c
                        , Phone__c
                        , Nationality__c 
                        , Person__c
                        , Primary_Inventor__c
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
                    	, Applicant_Name__c
                        , Applicant__c
                        , US_CA_Entity_Size__c
                        , Applicant_Address__City__s
                        , Applicant_Address__CountryCode__s
                        , Applicant_Address__PostalCode__s
                        , Applicant_Address__StateCode__s
                        , Applicant_Address__Street__s
                        , Asset_Intake_Form__r.Client__c
                        , Asset_Intake_Form__r.Patent_Family__c 
                        , Currency__c
                    FROM 
                    Asset_Intake_Applicants__c 
                    WHERE 
                        ID IN: applicantIds 
                        OR Asset_Intake_Form__c IN: intakeFormNewPatentFamilyMap.keyset() 
                ]
            ); 
        }

        if(!jurisdictionIds.isEmpty() || !intakeFormNewPatentFamilyMap.isEmpty()){
            intakeJurisdictionMap = new Map<String, Asset_Intake_Jurisdiction__c >(
                [
                    SELECT 
                        Id, Event_Name__c, Event_Date__c, Assigned_To__c,Docket_Type__c,Due_Date__c,Asset_Intake_Form__c
                    FROM 
                    Asset_Intake_Jurisdiction__c 
                    WHERE 
                        ID IN: jurisdictionIds 
                        OR Asset_Intake_Form__c IN: intakeFormNewPatentFamilyMap.keyset() 
                ]
            ); 
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
                            memMO.SymphonyLF__Patent_Family__c = intakeFormNewPatentFamilyMap.get(key).Id;
                            if(personRecord.Client_Engagement_Model__c == null ){
                                memMO.SymphonyLF__Type__c = personRecord.Type__c;
                            }else{
                            memMO.SymphonyLF__Type__c = personRecord.Client_Engagement_Model__r.SymphonyLF__Type__c;
                            }
                            memToBeInserted.add(memMO);
                            System.debug('memToBeInserted-->'+memToBeInserted);
                        }
                        
                    }
                }
                if(!intakeInventorMap.isEmpty()){
                    system.debug('intakeInventorMap :'+intakeInventorMap);
                    for(Asset_Intake_Inventor__c inventorRec: intakeInventorMap.values()){
                        system.debug('inventor Rec :'+inventorRec);
                        if(inventorRec.Asset_Intake_Form__c == key ){
                            SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                            //inventor.SymphonyLF__Contact__c = inventorRec.Inventor_Designer_Author__r.SymphonyLF__Contact__c;
                            inventor.SymphonyLF__Contact__c = inventorRec.Person__c;
                            inventor.SymphonyLF__Type__c = 'Inventor';
                            inventor.SymphonyLF__Primary_Inventor__c = inventorRec.Primary_Inventor__c;
                            //inventor.Sequence__c = inventorRec.Sequence__c;
                            inventor.SymphonyLF__Patent_Family__c = intakeFormNewPatentFamilyMap.get(key).Id;
                            system.debug('inventor last :'+inventor);
                            inventorsToBeInserted.add(inventor);
                            
                            if(inventorRec.Inventor_Designer_Author__c == null){
                                SymphonyLF__Person__c person = new SymphonyLF__Person__c();
                                person.SymphonyLF__Type__c = 'Client';
                                person.SymphonyLF__Contact_Type__c = 'Inventor';
                                person.RecordTypeId = Schema.getGlobalDescribe().get('SymphonyLF__Person__c').getDescribe().getRecordTypeInfosByName().get('Innovator').getRecordTypeId();
                                person.SymphonyLF__Email__c = inventorRec.Email__c;
                                person.SymphonyLF__Phone_Number__c = inventorRec.Phone__c;
                                person.SymphonyLF__Nationality__c = inventorRec.Nationality__c;
                                personsToBeInserted.add(person);
                            }
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
                            applicant.SymphonyLF__Patent_Family__c = (intakeFormNewPatentFamilyMap.get(key)).Id;
                            chainOfTitleToBeInserted.add(applicant);
                            
                            if(applicantRec.Applicant__c == null){
                                SymphonyLF__Client__c client = new SymphonyLF__Client__c();
                                client.Name = applicantRec.Applicant_Name__c;
                                client.SymphonyLF__Client_Classification__c = applicantRec.Client_Classification__c;
                                client.SymphonyLF__Entity_Size__c = applicantRec.US_CA_Entity_Size__c;
                                client.SymphonyLF__Default_Billing_Currency__c = applicantRec.Currency__c;
                                clientsToBeInserted.add(client);
                            }
                        }
                    }
                }
                // if(!intakeJurisdictionMap.isEmpty()){

                //     for(Asset_Intake_Jurisdiction__c jurisdictionRec: intakeJurisdictionMap.values()){
                        
                //         if(jurisdictionRec.Asset_Intake_Form__c == key ){
                //             SymphonyLF__Docketing_Activity__c docketActivity = new SymphonyLF__Docketing_Activity__c();
                //             docketActivity.SymphonyLF__Event_Name__c = 	jurisdictionRec.Event_Name__c;
                //             docketActivity.SymphonyLF__Event_Date__c = jurisdictionRec.Event_Date__c;
                //             docketActivity.SymphonyLF__Assigned_To_User__c = jurisdictionRec.Assigned_To__c;
                //             docketActivity.SymphonyLF__Due_Date__c  = jurisdictionRec.Due_Date__c ;
                //             docketActivity.Docket_Type__c=jurisdictionRec.Docket_Type__c;
                //            // docket.SymphonyLF__Patent__c =  patentId;
                //             docketActivityRecords.get(jurisdiction.Id).add(docketActivity);
                            
                //         }
                //     }

                // }
                
            }
            
        }
        
       
        for(String assetIntake : intakeFormVsJurisdictions.keyset()){
            if(intakeFormVsJurisdictions.containskey(assetIntake)){
                for(Asset_Intake_Jurisdiction__c jurisdiction : intakeFormVsJurisdictions.get(assetIntake) ){
                    SymphonyLF__Patent__c mainPatent = new SymphonyLF__Patent__c();
                    mainPatent.SymphonyLF__Case_Type__c = jurisdiction.CaseType__c;
                    mainPatent.SymphonyLF__Client__c = jurisdiction.Asset_Intake_Form__r.Client__c;
                    mainPatent.SymphonyLF__Country__c = jurisdiction.Jurisdiction__c;
                    mainPatent.Name = jurisdiction.Asset_Intake_Form__r.New_Patent_Family__c;
                    mainPatent.SymphonyLF__Title__c = jurisdiction.Asset_Intake_Form__r.New_Patent_Family__c;
                    mainPatent.SymphonyLF__Patent_Family__c = jurisdiction.Asset_Intake_Form__r.Patent_Family__c;
                    mainPatent.Department__c = jurisdiction.Asset_Intake_Form__r.Department__c;
                    mainPatent.SymphonyLF__Client_Reference__c = jurisdiction.ClientReferenceNumber__c;
                    mainPatent.SymphonyLF__Patent_Status__c = 'Application Preparation';
                    mainPatent.SymphonyLF__Active__c = true;

                    patentRecords.put(jurisdiction.Id, mainPatent);
                    patentVsJurisdictionIdMap.put(mainPatent.Id, jurisdiction.Id);

                    SymphonyLF__Docketing_Activity__c docketActivity = new SymphonyLF__Docketing_Activity__c();
                    docketActivity.SymphonyLF__Event_Name__c = 	jurisdiction.Event_Name__c;
                    docketActivity.SymphonyLF__Event_Date__c = jurisdiction.Event_Date__c;
                    docketActivity.SymphonyLF__Assigned_To_User__c = jurisdiction.Assigned_To__c;
                    docketActivity.SymphonyLF__Due_Date__c  = jurisdiction.Due_Date__c ;
                    docketActivity.Docket_Type__c=jurisdiction.Docket_Type__c;
                    docketActivityRecords.put(jurisdiction.Id, docketActivity);

                    memRecords.put(jurisdiction.Id, new List<SymphonyLF__Matter_Engagement_Model__c>());
                    chainOfTitleRecords.put(jurisdiction.Id, new List<SymphonyLF__Chain_of_Title__c>());
                    inventorRecords.put(jurisdiction.Id, new List<SymphonyLF__Inventor_Designer_Author__c>());
                   // docketActivityRecords.put(jurisdiction.Id, new List<SymphonyLF__Docketing_Activity__c>());

                    if(jurisdictionVsRelations.containskey(jurisdiction.Id)){

                        for(Asset_Intake_Jurisdiction_Relations__c record : jurisdictionVsRelations.get(jurisdiction.Id)){
                            System.debug(record + ' ---- record');
                            if(record.InstanceType__c == 'Asset_Intake_Personnel__c' && intakePersonnelMap != null && intakePersonnelMap.containskey(record.Asset_Intake_Personnel__c)){
                                Asset_Intake_Personnel__c personnelRec =  intakePersonnelMap.get(record.Asset_Intake_Personnel__c);
                                SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
                                memMO.SymphonyLF__Client__c = personnelRec.Asset_Intake_Form__r.Client__c;
                                // if(personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c == 'Foreign Associate'){
                                //     memMO.SymphonyLF__Office_Agent__c = personnelRec.Personnel__c;
                                // }else{
                                //     memMO.SymphonyLF__Supervisor_Client_Contact__c = personnelRec.Personnel__c;
                                // }
                                memMO.Client_Engagement_Model__c = personnelRec.Client_Engagement_Model__c;
                                memMO.SymphonyLF__Assign_to_User__c = personnelRec.Personnel__c;
                                if(personnelRec.Client_Engagement_Model__c == null ){
                                    memMO.SymphonyLF__Type__c = personnelRec.Type__c;
                                }else{
                                    memMO.SymphonyLF__Type__c = personnelRec.Client_Engagement_Model__r.SymphonyLF__Type__c;
                                }
                                memRecords.get(jurisdiction.Id).add(memMO);
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
                                chainOfTitleRecords.get(jurisdiction.Id).add(applicant);
                            }
                            if(record.InstanceType__c == 'Asset_Intake_Inventor__c' && intakeInventorMap != null && intakeInventorMap.containskey(record.Asset_Intake_Inventor__c)){
                                Asset_Intake_Inventor__c inventorRec =  intakeInventorMap.get(record.Asset_Intake_Inventor__c);
                                SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                                inventor.SymphonyLF__Contact__c = inventorRec.Person__c;
                                inventor.SymphonyLF__Type__c = 'Inventor';
                                inventor.SymphonyLF__Primary_Inventor__c = inventorRec.Primary_Inventor__c;
                                //inventor.Sequence__c = inventorRec.Inventor_Designer_Author__r.Sequence__c;
                                inventorRecords.get(jurisdiction.Id).add(inventor);   
                            }
                            // if(intakeJurisdictionMap != null && intakeJurisdictionMap.containskey(record.Asset_Intake_Jurisdiction__c)){
                            //     Asset_Intake_Jurisdiction__c jurisdictionRec =  intakeJurisdictionMap.get(record.Asset_Intake_Jurisdiction__c);
                            //     SymphonyLF__Docketing_Activity__c docketActivity = new SymphonyLF__Docketing_Activity__c();
                            //     docketActivity.SymphonyLF__Event_Name__c = 	jurisdictionRec.Event_Name__c;
                            //     docketActivity.SymphonyLF__Event_Date__c = jurisdictionRec.Event_Date__c;
                            //     docketActivity.SymphonyLF__Assigned_To_User__c = jurisdictionRec.Assigned_To__c;
                            //     docketActivity.SymphonyLF__Due_Date__c  = jurisdictionRec.Due_Date__c ;
                            //     docketActivity.Docket_Type__c=jurisdictionRec.Docket_Type__c;
                            //     docketActivityRecords.get(jurisdiction.Id).add(docketActivity);
                            // }
                        }
                    }
                    
                }
            }
            
        }
        
        if(patentRecords.isEmpty()) return;
		system.debug('patentRecords :'+patentRecords);
        Insert patentRecords.values();
        
        
        for(String key: patentRecords.keyset()){
            String patentId = patentRecords.get(key).Id;
            newPatentIds.add(patentId);
            for(SymphonyLF__Matter_Engagement_Model__c mems : memRecords.get(key)){
                System.debug('mems ' + mems);
                mems.SymphonyLF__Patent__c = patentId;
                memToBeInserted.add(mems);
            }
            for(SymphonyLF__Chain_of_Title__c chainOfTitle : chainOfTitleRecords.get(key)){
                System.debug('chainOfTitle ' + chainOfTitle);
                chainOfTitle.SymphonyLF__Patent__c = patentId;
                chainOfTitleToBeInserted.add(chainOfTitle);
            }
            for(SymphonyLF__Inventor_Designer_Author__c inventor : inventorRecords.get(key)){
                System.debug('inventor ' + inventor);
                inventor.SymphonyLF__Patent__c = patentId;
                inventorsToBeInserted.add(inventor);
            }
           if(docketActivityRecords.containskey(key) && docketActivityRecords.get(key) != null){
                SymphonyLF__Docketing_Activity__c docket = docketActivityRecords.get(key);
                    docket.SymphonyLF__Patent__c = patentId;
                    docketActivitiesToBeInserted.add(docket);
           }
        }
        
        List<SymphonyLF__Matter_Engagement_Model__c> existingMEMs = [
            SELECT 
                Id 
            FROM SymphonyLF__Matter_Engagement_Model__c 
            WHERE SymphonyLF__Patent__c IN: newPatentIds
        ];
       
        if(!existingMEMs.isEmpty()){
            DELETE existingMEMs;
        }
        
        if(!memToBeInserted.isEmpty()){
            System.debug('memToBeInserted before insert-->'+memToBeInserted);
            Insert memToBeInserted;
        }
        
        if(!chainOfTitleToBeInserted.isEmpty()){
            Insert chainOfTitleToBeInserted;
        }
        
        if(!inventorsToBeInserted.isEmpty()){
            Insert inventorsToBeInserted;
        }
        
        // if(!personsToBeInserted.isEmpty())
        //     insert personsToBeInserted;

        if(!clientsToBeInserted.isEmpty())
            insert clientsToBeInserted;

        if(!docketActivitiesToBeInserted.isEmpty())
            insert docketActivitiesToBeInserted;
        
        System.debug('memToBeInserted ' + memToBeInserted.size());
        System.debug('inventorsToBeInserted ' + inventorsToBeInserted.size());
        System.debug('chainOfTitleToBeInserted ' + chainOfTitleToBeInserted.size());
        
        
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
}