trigger CopyrightTrigger1 on SymphonyLF__Copyright__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    list<id> CopyrightIds= new list<id>();
    Map<Id, Id> ClientIdMap = new Map<Id, Id>();    
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        cmpAPiManageEventCtrl.trgPatentiManageEvent(Trigger.new, Trigger.old);
    }
    
    if(trigger.IsAfter && trigger.Isinsert) {
        for(SymphonyLF__Copyright__c pat:Trigger.new) {
            CopyrightIds.add(pat.Id);
            if (pat.SymphonyLF__Client__c != null) {
                ClientIdMap.put(pat.Id, pat.SymphonyLF__Client__c); // Store Patent Id with Client Id
            }
        }
    }
    
    if (trigger.isBefore && trigger.isInsert) {
        MatterCreditStatusHandler.handleBeforeInsert(trigger.new,'SymphonyLF__Copyright__c');
    }
    
    /*  if(CopyrightIds.size()>0) {
if(System.isFuture() || System.isBatch()){
cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Copyright__Share',CopyrightIds,ClientIdMap);
}else{
cmpAPTrgUtilCtrl.ShareFeatureClientMatterObj('SymphonyLF__Copyright__Share',CopyrightIds,ClientIdMap);
}
} */
    
    
    if(CopyrightIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.PatentDocektNumber(CopyrightIds,'SymphonyLF__Copyright__c');
        }else{
            cmpAPTrgUtilCtrl.PatentDocektNumberfuture(CopyrightIds,'SymphonyLF__Copyright__c');
        }
    }
    
    
    //TriggerDispatcher1.run(new CopyrightTriggerHandler1(), 'Copyright');
}