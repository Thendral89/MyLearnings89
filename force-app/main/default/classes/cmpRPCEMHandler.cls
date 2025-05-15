public with sharing class cmpRPCEMHandler {
	
	 @future
  public static void cemCreationLegalAssistantfuture(Set<Id> newList) {
     cmpRPCEMHandler.cemCreationLegalAssistant(newList);
  }
    
  

    public static void cemCreationLegalAssistant(Set<Id> newList){
        
       
       
        List<SymphonyLF__Client_Engagement_Model__c> cemToInsert = new List<SymphonyLF__Client_Engagement_Model__c>();
        List<SymphonyLF__Client_Engagement_Model__c> cemToUpdate = new List<SymphonyLF__Client_Engagement_Model__c>();
        List<SymphonyLF__Client_Engagement_Model__c> ceminScope = [Select id, SymphonyLF__Person__c,SymphonyLF__Client__c,SymphonyLF__IP_Matters__c,SymphonyLF__Applicable_to_all_jurisdiction__c,SymphonyLF__Type__c,SymphonyLF__Jurisdiction__c,Is_Active__c,Is_Default__c from SymphonyLF__Client_Engagement_Model__c where id IN :newList and (SymphonyLF__Person__r.SymphonyLF__Type__c = 'Attorney' or  SymphonyLF__Person__r.SymphonyLF__Type__c = 'Paralegal')];
		
         system.debug('ceminScope 17 ' + ceminScope);
         system.debug('ceminScope 18 ' + ceminScope.size());
       
        Set<Id> personIds = new Set<Id>();
		Set<Id> clientIds = new Set<Id>();
        
        Set<Id> newMEMIds = new Set<Id>();
        
        
        for (SymphonyLF__Client_Engagement_Model__c cem : ceminScope) {
           
        		newMEMIds.add(cem.Id);
                if (cem.SymphonyLF__Person__c != null) {
                    personIds.add(cem.SymphonyLF__Person__c);
                }
                if (cem.SymphonyLF__Client__c != null) {
                    clientIds.add(cem.SymphonyLF__Client__c);
                }
                
        }
        system.debug('personIds ' + personIds.size());
        system.debug('personIds ' + personIds);
        
        Map<Id, Set<Id>> attorneyToLegalAssistantMap = new Map<Id, Set<Id>>();
       
        Set<Id> legalAssistantsIds = new Set<Id>();
        
        
        List<Legal_Assistant__c> legalAssistants = [SELECT Id, Attorney_Paralegal__c, Legal_Assistant__c FROM Legal_Assistant__c WHERE Attorney_Paralegal__c IN :personIds AND Legal_Assistant__r.SymphonyLF__Type__c = 'Assistant'];
        for (Legal_Assistant__c la : legalAssistants) {
             system.debug('la 48 ' + la);
            if (!attorneyToLegalAssistantMap.containsKey(la.Attorney_Paralegal__c)) {
                 attorneyToLegalAssistantMap.put(la.Attorney_Paralegal__c, new Set<Id>());
          
        }
         attorneyToLegalAssistantMap.get(la.Attorney_Paralegal__c).add(la.Legal_Assistant__c);
        legalAssistantsIds.add(la.Legal_Assistant__c);
        }

        Set<Id> allLegalAssistantIds = new Set<Id>();
            for (Set<Id> las : attorneyToLegalAssistantMap.values()) {
                allLegalAssistantIds.addAll(las);
                    }
      
        
        Map<String, SymphonyLF__Client_Engagement_Model__c> existingMemMap = new Map<String, SymphonyLF__Client_Engagement_Model__c>();

        
        for (SymphonyLF__Client_Engagement_Model__c existingCemRecords : [
            SELECT Id, SymphonyLF__Client__c, Is_Active__c, SymphonyLF__IP_Matters__c, SymphonyLF__Person__c
            FROM SymphonyLF__Client_Engagement_Model__c
            WHERE SymphonyLF__Person__c IN :allLegalAssistantIds
            AND (
                SymphonyLF__Client__c IN :clientIds
            )
            AND Id NOT IN :newMEMIds
        ]) {
            
                        
            String key = existingCemRecords.SymphonyLF__Person__c + '-' + existingCemRecords.SymphonyLF__Client__c;

           
                existingMemMap.put(key, existingCemRecords);
            }

            List<String> compareLAkey = new List<String>();
           
            for (SymphonyLF__Client_Engagement_Model__c cem : ceminScope) {

                if (attorneyToLegalAssistantMap.containsKey(cem.SymphonyLF__Person__c)) {
                    Set<Id> legalAssistantIds = attorneyToLegalAssistantMap.get(cem.SymphonyLF__Person__c);
            
                    for (Id legalAssistantId : legalAssistantIds) {
                    String LAkey = legalAssistantId + '-' + cem.SymphonyLF__Client__c;            
              
             
                if (!existingMemMap.containsKey(LAkey) && !compareLAkey.contains(LAkey)) { 
                    SymphonyLF__Client_Engagement_Model__c newMem = new SymphonyLF__Client_Engagement_Model__c();
                    newMem.SymphonyLF__Person__c = legalAssistantId;
                    newMem.SymphonyLF__Type__c = 'Legal Assistant';  // Set type for new MEM record
                    newMem.SymphonyLF__IP_Matters__c = cem.SymphonyLF__IP_Matters__c;
					if(cem.SymphonyLF__Applicable_to_all_jurisdiction__c == true){
                    newMem.SymphonyLF__Applicable_to_all_jurisdiction__c = true;}
					else{
                    newMem.SymphonyLF__Jurisdiction__c = cem.SymphonyLF__Jurisdiction__c;}
					newMem.SymphonyLF__Client__c = cem.SymphonyLF__Client__c;
                    newMem.Is_Default__c = cem.Is_Default__c;
                    newMem.Is_Active__c = cem.Is_Active__c;
                 
                    cemToInsert.add(newMem);
                    compareLAkey.add(LAkey);
                }
                else if(existingMemMap.containsKey(LAkey)){
                               SymphonyLF__Client_Engagement_Model__c cemInstance = existingMemMap.get(LAkey);
                               if (cemInstance.Is_Active__c == false) {
                               cemInstance.Is_Active__c = true;

                               cemToUpdate.add(cemInstance);
                               }
                        }
            }
        }
      
        }
     if (!cemToInsert.isEmpty()) {
            insert cemToInsert;
        }
        system.debug('Final Inserted Records ' + cemToInsert.size());

        if (!cemToUpdate.isEmpty()) {
            update cemToUpdate;
        }
}

    @future
    public static void updateLegalAssistantsfuture(Set<Id> newRecords, Set<Id> oldMap) {
        cmpRPCEMHandler.updateLegalAssistants(newRecords,oldMap);
    }

public static void updateLegalAssistants(Set<Id> newRecords, Set<Id> oldPersonIds) {
    
    List<SymphonyLF__Client_Engagement_Model__c> updatedCEMs = [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c, 
               SymphonyLF__Type__c, Is_Active__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE Id IN :newRecords
          AND (SymphonyLF__Person__r.SymphonyLF__Type__c = 'Attorney' OR SymphonyLF__Person__r.SymphonyLF__Type__c = 'Paralegal')
    ];

    Set<Id> attorneyParalegalIds = new Set<Id>();
    Set<Id> clientIds = new Set<Id>();

    for (SymphonyLF__Client_Engagement_Model__c cem : updatedCEMs) {
        if (cem.SymphonyLF__Person__c != null) {
            attorneyParalegalIds.add(cem.SymphonyLF__Person__c);
        }
        if (cem.SymphonyLF__Client__c != null) {
            clientIds.add(cem.SymphonyLF__Client__c);
        }
    }

   
    List<Legal_Assistant__c> legalAssistants = [
        SELECT Id, Attorney_Paralegal__c, Legal_Assistant__c 
        FROM Legal_Assistant__c 
        WHERE Attorney_Paralegal__c IN :attorneyParalegalIds
          AND Legal_Assistant__r.SymphonyLF__Type__c = 'Assistant'
    ];

    Set<Id> legalAssistantPersonIds = new Set<Id>();
    Set<Id> allAssociatedAttorneyIds = new Set<Id>();

    
    Map<Id, Set<Id>> legalAssistantToAllAttorneyMap = new Map<Id, Set<Id>>();
    for (Legal_Assistant__c la : legalAssistants) {
        if (!legalAssistantToAllAttorneyMap.containsKey(la.Legal_Assistant__c)) {
            legalAssistantToAllAttorneyMap.put(la.Legal_Assistant__c, new Set<Id>());
        }
        legalAssistantToAllAttorneyMap.get(la.Legal_Assistant__c).add(la.Attorney_Paralegal__c);
        legalAssistantPersonIds.add(la.Legal_Assistant__c);
        allAssociatedAttorneyIds.add(la.Attorney_Paralegal__c);
    }

    
    List<Legal_Assistant__c> allLAMappings = [
        SELECT Attorney_Paralegal__c, Legal_Assistant__c
        FROM Legal_Assistant__c
        WHERE Legal_Assistant__c IN :legalAssistantPersonIds
    ];

    for (Legal_Assistant__c la : allLAMappings) {
        if (!legalAssistantToAllAttorneyMap.containsKey(la.Legal_Assistant__c)) {
            legalAssistantToAllAttorneyMap.put(la.Legal_Assistant__c, new Set<Id>());
        }
        legalAssistantToAllAttorneyMap.get(la.Legal_Assistant__c).add(la.Attorney_Paralegal__c);
        allAssociatedAttorneyIds.add(la.Attorney_Paralegal__c);
    }

    
    List<SymphonyLF__Client_Engagement_Model__c> allAttorneyCEMs = [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c, Is_Active__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE SymphonyLF__Person__c IN :allAssociatedAttorneyIds
          AND SymphonyLF__Client__c IN :clientIds
    ];

    
    Map<String, Boolean> assistantClientActiveMap = new Map<String, Boolean>();
    for (Id laId : legalAssistantPersonIds) {
        Set<Id> associatedAttorneys = legalAssistantToAllAttorneyMap.get(laId);
        for (Id clientId : clientIds) {
            Boolean hasActive = false;
            for (SymphonyLF__Client_Engagement_Model__c cem : allAttorneyCEMs) {
                if (cem.SymphonyLF__Client__c == clientId && 
                    associatedAttorneys.contains(cem.SymphonyLF__Person__c) && 
                    cem.Is_Active__c) {
                    hasActive = true;
                    break;
                }
            }
            assistantClientActiveMap.put(laId + ':' + clientId, hasActive);
        }
    } 

    
    List<SymphonyLF__Client_Engagement_Model__c> legalAssistantCEMs = [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c, Is_Active__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE SymphonyLF__Person__c IN :legalAssistantPersonIds
          AND SymphonyLF__Client__c IN :clientIds
    ];

    List<SymphonyLF__Client_Engagement_Model__c> updates = new List<SymphonyLF__Client_Engagement_Model__c>();

    for (SymphonyLF__Client_Engagement_Model__c laCEM : legalAssistantCEMs) {
        String key = laCEM.SymphonyLF__Person__c + ':' + laCEM.SymphonyLF__Client__c;
        Boolean shouldBeActive = assistantClientActiveMap.get(key);

        if (shouldBeActive != null && laCEM.Is_Active__c != shouldBeActive) {
            laCEM.Is_Active__c = shouldBeActive;
            updates.add(laCEM);
        }
    }

    if (!updates.isEmpty()) {
        update updates;
    }
}




 @future
  public static void deleteAttorneyandLAfuture(Set<Id> oldList) {
     cmpRPCEMHandler.deleteAttorneyandLA(oldList);
  }
	

    public static void deleteAttorneyandLA(Set<Id> oldRecords) {
    Set<Id> personIdsToCheck = new Set<Id>();
    Set<Id> oldMEMIds  = new Set<Id>();
    Set<Id> clientIds = new Set<Id>();
    Set<Id> oldLAId = new Set<Id>();

    List<SymphonyLF__Client_Engagement_Model__c> ceminScope = [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c, Is_Active__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE Id IN :oldRecords AND IsDeleted = TRUE ALL ROWS
    ];

    for (SymphonyLF__Client_Engagement_Model__c cem : ceminScope) {
        if (cem.SymphonyLF__Person__c != null) {
            personIdsToCheck.add(cem.SymphonyLF__Person__c);
        }
        oldMEMIds.add(cem.Id);
        if (cem.SymphonyLF__Client__c != null) {
            clientIds.add(cem.SymphonyLF__Client__c);
        }
    }

    
    List<Legal_Assistant__c> legalAssistantsToCheck = [
        SELECT Id, Legal_Assistant__c, Attorney_Paralegal__c
        FROM Legal_Assistant__c
        WHERE Attorney_Paralegal__c IN :personIdsToCheck
    ];

    for (Legal_Assistant__c la : legalAssistantsToCheck) {
        oldLAId.add(la.Legal_Assistant__c);
    }

    
    Set<Id> allParalegalInMEM = new Set<Id>();
    for (SymphonyLF__Client_Engagement_Model__c cem : [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE (SymphonyLF__Person__r.SymphonyLF__Type__c = 'Attorney' OR SymphonyLF__Person__r.SymphonyLF__Type__c = 'Paralegal')
        AND SymphonyLF__Client__c IN :clientIds
        AND Id NOT IN :oldMEMIds
    ]) {
        allParalegalInMEM.add(cem.SymphonyLF__Person__c);
    }

    
    Set<Id> existingLAID = new Set<Id>();
    List<Legal_Assistant__c> afterUpdateAttorneyLA = [
        SELECT Id, Legal_Assistant__c, Attorney_Paralegal__c
        FROM Legal_Assistant__c
        WHERE Attorney_Paralegal__c IN :allParalegalInMEM
    ];

    for (Legal_Assistant__c la : afterUpdateAttorneyLA) {
        existingLAID.add(la.Legal_Assistant__c);
    }

    
    List<SymphonyLF__Client_Engagement_Model__c> cemToDelete = new List<SymphonyLF__Client_Engagement_Model__c>();
    List<SymphonyLF__Client_Engagement_Model__c> oldAttorneyexistingMemList = [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE SymphonyLF__Person__c IN :oldLAId
        AND SymphonyLF__Client__c IN :clientIds
    ];

    for (SymphonyLF__Client_Engagement_Model__c existingMem : oldAttorneyexistingMemList) {
        Id laId = existingMem.SymphonyLF__Person__c;
        if (!existingLAID.contains(laId)) {
            cemToDelete.add(existingMem);
        }
    }

    if (!cemToDelete.isEmpty()) {
        delete cemToDelete;
    }

    
    Map<Id, List<Id>> laToClientsMap = new Map<Id, List<Id>>();
    for (SymphonyLF__Client_Engagement_Model__c cem : oldAttorneyexistingMemList) {
        if (!existingLAID.contains(cem.SymphonyLF__Person__c)) continue;
        if (!laToClientsMap.containsKey(cem.SymphonyLF__Person__c)) {
            laToClientsMap.put(cem.SymphonyLF__Person__c, new List<Id>());
        }
        laToClientsMap.get(cem.SymphonyLF__Person__c).add(cem.SymphonyLF__Client__c);
    }

    
    List<SymphonyLF__Client_Engagement_Model__c> remainingAttorneyMEMs = [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c, Is_Active__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE SymphonyLF__Client__c IN :clientIds
        AND (SymphonyLF__Person__r.SymphonyLF__Type__c = 'Attorney' OR SymphonyLF__Person__r.SymphonyLF__Type__c = 'Paralegal')
    ];

    Map<String, Boolean> clientHasActiveAttorney = new Map<String, Boolean>();
    for (SymphonyLF__Client_Engagement_Model__c mem : remainingAttorneyMEMs) {
        String key = mem.SymphonyLF__Client__c + '';
        if (mem.Is_Active__c) {
            clientHasActiveAttorney.put(key, true);
        } else if (!clientHasActiveAttorney.containsKey(key)) {
            clientHasActiveAttorney.put(key, false);
        }
    }

    
    List<SymphonyLF__Client_Engagement_Model__c> toUpdate = new List<SymphonyLF__Client_Engagement_Model__c>();
    List<SymphonyLF__Client_Engagement_Model__c> laMemsStillPresent = [
        SELECT Id, SymphonyLF__Person__c, SymphonyLF__Client__c, Is_Active__c
        FROM SymphonyLF__Client_Engagement_Model__c
        WHERE SymphonyLF__Person__c IN :existingLAID
        AND SymphonyLF__Client__c IN :clientIds
    ];

    for (SymphonyLF__Client_Engagement_Model__c laMem : laMemsStillPresent) {
        String key = laMem.SymphonyLF__Client__c + '';
        if (clientHasActiveAttorney.containsKey(key) && clientHasActiveAttorney.get(key) == false) {
            if (laMem.Is_Active__c) {
                laMem.Is_Active__c = false;
                toUpdate.add(laMem);
            }
        }
    }

    if (!toUpdate.isEmpty()) {
        update toUpdate;
    }
}

}