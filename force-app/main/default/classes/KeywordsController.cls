public with sharing class KeywordsController {
    public static Map<String, String> objectToLookupFieldForKeyword = new Map<String, String>{
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Trademark__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Mark__c'
    };

    @AuraEnabled
    public static List<mvWrapper.Keyword> getKeywords(String objectApiName, Id recordId){

        if(! objectToLookupFieldForKeyword.containsKey(objectApiName)){
            return null;
        }

        String lookup = objectToLookupFieldForKeyword.get( objectApiName );

        Set<String> fields = new Set<String>{
            'Id',
            'SymphonyLF__Keyword__c',
            'SymphonyLF__Keyword__r.Name'
        };

        // System.debug('fields ' + fields);

        String query = ' SELECT ' + String.join( fields, ', ' ) +
            '   FROM SymphonyLF__Keyword_Association__c ' +
            '   WHERE ' + lookup + ' = :recordId AND SymphonyLF__Keyword__c != null' +
            '   ORDER BY SymphonyLF__Keyword__r.Name';

            // System.debug('query ' + query);
        SObject[] records = Database.query( query );

        // System.debug('records ' + records);

        List<mvWrapper.Keyword> kws = new List<mvWrapper.Keyword>();

        for(SObject r : records){
            mvWrapper.Keyword k = new mvWrapper.Keyword();
            k.keywordName = String.valueOf( r.getSObject('SymphonyLF__Keyword__r').get('Name') );
            k.associationId = String.valueOf( r.get('Id') );
            k.keywordId = String.valueOf( r.get('SymphonyLF__Keyword__c') );
            kws.add(k);
        }
        // System.debug('kws'+ kws);
        return kws;
    }

    @AuraEnabled
    public static List<mvWrapper.Keyword> addKeywords(List<Id> keywordIds, Id recordId, String objectApiName){
        try {
            List<sObject> associations = new List<sObject>();

            if (objectApiName == 'SymphonyLF__Patent_Family__c') {
                List<SymphonyLF__Patent__c> patents = [
                    SELECT 
                        Id 
                    FROM 
                        SymphonyLF__Patent__c 
                    WHERE 
                        SymphonyLF__Patent_Family__c = :recordId
                ];

            for (SymphonyLF__Patent__c patent : patents) {
                for (Id keywordId : keywordIds) {
                    sObject ka = (sObject) Type.forName('SymphonyLF__Keyword_Association__c').newInstance();
                    ka.put('SymphonyLF__Keyword__c', keywordId);
                    ka.put('SymphonyLF__Patent__c', patent.Id); 
                    associations.add(ka);
                }
            }
        }
        if (objectApiName == 'SymphonyLF__Mark__c') {
            List<SymphonyLF__Trademark__c> trademarks = [
                SELECT 
                    Id 
                FROM 
                SymphonyLF__Trademark__c 
                WHERE 
                SymphonyLF__Mark__c = :recordId
            ];

        for (SymphonyLF__Trademark__c trademark : trademarks) {
            for (Id keywordId : keywordIds) {
                sObject ka = (sObject) Type.forName('SymphonyLF__Keyword_Association__c').newInstance();
                ka.put('SymphonyLF__Keyword__c', keywordId);
                ka.put('SymphonyLF__Trademark__c', trademark.Id); 
                associations.add(ka);
            }
        }
    }

            for(Id i : keywordIds){
                sObject ka = (sObject) Type.forname('SymphonyLF__Keyword_Association__c').newInstance();
                ka.put('SymphonyLF__Keyword__c', i);
                ka.put( objectToLookupFieldForKeyword.get(objectApiName) , recordId);
                associations.add(ka);
            }

            if(associations.size() > 0){
                insert associations;
            }

            return getKeywords(objectApiName, recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<mvWrapper.Keyword> removeKeywordAssociations(List<Id> keywordAssociationIds, Id recordId, String objectApiName){
        try {
            List<sObject> associations = new List<sObject>();

            for(Id i : keywordAssociationIds){
                sObject ka = (sObject) Type.forname('SymphonyLF__Keyword_Association__c').newInstance();
                ka.put('Id', i);
                associations.add(ka);
            }

            if(associations.size() > 0){
                delete associations;
            }

            return getKeywords(objectApiName, recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}