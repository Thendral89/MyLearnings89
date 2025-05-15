public class AssetIntakeInventorHandler {

    public static void handlePrimaryInventorUpdate(
        List<Asset_Intake_Inventor__c> newList,
        Map<Id, Asset_Intake_Inventor__c> oldMap
    ) {
        List<Asset_Intake_Inventor__c> inventorsList = new List<Asset_Intake_Inventor__c>();
        if (newList == null || newList.isEmpty()) return;

        Set<Id> formIds = new Set<Id>();
        Map<Id, List<Asset_Intake_Inventor__c>> primaryMarkedByForm = new Map<Id, List<Asset_Intake_Inventor__c>>();

        for (Asset_Intake_Inventor__c newRec : newList) {
            Asset_Intake_Inventor__c oldRec = (oldMap != null && newRec.Id != null) ? oldMap.get(newRec.Id) : null;

            Boolean changedToPrimary = newRec.Primary_Inventor__c &&
                (oldRec == null || !oldRec.Primary_Inventor__c);

            if (changedToPrimary && newRec.Asset_Intake_Form__c != null) {
                formIds.add(newRec.Asset_Intake_Form__c);
                System.debug('formIds------>'+formIds);

                if (!primaryMarkedByForm.containsKey(newRec.Asset_Intake_Form__c)) {
                    primaryMarkedByForm.put(newRec.Asset_Intake_Form__c, new List<Asset_Intake_Inventor__c>());
                    System.debug('primaryMarkedByForm put------>'+primaryMarkedByForm);
                }
                primaryMarkedByForm.get(newRec.Asset_Intake_Form__c).add(newRec);
                System.debug('primaryMarkedByForm get------>'+primaryMarkedByForm);
            }
        }

        if (formIds.isEmpty()) return;

        // Step 2: Fetch all inventors for these forms
        Map<Id, List<Asset_Intake_Inventor__c>> formInventorMap = new Map<Id, List<Asset_Intake_Inventor__c>>();
        for (Asset_Intake_Inventor__c inv : [
            SELECT Id, Asset_Intake_Form__c, Primary_Inventor__c
            FROM Asset_Intake_Inventor__c
            WHERE Asset_Intake_Form__c IN :formIds
        ]) {
            if (!formInventorMap.containsKey(inv.Asset_Intake_Form__c)) {
                formInventorMap.put(inv.Asset_Intake_Form__c, new List<Asset_Intake_Inventor__c>());
                System.debug('formInventorMap put------>'+formInventorMap);
            }
            formInventorMap.get(inv.Asset_Intake_Form__c).add(inv);
            System.debug('formInventorMap get------>'+formInventorMap);
        }

        // Step 3: Mark all others as false
        for (Id formId : primaryMarkedByForm.keySet()) {
            List<Asset_Intake_Inventor__c> updatedPrimaries = primaryMarkedByForm.get(formId);
            System.debug('updatedPrimaries------>'+updatedPrimaries);
            if (updatedPrimaries.isEmpty()) continue;

            Asset_Intake_Inventor__c selectedPrimary = updatedPrimaries[0];
            System.debug('selectedPrimary------>'+selectedPrimary);
            
            // if (!formInventorMap.containsKey(formId)) continue;
            if(!formInventorMap.isEmpty()){
                for (Asset_Intake_Inventor__c inventor : formInventorMap.get(formId)) {
                if (inventor.Id != selectedPrimary.Id && inventor.Primary_Inventor__c) {
                    inventor.Primary_Inventor__c = false;
                    inventorsList.add(inventor);

                    // Check if it's part of trigger.new and set it directly
                   /* for (Asset_Intake_Inventor__c rec : newList) {
                        if (rec.Id == inventor.Id) {
                            rec.Primary_Inventor__c = false;
                        }
                    }*/
                }
             }
            }
            
            System.debug('inventorsList---->'+inventorsList);
            if(!inventorsList.isEmpty()){
                update inventorsList;
            }
        }
    }
}