global with sharing class cmpAPiManagObjectUtilWebservice { 
    
    @AuraEnabled
    webservice static Boolean deleteObjects(List<String> ids, String objectType) { 
        String query ='';
        query = 'SELECT Id FROM ' + objectType + ' WHERE Id IN :ids '; 
         try { 
             SObject[] objects = Database.query(query); 
             System.debug('objects.size():'+ objects.size());
             delete objects; 
             return true; 
         } catch (Exception e) { 
             return false; 
         } 
     } 
}