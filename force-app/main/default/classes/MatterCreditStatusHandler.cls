public class MatterCreditStatusHandler {
    public static void handleBeforeInsert(List<SObject> newRecords, String objectType) {
        Set<Id> clientIds = new Set<Id>();

        for (SObject record : newRecords) {
            if(objectType == 'SymphonyLF__Patent__c'){
                SymphonyLF__Patent__c patentRecord = (SymphonyLF__Patent__c) record;
        
                if (patentRecord != null) {
                    patentRecord.SymphonyLF__ShowPTAFetched__c = false; 
                }
            }
            if (record.get('SymphonyLF__Client__c') != null) {
                clientIds.add((Id)record.get('SymphonyLF__Client__c'));                
            }
        }

        if (!clientIds.isEmpty()) {
            Map<Id, String> clientCreditStatusMap = new Map<Id, String>();

            for (SymphonyLF__Client__c client : [SELECT Id, Credit_Status__c FROM SymphonyLF__Client__c WHERE Id IN :clientIds]) {
                clientCreditStatusMap.put(client.Id, client.Credit_Status__c);
            }

            for (SObject record : newRecords) {
                if (clientCreditStatusMap.containsKey((Id)record.get('SymphonyLF__Client__c'))) {
                    record.put('Credit_Status__c', clientCreditStatusMap.get((Id)record.get('SymphonyLF__Client__c')));                    
                }
            }
        }
        
    }
}