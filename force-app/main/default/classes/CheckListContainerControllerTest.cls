@isTest
public class CheckListContainerControllerTest {

    
    @testSetup
    static void setupTestData() {
        
        Profile attorneyProfile = [SELECT Id FROM Profile WHERE Name = 'Attorney' LIMIT 1];
        User attorneyUser = new User(
            Username = 'customuserss4@test.com',
            LastName = 'Attorneytest',
            Alias = 'test',
            Email = 'customuser@test.com',
            ProfileId = attorneyProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert attorneyUser;

        Profile legalAssistantProfile = [SELECT Id FROM Profile WHERE Name = 'Legal Assistant' LIMIT 1];
        User legalAssistantUser = new User(
            Username = 'customuserss3@test.com',
            LastName = 'legalAssistanttest',
            Alias = 'test',
            Email = 'customuser@test.com',
            ProfileId = legalAssistantProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert legalAssistantUser;

        Profile paralegalProfile = [SELECT Id FROM Profile WHERE Name = 'Paralegal' LIMIT 1];
        User paralegalUser = new User(
            Username = 'customusersss2@test.com',
            LastName = 'Paralegaltest',
            Alias = 'test',
            Email = 'customuser@test.com',
            ProfileId = paralegalProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert paralegalUser;

        User paralegalDoubleCheckerUser = new User(
            Username = 'customuser1sss@test.com',
            LastName = 'doubleCheckertest',
            Alias = 'test',
            Email = 'customuser@test.com',
            ProfileId = paralegalProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            double_checker__c = true
        );
        insert paralegalDoubleCheckerUser;

        // Create test Checklist records
        Checklist__c checklist1 = new Checklist__c(Name = 'CHECKLIST FOR NEW U.S. APPLICATION', Checklist_Code__c = 'CHECKLIST FOR NEW U.S. APPLICATION');
        insert checklist1;
        Checklist__c checklist2 = new Checklist__c(Name = 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION', Checklist_Code__c = 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION');
        insert checklist2;
        Checklist__c checklist3 = new Checklist__c(Name = 'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION', Checklist_Code__c = 'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION');
        insert checklist3;
        Checklist__c checklist4 = new Checklist__c(Name = 'CHECKLIST FOR NEW U.S. DESIGN APPLICATION', Checklist_Code__c = 'CHECKLIST FOR NEW U.S. DESIGN APPLICATION');
        insert checklist4;
        Checklist__c checklist5 = new Checklist__c(Name = 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION', Checklist_Code__c = 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION');
        insert checklist5;
        Checklist__c checklist6 = new Checklist__c(Name = 'CHECKLIST FOR NOTICE OF ALLOWANCE', Checklist_Code__c = 'CHECKLIST FOR NOTICE OF ALLOWANCE');
        insert checklist6;
        Checklist__c checklist7 = new Checklist__c(Name = 'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE', Checklist_Code__c = 'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE');
        insert checklist7;
        List<Checklist_Item__c> itemList = new List<Checklist_Item__c>();
        itemList.add(new Checklist_Item__c(Checklist__c = checklist1.Id));
        itemList.add(new Checklist_Item__c(Checklist__c = checklist2.Id));
        itemList.add(new Checklist_Item__c(Checklist__c = checklist3.Id));
        itemList.add(new Checklist_Item__c(Checklist__c = checklist4.Id));
        itemList.add(new Checklist_Item__c(Checklist__c = checklist5.Id));
        itemList.add(new Checklist_Item__c(Checklist__c = checklist6.Id));
        itemList.add(new Checklist_Item__c(Checklist__c = checklist7.Id));
        insert itemList;

        // Create related records (Currency, Client, Country, Patent, Design)
        SymphonyLF__Currency__c usdCurrency = new SymphonyLF__Currency__c(Name = 'USD');
        insert usdCurrency;

        SymphonyLF__Client__c client = new SymphonyLF__Client__c(
            Name = 'Test Client',
            SymphonyLF__Default_Billing_Currency__c = usdCurrency.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Number_New__c = '12345'
        );
        insert client;

        SymphonyLF__Country__c usaCountry = new SymphonyLF__Country__c(Name = 'United States of America');
        insert usaCountry;
        
        SymphonyLF__Country__c wipoCountry = new SymphonyLF__Country__c(Name = 'World Intellectual Property Organization (WIPO)/PCT');
        insert wipoCountry;

        List<SymphonyLF__Patent__c> patentList = new List<SymphonyLF__Patent__c>();
        patentList.add(new SymphonyLF__Patent__c(
            Name = 'test',
            SymphonyLF__Country__c = usaCountry.Id,
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Case_Type__c = 'Continuation'
        )) ;
        
        patentList.add( new SymphonyLF__Patent__c(
            Name = 'test',
            SymphonyLF__Country__c = usaCountry.Id,
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Case_Type__c = 'PCT National'
        ));
        
       patentList.add( new SymphonyLF__Patent__c(
            Name = 'test',
            SymphonyLF__Country__c = wipoCountry.Id,
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Case_Type__c = 'Secondary'
        ));
        
        patentList.add(new SymphonyLF__Patent__c(
            Name = 'test',
            SymphonyLF__Country__c = usaCountry.Id,
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Case_Type__c = 'Provisional'
        ));
        Insert patentList;

        SymphonyLF__Design__c design = new SymphonyLF__Design__c(
            SymphonyLF__Case_Type__c = 'Continuation',
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Jurisdiction__c = usaCountry.Id
        );
        insert design;
        
        SymphonyLF__Legal_Event__c legalEvent = new SymphonyLF__Legal_Event__c();
        legalEvent.SymphonyLF__Document_Code__c = 'NOA';
        legalEvent.SymphonyLF__Patent__c = patentList[0].Id;
        Insert legalEvent;
          RecordType personRecordType = [SELECT Id FROM RecordType 
                                          WHERE SobjectType = 'SymphonyLF__Person__c' 
                                          AND DeveloperName = 'Internal' 
                                          LIMIT 1];
        SymphonyLF__Office_Agent__c office = new SymphonyLF__Office_Agent__c(Name = 'test', SymphonyLF__Type__c = 'Office');
        insert office;
        SymphonyLF__Person__c paralegalPerson = new SymphonyLF__Person__c(
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__User__c = paralegalUser.Id,
            SymphonyLF__Contact_Type__c = 'Paralegal',
            SymphonyLF__Email__c = 'paralegal@example.com',
            SymphonyLF__Type__c = 'Internal',
            RecordTypeId = personRecordType.Id,
            SymphonyLF__Office_Agent__c = office.Id
        );
        INSERT paralegalPerson;
        SymphonyLF__Person__c legalAssistantPerson = new SymphonyLF__Person__c(
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__User__c = legalAssistantUser.Id,
            SymphonyLF__Contact_Type__c = 'Legal Assistant',
            SymphonyLF__Email__c = 'paralegal@example.com',
            SymphonyLF__Type__c = 'Internal',
            RecordTypeId = personRecordType.Id,
            SymphonyLF__Office_Agent__c = office.Id
        );
        INSERT legalAssistantPerson;
        
        List<SymphonyLF__Matter_Engagement_Model__c> memRecordsList = new List<SymphonyLF__Matter_Engagement_Model__c>();
        memRecordsList.add(new SymphonyLF__Matter_Engagement_Model__c(SymphonyLF__Type__c = 'Paralegal',SymphonyLF__Supervisor_Client_Contact__c = paralegalPerson.Id,  SymphonyLF__Client2__c = client.Id, SymphonyLF__Design__c = design.Id));
        memRecordsList.add(new SymphonyLF__Matter_Engagement_Model__c(SymphonyLF__Type__c = 'Paralegal',SymphonyLF__Supervisor_Client_Contact__c = paralegalPerson.Id,  SymphonyLF__Client2__c = client.Id, SymphonyLF__Patent__c = patentList[0].Id));
        memRecordsList.add(new SymphonyLF__Matter_Engagement_Model__c( SymphonyLF__Type__c = 'Legal Assistant',SymphonyLF__Supervisor_Client_Contact__c = legalAssistantPerson.Id,  SymphonyLF__Client2__c = client.Id, SymphonyLF__Patent__c = patentList[0].Id));
        memRecordsList.add(new SymphonyLF__Matter_Engagement_Model__c(SymphonyLF__Type__c = 'Legal Assistant',SymphonyLF__Supervisor_Client_Contact__c = legalAssistantPerson.Id,  SymphonyLF__Client2__c = client.Id, SymphonyLF__Design__c = design.Id));
        
        INSERT memRecordsList;

        
        SymphonyLF__Legal_Event__c legalEvent2 = new SymphonyLF__Legal_Event__c();
        legalEvent2.SymphonyLF__Document_Code__c = 'NOA';
        legalEvent2.SymphonyLF__Design__c = design.Id;
        Insert legalEvent2;

        // Create Checklist Instances
        Checklist_Instance__c checklistInstance1 = new Checklist_Instance__c(
            Checklist__c = checklist1.Id,
            Secretary__c = paralegalUser.Id,
            Patent__c = patentList[0].Id,
            Status__c = 'Initial Assignment Checklist In Progress'
        );
        insert checklistInstance1;

        Checklist_Instance__c checklistInstance2 = new Checklist_Instance__c(
            Checklist__c = checklist1.Id,
            Secretary_Completed__c = true,
            Attorney__c = attorneyUser.Id,
            Patent__c = patentList[0].Id,
            Status__c = 'Initial Assignment Checklist In Progress'
        );
        insert checklistInstance2;

        Checklist_Instance__c checklistInstance3 = new Checklist_Instance__c(
            Checklist__c = checklist1.Id,
            Attorney_Completed__c = true,
            Patent__c = patentList[0].Id,
            Status__c = 'Double Checking'
        );
        insert checklistInstance3;

        Checklist_Instance__c checklistInstance4 = new Checklist_Instance__c(
            Checklist__c = checklist1.Id,
            Attorney_Completed__c = true,
            Status__c = 'Double Checking',
            Patent__c = patentList[0].Id,
            Double_Checker__c = paralegalDoubleCheckerUser.Id
        );
        insert checklistInstance4;

        Checklist_Instance__c checklistInstance5 = new Checklist_Instance__c(
            Checklist__c = checklist2.Id,
            Patent__c = patentList[0].Id,
            Status__c = 'Initial Assignment Checklist In Progress'
        );
        insert checklistInstance5;

        Checklist_Instance__c checklistInstance6 = new Checklist_Instance__c(
            Checklist__c = checklist3.Id,
            Patent__c = patentList[0].Id,
            Status__c = 'Initial Assignment Checklist In Progress'
        );
        insert checklistInstance6;

        Checklist_Instance__c checklistInstance7 = new Checklist_Instance__c(
            Checklist__c = checklist3.Id,
            Patent__c = patentList[0].Id,
            Status__c = 'Completed'
        );
        insert checklistInstance7;
    }

    @isTest
    public static void testGetCurrentUser() {
        
            Test.startTest();
            User result = ChecklistContainerController.getCurrentUser();
            //System.assertNotEquals(null, result);
            Test.stopTest();
        
    }

    @isTest
    public static void testGetChecklistInstanceRecord() {
        List<Checklist_Instance__c> instanceRecords = [SELECT Id FROM Checklist_Instance__c LIMIT 1];
        Test.startTest();
        List<Checklist_Instance__c> result = ChecklistContainerController.getCheckInstanceRec(instanceRecords[0].Id);
        //System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    public static void testGetChecklistInstancesForPatent() {
        SymphonyLF__Patent__c patentRecord = [SELECT Id FROM SymphonyLF__Patent__c LIMIT 1];
        Test.startTest();
        List<ChecklistContainerController.InstanceWrapper> result = ChecklistContainerController.getCheckListInstances(patentRecord.Id);
        //System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    public static void testGetChecklistInstancesForDesign() {
        SymphonyLF__Design__c designRecord = [SELECT Id FROM SymphonyLF__Design__c LIMIT 1];
        Test.startTest();
        List<ChecklistContainerController.InstanceWrapper> result = ChecklistContainerController.getCheckListInstances(designRecord.Id);
        //System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    public static void testGetChecklistInstancesForPatentWithLegalAssistant() {
        SymphonyLF__Patent__c patentRecord = [SELECT Id FROM SymphonyLF__Patent__c LIMIT 1];
        User legalAssistantUser = [SELECT Id FROM User WHERE LastName = 'legalAssistanttest' LIMIT 1];

        System.runAs(legalAssistantUser) {
            Test.startTest();
            List<ChecklistContainerController.InstanceWrapper> result = ChecklistContainerController.getCheckListInstances(patentRecord.Id);
            //System.assertNotEquals(null, result);
            Test.stopTest();
        }
    }

    @isTest
    public static void testGetChecklistInstancesForPatentWithParalegal() {
        SymphonyLF__Patent__c patentRecord = [SELECT Id FROM SymphonyLF__Patent__c LIMIT 1];
        User paralegalUser = [SELECT Id FROM User WHERE LastName = 'Paralegaltest' LIMIT 1];

        System.runAs(paralegalUser) {
            Test.startTest();
            List<ChecklistContainerController.InstanceWrapper> result = ChecklistContainerController.getCheckListInstances(patentRecord.Id);
            //System.assertNotEquals(null, result);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testPatent() {
        SymphonyLF__Country__c usaCountry = [Select Id from SymphonyLF__Country__c where Name = 'United States of America'];
        SymphonyLF__Client__c client = [Select Id from SymphonyLF__Client__c limit 1];
        SymphonyLF__Patent__c patentRec = new SymphonyLF__Patent__c(
            Name = 'test',
            SymphonyLF__Country__c = usaCountry.Id,
            SymphonyLF__Client__c = client.Id,
            SymphonyLF__Case_Type__c = 'Provisional'
        );
        Insert patentRec;
        SymphonyLF__Person__c legalAssistantPerson = [Select id from SymphonyLF__Person__c where SymphonyLF__Contact_Type__c = 'Legal Assistant'];
        SymphonyLF__Person__c paralegalPerson = [Select id from SymphonyLF__Person__c where SymphonyLF__Contact_Type__c = 'Paralegal'];
        List<SymphonyLF__Matter_Engagement_Model__c> memRecordsList = new List<SymphonyLF__Matter_Engagement_Model__c>();
         memRecordsList.add(new SymphonyLF__Matter_Engagement_Model__c(SymphonyLF__Type__c = 'Paralegal',SymphonyLF__Supervisor_Client_Contact__c = paralegalPerson.Id,  SymphonyLF__Client2__c = client.Id, SymphonyLF__Patent__c = patentRec.Id));
        memRecordsList.add(new SymphonyLF__Matter_Engagement_Model__c( SymphonyLF__Type__c = 'Legal Assistant',SymphonyLF__Supervisor_Client_Contact__c = legalAssistantPerson.Id,  SymphonyLF__Client2__c = client.Id, SymphonyLF__Patent__c = patentRec.Id));
		Insert memRecordsList;
        patentRec.SymphonyLF__Case_Type__c = 'Utility Original';
        Update patentRec;
        
    }
}