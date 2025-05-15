trigger ClientTriggerCustom on SymphonyLF__Client__c (before insert,before update, after insert, after update) {
    mvSObjectDomain.triggerHandler(ClientTriggerHandler.class);
}