/* Copyright © 2024 MaxVal Group. All Rights Reserved.
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Dinesh R, 08/01/25 
* Jira Ticket#MCC-1708
Test Class: MEMGroupTriggerHandlerTest
*/
public class MEMGroupTriggerHandler {
    
    //update MEM Group field on MEM records
    public void updateMEMLookupField(List<MEM_Group__c> memGrpList){
        Map<String, MEM_Group__c> memGrpIdByMatterId = New map<String, MEM_Group__c>();
        Set<Id> memIdSet = New Set<Id>();
        List<SymphonyLF__Matter_Engagement_Model__c> memToUpdate = New List<SymphonyLF__Matter_Engagement_Model__c>();
        
        //To collect all the MEM Id's which is related to the grp record (MemIdSet)
        //To store the MEM Grp record in Map by matter ID (memGrpIdByMatterId)
        for(MEM_Group__c memGrp :memGrpList){
            string matterId = getSObjectIdFromMEMgroup(memGrp);
            memGrpIdByMatterId.put(matterId, memGrp);   
            
            for (Integer i = 1; i <= 18; i++) {
                String fieldName = 'MEM_' + i + '__c';
                Id memId = (Id) memGrp.get(fieldName);
                if (memId != null) {
                    memIdSet.add(memId);
                }
            }      
        }
        
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
             WHERE ID IN:memIdSet];
        
        for(SymphonyLF__Matter_Engagement_Model__c mem : allMEMList){
            string matterId = MatterEngagementModelDomain.getSObjectId(mem);
            if(mem.MEM_Group__c == null || (matterId != '' && memGrpIdByMatterId.containsKey(matterId) && mem.MEM_Group__c != memGrpIdByMatterId.get(matterId).Id )){
                mem.MEM_Group__c = memGrpIdByMatterId.get(matterId).Id;
                memToUpdate.add(mem);
            }
            else if( !memGrpIdByMatterId.containsKey(matterId)){
                mem.MEM_Group__c = '';
                memToUpdate.add(mem);
            }
        }
        
        try{
            update memToUpdate;
            Set<Id> sObjectIdSet = New Set<Id>();
            for(string matterId : memGrpIdByMatterId.keyset()){
                sObjectIdSet.add((Id)matterId);
            }
            MatterEngagementModelDomain memDomain = New MatterEngagementModelDomain();
            memDomain.updateMEMLookupsInMEMGroup(sObjectIdSet);
        }
        catch(Exception exp){
            system.debug('Error Message :: '+exp.getMessage());
        }
    }
    
    public void processAfterInsertAndUpdate(List<MEM_Group__c> memGrpList){
        Map<String,String> mapOfMEMGrpIdByMatterId = New Map<String,String>();
        for(MEM_Group__c memGrp : memGrpList ){
            String sObjectId = getSObjectIdFromMEMgroup(memGrp);
            mapOfMEMGrpIdByMatterId.put(sObjectId, memGrp.id);
        }
        if(mapOfMEMGrpIdByMatterId.size() > 0){
            updateMEMGrpInMatter(mapOfMEMGrpIdByMatterId);
        }
    }
    
    public string getSObjectIdFromMEMgroup( MEM_Group__c memGrp){
        string sObjectId =  memGrp.Patent__c != null ? memGrp.Patent__c : 
        memGrp.Design__c != null ? memGrp.Design__c : 
        memGrp.Trademark__c != null ? memGrp.Trademark__c :
        memGrp.Agreement_Contract__c != null ? memGrp.Agreement_Contract__c :
        memGrp.Copyright__c != null ? memGrp.Copyright__c :
        memGrp.Dispute_Opposition__c != null ? memGrp.Dispute_Opposition__c :
        memGrp.General_Matter__c != null ? memGrp.General_Matter__c : '';
        return sObjectId;
    }
    
    //before Insert and Update
    public void updateMEMGrpInMatter(Map<String,String> mapOfMEMGrpIdByMatterId){
        
        if(mapOfMEMGrpIdByMatterId.size() > 0){
            Map<Id,SymphonyLF__Patent__c> patentMap = New Map<Id,SymphonyLF__Patent__c>([SELECT Id,Name,Matter_Engagement_Model_Group__c From SymphonyLF__Patent__c WHERE ID IN :mapOfMEMGrpIdByMatterId.keyset()]);
            Map<Id,SymphonyLF__Design__c> designMap = New Map<Id,SymphonyLF__Design__c>([SELECT Id,Name,Matter_Engagement_Model_Group__c From SymphonyLF__Design__c WHERE ID IN :mapOfMEMGrpIdByMatterId.keyset()]);
            Map<Id,SymphonyLF__Trademark__c> trademarkMap = New Map<Id,SymphonyLF__Trademark__c>([SELECT Id,Name,Matter_Engagement_Model_Group__c From SymphonyLF__Trademark__c WHERE ID IN :mapOfMEMGrpIdByMatterId.keyset()]);
            Map<Id,SymphonyLF__Agreement_Contract__c> aggrementContractsMap = New Map<Id,SymphonyLF__Agreement_Contract__c>([SELECT Id,Name,Matter_Engagement_Model_Group__c From SymphonyLF__Agreement_Contract__c WHERE ID IN :mapOfMEMGrpIdByMatterId.keyset()]);
            Map<Id,SymphonyLF__Copyright__c> copyrightMap = New Map<Id,SymphonyLF__Copyright__c>([SELECT Id,Name,Matter_Engagement_Model_Group__c From SymphonyLF__Copyright__c WHERE ID IN :mapOfMEMGrpIdByMatterId.keyset()]);
            Map<Id,SymphonyLF__Dispute_Opposition__c> disputeOppositionMap = New Map<Id,SymphonyLF__Dispute_Opposition__c>([SELECT Id,Name,Matter_Engagement_Model_Group__c From SymphonyLF__Dispute_Opposition__c WHERE ID IN :mapOfMEMGrpIdByMatterId.keyset()]);
            Map<Id,SymphonyLF__General_Matter__c> generalMatterMap = New Map<Id,SymphonyLF__General_Matter__c>([SELECT Id,Name,Matter_Engagement_Model_Group__c From SymphonyLF__General_Matter__c WHERE ID IN :mapOfMEMGrpIdByMatterId.keyset()]);
            
            try{
                
                
                List<SymphonyLF__Patent__c> patentsToUpdate = New List<SymphonyLF__Patent__c>();
                for(SymphonyLF__Patent__c patent : patentMap.values()){
                    if(patent.Matter_Engagement_Model_Group__c == null || 
                       mapOfMEMGrpIdByMatterId.containskey(patent.Id) && patent.Matter_Engagement_Model_Group__c !=  mapOfMEMGrpIdByMatterId.get(patent.Id) ){
                           patent.Matter_Engagement_Model_Group__c = mapOfMEMGrpIdByMatterId.get(patent.Id);
                           patentsToUpdate.add(patent);
                       }
                }
                if(patentsToUpdate.size() > 0 ){update patentsToUpdate;}
                
                List<SymphonyLF__Design__c> designsToUpdate = New List<SymphonyLF__Design__c>();
                for(SymphonyLF__Design__c design : designMap.values()){
                    if(design.Matter_Engagement_Model_Group__c == null || 
                       mapOfMEMGrpIdByMatterId.containskey(design.Id) && design.Matter_Engagement_Model_Group__c !=  mapOfMEMGrpIdByMatterId.get(design.Id) ){
                           design.Matter_Engagement_Model_Group__c = mapOfMEMGrpIdByMatterId.get(design.Id);
                           designsToUpdate.add(design);
                       }
                }
                if(designsToUpdate.size() > 0 ){update designsToUpdate;}
                
                List<SymphonyLF__Trademark__c> tmToUpdate = New List<SymphonyLF__Trademark__c>();
                for(SymphonyLF__Trademark__c tm : trademarkMap.values()){
                    if(tm.Matter_Engagement_Model_Group__c == null || 
                       mapOfMEMGrpIdByMatterId.containskey(tm.Id) && tm.Matter_Engagement_Model_Group__c !=  mapOfMEMGrpIdByMatterId.get(tm.Id) ){
                           tm.Matter_Engagement_Model_Group__c = mapOfMEMGrpIdByMatterId.get(tm.Id);
                           tmToUpdate.add(tm);
                       }
                }
                if(tmToUpdate.size() > 0 ){update tmToUpdate;}
                
                List<SymphonyLF__Agreement_Contract__c> agreementConToUpdate = New List<SymphonyLF__Agreement_Contract__c>();
                for(SymphonyLF__Agreement_Contract__c ac : aggrementContractsMap.values()){
                    if(ac.Matter_Engagement_Model_Group__c == null || 
                       mapOfMEMGrpIdByMatterId.containskey(ac.Id) && ac.Matter_Engagement_Model_Group__c !=  mapOfMEMGrpIdByMatterId.get(ac.Id) ){
                           ac.Matter_Engagement_Model_Group__c = mapOfMEMGrpIdByMatterId.get(ac.Id);
                           agreementConToUpdate.add(ac);
                       }
                }
                if(agreementConToUpdate.size() > 0 ){update agreementConToUpdate;}
                
                List<SymphonyLF__Copyright__c> copyrightsToUpdate = New List<SymphonyLF__Copyright__c>();
                for(SymphonyLF__Copyright__c copyright : copyrightMap.values()){
                    if(copyright.Matter_Engagement_Model_Group__c == null || 
                       mapOfMEMGrpIdByMatterId.containskey(copyright.Id) && copyright.Matter_Engagement_Model_Group__c !=  mapOfMEMGrpIdByMatterId.get(copyright.Id) ){
                           copyright.Matter_Engagement_Model_Group__c = mapOfMEMGrpIdByMatterId.get(copyright.Id);
                           copyrightsToUpdate.add(copyright);
                       }
                }
                if(copyrightsToUpdate.size() > 0 ){update copyrightsToUpdate;}
                
                List<SymphonyLF__Dispute_Opposition__c> dispOppToUpdate = New List<SymphonyLF__Dispute_Opposition__c>();
                for(SymphonyLF__Dispute_Opposition__c dispOpp : disputeOppositionMap.values()){
                    if(dispOpp.Matter_Engagement_Model_Group__c == null || 
                       mapOfMEMGrpIdByMatterId.containskey(dispOpp.Id) && dispOpp.Matter_Engagement_Model_Group__c !=  mapOfMEMGrpIdByMatterId.get(dispOpp.Id) ){
                           dispOpp.Matter_Engagement_Model_Group__c = mapOfMEMGrpIdByMatterId.get(dispOpp.Id);
                           dispOppToUpdate.add(dispOpp);
                       }
                }
                if(dispOppToUpdate.size() > 0 ){update dispOppToUpdate;}
                
                List<SymphonyLF__General_Matter__c> generalmatterToUpdate = New List<SymphonyLF__General_Matter__c>();
                for(SymphonyLF__General_Matter__c generalMatter : generalMatterMap.values()){
                    if(generalMatter.Matter_Engagement_Model_Group__c == null || 
                       mapOfMEMGrpIdByMatterId.containskey(generalMatter.Id) && generalMatter.Matter_Engagement_Model_Group__c !=  mapOfMEMGrpIdByMatterId.get(generalMatter.Id) ){
                           generalMatter.Matter_Engagement_Model_Group__c = mapOfMEMGrpIdByMatterId.get(generalMatter.Id);
                           generalmatterToUpdate.add(generalMatter);
                       }
                }
                if(generalmatterToUpdate.size() > 0 ){update generalmatterToUpdate;}
            }
            catch(Exception exp){
                system.debug('Error Message :: '+exp.getMessage());
            }
        }
    }
    
    //to update String fields of MEM Group using MEM contact Person - (Attorneys, WorkingAttorneys, Paralegals)
    public void beforeInsertORUpdate(List<MEM_Group__c> triggerNew){
        Map<String, MEM_Group__c> memGrpIdByMatterId = New map<String, MEM_Group__c>();
        Set<Id> memIdSet = New Set<Id>();
        List<SymphonyLF__Matter_Engagement_Model__c> memToUpdate = New List<SymphonyLF__Matter_Engagement_Model__c>();
        
        //To store the MEM Grp record in Map by matter ID (memGrpIdByMatterId)
        for(MEM_Group__c memGrp :triggerNew){
            string matterId = getSObjectIdFromMEMgroup(memGrp);
            memGrpIdByMatterId.put(matterId, memGrp);
            
            for (Integer i = 1; i <= 18; i++) {
                String fieldName = 'MEM_' + i + '__c';
                Id memId = (Id) memGrp.get(fieldName);
                if (memId != null) {
                    memIdSet.add(memId);
                }
            }         
        }   
        
        List<SymphonyLF__Matter_Engagement_Model__c> allMEMList = 
            [SELECT Id, Name, SymphonyLF__Type__c, MEM_Group__c,
             SymphonyLF__Patent__c, SymphonyLF__Patent__r.Matter_Engagement_Model_Group__c,
             SymphonyLF__Design__c, SymphonyLF__Design__r.Matter_Engagement_Model_Group__c,
             SymphonyLF__Trademark__c, SymphonyLF__Trademark__r.Matter_Engagement_Model_Group__c,
             SymphonyLF__Agreements_Contracts__c, SymphonyLF__Agreements_Contracts__r.Matter_Engagement_Model_Group__c,
             SymphonyLF__Copyright__c, SymphonyLF__Copyright__r.Matter_Engagement_Model_Group__c,
             SymphonyLF__Dispute_Opposition__c, SymphonyLF__Dispute_Opposition__r.Matter_Engagement_Model_Group__c,
             SymphonyLF__General_Matter__c, SymphonyLF__General_Matter__r.Matter_Engagement_Model_Group__c,
             SymphonyLF__Assign_to_User__c, SymphonyLF__Assign_to_User__r.name
             FROM SymphonyLF__Matter_Engagement_Model__c
             WHERE ID IN:MemIdSet AND Is_Active__c = true
             Order By CreatedDate ASC];
        
        //Attorney__c , Working_Attorneys__c , Paralegals__c
        
        Map<String, List<SymphonyLF__Matter_Engagement_Model__c>> mapOfMatterEngagementsBySObjectId  = new Map<String, List<SymphonyLF__Matter_Engagement_Model__c>>();
        //Store MEM records into the Map of SObject Id's
        for (SymphonyLF__Matter_Engagement_Model__c mem : allMEMList) {
            string sObjectId = MatterEngagementModelDomain.getSObjectId(mem);
            if (mapOfMatterEngagementsBySObjectId.containsKey(sObjectId)) {
                mapOfMatterEngagementsBySObjectId.get(sObjectId).add(mem);
            } else {
                mapOfMatterEngagementsBySObjectId.put(sObjectId, new List<SymphonyLF__Matter_Engagement_Model__c>{mem});
            }
        }
        
        for(MEM_Group__c memGrp :triggerNew){
            String sObjectId = getSObjectIdFromMEMgroup(memGrp);
            
            memGrp.Attorney__c =  '';
            memGrp.Working_Attorneys__c = '';
            memGrp.Paralegals__c = '';
            
            if(mapOfMatterEngagementsBySObjectId.containskey(sObjectId) && mapOfMatterEngagementsBySObjectId.get(sObjectId).size() > 0){
                
                for(SymphonyLF__Matter_Engagement_Model__c mem : mapOfMatterEngagementsBySObjectId.get(sObjectId)){
                    
                    if(mem.SymphonyLF__Assign_to_User__c != null && mem.SymphonyLF__Type__c == 'Paralegal'){
                        memGrp.Paralegals__c = memGrp.Paralegals__c == '' ? mem.SymphonyLF__Assign_to_User__r.name : memGrp.Paralegals__c +','+mem.SymphonyLF__Assign_to_User__r.name;
                    }
                    else if(mem.SymphonyLF__Assign_to_User__c != null && 
                            (mem.SymphonyLF__Type__c == 'Responsible (Billing) Attorney'
                             || mem.SymphonyLF__Type__c == 'Backup Attorney'
                             || mem.SymphonyLF__Type__c == 'Managing (Supervising) Attorney'
                             || mem.SymphonyLF__Type__c == 'Originating Attorney'
                             ) ){
                                 
                                 memGrp.Attorney__c = memGrp.Attorney__c == '' ? mem.SymphonyLF__Assign_to_User__r.name : memGrp.Attorney__c +','+mem.SymphonyLF__Assign_to_User__r.name;
                             }
                    else if(mem.SymphonyLF__Assign_to_User__c != null && mem.SymphonyLF__Type__c == 'Working Attorney'){
                        memGrp.Working_Attorneys__c = memGrp.Working_Attorneys__c == '' ? mem.SymphonyLF__Assign_to_User__r.name : memGrp.Working_Attorneys__c +','+mem.SymphonyLF__Assign_to_User__r.name;
                    }
                }
            }
            
        }
    }
    
    //afterInsert
    public void processAfterUpdate(List<MEM_Group__c> triggerNew, Map<Id, MEM_Group__c> triggerOldMap){
        Set<Id> sObjectIdSet = New Set<Id>();
        List<MEM_Group__c> memGrpList = New List<MEM_Group__c>();
        boolean isMEMChanged = false;
        for(MEM_Group__c grp : triggerNew){
            isMEMChanged = false;
            for (Integer i = 1; i <= 18; i++) {
                String fieldName = 'MEM_' + i + '__c';
                //Id memId = (Id) grp.get(fieldName);
                if ((Id) grp.get(fieldName) != (Id) (triggerOldMap.get(grp.Id)).get(fieldName)) {
                    isMEMChanged = true;
                }
            }
            if(isMEMChanged == true){
                memGrpList.add(grp);
            }
            
            if( (grp.Patent__c != triggerOldMap.get(grp.Id).Patent__c) ||
               (grp.Design__c != triggerOldMap.get(grp.Id).Design__c) ||
               (grp.Trademark__c != triggerOldMap.get(grp.Id).Trademark__c) ||
               (grp.Agreement_Contract__c != triggerOldMap.get(grp.Id).Agreement_Contract__c) ||
               (grp.Copyright__c != triggerOldMap.get(grp.Id).Copyright__c) ||
               (grp.General_Matter__c != triggerOldMap.get(grp.Id).General_Matter__c) ||
               (grp.Dispute_Opposition__c != triggerOldMap.get(grp.Id).Dispute_Opposition__c)  ){
                   
                   string matterID = getSObjectIdFromMEMgroup(grp);
                   string matterID1 = getSObjectIdFromMEMgroup(triggerOldMap.get(grp.Id));
                   if(matterId != '' || matterId != null ){
                       sObjectIdSet.add((Id)matterId);
                       sObjectIdSet.add((Id)matterID1);                        
                   }
               }
            if(sObjectIdSet.size() > 0){
                updaterelatedDA(sObjectIdSet);
                
                MatterEngagementModelDomain memDomain = New MatterEngagementModelDomain();
                memDomain.updateMEMLookupsInMEMGroup(sObjectIdSet);
            }
        }
        // if(memGrpList.size() > 0){
        //     updateMEMLookupField(memGrpList);
        // }
    }
    
    //afterInsert
    public void processAfterInsert(List<MEM_Group__c> triggerNew){
        
        Set<Id> sObjectIdSet = New Set<Id>();
        for(MEM_Group__c grp : triggerNew){
            string matterID = getSObjectIdFromMEMgroup(grp);
            if(matterId != '' || matterId != null ){
                sObjectIdSet.add((Id)matterId);
            }
        }
        if(sObjectIdSet.size() > 0){
            updaterelatedDA(sObjectIdSet);
        }
    }
    
    public void updaterelatedDA(Set<Id> sObjectIdSet){
        List<MEM_Group__c> memGrpList = [SELECT ID, Name, Patent__c, Design__c, Trademark__c, Agreement_Contract__c, 
                                         Copyright__c, Dispute_Opposition__c, General_Matter__c
                                         FROM MEM_Group__c
                                         WHERE   (Patent__c IN :sObjectIdSet) OR 
                                         (Design__c IN :sObjectIdSet) OR 
                                         (Trademark__c IN :sObjectIdSet ) OR 
                                         (Agreement_Contract__c IN :sObjectIdSet) OR 
                                         (Copyright__c IN :sObjectIdSet) OR 
                                         (Dispute_Opposition__c IN :sObjectIdSet) OR
                                         (General_Matter__c IN :sObjectIdSet) ];
        
        Map<String,String> mapOfMEMGrpIdByMatterId = New Map<String,String>();
        
        for(MEM_Group__c grp : memGrpList){
            string matterID = getSObjectIdFromMEMgroup(grp);
            if(matterId != '' || matterId != null ){
                mapOfMEMGrpIdByMatterId.put(matterID, grp.Id);
            }
        }
        
        List<SymphonyLF__Docketing_Activity__c> docketingActivityToUpdate = New List<SymphonyLF__Docketing_Activity__c>();
        //get all SymphonyLF__Docketing_Activity__c records which is related to the Matter Id's store in the sObjectIdSet.
        List<SymphonyLF__Docketing_Activity__c> allDocketingActivityList = 
            [SELECT Id, Name, MEM_Group__c, SymphonyLF__Patent__c, SymphonyLF__Design__c, SymphonyLF__Trademark__c,
             SymphonyLF__Agreement_and_Contract__c,SymphonyLF__Copyright__c,SymphonyLF__Dispute_Opposition__c,SymphonyLF__General_Matter__c
             FROM SymphonyLF__Docketing_Activity__c 
             WHERE 	(SymphonyLF__Patent__c IN :sObjectIdSet) OR (SymphonyLF__Design__c IN :sObjectIdSet) OR 
             (SymphonyLF__Trademark__c IN :sObjectIdSet ) OR (SymphonyLF__Agreement_and_Contract__c IN :sObjectIdSet) OR 
             (SymphonyLF__Copyright__c IN :sObjectIdSet) OR (SymphonyLF__Dispute_Opposition__c IN :sObjectIdSet) OR
             (SymphonyLF__General_Matter__c IN :sObjectIdSet)];
        
        for(SymphonyLF__Docketing_Activity__c docketingActivity : allDocketingActivityList){
            string sObjectId =  MatterEngagementModelDomain.getSObjectId(docketingActivity);
            if(sObjectId != '' && mapOfMEMGrpIdByMatterId.containsKey(sObjectId) && docketingActivity.MEM_Group__c == null){
                docketingActivity.MEM_Group__c = mapOfMEMGrpIdByMatterId.get(sObjectId);
            }
            else if(sObjectId != '' && mapOfMEMGrpIdByMatterId.containsKey(sObjectId) && docketingActivity.MEM_Group__c != mapOfMEMGrpIdByMatterId.get(sObjectId)){
                docketingActivity.MEM_Group__c = mapOfMEMGrpIdByMatterId.get(sObjectId);
            }
            docketingActivityToUpdate.add(docketingActivity);
        }
        update docketingActivityToUpdate;
    }
}