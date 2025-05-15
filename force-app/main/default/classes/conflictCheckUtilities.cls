/* TODO: 1. Filter data where createdBy = Logged in user or Originating Attorney
2. Query needs to fetch all the data related to the Conflict Check, Clients, Inventors and Keywords 
3. Add the variables to the Wrapper for Keywords and Inventor Table

*/
public with sharing class conflictCheckUtilities {
    public conflictCheckUtilities() {
        
    }
    @AuraEnabled
    public static List<conflictCheckWrapper> getRecentConflictCheckRequests(String recordId) {
        List<conflictCheckWrapper> wrapperResults = getConflictCheckRequests(recordId);
        return wrapperResults;
    }

    @AuraEnabled(cacheable=false)
    public static List<conflictCheckWrapper> getConflictCheckMasterRequests(String recordId) {
        // Wrapper for the Conflic Check Requests
        
        List<Conflict_Check__c> conflictCheckRequests = new List <Conflict_Check__c>();
        System.debug('recordId ====> '+recordId);

        String conflictCheckUtilitiesWereClause = '';
        {
            Set<String> fieldWhereSingle = new Set<String>();
            for(String lookup : lookupFieldToSobjectOnConflictCheck){
                fieldWhereSingle.add( lookup + ' != NULL' );
            }
            conflictCheckUtilitiesWereClause = ' ( ' + String.join(fieldWhereSingle, ' OR ') + ' ) ';
        }

        String query = ' SELECT ' +
                            String.join(conflictCheckFields, ', ') +
                            // ' ,( SELECT ' +
                            //     String.join(conflictCheckSearchResultFields, ', ') +
                            //     ' FROM Conflict_Check_Results__r ' +
                            //     ' WHERE ' + conflictCheckUtilitiesWereClause +
                            // ' ) ' +
                        ' FROM Conflict_Check__c ' ;
                        // ' WHERE ' + 
                        //     ' CC_Status__c IN :pendingCcStatus ';

        if(String.isBlank(recordId)){
          query +=   'WHERE  CC_Status__c IN :pendingCcStatus AND ( CreatedById = :loggedInUser OR Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c = :loggedInUser ) ';
        }
                    
        if(String.isNotBlank(recordId)){
            query += ' WHERE Id = :recordId ';
        }

        query += ' ORDER BY CreatedDate DESC ';
         System.debug('query : '+query);
        conflictCheckRequests = Database.query( query );
        System.debug('conflictCheckRequests :::::: Master :: '+conflictCheckRequests);
        Set<Id> conflictCheckIds = new Set<Id>();
        for(Conflict_Check__c c : conflictCheckRequests){
            conflictCheckIds.add(c.Id);
        }
        
        List<conflictCheckWrapper> conflictCheckWrapperRecords = new List<conflictCheckWrapper>();
        List<Task> taskList = [SELECT Id, WhatId, OwnerId, Subject, Status 
                               FROM Task 
                               WHERE WhatId IN :conflictCheckIds AND Status != NULL];
        Map<Id,List<Task>> map_taskList_Approve = new Map<Id,List<Task>>();
        Map<Id,List<Task>> map_taskList_Discuss = new Map<Id,List<Task>>();
        Map<Id,List<Task>> map_taskList_Total = new Map<Id,List<Task>>();
        for(Task t : taskList){
            if(t.Status == 'Discuss'){
                if(map_taskList_Discuss.containskey(t.WhatId)){
                    map_taskList_Discuss.get(t.WhatId).add(t);
                }
                else{
                    map_taskList_Discuss.put(t.WhatId,new list<Task>{t});
                }
            }
            else if(t.Status == 'Approve'){
                if(map_taskList_Approve.containskey(t.WhatId)){
                    map_taskList_Approve.get(t.WhatId).add(t);
                }
                else{
                    map_taskList_Approve.put(t.WhatId,new list<Task>{t});
                }
            }
            
            
            if(map_taskList_Total.containskey(t.WhatId)){
                map_taskList_Total.get(t.WhatId).add(t);
            }
            else{
                map_taskList_Total.put(t.WhatId,new list<Task>{t});
            }
        } 
        
        if(conflictCheckRequests.size() > 0 ){ 
            
            for(Conflict_Check__c cc : conflictCheckRequests){
                conflictCheckWrapper ccWrapper = new conflictCheckWrapper();
                ccWrapper.recordId              = cc.Id;
                ccWrapper.recordName            = cc.name;
                ccWrapper.clientName            = cc.Client_Name__r.Name;
                ccWrapper.clientStatus          = cc.Client_Name__r.Client_Status__c;
                ccWrapper.clientId              = cc.Client_Name__c;
                ccWrapper.clientReferenceNumber = cc.Client_Reference_Number__c;
                ccWrapper.clientGroupNumber     = cc.Client_Name__r.SymphonyLF__Client_Group_Number__c;
                ccWrapper.matterNames           = cc.Matter_Name__c;
                ccWrapper.adverseParties        = cc.Adverse_Parties__c;
                ccWrapper.relatedParties        = cc.Related_Parties_other_than_client__c;
                ccWrapper.status                = cc.CC_Status__c;
                ccWrapper.areaOfLaw             = cc.Area_of_Law_AOL__c;
                ccWrapper.approveCount          = map_taskList_Approve.containskey(cc.Id) ? map_taskList_Approve.get(cc.Id).size() : 0;
                ccWrapper.discussCount          = map_taskList_Discuss.containskey(cc.Id) ? map_taskList_Discuss.get(cc.Id).size() : 0;
                ccWrapper.totalCount            = map_taskList_Total.containskey(cc.Id) ? map_taskList_Total.get(cc.Id).size() : 0;
                ccWrapper.contributors          = cc.Contributor__c;
                ccWrapper.keywords              = cc.Keywords__c;
                ccWrapper.isSelected            = false;
                ccWrapper.isExpanded            = false;
                ccWrapper.isChildCreated        = false;
                ccWrapper.isRecordCreator       = cc.Logged_in_User_is_Creator__c;
                ccWrapper.isOriginatingAttorney = cc.Logged_in_User_is_Originating_Attorney__c;
                
                // if(cc.Conflict_Check_Results__r.Client__r.size() >0)
                //     ccWrapper.displayExpand = true;
                // else 
                //     ccWrapper.displayExpand = false;
                // for (Conflict_Check_Search_Result__c conflictCheckResult: cc.Conflict_Check_Results__r) {
                //     system.debug('conflictCheckResult :: '+conflictCheckResult);
                //     if (conflictCheckResult.client__c != null ) { 
                //         conflictCheckWrapper.clientRecord clientRecord = new conflictCheckWrapper.clientRecord ();
                //         clientRecord.recordId = conflictCheckResult.Id;
                //         clientRecord.clientId = conflictCheckResult.Client__r.Id;
                //         clientRecord.clientName = conflictCheckResult.Client__r.Name;
                //         clientRecord.classification = conflictCheckResult.Client__r.SymphonyLF__Client_Classification__c;
                //         clientRecord.clientNumber = conflictCheckResult.Client__r.SymphonyLF__Client_Number_New__c;
                //         clientRecord.isActive = conflictCheckResult.Client__r.Client_Status__c == 'Active' ? true : false;
                //         clientRecord.groupNumber = conflictCheckResult.Client__r.SymphonyLF__Client_Group_Number__c;
                //         clientRecord.isVerified = conflictCheckResult.Is_Verified__c;
                //         ccWrapper.clientRecords.add(clientRecord);
                //     } 
                //     else if (conflictCheckResult.Inventor_Designer_Author__c != null) {
                //         conflictCheckWrapper.contributorRecord contributorRecord = new conflictCheckWrapper.contributorRecord();
                        
                //         contributorRecord.recordId = conflictCheckResult.Id;
                //         contributorRecord.inventorId = conflictCheckResult.Inventor_Designer_Author__c;
                //         contributorRecord.contributorName = conflictCheckResult.Inventor_Designer_Author__r.SymphonyLF__Contact_Name__c;
                //         contributorRecord.contributorType = conflictCheckResult.Inventor_Designer_Author__r.SymphonyLF__Type__c;

                //         SymphonyLF__Inventor_Designer_Author__c ida = conflictCheckResult.Inventor_Designer_Author__r;
                //         MatterDetails matterDetail = inventorDesignerAuthorMatterType( ida );
                //         contributorRecord.matterType = matterDetail.matterType;
                //         contributorRecord.docketNumber = matterDetail.docketNumber;
                //         contributorRecord.relatedRecordId = matterDetail.relatedRecordId;
 
                //         ccWrapper.contributorRecords.add(contributorRecord);
                //     } 
                //     else if (conflictCheckResult.Keyword_Association__c != null) { 
                //         conflictCheckWrapper.keywordRecord keywordRecord = new conflictCheckWrapper.keywordRecord();
                        
                //         keywordRecord.recordId = conflictCheckResult.Id;
                //         keywordRecord.keywordId = conflictCheckResult.Keyword_Association__c;
                //         keywordRecord.isVerified = conflictCheckResult.Is_Verified__c;
                //         keywordRecord.keyword = conflictCheckResult.Keyword_Association__r.SymphonyLF__Keyword__r.Name;

                //         SymphonyLF__Keyword_Association__c ka = conflictCheckResult.Keyword_Association__r;
                //         MatterDetails matterDetail = keywordMatterType( ka );
                //         keywordRecord.matterType = matterDetail.matterType;
                //         keywordRecord.matterName = matterDetail.matterName;
                //         keywordRecord.docketNumber = matterDetail.docketNumber;
                //         keywordRecord.relatedRecordId = matterDetail.relatedRecordId;
                        
                //         ccWrapper.keywordRecords.add(keywordRecord);
                //     }
                //     else if (conflictCheckResult.Entity__c != null) { 
                //         conflictCheckWrapper.entityRecord entityRecord = new conflictCheckWrapper.entityRecord();
                        
                //         entityRecord.recordId = conflictCheckResult.Id;
                //         entityRecord.entityId = conflictCheckResult.Entity__c;
                //         entityRecord.isVerified = conflictCheckResult.Is_Verified__c;
                //         entityRecord.entityName = conflictCheckResult.Entity__r.Name;
                //         entityRecord.entityType = conflictCheckResult.Entity__r.SymphonyLF__Type__c;
                //         entityRecord.entityContact = conflictCheckResult.Entity__r.SymphonyLF__Primary_Contact__r.Name;
                //         entityRecord.entityActive = conflictCheckResult.Entity__r.SymphonyLF__Active__c;
                //         ccWrapper.entityRecords.add(entityRecord);
                //     }
                //     else if (conflictCheckResult.Chain_of_Title__c != null) { 
                //         conflictCheckWrapper.chainOfTitleRecord chainOfTitleRecord = new conflictCheckWrapper.chainOfTitleRecord();
                        
                //         chainOfTitleRecord.recordId = conflictCheckResult.Id;
                //         chainOfTitleRecord.isVerified = conflictCheckResult.Is_Verified__c;
                //         chainOfTitleRecord.title = conflictCheckResult.Chain_of_Title__r.SymphonyLF__Client__r.Name;
                //         chainOfTitleRecord.chainOfTitleId = conflictCheckResult.Chain_of_Title__c;
                //         chainOfTitleRecord.applicantName = conflictCheckResult.Chain_of_Title__r.SymphonyLF__Applicant_Assignee_Name__c;
                //         chainOfTitleRecord.role = conflictCheckResult.Chain_of_Title__r.SymphonyLF__Role__c;
                //         chainOfTitleRecord.fromDate = conflictCheckResult.Chain_of_Title__r.SymphonyLF__From_Date__c;
                //         chainOfTitleRecord.toDate = conflictCheckResult.Chain_of_Title__r.SymphonyLF__To_Date__c;

                //         SymphonyLF__Chain_of_Title__c cot = conflictCheckResult.Chain_of_Title__r;
                //         MatterDetails matterDetail = chainOfTitleMatterType(cot);
                //         chainOfTitleRecord.matterType = matterDetail.matterType;
                //         chainOfTitleRecord.docketNumber = matterDetail.docketNumber;
                //         chainOfTitleRecord.relatedRecordId = matterDetail.relatedRecordId;
                        
                //         ccWrapper.chainOfTitleRecords.add(chainOfTitleRecord);
                //     }
                //     else if( 
                //         conflictCheckResult.Copyright__c != null || 
                //         conflictCheckResult.Design__c != null ||
                //         conflictCheckResult.Patent__c != null ||
                //         conflictCheckResult.Trademark__c != null ||
                //         conflictCheckResult.Design_Family__c != null ||
                //         conflictCheckResult.Dispute_Opposition__c != null ||
                //         conflictCheckResult.General_Matter__c != null ||
                //         conflictCheckResult.Mark__c != null ||
                //         conflictCheckResult.Patent_Family__c != null || 
                //         conflictCheckResult.Agreement_and_Contract__c != null){
                //             system.debug('In here');
                //             system.debug('conflictCheckResult :: '+conflictCheckResult);
                //             conflictCheckWrapper.matterRecord matterRecord = new conflictCheckWrapper.matterRecord();
                //             matterRecord.recordId = conflictCheckResult.Id;
                            
                //             if(String.isBlank(conflictCheckResult.LookupFieldToSobject__c)){
                //                 continue;
                //             }

                //             String lookupField = conflictCheckResult.LookupFieldToSobject__c;

                //            matterRecord.matterId = (String)  ((sObject) conflictCheckResult).get(lookupField);

                //             string copyrightTitle = conflictCheckResult.Copyright__c != null ? 
                //                                         conflictCheckResult.Copyright__r.Name != null? conflictCheckResult.Copyright__r.Name :
                //                                         conflictCheckResult.Copyright__r.Name : '';
                    
                //             string designTitle = conflictCheckResult.Design__c != null ?
                //                                     conflictCheckResult.Design__r.Name != null? conflictCheckResult.Design__r.Name : 
                //                                     conflictCheckResult.Design__r.Title__c : '';	
                            
                //             string patentTitle =    conflictCheckResult.Patent__c != null ? 
                //                                     conflictCheckResult.Patent__r.SymphonyLF__Title__c != null ?
                //                                     conflictCheckResult.Patent__r.SymphonyLF__Title__c : 
                //                                     conflictCheckResult.Patent__r.Name != null? conflictCheckResult.Patent__r.Name : 
                //                                     conflictCheckResult.Patent__r.SymphonyLF__Title__c : '';
                    
                //             string tradeMarkTitle = conflictCheckResult.Trademark__c != null? 
                //                                         conflictCheckResult.Trademark__r.name != null? 
                //                                         conflictCheckResult.Trademark__r.name : 
                //                                         conflictCheckResult.Trademark__r.Name : '';

                //             string markTitle = conflictCheckResult.Mark__c != null? 
                //                                         conflictCheckResult.mark__r.name != null? 
                //                                         conflictCheckResult.mark__r.name : 
                //                                         conflictCheckResult.mark__r.Name : '';

                //             string designFamilyTitle = conflictCheckResult.Design_Family__c != null ? 
                //                                             conflictCheckResult.Design_Family__r.Title__c != null ? 
                //                                             conflictCheckResult.Design_Family__r.Title__c : 
                //                                             conflictCheckResult.Design_Family__r.Name != null? conflictCheckResult.Design_Family__r.Name : 
                //                                             conflictCheckResult.Design_Family__r.Title__c : '';
                            
                //             string disputeOpptitle = conflictCheckResult.Dispute_Opposition__c != null ? 
                //                                         conflictCheckResult.Dispute_Opposition__r.Name != null ? 
                //                                         conflictCheckResult.Dispute_Opposition__r.Name : 
                //                                         conflictCheckResult.Dispute_Opposition__r.Name != null? conflictCheckResult.Dispute_Opposition__r.Name : 
                //                                         conflictCheckResult.Dispute_Opposition__r.Name : '';		
                            
                //             string generalMatterTitle = conflictCheckResult.General_Matter__c != null ? 
                //                                             conflictCheckResult.General_Matter__r.Name != null ? 
                //                                             conflictCheckResult.General_Matter__r.Name : 
                //                                             conflictCheckResult.General_Matter__r.Name != null? conflictCheckResult.General_Matter__r.Name : 
                //                                             conflictCheckResult.General_Matter__r.Name : '';
                    
                //             string patentFamilyTitle = conflictCheckResult.Patent_Family__c != null ? 
                //                                             conflictCheckResult.Patent_Family__r.SymphonyLF__Title__c != null ? 
                //                                             conflictCheckResult.Patent_Family__r.SymphonyLF__Title__c : 
                //                                             conflictCheckResult.Patent_Family__r.Name : '';

                //             string agreementAndContractTitle = conflictCheckResult.Agreement_and_Contract__c != null ? 
                //                                             conflictCheckResult.Agreement_and_Contract__r.Name != null ? 
                //                                             conflictCheckResult.Agreement_and_Contract__r.Name : 
                //                                             conflictCheckResult.Agreement_and_Contract__r.Name : '';

                //             matterRecord.title = 
                //                 (conflictCheckResult.Copyright__c != null) ? copyrightTitle :
                //                 (conflictCheckResult.Design__c != null) ? designTitle :
                //                 (conflictCheckResult.Patent__c != null) ? patentTitle :
                //                 (conflictCheckResult.Trademark__c != null) ? tradeMarkTitle : 
                //                 (conflictCheckResult.Design_Family__c != null) ? designFamilyTitle :
                //                 (conflictCheckResult.Dispute_Opposition__c != null) ? disputeOpptitle :
                //                 (conflictCheckResult.General_Matter__c != null) ? generalMatterTitle :
                //                 (conflictCheckResult.Mark__c != null) ? markTitle :
                //                 (conflictCheckResult.Patent_Family__c != null) ? patentFamilyTitle : 
                //                 (conflictCheckResult.Agreement_and_Contract__c != null) ? agreementAndContractTitle : '';
                                
                //             matterRecord.docket_Number = 
                //                 (conflictCheckResult.Copyright__c != null) ? conflictCheckResult.Copyright__r.SymphonyLF__Docket_Number__c :
                //                 (conflictCheckResult.Design__c != null) ? conflictCheckResult.Design__r.SymphonyLF__Docket_Number__c:
                //                 (conflictCheckResult.Patent__c != null) ? conflictCheckResult.Patent__r.SymphonyLF__Docket_Number__c :
                //                 (conflictCheckResult.Trademark__c != null) ? conflictCheckResult.Trademark__r.SymphonyLF__Docket_Number__c : 
                //                 (conflictCheckResult.Design_Family__c != null) ? conflictCheckResult.Design_Family__r.SymphonyLF__Docket_Number__c :
                //                 (conflictCheckResult.Dispute_Opposition__c != null) ? conflictCheckResult.Dispute_Opposition__r.SymphonyLF__Docket_Number__c :
                //                 (conflictCheckResult.General_Matter__c != null) ? conflictCheckResult.General_Matter__r.SymphonyLF__Docket_Number__c :
                //                 (conflictCheckResult.Mark__c != null) ? conflictCheckResult.Mark__r.SymphonyLF__Docket_Number__c :
                //                 (conflictCheckResult.Patent_Family__c != null) ? conflictCheckResult.Patent_Family__r.SymphonyLF__Docket_Number__c : 
                //                 (conflictCheckResult.Agreement_and_Contract__c != null) ? conflictCheckResult.Agreement_and_Contract__r.SymphonyLF__Docket_Number__c : null;
                            
                //             matterRecord.Matter_Name = 
                //                 (conflictCheckResult.Copyright__c != null) ? 'Copyright' :
                //                 (conflictCheckResult.Design__c != null) ? 'Design':
                //                 (conflictCheckResult.Patent__c != null) ? 'Patent' :
                //                 (conflictCheckResult.Trademark__c != null) ? 'Trademark' : 
                //                 (conflictCheckResult.Design_Family__c != null) ? 'Design Family' :
                //                 (conflictCheckResult.Dispute_Opposition__c != null) ? 'Dispute Opposition' :
                //                 (conflictCheckResult.General_Matter__c != null) ? 'General Matter' :
                //                 (conflictCheckResult.Mark__c != null) ? 'Mark' :
                //                 (conflictCheckResult.Patent_Family__c != null) ? 'Patent Family' : 
                //                 (conflictCheckResult.Agreement_and_Contract__c != null) ? 'Agreement and Contract' : null;
                                
                //             matterRecord.status = 
                //                 (conflictCheckResult.Copyright__c != null) ? conflictCheckResult.Copyright__r.SymphonyLF__Status__c :
                //                 (conflictCheckResult.Design__c != null) ? conflictCheckResult.Design__r.SymphonyLF__Design_Status__c:
                //                 (conflictCheckResult.Patent__c != null) ? conflictCheckResult.Patent__r.SymphonyLF__Patent_Status__c :
                //                 (conflictCheckResult.Trademark__c != null) ? conflictCheckResult.Trademark__r.SymphonyLF__Status__c : 
                //                 (conflictCheckResult.Design_Family__c != null) ? conflictCheckResult.Design_Family__r.SymphonyLF__Status__c :
                //                 (conflictCheckResult.Dispute_Opposition__c != null) ? conflictCheckResult.Dispute_Opposition__r.SymphonyLF__Status__c :
                //                 (conflictCheckResult.General_Matter__c != null) ? conflictCheckResult.General_Matter__r.SymphonyLF__Matter_Status__c :
                //                 (conflictCheckResult.Mark__c != null) ? conflictCheckResult.Mark__r.SymphonyLF__Mark_Status__c :
                //                 (conflictCheckResult.Patent_Family__c != null) ? conflictCheckResult.Patent_Family__r.SymphonyLF__Family_Status__c : 
                //                 (conflictCheckResult.Agreement_and_Contract__c != null) ? conflictCheckResult.Agreement_and_Contract__r.SymphonyLF__Matter_Status__c : null;
                                
                //             ccWrapper.matterRecords.add(matterRecord);
                //         }   
                // }
                
                conflictCheckWrapperRecords.add(ccWrapper);
                
            }
        }
        return conflictCheckWrapperRecords;
    }

    @AuraEnabled(cacheable=true)
    public static List<conflictCheckWrapper> getConflictCheckRequests(String recordId) {
        // Wrapper for the Conflic Check Requests
        
        List<Conflict_Check__c> conflictCheckRequests = new List <Conflict_Check__c>();
        System.debug('recordId ====> '+recordId);

        String conflictCheckUtilitiesWereClause = '';
        {
            Set<String> fieldWhereSingle = new Set<String>();
            for(String lookup : lookupFieldToSobjectOnConflictCheck){
                fieldWhereSingle.add( lookup + ' != NULL' );
            }
            conflictCheckUtilitiesWereClause = ' ( ' + String.join(fieldWhereSingle, ' OR ') + ' ) ';
        }

        String query = ' SELECT ' +
                            String.join(conflictCheckFields, ', ') +
                            ' ,( SELECT ' +
                                String.join(conflictCheckSearchResultFields, ', ') +
                                ' FROM Conflict_Check_Results__r ' +
                                ' WHERE ' + conflictCheckUtilitiesWereClause +
                            ' ) ' +
                        ' FROM Conflict_Check__c ' ;
                        // ' WHERE ' + 
                        //     ' CC_Status__c IN :pendingCcStatus';

        if(String.isBlank(recordId)){
          query += 'WHERE CC_Status__c IN :pendingCcStatus  AND ( CreatedById = :loggedInUser OR Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c = :loggedInUser ) ';
        }

        if(String.isNotBlank(recordId)){
            query += ' WHERE Id = :recordId ';
        }

        query += ' ORDER BY CreatedDate DESC ';
        System.debug('query : '+query);
        conflictCheckRequests = Database.query( query );
        System.debug('conflictCheckRequests ::::: child :: '+conflictCheckRequests);

        Set<Id> conflictCheckIds = new Set<Id>();
        for(Conflict_Check__c c : conflictCheckRequests){
            conflictCheckIds.add(c.Id);
        }
        
        List<conflictCheckWrapper> conflictCheckWrapperRecords = new List<conflictCheckWrapper>();
        List<Task> taskList = [SELECT Id, WhatId, OwnerId, Subject, Status 
                               FROM Task 
                               WHERE WhatId IN :conflictCheckIds AND Status != NULL];
        Map<Id,List<Task>> map_taskList_Approve = new Map<Id,List<Task>>();
        Map<Id,List<Task>> map_taskList_Discuss = new Map<Id,List<Task>>();
        Map<Id,List<Task>> map_taskList_Total = new Map<Id,List<Task>>();
        for(Task t : taskList){
            if(t.Status == 'Discuss'){
                if(map_taskList_Discuss.containskey(t.WhatId)){
                    map_taskList_Discuss.get(t.WhatId).add(t);
                }
                else{
                    map_taskList_Discuss.put(t.WhatId,new list<Task>{t});
                }
            }
            else if(t.Status == 'Approve'){
                if(map_taskList_Approve.containskey(t.WhatId)){
                    map_taskList_Approve.get(t.WhatId).add(t);
                }
                else{
                    map_taskList_Approve.put(t.WhatId,new list<Task>{t});
                }
            }
            
            
            if(map_taskList_Total.containskey(t.WhatId)){
                map_taskList_Total.get(t.WhatId).add(t);
            }
            else{
                map_taskList_Total.put(t.WhatId,new list<Task>{t});
            }
        } 
        
        if(conflictCheckRequests.size() > 0 ){ 
            
            for(Conflict_Check__c cc : conflictCheckRequests){
                conflictCheckWrapper ccWrapper = new conflictCheckWrapper();
                ccWrapper.recordId              = cc.Id;
                ccWrapper.recordName            = cc.name;
                ccWrapper.clientName            = cc.Client_Name__r.Name;
                ccWrapper.clientStatus          = cc.Client_Name__r.Client_Status__c;
                ccWrapper.clientId              = cc.Client_Name__c;
                ccWrapper.clientReferenceNumber = cc.Client_Reference_Number__c;
                ccWrapper.matterNames           = cc.Matter_Name__c;
                ccWrapper.adverseParties        = cc.Adverse_Parties__c;
                ccWrapper.relatedParties        = cc.Related_Parties_other_than_client__c;
                ccWrapper.status                = cc.CC_Status__c;
                ccWrapper.areaOfLaw             = cc.Area_of_Law_AOL__c;
                ccWrapper.approveCount          = map_taskList_Approve.containskey(cc.Id) ? map_taskList_Approve.get(cc.Id).size() : 0;
                ccWrapper.discussCount          = map_taskList_Discuss.containskey(cc.Id) ? map_taskList_Discuss.get(cc.Id).size() : 0;
                ccWrapper.totalCount            =  map_taskList_Total.containskey(cc.Id) ? map_taskList_Total.get(cc.Id).size() : 0;
                ccWrapper.contributors          = cc.Contributor__c;
                ccWrapper.keywords              = cc.Keywords__c;
                ccWrapper.isSelected            = false;
                ccWrapper.isExpanded            = false;
                ccWrapper.isChildCreated        = false;
                ccWrapper.isRecordCreator       = cc.Logged_in_User_is_Creator__c;
                ccWrapper.isOriginatingAttorney = cc.Logged_in_User_is_Originating_Attorney__c;
                
                for (Conflict_Check_Search_Result__c conflictCheckResult: cc.Conflict_Check_Results__r) {
                    system.debug('conflictCheckResult :: '+conflictCheckResult);
                    if (conflictCheckResult.client__c != null ) { 
                        if(cc.Client_Name__c != conflictCheckResult.Client__r.Id){
                            conflictCheckWrapper.clientRecord clientRecord = new conflictCheckWrapper.clientRecord ();
                            clientRecord.recordId = conflictCheckResult.Id;
                            clientRecord.clientId = conflictCheckResult.Client__r.Id;
                            clientRecord.clientName = conflictCheckResult.Client__r.Name;
                            clientRecord.classification = conflictCheckResult.Client__r.SymphonyLF__Client_Classification__c;
                            clientRecord.clientNumber = conflictCheckResult.Client__r.SymphonyLF__Client_Number_New__c;
                            clientRecord.isActive = conflictCheckResult.Client__r.Client_Status__c == 'Active' ? true : false;
                            clientRecord.groupNumber = conflictCheckResult.Client__r.SymphonyLF__Client_Group_Number__c;
                            clientRecord.isVerified = conflictCheckResult.Is_Verified__c;
                            ccWrapper.clientRecords.add(clientRecord);
                        }
                    } 
                    else if (conflictCheckResult.Inventor_Designer_Author__c != null) {
                        conflictCheckWrapper.contributorRecord contributorRecord = new conflictCheckWrapper.contributorRecord();
                        
                        contributorRecord.recordId = conflictCheckResult.Id;
                        contributorRecord.inventorId = conflictCheckResult.Inventor_Designer_Author__c;
                        contributorRecord.contributorName = conflictCheckResult.Inventor_Designer_Author__r.SymphonyLF__Contact_Name__c;
                        contributorRecord.contributorType = conflictCheckResult.Inventor_Designer_Author__r.SymphonyLF__Type__c;

                        if(conflictCheckResult.Inventor_Designer_Author__r != null){
                            SymphonyLF__Inventor_Designer_Author__c ida = conflictCheckResult.Inventor_Designer_Author__r;
                            MatterDetails matterDetail = inventorDesignerAuthorMatterType( ida );
                            contributorRecord.matterType = matterDetail.matterType;
                            contributorRecord.docketNumber = matterDetail.docketNumber;
                            contributorRecord.relatedRecordId = matterDetail.relatedRecordId;
                        }
 
                        ccWrapper.contributorRecords.add(contributorRecord);
                    } 
                    else if (conflictCheckResult.Keyword_Association__c != null) { 
                        conflictCheckWrapper.keywordRecord keywordRecord = new conflictCheckWrapper.keywordRecord();
                        
                        keywordRecord.recordId = conflictCheckResult.Id;
                        keywordRecord.keywordId = conflictCheckResult.Keyword_Association__c;
                        keywordRecord.isVerified = conflictCheckResult.Is_Verified__c;
                        keywordRecord.keyword = conflictCheckResult.Keyword_Association__r.SymphonyLF__Keyword__r.Name;

                        SymphonyLF__Keyword_Association__c ka = conflictCheckResult.Keyword_Association__r;
                        MatterDetails matterDetail = keywordMatterType( ka );
                        keywordRecord.matterType = matterDetail.matterType;
                        keywordRecord.matterName = matterDetail.matterName;
                        keywordRecord.docketNumber = matterDetail.docketNumber;
                        keywordRecord.relatedRecordId = matterDetail.relatedRecordId;
                        
                        ccWrapper.keywordRecords.add(keywordRecord);
                    }
                    else if (conflictCheckResult.Entity__c != null) { 
                        conflictCheckWrapper.entityRecord entityRecord = new conflictCheckWrapper.entityRecord();
                        
                        entityRecord.recordId = conflictCheckResult.Id;
                        entityRecord.entityId = conflictCheckResult.Entity__c;
                        entityRecord.isVerified = conflictCheckResult.Is_Verified__c;
                        entityRecord.entityName = conflictCheckResult.Entity__r.Name;
                        entityRecord.entityType = conflictCheckResult.Entity__r.SymphonyLF__Type__c;
                        entityRecord.entityContact = conflictCheckResult.Entity__r.SymphonyLF__Primary_Contact__r.Name;
                        entityRecord.entityActive = conflictCheckResult.Entity__r.SymphonyLF__Active__c;
                        ccWrapper.entityRecords.add(entityRecord);
                    }
                    else if (conflictCheckResult.Chain_of_Title__c != null) { 
                        conflictCheckWrapper.chainOfTitleRecord chainOfTitleRecord = new conflictCheckWrapper.chainOfTitleRecord();
                        
                        chainOfTitleRecord.recordId = conflictCheckResult.Id;
                        chainOfTitleRecord.isVerified = conflictCheckResult.Is_Verified__c;
                        chainOfTitleRecord.title = conflictCheckResult.Chain_of_Title__r.SymphonyLF__Client__r.Name;
                        chainOfTitleRecord.chainOfTitleId = conflictCheckResult.Chain_of_Title__c;
                        chainOfTitleRecord.applicantName = conflictCheckResult.Chain_of_Title__r.SymphonyLF__Applicant_Assignee_Name__c;
                        chainOfTitleRecord.role = conflictCheckResult.Chain_of_Title__r.SymphonyLF__Role__c;
                        chainOfTitleRecord.fromDate = conflictCheckResult.Chain_of_Title__r.SymphonyLF__From_Date__c;
                        chainOfTitleRecord.toDate = conflictCheckResult.Chain_of_Title__r.SymphonyLF__To_Date__c;
                        if(conflictCheckResult.Chain_of_Title__r != null && conflictCheckResult.Chain_of_Title__r.SymphonyLF__Client__c != cc.Client_Name__c){
                            SymphonyLF__Chain_of_Title__c cot = conflictCheckResult.Chain_of_Title__r;
                            MatterDetails matterDetail = chainOfTitleMatterType(cot);
                            chainOfTitleRecord.matterType = matterDetail.matterType;
                            chainOfTitleRecord.docketNumber = matterDetail.docketNumber;
                            chainOfTitleRecord.relatedRecordId = matterDetail.relatedRecordId;
                        }
                        
                        ccWrapper.chainOfTitleRecords.add(chainOfTitleRecord);
                    }
                    else if( 
                        conflictCheckResult.Copyright__c != null || 
                        conflictCheckResult.Design__c != null ||
                        conflictCheckResult.Patent__c != null ||
                        conflictCheckResult.Trademark__c != null ||
                        conflictCheckResult.Design_Family__c != null ||
                        conflictCheckResult.Dispute_Opposition__c != null ||
                        conflictCheckResult.General_Matter__c != null ||
                        conflictCheckResult.Mark__c != null ||
                        conflictCheckResult.Patent_Family__c != null || 
                        conflictCheckResult.Agreement_and_Contract__c != null){
                            system.debug('In here');
                            system.debug('conflictCheckResult :: '+conflictCheckResult);
                            conflictCheckWrapper.matterRecord matterRecord = new conflictCheckWrapper.matterRecord();
                            matterRecord.recordId = conflictCheckResult.Id;
                            
                            if(String.isBlank(conflictCheckResult.LookupFieldToSobject__c)){
                                continue;
                            }

                            String lookupField = conflictCheckResult.LookupFieldToSobject__c;

                           matterRecord.matterId = (String)  ((sObject) conflictCheckResult).get(lookupField);
                           
                            string copyrightTitle = conflictCheckResult.Copyright__c != null ? 
                                                        conflictCheckResult.Copyright__r.Name != null ? conflictCheckResult.Copyright__r.Name :
                                                        conflictCheckResult.Copyright__r.Name : '';
                    
                            string designTitle = conflictCheckResult.Design__c != null ?
                                                    conflictCheckResult.Design__r.Name != null? conflictCheckResult.Design__r.Name : 
                                                    conflictCheckResult.Design__r.Title__c : '';	
                            
                            string patentTitle =    conflictCheckResult.Patent__c != null ? 
                                                    conflictCheckResult.Patent__r.SymphonyLF__Title__c != null ?
                                                    conflictCheckResult.Patent__r.SymphonyLF__Title__c : 
                                                    conflictCheckResult.Patent__r.Name != null? conflictCheckResult.Patent__r.Name : 
                                                    conflictCheckResult.Patent__r.SymphonyLF__Title__c : '';
                    
                            string tradeMarkTitle = conflictCheckResult.Trademark__c != null? 
                                                        conflictCheckResult.Trademark__r.name != null? 
                                                        conflictCheckResult.Trademark__r.name : 
                                                        conflictCheckResult.Trademark__r.Name : '';

                            string markTitle = conflictCheckResult.Mark__c != null? 
                                                        conflictCheckResult.mark__r.name != null? 
                                                        conflictCheckResult.mark__r.name : 
                                                        conflictCheckResult.mark__r.Name : '';

                            string designFamilyTitle = conflictCheckResult.Design_Family__c != null ? 
                                                            conflictCheckResult.Design_Family__r.Title__c != null ? 
                                                            conflictCheckResult.Design_Family__r.Title__c : 
                                                            conflictCheckResult.Design_Family__r.Name != null? conflictCheckResult.Design_Family__r.Name : 
                                                            conflictCheckResult.Design_Family__r.Title__c : '';
                            
                            string disputeOpptitle = conflictCheckResult.Dispute_Opposition__c != null ? 
                                                        conflictCheckResult.Dispute_Opposition__r.Name != null ? 
                                                        conflictCheckResult.Dispute_Opposition__r.Name : 
                                                        conflictCheckResult.Dispute_Opposition__r.Name != null? conflictCheckResult.Dispute_Opposition__r.Name : 
                                                        conflictCheckResult.Dispute_Opposition__r.Name : '';		
                            
                            string generalMatterTitle = conflictCheckResult.General_Matter__c != null ? 
                                                            conflictCheckResult.General_Matter__r.Name != null ? 
                                                            conflictCheckResult.General_Matter__r.Name : 
                                                            conflictCheckResult.General_Matter__r.Name != null? conflictCheckResult.General_Matter__r.Name : 
                                                            conflictCheckResult.General_Matter__r.Name : '';
                    
                            string patentFamilyTitle = conflictCheckResult.Patent_Family__c != null ? 
                                                            conflictCheckResult.Patent_Family__r.SymphonyLF__Title__c != null ? 
                                                            conflictCheckResult.Patent_Family__r.SymphonyLF__Title__c : 
                                                            conflictCheckResult.Patent_Family__r.Name : '';

                            string agreementAndContractTitle = conflictCheckResult.Agreement_and_Contract__c != null ? 
                                                            conflictCheckResult.Agreement_and_Contract__r.Name != null ? 
                                                            conflictCheckResult.Agreement_and_Contract__r.Name : 
                                                            conflictCheckResult.Agreement_and_Contract__r.Name : '';

                            matterRecord.title = 
                                (conflictCheckResult.Copyright__c != null) ? copyrightTitle :
                                (conflictCheckResult.Design__c != null) ? designTitle :
                                (conflictCheckResult.Patent__c != null) ? patentTitle :
                                (conflictCheckResult.Trademark__c != null) ? tradeMarkTitle : 
                                (conflictCheckResult.Design_Family__c != null) ? designFamilyTitle :
                                (conflictCheckResult.Dispute_Opposition__c != null) ? disputeOpptitle :
                                (conflictCheckResult.General_Matter__c != null) ? generalMatterTitle :
                                (conflictCheckResult.Mark__c != null) ? markTitle :
                                (conflictCheckResult.Patent_Family__c != null) ? patentFamilyTitle : 
                                (conflictCheckResult.Agreement_and_Contract__c != null) ? agreementAndContractTitle : '';
                                
                            matterRecord.docket_Number = 
                                (conflictCheckResult.Copyright__c != null) ? conflictCheckResult.Copyright__r.SymphonyLF__Docket_Number__c :
                                (conflictCheckResult.Design__c != null) ? conflictCheckResult.Design__r.SymphonyLF__Docket_Number__c:
                                (conflictCheckResult.Patent__c != null) ? conflictCheckResult.Patent__r.SymphonyLF__Docket_Number__c :
                                (conflictCheckResult.Trademark__c != null) ? conflictCheckResult.Trademark__r.SymphonyLF__Docket_Number__c : 
                                (conflictCheckResult.Design_Family__c != null) ? conflictCheckResult.Design_Family__r.SymphonyLF__Docket_Number__c :
                                (conflictCheckResult.Dispute_Opposition__c != null) ? conflictCheckResult.Dispute_Opposition__r.SymphonyLF__Docket_Number__c :
                                (conflictCheckResult.General_Matter__c != null) ? conflictCheckResult.General_Matter__r.SymphonyLF__Docket_Number__c :
                                (conflictCheckResult.Mark__c != null) ? conflictCheckResult.Mark__r.SymphonyLF__Docket_Number__c :
                                (conflictCheckResult.Patent_Family__c != null) ? conflictCheckResult.Patent_Family__r.SymphonyLF__Docket_Number__c : 
                                (conflictCheckResult.Agreement_and_Contract__c != null) ? conflictCheckResult.Agreement_and_Contract__r.SymphonyLF__Docket_Number__c : null;
                            
                            matterRecord.Matter_Name = 
                                (conflictCheckResult.Copyright__c != null) ? 'Copyright' :
                                (conflictCheckResult.Design__c != null) ? 'Design':
                                (conflictCheckResult.Patent__c != null) ? 'Patent' :
                                (conflictCheckResult.Trademark__c != null) ? 'Trademark' : 
                                (conflictCheckResult.Design_Family__c != null) ? 'Design Family' :
                                (conflictCheckResult.Dispute_Opposition__c != null) ? 'Dispute Opposition' :
                                (conflictCheckResult.General_Matter__c != null) ? 'General Matter' :
                                (conflictCheckResult.Mark__c != null) ? 'Mark' :
                                (conflictCheckResult.Patent_Family__c != null) ? 'Patent Family' : 
                                (conflictCheckResult.Agreement_and_Contract__c != null) ? 'Agreement and Contract' : null;
                                
                            matterRecord.status = 
                                (conflictCheckResult.Copyright__c != null) ? conflictCheckResult.Copyright__r.SymphonyLF__Status__c :
                                (conflictCheckResult.Design__c != null) ? conflictCheckResult.Design__r.SymphonyLF__Design_Status__c:
                                (conflictCheckResult.Patent__c != null) ? conflictCheckResult.Patent__r.SymphonyLF__Patent_Status__c :
                                (conflictCheckResult.Trademark__c != null) ? conflictCheckResult.Trademark__r.SymphonyLF__Status__c : 
                                (conflictCheckResult.Design_Family__c != null) ? conflictCheckResult.Design_Family__r.SymphonyLF__Status__c :
                                (conflictCheckResult.Dispute_Opposition__c != null) ? conflictCheckResult.Dispute_Opposition__r.SymphonyLF__Status__c :
                                (conflictCheckResult.General_Matter__c != null) ? conflictCheckResult.General_Matter__r.SymphonyLF__Matter_Status__c :
                                (conflictCheckResult.Mark__c != null) ? conflictCheckResult.Mark__r.SymphonyLF__Mark_Status__c :
                                (conflictCheckResult.Patent_Family__c != null) ? conflictCheckResult.Patent_Family__r.SymphonyLF__Family_Status__c : 
                                (conflictCheckResult.Agreement_and_Contract__c != null) ? conflictCheckResult.Agreement_and_Contract__r.SymphonyLF__Matter_Status__c : null;
                                
                            ccWrapper.matterRecords.add(matterRecord);
                        }   
                }
                
                conflictCheckWrapperRecords.add(ccWrapper);
                
            }
        }
        return conflictCheckWrapperRecords;
    }

    static Set<String> conflictCheckFields = new Set<String>{
          'id'
        , 'Client_Name__r.Name'
        , 'Client_Name__r.Client_Status__c'
        , 'Adverse_Parties__c'
        , 'Related_Parties_other_than_client__c'
        , 'Client_Reference_Number__c'
        , 'Client_Name__r.SymphonyLF__Client_Group_Number__c'
        , 'CC_Status__c'
        , 'Contributor__c'
        , 'Keywords__c'
        , 'Area_of_Law_AOL__c'
        , 'New_Client__c'
        , 'Matter_Name__c'
        , 'Name'
        , 'Logged_in_User_is_Creator__c'
        , 'Logged_in_User_is_Originating_Attorney__c'
        , 'Client_Name__r.Originating_Attorney__c'
        , 'Client_Name__r.Originating_Attorney__r.SymphonyLF__User__c'
    };

    static Set<String> conflictCheckSearchResultFields = new Set<String>{
          'id'
        , 'LookupFieldToSobject__c'
        , 'Client__c'
        , 'Client__r.Name'
        , 'Client__r.SymphonyLF__Client_Number_New__c'
        , 'Client__r.Client_Status__c'
        , 'Client__r.SymphonyLF__Client_Group_Number__c'
        , 'Client__r.SymphonyLF__Client_Classification__c'
        , 'Client__r.SymphonyLF__Active__c'
        , 'Is_Verified__c'
        , 'Inventor_Designer_Author__c'
        , 'Keyword_Association__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Contact_Name__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Type__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Patent__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Patent__r.Name'
        , 'Inventor_Designer_Author__r.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Patent__r.Id'
        , 'Inventor_Designer_Author__r.SymphonyLF__Patent_Family__r.Name'
        , 'Inventor_Designer_Author__r.SymphonyLF__Patent_Family__r.SymphonyLF__Docket_Number__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Patent_Family__r.Id'
        , 'Inventor_Designer_Author__r.SymphonyLF__Design__r.Name'
        , 'Inventor_Designer_Author__r.SymphonyLF__Design__r.SymphonyLF__Docket_Number__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Design__r.Id'
        , 'Inventor_Designer_Author__r.SymphonyLF__Design_Family__r.Name'
        , 'Inventor_Designer_Author__r.SymphonyLF__Design_Family__r.SymphonyLF__Docket_Number__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Design_Family__r.Id'
        , 'Inventor_Designer_Author__r.SymphonyLF__Copyright__r.Name'
        , 'Inventor_Designer_Author__r.SymphonyLF__Copyright__r.SymphonyLF__Docket_Number__c'
        , 'Inventor_Designer_Author__r.SymphonyLF__Copyright__r.Id'
        , 'Keyword_Association__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Keyword__c'
        , 'Keyword_Association__r.SymphonyLF__Keyword__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Agreement_Contract__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Copyright__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Design__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Design_Family__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Dispute_Opposition__r.Name'
        , 'Keyword_Association__r.SymphonyLF__General_Matter__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Mark__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Patent__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Patent_Family__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Trademark__r.Name'
        , 'Keyword_Association__r.SymphonyLF__Agreement_Contract__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Copyright__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Design__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Design_Family__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Dispute_Opposition__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__General_Matter__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Mark__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Patent_Family__r.SymphonyLF__Docket_Number__c'
        , 'Keyword_Association__r.SymphonyLF__Trademark__r.SymphonyLF__Docket_Number__c'
        , 'Entity__c'
        , 'Entity__r.Name'
        , 'Entity__r.SymphonyLF__Type__c'
        , 'Entity__r.SymphonyLF__Primary_Contact__c'
        , 'Entity__r.SymphonyLF__Primary_Contact__r.Name'
        , 'Entity__r.SymphonyLF__Active__c'
        , 'Chain_of_Title__c'
        , 'Chain_of_Title__r.SymphonyLF__Client__c'
        , 'Chain_of_Title__r.SymphonyLF__Client__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Applicant_Assignee_Name__c'
        , 'Chain_of_Title__r.SymphonyLF__Applicant_Assignee_Name_Hyperlink__c'
        , 'Chain_of_Title__r.SymphonyLF__Role__c'
        , 'Chain_of_Title__r.SymphonyLF__From_Date__c'
        , 'Chain_of_Title__r.SymphonyLF__To_Date__c'
        , 'Chain_of_Title__r.SymphonyLF__Copyright__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Copyright__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.SymphonyLF__Copyright__r.Id'
        , 'Chain_of_Title__r.SymphonyLF__Design__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Design__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.SymphonyLF__Design__r.Id'
        , 'Chain_of_Title__r.SymphonyLF__Design_Family__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Design_Family__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.SymphonyLF__Design_Family__r.Id'
        , 'Chain_of_Title__r.SymphonyLF__Mark__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Mark__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.SymphonyLF__Mark__r.Id'
        , 'Chain_of_Title__r.SymphonyLF__Patent__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.SymphonyLF__Patent__r.Id'
        , 'Chain_of_Title__r.SymphonyLF__Patent_Family__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Patent_Family__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.SymphonyLF__Patent_Family__r.Id'
        , 'Chain_of_Title__r.SymphonyLF__Trademark__r.Name'
        , 'Chain_of_Title__r.SymphonyLF__Trademark__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.SymphonyLF__Trademark__r.Id'
        , 'Chain_of_Title__r.General_Matter__r.Name'
        , 'Chain_of_Title__r.General_Matter__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.General_Matter__r.Id'
        , 'Chain_of_Title__r.Dispute_Opposition__r.Name'
        , 'Chain_of_Title__r.Dispute_Opposition__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.Dispute_Opposition__r.Id'
        , 'Chain_of_Title__r.Agreement_and_Contract__r.Name'
        , 'Chain_of_Title__r.Agreement_and_Contract__r.SymphonyLF__Docket_Number__c'
        , 'Chain_of_Title__r.Agreement_and_Contract__r.Id'
        , 'Copyright__c'
        , 'Copyright__r.Name'
        , 'Copyright__r.Name'
        , 'Copyright__r.SymphonyLF__Docket_Number__c' 
        , 'Copyright__r.SymphonyLF__Status__c'
        , 'Design__c'
        , 'Design__r.Name' 
        , 'Design__r.Title__c' 
        , 'Design__r.SymphonyLF__Docket_Number__c' 
        , 'Design__r.SymphonyLF__Design_Status__c'
        , 'Patent__c'
        , 'Patent__r.Name' 
        , 'Patent__r.SymphonyLF__Client__c'
        , 'Patent__r.SymphonyLF__Title__c' 
        , 'Patent__r.SymphonyLF__Title__c' 
        , 'Patent__r.SymphonyLF__Docket_Number__c' 
        , 'Patent__r.SymphonyLF__Patent_Status__c'
        , 'Patent__r.Id'
        , 'Trademark__c'
        , 'Trademark__r.Name' 
        , 'Trademark__r.Name' 
        , 'Trademark__r.SymphonyLF__Docket_Number__c' 
        , 'Trademark__r.SymphonyLF__Status__c'
        , 'Design_Family__c'
        , 'Design_Family__r.Name' 
        , 'Design_Family__r.Title__c' 
        , 'Design_Family__r.Title__c' 
        , 'Design_Family__r.SymphonyLF__Docket_Number__c' 
        , 'Design_Family__r.SymphonyLF__Status__c'
        , 'Dispute_Opposition__c'
        , 'Dispute_Opposition__r.Name'
        , 'Dispute_Opposition__r.Name'
        , 'Dispute_Opposition__r.Name' 
        , 'Dispute_Opposition__r.SymphonyLF__Docket_Number__c' 
        , 'Dispute_Opposition__r.SymphonyLF__Status__c'
        , 'General_Matter__c'
        , 'General_Matter__r.Name'
        , 'General_Matter__r.SymphonyLF__Docket_Number__c' 
        , 'General_Matter__r.SymphonyLF__Matter_Status__c'
        , 'Mark__c'
        , 'Mark__r.Name' 
        , 'Mark__r.Name'
        , 'Mark__r.SymphonyLF__Docket_Number__c' 
        , 'Mark__r.SymphonyLF__Mark_Status__c'
        , 'Patent_Family__c'
        , 'Patent_Family__r.Name'
        , 'Patent_Family__r.SymphonyLF__Client__c'
        , 'Patent_Family__r.SymphonyLF__Title__c'  
        , 'Patent_Family__r.SymphonyLF__Docket_Number__c'
        , 'Patent_Family__r.Id'
        , 'Patent_Family__r.SymphonyLF__Family_Status__c'
        , 'Agreement_and_Contract__r.Name'
        , 'Agreement_and_Contract__r.Name'
        , 'Agreement_and_Contract__r.SymphonyLF__Matter_Status__c'
        , 'Agreement_and_Contract__r.SymphonyLF__Docket_Number__c'
    };

    static Set<String> lookupFieldToSobjectOnConflictCheck = new Set<String>{
        'client__c',
        'Inventor_Designer_Author__c',
        'Keyword_Association__c',
        'Entity__c',
        'Chain_of_Title__c',
        'Copyright__c',
        'Design__c',
        'Patent__c',
        'Trademark__c',
        'Design_Family__c',
        'Dispute_Opposition__c',
        'General_Matter__c',
        'Mark__c',
        'Patent_Family__c',
        'Agreement_and_Contract__c'
    };

    static Set<String> pendingCcStatus = new Set<String>{
        'In Progress',
        'Conflict Check Pending'
    };

    static Id loggedInUser = UserInfo.getUserId();

    static Map<String, String> matterTypeByMatterLookupField = new Map<String, String>{
        'Patent__c' => 'Patent',
        'Trademark__c' => 'Trademark',
        'Copyright__c' => 'Copyright',
        'Design_Family__c' => 'Design Family',
        'Dispute_Opposition__c' => 'Dispute Opposition',
        'General_Matter__c' => 'General Matter',
        'Mark__c' => 'Mark',
        'Patent_Family__c' => 'Patent Family',
        'Design__c' => 'Design',
        'Agreement_and_Contract__c' => 'Agreement and Contract'
    };

    static MatterDetails inventorDesignerAuthorMatterType(SymphonyLF__Inventor_Designer_Author__c ida){
        MatterDetails output = new MatterDetails();

        if(ida.SymphonyLF__Patent__c != null){
            output.matterType = 'Patent';
            output.docketNumber = ida.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = ida.SymphonyLF__Patent__c;
        }
        if(ida.SymphonyLF__Patent_Family__c != null){
            output.matterType = 'Patent Family';
            output.docketNumber = ida.SymphonyLF__Patent_Family__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = ida.SymphonyLF__Patent_Family__c;
        }
        if(ida.SymphonyLF__Design__c != null){
            output.matterType = 'Design';
            output.docketNumber = ida.SymphonyLF__Design__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = ida.SymphonyLF__Design__c;
        }
        if(ida.SymphonyLF__Design_Family__c != null){
            output.matterType = 'Design Family';
            output.docketNumber = ida.SymphonyLF__Design_Family__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = ida.SymphonyLF__Design_Family__c;
        }
        if(ida.SymphonyLF__Copyright__c != null){
            output.matterType = 'Copyright';
            output.docketNumber = ida.SymphonyLF__Copyright__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = ida.SymphonyLF__Copyright__c;
        }
        return output;
    }

    static MatterDetails chainOfTitleMatterType(SymphonyLF__Chain_of_Title__c cot){
        MatterDetails output = new MatterDetails();

        if(cot.General_Matter__c != null){
            output.matterType = 'General Matter';
            output.docketNumber = cot.General_Matter__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.General_Matter__c;
        }
        if(cot.Dispute_Opposition__c != null){
            output.matterType = 'Dispute/Opposition';
            output.docketNumber = cot.Dispute_Opposition__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.Dispute_Opposition__c;
        }
        if(cot.Agreement_and_Contract__c != null){
            output.matterType = 'Agreement and Contract';
            output.docketNumber = cot.Agreement_and_Contract__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.Agreement_and_Contract__c;
        }
        if(cot.SymphonyLF__Patent__c != null){
            output.matterType = 'Patent';
            output.docketNumber = cot.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.SymphonyLF__Patent__c;
        }
        if(cot.SymphonyLF__Patent_Family__c != null){
            output.matterType = 'Patent Family';
            output.docketNumber = cot.SymphonyLF__Patent_Family__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.SymphonyLF__Patent_Family__c;
        }
        if(cot.SymphonyLF__Design__c != null){
            output.matterType = 'Design';
            output.docketNumber = cot.SymphonyLF__Design__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.SymphonyLF__Design__c;
        }
        if(cot.SymphonyLF__Design_Family__c != null){
            output.matterType = 'Design Family';
            output.docketNumber = cot.SymphonyLF__Design_Family__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.SymphonyLF__Design_Family__c;
        }
        if(cot.SymphonyLF__Copyright__c != null){
            output.matterType = 'Copyright';
            output.docketNumber = cot.SymphonyLF__Copyright__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.SymphonyLF__Copyright__c;
        }
        if(cot.SymphonyLF__Mark__c != null){
            output.matterType = 'Mark';
            output.docketNumber = cot.SymphonyLF__Mark__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.SymphonyLF__Mark__c;
        }
        if(cot.SymphonyLF__Trademark__c != null){
            output.matterType = 'Trademark';
            output.docketNumber = cot.SymphonyLF__Trademark__r.SymphonyLF__Docket_Number__c;
            output.relatedRecordId = cot.SymphonyLF__Trademark__c;
        }
        return output;
    }

    static MatterDetails keywordMatterType(SymphonyLF__Keyword_Association__c ka){
        MatterDetails output = new MatterDetails();

        if(ka.SymphonyLF__Patent__c != null){
            output.matterType = 'Patent';
            output.docketNumber = ka.SymphonyLF__Patent__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Patent__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Patent__c;
        }
        if(ka.SymphonyLF__Patent_Family__c != null){
            output.matterType = 'Patent Family';
            output.docketNumber = ka.SymphonyLF__Patent_Family__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Patent_Family__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Patent_Family__c;
        }
        if(ka.SymphonyLF__Design__c != null){
            output.matterType = 'Design';
            output.docketNumber = ka.SymphonyLF__Design__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Design__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Design__c;
        }
        if(ka.SymphonyLF__Design_Family__c != null){
            output.matterType = 'Design Family';
            output.docketNumber = ka.SymphonyLF__Design_Family__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Design_Family__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Design_Family__c;
        }
        if(ka.SymphonyLF__Copyright__c != null){
            output.matterType = 'Copyright';
            output.docketNumber = ka.SymphonyLF__Copyright__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Copyright__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Copyright__c;
        }
        if(ka.SymphonyLF__Mark__c != null){
            output.matterType = 'Mark';
            output.docketNumber = ka.SymphonyLF__Mark__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Mark__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Mark__c;
        }
        if(ka.SymphonyLF__Trademark__c != null){
            output.matterType = 'Trademark';
            output.docketNumber = ka.SymphonyLF__Trademark__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Trademark__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Trademark__c;
        }
        if(ka.SymphonyLF__Agreement_Contract__c != null){
            output.matterType = 'Agreement and Contract';
            output.docketNumber = ka.SymphonyLF__Agreement_Contract__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Agreement_Contract__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Agreement_Contract__c;
        }
        if(ka.SymphonyLF__Dispute_Opposition__c != null){
            output.matterType = 'Dispute/Opposition';
            output.docketNumber = ka.SymphonyLF__Dispute_Opposition__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__Dispute_Opposition__r.Name;
            output.relatedRecordId = ka.SymphonyLF__Dispute_Opposition__c;
        }
        if(ka.SymphonyLF__General_Matter__c != null){
            output.matterType = 'General Matter';
            output.docketNumber = ka.SymphonyLF__General_Matter__r.SymphonyLF__Docket_Number__c;
            output.matterName = ka.SymphonyLF__General_Matter__r.Name;
            output.relatedRecordId = ka.SymphonyLF__General_Matter__c;
        }
        return output;
    }

    public class MatterDetails{
        String matterType;
        String docketNumber;
        String relatedRecordId;
        String matterName;
    }
}