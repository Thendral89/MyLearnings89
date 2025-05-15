trigger cmpRPLegalAssistantTrigger on Legal_Assistant__c (after delete, after insert) {

     mvSObjectDomain.triggerHandler(legalAssistantTriggerHandler.class);
}