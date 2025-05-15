@isTest
public class CL_ChecklistControllerTest {
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
        Object configData = CL_ChecklistController.getCheckListConfigData(checklistInstance.Id);
        Map<String, Object> deserializedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configData));
        Test.stopTest();
        Assert.IsTrue(Boolean.ValueOf(deserializedMap.get('isSuccess')), 'The config data should be successful.');
    }

    @isTest
    static void testGetCheckListConfigDataWithError() {
        Test.startTest();
        Object configData = CL_ChecklistController.getCheckListConfigData('12345');
        Map<String, Object> deserializedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configData));
        Test.stopTest();
        Assert.IsFalse(Boolean.ValueOf(deserializedMap.get('isSuccess')), 'The config data should be failed.');
    }

    @isTest
    static void testGetSectionList() {
        Checklist_Instance__c checklistInstance = [SELECT Id FROM Checklist_Instance__c LIMIT 1];
        Test.startTest();
        Object configData = CL_ChecklistController.getSectionList(checklistInstance.Id);
        Map<String, Object> deserializedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configData));
        Test.stopTest();
        Assert.IsTrue(Boolean.ValueOf(deserializedMap.get('isSuccess')), 'The config data should be successful.');
    }

    @isTest
    static void testGetSectionListWithError() {
        Test.startTest();
        Object configData = CL_ChecklistController.getSectionList('12345');
        Map<String, Object> deserializedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configData));
        Test.stopTest();
        Assert.IsFalse(Boolean.ValueOf(deserializedMap.get('isSuccess')), 'The config data should be failed.');
    }

    @isTest
    static void testGetSubSectionList() {
        Checklist_Instance__c checklistInstance = [SELECT Id FROM Checklist_Instance__c LIMIT 1];
        Checklist_Section__c section = [SELECT Id FROM Checklist_Section__c WHERE Name = 'Parent Section' LIMIT 1];
        Test.startTest();
        Object configData = CL_ChecklistController.getSubSectionList(checklistInstance.Id, section.Id);
        Map<String, Object> deserializedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configData));
        Test.stopTest();
        Assert.IsTrue(Boolean.ValueOf(deserializedMap.get('isSuccess')), 'The config data should be successful.');
    }
}