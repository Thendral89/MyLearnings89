trigger tgrDocketingActivity on SymphonyLF__Docketing_Activity__c (before insert, before update, after insert, after update) {
    List<Id> docketIds = new List<Id>();
    
    if (Trigger.isBefore && Trigger.isInsert) {
        for (SymphonyLF__Docketing_Activity__c  eachDocketActivity:trigger.new) {
            if(eachDocketActivity.Comments__c!=null && eachDocketActivity.Comments__c!=''){
                eachDocketActivity.SymphonyLF__Comments__c  = Date.today().format() + ' - '  + eachDocketActivity.Comments__c +'\r\n';
                eachDocketActivity.Comments__c = '';
            }
        }
    }
    
    if (trigger.isBefore && trigger.isUpdate) {
        for (SymphonyLF__Docketing_Activity__c  eachDocketActivity:trigger.new) {
            if(eachDocketActivity.Comments__c!=null && eachDocketActivity.Comments__c!=''){
                if(Trigger.oldMap <> Null && !String.isBlank(Trigger.oldMap.get(eachDocketActivity.Id).SymphonyLF__Comments__c)){
                    eachDocketActivity.SymphonyLF__Comments__c = Trigger.oldMap.get(eachDocketActivity.Id).SymphonyLF__Comments__c + '\r\n' + Date.today().format() + ' - '  + eachDocketActivity.Comments__c;    
                }else{
                    eachDocketActivity.SymphonyLF__Comments__c = Date.today().format() + ' - '  + eachDocketActivity.Comments__c;
                }
                eachDocketActivity.Comments__c = '';
            }
        }
    }

}