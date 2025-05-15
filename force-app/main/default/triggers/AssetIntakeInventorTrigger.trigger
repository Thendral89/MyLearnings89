trigger AssetIntakeInventorTrigger on Asset_Intake_Inventor__c (before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AssetIntakeInventorHandler.handlePrimaryInventorUpdate(Trigger.new, null);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        AssetIntakeInventorHandler.handlePrimaryInventorUpdate(Trigger.new, Trigger.oldMap);
    }
}