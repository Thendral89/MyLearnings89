trigger trgIManageDocuments on iManage_Documents__c (after insert) {
     mvSObjectDomain.triggerHandler(imanageDocTriggerHandler.class);
}