Public with sharing class cmpAPCommitteeMembers {
    
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String values,String FilterFieldName, String FilterFieldValue, string Role, string FilingUnderUnitaryPatent, string DoNotselectedRecords) {
        try {
            //system.debug('DoNotselectedRecords ' + DoNotselectedRecords);
            string searchqstr='[""]';
            if(DoNotselectedRecords!=null && DoNotselectedRecords!='' && DoNotselectedRecords!='null')
                searchqstr=string.valueOf(DoNotselectedRecords);
            
            searchqstr=searchqstr.replace('["', '');
            searchqstr=searchqstr.replace('"]', '');
            searchqstr=searchqstr.replace('"', '');
            //system.debug('searchqstr ' + searchqstr);
            List<String> DoNotselectedRecordsvalues = searchqstr.split(',');
            //system.debug('DoNotselectedvalues ' + DoNotselectedRecordsvalues);
            
            List<RecordsData> recordsDataList = new List<RecordsData>();
            string searchWord='';
            List<String> selectedvalues = (List<String>) JSON.deserialize(values, List<String>.class);
            List<String> committees = new List<String>();
            List<String> DuplicateName = new List<String>();
            committees.add('Reviewer');
            committees.add('PPM');
            committees.add('Chair Person');
            committees.add('Selection Users');
            
            List<String> roles = new List<String>();
            roles.add('Selection Users');
            
            String query='';
            if (objectName=='SymphonyLF__Person__c'){
                query = 'SELECT Id,Name FROM '+objectName;
            } else {
                query = 'SELECT Id, ' + filterField + ' FROM '+objectName;  
            }
            
            
            if(selectedvalues != null && selectedvalues.size() > 0) {
                query += ' WHERE Id IN: selectedvalues ';
                
            } else {
                if (objectName=='SymphonyLF__Person__c') {
                    searchWord = '%' + searchString + '%';
                    query += ' WHERE (Name LIKE :searchWord ) ';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
                }
                
            }
            query += ' ORDER BY ' + filterField + ' ASC NULLS LAST LIMIT 50 ';
            
            
            for(SObject s : Database.query(query)) {
                	string recordIdValue=(String)s.get('id');
                    if(!DoNotselectedRecordsvalues.contains(recordIdValue) && !DuplicateName.contains((String)s.get(filterField))) 
                        recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')));
                    DuplicateName.add((String)s.get(filterField));
            }
            
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    
}