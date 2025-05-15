trigger MarkTrigger on SymphonyLF__Mark__c (after insert) {
	mvSObjectDomain.triggerHandler( MarkTriggerHandler.class );
}