/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-19-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PersonSearchController {
    public PersonSearchController() {

    }

    public static List<PersonsWrapper> reviewers = new List<PersonsWrapper>();

    private static Set<String> alreadyAddedPersonsToExclude = new Set<String>();
    private static String searchText;

    @AuraEnabled
    public static List<PersonsWrapper> searchPersons(String inputParameters){
        try {
            SearchPersonsInput input = (SearchPersonsInput) JSON.deserializeStrict(inputParameters, SearchPersonsInput.class);
            
            if(input.personRecordsInConsideration != null){
                for(String s : input.personRecordsInConsideration){
                    alreadyAddedPersonsToExclude.add(s);
                }
            }

            if(String.isNotBlank(input.searchWord)){
                searchText = '%' + String.escapeSingleQuotes(input.searchWord) + '%';
            }
            
            findPersons();
            System.debug('input.searchAcross ' + input.searchAcross);
          //  if(input.searchAcross == true){
            //    findLawFirms();
          //  }

            return reviewers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PersonsWrapper> fetchAlreadySelectedPersons(String inputParameters){
        try {
            SearchPersonsInput input = (SearchPersonsInput) JSON.deserializeStrict(inputParameters, SearchPersonsInput.class);

            if(input.personRecordsInConsideration != null){
                for(String s : input.personRecordsInConsideration){
                    alreadyAddedPersonsToExclude.add(s);
                }
            }

            fetchAlreadySelectedPersons();

            return reviewers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void findPersons(){
        for(SymphonyLF__Person__c reviewer : [SELECT Id, 
                                                        Name, 
                                                        SymphonyLF__Email__c,
                                                        // CEC_ID__c,
                                                        SymphonyLF__User__r.FullPhotoUrl,
                                                        SymphonyLF__User__r.Name
                                                    FROM SymphonyLF__Person__c 
                                                    WHERE 
                                                    (
                                                        Name LIKE :searchText 
                                                        OR SymphonyLF__Email__c LIKE :searchText
                                                    )// OR CEC_ID__c LIKE :searchText)
                                                    AND Id NOT IN :alreadyAddedPersonsToExclude AND 
                                                    (SymphonyLF__Email__c != NULL)
                                                    LIMIT 200
                                                ]
        ){
            PersonsWrapper r = new PersonsWrapper();
            r.name = reviewer.Id;
            r.label = reviewer.Name;
            r.src = reviewer.SymphonyLF__User__r.FullPhotoUrl;
            r.fallbackIconName = 'standard:user';
            r.variant = 'circle';
            r.type = 'avatar';
            //r.href = '/'+reviewer.SymphonyLF__User__c;
            //r.isLink = true;
            r.email = reviewer.SymphonyLF__Email__c;
            reviewers.add(r);
        }
    }

    /* private static void findLawFirms(){
        for(SymphonyLF__Law_Firm__c lawFirm : [SELECT Id, 
                                                        Name, 
                                                        SymphonyLF__Email__c
                                                    FROM SymphonyLF__Law_Firm__c 
                                                    WHERE 
                                                    (
                                                        Name LIKE :searchText 
                                                        OR SymphonyLF__Email__c LIKE :searchText
                                                    )
                                                    AND Id NOT IN :alreadyAddedPersonsToExclude
                                                    LIMIT 1000
                                                ]
        ){
            PersonsWrapper r = new PersonsWrapper();
            r.name = lawFirm.Id;
            r.label = lawFirm.Name + ' | ' + lawFirm.SymphonyLF__Email__c;
            r.src = '';
            r.fallbackIconName = 'utility:agent_home';
            r.variant = 'circle';
            r.type = 'avatar';
            reviewers.add(r);
        }
    } */

    /* private static void findRelatedLawFirms(){
        for(SymphonyLF__Law_Firm__c lawFirm : [SELECT Id, 
                                                        Name, 
                                                        SymphonyLF__Email__c,
                                                        Professional_Email__c
                                                    FROM SymphonyLF__Law_Firm__c 
                                                    WHERE 
                                                    (
                                                        Name LIKE :searchText 
                                                        OR SymphonyLF__Email__c LIKE :searchText
                                                        OR Professional_Email__c LIKE :searchText
                                                    )
                                                    AND Id NOT IN :alreadyAddedPersonsToExclude
                                                    LIMIT 1000
                                                ]
        ){
            PersonsWrapper r = new PersonsWrapper();
            r.name = lawFirm.Id;
            r.label = lawFirm.Name + ' | ' + lawFirm.SymphonyLF__Email__c  + ' | ' + lawFirm.Professional_Email__c ;// + ' | ' + lawFirm.CEC_ID__c;
            r.src = '';
            r.fallbackIconName = 'utility:agent_home';
            r.variant = 'circle';
            r.type = 'avatar';
            //r.href = '/'+lawFirm.SymphonyLF__User__c;
            //r.isLink = true;
            r.email = lawFirm.SymphonyLF__Email__c;
            reviewers.add(r);
        }
    } */

    private static void fetchAlreadySelectedPersons(){
        for(SymphonyLF__Person__c reviewer : [SELECT Id, 
                                                    Name, 
                                                    SymphonyLF__Email__c, 
                                                    //CEC_ID__c,
                                                    SymphonyLF__User__r.FullPhotoUrl,
                                                    SymphonyLF__User__r.Name
                                                FROM SymphonyLF__Person__c 
                                                WHERE Id IN :alreadyAddedPersonsToExclude
                                            ]
        ){
            PersonsWrapper r = new PersonsWrapper();
            r.name = reviewer.Id;
            r.label = reviewer.Name + ' | ' + reviewer.SymphonyLF__Email__c; //+ ' | ' + reviewer.CEC_ID__c;
            r.src = reviewer.SymphonyLF__User__r.FullPhotoUrl;
            r.fallbackIconName = 'standard:user';
            r.variant = 'circle';
            r.type = 'avatar';
            r.instanceType = 'personRecordId';
            //r.href = '/'+reviewer.SymphonyLF__User__c;
            //r.isLink = true;
            reviewers.add(r);
        }
    }

    public class SearchPersonsInput{
        public String searchWord;
        public Boolean searchAcross;
        public List<String> personRecordsInConsideration;
    }
    
    public class PersonsWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String src;
        @AuraEnabled
        public String fallbackIconName;
        @AuraEnabled
        public String variant;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String href;
        @AuraEnabled
        public Boolean isLink;
        @AuraEnabled 
        public String instanceType;
        @AuraEnabled 
        public String email;
    }
}