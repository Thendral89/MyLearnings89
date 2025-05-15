public class taskTriggerHandler {
    public static void handleAfterInsertTask(List<Task> newItems) {
        Map<Id, Task> newMap = new Map<Id, Task>();
        for (Task t : newItems) {
            newMap.put(t.Id, t);
        }
		handleTaskProcessing(newMap, null, true);
    }

    public static void handleAfterUpdateTask(Map<Id, Task> newItems, Map<Id, Task> oldItems) {
        handleTaskProcessing(newItems, oldItems, false);
    }

    
    private static void handleTaskProcessing(Map<Id, Task> newItems, Map<Id, Task> oldItems, Boolean isInsert) {
        Map<Id, Integer> conflictCountApprove = new Map<Id, Integer>();
        Map<Id, Integer> conflictCountDiscuss = new Map<Id, Integer>();
        Map<Id, Integer> conflictTotalCount = new Map<Id, Integer>();
        Set<Id> conflictIdSet = new Set<Id>();

        for (Task taskRec : newItems.values()) {
            if (taskRec.Status == null || taskRec.WhatId == null) continue;

            
            if (!isInsert && oldItems != null && taskRec.Status == oldItems.get(taskRec.Id).Status) continue;

            Schema.SObjectType type = taskRec.WhatId.getSObjectType();
            String typeName = type.getDescribe().getName();

            if (typeName != 'Conflict_Check__c') continue;

            Id conflictId = taskRec.WhatId;
            conflictIdSet.add(conflictId);

            if (taskRec.Status == 'Approve') {
                conflictCountApprove.put(conflictId, conflictCountApprove.containsKey(conflictId) ? conflictCountApprove.get(conflictId) + 1 : 1);
            }

            if (taskRec.Status == 'Discuss') {
                conflictCountDiscuss.put(conflictId,conflictCountDiscuss.containsKey(conflictId)? conflictCountDiscuss.get(conflictId) + 1: 1);
            }

            conflictTotalCount.put(conflictId,conflictTotalCount.containsKey(conflictId)? conflictTotalCount.get(conflictId) + 1: 1);
        }

        updateConflictCounts(conflictIdSet, conflictCountApprove, conflictCountDiscuss, conflictTotalCount);
    }

    private static void updateConflictCounts(Set<Id> conflictIds,Map<Id, Integer> approveCounts,Map<Id, Integer> discussCounts,Map<Id, Integer> totalCounts) {
        if (conflictIds.isEmpty()) return;

        Map<Id, Conflict_Check__c> conflictCheckMap = new Map<Id, Conflict_Check__c>(
            [SELECT Id, Approve_Count__c, Discuss_Count__c, Total_Count__c
             FROM Conflict_Check__c
             WHERE Id IN :conflictIds]
        );

        List<Conflict_Check__c> recordsToUpdate = new List<Conflict_Check__c>();

        for (Id ccId : conflictCheckMap.keySet()) {
            Conflict_Check__c ccRec = conflictCheckMap.get(ccId);

            if (approveCounts.containsKey(ccId)) {
                ccRec.Approve_Count__c += approveCounts.get(ccId);
            }

            if (discussCounts.containsKey(ccId)) {
                ccRec.Discuss_Count__c += discussCounts.get(ccId);
            }

            if (totalCounts.containsKey(ccId)) {
                ccRec.Total_Count__c += totalCounts.get(ccId);
            }

            recordsToUpdate.add(ccRec);
        }
		system.debug('record to update :'+recordsToUpdate);
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
   
    
}