trigger trgAPClientEngagement on SymphonyLF__Client_Engagement_Model__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
     mvSObjectDomain.triggerHandler(ClientEngagementModelTriggerHandler.class);
}