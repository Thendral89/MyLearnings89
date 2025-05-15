global class legalAssistantBatch implements Database.Batchable<SObject> {
    Set<Id> oldLAPersonIds;
    Set<Id> newLAPersonIds;
    Map<Id, Id> laToAttorneyMap;
  
    Integer totalInsertedRecords;
    Integer totalUpdatedRecords;

   // List<String> AttorneyList = new List<String>{'Managing Partner', 'Responsible Partner', 'Responsible Attorney', 'Working Attorney', 'Paralegal'};
    List<String> AttorneyList = new List<String>{'Attorney', 'Paralegal'};
    List<String> excludedStatus = new List<String>{'Inactive', 'Abandoned', 'Expired', 'Transferred Out', 'Closed', 'Case Transferred', 'Withdrawn', 'Terminated'};

    public legalAssistantBatch(Set<Id> oldLAPersonIds, Set<Id> newLAPersonIds, Map<Id, Id> laToAttorneyMap) {
        this.oldLAPersonIds = oldLAPersonIds;
        this.newLAPersonIds = newLAPersonIds;
        this.laToAttorneyMap = laToAttorneyMap;

        system.debug('oldLAPersonIds '+ oldLAPersonIds);
        system.debug('newLAPersonIds '+ newLAPersonIds);
        system.debug('laToAttorneyMap '+ laToAttorneyMap);

    }

    public legalAssistantBatch( Set<Id> newLAPersonIds, Map<Id, Id> laToAttorneyMap) {
        
        this.newLAPersonIds = newLAPersonIds;
        this.laToAttorneyMap = laToAttorneyMap;

        
        system.debug('newLAPersonIds '+ newLAPersonIds);
        system.debug('laToAttorneyMap '+ laToAttorneyMap);
        
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
       
        return Database.getQueryLocator([
            SELECT Id, SymphonyLF__Client__c,Is_Default__c, SymphonyLF__Person__c
            FROM SymphonyLF__Client_Engagement_Model__c
            WHERE Person_Type__c IN :AttorneyList
            AND SymphonyLF__Person__c IN :laToAttorneyMap.values()
        ]);
        
        
    }

    public void execute(Database.BatchableContext bc, List<SymphonyLF__Client_Engagement_Model__c> attorneyCEMs) {
        system.debug('attorneyCEMs 30 '+ attorneyCEMs.size());
        Set<Id> clientIds = new Set<Id>();
        for (SymphonyLF__Client_Engagement_Model__c cem : attorneyCEMs) {
            clientIds.add(cem.SymphonyLF__Client__c);
        }
        system.debug('clientIds 35 '+ clientIds.size());

        if (oldLAPersonIds != null && !oldLAPersonIds.isEmpty()) {
                List<SymphonyLF__Client_Engagement_Model__c> laCEMsToUpdate = [
                    SELECT Id, SymphonyLF__Client__c, SymphonyLF__Person__c, Is_Active__c, Is_Default__c
                    FROM SymphonyLF__Client_Engagement_Model__c
                    WHERE SymphonyLF__Type__c = 'Legal Assistant'
                    AND SymphonyLF__Client__c IN :clientIds
                    AND SymphonyLF__Person__c IN :oldLAPersonIds
                    AND Is_Active__c = true
                ];

                for (SymphonyLF__Client_Engagement_Model__c laCem : laCEMsToUpdate) {
                    laCem.Is_Active__c = false;
                }

                if (!laCEMsToUpdate.isEmpty()) {
                    system.debug('laCEMsToUpdate size 54 '+ laCEMsToUpdate.size());
                    update laCEMsToUpdate;
                    system.debug('CEMs updated '+ laCEMsToUpdate);
                    //totalRecords += laCEMsToUpdate.size();
                }
        }
        

        if (newLAPersonIds != null && !newLAPersonIds.isEmpty()) {
        Map<Id, Set<Id>> newLAClientMap = new Map<Id, Set<Id>>();
        for (Id newLA : newLAPersonIds) {
            newLAClientMap.put(newLA, new Set<Id>());
        }
        system.debug('newLAClientMap size 62 '+ newLAClientMap);


        List<SymphonyLF__Client_Engagement_Model__c> existingNewLACEMs = [
            SELECT Id, SymphonyLF__Client__c, SymphonyLF__Person__c, Is_Active__c 
            FROM SymphonyLF__Client_Engagement_Model__c
            WHERE SymphonyLF__Type__c = 'Legal Assistant'
            AND SymphonyLF__Person__c IN :newLAPersonIds
            AND SymphonyLF__Client__c IN :clientIds
        ];
        system.debug('existingNewLACEMs size 70 '+ existingNewLACEMs.size());
        system.debug('existingNewLACEMs size 70 '+ existingNewLACEMs);

        List<SymphonyLF__Client_Engagement_Model__c> newCEMsToInsert = new List<SymphonyLF__Client_Engagement_Model__c>();
        List<SymphonyLF__Client_Engagement_Model__c> existingInactiveCEMsToUpdate = new List<SymphonyLF__Client_Engagement_Model__c>();
        Set<String> compareLAkey = new Set<String>();

       
        Map<String, SymphonyLF__Client_Engagement_Model__c> existingCEMMap = new Map<String, SymphonyLF__Client_Engagement_Model__c>();
        for (SymphonyLF__Client_Engagement_Model__c cem : existingNewLACEMs) {
            String key = cem.SymphonyLF__Person__c + '_' + cem.SymphonyLF__Client__c;
            existingCEMMap.put(key, cem);
        }
        system.debug('updated existingCEMMap size 79 '+ existingCEMMap);
        
        
        
        
                for (SymphonyLF__Client_Engagement_Model__c attorneyCem : attorneyCEMs) {
                    Id clientId = attorneyCem.SymphonyLF__Client__c;

                    for (Id newLAId : newLAPersonIds) {
                        String key = newLAId + '_' + clientId;
                         system.debug('key 115'+ key);

                        if (existingCEMMap.containsKey(key)) {
                            SymphonyLF__Client_Engagement_Model__c existingCEM = existingCEMMap.get(key);
                            if (existingCEM.Is_Active__c == false) {
                                existingCEM.Is_Active__c = true;
                                existingInactiveCEMsToUpdate.add(existingCEM);
                            }
                        } else if(!compareLAkey.contains(key)){
                             system.debug('else case 124 key '+key);
                            SymphonyLF__Client_Engagement_Model__c newMem = new SymphonyLF__Client_Engagement_Model__c();
                            newMem.SymphonyLF__Person__c = newLAId;
                            newMem.SymphonyLF__Type__c = 'Legal Assistant';
                            newMem.SymphonyLF__Client__c = clientId;
                            newMem.Is_Active__c = true;
                            newMem.Is_Default__c = attorneyCem.Is_Default__c;
                            
                            newMem.SymphonyLF__Applicable_to_all_jurisdiction__c = true;
                            newCEMsToInsert.add(newMem);

                            compareLAkey.add(key);
                        }
                
                    }
                }

                if (!newCEMsToInsert.isEmpty()) {
                    system.debug('newCEMsToInsert size 100 '+ newCEMsToInsert.size());
                    system.debug('newCEMsToInsert records '+ newCEMsToInsert);
                    insert newCEMsToInsert;
                    totalInsertedRecords = newCEMsToInsert.size();
                    
                }

                if (!existingInactiveCEMsToUpdate.isEmpty()) {
                    system.debug('Reactivating existing inactive CEMs: ' + existingInactiveCEMsToUpdate.size());
                    update existingInactiveCEMsToUpdate;
                    totalUpdatedRecords = existingInactiveCEMsToUpdate.size();
                }
             }
             

           

            }




    public void finish(Database.BatchableContext bc) {
        System.debug(totalInsertedRecords + ' CEM records inserted');
        System.debug(totalUpdatedRecords + ' CEM records updated');
        System.debug(' CEM Legal Assistant Batch finished.');
    }
}