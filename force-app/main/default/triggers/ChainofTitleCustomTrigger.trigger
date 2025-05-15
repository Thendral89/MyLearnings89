trigger ChainofTitleCustomTrigger on SymphonyLF__Chain_of_Title__c (after insert) {
	mvSObjectDomain.triggerHandler( chainofTitleTriggerHandler.class );
}