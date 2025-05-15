public inherited sharing class CL_ChecklistService {
    private String CHECKLIST_INSTANCE_ITEM_OBJECT_NAME = 'Checklist_Instance_Item__c';
    private Map <String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    private Id currentUserId = UserInfo.getUserId();
    private static CL_ChecklistService serviceInstance;
    public static CL_ChecklistService instance() {
        if(serviceInstance == null) {
            serviceInstance = new CL_ChecklistService();
        }

        return serviceInstance;
    }
    
    public object getCheckListConfigData(String checklistInstanceId){
        return new Map<String, Object> {
            'checklistInstance' => getChecklistInstance(checklistInstanceId)
        };
    }

    public object getSectionList(String checklistInstanceId){
        Map<string, Object> responseMap = new Map<String, Object>();

        Map<String, Object> checklistInstanceRec = getChecklistInstance(checklistInstanceId);
        responseMap.put('sectionList', getSectionListHelper((String)checklistInstanceRec.get('checklistId')));
        
        return responseMap;
    }

    public object getSubSectionList(String checklistInstanceId, String parentSectionId){
        return new Map<String, Object> {
            'subSectionList' => getSubSectionListHelper(checklistInstanceId, parentSectionId)
        };
    }

    private Map<String, Object> getChecklistInstance(String recordId) {
        return buildChecklistInstanceData([SELECT Status__c, Checklist__c, Checklist__r.Name, Secretary_Completed__c, Attorney_Completed__c, Double_Checker_Completed__c, Double_Checker_Notes__c, Secretary__c, Attorney__c, Double_Checker__c, Patent__c, Design__c, Name, Id FROM Checklist_Instance__c WHERE Id =: recordId]);
    }

    private Map<String, Object> buildChecklistInstanceData(Checklist_Instance__c checklistInstance) {
        return new Map<String, Object> {
            'id' => checklistInstance.Id,
            'status' => checklistInstance.Status__c,
            'secretaryCompleted' => checklistInstance.Secretary_Completed__c,
            'checklistId' => checklistInstance.Checklist__c,
            'attorneyCompleted' => checklistInstance.Attorney_Completed__c,
            'doubleCheckerCompleted' => checklistInstance.Double_Checker_Completed__c,
            'secretaryId' => checklistInstance.Secretary__c,
            'attorneyId' => checklistInstance.Attorney__c,
            'doubleCheckerId' => checklistInstance.Double_Checker__c,
            'patentId' => checklistInstance.Patent__c,
            'designId' => checklistInstance.Design__c,
            'formName' => checklistInstance.Checklist__r.Name,
            'isSecretary' => currentUserId == checklistInstance.Secretary__c,
            'isAttorney' => currentUserId == checklistInstance.Attorney__c,
            'isDoubleChecker' => currentUserId == checklistInstance.Double_Checker__c,
            'doubleCheckerNotes' => checklistInstance.Double_Checker_Notes__c
        };
    } 

    private Object getSubsectionListHelper(String checklistInstanceId, String parentSectionId) {
        Set<String> fieldList = getAllChecklistInstanceFields();

        String query = '';
        query += 'SELECT ';
        query += ' Id, Name, Section_Type__c, Submit_By_Attorney__c, Submit_By_Double_Checker__c, Submit_By_Secretory__c, Icon_Name__c, Section_Notes__c, ';
        query += '( ';
        query += 'SELECT ';
        query += ' Checklist_Item__r.Display_Text__c, Checklist_Item__r.Dynamic_Fields__c, Checklist_Item__r.Help_Text__c, ';
        query += String.join(fieldList, ', ');
        query += ' FROM Checklist_Instance_Items__r ';
        query += ' WHERE Checklist_Instance__c =:checklistInstanceId ';
        query += ' ORDER BY Checklist_Item__r.Order__c NULLS LAST ';
        query += ' ) ';
        query += ' FROM Checklist_Section__c ';
        query += ' WHERE Parent_Section__c =: parentSectionId ';
        query += ' ORDER BY Order__c NULLS LAST ';
        query += ' LIMIT 10000 ';

        return buildSubSectionData(Database.query(query));
    }

    private Object buildSubSectionData(List<Checklist_Section__c> sectionList) {
        List<Object> objectList = new List<Object>();

        for(Checklist_Section__c section: sectionList) {
            objectList.add(new Map<String, Object> {
                'id' => section.Id,
                'label' => section.Name,
                'type' => section.Section_Type__c,
                'iconName' => section.Icon_Name__c,
                'submitByAttorney' => section.Submit_By_Attorney__c,
                'submitByDoubleChecker' => section.Submit_By_Double_Checker__c,
                'submitBySecretory' => section.Submit_By_Secretory__c,
                'sectionNotes' => section.Section_Notes__c,
                'itemList' => buildItemList(section.Checklist_Instance_Items__r)
            });
        }

        return objectList;
    }

    private Object buildItemList(List<Checklist_Instance_Item__c> instanceItemList) {
        List<Object> objectList = new List<Object>();

        for(Checklist_Instance_Item__c instanceItem: instanceItemList) {
            objectList.add(new Map<String, Object> {
                'id' => instanceItem.Id,
                'displayText' => instanceItem.Checklist_Item__r.Display_Text__c,
                'helpText' => instanceItem.Checklist_Item__r.Help_Text__c,
                'dynamicFields' => instanceItem.Checklist_Item__r.Dynamic_Fields__c != null ? buildDynamicFieldMapping(instanceItem) : new List<String>(),
                'secretoryCompleted' => instanceItem.Secretary_Completed__c,
                'attorneyCompleted' => instanceItem.Attorney_Completed__c,
                'doubleCheckerCompleted' => instanceItem.Double_Checker_Completed__c
            });
        }

        return objectList;
    }

    private Object getSectionListHelper(String checklistId) {
        return buildSectionData([SELECT Id, Name, Checklist__c FROM Checklist_Section__c WHERE Checklist__c =: checklistId AND Parent_Section__c = null ORDER BY Order__c NULLS LAST LIMIT 10000]);
    }

    private Object buildSectionData(List<Checklist_Section__c> sectionList) {
        List<Object> objectList = new List<Object>();

        for(Checklist_Section__c section: sectionList) {
            objectList.add(new Map<String, Object> {
                'id' => section.Id,
                'label' => section.Name,
                'checklistId' => section.Checklist__c
            });
        }

        return objectList;
    }

    private Object buildDynamicFieldMapping(Checklist_Instance_Item__c instanceItem) {
        List<Object> objectList = new List<Object>();

        sObject sObjRec = instanceItem;
        for(String str: instanceItem.Checklist_Item__r.Dynamic_Fields__c.split(',')) {
            Schema.DescribeFieldResult fieldDescribe = getTypeByApiName(str.trim());
            objectList.add(new Map<String, Object> {
                'apiName' => str.trim(),
                'type' => String.valueOf(fieldDescribe.getType()),
                'helpText' => fieldDescribe.getInlineHelpText(),
                'value' => fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST ? getValuesList(sObjRec.get(str.trim())) : sObjRec.get(str.trim()),
                'label' => fieldDescribe.getLabel(),
                'options' => fieldDescribe.getType() == Schema.DisplayType.PICKLIST || fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST ? buildPicklistOptions(fieldDescribe.getPicklistValues()) : null,
                'maxLength' => fieldDescribe.getLength()
            });
        }

        return objectList;
    }

    private Schema.DescribeFieldResult getTypeByApiName(String fieldApiName) {
        Map<String, Schema.SObjectField> fieldsMap = getAllFieldsByObjectName(CHECKLIST_INSTANCE_ITEM_OBJECT_NAME);
        Schema.SObjectField field = fieldsMap.get(fieldApiName);
        return field.getDescribe();
    }

    private Set<String> getAllChecklistInstanceFields() {
        return  getAllFieldsByObjectName(CHECKLIST_INSTANCE_ITEM_OBJECT_NAME).keyset(); 
    }

    private Map<String, Schema.SObjectField> getAllFieldsByObjectName(String objectName) {
        Schema.SObjectType sobjType = globalDescribe.get(objectName);
        Schema.DescribeSObjectResult sObjectResultDescribe = sobjType.getDescribe();
        return sObjectResultDescribe.fields.getMap();
    }

    private Object buildPicklistOptions(List<Schema.PicklistEntry> picklistEntryList) {
        List<Object> objectList = new List<Object>();

        for(Schema.PicklistEntry entry: picklistEntryList) {
            objectList.add(new Map<String, Object> {
                'label' => entry.getLabel(),
                'value' => entry.getValue()
            });
        }

        return objectList;
    }

    private Object getValuesList(Object value) {
        if(value == null) return new List<String>();

        return ((String)value).split(';');
    }
    
}