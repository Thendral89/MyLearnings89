public with sharing class assetIntakeFormController {
    @AuraEnabled(cacheable=true)
    public static List<SymphonyLF__Patent_Family__c> searchPatentFamilyRecords(String clientId, String searchTerm) {
        if (String.isBlank(clientId)) {
            return new List<SymphonyLF__Patent_Family__c>();
        }

        String queryTerm = '%' + searchTerm + '%';
        return [
            SELECT Id,
                   Name,
                   SymphonyLF__Invention_Title__c,
                   SymphonyLF__Earliest_Priority_Date__c,
                   SymphonyLF__Extended_Family__c,
                   SymphonyLF__Invention_Date__c,
                   SymphonyLF__Docket_Number__c,
                   SymphonyLF__Family_Status__c,
                   SymphonyLF__Short_Title_Hyperlink__c,
                   SymphonyLF__Family_ID__c
            FROM SymphonyLF__Patent_Family__c
            WHERE SymphonyLF__Client__c = :clientId
            AND (
                Name LIKE :queryTerm
                OR SymphonyLF__Invention_Title__c LIKE :queryTerm
            )
            AND SymphonyLF__Family_Status__c != 'Draft'
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<SymphonyLF__Patent_Family__c> getDraftPatentFamilyRecords(String clientId) {
        if (String.isBlank(clientId)) {
            return new List<SymphonyLF__Patent_Family__c>();
        }
        
        Map<String, Schema.FieldSet> fsetMap = SymphonyLF__Patent_Family__c.SObjectType.getDescribe().fieldSets.getMap();
        String fieldSetName = 'Related_List';
        if (!fsetMap.containsKey(fieldSetName)) {
            throw new AuraHandledException('Field set not found: ' + fieldSetName);
        }
        
        Schema.FieldSet fset = fsetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fsetMembers = fset.getFields();
        
        // Start with 'Id' and add all fields from the field set
        List<String> fieldAPINames = new List<String>{'Id'};
        for (Schema.FieldSetMember fsm : fsetMembers) {
            fieldAPINames.add(fsm.getFieldPath());
        }
        
        // Build and execute the dynamic SOQL query
        String query = 'SELECT ' + String.join(fieldAPINames, ',') +
                       ' FROM SymphonyLF__Patent_Family__c ' +
                       ' WHERE SymphonyLF__Client__c = :clientId ' +
                       ' AND SymphonyLF__Family_Status__c = \'Draft\' ' +
                       ' ORDER BY CreatedDate DESC';
        
        List<SymphonyLF__Patent_Family__c> records = Database.query(query);
        return records;
    }
    

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getFieldSetColumns(String sObjectName) {
        List<Map<String, String>> columns = new List<Map<String, String>>();
        
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if (!globalDescribe.containsKey(sObjectName)) {
            throw new AuraHandledException('Invalid SObject: ' + sObjectName);
        }
        
        Schema.SObjectType sobjectType = globalDescribe.get(sObjectName);
        Schema.DescribeSObjectResult dsr = sobjectType.getDescribe();
        
        Map<String, Schema.FieldSet> fieldSetMap = dsr.fieldSets.getMap();
        String fieldSetName = 'Related_List';
        if (!fieldSetMap.containsKey(fieldSetName)) {
            throw new AuraHandledException('Field set not found: ' + fieldSetName);
        }
        
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fsetMembers = fieldSet.getFields();
        
        for (Schema.FieldSetMember fsm : fsetMembers) {
            Map<String, String> col = new Map<String, String>();
            col.put('fieldName', fsm.getFieldPath());
            col.put('label', fsm.getLabel());
            columns.add(col);
        }
        
        return columns;
    }
    


}