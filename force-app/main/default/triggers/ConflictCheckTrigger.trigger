trigger ConflictCheckTrigger on Conflict_Check__c (after insert, after update) {
    mvSObjectDomain.triggerHandler(ConflictCheckTriggerHandler.class);
}