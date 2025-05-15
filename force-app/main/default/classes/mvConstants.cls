public with sharing class mvConstants {
    public final static String CLIENTDEFAULTSETTINGS = 'DEFAULTSETTING';
    public final static Boolean MASTER_CLIENT = true;
    public final static Set<String> CLIENT_CLASSIFICATION_TYPES_FOR_AUTONUMBER = new Set<String>{
        'Client'
    };

    public final static String CLIENT_OBJECT_NAME = 'SymphonyLF__Client__c';
    public final static String CLIENTENGAGEMENT_OBJECT_NAME = 'SymphonyLF__Client_Engagement_Model__c';

    public final static Set<String> fieldsClientEngagementModel = new Set<String>{
        'Id',
        'Name',
        'Is_Default__c',
        'Is_Active__c',
        'SymphonyLF__Client__c',
        'SymphonyLF__Person__c',
        'SymphonyLF__Person__r.Name',
        'SymphonyLF__Person__r.RecordType.DeveloperName',
        'SymphonyLF__Person__r.SymphonyLF__Email__c',
        'SymphonyLF__Person__r.SymphonyLF__Phone_Number__c',
        'SymphonyLF__Type__c',
        'SymphonyLF__IP_Matters__c',
        'SymphonyLF__Applicable_to_all_jurisdiction__c',
        'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Jurisdiction__r.Name',
        'CreatedDate'
    };

    public static Map<String, String> sObjectToLookupField = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'SymphonyLF__Agreements_Contracts__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Copyright__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Design__c',
        'SymphonyLF__Design_Family__c' => 'SymphonyLF__Design_Family__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__Entity__c' => 'SymphonyLF__Entity__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__General_Matter__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Mark__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Trademark__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c',
        'Wall_Of_User__c' => 'Wall_Of_User__c'
};
}