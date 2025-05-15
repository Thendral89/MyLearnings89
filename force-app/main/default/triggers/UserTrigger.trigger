trigger UserTrigger on User (after insert, after update) {
    mvSObjectDomain.triggerHandler( UserTriggerHandler.class );
}