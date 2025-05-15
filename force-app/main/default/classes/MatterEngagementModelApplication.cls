public with sharing class MatterEngagementModelApplication {
    public MatterEngagementModelApplication() {

    }
    
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