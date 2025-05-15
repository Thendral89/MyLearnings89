trigger PatentFamilyTrigger on SymphonyLF__Patent_Family__c (after insert) {
    mvSObjectDomain.triggerHandler( PatentFamilyTriggerHandler.class );
}