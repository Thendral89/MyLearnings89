/* Copyright © 2024 MaxVal Group. All Rights Reserved.
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Dinesh R, 08/01/25 
* Jira Ticket#MCC-1708
Test Class: MEMGroupTriggerHandlerTest
*/
trigger MEMGroupTrigger on MEM_Group__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    MEMGroupTriggerHandler handler = New MEMGroupTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert){
        //to update String fields of MEM Group using MEM contact Person - (Attorneys, WorkingAttorneys, Paralegals)
        handler.beforeInsertORUpdate(trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        if(UserInfo.getName() != 'Data Migration'){
            //handler.updateMEMLookupField(trigger.new);
            handler.processAfterInsertAndUpdate(trigger.new); 
            handler.processAfterInsert(trigger.new);       
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        //to update String fields of MEM Group using MEM contact Person - (Attorneys, WorkingAttorneys, Paralegals)
        handler.beforeInsertORUpdate(trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        handler.processAfterUpdate(trigger.new, trigger.OldMap);
        handler.processAfterInsertAndUpdate(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isDelete){}
    
    if(Trigger.isAfter && Trigger.isDelete){}
}