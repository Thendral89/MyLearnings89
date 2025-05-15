public with sharing class lwcMultiLookupController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, List<String> selectedRecId, Boolean isKeywordHierarchy, String currentRecordId) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        system.debug(fieldName+'-------------'+ObjectName+'---++----------'+value+'====='+selectedRecId);
        if(selectedRecId == null)
            selectedRecId = new List<String>();
        
        if(String.isNotEmpty(value)) {
            String query = '';
            if(String.isBlank(value))
            {
                query = 'Select Id,SymphonyLF__Contact_Type__c,SymphonyLF__Email__c,'+fieldName+' FROM '+ObjectName+' WHERE ID IN: selectedRecId limit 50';
                system.debug('++++++rrr');
            }
            else
            {
                if(isKeywordHierarchy) {
                    //Set<Id> allIds = KeywordHierarchyCtrl.fetchHierarchyRecordsHandler(currentRecordId);
                    //Set<Id> allIds = allKeywordId(currentRecordId);
                    query = 'Select Id,SymphonyLF__Contact_Type__c,SymphonyLF__Email__c,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId AND Id IN: allIds limit 50';
                } else {
                    query = 'Select Id,SymphonyLF__Contact_Type__c,SymphonyLF__Email__c,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId limit 50';
                }
            }
            
            system.debug(query);
            for(sObject so : Database.Query(query)) {
                String fieldvalue = (String)so.get(fieldName);
                string email = (String)so.get('SymphonyLF__Email__c');
                string con = (String)so.get('SymphonyLF__Contact_Type__c');
                sObjectResultList.add(new SObjectResult(fieldvalue,email,con, so.Id));
            }
        }
        else
        {
             String query = '';
           if(selectedRecId.size() > 0)
           {
                query = 'Select Id,SymphonyLF__Contact_Type__c,SymphonyLF__Email__c,'+fieldName+' FROM '+ObjectName+' WHERE ID IN: selectedRecId ';
                system.debug('++++++rrr');
               
    
            system.debug(query);
            for(sObject so : Database.Query(query)) {
                String fieldvalue = (String)so.get(fieldName);
                string email = (String)so.get('SymphonyLF__Email__c');
                string con = (String)so.get('SymphonyLF__Contact_Type__c');
                sObjectResultList.add(new SObjectResult(fieldvalue,email,con, so.Id));
            }
           }
            
        }
        system.debug('++++++'+sObjectResultList);
        return sObjectResultList;
    }
    
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public String recEmail;
        @AuraEnabled
        public String recConType;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp,string email,string contype, Id recIdTemp) {
            recName = recNameTemp;
            recEmail = email;
            recConType = contype;
            recId = recIdTemp;
        }
        public SObJectResult() {
            
        }
    }
}