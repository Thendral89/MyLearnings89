@isTest
public class CL_ChecklistServiceTest {
    @testSetup
    static void setupData() {
        Checklist__c checklist = new Checklist__c (
            Name = 'Test Checklist', 
            Checklist_Code__c = 'Test Checklist Code');
        INSERT checklist;

        Checklist_Instance__c checklistInstance = new Checklist_Instance__c (
            Checklist__c = checklist.Id,
            Status__c = 'Initial Assignment Checklist In Progress'
        );
        INSERT checklistInstance;

        Checklist_Section__c PatenSection = new Checklist_Section__c (
            Name = 'Parent Section',
            Checklist__c = checklist.Id
        );
        INSERT PatenSection;

        Checklist_Section__c childSection = new Checklist_Section__c (
            Name = 'Child Section',
            Checklist__c = checklist.Id,
            Parent_Section__c = PatenSection.Id
        );
        INSERT childSection;

        Checklist_Item__c checkListItem = new Checklist_Item__c (
            Checklist__c = checklist.Id,
            Checklist_Section__c = childSection.Id,
            Display_Text__c = 'Sample Display Text',
            Dynamic_Fields__c = 'Disclosure_date__c',
            Help_Text__c = 'Sample Help Text'
        );
        INSERT checkListItem;

        Checklist_Instance_Item__c instanceItem = new Checklist_Instance_Item__c (
            Checklist_Instance__c = checklistInstance.Id,
            Secretary_Completed__c = false,
            Checklist_Section__c = childSection.Id,
            Checklist_Item__c = checkListItem.Id
        );
        INSERT instanceItem;
    }

    @isTest
    static void testGetCheckListConfigData() {
        Checklist_Instance__c checklistInstance = [SELECT Id FROM Checklist_Instance__c LIMIT 1];
        Test.startTest();
        CL_ChecklistService service = CL_ChecklistService.instance();
        Object configData = service.getCheckListConfigData(checklistInstance.Id);
        Test.stopTest();
        Assert.IsNotNull(configData, 'The config data should not be null.');
    }

    @isTest
    static void testGetSectionList() {
        Checklist_Instance__c checklistInstance = [SELECT Id FROM Checklist_Instance__c LIMIT 1];
        Test.startTest();
        CL_ChecklistService service = CL_ChecklistService.instance();
        Object sectionList = service.getSectionList(checklistInstance.Id);
        Test.stopTest();
        Assert.IsNotNull(sectionList, 'The section list should not be null.');
    }

    @isTest
    static void testGetSubSectionList() {
        Checklist_Instance__c checklistInstance = [SELECT Id FROM Checklist_Instance__c LIMIT 1];
        Checklist_Section__c section = [SELECT Id FROM Checklist_Section__c WHERE Name = 'Parent Section' LIMIT 1];
        Test.startTest();
        CL_ChecklistService service = CL_ChecklistService.instance();
        Object subSectionList = service.getSubSectionList(checklistInstance.Id, section.Id);
        Test.stopTest();
        Assert.IsNotNull(subSectionList, 'The subsection list should not be null.');
    }
}