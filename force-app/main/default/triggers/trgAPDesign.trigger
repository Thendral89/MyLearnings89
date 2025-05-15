trigger trgAPDesign on SymphonyLF__Design__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
     list<id> DesignIds= new list<id>();
     Map<Id, Id> ClientIdMap = new Map<Id, Id>();
    
     if (Trigger.isAfter && Trigger.isUpdate) {
        cmpAPiManageEventCtrl.trgPatentiManageEvent(Trigger.new, Trigger.old);
    }
    
    
     if(trigger.IsAfter && trigger.Isinsert) {
         for(SymphonyLF__Design__c pat:Trigger.new) {
             DesignIds.add(pat.Id);
             if (pat.SymphonyLF__Client__c != null) {
                ClientIdMap.put(pat.Id, pat.SymphonyLF__Client__c); // Store Patent Id with Client Id
            }
         }
     }

    if (trigger.isBefore && trigger.isInsert) {
    MatterCreditStatusHandler.handleBeforeInsert(trigger.new,'SymphonyLF__Design__c');
    }    

//    if(trigger.isBefore && trigger.Isupdate) {
//         for(SymphonyLF__Design__c pat:Trigger.new) {
//             if(pat.SymphonyLF__Root_Design_Docket_Number__c!=null && pat.SymphonyLF__Root_Design_Docket_Number__c != Trigger.oldMap.get(pat.Id).SymphonyLF__Root_Design_Docket_Number__c){
//                 pat.SymphonyLF__Family_ID__c=pat.SymphonyLF__Root_Design_Docket_Number__c.replace('-','');
//             }
//         }
//     }
   
   
    if(DesignIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.PatentDocektNumber(DesignIds,'SymphonyLF__Design__c');
        }else{
            cmpAPTrgUtilCtrl.PatentDocektNumberfuture(DesignIds,'SymphonyLF__Design__c');
        }
    }
   
     if(DesignIds.size()>0) {
        if(System.isFuture() || System.isBatch()){
            cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Design__Share',DesignIds,ClientIdMap);
        }else{
            cmpAPTrgUtilCtrl.ShareFeatureClientMatterObj('SymphonyLF__Design__Share',DesignIds,ClientIdMap);
        }
    }
   
//    // For dynamic docketing
//    TriggerDispatcher1.run(new DesignTriggerHandler1(), 'Design');
//    // End dynamic docketing

   if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate )){
    CheckListGenerationHandler.initiateDesignCheckList(trigger.new, trigger.oldMap);
    }
}