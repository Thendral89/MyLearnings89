public with sharing class PatentIntakeFormHelperNew {
    
    /**
     * @description         Saves the PAIF form related records
     * @param  jsonString   input JSON string
     * @param  userId       To check access across DML operations
     * @return Reponse      Wrapper with Patent Family ID, Status, and Errors List
     */


    @AuraEnabled(cacheable=false)
    public static Response saveRecord(String jsonString,String userId) {
        Savepoint sp = Database.setSavepoint();
        Boolean status = false;
        Response response = new Response();
        List<ErrorDetail> errorList = new List<ErrorDetail>();
        String strAuditTrailLogText = ''; 
        // List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
        // List<String> contentVersionIds =  new List<String>();   // No Use of it in this Code uptil now
        
        try{
            if (jsonString != null){
                System.debug(jsonString);
                recordWrapper wrapperRecord = (recordWrapper) JSON.deserialize(jsonString, recordWrapper.class);
                ID patentFamilyID = null;
                if (wrapperRecord != null){
                    System.debug('jsonString' + jsonString);
                    IntakeFormClientEngageHelper.updateClientRecord(wrapperRecord.ClientId, wrapperRecord.conflictCheckId);
                    List<SymphonyLF__Matter_Engagement_Model__c> PFMEMs = new List<SymphonyLF__Matter_Engagement_Model__c>();
                    Boolean existingPatentFamily = wrapperRecord.Source == 'An Existing Patent Family' ? true : false;
                    if(!existingPatentFamily){ // New patent family
                        // Create a new Patent  Family record
                        List<SymphonyLF__Patent_Family__c> patentFamilyList = new List<SymphonyLF__Patent_Family__c>();
                        SymphonyLF__Patent_Family__c patentFamily = new SymphonyLF__Patent_Family__c();
                        patentFamily.SymphonyLF__Client__c = wrapperRecord.ClientId;
                        patentFamily.SymphonyLF__Invention_Title__c = wrapperRecord.PatentFamily.title;
                        // patentFamily.SymphonyLF__Invention_Date__c = wrapperRecord.PatentFamily.inventionDate;
                        patentFamily.Name = wrapperRecord.PatentFamily.shortTitle;
                       // patentFamily.Client_Reference__c = wrapperRecord.PatentFamily.clientReference;
                        // patentFamily.SymphonyLF__Earliest_Priority_Date__c = wrapperRecord.PatentFamily.earliestPriorityDate;
                        //patentFamily.SymphonyLF__Invention_Description__c = wrapperRecord.PatentFamily.inventionDescription;
                        patentFamily.SymphonyLF__Active__c = true;
                        patentFamilyList.add(patentFamily);
                        system.debug('patentFamilyList-->'+patentFamilyList);
                        INSERT patentFamilyList;
                        if(!patentFamilyList.isEmpty()){
                            patentFamilyID = patentFamilyList[0].id;
                        }
                        
                        if(wrapperRecord.PatentFamily.engagementDetails.size() > 0){
                        
                            for(CEMwrapper wrap: wrapperRecord.PatentFamily.engagementDetails){
                                if(wrap.personId != ''){
                                    SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
                                    memMO.SymphonyLF__Client__c = wrapperRecord.ClientId;
                                    if(wrap.type == 'Foreign Associate'){
                                        memMO.SymphonyLF__Office_Agent__c = wrap.personId;
                                    }else{
                                        memMO.SymphonyLF__Supervisor_Client_Contact__c = wrap.personId;
                                    }
                                    
                                    memMO.SymphonyLF__Patent_Family__c = patentFamilyID;
                                    memMO.SymphonyLF__Type__c = wrap.type;
                                    PFMEMs.add(memMO);
                                }
                            }
                        }
  
                    }
                    else{   //  Existing patent family
                        patentFamilyID = (ID)wrapperRecord.PatentFamily.PatentFamilyId;
                        if(wrapperRecord.PatentFamily.engagementDetails.size() > 0){
                        
                            for(CEMwrapper wrap: wrapperRecord.PatentFamily.engagementDetails){
                                if(wrap.personId != '' && wrap.isAlreadyCreated == false){
                                    SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
                                    memMO.SymphonyLF__Client__c = wrapperRecord.ClientId;
                                    if(wrap.type == 'Foreign Associate'){
                                        memMO.SymphonyLF__Office_Agent__c = wrap.personId;
                                    }else{
                                        memMO.SymphonyLF__Supervisor_Client_Contact__c = wrap.personId;
                                    }
                                    
                                    memMO.SymphonyLF__Patent_Family__c = patentFamilyID;
                                    memMO.SymphonyLF__Type__c = wrap.type;
                                    PFMEMs.add(memMO);
                                }
                            }
                        }
                    }

                    if (PFMEMs.size() > 0){
                        INSERT PFMEMs;
                    }

                    List<SymphonyLF__Patent__c> allPatents = new List<SymphonyLF__Patent__c>();
                    List<SymphonyLF__Patent__c> allExistingSelectedPriorities = new List<SymphonyLF__Patent__c>();
                    for (ApplicationDetails wrapperApplicationDetails: wrapperRecord.ApplicationDetails){
                        SymphonyLF__Patent__c mainPatent = new SymphonyLF__Patent__c();
                        mainPatent.SymphonyLF__Case_Type__c = wrapperApplicationDetails.caseTypeValue;
                        mainPatent.SymphonyLF__Client_Reference__c = wrapperApplicationDetails.clientRefNo;
                        mainPatent.SymphonyLF__Client__c = (ID)wrapperRecord.ClientId;
                        mainPatent.SymphonyLF__Country__c = (ID)wrapperApplicationDetails.jurisdictionId;
                        mainPatent.Name = wrapperRecord.PatentFamily.shortTitle; // Check Once
                        mainPatent.SymphonyLF__UniqueId__c = wrapperApplicationDetails.uniqueId;
                        mainPatent.SymphonyLF__Patent_Family__c = patentFamilyID;
                        mainPatent.SymphonyLF__Title__c = wrapperRecord.PatentFamily.title;
                       mainPatent.Pat_or_prosecution_docketing_needed__c = wrapperApplicationDetails.patOrProsecutionDN;
                       mainPatent.IPR_docketing_required__c = wrapperApplicationDetails.IPRdocketReq;
                        mainPatent.opposition_docketing_required__c = wrapperApplicationDetails.OppDocketReq;
                        mainPatent.Litigation_docketing_required__c = wrapperApplicationDetails.litigationDocketReq;

                        //mainPatent.Client_Reference__c = wrapperRecord.PatentFamily.clientReference;
                        mainPatent.SymphonyLF__Patent_Status__c = 'Application Preparation';
                        mainPatent.SymphonyLF__Active__c = true;
                        //mainPatent.Portfolio_Management__c = 'Managed by HE';
                        mainPatent.SymphonyLF__IP_Matter__c = wrapperApplicationDetails.assetType;
                        mainPatent.Will_client_access_their_files_on_docket__c = wrapperApplicationDetails.clientAccessToFileDocket;
                        mainPatent.Is_MCC_responsible_for_annuities__c = wrapperApplicationDetails.responsibleForAnnuities;
                        mainPatent.Did_you_advise_Client_on_Annuity_Policy__c = wrapperApplicationDetails.clientOnAnnuityPolicy;
                        if(Boolean.valueOf(wrapperApplicationDetails.renewalsAnnuities))
                        {
                            mainPatent.SymphonyLF__Renewal_Managed_by_Lawfirm_1__c = 'Yes';
                        }
                        else
                        {
                            mainPatent.SymphonyLF__Renewal_Managed_by_Lawfirm_1__c = 'No';
                        }
                        //mainPatent.SymphonyLF__Renewal_Managed_by_Lawfirm_1__c=Boolean.valueOf(wrapperApplicationDetails.renewalsAnnuities);
                        mainPatent.SymphonyLF__Auto_assign_mems__c=false;
                        if (wrapperApplicationDetails.caseTypeValue == 'Primary'){
                          //  mainPatent.Patent_Filing_Instruction_Status__c = 'Attorney Drafting/Review';
                        }else if(wrapperApplicationDetails.caseTypeValue == 'EP Validation'){
                           // mainPatent.EP_Validation_Instruction_Status__c = 'Paralegal Review';
                        }else if(wrapperApplicationDetails.caseTypeValue != 'Primary'){
                            //mainPatent.Patent_Filing_Instruction_Status__c = 'Foreign/Filing Team Review';
                        }
                        allPatents.add(mainPatent);

                        for (SelectedPriorities selectedPriority: wrapperApplicationDetails.selectedPriorities){
                            String timeStamp = String.valueOf(DateTime.now().getTime());
                            if(selectedPriority.Id == ''){
                                SymphonyLF__Patent__c patent = new SymphonyLF__Patent__c();
                                patent.SymphonyLF__Client__c = (ID)wrapperRecord.ClientId;
                                patent.SymphonyLF__Country__c = (ID)selectedPriority.jurisdiction;
                                patent.SymphonyLF__Application_Date__c = selectedPriority.filingDate;
                                patent.SymphonyLF__Filing_Number__c = selectedPriority.filingNumber;
                                patent.SymphonyLF__Patent_Number__c = selectedPriority.patentNumber;
                                //patent.Client_Reference__c = selectedPriority.clientReference;
                                patent.SymphonyLF__Case_Type__c = selectedPriority.caseType;
                                //patent.SymphonyLF__Asset_Type__c = selectedPriority.ipMatter;
                                patent.Name = selectedPriority.shortTitle;
                                patent.SymphonyLF__Title__c = selectedPriority.title;
                                patent.SymphonyLF__UniqueId__c = wrapperApplicationDetails.uniqueId + '_' + timeStamp + 'N-PR';
                                patent.SymphonyLF__Patent_Family__c = patentFamilyID;
                                patent.SymphonyLF__Patent_Family__c=selectedPriority.patentFamily;
                                patent.SymphonyLF__IP_Matter__c = selectedPriority.priorityAssetType;
                                // patent.SymphonyLF__Patent_Status__c = ''; // TBD
                                patent.SymphonyLF__Active__c = true;
                                patent.SymphonyLF__Auto_assign_mems__c=false;
                                //patent.Portfolio_Management__c = selectedPriority.portfolioManagement;
                                allPatents.add(patent);
                            }
                            else{
                                SymphonyLF__Patent__c patent = new SymphonyLF__Patent__c();
                                patent.ID = (ID)selectedPriority.Id;
                                patent.SymphonyLF__UniqueId__c = wrapperApplicationDetails.uniqueId + '_' + timeStamp + 'E-PR';
                                allExistingSelectedPriorities.add(patent);
                            }
                        }
                    }

                    if(!allPatents.isEmpty()){
                        INSERT allPatents;
                    }
                    
                    
                    // UPDATE allExistingSelectedPriorities; // No need to update Unique ID on Existing Patents(Priorities) in ORG, we can use it Temorarily
                    allPatents.addAll(allExistingSelectedPriorities);
                    // Database.UpsertResult[] upsertResults = Database.upsert(allPatents, SymphonyLF__Patent__c.UniqueId__c);

                    // Inserting Realted IP Matters
                    // Map of - Priority Patent UniqueId <--> ParentPatentUniqueId
                    Map<String,String> allPRPatentsUniqueIds = new Map<String,String>();
                    Map<String,ID> allParentPatentIDs = new Map<String,ID>();
                    for (SymphonyLF__Patent__c patent: allPatents){
                        if (patent.SymphonyLF__UniqueId__c.endsWith('-PR')){
                            String tempVal = patent.SymphonyLF__UniqueId__c.split('_')[0];
                            allPRPatentsUniqueIds.put(patent.SymphonyLF__UniqueId__c,tempVal);
                        }else{
                            allPRPatentsUniqueIds.put(patent.SymphonyLF__UniqueId__c,patent.SymphonyLF__UniqueId__c);
                            allParentPatentIDs.put(patent.SymphonyLF__UniqueId__c,patent.ID);
                        }
                    }
                    List<SymphonyLF__Related_IP_Matter__c> allRelatedIpMatter = new List<SymphonyLF__Related_IP_Matter__c>();
                    for (SymphonyLF__Patent__c patent: allPatents) {
                        if (patent.SymphonyLF__UniqueId__c.endsWith('-PR')){
                            SymphonyLF__Related_IP_Matter__c relatedIpMatter = new SymphonyLF__Related_IP_Matter__c();
                            //relatedIpMatter.SymphonyLF__Client__c = (ID)wrapperRecord.ClientId;
                            relatedIpMatter.SymphonyLF__Patent__c = allParentPatentIDs.get(allPRPatentsUniqueIds.get(patent.SymphonyLF__UniqueId__c));
                            relatedIpMatter.SymphonyLF__Referenced_Patent__c = patent.id;
                            relatedIpMatter.SymphonyLF__Relation_Type__c = 'Priority';
                            allRelatedIpMatter.add(relatedIpMatter);                        
                        }
                    }
                    
                    if(!allRelatedIpMatter.isEmpty()){
                        INSERT allRelatedIpMatter;
                    }


                    List<SymphonyLF__Matter_Business_Category__c> allBusinessCategory = new List<SymphonyLF__Matter_Business_Category__c>();
                    List<SymphonyLF__Matter_Engagement_Model__c> MEMs = new List<SymphonyLF__Matter_Engagement_Model__c>();
                    List<SymphonyLF__Docketing_Activity__c> docketActivityList = new List<SymphonyLF__Docketing_Activity__c>();
                    List<SymphonyLF__Keyword_Association__c> allKeywordAssocation = new List<SymphonyLF__Keyword_Association__c>();
                    
                    for(BusinessCategory wrapperBusinessCategory: wrapperRecord.BusinessCategory){
                        if(wrapperBusinessCategory.existing != true){
                            SymphonyLF__Matter_Business_Category__c businessCategoryPF = new SymphonyLF__Matter_Business_Category__c();
                            businessCategoryPF.SymphonyLF__Client_Business_Category_New__c = (ID)wrapperBusinessCategory.id;
                           businessCategoryPF.Patent_Family__c = patentFamilyID;
                            allBusinessCategory.add(businessCategoryPF);
                       }
                        
                    }

                    for (keyword record: wrapperRecord.keywords){
                        if(record.existing != true){
                            SymphonyLF__Keyword_Association__c associationRec = new SymphonyLF__Keyword_Association__c();
                            associationRec.SymphonyLF__Patent_Family__c = patentFamilyID;
                            associationRec.SymphonyLF__Keyword__c = record.key;
                            allKeywordAssocation.add(associationRec);
                        }
                        
                    }

                    
                    // MEM and Docket Activities and Business Category for Patent
                    for (ApplicationDetails wrapperApplicationDetails: wrapperRecord.ApplicationDetails){
                        
                        if(wrapperApplicationDetails.engagementDetailsPatent.size() > 0){
                            

                            for(CEMwrapper wrap: wrapperApplicationDetails.engagementDetailsPatent){
                                if(wrap.personId != ''){
                                    SymphonyLF__Matter_Engagement_Model__c memMO = new SymphonyLF__Matter_Engagement_Model__c();
                                    memMO.SymphonyLF__Client__c = wrapperRecord.ClientId;
                                    if(wrap.type == 'Foreign Associate'){
                                        memMO.SymphonyLF__Office_Agent__c = wrap.personId;
                                    }else{
                                        memMO.SymphonyLF__Supervisor_Client_Contact__c = wrap.personId;
                                    }
                                    
                                    memMO.SymphonyLF__Patent__c = allParentPatentIDs.get(wrapperApplicationDetails.uniqueId);
                                    memMO.SymphonyLF__Type__c = wrap.type;
                                    MEMs.add(memMO);
                                }
                            }
                        }
                        if(wrapperApplicationDetails.docketActivities.size() > 0){
                            
                            for(DocketActivity docActivity : wrapperApplicationDetails.docketActivities){
                                
                                if(docActivity.eventName != '' && docActivity.eventDate != '' &&  docActivity.dueDate != '' && (docActivity.assignToUser != '' || docActivity.assignToTeam != '' )){
                                    SymphonyLF__Docketing_Activity__c doc= new SymphonyLF__Docketing_Activity__c();
                                    doc.SymphonyLF__Event_Name__c = docActivity.eventName;
                                    doc.SymphonyLF__Event_Date__c = date.valueOf(docActivity.eventDate);
                                    doc.SymphonyLF__Due_Date__c = date.valueOf(docActivity.dueDate);
                                    if(docActivity.assignToUser != ''){
                                        doc.SymphonyLF__Assigned_To_User__c = docActivity.assignToUser;
                                    }
                                    if(docActivity.assignToTeam != ''){
                                        doc.SymphonyLF__Assigned_To_Team__c = docActivity.assignToTeam;
                                    }
                                    if(docActivity.nameLabel == 'Hard Docket Event Name'){
                                        doc.Docket_Type__c = 'Hard Docket';
                                    }else if(docActivity.nameLabel == 'Soft Docket Event Name'){
                                        doc.Docket_Type__c = 'Soft Docket';
                                    }
                                    doc.SymphonyLF__Patent__c = allParentPatentIDs.get(wrapperApplicationDetails.uniqueId);
                                    doc.SymphonyLF__Status__c = 'Open';
                                    docketActivityList.add(doc);
                                }
                                
                            }
                        }
                        if(wrapperApplicationDetails.selectedBusinessInfos.size() > 0){
                            

                            for(BusinessCategory wrapperBusinessCategory: wrapperApplicationDetails.selectedBusinessInfos){
                                SymphonyLF__Matter_Business_Category__c businessCategory = new SymphonyLF__Matter_Business_Category__c();
                                businessCategory.SymphonyLF__Client_Business_Category_New__c = (ID)wrapperBusinessCategory.id;
                                businessCategory.SymphonyLF__Patent__c = allParentPatentIDs.get(wrapperApplicationDetails.uniqueId);
                                allBusinessCategory.add(businessCategory);
                            }
                        }

                        if(wrapperApplicationDetails.selectedkeywords.size() > 0){
                            
                            for(keyword record: wrapperApplicationDetails.selectedkeywords){
                                SymphonyLF__Keyword_Association__c keywordAssocation = new SymphonyLF__Keyword_Association__c();
                                keywordAssocation.SymphonyLF__Keyword__c = record.key;
                                keywordAssocation.SymphonyLF__Patent__c = allParentPatentIDs.get(wrapperApplicationDetails.uniqueId);
                                allKeywordAssocation.add(keywordAssocation);
                            }
                        }
                    }
                 
                    if (MEMs.size() > 0){
                        INSERT MEMs;
                    }
                    if (docketActivityList.size() > 0 ){
                        INSERT docketActivityList;
                    }
                    if(!allBusinessCategory.isEmpty()){
                        INSERT allBusinessCategory;
                    }   

                    

                    if(!allKeywordAssocation.isEmpty()){
                        INSERT allKeywordAssocation;
                    }   
                    

                    // File attaching to Patents - TBD
                    // if(wrapperRecord.FileDetails !=null ) {     
                    //     for(FileDetails file : wrapperRecord.FileDetails){
                    //         if(file.contentDocumentId != ''){
                    //             for (SymphonyLF__Patent__c patent: allPatents){
                    //                 if (!patent.UniqueId__c.endsWith('-PR')){
                    //                     ContentDocumentLink contentLink = new ContentDocumentLink();
                    //                     contentLink.LinkedEntityId = patent.id;
                    //                     contentLink.contentdocumentid = file.contentDocumentId;
                    //                     contentLink.ShareType = 'V';
                    //                     contentLinks.add(contentLink);
                    //                     contentVersionIds.add(file.contentVersionId);
                    //                 }
                    //             }
                    //         }
                    //     }
                    //     if(contentLinks.size()>0){
                    //         UPSERT contentLinks;
                    //         System.debug('contentLinks ID: '+contentLinks);
                    //     }            
                    // }

                    // Applicants for PatentFamily (New or Existing PF)
                   
                    List<SymphonyLF__Chain_of_Title__c> PFChainOfTitleList = new List<SymphonyLF__Chain_of_Title__c>();
                    for (SelectedApplicants selectedApplicant: wrapperRecord.Applicants){
                     
                            SymphonyLF__Chain_of_Title__c applicant = new SymphonyLF__Chain_of_Title__c();
                            applicant.SymphonyLF__Client__c = selectedApplicant.key;
                            applicant.SymphonyLF__Role__c = 'Applicant';
                            applicant.SymphonyLF__Current__c = true;
                            applicant.SymphonyLF__Patent_Family__c = patentFamilyID;
                            applicant.SymphonyLF__Registered_Applicant__c=selectedApplicant.registeredApplicant;
                            if(selectedApplicant.addressedit != null){
                                applicant.SymphonyLF__Address__City__s=selectedApplicant.addressedit.city;
                                applicant.SymphonyLF__Address__CountryCode__s=selectedApplicant.addressedit.country;
                                applicant.SymphonyLF__Address__StateCode__s=selectedApplicant.addressedit.state;
                                applicant.SymphonyLF__Address__Street__s=selectedApplicant.addressedit.street;
                                applicant.SymphonyLF__Address__PostalCode__s=selectedApplicant.addressedit.postalCode;
                            }
                            if(selectedApplicant.existingApplicantId != null && selectedApplicant.existingApplicantId != ''){
                                applicant.Id = selectedApplicant.existingApplicantId;
                            }
                            
                            
                            PFChainOfTitleList.add(applicant);
                     
                        
                    }
                    
                    // Selected Applicants for Patent
                    List<SymphonyLF__Chain_of_Title__c> PatentApplicantsList = new List<SymphonyLF__Chain_of_Title__c>();
                    for (ApplicationDetails wrapperApplicationDetails: wrapperRecord.ApplicationDetails){
                        for (SelectedApplicants selectedApplicant: wrapperApplicationDetails.selectedApplicants){
                            SymphonyLF__Chain_of_Title__c applicant = new SymphonyLF__Chain_of_Title__c();
                            applicant.SymphonyLF__Client__c = (ID)selectedApplicant.key;
                            applicant.SymphonyLF__Role__c = 'Applicant';
                            applicant.SymphonyLF__Current__c = true;
                            applicant.SymphonyLF__Patent__c = allParentPatentIDs.get(wrapperApplicationDetails.uniqueId);
                            applicant.SymphonyLF__Registered_Applicant__c=selectedApplicant.registeredApplicant;
                            if(selectedApplicant.addressedit != null){
                                applicant.SymphonyLF__Address__City__s=selectedApplicant.addressedit.city;
                                applicant.SymphonyLF__Address__CountryCode__s=selectedApplicant.addressedit.country;
                                applicant.SymphonyLF__Address__StateCode__s=selectedApplicant.addressedit.state;
                                applicant.SymphonyLF__Address__Street__s=selectedApplicant.addressedit.street;
                                applicant.SymphonyLF__Address__PostalCode__s=selectedApplicant.addressedit.postalCode;
                            }
                           
                            PatentApplicantsList.add(applicant);
                        }
                        
                    }
                    
                    PFChainOfTitleList.addAll(PatentApplicantsList);
                    
                    if(!PFChainOfTitleList.isEmpty()){
                        UPSERT PFChainOfTitleList;
                    }
                        
                    List<SymphonyLF__Inventor_Designer_Author__c> PFinventorsListSequenceEmtpy = new List<SymphonyLF__Inventor_Designer_Author__c>();
                    
                  for (Inventor currentInventor: wrapperRecord.Inventors){
                            SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                           
                            if(currentInventor.existingRecId != null && currentInventor.existingRecId != ''){
                                inventor.Id = currentInventor.existingRecId;
                                // inventor.SymphonyLF__Patent_Family__c = patentFamilyID;
                                inventor.Sequence__c = null;
                                inventor.SymphonyLF__Primary_Inventor__c = false;
                                PFinventorsListSequenceEmtpy.add(inventor);
                            }
                            
                            
                            
                  }
                  if(!PFinventorsListSequenceEmtpy.isEmpty()){
                    update PFinventorsListSequenceEmtpy;
                  }
                  
                    // Inventors for PatentFamily (New or Existing PF)
                  
                    List<SymphonyLF__Inventor_Designer_Author__c> PFinventorsList = new List<SymphonyLF__Inventor_Designer_Author__c>();
                    for (Inventor currentInventor: wrapperRecord.Inventors){
                        
                            SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                            inventor.SymphonyLF__Contact__c = (ID)currentInventor.key;
                            inventor.SymphonyLF__Patent_Family__c = patentFamilyID;
                            inventor.SymphonyLF__Type__c = 'Inventor';
                            if(currentInventor.existingRecId != null && currentInventor.existingRecId != ''){
                                inventor.Id = currentInventor.existingRecId;
                            }
                            // if(currentInventor.existingRecId == null && currentInventor.primary != null && currentInventor.primary == true){
                            if(currentInventor.primary != null){
                                inventor.SymphonyLF__Primary_Inventor__c = currentInventor.primary;
                            }
                                
                            // }
                            if(currentInventor.sequence != null){
                                inventor.Sequence__c = currentInventor.sequence;
                            }
                            
                            PFinventorsList.add(inventor);
                        
                    }

                    // Selected Inventors for Patent
                    List<SymphonyLF__Inventor_Designer_Author__c> PatentInventorsList = new List<SymphonyLF__Inventor_Designer_Author__c>();
                    for (ApplicationDetails wrapperApplicationDetails: wrapperRecord.ApplicationDetails){
                        for (Inventor selectedInventor: wrapperApplicationDetails.selectedInventors){
                            SymphonyLF__Inventor_Designer_Author__c inventor = new SymphonyLF__Inventor_Designer_Author__c();
                            inventor.SymphonyLF__Contact__c = (ID)selectedInventor.key;
                            inventor.SymphonyLF__Patent__c = allParentPatentIDs.get(wrapperApplicationDetails.uniqueId);
                            inventor.SymphonyLF__Type__c = 'Inventor';
                            if(selectedInventor.primary != null){
                                inventor.SymphonyLF__Primary_Inventor__c = selectedInventor.primary;
                            }
                            if(selectedInventor.sequence != null){
                                inventor.Sequence__c = selectedInventor.sequence;
                            }
                            PatentInventorsList.add(inventor);
                        }
                    }

                    PFinventorsList.addAll(PatentInventorsList);
                    
                    if(!PFinventorsList.isEmpty()){
                        UPSERT PFinventorsList;
                    }
                   
                    response.PatentFamilyID = (String)patentFamilyID;
                    response.Status = true;
                    status=true;
                    strAuditTrailLogText +='Successfully saved PAIF records.';
                }
                else
                {
                    ErrorDetail errorDetail = new ErrorDetail();
                    errorDetail.Code='ERR001';
                    response.message = 'Details are null or empty';
                    errorDetail.Description = 'Details are null or empty';
                    errorList.add(errorDetail);
                    response.Errors = errorList;
                }
                 
            }
        }
        // ***************************** Boiler Plate ***********************************
        catch(Exception exp)
        {
            Database.RollBack(sp);
            String errMessage = '';
            if(exp.getMessage().contains('first error:')){
                errMessage = exp.getMessage().substringAfter('first error:');
            }else{
                errMessage = exp.getMessage().substringAfter('Exception:');
            }
            response.message = errMessage;
            ErrorDetail errorDetail = new ErrorDetail();
            errorDetail.Code='EXP001';
            errorDetail.Description = 'Exception Occurred. Message -'+exp.getMessage()+' |StackTrace - '+exp.getStackTraceString()+' |linenumber - '+exp.getLineNumber();
            errorList.add(errorDetail);
            system.debug('Exception-11111'+exp.getMessage()+'|Line number - '+exp.getLineNumber()+' |StackTrace - '+exp.getStackTraceString());
             status = false;
            strAuditTrailLogText +=' Error:'+ exp.getMessage()+'|Line number - '+exp.getLineNumber()+' |StackTrace - '+exp.getStackTraceString();
        }
        finally
        {
            // Audit record creation
             HelperAudit.updateAudit('PatentIntakeFormHelperNew', strAuditTrailLogText, status);
        }
        if(errorList.size() > 0)
        {
            response.Status = false;
            response.Errors = errorList;
        }
        return response;
    }

    /**
     * @description                     Return Applicants and Inventors to UI
     * @param  clientID                 to use in SOQL
     * @return ConfigData               Wrapper of Applicants and Inventors
     * @written by                      Sneha B
     */
    @AuraEnabled
    public static ConfigData GetApplicantsAndInventors(string clientId)
    {
        ConfigData data=new ConfigData();
        try
        {//client _reference__c is removed in this query because of unmanaged field
           data.patentFamily=[SELECT Id,SymphonyLF__Invention_Title__c,SymphonyLF__Earliest_Priority_Date__c,SymphonyLF__Extended_Family__c,SymphonyLF__Invention_Date__c,SymphonyLF__Docket_Number__c,SymphonyLF__Family_Status__c,SymphonyLF__Short_Title_Hyperlink__c,Name,SymphonyLF__Family_ID__c FROM SymphonyLF__Patent_Family__c WHERE SymphonyLF__Client__c=:clientId];
            List<SymphonyLF__Client__c> client = [SELECT SymphonyLF__Client_Group_Number__c from SymphonyLF__Client__c WHERE Id=:clientId];
            if(client.size() > 0)
            {
                data.applicants = [SELECT Name,SymphonyLF__Address__c FROM SymphonyLF__Client__c WHERE SymphonyLF__Client_Group_Number__c=:client[0].SymphonyLF__Client_Group_Number__c AND SymphonyLF__Client_Classification__c INCLUDES ('Applicant')];
            }
            data.inventors = [SELECT Name,SymphonyLF__Contact_Type__c,SymphonyLF__Email__c,SymphonyLF__Address__c FROM SymphonyLF__Person__c where SymphonyLF__Contact_Type__c='Inventor' AND SymphonyLF__Client__c=:clientId];
        }
        catch(exception e)
        {
            system.debug('error-'+e.getMessage()+ '||' + e.getStacktraceString());
        }
        return data;
    }


    @AuraEnabled
    public static Map<String,String> getPicklistValuesMethod(String objectName, String fieldName){
       
       Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
       Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
       Schema.DescribeFieldResult fieldDescribe = describeResult.fields.getMap().get(fieldName).getDescribe();
       List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        Map<String,String> valueVsLabel = new Map<String,String>();
        For(Schema.PicklistEntry sp : picklistEntries){
            
            valueVsLabel.put(sp.getValue(), sp.getLabel());
        }
        return valueVsLabel;
    }
    
    @AuraEnabled
    public static List<CEMwrapper>  getClientCEMdetails(String clientId, String moduleName, Boolean allJurisdiction, String jurisdictionId ){
        system.debug(clientID + ' --- ' + moduleName + ' --- ' + allJurisdiction + ' ---- ' + jurisdictionId);
        Map<String,String> picklistValues = getPicklistValuesMethod('SymphonyLF__Client_Engagement_Model__c', 'SymphonyLF__Type__c');
        system.debug(picklistValues);
        List<String> CEMipMatters = new List<String> {moduleName, 'All'};
        String CEMquery = 'SELECT SymphonyLF__Jurisdiction__c, SymphonyLF__Jurisdiction__r.Name, SymphonyLF__Office_Agent__c, SymphonyLF__Office_Agent__r.Name, SymphonyLF__Type__c, SymphonyLF__Person__c, SymphonyLF__Person__r.Name from SymphonyLF__Client_Engagement_Model__c where SymphonyLF__Client__c = \'' + clientId + '\' AND SymphonyLF__IP_Matters__c INCLUDES (\'' + String.join(CEMipMatters, '\',\'') + '\') AND ';
        if(jurisdictionId != ''){
            CEMquery += '  SymphonyLF__Jurisdiction__c = \'' + jurisdictionId + '\'  ORDER by CreatedDate ASC limit 10000';
            
        }else{
            CEMquery += ' SymphonyLF__Applicable_to_all_jurisdiction__c = ' + allJurisdiction + ' ORDER by CreatedDate ASC limit 10000';
        }
        System.debug('-->'+CEMquery);
        List<SymphonyLF__Client_Engagement_Model__c> orgCEM = (List<SymphonyLF__Client_Engagement_Model__c>)Database.query(CEMquery);
        
        Map<String , CEMwrapper> pickListWrapperMap = new Map<String , CEMwrapper>();
        for(String str : picklistValues.keyset()){
            CEMwrapper wrap = new CEMwrapper();
            wrap.type = str;
            wrap.label = picklistValues.get(str);
            wrap.placeholder = 'Select ' + picklistValues.get(str);
            wrap.personId = '';
            wrap.personName = '';
            wrap.errorClass = '';
            wrap.errorMessage = '';
            wrap.required = str == 'Responsible Partner' ? true : false;
            wrap.objectName = str == 'Foreign Associate' ? 'SymphonyLF__Office_Agent__c' : 'SymphonyLF__Person__c';
            wrap.fieldNames = str == 'Foreign Associate' ? 'Name,SymphonyLF__Type__c' : 'Name,SymphonyLF__Type__c';
            wrap.whereCondition = str == 'Foreign Associate' ? 'SymphonyLF__Type__c=\'Office\' OR SymphonyLF__Type__c=\'Agent\'' : 'SymphonyLF__Type__c=\'Attorney\'';
            if(str == 'Backup Attorney' || str == 'Managing Partner' || str == 'Responsible Partner' || str == 'Responsible Attorney' || str == 'Working Attorney' || str == 'Foreign Associate' ){
                wrap.isVisible = true;
            }else{
                wrap.isVisible = false;
            }
            pickListWrapperMap.put(str, wrap );
        }
        for(SymphonyLF__Client_Engagement_Model__c cem : orgCEM){
            if(pickListWrapperMap.containskey(cem.SymphonyLF__Type__c)){

                CEMwrapper wrap = pickListWrapperMap.get(cem.SymphonyLF__Type__c);
                if(wrap.personId == ''){
                    wrap.personId = cem.SymphonyLF__Type__c == 'Foreign Associate' ? cem.SymphonyLF__Office_Agent__c : cem.SymphonyLF__Person__c;
                    wrap.personName =  cem.SymphonyLF__Type__c == 'Foreign Associate'  ? cem.SymphonyLF__Office_Agent__r.Name :  cem.SymphonyLF__Person__r.name;
                    pickListWrapperMap.put(cem.SymphonyLF__Type__c, wrap);   
                }
                
            }
           
            
        }
        System.debug(pickListWrapperMap);
        List<CEMwrapper> CEMWrapperList = new List<CEMwrapper>();
        CEMWrapperList = pickListWrapperMap.values();
        return CEMWrapperList;
    }

    @AuraEnabled
    public static List<CEMwrapper>  getMEMpatentFamilyDetails(String patentFamilyId ){
        Map<String,String> picklistValues = getPicklistValuesMethod('SymphonyLF__Matter_Engagement_Model__c', 'SymphonyLF__Type__c');
        system.debug(picklistValues);
        String CEMquery = 'SELECT SymphonyLF__Office_Agent__c, SymphonyLF__Office_Agent__r.Name, SymphonyLF__Type__c, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Supervisor_Client_Contact__r.Name from SymphonyLF__Matter_Engagement_Model__c where SymphonyLF__Patent_Family__c = \'' + patentFamilyId + '\'  ORDER by CreatedDate ASC limit 10000';

        System.debug('-->'+CEMquery);
        List<SymphonyLF__Matter_Engagement_Model__c> orgCEM = (List<SymphonyLF__Matter_Engagement_Model__c>)Database.query(CEMquery);
        
        Map<String , CEMwrapper> pickListWrapperMap = new Map<String , CEMwrapper>();
        for(String str : picklistValues.keyset()){
            CEMwrapper wrap = new CEMwrapper();
            wrap.type = str;
            wrap.label = picklistValues.get(str);
            wrap.placeholder = 'Select ' + picklistValues.get(str);
            wrap.personId = '';
            wrap.personName = '';
            wrap.errorClass = '';
            wrap.errorMessage = '';
            wrap.required = str == 'Responsible Partner' ? true : false;
            wrap.objectName = str == 'Foreign Associate' ? 'SymphonyLF__Office_Agent__c' : 'SymphonyLF__Person__c';
            wrap.fieldNames = str == 'Foreign Associate' ? 'Name,SymphonyLF__Type__c' : 'Name,SymphonyLF__Type__c';
            wrap.whereCondition = str == 'Foreign Associate' ? 'SymphonyLF__Type__c=\'Office\' OR SymphonyLF__Type__c=\'Agent\'' : 'SymphonyLF__Type__c=\'Attorney\'';
                
            if(str == 'Backup Attorney' || str == 'Managing Partner' || str == 'Responsible Partner' || str == 'Responsible Attorney' || str == 'Working Attorney' || str == 'Foreign Associate' ){
                wrap.isVisible = true;
            }else{
                wrap.isVisible = false;
            }
            pickListWrapperMap.put(str, wrap );
        }
        for(SymphonyLF__Matter_Engagement_Model__c cem : orgCEM){
            if(pickListWrapperMap.containskey(cem.SymphonyLF__Type__c)){
                
                CEMwrapper wrap = pickListWrapperMap.get(cem.SymphonyLF__Type__c);
                if(wrap.personId == ''){
                    wrap.personId = cem.SymphonyLF__Type__c == 'Foreign Associate' ? cem.SymphonyLF__Office_Agent__c : cem.SymphonyLF__Supervisor_Client_Contact__c;
                    wrap.personName =  cem.SymphonyLF__Type__c == 'Foreign Associate'  ? cem.SymphonyLF__Office_Agent__r.Name :  cem.SymphonyLF__Supervisor_Client_Contact__r.name;
                    pickListWrapperMap.put(cem.SymphonyLF__Type__c, wrap);
                }
                
            }
           
            
        }
        System.debug(pickListWrapperMap);
        List<CEMwrapper> CEMWrapperList = new List<CEMwrapper>();
        CEMWrapperList = pickListWrapperMap.values();
        return CEMWrapperList;
    }
    
    @AuraEnabled
    public static string getMemDetails(List<ID> patentIdList){
        try {
            List<String> MOWOFAList=new List<String>();
            List<SymphonyLF__Matter_Engagement_Model__c> MemList=[SELECT ID,Name,SymphonyLF__Patent__r.SymphonyLF__Case_Type__c,SymphonyLF__Patent__r.SymphonyLF__Patent_Status__c,SymphonyLF__Office_Agent__c,SymphonyLF__Supervisor_Client_Contact__r.name,SymphonyLF__Office_Agent__r.name,  SymphonyLF__Type__c,SymphonyLF__Patent__c,SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c, SymphonyLF__Patent__r.SymphonyLF__Country__r.name  FROM SymphonyLF__Matter_Engagement_Model__c WHERE SymphonyLF__Patent__c =:patentIdList  ];

            Map<ID,MemPatentDetails> patentMEMMap=new Map<ID,MemPatentDetails>();

            for(SymphonyLF__Matter_Engagement_Model__c memRec:MemList){
                if(!patentMEMMap.keyset().contains(memRec.SymphonyLF__Patent__c)){
                MemPatentDetails memdetail=new MemPatentDetails();
                memdetail.heReferenceNumber=memRec.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c;
                memdetail.jurisdictionName=memRec.SymphonyLF__Patent__r.SymphonyLF__Country__r.name;
                memdetail.caseType=memRec.SymphonyLF__Patent__r.SymphonyLF__Case_Type__c;
				memdetail.patentID=String.valueof(memRec.SymphonyLF__Patent__c);
                memdetail.status=memRec.SymphonyLF__Patent__r.SymphonyLF__Patent_Status__c;
                patentMEMMap.put(memRec.SymphonyLF__Patent__c,memdetail);
                }
                // if(memRec.SymphonyLF__Type__c=='Managing Office'){
                //     patentMEMMap.get(memRec.SymphonyLF__Patent__c).managingOfficeName=memRec.SymphonyLF__Office_Agent__r.name==null?'':memRec.SymphonyLF__Office_Agent__r.name;
                //     patentMEMMap.get(memRec.SymphonyLF__Patent__c).managingOfficeName=memRec.SymphonyLF__Office_Agent__r.name==null?'':memRec.SymphonyLF__Office_Agent__r.name;
                    
                // }
                // if(memRec.SymphonyLF__Type__c=='Working Office'){
                //     patentMEMMap.get(memRec.SymphonyLF__Patent__c).workingOfficeName=memRec.SymphonyLF__Office_Agent__r.name==null?'':memRec.SymphonyLF__Office_Agent__r.name;
                // }
                if(memRec.SymphonyLF__Type__c=='Foreign Associate'){
                    patentMEMMap.get(memRec.SymphonyLF__Patent__c).foreignAssociateName= ( memRec.SymphonyLF__Type__c == 'Foreign Associate' && memRec.SymphonyLF__Office_Agent__r.name==null ) ?'' : memRec.SymphonyLF__Office_Agent__r.name;
                    // patentMEMMap.get(memRec.SymphonyLF__Patent__c).foreignAssociateName=memRec.SymphonyLF__Office_Agent__r.name==null?'':memRec.SymphonyLF__Office_Agent__r.name;

                }
            }
            return JSON.serialize(patentMEMMap.values());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
    @AuraEnabled
    public static Response createPerson(String person){
     system.debug('Person'+person);
        List<Persons> personList=(List<Persons>)JSON.deserialize(person, List<Persons>.class);
        system.debug('Person'+personList);
        List<SymphonyLF__Person__c> personListtoInsert= new List<SymphonyLF__Person__c>();
        Response resp=new Response();
       try{
        
            for(Persons pers:personList)
            {
            SymphonyLF__Person__c per=new SymphonyLF__Person__c();
            per.name=pers.personName;
            per.SymphonyLF__Client__c=pers.clientId;
            per.SymphonyLF__Email__c=pers.email;
            per.SymphonyLF__Contact_Type__c='Inventor';
            per.SymphonyLF__Type__c='Client';
            per.recordTypeId = pers.recordTypeId;
            per.SymphonyLF__User__c=pers.user;
            per.SymphonyLF__Nationality__c=pers.nationality;
            if(pers.inventorAddress!=null)
            {
           // per.SymphonyLF__Address__City__s=pers.inventorAddress.city;
            per.SymphonyLF__Address__CountryCode__s=pers.inventorAddress.country;
            per.SymphonyLF__Address__StateCode__s=pers.inventorAddress.state;
            per.SymphonyLF__Address__Street__s=pers.inventorAddress.street;
            per.SymphonyLF__Address__PostalCode__s=pers.inventorAddress.postalCode;
            }
            personListtoInsert.add(per);
            system.debug('per'+per);
           }
           system.debug('personListtoInsert'+personListtoInsert);
         insert personListtoInsert;
         resp.PatentFamilyID=personListtoInsert[0].id;
        resp.Status=true;
        }
        
       catch(Exception e){
        ErrorDetail erd=new ErrorDetail();
        erd.Description=e.getMessage();
        List<ErrorDetail> err=new List<ErrorDetail>();
        err.add(erd);
        resp.Errors=err;
        resp.Status=false;
       }
       return resp;

    } 
    @AuraEnabled
    public static Boolean checkRenewalsAnnuities (String clientID) {
           List<SymphonyLF__Client_Renewal_Configuration__c> records=[select id,name,SymphonyLF__Is_Active__c,SymphonyLF__Asset_Type__c from SymphonyLF__Client_Renewal_Configuration__c where SymphonyLF__Client__c =:clientID AND SymphonyLF__Asset_Type__c ='Patent' AND SymphonyLF__Is_Active__c =true];
          return records.size()>0;
    }

    @AuraEnabled
    public static Response createClient(String client, String existingClientId){
        System.debug('existingClientId  ' + existingClientId);
        List<SymphonyLF__Client__c> existingClient = new List<SymphonyLF__Client__c>();
        existingClient = [SELECT Id, SymphonyLF__Client_Group_Number__c, SymphonyLF__Master_Company__c, SymphonyLF__Active__c  from SymphonyLF__Client__c WHERE Id=:existingClientId];
        List<clients> clientList=(List<Clients>)JSON.deserialize(client, List<Clients>.class);
        List<SymphonyLF__Client__c> clientListtoInsert= new List<SymphonyLF__Client__c>();
        Response resp=new Response();
       try{
        for(Clients cli:clientList){
            SymphonyLF__Client__c cl=new SymphonyLF__Client__c();
            cl.Name=cli.name;
            cl.SymphonyLF__Client_Classification__c=cli.classification;
            if(!existingClient.isEmpty() && existingClient.size() > 0 ){
                cl.SymphonyLF__Client_Group_Number__c= existingClient[0].SymphonyLF__Client_Group_Number__c;
                if(existingClient[0].SymphonyLF__Master_Company__c == true && existingClient[0].SymphonyLF__Active__c == true){
                    cl.SymphonyLF__Client__c = existingClient[0].Id;
                }
            }
            cl.SymphonyLF__Entity_Size__c=cli.entitySize;
            cl.SymphonyLF__Default_Billing_Currency__c=ID.valueOf(cli.defaultCurrency);
            cl.SymphonyLF__Active__c=true;
            cl.Client_Status__c='Active';
            cl.SymphonyLF__Address__City__s=cli.address.city;
            // cl.SymphonyLF__Address__Country__s='';
            cl.SymphonyLF__Address__CountryCode__s=cli.address.country;
            cl.SymphonyLF__Address__StateCode__s=cli.address.state;
            cl.SymphonyLF__Address__Street__s=cli.address.street;
            cl.SymphonyLF__Address__PostalCode__s=cli.address.postalCode;
            clientListtoInsert.add(cl);
        }
        insert clientListtoInsert;
        resp.PatentFamilyID=clientListtoInsert[0].id;
        resp.Status=true;
       }
       catch(Exception e){
        ErrorDetail erd=new ErrorDetail();
        erd.Description=e.getMessage();
        List<ErrorDetail> err=new List<ErrorDetail>();
        err.add(erd);
        resp.Errors=err;
        resp.Status=false;
       }
       return resp;
    } 
    
    @AuraEnabled
    public static List<Options> getAddressOptions(String option)  
    {       

        // Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        Schema.DescribeSObjectResult userDescribe = Schema.sObjectType.User;
        List<Options> returnOption=new List<Options>();
        Schema.DescribeFieldResult fieldResult;
        
        if(option == 'country')
             fieldResult = userDescribe.fields.getMap().get('CountryCode').getDescribe();
        if(option == 'state')
             fieldResult = userDescribe.fields.getMap().get('StateCode').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple)
        {
            System.debug(f.getLabel() +'::'+ f.getValue());
            Options opt=new Options();
            opt.label=f.getLabel() ;
            opt.value= f.getValue();
            opt.code=f.getValue();
            returnOption.add(opt);
        }
        return returnOption;       
    }

    @AuraEnabled(cacheable=false)
    public static bitset.FieldDependencyWrapper getPicklistValues(String objectName, String controllingField, String dependentField, String controllingValue) {
      
        Bitset.FieldDependencyWrapper returnValue=bitset.getDependentPicklistValuesViaDependentFieldAPI(SymphonyLF__Client__c.SymphonyLF__Address__StateCode__s );
        return returnValue;
    }

    @AuraEnabled
    public static List<SymphonyLF__Keyword__c> getKeywords(){
        return [ SELECT Id, Name, SymphonyLF__Full_Name__c from SymphonyLF__Keyword__c  LIMIT 10000 ];
    }

	public class ConfigData
    {
        @AuraEnabled
        public List<SymphonyLF__Patent_Family__c> patentFamily{set;get;}
        @AuraEnabled
        public List<SymphonyLF__Client__c> applicants{set;get;}
        @AuraEnabled
        public List<SymphonyLF__Person__c> inventors {set;get;}
    }
    public class jurisdictionData {
        @AuraEnabled
        public String jurisdictionId{set;get;}
        @AuraEnabled
        public String jurisdictionName{set;get;}
    }

    public class recordWrapper {
        @AuraEnabled
        public String ClientId{set;get;}
        @AuraEnabled
        public String conflictCheckId{set;get;}
        @AuraEnabled
        public String Source{set;get;}
        @AuraEnabled
        public PatentFamily PatentFamily{set;get;}
        @AuraEnabled
        public List<BusinessCategory> BusinessCategory{set;get;}
        @AuraEnabled
        public List<Inventor> Inventors{set;get;}
        @AuraEnabled
        public List<keyword> keywords{set;get;}
        @AuraEnabled
        public List<SelectedApplicants> Applicants{set;get;}
        @AuraEnabled
        public List<ApplicationDetails> ApplicationDetails{set;get;}
       // @AuraEnabled
       //public List<FileDetails> FileDetails{set;get;}
    }

	public class BusinessCategory {
		@AuraEnabled
        public String id{set;get;}
		@AuraEnabled
        public String categoryValue{set;get;}
		@AuraEnabled
        public String name{set;get;}
        @AuraEnabled
        public String existingBCId{set;get;}
		@AuraEnabled
        public String categoryFormula{set;get;}
		@AuraEnabled
        public Boolean existing{set;get;}
	}

    public class keyword {
		@AuraEnabled
        public String key{set;get;} // keyword record Id
        @AuraEnabled
        public String existingKeywordId{set;get;} //Existing keywordAssocation Id
		@AuraEnabled
        public Boolean existing{set;get;}
	}

	public class Inventor {
		@AuraEnabled
        public String label{set;get;}
		@AuraEnabled
        public String value{set;get;}
		@AuraEnabled
        public String key{set;get;}
		@AuraEnabled
        public String email{set;get;}
		@AuraEnabled
        public String address{set;get;}
		@AuraEnabled
        public Boolean isVisible{set;get;}
		@AuraEnabled
        public Boolean selected{set;get;}
        @AuraEnabled
        public Boolean primary{set;get;}
        @AuraEnabled
        public String existingRecId{set;get;}
        @AuraEnabled
        public Integer sequence{set;get;}
	}

	public class SelectedApplicants {
		@AuraEnabled
        public String label{set;get;}
		@AuraEnabled
        public String value{set;get;}
		@AuraEnabled
        public String key{set;get;}
		@AuraEnabled
        public String existingApplicantId{set;get;}
		@AuraEnabled
        public String address{set;get;}
		@AuraEnabled
        public Boolean isVisible{set;get;}
		@AuraEnabled
        public Boolean selected{set;get;}
        @AuraEnabled
        public String registeredApplicant{set;get;}
        @AuraEnabled
        public AddressE addressedit{set;get;}
	}

	// public class FileDetails {
	// 	@AuraEnabled
    //     public String id{set;get;}
	// 	@AuraEnabled
    //     public String contentVersionId{set;get;}
	// 	@AuraEnabled
    //     public String contentDocumentId{set;get;}
	// }

	public class ApplicationDetails {
		@AuraEnabled
        public String jurisdictionName{set;get;}
        @AuraEnabled
        public String clientRefNo{set;get;}
		@AuraEnabled
        public String jurisdictionId{set;get;}
		@AuraEnabled
        public String groupName{set;get;}
		@AuraEnabled
        public String groupId{set;get;}
		@AuraEnabled
        public String uniqueId{set;get;}
		@AuraEnabled
        public String caseTypeValue{set;get;}
        @AuraEnabled
        public String patOrProsecutionDN{set;get;}
        @AuraEnabled
        public String IPRdocketReq{set;get;}
        @AuraEnabled
        public String OppDocketReq{set;get;}
        @AuraEnabled
        public String litigationDocketReq{set;get;}
        @AuraEnabled
        public String clientAccessToFileDocket{set;get;}
        @AuraEnabled
        public String responsibleForAnnuities{set;get;}
        @AuraEnabled
        public String clientOnAnnuityPolicy{set;get;}
        @AuraEnabled
        public List<DocketActivity> docketActivities{set;get;}
		@AuraEnabled
        public List<Inventor> selectedInventors{set;get;}
		@AuraEnabled
        public List<CEMwrapper> engagementDetailsPatent{set;get;}
		@AuraEnabled
        public List<SelectedApplicants> selectedApplicants{set;get;}
		@AuraEnabled
        public List<SelectedPriorities> selectedPriorities{set;get;}
		@AuraEnabled
        public List<BusinessCategory> selectedBusinessInfos{set;get;}
		@AuraEnabled
        public List<keyword> selectedkeywords{set;get;}
        @AuraEnabled
        public String assetType{set;get;}
        @AuraEnabled
        public String responsiblePartnerName{set;get;}
        @AuraEnabled
        public String responsibleAttorneyName{set;get;}
        @AuraEnabled
        public String renewalsAnnuities{set;get;}
	}
    public class DocketActivity {
		@AuraEnabled
        public String eventName{set;get;}
		@AuraEnabled
        public String dueDate{set;get;}
		@AuraEnabled
        public String eventDate{set;get;}
		@AuraEnabled
        public String assignToUser{set;get;}
		@AuraEnabled
        public String assignToTeam{set;get;}
		@AuraEnabled
        public String nameLabel{set;get;}
	}
    public class SelectedPriorities {
		@AuraEnabled
        public String jurisdiction{set;get;}
		@AuraEnabled
        public String heReferenceNumber{set;get;}
		@AuraEnabled
        public Date filingDate{set;get;}
		@AuraEnabled
        public String filingNumber{set;get;}
		@AuraEnabled
        public String patentNumber{set;get;}
		//@AuraEnabled
       // public String clientReference{set;get;}
		@AuraEnabled
        public String caseType{set;get;}
		@AuraEnabled
        public String Id{set;get;}
		@AuraEnabled
        public String ipMatter{set;get;}
		@AuraEnabled
        public String shortTitle{set;get;}
		@AuraEnabled
        public String title{set;get;}
      //  @AuraEnabled
     //   public String portfolioManagement{set;get;}
        @AuraEnabled
        public String patentFamily{set;get;}
        @AuraEnabled
        public String priorityAssetType{set;get;}
	}

	public class PatentFamily {
		@AuraEnabled
        public String patentFamilyId{set;get;}
		@AuraEnabled
        public String title{set;get;}
		// @AuraEnabled
        // public Date inventionDate{set;get;}
		@AuraEnabled
        public String shortTitle{set;get;}
		//@AuraEnabled
        //public String clientReference{set;get;}
		// @AuraEnabled
        // public Date earliestPriorityDate{set;get;}
		// @AuraEnabled
        // public String inventionDescription{set;get;}
		@AuraEnabled
        public List<CEMwrapper> engagementDetails{set;get;}

		// @AuraEnabled
        // public String managingOffice{set;get;}
		// @AuraEnabled
        // public String responsiblePartner{set;get;}
	}

    // Common Wrappers Below
    public class ErrorDetail {
        @AuraEnabled
        public String Code{set;get;}
        @AuraEnabled
        public String Description{set;get;}
    }
    public class Response {
        @AuraEnabled
        public string PatentFamilyID{set;get;}
        @AuraEnabled
        public boolean Status{set;get;}
        @AuraEnabled
        public String message{set;get;}
        @AuraEnabled
        public List<ErrorDetail> Errors{set;get;}
    }
    public class MemPatentDetails{
        @AuraEnabled
        public String heReferenceNumber{set;get;}
        @AuraEnabled
        public String jurisdictionName{set;get;}
        @AuraEnabled
        public String caseType{set;get;}
        @AuraEnabled
        public String status{set;get;}
        @AuraEnabled
        public String managingOfficeName{set;get;}
        @AuraEnabled
        public String workingOfficeName{set;get;}
        @AuraEnabled
        public String foreignAssociateName{set;get;}
        @AuraEnabled
        public String patentId{set;get;}

    }
    public class Persons{
        @AuraEnabled
        public String clientId{get;set;}
        @AuraEnabled
        public String recordTypeId{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String contactType{get;set;}
        @AuraEnabled
        public String Type{get;set;}
        @AuraEnabled
        public AddressE inventorAddress{get;set;}
        @AuraEnabled
        public String personName{get;set;}
        @AuraEnabled
        public String nationality{get;set;}
        @AuraEnabled
        public String phone{get;set;}
        @AuraEnabled
        public String assistant{get;set;}
        @AuraEnabled
        public String extension{get;set;}
        @AuraEnabled
        public String mobilePhone{get;set;}
        @AuraEnabled
        public String linkVcard{get;set;}
        @AuraEnabled
        public String linkToProfile{get;set;}
        @AuraEnabled
        public String user{get;set;}
    }
    public class Options{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String code{get;set;}

    }
    public class Clients{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String defaultCurrency{get;set;}
        @AuraEnabled
        public String classification{get;set;}
        @AuraEnabled
        public String entitySize{get;set;}
        @AuraEnabled
        public AddressE address{get;set;}
    }
    public class AddressE{
        @AuraEnabled
        public String state{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String street{get;set;}
        @AuraEnabled
        public String country{get;set;}
        @AuraEnabled
        public String postalCode{get;set;}

    }

    public class CEMwrapper{
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String personId{get;set;}
        @AuraEnabled
        public String personName{get;set;}
        @AuraEnabled
        public String placeholder{get;set;}
        @AuraEnabled
        public String errorClass{get;set;}
        @AuraEnabled
        public String errorMessage{get;set;}
        @AuraEnabled
        public String objectName{get;set;}
        @AuraEnabled
        public String fieldNames{get;set;}
        @AuraEnabled
        public Boolean required{get;set;}
        @AuraEnabled
        public String whereCondition{get;set;}
        @AuraEnabled
        public Boolean isVisible{get;set;}
        @AuraEnabled
        public Boolean isAlreadyCreated{get;set;}
       

    }

    
    public class CustomException extends Exception {}
}