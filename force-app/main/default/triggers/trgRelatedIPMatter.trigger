trigger trgRelatedIPMatter on SymphonyLF__Related_IP_Matter__c (after insert) {
   mvSObjectDomain.triggerHandler(RelatedIPMatterTriggerHandler.class);
}