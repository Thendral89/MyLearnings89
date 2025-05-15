@isTest
public class taskTriggerHandlerTest {
        @testSetup
    static void setupData() {
        Conflict_Check__c conflictRecord = new Conflict_Check__c(
            Approve_Count__c = 0,
            Discuss_Count__c = 0,
            Total_Count__c = 0
        );
        insert conflictRecord;
    }

    @isTest
    static void testInsertTasks() {
        Conflict_Check__c conflict = [SELECT Id FROM Conflict_Check__c LIMIT 1];
        
        List<Task> taskList = new List<Task>{
            new Task(Subject = 'Approve Task', Status = 'Approve', WhatId = conflict.Id),
            new Task(Subject = 'Discuss Task', Status = 'Discuss', WhatId = conflict.Id)
        };

        Test.startTest();
        insert taskList;
        Test.stopTest();
    }

    @isTest
    static void testUpdateTasks() {
        Conflict_Check__c conflict = [SELECT Id FROM Conflict_Check__c LIMIT 1];

        List<Task> taskList = new List<Task>{
            new Task(Subject = 'Task 1', Status = 'Not Started', WhatId = conflict.Id),
            new Task(Subject = 'Task 2', Status = 'Not Started', WhatId = conflict.Id)
        };
        insert taskList;

        for (Task t : taskList) {
            t.Status = 'Approve';
        }

        Test.startTest();
        update taskList;
        Test.stopTest();
    }
}