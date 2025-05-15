public without sharing class DynamicSearchRecords {
    @AuraEnabled(cacheable=false)
    public static List<SObject> DynamicSearchRecords(String ObjectName, List<String> SearchFieldNameList, string FieldsToFetch, string str, List<String> selectedRecId, String additionalCond, String orderBy, Integer numOfRecs, Boolean hasEncryptedFieldSearch, String returnUniqueValueFor) {
       return getRecords(ObjectName,SearchFieldNameList,FieldsToFetch,str,selectedRecId,additionalCond,orderBy,numOfRecs, hasEncryptedFieldSearch, returnUniqueValueFor);
    }
     @AuraEnabled
    public static List<SObject> RetrieveSearchRecords(String ObjectName, List<String> SearchFieldNameList, string FieldsToFetch, string str, List<String> selectedRecId, String additionalCond, String orderBy, Integer numOfRecs, Boolean hasEncryptedFieldSearch, String returnUniqueValueFor) {
       return getRecords(ObjectName,SearchFieldNameList,FieldsToFetch,str,selectedRecId,additionalCond,orderBy,numOfRecs, hasEncryptedFieldSearch, returnUniqueValueFor);
    }
    @AuraEnabled(cacheable=true)
    public static List<SObject> DynamicQueryRecords(String query){
        // System.debug('Js Query: '+query);
        List<SObject> recList = Database.Query(query);
        return recList;
    }
    @AuraEnabled
    public static List<SObject> RetrieveQueryRecords(String query){
        List<SObject> recList = Database.Query(query);
        return recList;
    }
    public static List<SObject> getRecords(String ObjectName, List<String> SearchFieldNameList, string FieldsToFetch, string str, List<String> selectedRecId, String additionalCond, String orderBy, Integer numOfRecs, Boolean hasEncryptedFieldSearch, String returnUniqueValueFor)
    {
        if (hasEncryptedFieldSearch == null) {
            hasEncryptedFieldSearch = false;
        }
        String searchStr = str.trim();
        List<SObject> recList = new List<SObject>();
        if(selectedRecId == null){
            selectedRecId = new List<String>();
        }
        if (String.isNotBlank(additionalCond)) {            
           // additionalCond = '( ' + additionalCond  + ' ) and ';
            additionalCond =  additionalCond  + ' and ';
        }else{
            additionalCond='';
        }
        // System.debug(additionalCond);
        String whereCond = additionalCond +'ID NOT IN :selectedRecId';
        String orderByCond='',queryLimit='';
        if (String.isNotBlank(orderBy)) {
            orderByCond += ' ORDER BY ' + orderBy;
        }
        if (numOfRecs != null) {
            queryLimit += ' LIMIT :numOfRecs';
        }
        if (hasEncryptedFieldSearch) {
            if (searchStr.length() > 1) {
                String soslQuery = 'FIND \''+String.escapeSingleQuotes(searchStr)+'*\' RETURNING '+ObjectName+'('+FieldsToFetch +' WHERE '+ whereCond + orderByCond + queryLimit +')';
                // System.debug('SOSL_Query: '+soslQuery);
                List<List<SObject>> soslRes = search.query(soslQuery);
                if (soslRes.size() > 0) {
                    recList = soslRes[0];
                }
            }
            /* else {
                String soqlQuery = 'Select '+ FieldsToFetch +' from '+ ObjectName +' where '+ whereCond;
                // System.debug('SOQL_Query: '+soqlQuery);
                recList = Database.Query(soqlQuery);
            } */
        } else {
            String searchCond = '';
            if(String.isNotEmpty(searchStr)){
                for (String fName : SearchFieldNameList) {
                    if (searchCond == '') {
                        searchCond = fName + ' LIKE \'%' + String.escapeSingleQuotes(searchStr) + '%\' ';
                    } else {
                        searchCond += 'or ' + fName + ' LIKE \'%' + String.escapeSingleQuotes(searchStr) + '%\' ';
                    }
                }
                searchCond = '( '+ searchCond + ') and ';
            }
            String soqlQuery = 'Select '+ FieldsToFetch +' from '+ ObjectName +' where '+ searchCond + whereCond + orderByCond + queryLimit;
            // System.debug('SOQL_Query: '+soqlQuery);
            recList = Database.Query(soqlQuery);
        }
        if (String.isNotBlank(returnUniqueValueFor)) {
            Map<String, SObject> returnMap = new Map<String, SObject>();
            for (SObject sobj : recList) {
                returnMap.put((String)sobj.get(returnUniqueValueFor), sobj);
            }
            recList = returnMap.values();
        }
        // system.debug(recList);
        // system.debug(recList.size());
        return recList;
    }
}