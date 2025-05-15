trigger trgChecklist on Checklist__c (after insert) {

     mvSObjectDomain.triggerHandler(checklistTriggerHandler.class);
}