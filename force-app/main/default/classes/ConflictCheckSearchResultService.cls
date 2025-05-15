public with sharing class ConflictCheckSearchResultService {
    final static String DELIMITER = ',';

    final static String CONFLICT_CHECK_FORM_FIELD_CLIENT_NAME = 'clientName';
    final static String CONFLICT_CHECK_FORM_FIELD_ADVERSE_PARTIES = 'adverseParties';
    final static String CONFLICT_CHECK_FORM_FIELD_RELATED_PARTIES_OTHER_THAN_CLIENT = 'relatedPartiesOtherThanClient';
    final static String CONFLICT_CHECK_FORM_FIELD_CONTRIBUTORS = 'contributors';
    final static String CONFLICT_CHECK_FORM_FIELD_KEYWORDS = 'keywords';

    final static String SOBJECT_CLIENT = 'SymphonyLF__Client__c';
    final static String SOBJECT_CHAIN_OF_TITLE = 'SymphonyLF__Chain_of_Title__c';
    final static String SOBJECT_ENTITY = 'SymphonyLF__Entity__c';
    final static String SOBJECT_INVENTOR_DESIGNER_AUTHOR = 'SymphonyLF__Inventor_Designer_Author__c';
    final static String SOBJECT_KEYWORD_ASSOCIATION = 'SymphonyLF__Keyword_Association__c';
    final static String SOBJECT_PATENT = 'SymphonyLF__Patent__c';
    final static String SOBJECT_TRADEMARK = 'SymphonyLF__Trademark__c';
    final static String SOBJECT_COPYRIGHT = 'SymphonyLF__Copyright__c';
    final static String SOBJECT_DESIGN_FAMILY = 'SymphonyLF__Design_Family__c';
    final static String SOBJECT_DISPUTE_OPPOSITION = 'SymphonyLF__Dispute_Opposition__c';
    final static String SOBJECT_GENERAL_MATTER = 'SymphonyLF__General_Matter__c';
    final static String SOBJECT_MARK = 'SymphonyLF__Mark__c';
    final static String SOBJECT_PATENT_FAMILY = 'SymphonyLF__Patent_Family__c';
    final static String SOBJECT_DESIGN = 'SymphonyLF__Design__c';
    final static String SOBJECT_AGREEMENT_CONTRACT = 'SymphonyLF__Agreement_Contract__c';

    final static Set<String> CLIENT_STATUS_NOT_TO_INCLUDE = new Set<String>{'Yet to Engage'};

    static Map<String, Map<String, List<String>>> formFieldBySearchObjectFieldBySearchObject = new Map<String, Map<String, List<String>>>{
        SOBJECT_CLIENT => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_CLIENT_NAME,
                CONFLICT_CHECK_FORM_FIELD_ADVERSE_PARTIES,
                CONFLICT_CHECK_FORM_FIELD_RELATED_PARTIES_OTHER_THAN_CLIENT,
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_CHAIN_OF_TITLE => new Map<String, List<String>>{
            'SymphonyLF__Client__r.Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_CLIENT_NAME,
                CONFLICT_CHECK_FORM_FIELD_ADVERSE_PARTIES,
                CONFLICT_CHECK_FORM_FIELD_RELATED_PARTIES_OTHER_THAN_CLIENT
            }
        },
        SOBJECT_ENTITY => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_ADVERSE_PARTIES,
                CONFLICT_CHECK_FORM_FIELD_RELATED_PARTIES_OTHER_THAN_CLIENT
            }
        },
        SOBJECT_INVENTOR_DESIGNER_AUTHOR => new Map<String, List<String>>{
            'SymphonyLF__Contact__r.Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_CONTRIBUTORS,
                CONFLICT_CHECK_FORM_FIELD_ADVERSE_PARTIES,
                CONFLICT_CHECK_FORM_FIELD_RELATED_PARTIES_OTHER_THAN_CLIENT
            }
        },
        SOBJECT_KEYWORD_ASSOCIATION => new Map<String, List<String>>{
            'SymphonyLF__Keyword__r.Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_PATENT => new Map<String, List<String>>{
            'SymphonyLF__Title__c' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_TRADEMARK => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_COPYRIGHT => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_DESIGN_FAMILY => new Map<String, List<String>>{
            'Title__c' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_DISPUTE_OPPOSITION => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_GENERAL_MATTER => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_MARK => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_PATENT_FAMILY => new Map<String, List<String>>{
            'SymphonyLF__Invention_Title__c' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_DESIGN => new Map<String, List<String>>{
            'Title__c' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        },
        SOBJECT_AGREEMENT_CONTRACT => new Map<String, List<String>>{
            'Name' => new List<String>{
                CONFLICT_CHECK_FORM_FIELD_KEYWORDS
            }
        }
    };

    static Map<String, List<String>> clientLookupByObject = new Map<String, List<String>>{
        SOBJECT_CLIENT => new List<String>{},
        SOBJECT_CHAIN_OF_TITLE => new List<String>{
            'SymphonyLF__Client__c'
            ,'Assignor__c'
        },
        SOBJECT_ENTITY => new List<String>{
            'SymphonyLF__Primary_Contact__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Secondary_Contact__r.SymphonyLF__Client__c'
        },
        SOBJECT_INVENTOR_DESIGNER_AUTHOR => new List<String>{
            'SymphonyLF__Contact__r.SymphonyLF__Client__c'
        },
        SOBJECT_KEYWORD_ASSOCIATION => new List<String>{
            'SymphonyLF__Agreement_Contract__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Copyright__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Design_Family__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Design__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Dispute_Opposition__r.SymphonyLF__Client__c'
            ,'SymphonyLF__General_Matter__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Mark__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Patent_Family__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Patent__r.SymphonyLF__Client__c'
            ,'SymphonyLF__Trademark__r.SymphonyLF__Client__c'
        },
        SOBJECT_PATENT => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_TRADEMARK => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_COPYRIGHT => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_DESIGN_FAMILY => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_DISPUTE_OPPOSITION => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_GENERAL_MATTER => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_MARK => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_PATENT_FAMILY => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_DESIGN => new List<String>{
            'SymphonyLF__Client__c'
        },
        SOBJECT_AGREEMENT_CONTRACT => new List<String>{
            'SymphonyLF__Client__c'
        }
    };

    static Map<String, String> conflictCheckSearchResultLookupBySobjectType = new Map<String, String>{
        SOBJECT_CLIENT => 'Client__c',
        SOBJECT_CHAIN_OF_TITLE => 'Chain_of_Title__c',
        SOBJECT_ENTITY => 'Entity__c',
        SOBJECT_INVENTOR_DESIGNER_AUTHOR => 'Inventor_Designer_Author__c',
        SOBJECT_KEYWORD_ASSOCIATION => 'Keyword_Association__c',
        SOBJECT_PATENT => 'Patent__c',
        SOBJECT_TRADEMARK => 'Trademark__c',
        SOBJECT_COPYRIGHT => 'Copyright__c',
        SOBJECT_DESIGN_FAMILY => 'Design_Family__c',
        SOBJECT_DISPUTE_OPPOSITION => 'Dispute_Opposition__c',
        SOBJECT_GENERAL_MATTER => 'General_Matter__c',
        SOBJECT_MARK => 'Mark__c',
        SOBJECT_PATENT_FAMILY => 'Patent_Family__c',
        SOBJECT_DESIGN => 'Design__c',
        SOBJECT_AGREEMENT_CONTRACT => 'Agreement_and_Contract__c'
    };

    static Set<String> matterLookupFieldsOnKeyword = new Set<String>{
        'SymphonyLF__Agreement_Contract__c',
        'SymphonyLF__Copyright__c',
        'SymphonyLF__Design__c',
        'SymphonyLF__Design_Family__c',
        'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__General_Matter__c',
        'SymphonyLF__Patent__c',
        'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Trademark__c'
    };

    public enum OperationType {
        DELETE_AND_SEARCH,
        SEARCH,
        DELETE_PREVIOUS
    }

    OperationType operationType;

    Map<String, Set<String>> searchValuesByFieldInConflictCheck = new Map<String, Set<String>>();

    Conflict_Check__c conflictCheck;

    Map<String, Object> bindMap = new Map<String, Object>();
    Integer bindMapIndex = 1;

    List<sObject> conflictCheckSearchResults = new List<sObject>();

    public void setOperationType(OperationType operationType){
        this.operationType = operationType;
    }

    public void setConflictCheck(Conflict_Check__c conflictCheck){
        this.conflictCheck = conflictCheck;

        this.setAdverseParties(conflictCheck.Adverse_Parties__c);
        this.setRelatedPartiesOtherThanClient(conflictCheck.Related_Parties_other_than_client__c);
        this.setContributors(conflictCheck.Contributor__c);
        this.setKeywords(conflictCheck.Keywords__c);

        if(conflictCheck.Client_Name__c != null){
            Id clientId = conflictCheck.Client_Name__c;
            System.debug('BB clientId ' + clientId);
            String clientName = [SELECT Id, Name FROM SymphonyLF__Client__c WHERE Id = :clientId][0].Name;
            this.setClientName(clientName);
        }
    }

    void setAdverseParties(String adverseParties){
        searchValuesByFieldInConflictCheck.put(CONFLICT_CHECK_FORM_FIELD_ADVERSE_PARTIES , cleanLike(adverseParties) );
    }

    void setRelatedPartiesOtherThanClient(String relatedPartiesOtherThanClient){
        searchValuesByFieldInConflictCheck.put(CONFLICT_CHECK_FORM_FIELD_RELATED_PARTIES_OTHER_THAN_CLIENT , cleanLike(relatedPartiesOtherThanClient) );
    }

    void setContributors(String contributors){
        searchValuesByFieldInConflictCheck.put(CONFLICT_CHECK_FORM_FIELD_CONTRIBUTORS , cleanLike(contributors) );
    }

    void setKeywords(String keywords){
        searchValuesByFieldInConflictCheck.put(CONFLICT_CHECK_FORM_FIELD_KEYWORDS , cleanLike(keywords) );
    }

    void setClientName(String clientName){
        searchValuesByFieldInConflictCheck.put(CONFLICT_CHECK_FORM_FIELD_CLIENT_NAME , cleanLike(clientName) );
    }

    public void execute(){
        if(this.operationType == null){
            throw new OperationTypeCannotBeBlankException();
        }

        if(this.operationType == ConflictCheckSearchResultService.OperationType.DELETE_AND_SEARCH){
            handleOldSearchResultsDelete();
            handleNewSearchResult();
        }
        else if(this.operationType == ConflictCheckSearchResultService.OperationType.DELETE_PREVIOUS){
            handleOldSearchResultsDelete();
        }
        else if(this.operationType == ConflictCheckSearchResultService.OperationType.SEARCH){
            handleNewSearchResult();
        }
    }

    void handleOldSearchResultsDelete(){
        fetchExistingSearchResultsToDelete();
        
        if(conflictCheckSearchResults.size() > 0){
            delete conflictCheckSearchResults;
            conflictCheckSearchResults.clear();
        }
    }

    void handleNewSearchResult(){
        for(String sObjectToSearch : formFieldBySearchObjectFieldBySearchObject.keySet()){
            searchAndAdd(sObjectToSearch);
        }

        if(conflictCheckSearchResults.size() > 0 ){
            System.debug('size ---- ' + conflictCheckSearchResults.size());
            if(conflictCheckSearchResults.size() > 10000){
                String serializedConflictCheckSearchResults = JSON.serialize(conflictCheckSearchResults);
                processCCSResults(serializedConflictCheckSearchResults);
            }else{
                insert conflictCheckSearchResults;
            }
            
            conflictCheckSearchResults.clear();
        }
    }

     @future
    public static void processCCSResults(String serializedObjects) {
        List<Conflict_Check_Search_Result__c> conflictCheckSearchResultList = (List<Conflict_Check_Search_Result__c>)JSON.deserialize(serializedObjects, List<Conflict_Check_Search_Result__c>.class);

        INSERT conflictCheckSearchResultList;
    }

    void fetchExistingSearchResultsToDelete(){
        system.debug('cconflictCheck :'+this.conflictCheck);
        Id conflictCheckId = (conflictCheck != null ) ? conflictCheck.Id : null;
        String searchResultQuery = ' SELECT Id FROM Conflict_Check_Search_Result__c WHERE Conflict_Check__c = :conflictCheckId ';
        List<String> whereIn = new List<String>();

        for(String sObjectSearchResultToDelete : formFieldBySearchObjectFieldBySearchObject.keySet()){
            String lookupField = conflictCheckSearchResultLookupBySobjectType.get( sObjectSearchResultToDelete );
            String querySingle = lookupField + ' != NULL';
            whereIn.add( querySingle );
        }

        if(whereIn.size() > 0){
            searchResultQuery += ' AND ' + ' ( ' + String.join(whereIn, ' OR ') + ' ) ';
        }

        this.conflictCheckSearchResults = Database.query(searchResultQuery);
    }

    void searchAndAdd(String searchObject){
        List<sObject> matches = searchIn( searchObject );

        if(matches == null || matches.size() == 0){
            return;
        }

        prepareToAdd(searchObject, matches);
    }

    void prepareToAdd(String searchObject, List<sObject> results){
        String lookupField = conflictCheckSearchResultLookupBySobjectType.get( searchObject );

        for(sObject rec : results){
            Conflict_Check_Search_Result__c toInsert = new Conflict_Check_Search_Result__c();
            toInsert.put('Conflict_Check__c' , conflictCheck.Id);
            toInsert.put(lookupField , rec.get('Id'));
            toInsert.put('LookupFieldToSobject__c', lookupField);

            this.conflictCheckSearchResults.add(toInsert);
        }
    }

    List<sObject> searchIn(String searchObject){
        List<String> whereIn = prepareWhereIn(searchObject);
        if( whereIn == null || whereIn.size() == 0 ){
            return null;
        }

        String query = '  SELECT Id ' +
                        ' FROM ' + searchObject +
                        ' WHERE ';

        query += ' ( ' + String.join(whereIn, ' OR ') + ' ) ';

        List<String> whereNotIn = prepareWhereNotIn(searchObject);

        if(whereNotIn.size() > 0){
            query += ' AND ' + ' ( ' + String.join(whereNotIn, ' AND ') + ' ) ';
        }
        System.debug('QQQ ' + query);
        List<sObject> result = Database.queryWithBinds(
            query,
            this.bindMap,
            AccessLevel.SYSTEM_MODE
        );

        this.bindMap.clear();

        return result;
    }

    List<String> prepareWhereNotIn(String searchObject){
        List<String> output = new List<String>();

        if(searchObject == SOBJECT_CLIENT){
            {
                String bindMapName = 'WIS' + bindMapIndex + 'WIE';
                bindMapIndex++;
                

                Id conflictCheckId = this.conflictCheck.Id;

                bindMap.put( bindMapName, conflictCheckId);

                String whereNotSingle = ' Id != :' + bindMapName;
                output.add(whereNotSingle);
            }

            {
                String bindMapName = 'WIS' + bindMapIndex + 'WIE';
                bindMapIndex++;

                bindMap.put( bindMapName, CLIENT_STATUS_NOT_TO_INCLUDE);

                String whereNotSingle = ' Client_Status__c NOT IN :' + bindMapName;
                output.add(whereNotSingle);
            }
        }
        else if(searchObject == SOBJECT_KEYWORD_ASSOCIATION){
            {
                List<String> whereNotInSingle = new List<String>();
                for(String lookupField : matterLookupFieldsOnKeyword){
                    whereNotInSingle.add( lookupField + ' != NULL ');
                }
                output.add( ' ( ' + String.join(whereNotInSingle, ' OR ') + ' ) ' );
            }
        }

        prepareWhereNotInForConflictCheckClient(output, searchObject);

        return output;
    }

    void prepareWhereNotInForConflictCheckClient(List<String> output ,String searchObject){
        if(clientLookupByObject.containsKey(searchObject) && clientLookupByObject.get( searchObject ).size() > 0 ){
            String bindMapName = 'WIS' + bindMapIndex + 'WIE';
            bindMapIndex++;
            
    
            Id conflictCheckId = this.conflictCheck.Id;
    
            bindMap.put( bindMapName, conflictCheckId);
    
            List<String> whereNotMultiple = new List<String>{};
            
            for(String field : clientLookupByObject.get( searchObject )){
                whereNotMultiple.add( field + ' != :' + bindMapName );
            }

            output.add( ' ( ' + String.join(whereNotMultiple, ' AND ') + ' ) ' );
        }
    }

    List<String> prepareWhereIn(String searchObject){
        List<String> whereIn = new List<String>();

        Map<String, List<String>> formFieldBySearchObjectField = formFieldBySearchObjectFieldBySearchObject.get(searchObject);

        if(formFieldBySearchObjectField == null || formFieldBySearchObjectField.size() == 0){
            return null;
        }

        Set<String> searchObjectFields = formFieldBySearchObjectField.keySet();

        for(String field : searchObjectFields){
            List<String> formFields = formFieldBySearchObjectField.get( field );

            Set<String> searchValues = new Set<String>();

            for(String formField : formFields){
                Set<String> searchValuesSingle = searchValuesByFieldInConflictCheck.get( formField );

                if(searchValuesSingle == null || searchValuesSingle.size() == 0){
                    continue;
                }

                searchValues.addAll(searchValuesSingle);
            }

            if(searchValues.size() == 0){
                continue;
            }
            
            String bindMapName = 'WIS' + bindMapIndex + 'WIE';
            bindMapIndex++;
            bindMap.put( bindMapName, searchValues);

            String whereInSingle = ' ' + field + ' LIKE ' + ' :' + bindMapName;
            whereIn.add( whereInSingle );
        }

        return whereIn;
    }

    static Set<String> cleanLike(String input){
        Set<String> output = new Set<String>();

        if(
            String.isNotBlank(input) 
            && 
            ( !input.equalsIgnoreCase('NULL') )
        ){
            List<String> smallOutput = input.split( DELIMITER );
            for(String s : smallOutput){
                output.add( '%' + s + '%' );
            }
        }

        return output;
    } 

    public class OperationTypeCannotBeBlankException extends Exception{}
}