global class MEMLegalAssistantBatch implements Database.Batchable<SObject> {
    

    Set<Id> oldLAPersonIds;
    Set<Id> newLAPersonIds;
    Map<Id, Id> laToAttorneyMap;
   
    Integer totalInsertedRecords;
    Integer totalUpdatedRecords;

    //List<String> AttorneyList = new List<String>{'Managing Partner', 'Responsible Partner', 'Responsible Attorney', 'Working Attorney', 'Paralegal'};
    List<String> AttorneyList = new List<String>{'Attorney', 'Paralegal'};
    List<String> excludedStatus = new List<String>{'Inactive', 'Abandoned', 'Expired', 'Transferred Out', 'Closed', 'Case Transferred', 'Withdrawn', 'Terminated'};

    public MEMLegalAssistantBatch(Set<Id> oldLAPersonIds, Set<Id> newLAPersonIds, Map<Id, Id> laToAttorneyMap) {
        this.oldLAPersonIds = oldLAPersonIds;
        this.newLAPersonIds = newLAPersonIds;
        this.laToAttorneyMap = laToAttorneyMap;
    }

    public MEMLegalAssistantBatch( Set<Id> newLAPersonIds, Map<Id, Id> laToAttorneyMap) {
        
        this.newLAPersonIds = newLAPersonIds;
        this.laToAttorneyMap = laToAttorneyMap;

        
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
            return Database.getQueryLocator([
                SELECT Id, SymphonyLF__Client__c, SymphonyLF__Assign_to_User__c, Matter_Status__c, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Copyright__c, SymphonyLF__Mark__c,SymphonyLF__Patent_Family__c, SymphonyLF__Design_Family__c,
                 SymphonyLF__Design__c, SymphonyLF__Agreements_Contracts__c, Is_Active__c, SymphonyLF__Dispute_Opposition__c,  SymphonyLF__General_Matter__c, SymphonyLF__Patent__c,  SymphonyLF__Trademark__c
                FROM SymphonyLF__Matter_Engagement_Model__c WHERE Person_Type__c IN :AttorneyList AND SymphonyLF__Assign_to_User__c IN :laToAttorneyMap.values()
                AND Matter_Status__c NOT IN: excludedStatus
            
        ]);
        
    }

    public void execute(Database.BatchableContext bc, List<SymphonyLF__Matter_Engagement_Model__c> attorneyCEMs) {

        Set<Id> matterIds = new Set<Id>();
        for (SymphonyLF__Matter_Engagement_Model__c mem : attorneyCEMs) {
            if (mem.SymphonyLF__Copyright__c != null) matterIds.add(mem.SymphonyLF__Copyright__c);
                if (mem.SymphonyLF__Design__c != null) matterIds.add(mem.SymphonyLF__Design__c);
                if (mem.SymphonyLF__Agreements_Contracts__c != null) matterIds.add(mem.SymphonyLF__Agreements_Contracts__c);
                if (mem.SymphonyLF__Dispute_Opposition__c != null) matterIds.add(mem.SymphonyLF__Dispute_Opposition__c);
                if (mem.SymphonyLF__General_Matter__c != null) matterIds.add(mem.SymphonyLF__General_Matter__c);
                if (mem.SymphonyLF__Patent__c != null) matterIds.add(mem.SymphonyLF__Patent__c);
                if (mem.SymphonyLF__Trademark__c != null) matterIds.add(mem.SymphonyLF__Trademark__c);
                if (mem.SymphonyLF__Design_Family__c != null) matterIds.add(mem.SymphonyLF__Design_Family__c);
                if (mem.SymphonyLF__Mark__c != null) matterIds.add(mem.SymphonyLF__Mark__c);
                if (mem.SymphonyLF__Patent_Family__c != null) matterIds.add(mem.SymphonyLF__Patent_Family__c);
           
        }

        if (oldLAPersonIds != null && !oldLAPersonIds.isEmpty()) {
            List<SymphonyLF__Matter_Engagement_Model__c> laMEMsToUpdate = [
                SELECT Id, SymphonyLF__Client__c, Is_Active__c
                FROM SymphonyLF__Matter_Engagement_Model__c
                WHERE SymphonyLF__Type__c = 'Legal Assistant'
                AND (SymphonyLF__Copyright__c IN :matterIds OR
                SymphonyLF__Design__c IN :matterIds OR
                SymphonyLF__Agreements_Contracts__c IN :matterIds OR
                SymphonyLF__Dispute_Opposition__c IN :matterIds OR
                SymphonyLF__General_Matter__c IN :matterIds OR
                SymphonyLF__Patent__c IN :matterIds OR
                SymphonyLF__Trademark__c IN :matterIds OR
                SymphonyLF__Mark__c IN :matterIds OR
                SymphonyLF__Patent_Family__c IN :matterIds OR
                SymphonyLF__Design_Family__c IN :matterIds) 
                AND SymphonyLF__Assign_to_User__c IN :oldLAPersonIds
                AND Is_Active__c = true
                AND Matter_Status__c NOT IN: excludedStatus
            ];

            for (SymphonyLF__Matter_Engagement_Model__c laMem : laMEMsToUpdate) {
                laMem.Is_Active__c = false;
            }

            if (!laMEMsToUpdate.isEmpty()) {
               
                update laMEMsToUpdate;
               
                
            }
        }

        if (newLAPersonIds != null && !newLAPersonIds.isEmpty()) {
        List<SymphonyLF__Matter_Engagement_Model__c> existingNewLAMEMs = [
                SELECT Id, SymphonyLF__Client__c, Is_Active__c, SymphonyLF__General_Matter__c, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Patent__c, SymphonyLF__Design__c, SymphonyLF__Copyright__c,  SymphonyLF__Agreements_Contracts__c, SymphonyLF__Dispute_Opposition__c,
                SymphonyLF__Trademark__c,SymphonyLF__Mark__c, SymphonyLF__Patent_Family__c, SymphonyLF__Design_Family__c, Matter_Status__c, SymphonyLF__Assign_to_User__c 
                FROM SymphonyLF__Matter_Engagement_Model__c
                WHERE SymphonyLF__Type__c = 'Legal Assistant'
                AND (SymphonyLF__Copyright__c IN :matterIds OR
                SymphonyLF__Design__c IN :matterIds OR
                SymphonyLF__Agreements_Contracts__c IN :matterIds OR
                SymphonyLF__Dispute_Opposition__c IN :matterIds OR
                SymphonyLF__General_Matter__c IN :matterIds OR
                SymphonyLF__Patent__c IN :matterIds OR
                SymphonyLF__Trademark__c IN :matterIds OR
                SymphonyLF__Mark__c IN :matterIds OR
                SymphonyLF__Patent_Family__c IN :matterIds OR
                SymphonyLF__Design_Family__c IN :matterIds) 
                AND SymphonyLF__Assign_to_User__c IN :newLAPersonIds
                AND Matter_Status__c NOT IN: excludedStatus
                 
            ];
            

            Map<String, SymphonyLF__Matter_Engagement_Model__c> existingMemMap = new Map<String, SymphonyLF__Matter_Engagement_Model__c>();
            for (SymphonyLF__Matter_Engagement_Model__c mem : existingNewLAMEMs) {
                Id matterId = cmpRPMEMHandler.getSingleMatterId(mem);
                if (matterId != null) {
                    String key = mem.SymphonyLF__Assign_to_User__c + '_' + matterId;
                    
                    existingMEMMap.put(key, mem);
                }
            }

            List<SymphonyLF__Matter_Engagement_Model__c> newMEMsToInsert = new List<SymphonyLF__Matter_Engagement_Model__c>();
            List<SymphonyLF__Matter_Engagement_Model__c> existingInactiveMEMsToUpdate = new List<SymphonyLF__Matter_Engagement_Model__c>();
            Set<String> compareLAkey = new Set<String>();
            
            
            for (SymphonyLF__Matter_Engagement_Model__c attorneyMem : attorneyCEMs) {
                Id uniqueMatterId =  cmpRPMEMHandler.getSingleMatterId(attorneyMem);
                for (Id newLAId : newLAPersonIds) {
                    String key = newLAId + '_' + uniqueMatterId;
                    if (existingMEMMap.containsKey(key)) {
                      
                        SymphonyLF__Matter_Engagement_Model__c existingMem = existingMEMMap.get(key);
                        if (existingMem.Is_Active__c == false) {
                            existingMem.Is_Active__c = true;
                            existingInactiveMEMsToUpdate.add(existingMem);
                          
                        }
                    } else if(!compareLAkey.contains(key)){
                        SymphonyLF__Matter_Engagement_Model__c newMem = new SymphonyLF__Matter_Engagement_Model__c();
                        newMem.SymphonyLF__Assign_to_User__c = newLAId;
                        newMem.SymphonyLF__Supervisor_Client_Contact__c = newLAId;
                        newMem.SymphonyLF__Type__c = 'Legal Assistant';
                        newMem.Is_Active__c = true;

                        // Map matter references from attorney MEM to the new LA MEM
                        newMem.SymphonyLF__Copyright__c = attorneyMem.SymphonyLF__Copyright__c;
                        newMem.SymphonyLF__Design__c = attorneyMem.SymphonyLF__Design__c;
                        newMem.SymphonyLF__Agreements_Contracts__c = attorneyMem.SymphonyLF__Agreements_Contracts__c;
                        newMem.SymphonyLF__Dispute_Opposition__c = attorneyMem.SymphonyLF__Dispute_Opposition__c;
                        newMem.SymphonyLF__General_Matter__c = attorneyMem.SymphonyLF__General_Matter__c;
                        newMem.SymphonyLF__Patent__c = attorneyMem.SymphonyLF__Patent__c;
                        newMem.SymphonyLF__Trademark__c = attorneyMem.SymphonyLF__Trademark__c;
                        newMem.SymphonyLF__Mark__c = attorneyMem.SymphonyLF__Mark__c;
                        newMem.SymphonyLF__Patent_Family__c = attorneyMem.SymphonyLF__Patent_Family__c;
                        newMem.SymphonyLF__Design_Family__c = attorneyMem.SymphonyLF__Design_Family__c;

                        newMEMsToInsert.add(newMem);
                        compareLAkey.add(key);
                    }
                }
            }
        

            if (!newMEMsToInsert.isEmpty()) {
                
                insert newMEMsToInsert;
                totalInsertedRecords = newMEMsToInsert.size();
            }

            if (!existingInactiveMEMsToUpdate.isEmpty()) {
               
                update existingInactiveMEMsToUpdate;
                totalUpdatedRecords = existingInactiveMEMsToUpdate.size();
            }

 }
}

    

    public void finish(Database.BatchableContext bc) {
        System.debug(totalInsertedRecords + ' MEM records inserted');
        System.debug(totalUpdatedRecords + ' MEM records updated');
        System.debug(' MEM Legal Assistant Batch finished.');
    }
}