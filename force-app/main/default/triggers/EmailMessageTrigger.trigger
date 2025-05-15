trigger EmailMessageTrigger on EmailMessage (before insert,after insert, after update) {
    Set<Id> emailMessageIdsToSync = new Set<Id>();
    
/*    if(trigger.IsBefore && trigger.Isinsert) {
        for (EmailMessage em : Trigger.new) {
            //em.Sync_to_iManage__c = true;   
        }
    }
    
    if(trigger.IsAfter && trigger.Isinsert) {
        for (EmailMessage em : Trigger.new) {
            if (em.Sync_to_iManage__c == true) {
                emailMessageIdsToSync.add(em.Id);
            }
        }
    }
    
    
    if (!emailMessageIdsToSync.isEmpty()) {
        if(System.isFuture() || System.isBatch()){
            EmailMessageTriggerHelper.uploadEmailsToIManage(emailMessageIdsToSync);
        }else{
            EmailMessageTriggerHelper.uploadEmailsToIManagefuture(emailMessageIdsToSync);  
        }
    } */
   
}