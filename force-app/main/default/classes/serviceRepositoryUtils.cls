public with sharing class serviceRepositoryUtils {
    // System.debug(serviceRepositoryUtils.fetchRecords('relatedListPersonnel',''));
	@AuraEnabled
    public static mvWrappers.serviceResponseWrapper fetchRecords(String serviceName, String recordId, String serviceRepositoryWhereClauseReplacer) { 
        mvWrappers.serviceResponseWrapper serviceResponse = new mvWrappers.serviceResponseWrapper(); 
        
      //  try {
            List<sObject> queriedRecords = new List<sObject>();
            String servLabels = '';
            String groupBy = '';
            List<String> labelList = new List<String>();
                List<Service_Repository__c> serviceRecord = getServiceRecord(serviceName);
                if (serviceRecord.isEmpty()) {
                    serviceResponse.serviceStatus = 'NO_SERVICE_RECORDS';
                    return serviceResponse;
                }
                
                String queryString = createQuery(serviceRecord[0], '', '');

                Map<String, Object> bindMap = new Map<String, Object>();
                bindMap.put('recordId', recordId);
                ServiceRepositoryQueryMap.createBindMap( bindMap, recordId, serviceName );
                
                List<sObject> recordsList = Database.queryWithBinds(queryString, bindMap, AccessLevel.USER_MODE);

                List<Id> recordIds = new List<Id>();
                for(sObject r : recordsList){
                    recordIds.add((Id) r.get('Id'));
                }
                serviceResponse.recordPermission = mvLawfirmUtilities.getRecordPermissions(recordIds);
                serviceResponse.objectPermission = mvLawfirmUtilities.getObjectPermission(serviceRecord[0].Service_Objects__c);
                if (recordsList.isEmpty()) {
                    serviceResponse.serviceStatus = 'NO_DATA_RECORDS';
                }
                
                serviceResponse.serviceOutput = recordsList;
                serviceResponse.serviceLabels = serviceRecord[0].ServiceLabels__c;
                serviceResponse.childObjectApiName = serviceRecord[0].Service_Objects__c;
                serviceResponse.lookupField = serviceRecord[0].Parent_Filter_Field__c;
                serviceResponse.childObjectLabel = ((sObject) Type.forName(serviceRecord[0].Service_Objects__c).newInstance()).getSobjectType().getDescribe().getLabel();

                if( String.isNotBlank( serviceRecord[0].Custom_Label__c ) ){
                    serviceResponse.childObjectLabel = serviceRecord[0].Custom_Label__c;
                }

                serviceResponse.actionFields = serviceRecord[0].Action_Fields__c;
                serviceResponse.recordType = serviceRecord[0].Record_Type_Developer_Name__c;
                serviceResponse.groupBy = serviceRecord[0].Group_By__c;
                serviceResponse.serviceName = serviceName;
                serviceResponse.serviceStatus = 'SUCCESS';
                serviceResponse.servicequeryString = queryString;
     /*       
        } catch (Exception e) {
            serviceResponse.serviceStatus = 'ERROR';
            serviceResponse.serviceErrorMessage = e.getMessage();
            // System.debug('Error: ' + e);
        }*/
        
        return serviceResponse;
    }
    
    private static String createQuery(Service_Repository__c serviceRepository, String serviceFilterBy, String serviceSortOrder) {
        // Trim the query to remove any extra spaces
        String query = serviceRepository.Service_Descriptor__c;
        string cleanquery = cleanQuery(query);
        // Check positions of WHERE, ORDER BY, and LIMIT clauses
        Integer wherePos = query.toLowerCase().indexOf('where');
        Integer orderByPos = query.toLowerCase().indexOf('order by');
        Integer limitPos = query.toLowerCase().indexOf('limit');
        // system.debug('values :'+wherePos+' '+orderByPos+' '+limitPos);
        // Handle WHERE clause
        if (String.isNotEmpty(serviceFilterBy)) {
            if (wherePos == -1) {
                // system.debug('where -1');
                // No WHERE clause present
                if (limitPos == -1) {
                    // No LIMIT clause present
                    if (orderByPos == -1) {
                        // No ORDER BY clause present
                        query += ' WHERE ' + serviceFilterBy;
                    } else {
                        // ORDER BY clause present
                        query = query.substring(0, orderByPos) + ' WHERE ' + serviceFilterBy + ' ' + query.substring(orderByPos);
                    }
                } else {
                    // LIMIT clause present
                    if (orderByPos == -1 || orderByPos > limitPos) {
                        // No ORDER BY clause or ORDER BY is after LIMIT
                        query = query.substring(0, limitPos) + ' WHERE ' + serviceFilterBy + ' ' + query.substring(limitPos);
                    } else {
                        // ORDER BY is before LIMIT
                        query = query.substring(0, orderByPos) + ' WHERE ' + serviceFilterBy + ' ' + query.substring(orderByPos);
                    }
                }
            } else {
                // system.debug('else where -1');
                // WHERE clause present
                if (orderByPos == -1) {
                    // No ORDER BY clause present
                    if (limitPos == -1) {
                        // No LIMIT clause present
                        // system.debug(query.substring(0, wherePos + 5));
                        // system.debug(query.substring(wherePos + 5));
                        query = query.substring(0, wherePos + 5) + ' ' + serviceFilterBy + ' AND ' + query.substring(wherePos + 5);
                    } else {
                        // LIMIT clause present
                        query = query.substring(0, wherePos + 5) + ' ' + serviceFilterBy + ' AND ' + query.substring(wherePos + 5, limitPos) + ' ' + query.substring(limitPos);
                    }
                } else {
                    // ORDER BY clause present
                    if (limitPos == -1 || limitPos > orderByPos) {
                        // No LIMIT clause or LIMIT is after ORDER BY
                        query = query.substring(0, wherePos + 5) + ' ' + serviceFilterBy + ' AND ' + query.substring(wherePos + 5, orderByPos) + ' ' + query.substring(orderByPos);
                    } else {
                        // LIMIT is before ORDER BY
                        query = query.substring(0, wherePos + 5) + ' ' + serviceFilterBy + ' AND ' + query.substring(wherePos + 5, limitPos) + ' ' + query.substring(limitPos);
                    }
                }
            }
        }
        return query;
    }
    
    private static List<Service_Repository__c> getServiceRecord(String serviceName){
        return [SELECT Id
                , Action_Fields__c
                , Parent_Filter_Field__c
                , Service_Objects__c
                , Service_Name__c
                , Enabled__c
                , Service_Request_Type__c
                , Service_Descriptor__c
                , ServiceLabels__c
                , Group_By__c
                , Record_Type_Developer_Name__c
                , Custom_Label__c
                FROM Service_Repository__c
                WHERE Service_Name__c =:serviceName 
                AND Enabled__c = true
               ];
    }
    
    private static String cleanQuery(String query) {
        if (query == null) {
            return '';
        }
        // Remove line breaks and trim extra spaces
        return query.replaceAll('\r?\n|\r', ' ').trim();
    } 
}