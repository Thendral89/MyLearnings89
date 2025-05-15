trigger trgAPiManageEventQueue on iManage_Events__c (after insert) {
    List<cmpAPiManageEvent__e> events = new List<cmpAPiManageEvent__e>();
    
    for (iManage_Events__c record : Trigger.new) {
        events.add(new cmpAPiManageEvent__e(
            recordId__c= record.recordId__c
        ));
    }
    
    if (!events.isEmpty()) {
        Database.SaveResult[] results = EventBus.publish(events);
    }
}