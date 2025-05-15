@isTest
public class ClientEngagementModelTriggerHandlerTest {
    @TestSetup
    static void setupTestData() {
        
        TestDataFactory.createMasterData();
        TestDataFactory.createClient();
        SymphonyLF__Client__c cli = [
            SELECT Id
              FROM SymphonyLF__Client__c
             WHERE SymphonyLF__Client_Number_New__c = '12345'
             LIMIT 1
        ];
        
        System.debug('cli::'+cli.id);
        System.debug('TestDataFactory.personId:'+TestDataFactory.personId);
        
        List<SymphonyLF__Client_Engagement_Model__c> cemList = new List<SymphonyLF__Client_Engagement_Model__c>{
            new SymphonyLF__Client_Engagement_Model__c(
                SymphonyLF__Client__c                    = cli.Id,
                SymphonyLF__Type__c                      = 'Paralegal',
                SymphonyLF__Person__c                    = TestDataFactory.personId,
                SymphonyLF__Applicable_to_all_jurisdiction__c = true,
                Is_Active__c                             = true,
                Is_Default__c                            = true
            ),
            new SymphonyLF__Client_Engagement_Model__c(
                SymphonyLF__Client__c                    = cli.Id,
                SymphonyLF__Type__c                      = 'Backup Attorney',
                SymphonyLF__Person__c                    = TestDataFactory.personId,
                SymphonyLF__Jurisdiction__c              = TestDataFactory.jurisdictionId,
                SymphonyLF__Applicable_to_all_jurisdiction__c = false,
                Is_Active__c                             = true,
                Is_Default__c                            = false
            )
        };
        insert cemList;
    }

    @IsTest
    static void testDeactivateRelatedMEMs() {
        
        SymphonyLF__Client__c cli = [
            SELECT Id
              FROM SymphonyLF__Client__c
             WHERE SymphonyLF__Client_Number_New__c = '12345'
             LIMIT 1
        ];

        
        List<SymphonyLF__Client_Engagement_Model__c> cems = [
            SELECT Id
              FROM SymphonyLF__Client_Engagement_Model__c
             WHERE SymphonyLF__Client__c = :cli.Id
        ];
        System.assertEquals(2, cems.size(), 'Should have exactly 2 CEMs');

        
        Id targetCemId = cems[0].Id;
        Id otherCemId  = cems[1].Id;
       

        //Create three MEMs:
        //    • memA: same client+targetCEM, active
        //    • memB: same client+targetCEM, already inactive
        //    • memC: same client+otherCEM, active
        SymphonyLF__Matter_Engagement_Model__c memA = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Client__c           = cli.Id,
            Client_Engagement_Model__c     = targetCemId,
            Is_Active__c                   = true,
            SymphonyLF__Client2__c      = cli.Id
        );
        SymphonyLF__Matter_Engagement_Model__c memB = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Client__c           = cli.Id,
            Client_Engagement_Model__c     = targetCemId,
            Is_Active__c                   = false,
            SymphonyLF__Client2__c      = cli.Id
        );
        SymphonyLF__Matter_Engagement_Model__c memC = new SymphonyLF__Matter_Engagement_Model__c(
            SymphonyLF__Client__c           = cli.Id,
            Client_Engagement_Model__c     = otherCemId,
            Is_Active__c                   = true,
            SymphonyLF__Client2__c      = cli.Id
        );
        insert new List<SymphonyLF__Matter_Engagement_Model__c>{ memA, memB, memC };

        // change CEM to inactive—this should fire your trigger
        Test.startTest();
          update new SymphonyLF__Client_Engagement_Model__c(
            Id           = targetCemId,
            Is_Active__c = false
          );
        Test.stopTest();

        //  Re-fetch three MEMs and assert the correct one changed
        List<SymphonyLF__Matter_Engagement_Model__c> mems = [
            SELECT Client_Engagement_Model__c, Is_Active__c
              FROM SymphonyLF__Matter_Engagement_Model__c
             WHERE Id IN :new List<Id>{ memA.Id, memB.Id, memC.Id }
             ORDER BY Id
        ];

        for (SymphonyLF__Matter_Engagement_Model__c m : mems) {
            if (m.Id == memA.Id) {
                System.assertEquals(false, m.Is_Active__c, 'memA should have been deactivated');
            } else if (m.Id == memB.Id) {
                System.assertEquals(false, m.Is_Active__c, 'memB was already inactive');
            } else {
                System.assertEquals(true, m.Is_Active__c, 'memC is on the other CEM and should remain active');
            }
        }
    }
}