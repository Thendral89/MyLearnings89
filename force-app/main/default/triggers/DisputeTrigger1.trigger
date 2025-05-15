trigger DisputeTrigger1 on SymphonyLF__Dispute_Opposition__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        cmpAPiManageEventCtrl.trgPatentiManageEvent(Trigger.new, Trigger.old);
    }
    
     list<id> DisputeIds= new list<id>();
     Map<Id, Id> ClientIdMap = new Map<Id, Id>();    
      if(trigger.IsAfter && trigger.Isinsert) {
         for(SymphonyLF__Dispute_Opposition__c pat:Trigger.new) {
             DisputeIds.add(pat.Id);
             if (pat.SymphonyLF__Client__c != null) {
                ClientIdMap.put(pat.Id, pat.SymphonyLF__Client__c); // Store Patent Id with Client Id
            }
         }
     }
    
    if (trigger.isBefore && trigger.isInsert) {
    MatterCreditStatusHandler.handleBeforeInsert(trigger.new,'SymphonyLF__Agreement_Contract__c');
    }
    
     if(DisputeIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.PatentDocektNumber(DisputeIds,'SymphonyLF__Dispute_Opposition__c');
        }else{
            cmpAPTrgUtilCtrl.PatentDocektNumberfuture(DisputeIds,'SymphonyLF__Dispute_Opposition__c');
        }
    }
    
  /*   if(DisputeIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Dispute_Opposition__Share',DisputeIds,ClientIdMap);
        }else{
            cmpAPTrgUtilCtrl.ShareFeatureClientMatterObj('SymphonyLF__Dispute_Opposition__Share',DisputeIds,ClientIdMap);
        }
    } */
    
    //TriggerDispatcher1.run(new DisputeTriggerHandler1(), 'Dispute/Opposition');
}