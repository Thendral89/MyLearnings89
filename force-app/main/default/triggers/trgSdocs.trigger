trigger trgSdocs on SDOC__SDoc__c (after insert) {
     mvSObjectDomain.triggerHandler(sdocsTriggerHandler.class);
}