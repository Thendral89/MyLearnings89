trigger TrgLegalEvent on SymphonyLF__Legal_Event__c (after insert, after update) {
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate )){
        CheckListGenerationHandler.initiateNOACheckList(trigger.new, trigger.oldMap);
    }
}