public inherited sharing class MyTaskUtility {

    private static Map<String, Schema.SObjectType> globalDescribe;
    
    public static Map<String, Schema.SObjectField> getFieldsByObjectName(String objectName) {
        List<Object> fieldList = new List<Object>();
        Map<String, Schema.SObjectType> gd = getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectName);
        Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();
        return objectDescribe.fields.getMap();
    }

    public static List<Schema.FieldSetMember> getFieldSetMembersByObjectNameAndFieldSetName(String objectName, String fieldSetName) {
        Map<String, Schema.SObjectType> gd = getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectName);
        Schema.DescribeSObjectResult objectDescribe = sobjType.getDescribe();

        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();


        if (fieldSetMap != null && fieldSetMap.containsKey(fieldSetName)) {
            return fieldSetMap.get(fieldSetName).getFields();
        }
        return null;
    }

    private static Map<String,Schema.SObjectType> getGlobalDescribe() {
        if(globalDescribe == null) {
            globalDescribe = Schema.getGlobalDescribe();
        }

        return globalDescribe;
    }


}