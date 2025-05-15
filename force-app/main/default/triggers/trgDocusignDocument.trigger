trigger trgDocusignDocument on DocuSign_Document__c (after insert) {
    mvSObjectDomain.triggerHandler(docusignTriggerHandler.class);
}