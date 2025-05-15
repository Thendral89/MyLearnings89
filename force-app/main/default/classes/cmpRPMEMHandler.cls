public with sharing class cmpRPMEMHandler {
    @future
    public static void memCreationLegalAssistantfuture(Set<Id> newList) {
        cmpRPMEMHandler.memCreationLegalAssistant(newList);
    }
    
    public static void memCreationLegalAssistant(Set<Id> newList) {
            System.debug('newList: ' + newList);

            
            List<SymphonyLF__Matter_Engagement_Model__c> memInScope = [
                SELECT Id, SymphonyLF__Assign_to_User__c, SymphonyLF__Copyright__c, SymphonyLF__Mark__c,
                        SymphonyLF__Patent_Family__c, SymphonyLF__Design_Family__c, SymphonyLF__Design__c, 
                    SymphonyLF__Agreements_Contracts__c, Is_Active__c, SymphonyLF__Dispute_Opposition__c, 
                    SymphonyLF__General_Matter__c, SymphonyLF__Patent__c,  SymphonyLF__Trademark__c
                    , SymphonyLF__Client__c
                    , SymphonyLF__Copyright__r.SymphonyLF__Client__c
                    , SymphonyLF__Mark__r.SymphonyLF__Client__c
                    , SymphonyLF__Patent_Family__r.SymphonyLF__Client__c
                    , SymphonyLF__Design_Family__r.SymphonyLF__Client__c
                    , SymphonyLF__Design__r.SymphonyLF__Client__c
                    , SymphonyLF__Agreements_Contracts__r.SymphonyLF__Client__c
                    , SymphonyLF__Dispute_Opposition__r.SymphonyLF__Client__c
                    , SymphonyLF__General_Matter__r.SymphonyLF__Client__c
                    , SymphonyLF__Patent__r.SymphonyLF__Client__c
                    , SymphonyLF__Trademark__r.SymphonyLF__Client__c
                FROM SymphonyLF__Matter_Engagement_Model__c
                WHERE Id IN :newList
                AND (SymphonyLF__Assign_to_User__r.SymphonyLF__Type__c IN ('Attorney', 'Paralegal'))
            ];

            System.debug('memInScope: ' + memInScope);

            
            Set<Id> personIds = new Set<Id>();
            Set<Id> objectIds = new Set<Id>();
            Set<Id> newMEMIds = new Set<Id>();
            Set<Id> clientIds = new Set<Id>();

            Map<Id, Id> memInScopeToClientId = new Map<Id, Id>();

            for (SymphonyLF__Matter_Engagement_Model__c mem : memInScope) {
                newMEMIds.add(mem.Id);
                if (mem.SymphonyLF__Assign_to_User__c != null) {
                    personIds.add(mem.SymphonyLF__Assign_to_User__c);
                }

                Id clientIdOnMem = getClientIdOnMem(mem);
                if(clientIdOnMem != null){
                    clientIds.add(clientIdOnMem);
                    memInScopeToClientId.put(mem.Id, clientIdOnMem);
                } 
                
                if (mem.SymphonyLF__Copyright__c != null) objectIds.add(mem.SymphonyLF__Copyright__c);
                if (mem.SymphonyLF__Design__c != null) objectIds.add(mem.SymphonyLF__Design__c);
                if (mem.SymphonyLF__Agreements_Contracts__c != null) objectIds.add(mem.SymphonyLF__Agreements_Contracts__c);
                if (mem.SymphonyLF__Dispute_Opposition__c != null) objectIds.add(mem.SymphonyLF__Dispute_Opposition__c);
                if (mem.SymphonyLF__General_Matter__c != null) objectIds.add(mem.SymphonyLF__General_Matter__c);
                if (mem.SymphonyLF__Patent__c != null) objectIds.add(mem.SymphonyLF__Patent__c);
                if (mem.SymphonyLF__Trademark__c != null) objectIds.add(mem.SymphonyLF__Trademark__c);
                if (mem.SymphonyLF__Design_Family__c != null) objectIds.add(mem.SymphonyLF__Design_Family__c);
                if (mem.SymphonyLF__Mark__c != null) objectIds.add(mem.SymphonyLF__Mark__c);
                if (mem.SymphonyLF__Patent_Family__c != null) objectIds.add(mem.SymphonyLF__Patent_Family__c);
            }

          
            Map<Id, Set<Id>> attorneyToLegalAssistantMap = new Map<Id, Set<Id>>();
            for (Legal_Assistant__c la : [
                SELECT Attorney_Paralegal__c, Legal_Assistant__c
                FROM Legal_Assistant__c
                WHERE Attorney_Paralegal__c IN :personIds AND Legal_Assistant__r.SymphonyLF__Type__c = 'Assistant'
            ]) {
                if (!attorneyToLegalAssistantMap.containsKey(la.Attorney_Paralegal__c)) {
                    attorneyToLegalAssistantMap.put(la.Attorney_Paralegal__c, new Set<Id>());
                }
                attorneyToLegalAssistantMap.get(la.Attorney_Paralegal__c).add(la.Legal_Assistant__c);
            }

           
            Set<Id> legalAssistantIds = new Set<Id>();
            for (Set<Id> idSet : attorneyToLegalAssistantMap.values()) {
                legalAssistantIds.addAll(idSet);
            }

            System.debug('BBB clientIds ' + clientIds);
            System.debug('BBB legalAssistantIds ' + legalAssistantIds);
            Map<String, Id> legalAssistantOnCemTocemId = new Map<String, Id>();
            for(SymphonyLF__Client_Engagement_Model__c c : [
                SELECT 
                    Id
                    , SymphonyLF__Client__c
                    , SymphonyLF__Person__c
                    , SymphonyLF__Type__c
                FROM SymphonyLF__Client_Engagement_Model__c 
                WHERE 
                    SymphonyLF__Person__c IN :legalAssistantIds
                    AND SymphonyLF__Client__c IN :clientIds
                    AND Is_Active__c = true
                    AND SymphonyLF__Type__c IN ('Legal Assistant')
            ]){
                legalAssistantOnCemTocemId.put(c.SymphonyLF__Client__c + '-' + c.SymphonyLF__Person__c, c.Id);
            }

            System.debug('BBB legalAssistantOnCemTocemId ' + legalAssistantOnCemTocemId);
        
            Map<String, SymphonyLF__Matter_Engagement_Model__c> existingMemMap = new Map<String, SymphonyLF__Matter_Engagement_Model__c>();
            for (SymphonyLF__Matter_Engagement_Model__c existingMem : [
                SELECT Id, SymphonyLF__Assign_to_User__c, Is_Active__c, SymphonyLF__Copyright__c, SymphonyLF__Design__c,
                        SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c, SymphonyLF__Design_Family__c,
                    SymphonyLF__Agreements_Contracts__c, SymphonyLF__Dispute_Opposition__c, SymphonyLF__General_Matter__c,
                    SymphonyLF__Patent__c, SymphonyLF__Trademark__c
                FROM SymphonyLF__Matter_Engagement_Model__c
                WHERE SymphonyLF__Assign_to_User__c IN :legalAssistantIds
                AND Id NOT IN :newMEMIds
                AND (
                    SymphonyLF__Copyright__c IN :objectIds OR
                    SymphonyLF__Design__c IN :objectIds OR
                    SymphonyLF__Agreements_Contracts__c IN :objectIds OR
                    SymphonyLF__Dispute_Opposition__c IN :objectIds OR
                    SymphonyLF__General_Matter__c IN :objectIds OR
                    SymphonyLF__Patent__c IN :objectIds OR
                    SymphonyLF__Trademark__c IN :objectIds OR
                    SymphonyLF__Mark__c IN :objectIds OR
                    SymphonyLF__Patent_Family__c IN :objectIds OR
                    SymphonyLF__Design_Family__c IN :objectIds
                )
            ]) {
                Id uniqueMatterId =  getSingleMatterId(existingMem);
   
            String key = existingMem.SymphonyLF__Assign_to_User__c + '_' + uniqueMatterId;
                                   
                existingMemMap.put(key, existingMem);
            }

                Set<String> compareLAkey = new Set<String>();
                
                

            List<SymphonyLF__Matter_Engagement_Model__c> memToInsert = new List<SymphonyLF__Matter_Engagement_Model__c>();
            List<SymphonyLF__Matter_Engagement_Model__c> memToUpdate = new List<SymphonyLF__Matter_Engagement_Model__c>();
            for (SymphonyLF__Matter_Engagement_Model__c mem : memInScope) {
                if (attorneyToLegalAssistantMap.containsKey(mem.SymphonyLF__Assign_to_User__c)) {
                    for (Id legalAssistantId : attorneyToLegalAssistantMap.get(mem.SymphonyLF__Assign_to_User__c)) {              
                            Id uniqueMatterId =  getSingleMatterId(mem);
                            
          
                 String key = legalAssistantId + '_' + uniqueMatterId;

                       
                                
                        if (!existingMemMap.containsKey(key) && !compareLAkey.contains(key)) {
                            Id clientId = memInScopeToClientId.get(mem.Id);

                            String k = clientId + '-' + legalAssistantId;
                            Id cemId = legalAssistantOnCemTocemId.get(k);
                            System.debug('BBB cemId ' + cemId);
                            System.debug('BBB k ' + k);

                            memToInsert.add(new SymphonyLF__Matter_Engagement_Model__c(
                                SymphonyLF__Assign_to_User__c = legalAssistantId,
                                SymphonyLF__Type__c = 'Legal Assistant',
                                SymphonyLF__Copyright__c = mem.SymphonyLF__Copyright__c,
                                SymphonyLF__Design__c = mem.SymphonyLF__Design__c,
                                SymphonyLF__Agreements_Contracts__c = mem.SymphonyLF__Agreements_Contracts__c,
                                SymphonyLF__Dispute_Opposition__c = mem.SymphonyLF__Dispute_Opposition__c,
                                SymphonyLF__General_Matter__c = mem.SymphonyLF__General_Matter__c,
                                SymphonyLF__Patent__c = mem.SymphonyLF__Patent__c,
                                SymphonyLF__Trademark__c = mem.SymphonyLF__Trademark__c,
                                SymphonyLF__Mark__c = mem.SymphonyLF__Mark__c,
                                SymphonyLF__Design_Family__c = mem.SymphonyLF__Design_Family__c,
                                SymphonyLF__Patent_Family__c = mem.SymphonyLF__Patent_Family__c,
                                Is_Active__c = mem.Is_Active__c,
                                Client_Engagement_Model__c = cemId,
                                SymphonyLF__Client__c = clientId
                            ));
                            compareLAkey.add(key);
                        }
                        else if(existingMemMap.containsKey(key)){
                               SymphonyLF__Matter_Engagement_Model__c memInstance = existingMemMap.get(key);
                               if (memInstance.Is_Active__c == false) {
                               memInstance.Is_Active__c = true;

                               memToUpdate.add(memInstance);
                               }
                        }
                    }
                }
            }

            if (!memToInsert.isEmpty()) {
                insert memToInsert;
            }
            System.debug('Inserted MEMs: ' + memToInsert.size());

            if (!memToUpdate.isEmpty()) {
                update memToUpdate;
            }
            System.debug('Updated MEMs: ' + memToUpdate.size());
    }

    private static Id getClientIdOnMem(SymphonyLF__Matter_Engagement_Model__c mem){
        List<Id> clientIds = new List<Id>();
        if(mem.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Client__c);

        if (mem.SymphonyLF__Copyright__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Copyright__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Design__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Design__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Agreements_Contracts__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Agreements_Contracts__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Dispute_Opposition__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Dispute_Opposition__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__General_Matter__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__General_Matter__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Patent__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Patent__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Trademark__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Trademark__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Design_Family__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Design_Family__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Mark__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Mark__r.SymphonyLF__Client__c);
        if (mem.SymphonyLF__Patent_Family__r.SymphonyLF__Client__c != null) clientIds.add(mem.SymphonyLF__Patent_Family__r.SymphonyLF__Client__c);

        if(clientIds.size() > 0){
            return clientIds[0];
        }

        return null;
    }

     
    @future
    public static void updateLegalAssistantsfuture(Set<Id> newRecords, Set<Id> oldMap) {
        cmpRPMEMHandler.updateLegalAssistants(newRecords,oldMap);
    }

    public static void updateLegalAssistants(Set<Id> newRecordIds, Set<Id> oldRecordIds) {
            if (newRecordIds.isEmpty() && oldRecordIds.isEmpty()) return;

            Set<Id> combinedIds = new Set<Id>();
            combinedIds.addAll(newRecordIds);
            combinedIds.addAll(oldRecordIds);

            List<SymphonyLF__Matter_Engagement_Model__c> memList = [
                SELECT Id, SymphonyLF__Assign_to_User__c,Is_Active__c, SymphonyLF__Assign_to_User__r.SymphonyLF__Type__c,
                    SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c, SymphonyLF__Design_Family__c,
                    SymphonyLF__Copyright__c, SymphonyLF__Design__c, SymphonyLF__Agreements_Contracts__c,
                    SymphonyLF__Dispute_Opposition__c, SymphonyLF__General_Matter__c,
                    SymphonyLF__Patent__c, SymphonyLF__Trademark__c, SymphonyLF__Type__c
                FROM SymphonyLF__Matter_Engagement_Model__c
                WHERE Id IN :combinedIds
            ];

            Set<Id> matterIds = new Set<Id>();
            Set<Id> attorneyParalegalIds = new Set<Id>();

            for (SymphonyLF__Matter_Engagement_Model__c mem : memList) {
                String matterId = MatterEngagementModelDomain.getSObjectId(mem);
                if (!String.isBlank(matterId)) matterIds.add(Id.valueOf(matterId));
                if (mem.SymphonyLF__Assign_to_User__r?.SymphonyLF__Type__c == 'Attorney' || 
                    mem.SymphonyLF__Assign_to_User__r?.SymphonyLF__Type__c == 'Paralegal') {
                    attorneyParalegalIds.add(mem.SymphonyLF__Assign_to_User__c);
                }
            }

            if (attorneyParalegalIds.isEmpty() || matterIds.isEmpty()) return;

            
            List<Legal_Assistant__c> directMappings = [
                SELECT Attorney_Paralegal__c, Legal_Assistant__c
                FROM Legal_Assistant__c
                WHERE Attorney_Paralegal__c IN :attorneyParalegalIds
            ];

            Set<Id> legalAssistantIds = new Set<Id>();
            for (Legal_Assistant__c la : directMappings) {
                if (la.Legal_Assistant__c != null) {
                    legalAssistantIds.add(la.Legal_Assistant__c);
                }
            }

            
            List<Legal_Assistant__c> allLAMappings = new List<Legal_Assistant__c>();
            if (!legalAssistantIds.isEmpty()) {
                allLAMappings = [
                    SELECT Attorney_Paralegal__c, Legal_Assistant__c
                    FROM Legal_Assistant__c
                    WHERE Legal_Assistant__c IN :legalAssistantIds
                ];
            }

            
            Map<Id, Set<Id>> laToAllAttorneysMap = new Map<Id, Set<Id>>();
            Set<Id> allAttorneyIds = new Set<Id>();

            for (Legal_Assistant__c la : allLAMappings) {
                if (la.Legal_Assistant__c == null || la.Attorney_Paralegal__c == null) continue;
                allAttorneyIds.add(la.Attorney_Paralegal__c);

                if (!laToAllAttorneysMap.containsKey(la.Legal_Assistant__c)) {
                    laToAllAttorneysMap.put(la.Legal_Assistant__c, new Set<Id>());
                }
                laToAllAttorneysMap.get(la.Legal_Assistant__c).add(la.Attorney_Paralegal__c);
            }

          
            List<SymphonyLF__Matter_Engagement_Model__c> attorneyMEMs = [
                SELECT Id, SymphonyLF__Assign_to_User__c, Is_Active__c,
                    SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c, SymphonyLF__Design_Family__c,
                    SymphonyLF__Copyright__c, SymphonyLF__Design__c, SymphonyLF__Agreements_Contracts__c,
                    SymphonyLF__Dispute_Opposition__c, SymphonyLF__General_Matter__c,
                    SymphonyLF__Patent__c, SymphonyLF__Trademark__c
                FROM SymphonyLF__Matter_Engagement_Model__c
                WHERE SymphonyLF__Assign_to_User__c IN :allAttorneyIds
            ];

            Map<String, Boolean> assistantMatterActiveMap = new Map<String, Boolean>();
            for (Id laId : laToAllAttorneysMap.keySet()) {
                for (Id matterId : matterIds) {
                    assistantMatterActiveMap.put(laId + ':' + matterId, false);
                }
            }

            for (SymphonyLF__Matter_Engagement_Model__c mem : attorneyMEMs) {
                if (!mem.Is_Active__c) continue;
                String matterId = MatterEngagementModelDomain.getSObjectId(mem);
                if (String.isBlank(matterId) || !matterIds.contains(Id.valueOf(matterId))) continue;

                for (Id laId : laToAllAttorneysMap.keySet()) {
                    if (laToAllAttorneysMap.get(laId).contains(mem.SymphonyLF__Assign_to_User__c)) {
                        assistantMatterActiveMap.put(laId + ':' + matterId, true);
                    }
                }
        }

        
        List<SymphonyLF__Matter_Engagement_Model__c> laMEMs = [
            SELECT Id, SymphonyLF__Assign_to_User__c, Is_Active__c,
                SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c, SymphonyLF__Design_Family__c,
                SymphonyLF__Copyright__c, SymphonyLF__Design__c, SymphonyLF__Agreements_Contracts__c,
                SymphonyLF__Dispute_Opposition__c, SymphonyLF__General_Matter__c,
                SymphonyLF__Patent__c, SymphonyLF__Trademark__c
            FROM SymphonyLF__Matter_Engagement_Model__c
            WHERE SymphonyLF__Assign_to_User__c IN :legalAssistantIds
        ];

        List<SymphonyLF__Matter_Engagement_Model__c> updates = new List<SymphonyLF__Matter_Engagement_Model__c>();
        for (SymphonyLF__Matter_Engagement_Model__c laMEM : laMEMs) {
            String matterId = MatterEngagementModelDomain.getSObjectId(laMEM);
            if (String.isBlank(matterId)) continue;

            String key = laMEM.SymphonyLF__Assign_to_User__c + ':' + matterId;
            if (assistantMatterActiveMap.containsKey(key)) {
                Boolean shouldBeActive = assistantMatterActiveMap.get(key);
                if (laMEM.Is_Active__c != shouldBeActive) {
                    laMEM.Is_Active__c = shouldBeActive;
                    updates.add(laMEM);
                }
            }
        }

        if (!updates.isEmpty()) update updates;
    }




    @future
    public static void deleteAttorneyandLAfuture(Set<Id> oldList) {
        cmpRPMEMHandler.deleteAttorneyandLA(oldList);
    }



public static void deleteAttorneyandLA(Set<Id> oldLAId) {
    Set<Id> personIdsToCheck = new Set<Id>();
    Set<Id> allMatterIds = new Set<Id>();

    List<SymphonyLF__Matter_Engagement_Model__c> deletedAttorneyMems = [
        SELECT Id, SymphonyLF__Assign_to_User__c,
            SymphonyLF__Copyright__c, SymphonyLF__Design__c,
            SymphonyLF__Agreements_Contracts__c, SymphonyLF__Dispute_Opposition__c,
            SymphonyLF__General_Matter__c, SymphonyLF__Patent__c, SymphonyLF__Trademark__c,
            SymphonyLF__Design_Family__c, SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c,
            SymphonyLF__Assign_to_User__r.SymphonyLF__Type__c
        FROM SymphonyLF__Matter_Engagement_Model__c 
        WHERE IsDeleted = TRUE 
        AND SymphonyLF__Assign_to_User__r.SymphonyLF__Type__c IN ('Attorney', 'Paralegal')
        AND SymphonyLF__Assign_to_User__c != null 
        AND Id IN :oldLAId ALL ROWS
    ];

    for (SymphonyLF__Matter_Engagement_Model__c mem : deletedAttorneyMems) {
        personIdsToCheck.add(mem.SymphonyLF__Assign_to_User__c);
        allMatterIds.add(getSingleMatterId(mem));
    }

    Map<Id, Set<Id>> matterToLAIds = new Map<Id, Set<Id>>();
    List<Legal_Assistant__c> legalAssistantLinks = [
        SELECT Id, Legal_Assistant__c, Attorney_Paralegal__c 
        FROM Legal_Assistant__c 
        WHERE Attorney_Paralegal__c IN :personIdsToCheck
    ];

    Set<Id> laPersonIds = new Set<Id>();
    for (Legal_Assistant__c la : legalAssistantLinks) {
        laPersonIds.add(la.Legal_Assistant__c);
    }

    List<SymphonyLF__Matter_Engagement_Model__c> laMems = [
        SELECT Id, SymphonyLF__Assign_to_User__c, Is_Active__c,
            SymphonyLF__Copyright__c, SymphonyLF__Design__c,
            SymphonyLF__Agreements_Contracts__c, SymphonyLF__Dispute_Opposition__c,
            SymphonyLF__General_Matter__c, SymphonyLF__Patent__c, SymphonyLF__Trademark__c,
            SymphonyLF__Design_Family__c, SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c
        FROM SymphonyLF__Matter_Engagement_Model__c 
        WHERE SymphonyLF__Assign_to_User__c IN :laPersonIds AND (
            SymphonyLF__Copyright__c IN :allMatterIds OR SymphonyLF__Design__c IN :allMatterIds OR 
            SymphonyLF__Agreements_Contracts__c IN :allMatterIds OR SymphonyLF__Dispute_Opposition__c IN :allMatterIds OR 
            SymphonyLF__General_Matter__c IN :allMatterIds OR SymphonyLF__Patent__c IN :allMatterIds OR 
            SymphonyLF__Trademark__c IN :allMatterIds OR SymphonyLF__Design_Family__c IN :allMatterIds OR 
            SymphonyLF__Mark__c IN :allMatterIds OR SymphonyLF__Patent_Family__c IN :allMatterIds
        )
    ];

    List<SymphonyLF__Matter_Engagement_Model__c> remainingAttorneyMems = [
        SELECT Id, SymphonyLF__Assign_to_User__c, Is_Active__c,
            SymphonyLF__Copyright__c, SymphonyLF__Design__c,
            SymphonyLF__Agreements_Contracts__c, SymphonyLF__Dispute_Opposition__c,
            SymphonyLF__General_Matter__c, SymphonyLF__Patent__c, SymphonyLF__Trademark__c,
            SymphonyLF__Design_Family__c, SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c
        FROM SymphonyLF__Matter_Engagement_Model__c 
        WHERE IsDeleted = FALSE 
        AND SymphonyLF__Assign_to_User__r.SymphonyLF__Type__c IN ('Attorney', 'Paralegal')
        AND (
            SymphonyLF__Copyright__c IN :allMatterIds OR SymphonyLF__Design__c IN :allMatterIds OR 
            SymphonyLF__Agreements_Contracts__c IN :allMatterIds OR SymphonyLF__Dispute_Opposition__c IN :allMatterIds OR 
            SymphonyLF__General_Matter__c IN :allMatterIds OR SymphonyLF__Patent__c IN :allMatterIds OR 
            SymphonyLF__Trademark__c IN :allMatterIds OR SymphonyLF__Design_Family__c IN :allMatterIds OR 
            SymphonyLF__Mark__c IN :allMatterIds OR SymphonyLF__Patent_Family__c IN :allMatterIds
        )
    ];

    Set<Id> remainingAttorneyIds = new Set<Id>();
    for (SymphonyLF__Matter_Engagement_Model__c mem : remainingAttorneyMems) {
        remainingAttorneyIds.add(mem.SymphonyLF__Assign_to_User__c);
    }

    List<Legal_Assistant__c> remainingAttorneyLAs = [
        SELECT Id, Legal_Assistant__c, Attorney_Paralegal__c 
        FROM Legal_Assistant__c 
        WHERE Attorney_Paralegal__c IN :remainingAttorneyIds
    ];

    Map<String, Set<Id>> matterKeyToRemainingLAIds = new Map<String, Set<Id>>();
    Map<String, List<SymphonyLF__Matter_Engagement_Model__c>> matterKeyToActiveAttorneyMems = new Map<String, List<SymphonyLF__Matter_Engagement_Model__c>>();

    for (SymphonyLF__Matter_Engagement_Model__c mem : remainingAttorneyMems) {
        String key = memKeyGenerator(mem);

      
        if (mem.Is_Active__c == true) {
            if (!matterKeyToActiveAttorneyMems.containsKey(key)) {
                matterKeyToActiveAttorneyMems.put(key, new List<SymphonyLF__Matter_Engagement_Model__c>());
            }
            matterKeyToActiveAttorneyMems.get(key).add(mem);
        }

        Set<Id> lasForAttorney = new Set<Id>();
        for (Legal_Assistant__c la : remainingAttorneyLAs) {
            if (la.Attorney_Paralegal__c == mem.SymphonyLF__Assign_to_User__c) {
                lasForAttorney.add(la.Legal_Assistant__c);
            }
        }
        if (!matterKeyToRemainingLAIds.containsKey(key)) {
            matterKeyToRemainingLAIds.put(key, new Set<Id>());
        }
        matterKeyToRemainingLAIds.get(key).addAll(lasForAttorney);
    }

    List<SymphonyLF__Matter_Engagement_Model__c> laMemsToDelete = new List<SymphonyLF__Matter_Engagement_Model__c>();
    List<SymphonyLF__Matter_Engagement_Model__c> laMemsToUpdateInactive = new List<SymphonyLF__Matter_Engagement_Model__c>();

    for (SymphonyLF__Matter_Engagement_Model__c mem : laMems) {
        String key = memKeyGenerator(mem);
        Id laId = mem.SymphonyLF__Assign_to_User__c;

        if (!matterKeyToRemainingLAIds.containsKey(key) || !matterKeyToRemainingLAIds.get(key).contains(laId)) {
            laMemsToDelete.add(mem);
        } else {
            
            Boolean stillActiveSupport = false;
            if (matterKeyToActiveAttorneyMems.containsKey(key)) {
                for (SymphonyLF__Matter_Engagement_Model__c atMem : matterKeyToActiveAttorneyMems.get(key)) {
                    for (Legal_Assistant__c link : remainingAttorneyLAs) {
                        if (link.Attorney_Paralegal__c == atMem.SymphonyLF__Assign_to_User__c && 
                            link.Legal_Assistant__c == laId) {
                            stillActiveSupport = true;
                            break;
                        }
                    }
                }
            }
            if (!stillActiveSupport && mem.Is_Active__c == true) {
                mem.Is_Active__c = false;
                laMemsToUpdateInactive.add(mem);
            }
        }
    }

    if (!laMemsToDelete.isEmpty()) {
        delete laMemsToDelete;
        System.debug('Deleted LA MEMs: ' + laMemsToDelete);
    }

    if (!laMemsToUpdateInactive.isEmpty()) {
        update laMemsToUpdateInactive;
        System.debug('Updated inactive LA MEMs: ' + laMemsToUpdateInactive);
    }
}


      

    public static Id getSingleMatterId(SymphonyLF__Matter_Engagement_Model__c mem) {
    if (mem.SymphonyLF__Patent__c != null) return mem.SymphonyLF__Patent__c;
    if (mem.SymphonyLF__Design__c != null) return mem.SymphonyLF__Design__c;
    if (mem.SymphonyLF__Agreements_Contracts__c != null) return mem.SymphonyLF__Agreements_Contracts__c;
    if (mem.SymphonyLF__Dispute_Opposition__c != null) return mem.SymphonyLF__Dispute_Opposition__c;
    if (mem.SymphonyLF__General_Matter__c != null) return mem.SymphonyLF__General_Matter__c;
    if (mem.SymphonyLF__Trademark__c != null) return mem.SymphonyLF__Trademark__c;
    if (mem.SymphonyLF__Mark__c != null) return mem.SymphonyLF__Mark__c;
    if (mem.SymphonyLF__Copyright__c != null) return mem.SymphonyLF__Copyright__c;
    if (mem.SymphonyLF__Patent_Family__c != null) return mem.SymphonyLF__Patent_Family__c;
    if (mem.SymphonyLF__Design_Family__c != null) return mem.SymphonyLF__Design_Family__c;
    return null;
}

public static String memKeyGenerator(SymphonyLF__Matter_Engagement_Model__c mem) {
            
    List<String> keyParts = new List<String>();
    if (mem.SymphonyLF__Copyright__c != null) keyParts.add(mem.SymphonyLF__Copyright__c);
    if (mem.SymphonyLF__Design__c != null) keyParts.add(mem.SymphonyLF__Design__c);
    if (mem.SymphonyLF__Agreements_Contracts__c != null) keyParts.add(mem.SymphonyLF__Agreements_Contracts__c);
    if (mem.SymphonyLF__Dispute_Opposition__c != null) keyParts.add(mem.SymphonyLF__Dispute_Opposition__c);
    if (mem.SymphonyLF__General_Matter__c != null) keyParts.add(mem.SymphonyLF__General_Matter__c);
    if (mem.SymphonyLF__Patent__c != null) keyParts.add(mem.SymphonyLF__Patent__c);
    if (mem.SymphonyLF__Trademark__c != null) keyParts.add(mem.SymphonyLF__Trademark__c);
    if (mem.SymphonyLF__Design_Family__c != null) keyParts.add(mem.SymphonyLF__Design_Family__c);
    if (mem.SymphonyLF__Mark__c != null) keyParts.add(mem.SymphonyLF__Mark__c);
    if (mem.SymphonyLF__Patent_Family__c != null) keyParts.add(mem.SymphonyLF__Patent_Family__c);
    return String.join(keyParts, '-');
}

}