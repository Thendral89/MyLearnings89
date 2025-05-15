trigger trgAPiManageEvent on cmpAPiManageEvent__e (after insert) {
    List<cmpAPiManageEvent__e> eventsToProcess = Trigger.new;
    if (!eventsToProcess.isEmpty()) {
        System.enqueueJob(new cmpAPiManageEventListener(eventsToProcess));
    }
}