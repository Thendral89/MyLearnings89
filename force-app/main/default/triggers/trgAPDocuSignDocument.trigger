trigger trgAPDocuSignDocument on DocuSign_Document__c (before insert,before update) {

      if (trigger.isBefore && (trigger.IsInsert || trigger.IsUpdate)) {
          for (DocuSign_Document__c pat:trigger.new) {
               pat.Name=pat.Name.left(80);
          }
      }
    
}