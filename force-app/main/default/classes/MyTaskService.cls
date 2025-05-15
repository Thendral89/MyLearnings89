public inherited sharing class MyTaskService {

    public static Object getViewsData() {
        List<Object> responseList = new List<Object>();

        for(String panel: MyTaskConstants.getHighlightedPanelMap().keyset()) {
            responseList.add(new Map<String, String> {
                'label' => MyTaskConstants.getHighlightedPanelByKey(panel),
                'value' => panel
            });
        }

        return responseList;
    }

    public static Object getTaskData(List<String> additionalFieldList, String filterVal, String selectedView, String sortBy, String sortDirection){
        return Database.query(buildQuery(additionalFieldList, filterVal, selectedView, sortBy, sortDirection));
    }

    public static Object getAdditionalFieldsLabel(String additionalFieldOne, String additionalFieldTwo){
        Map<String, String> responseMap = new Map<String, String>();
        Map<String, Schema.SObjectField> apiNameVsFieldMap = MyTaskUtility.getFieldsByObjectName(MyTaskConstants.TASK_OBJECT_NAME);

        if(additionalFieldOne != null && String.isNotBlank(additionalFieldOne) && additionalFieldOne != 'none') {
            Schema.DescribeFieldResult fieldDescribe = apiNameVsFieldMap.get(additionalFieldOne).getDescribe();
            responseMap.put(additionalFieldOne, fieldDescribe.getLabel());
        }

        if(additionalFieldTwo != null && String.isNotBlank(additionalFieldTwo) && additionalFieldTwo != 'none') {
            Schema.DescribeFieldResult fieldDescribe = apiNameVsFieldMap.get(additionalFieldTwo).getDescribe();
            responseMap.put(additionalFieldTwo, fieldDescribe.getLabel());
        }

        return responseMap;
    }

    public static void saveTaskData(List<Task> taskList) {
        update taskList;
    }

    public static void deleteTaskRecords(List<String> taskIds) {
        Database.delete(taskIds, true);
    }

    public static Object getPanelInfo(String panelKey, String filterVal){
        Map<String, Object> responseMap = new Map<String, Object> {
            'label' => MyTaskConstants.getHighlightedPanelByKey(panelKey),
            'count' => Database.countQuery(buildCountQuery(panelKey, filterVal))
        };

        return responseMap;
    }

    public static Object getTaskFieldsData() {
        List<Object> responseList = new List<Object>();

        Map<String, Schema.SObjectField> apiNameVsFieldMap = MyTaskUtility.getFieldsByObjectName(MyTaskConstants.TASK_OBJECT_NAME);

        for(String field: MyTaskConstants.getFilterFields()) {
            Schema.DescribeFieldResult fieldDescribe = apiNameVsFieldMap.get(field).getDescribe();

            if(fieldDescribe.isFilterable()) {
                Map<String, Object> fieldMap = new Map<String, Object> {
                    'label' => fieldDescribe.getLabel(),
                    'value' => fieldDescribe.getName(),
                    'dataType' => fieldDescribe.getType().name()
                };

                if(!fieldDescribe.isNamePointing() && fieldDescribe.getType() == Schema.DisplayType.REFERENCE ) {
                    fieldMap.put('referenceTo', fieldDescribe.getReferenceTo()[0].getDescribe().getName());
                } else if(fieldDescribe.getType() == Schema.DisplayType.PICKLIST || fieldDescribe.getType() == Schema.DisplayType.COMBOBOX) {
                    List<Object> pickListEntryList = new List<Object>();
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        pickListEntryList.add(new Map<String, String> {
                            'label' => entry.getLabel(),
                            'value' => entry.getValue()
                        });
                    }

                    fieldMap.put('picklistValues', pickListEntryList);
                }

                responseList.add(fieldMap);
            }
        }

        return responseList;

    }

    public static Object getPopoverData(String recordId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();

        List<Schema.FieldSetMember> fieldSetMemberList = MyTaskUtility.getFieldSetMembersByObjectNameAndFieldSetName(sObjName, MyTaskConstants.MY_TASK_FIELD_SET_NAME);

        if(fieldSetMemberList != null) {
            List<Object> fieldList = new List<Object>();
            for(Schema.FieldSetMember field: fieldSetMemberList) {
                fieldList.add(new Map<String, String> {
                    'label' => field.getLabel(),
                    'apiName' => field.getFieldPath()
                });
            }
            responseMap.put('fieldList', fieldList);
        }

        responseMap.put('objectName', sObjName);
        
        return responseMap;
    }

    private static String buildCountQuery(String panelKey, String filterVal) {
        String query = '';

        query += 'SELECT ';
        query += ' Count()';
        query += ' FROM';
        query += ' Task';

        if(panelKey != null && String.isNotBlank(panelKey)) {
            query += ' WHERE ';
            query += MyTaskConstants.getStaticQueryFilterByKey(panelKey);

            if(filterVal != null && String.isNotBlank(filterVal)) {
                query += ' AND ';
                query += filterVal;
            }
        }

        return query;
    }

    private static String buildQuery(List<String> additionalFieldList, String filterVal, String selectedView, String sortBy, String sortDirection) {
        Set<String> selectedFields = MyTaskConstants.getQueryFields();
        for(String str: additionalFieldList) {
            if(String.isNotBlank(str)) {
                selectedFields.add(str);
            }
        }
        String query = '';

        query += 'SELECT ';
        query += String.join(selectedFields, ',');
        query += ' FROM';
        query += ' Task';

        String filterString = buildFilters(filterVal, selectedView);

        if(String.isNotBlank(filterString)) {
            query += ' WHERE ';
            query += filterString;
        }

        if(sortBy != null && String.isNotBlank(sortBy)) {
            query += ' ORDER BY ';
            query += sortBy;
            query += ' ';
            query += sortDirection;
        }

        query += ' LIMIT 50000 ';
        
        return query;
    }

    private static String buildFilters(String filterVal, String selectedView) {
        String filter = '';

        filter += MyTaskConstants.getStaticQueryFilterByKey(selectedView);
        if(filterVal != null && String.isNotBlank(filterVal)) {
            filter += ' AND ';
            filter += filterVal;
        }

        return filter;
    }
}