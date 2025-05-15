trigger trgAPTrademark on SymphonyLF__Trademark__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    list<id> TrademarkIds= new list<id>();
    Map<Id, Id> ClientIdMap = new Map<Id, Id>();
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        cmpAPiManageEventCtrl.trgPatentiManageEvent(Trigger.new, Trigger.old);
    }
    
    if(trigger.IsAfter && trigger.Isinsert) {
        for(SymphonyLF__Trademark__c pat:Trigger.new) {
            TrademarkIds.add(pat.Id);
            if (pat.SymphonyLF__Client__c != null) {
                ClientIdMap.put(pat.Id, pat.SymphonyLF__Client__c); // Store Patent Id with Client Id
            }
        }
    }
    
    if (trigger.isBefore && trigger.isInsert) {
        MatterCreditStatusHandler.handleBeforeInsert(trigger.new,'SymphonyLF__Trademark__c');
    }    
    
    //    if(trigger.isBefore && trigger.Isupdate) {
    //        for(SymphonyLF__Trademark__c pat:Trigger.new) {
    //            if(pat.SymphonyLF__Root_Mark_Docket_Number__c!=null && pat.SymphonyLF__Root_Mark_Docket_Number__c != Trigger.oldMap.get(pat.Id).SymphonyLF__Root_Mark_Docket_Number__c){
    //               pat.SymphonyLF__Family_Id__c=pat.SymphonyLF__Root_Mark_Docket_Number__c.replace('-','');
    //            }
    //         }
    //    }
    
    if(TrademarkIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.PatentDocektNumber(TrademarkIds,'SymphonyLF__Trademark__c');
        }else{
            cmpAPTrgUtilCtrl.PatentDocektNumberfuture(TrademarkIds,'SymphonyLF__Trademark__c');
        }
    }
    
    if(TrademarkIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Trademark__Share',TrademarkIds,ClientIdMap);
        }else{
            cmpAPTrgUtilCtrl.ShareFeatureClientMatterObj('SymphonyLF__Trademark__Share',TrademarkIds,ClientIdMap);
        }
    }
    
    // For dynamic docketing
    //TriggerDispatcher1.run(new TrademarkTriggerHandler1(), 'Trademark');
    // End dynamic docketing
    
}