trigger GeneralMatterTrigger1 on SymphonyLF__General_Matter__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    list<id> GeneralIds= new list<id>();
    Map<Id, Id> ClientIdMap = new Map<Id, Id>();
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        cmpAPiManageEventCtrl.trgPatentiManageEvent(Trigger.new, Trigger.old);
    }
    
    if(trigger.isAfter && trigger.IsInsert) {   
        for(SymphonyLF__General_Matter__c pat:Trigger.new) {
            GeneralIds.add(pat.Id);
            if (pat.SymphonyLF__Client__c != null) {
                ClientIdMap.put(pat.Id, pat.SymphonyLF__Client__c); // Store Patent Id with Client Id
            }
        }
    }
    
    if (trigger.isBefore && trigger.isInsert) {
        MatterCreditStatusHandler.handleBeforeInsert(trigger.new,'SymphonyLF__General_Matter__c');
    }
    
    if(GeneralIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.PatentDocektNumber(GeneralIds,'SymphonyLF__General_Matter__c');
        }else{
            cmpAPTrgUtilCtrl.PatentDocektNumberfuture(GeneralIds,'SymphonyLF__General_Matter__c');
        }
    }
    
    if(GeneralIds.size()>0) {
            if(System.isFuture() || System.isBatch()){
                mvShareUtilities.OrgRecordSharing('SymphonyLF__General_Matter__Share',GeneralIds);
            }else{
                mvShareUtilities.OrgRecordSharingfuture('SymphonyLF__General_Matter__Share',GeneralIds);
            }
        }
    
    //TriggerDispatcher1.run(new GeneralMatterTriggerHandler1(), 'GeneralMatter');
    
}