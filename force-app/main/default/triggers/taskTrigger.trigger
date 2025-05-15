trigger taskTrigger on Task (after insert, after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            taskTriggerHandler.handleAfterInsertTask(Trigger.new);
        }
        if(Trigger.isUpdate){
            taskTriggerHandler.handleAfterUpdateTask(Trigger.newMap, Trigger.oldMap);
        }
    }
}