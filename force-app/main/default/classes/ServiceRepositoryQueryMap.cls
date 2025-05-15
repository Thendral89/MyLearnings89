public with sharing class ServiceRepositoryQueryMap {
    public static void createBindMap(Map<String, Object> bindMap, Id recordId, String serviceRepositoryName){
        switch on serviceRepositoryName {
            when 'patentApplicableRules' {
                patentApplicableRules(bindMap, recordId);
            }
            when 'trademarkApplicableRules'{
                trademarkApplicableRules(bindMap, recordId);
            }
            when else {
                
            }
        }
    }

    static void patentApplicableRules(Map<String, Object> bindMap, Id recordId){
        lIST<SymphonyLF__Patent__c> patent = [
            SELECT 
                Id,
                SymphonyLF__Case_Type__c,
                SymphonyLF__Country__c
            FROM SymphonyLF__Patent__c
            WHERE Id = :recordId
        ];

        bindMap.put('jurisdiction', patent[0].SymphonyLF__Country__c);
        bindMap.put('caseType', new Set<String>{patent[0].SymphonyLF__Case_Type__c} );
    }

    static void trademarkApplicableRules(Map<String, Object> bindMap, Id recordId){

        
        List<SymphonyLF__Trademark__c> trademark = [
            SELECT 
                Id,
                SymphonyLF__Case_Type__c,
                SymphonyLF__Jurisdiction__c
            FROM SymphonyLF__Trademark__c
            WHERE Id = :recordId
        ];

        bindMap.put('jurisdiction', trademark[0].SymphonyLF__Jurisdiction__c);
        bindMap.put('caseType', new Set<String>{trademark[0].SymphonyLF__Case_Type__c} );
    }
}