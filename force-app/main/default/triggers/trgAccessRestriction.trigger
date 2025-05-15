trigger trgAccessRestriction on Access_Restriction__c (before insert,before update, after insert, after update) {
    mvSObjectDomain.triggerHandler(AccessRestrictionHandler.class);
}