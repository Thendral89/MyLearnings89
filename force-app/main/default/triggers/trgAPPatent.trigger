trigger trgAPPatent on SymphonyLF__Patent__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
  
    list<id> PatentId= new list<id>();
    Map<Id, Id> ClientIdMap = new Map<Id, Id>();
    
   
    
    
    if(trigger.IsAfter && trigger.Isinsert) {
        for(SymphonyLF__Patent__c pat:Trigger.new) {
            PatentId.add(pat.Id);
            if (pat.SymphonyLF__Client__c != null) {
                ClientIdMap.put(pat.Id, pat.SymphonyLF__Client__c);
            }
        }
    }
    
      
    if (trigger.isBefore && trigger.isInsert) {
        MatterCreditStatusHandler.handleBeforeInsert(trigger.new,'SymphonyLF__Patent__c');
    }
    
    if(PatentId.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.PatentDocektNumber(PatentId,'SymphonyLF__Patent__c');
        }else{
            cmpAPTrgUtilCtrl.PatentDocektNumberfuture(PatentId,'SymphonyLF__Patent__c');
        }
    }

    if(PatentId.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Patent__Share',PatentId,ClientIdMap);
        }else{
            cmpAPTrgUtilCtrl.ShareFeatureClientMatterObj('SymphonyLF__Patent__Share',PatentId,ClientIdMap);
        }
    }
    
    
    if(trigger.isAfter && (trigger.Isupdate ||  trigger.Isinsert) ) {
        CheckListGenerationHandler.initiatePatentCheckList(trigger.new, trigger.oldMap);
    } 
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        cmpAPiManageEventCtrl.trgPatentiManageEvent(Trigger.new, Trigger.old);
    }
    
}