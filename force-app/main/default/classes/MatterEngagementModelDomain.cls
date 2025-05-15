/* Copyright © 2024 MaxVal Group. All Rights Reserved.
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Modified by Dinesh R, 08/01/25 
* 
* Jira Ticket#MCC-1708
Test Class: MatterEngagementModelDomainTest
*/
public with sharing class MatterEngagementModelDomain {
    public static Set<Id> setExecutedRecord = new Set<Id>();
    public static Set<Id> executedSObjectIdSet = new Set<Id>();
    
    Integer iterationCount = 0;
    // private Map<Id, SymphonyLF__Matter_Engagement_Model__c> newMap;
    // private Map<Id, SymphonyLF__Matter_Engagement_Model__c> oldMap;
    
    private Set<String> memGrpTypes = getAllMatterEngagementModelGrpType();
    private Set<String> restrictedMEMTypes = getAllRestrictedMEMType();
    
    private Set<String> getAllMatterEngagementModelGrpType() {
        Set<String> masterLabels = new Set<String>();
        try {
            // Query the MasterLabel field from the custom metadata
            List<MatterEngagementModelGrpType__mdt> metadataRecords = [
                SELECT MasterLabel 
                FROM MatterEngagementModelGrpType__mdt
            ];
            
            // Add MasterLabel values to the Set
            for (MatterEngagementModelGrpType__mdt record : metadataRecords) {
                masterLabels.add(record.MasterLabel);
            }
        } catch (Exception e) {
            System.debug('Error fetching master labels from custom metadata: ' + e.getMessage());
        }
        return masterLabels;
    }
    private Set<String> getAllRestrictedMEMType() {
        Set<String> masterLabels = new Set<String>();
        try {
            // Query the MasterLabel field from the custom metadata
            List<MEMRestrictedTypeForValidation__mdt> metadataRecords = [
                SELECT MasterLabel 
                FROM MEMRestrictedTypeForValidation__mdt
            ];
            
            // Add MasterLabel values to the Set
            for (MEMRestrictedTypeForValidation__mdt record : metadataRecords) {
                masterLabels.add(record.MasterLabel);
            }
        } catch (Exception e) {
            System.debug('Error fetching master labels from custom metadata: ' + e.getMessage());
        }
        return masterLabels;
    }
    
//    Set<String> lookupFieldsToSobject = MatterEngagementModelApplication.getLookupFieldsToSobject();
    // Map<String,String> sharingReasonByLookupFieldAndModelType = MatterEngagementModelApplication.getSharingReasonByLookupFieldAndModelType();
    // Map<String,String> accessLevelByLookupFieldAndModelType = MatterEngagementModelApplication.getAccessLevelByLookupFieldAndModelType();
    
    // private List<EditSharingStatistics> addShares = new List<EditSharingStatistics>();
    // private List<EditSharingStatistics> removeShares = new List<EditSharingStatistics>();
    
    // private static Map<Id, String> lookupFieldByMatterEngagementId = new Map<Id, String>();
    
    // public MatterEngagementModelDomain() {}
    
    // public void setNewRecords(Map<Id, SymphonyLF__Matter_Engagement_Model__c> newMap){
    //     this.newMap = newMap;
    // }
    
    // public void setOldRecords(Map<Id, SymphonyLF__Matter_Engagement_Model__c> oldMap){
    //     this.oldMap = oldMap;
    // }
    // /*
    // public void processAfterInsert(){
    //     system.debug('executing processAfterInsert');
    //     iterationCount++;
    //     String lockIdValue = 'MatterEngagementModelDomain.processAfterInsert()' + iterationCount;
    //     LockerService.applyLocksAcrossServices(lockIdValue);
        
    //     for(Id i : this.newMap.keySet()){
    //         SymphonyLF__Matter_Engagement_Model__c newRecord = this.newMap.get(i);
    //         editSharing_Insert(newRecord);
    //     }
        
    //     System.debug('addShares size > ' + addShares.size());
    //     if(addShares.size() > 0){
    //         editSharing(addShares, true);
    //     }
        
    //     LockerService.releaseLockAcrossServices(lockIdValue);
    // } */
    
    // public void processAfterUpdate(){
    //     system.debug('executing processAfterUpdate');
    //     iterationCount++;
    //     String lockIdValue = 'MatterEngagementModelDomain.processAfterUpdate()' + iterationCount;
    //     LockerService.applyLocksAcrossServices(lockIdValue);
        
    //     for(Id i : this.newMap.keySet()){
    //         SymphonyLF__Matter_Engagement_Model__c newRecord = this.newMap.get(i);
    //         SymphonyLF__Matter_Engagement_Model__c oldRecord = this.oldMap.get(i);
    //         editSharing_Update(newRecord, oldRecord);
    //     }
        
    //     if(removeShares.size() > 0){
    //         editSharing(removeShares, false);
    //     }
        
    //     if(addShares.size() > 0){
    //         editSharing(addShares, true);
    //     }
        
    //     LockerService.releaseLockAcrossServices(lockIdValue);
    // }
    
    // public void processBeforeDelete(List<SymphonyLF__Matter_Engagement_Model__c> oldRecords) {
    //     system.debug('executing processBeforeDelete');
    //     // Check if the current user is a System Administrator or has a Docketing Management profile
    //     //LoggedInPersonService loggedInPersonService = New LoggedInPersonService();
    //     Boolean isBypassUser = loggedInPersonService.isBypassUser();
    //     if (isBypassUser) {
    //         System.debug('Bypassing the business logic for the current user.');
    //         return;
    //     }
        
    //     List<SymphonyLF__Matter_Engagement_Model__c> filteredoldRecordList = New List<SymphonyLF__Matter_Engagement_Model__c>();
    //     for (SymphonyLF__Matter_Engagement_Model__c record : oldRecords) {
    //         if (record.SymphonyLF__Type__c != null && 
    //             this.restrictedMEMTypes.contains(record.SymphonyLF__Type__c) ) {
    //                 filteredoldRecordList.add(record);
    //             }
    //     }
    //     if(filteredoldRecordList.size() > 0 && !TriggerConstants.memTriggerBlocked.contains('validationOnTypeField') ){
    //         validationOnTypeField(filteredoldRecordList);
    //     }
    // }
    
    // public void processAfterDelete(){
    //     system.debug('executing processAfterDelete');
    //     iterationCount++;
    //     String lockIdValue = 'MatterEngagementModelDomain.processAfterDelete()' + iterationCount;
    //     LockerService.applyLocksAcrossServices(lockIdValue);
        
    //     for(Id i : this.oldMap.keySet()){
    //         SymphonyLF__Matter_Engagement_Model__c oldRecord = this.oldMap.get(i);
    //         editSharing_Delete(oldRecord);
    //     }
        
    //     if(removeShares.size() > 0){
    //         editSharing(removeShares, false);
    //     }
        
    //     LockerService.releaseLockAcrossServices(lockIdValue);
    // }
    // /*
    // private void editSharing(List<EditSharingStatistics> shares ,Boolean addShare){
    //     system.debug('executing editSharing');
    //     for(EditSharingStatistics share : shares){
    //         String lookupObjectApiName = SchemaService.getObjectApiName(share.lookupId);
            
    //         ApexSharingService a = new ApexSharingService();
    //         a.setModuleName('Matter Engagement Model');
    //         a.setShareObject(getShareObjectName(lookupObjectApiName));
    //         a.setRecordId(share.lookupId);
    //         a.setPersonIds(new Set<Id>{ share.personId });
    //         a.setRowCause(share.sharingReason); 
    //         a.setAccessLevel(share.accessLevel);
            
    //         if(addShare == true){
    //             a.addShare();
    //         }else{
    //             a.removeShare();
    //         }
    //     }
    // }*/
    
    // private Id getPersonId(Id matterEngagementId){
    //     system.debug('executing getPersonId');
    //     Id personId;
        
    //     if(this.newMap != null){
    //         personId = this.newMap.get(matterEngagementId).SymphonyLF__Supervisor_Client_Contact__c;
    //     }
    //     if(this.oldMap != null){
    //         personId = this.oldMap.get(matterEngagementId).SymphonyLF__Supervisor_Client_Contact__c;
    //     }
        
    //     return personId;
    // }
    
    // private String getShareObjectName(String objectApiName){
    //     system.debug('executing getShareObjectName');
    //     String shareObjectApiName = objectApiName.replace('__c', '__Share');
    //     return shareObjectApiName;
    // }
    
    // private Id getLookupFieldValue(Id matterEngagmentId){
    //     system.debug('executing getLookupFieldValue');
    //     String lookupFieldName = lookupFieldByMatterEngagementId.get(matterEngagmentId);
    //     sObject record;
    //     if(this.newMap != null){
    //         record = this.newMap.get(matterEngagmentId);
    //     }
    //     if(this.oldMap != null){
    //         record = this.oldMap.get(matterEngagmentId);
    //     }
    //     Id lookupValue = (Id) record.get(lookupFieldName);
        
    //     return lookupValue;
    // }
    // /*
    // private void editSharing_Update(sObject newRecord, sObject oldRecord){
    //     system.debug('executing editSharing_Update');
    //     Id personIdNew = (Id) newRecord.get('SymphonyLF__Supervisor_Client_Contact__c');
    //     Id personIdOld = (Id) oldRecord.get('SymphonyLF__Supervisor_Client_Contact__c');
        
    //     if(personIdNew == null && personIdOld == null){
    //         return;
    //     }
        
    //     String engagementTypeNew = (String) newRecord.get('SymphonyLF__Type__c');
    //     String engagementTypeOld = (String) oldRecord.get('SymphonyLF__Type__c');
        
    //     for(String lookup : lookupFieldsToSobject){
    //         Id newValue = (Id) newRecord.get(lookup);
    //         Id oldValue = (Id) oldRecord.get(lookup);
            
    //         if( newValue != oldValue || engagementTypeNew != engagementTypeOld || personIdNew != personIdOld ){
                
    //             {
    //                 String lookUpFieldAndModelTypeKeyOld = lookup + '-' + engagementTypeOld;
    //                 if(sharingReasonByLookupFieldAndModelType.containsKey(lookUpFieldAndModelTypeKeyOld)){
    //                     String sharingReason = sharingReasonByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKeyOld);
    //                     String accessLevel = accessLevelByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKeyOld);
                        
    //                     EditSharingStatistics s = new EditSharingStatistics();
    //                     s.matterEngagementModel = oldRecord;
    //                     s.lookupField = lookup;
    //                     s.lookupId = oldValue;
    //                     s.sharingReason = sharingReason;
    //                     s.personId = personIdOld;
    //                     s.accessLevel = accessLevel;
                        
    //                     if(personIdOld != null && oldValue != null){
    //                         removeShares.add(s);
    //                     }
    //                 }
    //             }
                
    //             {
    //                 String lookUpFieldAndModelTypeKeyNew = lookup + '-' + engagementTypeNew;
    //                 if(sharingReasonByLookupFieldAndModelType.containsKey(lookUpFieldAndModelTypeKeyNew)){
    //                     String sharingReason = sharingReasonByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKeyNew);
    //                     String accessLevel = accessLevelByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKeyNew);
                        
    //                     EditSharingStatistics s = new EditSharingStatistics();
    //                     s.matterEngagementModel = newRecord;
    //                     s.lookupField = lookup;
    //                     s.lookupId = newValue;
    //                     s.sharingReason = sharingReason;
    //                     s.personId = personIdNew;
    //                     s.accessLevel = accessLevel;
                        
    //                     if(personIdNew != null && newValue != null){
    //                         addShares.add(s);
    //                     }
    //                 }
    //             }
                
    //         }
    //     }
    // } */
    // /*
    // private Boolean editSharing_Insert(sObject newRecord){
    //     system.debug('executing editSharing_Insert');
    //     Id personId = (Id) newRecord.get('SymphonyLF__Supervisor_Client_Contact__c');
    //     if(personId == null){
    //         return false;
    //     }
        
    //     for(String lookup : lookupFieldsToSobject){
    //         Id newValue = (Id) newRecord.get(lookup);
    //         if(newValue != null){
    //             String engagementType = (String) newRecord.get('SymphonyLF__Type__c');
    //             String lookUpFieldAndModelTypeKey = lookup + '-' + engagementType;
                
    //             if(sharingReasonByLookupFieldAndModelType.containsKey(lookUpFieldAndModelTypeKey)){
    //                 String sharingReason = sharingReasonByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKey);
    //                 String accessLevel = accessLevelByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKey);
                    
    //                 EditSharingStatistics s = new EditSharingStatistics();
    //                 s.matterEngagementModel = newRecord;
    //                 s.lookupField = lookup;
    //                 s.lookupId = newValue;
    //                 s.sharingReason = sharingReason;
    //                 s.personId = personId;
    //                 s.accessLevel = accessLevel;
                    
    //                 addShares.add(s);
    //             }
    //         }
    //     }
        
    //     return true;
    // } */
    // /*
    // private Boolean editSharing_Delete(sObject oldRecord){
    //     system.debug('executing editSharing_Delete');
    //     Id personId = (Id) oldRecord.get('SymphonyLF__Supervisor_Client_Contact__c');
    //     if(personId == null){
    //         return false;
    //     }
        
    //     for(String lookup : lookupFieldsToSobject){
    //         Id newValue = (Id) oldRecord.get(lookup);
            
    //         if(newValue != null){
    //             String engagementType = (String) oldRecord.get('SymphonyLF__Type__c');
    //             String lookUpFieldAndModelTypeKey = lookup + '-' + engagementType;
                
    //             if(sharingReasonByLookupFieldAndModelType.containsKey(lookUpFieldAndModelTypeKey)){
    //                 String sharingReason = sharingReasonByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKey);
    //                 String accessLevel = accessLevelByLookupFieldAndModelType.get(lookUpFieldAndModelTypeKey);
                    
    //                 EditSharingStatistics s = new EditSharingStatistics();
    //                 s.matterEngagementModel = oldRecord;
    //                 s.lookupField = lookup;
    //                 s.lookupId = newValue;
    //                 s.sharingReason = sharingReason;
    //                 s.personId = personId;
    //                 s.accessLevel = accessLevel;
                    
    //                 removeShares.add(s);
    //             }
    //         }
    //     }
        
    //     return true;
    // } */
    
    // private void findLookupFieldByMatterEngagementId(sObject matterEngagement){
    //     system.debug('executing findLookupFieldByMatterEngagementId');
    //     for(String lookupField : MatterEngagementModelApplication.getLookupFieldsToSobject()){
    //         Id lookupId = (Id) matterEngagement.get(lookupField);
    //         if(lookupId != null){
    //             lookupFieldByMatterEngagementId.put((Id) matterEngagement.get('Id'), lookupField);
    //             break;
    //         }
    //     }
    // }
    
    // public class EditSharingStatistics{
    //     public sObject matterEngagementModel;
    //     public String lookupField;
    //     public Id lookupId;
    //     public String sharingReason;
    //     public String accessLevel;
    //     public Id personId;
    // }
    
    public void updateMEMLookupsInMEMGroup(Set<Id> sObjectIdSet1){
        system.debug('executing updateMEMLookupsInMEMGroup');
        Set<Id> sObjectIdSet = New Set<Id>();
        for(Id matterId : sObjectIdSet1){
            if(!executedSObjectIdSet.contains(matterId)){
            	sObjectIdSet.add(matterId);
            }
        }
        
        if(sObjectIdSet.size() > 0 ){
            executedSObjectIdSet.addAll(sObjectIdSet);
            //get all MEM records which is related to the Matter Id's store in the sObjectIdSet and filter with Type values from this.memGrpTypes.
            List<SymphonyLF__Matter_Engagement_Model__c> allMEMList = 
                [SELECT Id, Name, SymphonyLF__Type__c, MEM_Group__c,
                 SymphonyLF__Patent__c, SymphonyLF__Patent__r.Matter_Engagement_Model_Group__c,
                 SymphonyLF__Design__c, SymphonyLF__Design__r.Matter_Engagement_Model_Group__c,
                 SymphonyLF__Trademark__c, SymphonyLF__Trademark__r.Matter_Engagement_Model_Group__c,
                 SymphonyLF__Agreements_Contracts__c, SymphonyLF__Agreements_Contracts__r.Matter_Engagement_Model_Group__c,
                 SymphonyLF__Copyright__c, SymphonyLF__Copyright__r.Matter_Engagement_Model_Group__c,
                 SymphonyLF__Dispute_Opposition__c, SymphonyLF__Dispute_Opposition__r.Matter_Engagement_Model_Group__c,
                 SymphonyLF__General_Matter__c, SymphonyLF__General_Matter__r.Matter_Engagement_Model_Group__c 
                 FROM SymphonyLF__Matter_Engagement_Model__c  
                 WHERE SymphonyLF__Type__c IN :this.memGrpTypes AND  ( 
                     (SymphonyLF__Patent__c IN :sObjectIdSet) OR (SymphonyLF__Design__c IN :sObjectIdSet) OR 
                     (SymphonyLF__Trademark__c IN :sObjectIdSet ) OR (SymphonyLF__Agreements_Contracts__c IN :sObjectIdSet) OR 
                     (SymphonyLF__Copyright__c IN :sObjectIdSet) OR (SymphonyLF__Dispute_Opposition__c IN :sObjectIdSet) OR
                     (SymphonyLF__General_Matter__c IN :sObjectIdSet) ) 	
                 ORDER BY CreatedDate ASC];
            Map<String,String> mapOfMEMGrpIdByMatterId = New Map<String,String>();
            mapOfMEMGrpIdByMatterId = getMEMGroupIdFromMEM(allMEMList);
            
            Map<String, List<SymphonyLF__Matter_Engagement_Model__c>> mapOfMatterEngagementsBySObjectId  = new Map<String, List<SymphonyLF__Matter_Engagement_Model__c>>();
            //Store MEM records into the Map of SObject Id's
            for (SymphonyLF__Matter_Engagement_Model__c mem : allMEMList) {
                
                string sObjectId =  getSObjectId(mem);
                
                if (mapOfMatterEngagementsBySObjectId.containsKey(sObjectId)) {
                    mapOfMatterEngagementsBySObjectId.get(sObjectId).add(mem);
                } else {
                    mapOfMatterEngagementsBySObjectId.put(sObjectId, new List<SymphonyLF__Matter_Engagement_Model__c>{mem});
                }
            }
            
            Map<string,MEM_Group__c> mapofMemGrpRecordByMatterId = New Map<string,MEM_Group__c>();
            for(String sObjectId : mapOfMatterEngagementsBySObjectId.keyset() ){
                MEM_Group__c memGrp = New MEM_Group__c();
                
                memGrp.MEM_1__c = null; memGrp.MEM_2__c = null; memGrp.MEM_3__c = null; memGrp.MEM_4__c = null; memGrp.MEM_5__c = null;
                memGrp.MEM_6__c = null; memGrp.MEM_7__c = null; memGrp.MEM_8__c = null; memGrp.MEM_9__c = null; memGrp.MEM_10__c = null;
                memGrp.MEM_11__c = null; memGrp.MEM_12__c = null; memGrp.MEM_13__c = null; memGrp.MEM_14__c = null; memGrp.MEM_15__c = null;
                memGrp.MEM_16__c = null; memGrp.MEM_17__c = null; memGrp.MEM_18__c = null;
                
                if(mapOfMEMGrpIdByMatterId.containsKey(sObjectId) ){
                    memGrp.id = mapOfMEMGrpIdByMatterId.get(sObjectId);
                }
                
                for(SymphonyLF__Matter_Engagement_Model__c mem : mapOfMatterEngagementsBySObjectId.get(sObjectId)){
                    if(memGrp.MEM_1__c == null){ memGrp.MEM_1__c = mem.Id; }
                    else if(memGrp.MEM_2__c == null){ memGrp.MEM_2__c = mem.Id; }
                    else if(memGrp.MEM_3__c == null){ memGrp.MEM_3__c = mem.Id; }
                    else if(memGrp.MEM_4__c == null){ memGrp.MEM_4__c = mem.Id; }
                    else if(memGrp.MEM_5__c == null){ memGrp.MEM_5__c = mem.Id; }
                    else if(memGrp.MEM_6__c == null){ memGrp.MEM_6__c = mem.Id; }
                    else if(memGrp.MEM_7__c == null){ memGrp.MEM_7__c = mem.Id; }
                    else if(memGrp.MEM_8__c == null){ memGrp.MEM_8__c = mem.Id; }
                    else if(memGrp.MEM_9__c == null){ memGrp.MEM_9__c = mem.Id; }
                    else if(memGrp.MEM_10__c == null){ memGrp.MEM_10__c = mem.Id; }
                    else if(memGrp.MEM_11__c == null){ memGrp.MEM_11__c = mem.Id; }
                    else if(memGrp.MEM_12__c == null){ memGrp.MEM_12__c = mem.Id; }
                    else if(memGrp.MEM_13__c == null){ memGrp.MEM_13__c = mem.Id; }
                    else if(memGrp.MEM_14__c == null){ memGrp.MEM_14__c = mem.Id; }
                    else if(memGrp.MEM_15__c == null){ memGrp.MEM_15__c = mem.Id; }
                    else if(memGrp.MEM_16__c == null){ memGrp.MEM_16__c = mem.Id; }
                    else if(memGrp.MEM_17__c == null){ memGrp.MEM_17__c = mem.Id; }
                    else if(memGrp.MEM_18__c == null){ memGrp.MEM_18__c = mem.Id; }
                    else{
                        //trigger.addError('MEM grouping is greater than 15 for Matter record Id - '+sObjectId);
                    } 
                }
                
                Id matterId = sObjectId;
                // Compare the object type using getName() and store the Sobject Id in respective lookup field
                if ('SymphonyLF__Patent__c' == matterId.getSObjectType().getDescribe().getName()) {
                    memGrp.Patent__c = matterId;
                } else if ('SymphonyLF__Design__c' == matterId.getSObjectType().getDescribe().getName()) {
                    memGrp.Design__c = matterId;
                } else if ('SymphonyLF__Trademark__c' == matterId.getSObjectType().getDescribe().getName()) {
                    memGrp.Trademark__c = matterId;
                } else if ('SymphonyLF__Agreements_Contracts__c' == matterId.getSObjectType().getDescribe().getName()) {
                    memGrp.Agreement_Contract__c = matterId;
                } else if ('SymphonyLF__Copyright__c' == matterId.getSObjectType().getDescribe().getName()) {
                    memGrp.Copyright__c = matterId;
                } else if ('SymphonyLF__Dispute_Opposition__c' == matterId.getSObjectType().getDescribe().getName()) {
                    memGrp.Dispute_Opposition__c = matterId;
                } else if ('SymphonyLF__General_Matter__c' == matterId.getSObjectType().getDescribe().getName()) {
                    memGrp.General_Matter__c = matterId;
                }
                mapofMemGrpRecordByMatterId.put(sObjectId, memGrp);
            }
            
            try{
                upsert mapofMemGrpRecordByMatterId.values();
            }
            catch(Exception exp){
            system.debug('Error Message :: '+exp.getMessage());
        }
        }
    }
        
    public void	 memGroupCalculationOnUpdate(List<SymphonyLF__Matter_Engagement_Model__c> newList, Map<Id, SymphonyLF__Matter_Engagement_Model__c> oldMap){
        system.debug('executing memGroupCalculationOnUpdate');

        Set<Id> memIdsForCalculation = new Set<Id>();

        for(SymphonyLF__Matter_Engagement_Model__c mem : newList) {
            if( this.memGrpTypes.contains(mem.SymphonyLF__Type__c)  &&
               ((mem.SymphonyLF__Trademark__c != null && mem.SymphonyLF__Trademark__c != oldMap.get(mem.Id).SymphonyLF__Trademark__c ) 
                || (mem.SymphonyLF__Patent__c != null && mem.SymphonyLF__Patent__c != oldMap.get(mem.Id).SymphonyLF__Patent__c ) 
                || (mem.SymphonyLF__General_Matter__c != null && mem.SymphonyLF__General_Matter__c != oldMap.get(mem.Id).SymphonyLF__General_Matter__c ) 
                || (mem.SymphonyLF__Design__c != null && mem.SymphonyLF__Design__c != oldMap.get(mem.Id).SymphonyLF__Design__c ) 
                || (mem.SymphonyLF__Copyright__c != null && mem.SymphonyLF__Copyright__c != oldMap.get(mem.Id).SymphonyLF__Copyright__c ) 
                || (mem.SymphonyLF__Agreements_Contracts__c != null && mem.SymphonyLF__Agreements_Contracts__c != oldMap.get(mem.Id).SymphonyLF__Agreements_Contracts__c ) 
                || (mem.SymphonyLF__Dispute_Opposition__c != null && mem.SymphonyLF__Dispute_Opposition__c != oldMap.get(mem.Id).SymphonyLF__Dispute_Opposition__c ) 
                || (mem.SymphonyLF__Supervisor_Client_Contact__c != null && mem.SymphonyLF__Supervisor_Client_Contact__c != oldMap.get(mem.Id).SymphonyLF__Supervisor_Client_Contact__c)		) )
            {
                memIdsForCalculation.add(mem.Id);
            }
        }
        if(memIdsForCalculation.size() > 0){
            memGroupCalculation(new List<Id>(memIdsForCalculation));
        }
    }

     @future
  public static void memGroupCalculationFuture(List<Id> memIds) {
    MatterEngagementModelDomain instance = new MatterEngagementModelDomain();
     instance.memGroupCalculation(memIds);
  }
    
    public void	 memGroupCalculation(List<Id> memIds){
        system.debug('executing memGroupCalculation');
        Set<Id> sObjectIdSet = new Set<Id>();
        

        List<SymphonyLF__Matter_Engagement_Model__c> newList = [
        SELECT Id, SymphonyLF__Type__c, SymphonyLF__Trademark__c, SymphonyLF__Patent__c, 
               SymphonyLF__General_Matter__c, SymphonyLF__Design__c, SymphonyLF__Copyright__c,
               SymphonyLF__Agreements_Contracts__c, SymphonyLF__Dispute_Opposition__c
        FROM SymphonyLF__Matter_Engagement_Model__c
        WHERE Id IN :memIds
    ];

        //Filter MEM Records for Processing MEM Group - filter with Type values from this.memGrpTypes.
        for(SymphonyLF__Matter_Engagement_Model__c mem : newList) {
            system.debug('setExecutedRecord 1 -> '+setExecutedRecord);
            if(!setExecutedRecord.contains(mem.Id)){
                system.debug('setExecutedRecord 2 -> '+setExecutedRecord);
                if(this.memGrpTypes.contains(mem.SymphonyLF__Type__c)  &&
                   (mem.SymphonyLF__Trademark__c != null || mem.SymphonyLF__Patent__c != null || 
                    mem.SymphonyLF__General_Matter__c != null ||mem.SymphonyLF__Design__c != null  || 
                    mem.SymphonyLF__Copyright__c != null || mem.SymphonyLF__Agreements_Contracts__c != null ||
                    mem.SymphonyLF__Dispute_Opposition__c != null ) )
                {
                    setExecutedRecord.add(mem.Id);
                    system.debug('setExecutedRecord 3 -> '+setExecutedRecord);
                    string sObjectId =  getSObjectId(mem);
                    if(sObjectId != ''){
                        system.debug('sObjectIdSet 123 --> '+sObjectIdSet);
                        //To get all MEM records which is related to the below Matter Id's
                        sObjectIdSet.add(sObjectId);
                    }
                }
            }
            
        }
        
        if(sObjectIdSet.size() > 0){
            system.debug('sObjectIdSet 321 --> '+sObjectIdSet);
            updateMEMLookupsInMEMGroup(sObjectIdSet);   
        }
    }
    
    public void validationOnTypeField(List<SymphonyLF__Matter_Engagement_Model__c> oldRecords){
        system.debug('executing validationOnTypeField');  
        Map<String,String> sObjectIdByMEM = New Map<String,String>();
        Set<Id> sObjectIdSet = new Set<Id>();
        
        // Collect SObject IDs from records being deleted
        for (SymphonyLF__Matter_Engagement_Model__c mem : oldRecords) {
            if( mem.SymphonyLF__Copyright__c != null || mem.SymphonyLF__Design__c != null ||
               mem.SymphonyLF__Dispute_Opposition__c != null || mem.SymphonyLF__General_Matter__c != null ||
               mem.SymphonyLF__Patent__c != null || mem.SymphonyLF__Trademark__c != null ||
               mem.SymphonyLF__Agreements_Contracts__c != null || mem.SymphonyLF__Mark__c != null ||
               mem.SymphonyLF__Design_Family__c != null || mem.SymphonyLF__Patent_Family__c != null)
            {
                string sObjectId =  getSObjectId(mem);   
                if(sObjectId != ''){
                    sObjectIdByMEM.put(mem.Id, sObjectId);
                    sObjectIdSet.add(sObjectId);
                }
            }
        }
        
        // Fetch all the matter engagement records for all the related SObjects
        List<SymphonyLF__Matter_Engagement_Model__c> matterEngagementRecords = [
            SELECT Id, Name,  SymphonyLF__Agreements_Contracts__c, SymphonyLF__Copyright__c, SymphonyLF__Design__c, 
            SymphonyLF__Dispute_Opposition__c, SymphonyLF__General_Matter__c, SymphonyLF__Patent__c,  SymphonyLF__Trademark__c,
            SymphonyLF__Type__c, SymphonyLF__Mark__c, SymphonyLF__Design_Family__c, SymphonyLF__Patent_Family__c
            FROM SymphonyLF__Matter_Engagement_Model__c
            WHERE (SymphonyLF__Trademark__c IN :sObjectIdSet ) OR (SymphonyLF__Patent__c IN :sObjectIdSet) OR 
            (SymphonyLF__General_Matter__c IN :sObjectIdSet) OR (SymphonyLF__Dispute_Opposition__c IN :sObjectIdSet) OR
            (SymphonyLF__Design__c IN :sObjectIdSet) OR (SymphonyLF__Copyright__c IN :sObjectIdSet) OR
            (SymphonyLF__Agreements_Contracts__c IN :sObjectIdSet) OR (SymphonyLF__Mark__c IN :sObjectIdSet) OR
            (SymphonyLF__Design_Family__c IN :sObjectIdSet) OR (SymphonyLF__Patent_Family__c IN :sObjectIdSet) ];
        
        Map<String, List<SymphonyLF__Matter_Engagement_Model__c>> mapOfMatterEngagementsBySObjectId  = new Map<String, List<SymphonyLF__Matter_Engagement_Model__c>>();
        
        for (SymphonyLF__Matter_Engagement_Model__c mem : matterEngagementRecords) {
            
            string sObjectId =  getSObjectId(mem);
            
            if (mapOfMatterEngagementsBySObjectId.containsKey(sObjectId)) {
                mapOfMatterEngagementsBySObjectId.get(sObjectId).add(mem);
            } else {
                mapOfMatterEngagementsBySObjectId.put(sObjectId, new List<SymphonyLF__Matter_Engagement_Model__c>{mem});
            }
        }
        
        
        // Check deletion validity
        for (SymphonyLF__Matter_Engagement_Model__c record : oldRecords) {
            if (record.SymphonyLF__Type__c != null && 
                this.restrictedMEMTypes.contains(record.SymphonyLF__Type__c) &&
                sObjectIdByMEM.containsKey(record.Id) ) {
                    
                    List<SymphonyLF__Matter_Engagement_Model__c> siblingRecords = mapOfMatterEngagementsBySObjectId.get(sObjectIdByMEM.get(record.Id));
                    
                    Integer matchingCount = 0;
                    if(siblingRecords != null && !siblingRecords.isEmpty()){
                        for (SymphonyLF__Matter_Engagement_Model__c sibling : siblingRecords) {
                            if (sibling.SymphonyLF__Type__c == record.SymphonyLF__Type__c && sibling.Id != record.Id) {
                                matchingCount++;
                            }
                        }
                    }
                    Map<String, String> picklistValuesMap = getPicklistValuesMap('SymphonyLF__Matter_Engagement_Model__c','SymphonyLF__Type__c');
                    system.debug('picklistValuesMap --> '+picklistValuesMap);
                    system.debug('picklistValuesMap.get(record.SymphonyLF__Type__c) --> '+picklistValuesMap.get(record.SymphonyLF__Type__c));
                    // If no matching sibling is found for the restricted type, throw an error
                    if (matchingCount == 0) {
                        if(picklistValuesMap.containsKey(record.SymphonyLF__Type__c) ){
                            record.addError('At least one ' + picklistValuesMap.get(record.SymphonyLF__Type__c) + ' record must be associated with the matter. Please add a new ' + picklistValuesMap.get(record.SymphonyLF__Type__c) + ' record to the matter before deleting this one.');
                        } else {
                            record.addError('At least one ' + record.SymphonyLF__Type__c + ' record must be associated with the matter. Please add a new ' + record.SymphonyLF__Type__c + ' record to the matter before deleting this one.');
                        }
                    }
                }
        }
    }
    
    public static string getSObjectId( sObject sObjectRec){
        //system.debug('executing getSObjectId');
        string objectName = (sObjectRec.Id).getSObjectType().getDescribe().getName();
        Id matterId;
        if(sObjectRec.get('SymphonyLF__Patent__c') != null) {matterId = (Id)sObjectRec.get('SymphonyLF__Patent__c');}
        else if(sObjectRec.get('SymphonyLF__Design__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Design__c');}
        else if(sObjectRec.get('SymphonyLF__Trademark__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Trademark__c');}
        else if(sObjectRec.get('SymphonyLF__Copyright__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Copyright__c');}
        else if(sObjectRec.get('SymphonyLF__General_Matter__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__General_Matter__c');}
        else if(sObjectRec.get('SymphonyLF__Dispute_Opposition__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Dispute_Opposition__c');}
        else if(objectName == 'SymphonyLF__Matter_Engagement_Model__c' && sObjectRec.get('SymphonyLF__Agreements_Contracts__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Agreements_Contracts__c');}
        
        else if(objectName == 'SymphonyLF__Docketing_Activity__c' && sObjectRec.get('SymphonyLF__Agreement_and_Contract__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Agreement_and_Contract__c');}
        
        //commented below lines since we are not creating MEM at family level at present
        else if(objectName == 'SymphonyLF__Matter_Engagement_Model__c' && sObjectRec.get('SymphonyLF__Design_Family__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Design_Family__c');}
        else if(objectName == 'SymphonyLF__Matter_Engagement_Model__c' && sObjectRec.get('SymphonyLF__Mark__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Mark__c');}
        else if(objectName == 'SymphonyLF__Matter_Engagement_Model__c' && sObjectRec.get('SymphonyLF__Patent_Family__c') != null){matterId = (Id)sObjectRec.get('SymphonyLF__Patent_Family__c');}
        
        return matterId;
    }
    
    public Map<string,string> getMEMGroupIdFromMEM(List<SymphonyLF__Matter_Engagement_Model__c> memList){
        system.debug('executing getMEMGroupIdFromMEM');
        Map<String,String> mapOfMEMGrpIdByMatterId = New Map<String,String>();
        if(memList.size() > 0 ){
            for(SymphonyLF__Matter_Engagement_Model__c mem : memList) {
                if(mem.SymphonyLF__Trademark__c != null || mem.SymphonyLF__Patent__c != null || 
                   mem.SymphonyLF__General_Matter__c != null ||mem.SymphonyLF__Design__c != null  || 
                   mem.SymphonyLF__Copyright__c != null || mem.SymphonyLF__Agreements_Contracts__c != null ||
                   mem.SymphonyLF__Dispute_Opposition__c != null )
                {
                    if(mem.SymphonyLF__Trademark__c != null && mem.SymphonyLF__Trademark__r.Matter_Engagement_Model_Group__c != null){
                        mapOfMEMGrpIdByMatterId.put(mem.SymphonyLF__Trademark__c, mem.SymphonyLF__Trademark__r.Matter_Engagement_Model_Group__c);
                    }
                    else if(mem.SymphonyLF__Patent__c != null && mem.SymphonyLF__Patent__r.Matter_Engagement_Model_Group__c != null){
                        mapOfMEMGrpIdByMatterId.put(mem.SymphonyLF__Patent__c, mem.SymphonyLF__Patent__r.Matter_Engagement_Model_Group__c);
                    }
                    else if(mem.SymphonyLF__General_Matter__c != null && mem.SymphonyLF__General_Matter__r.Matter_Engagement_Model_Group__c != null){
                        mapOfMEMGrpIdByMatterId.put(mem.SymphonyLF__General_Matter__c, mem.SymphonyLF__General_Matter__r.Matter_Engagement_Model_Group__c);
                    }
                    else if(mem.SymphonyLF__Design__c != null && mem.SymphonyLF__Design__r.Matter_Engagement_Model_Group__c != null){
                        mapOfMEMGrpIdByMatterId.put(mem.SymphonyLF__Design__c, mem.SymphonyLF__Design__r.Matter_Engagement_Model_Group__c);
                    }
                    else if(mem.SymphonyLF__Copyright__c != null && mem.SymphonyLF__Copyright__r.Matter_Engagement_Model_Group__c != null){
                        mapOfMEMGrpIdByMatterId.put(mem.SymphonyLF__Copyright__c, mem.SymphonyLF__Copyright__r.Matter_Engagement_Model_Group__c);
                    }
                    else if(mem.SymphonyLF__Agreements_Contracts__c != null && mem.SymphonyLF__Agreements_Contracts__r.Matter_Engagement_Model_Group__c != null){
                        mapOfMEMGrpIdByMatterId.put(mem.SymphonyLF__Agreements_Contracts__c, mem.SymphonyLF__Agreements_Contracts__r.Matter_Engagement_Model_Group__c);
                    }
                    else if(mem.SymphonyLF__Dispute_Opposition__c != null && mem.SymphonyLF__Dispute_Opposition__r.Matter_Engagement_Model_Group__c != null){
                        mapOfMEMGrpIdByMatterId.put(mem.SymphonyLF__Dispute_Opposition__c, mem.SymphonyLF__Dispute_Opposition__r.Matter_Engagement_Model_Group__c);
                    }
                }
            }               
        }
        return mapOfMEMGrpIdByMatterId;   
    }
    
    public static Map<String, String> getPicklistValuesMap(string sObjectName , string pickListFieldName) {
        system.debug('executing getPicklistValuesMap');
        if(sObjectName != null && pickListFieldName != null){
            Map<String, String> picklistValuesMap = new Map<String, String>();
            
            // Retrieve the field describe result for the field
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName); //SymphonyLF__Matter_Engagement_Model__c
            Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
            Schema.DescribeFieldResult describeFieldResult = describeSObjectResult.fields.getMap().get(pickListFieldName).getDescribe(); //'SymphonyLF__Type__c'
            
            // Get all picklist values
            List<Schema.PicklistEntry> picklistValues = describeFieldResult.getPicklistValues();
            
            // Iterate and store API name as key and label as value
            for (Schema.PicklistEntry entry : picklistValues) {
                if (entry.isActive()) { // Ensure only active picklist values are included
                    picklistValuesMap.put(entry.getValue(), entry.getLabel());
                }
            }
            return picklistValuesMap;
        }
        return null;
    }
}