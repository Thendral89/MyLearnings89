global with sharing class MyTaskAdditionalFieldsPicklist extends VisualEditor.DynamicPickList {
    
    private static final String TASK_OBJECT_NAME = 'Task';

    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('--None--', 'none');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        return getAllFieldValues(TASK_OBJECT_NAME);
    }

    private static VisualEditor.DynamicPickListRows getAllFieldValues (String objectName) {
        VisualEditor.DynamicPickListRows  listValues = new VisualEditor.DynamicPickListRows();
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('--None--', 'none');
        listValues.addRow(defaultValue);

        Map<String, Schema.SObjectField> fieldsMap = MyTaskUtility.getFieldsByObjectName(objectName);
        for(Schema.SObjectField field : fieldsMap.values()) {

            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            if(fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                VisualEditor.DataRow listItem = new VisualEditor.DataRow((String)fieldDescribe.getLabel(), (String)fieldDescribe.getRelationshipName() + '.Name');
                listValues.addRow(listItem);
                System.debug('listValues----'+listItem);
            } else {
                VisualEditor.DataRow listItem = new VisualEditor.DataRow((String)fieldDescribe.getLabel(), (String)fieldDescribe.getName());
                listValues.addRow(listItem);
                System.debug('listValues----'+listItem);
            }
        }

        return listValues;
    }
}