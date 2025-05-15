trigger AgreementContractTrigger1 on SymphonyLF__Agreement_Contract__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    list<id> AgreementIds= new list<id>();
    Map<Id, Id> ClientIdMap = new Map<Id, Id>();
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        cmpAPiManageEventCtrl.trgPatentiManageEvent(Trigger.new, Trigger.old);
    }
    
    if(trigger.IsAfter && trigger.Isinsert) {
        for(SymphonyLF__Agreement_Contract__c pat:Trigger.new) {
            AgreementIds.add(pat.Id);
            if (pat.SymphonyLF__Client__c != null) {
                ClientIdMap.put(pat.Id, pat.SymphonyLF__Client__c); // Store Patent Id with Client Id
            }
        }
    }
    
    if (trigger.isBefore && trigger.isInsert) {
        MatterCreditStatusHandler.handleBeforeInsert(trigger.new,'SymphonyLF__Agreement_Contract__c');
    }
    
    if(AgreementIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.PatentDocektNumber(AgreementIds,'SymphonyLF__Agreement_Contract__c');
        }else{
            cmpAPTrgUtilCtrl.PatentDocektNumberfuture(AgreementIds,'SymphonyLF__Agreement_Contract__c');
        }
    }
    
    
    /*  if(AgreementIds.size()>0) {
if(System.isFuture() || System.isBatch()){
cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Agreement_Contract__Share',AgreementIds,ClientIdMap);
}else{
cmpAPTrgUtilCtrl.ShareFeatureClientMatterObj('SymphonyLF__Agreement_Contract__Share',AgreementIds,ClientIdMap);
}
}*/
    
    
    //TriggerDispatcher1.run(new AgreementsTriggerHandler1(), 'Agreements');
}