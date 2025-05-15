public with sharing class DocketActivityApplication {
    public static Map<String, String> sObjectToLookupField = new Map<String, String>{};

    public static Map<String, String> lookupToSobject = new Map<String, String>{
        'SymphonyLF__Agreement_and_Contract__c' => 'SymphonyLF__Agreement_Contract__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Copyright__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Design__c',
      //  'SymphonyLF__Design_Family__c' => 'SymphonyLF__Design_Family__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Dispute_Opposition__c',
      //  'SymphonyLF__Entity__c' => 'SymphonyLF__Entity__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__General_Matter__c',
       // 'SymphonyLF__Mark__c' => 'SymphonyLF__Mark__c',
      //  'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Trademark__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c'
    };

    static{
        for(String lookupField : lookupToSobject.keySet()){
            sObjectToLookupField.put(lookupToSobject.get(lookupField), lookupField);
        }
    }

    public static Map<String, String> assetTypeApiNameToTag = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => '',
        'SymphonyLF__Copyright__c' => 'Copyright',
        'SymphonyLF__Design__c' => 'Design',
        'SymphonyLF__Design_Family__c' => 'Design Family',
        'SymphonyLF__Dispute_Opposition__c' => 'Disputes',
        'SymphonyLF__Entity__c' => '',
        'SymphonyLF__General_Matter__c' => '',
        'SymphonyLF__Mark__c' => 'Mark',
        'SymphonyLF__Patent_Family__c' => 'Patent Family',
        'SymphonyLF__Trademark__c' => 'Trademark',
        'SymphonyLF__Patent__c' => 'Patent'
    };

    public static String lookupFieldApiName(sObject record){
        String lookupField = '';
        for(String field : lookupToSobject.keySet()){
            if(record.get(field) != null){
                lookupField = field;
                break;
            }
        }
        return lookupField;
    }

    public static Map<String, String> assetTypeApiNameToDocketNumberField = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Design_Family__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Docket_Number__c'
    };

    public static Map<String, String> assetTypeApiNameToTitleField = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'Name',
        'SymphonyLF__Copyright__c' => 'Name',
        'SymphonyLF__Design__c' => 'Name',
        'SymphonyLF__Design_Family__c' => 'Name',
        'SymphonyLF__Dispute_Opposition__c' => 'Name',
        'SymphonyLF__Entity__c' => 'Name',
        'SymphonyLF__General_Matter__c' => 'Name',
        'SymphonyLF__Mark__c' => 'Name',
        'SymphonyLF__Patent_Family__c' => 'Name',
        'SymphonyLF__Trademark__c' => 'Name',
        'SymphonyLF__Patent__c' => 'Name'
    };
}