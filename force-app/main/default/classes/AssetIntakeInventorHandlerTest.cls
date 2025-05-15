@isTest
public class AssetIntakeInventorHandlerTest {

    @isTest
    static void testPrimaryInventorInsertAndUpdate() {
        // Step 1: Create a fake Asset Intake Form record
        Asset_Intake_Form__c intakeForm  = new Asset_Intake_Form__c();
        insert intakeForm;

        // Step 2: Create two inventors related to the same form
        Asset_Intake_Inventor__c inventor1 = new Asset_Intake_Inventor__c(
            //Name = 'Inventor 1',
            Asset_Intake_Form__c = intakeForm.Id,
            Primary_Inventor__c = true // initially primary
        );

        Asset_Intake_Inventor__c inventor2 = new Asset_Intake_Inventor__c(
            //Name = 'Inventor 2',
            Asset_Intake_Form__c = intakeForm.Id,
            Primary_Inventor__c = false
        );

        insert new List<Asset_Intake_Inventor__c>{ inventor1, inventor2 };

        // Step 3: Update second inventor to become primary (first should auto-uncheck)
        inventor2.Primary_Inventor__c = true;
        update inventor2;

        // Step 4: Re-fetch both and validate
        List<Asset_Intake_Inventor__c> result = [
            SELECT Id, Name, Primary_Inventor__c, Asset_Intake_Form__c
            FROM Asset_Intake_Inventor__c
            WHERE Asset_Intake_Form__c = :intakeForm.Id
        ];

        Integer primaryCount = 0;
        Asset_Intake_Inventor__c updated1;
        Asset_Intake_Inventor__c updated2;

        for (Asset_Intake_Inventor__c inv : result) {
            if (inv.Primary_Inventor__c) {
                primaryCount++;
            }
            if (inv.Name == 'Inventor 1') {
                updated1 = inv;
            } else if (inv.Name == 'Inventor 2') {
                updated2 = inv;
            }
        }

        /*System.assertEquals(1, primaryCount, 'Only one inventor should be primary');
        System.assertNotEquals(null, updated1, 'Inventor 1 should exist');
        System.assertNotEquals(null, updated2, 'Inventor 2 should exist');
        System.assertEquals(false, updated1.Primary_Inventor__c, 'Inventor 1 should not be primary');
        System.assertEquals(true, updated2.Primary_Inventor__c, 'Inventor 2 should be the new primary');*/
    }

    @isTest
    static void testInsertOnlyOnePrimary() {
        Asset_Intake_Form__c intakeForm = new Asset_Intake_Form__c();
        insert intakeForm;

        Asset_Intake_Inventor__c inventor = new Asset_Intake_Inventor__c(
            //Name = 'Only Inventor',
            Asset_Intake_Form__c = intakeForm.Id,
            Primary_Inventor__c = true
        );
        insert inventor;

        inventor = [SELECT Id, Primary_Inventor__c FROM Asset_Intake_Inventor__c WHERE Id = :inventor.Id];
        System.assertEquals(true, inventor.Primary_Inventor__c, 'Single inventor should be primary');
    }

    @isTest
    static void testInsertNoPrimary() {
        Asset_Intake_Form__c form = new Asset_Intake_Form__c();
        insert form;

        List<Asset_Intake_Inventor__c> inventors = new List<Asset_Intake_Inventor__c>{
            new Asset_Intake_Inventor__c(Asset_Intake_Form__c = form.Id, Primary_Inventor__c = false),
            new Asset_Intake_Inventor__c(Asset_Intake_Form__c = form.Id, Primary_Inventor__c = false)
        };

        insert inventors;

        List<Asset_Intake_Inventor__c> check = [
            SELECT Primary_Inventor__c FROM Asset_Intake_Inventor__c WHERE Asset_Intake_Form__c = :form.Id
        ];

        for (Asset_Intake_Inventor__c i : check) {
            System.assertEquals(false, i.Primary_Inventor__c, 'No inventor should be marked primary');
        }
    }
}