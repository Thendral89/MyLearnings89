public with sharing class FieldSetController {
    @AuraEnabled(cacheable = true)
    public static List<AccordionFieldSet> getFieldSetDataAccordion(String objectName, String fieldSetsName, String recordId){
        List<AccordionFieldSet> output = new List<AccordionFieldSet>();

        Schema.DescribeSObjectResult DescribeSObjectResultObj = ( (sObject) Type.forname( objectName ).newInstance() ).getSobjectType().getDescribe();

        List<String> fieldSetList = fieldSetsName.split(';');

        Boolean hasRecordEditAccess = hasRecordEditAccess(recordId);
        Boolean hasObjectEditAccess = DescribeSObjectResultObj.isUpdateable();
        Map<String, Schema.SObjectField> fieldsMap = DescribeSObjectResultObj.fields.getMap();

        for(String fieldSetName : fieldSetList){
            Schema.FieldSet fieldSet = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

            if(
                fieldSet == null
                ||
                fieldSet.getFields().isEmpty()
            ){
                throw new AuraHandledException('The provided field set is not valid');
            }
    
            AccordionFieldSet smallOut = new AccordionFieldSet();
            List<FieldData> fieldSetData = new List<FieldData>();

            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                Boolean isFieldUpdateable = fieldsMap.get( field.getFieldPath() ).getDescribe().isUpdateable();

                FieldData fieldData = new FieldData();
                fieldData.label = field.getLabel();
                fieldData.fieldApiName = field.getFieldPath();
                fieldData.isEditable = field.getRequired() && hasRecordEditAccess && hasObjectEditAccess && isFieldUpdateable;
                fieldData.editMode = false;
                fieldSetData.add(fieldData);
            }

            smallOut.accordionLabel = fieldSet.getLabel();
            smallOut.accordionName = fieldSetName;
            smallOut.fieldSetData = fieldSetData;

            output.add(smallOut);
        }

        return output;
    }

    private static Boolean hasRecordEditAccess(Id recordId){
        Boolean hasEditAccess = false;
        UserRecordAccess userRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =: recordId];
        hasEditAccess = userRecordAccess.HasEditAccess;

        return hasEditAccess;
    }

    @AuraEnabled(cacheable=true)
    public static Response getFieldSetData(String objectName, String fieldSetName, Id recordId) {
        Response output = new Response();
        if(
            String.isBlank( objectName )
            ||
            String.isBlank( fieldSetName )
            ||
            String.isBlank( recordId )
        ){
            throw new AuraHandledException('Required attributes like objectName, fieldSetName, or recordId are null');
        }

        List<FieldData> fieldSetData = new List<FieldData>();
        output.fieldSetData = fieldSetData;

        Schema.DescribeSObjectResult DescribeSObjectResultObj = ( (sObject) Type.forname( objectName ).newInstance() ).getSobjectType().getDescribe();

        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

        Schema.FieldSet fieldSet = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        if(
            fieldSet == null
            ||
            fieldSet.getFields().isEmpty()
        ){
            throw new AuraHandledException('The provided field set is not valid');
        }

        output.objectLabel = DescribeSObjectResultObj.getLabel();
    //    output.logoUrl = DescribeSObjectResultObj.getThemeInfo().getIconUrl();

        // Build the SOQL query dynamically
        Set<String> fieldPaths = new Set<String>();
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            fieldPaths.add(field.getFieldPath());
        }
        fieldPaths.add('Name');

        if( objectToDocketNumber.containsKey( objectName ) ){
            fieldPaths.add( objectToDocketNumber.get( objectName ) );
        }

        if( objectToNameField.containsKey( objectName ) ){
            fieldPaths.add( objectToNameField.get( objectName ) );
        }

        System.debug('fieldPaths ' + fieldPaths);

        String query = 'SELECT ' + String.join(fieldPaths, ',') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
        SObject record = Database.query(query);

        Boolean hasRecordEditAccess = hasRecordEditAccess(recordId);
        Boolean hasObjectEditAccess = DescribeSObjectResultObj.isUpdateable();

        Map<String, Schema.SObjectField> fieldsMap = DescribeSObjectResultObj.fields.getMap();

        // Build the field set data
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            Boolean isFieldUpdateable = fieldsMap.get( field.getFieldPath() ).getDescribe().isUpdateable();
            FieldData fieldData = new FieldData();
            fieldData.label = field.getLabel();
            fieldData.fieldApiName = field.getFieldPath();
            fieldData.value = record.get(field.getFieldPath());
            fieldData.isEditable = field.getRequired() && hasRecordEditAccess && hasObjectEditAccess && isFieldUpdateable;
            fieldData.editMode = false;
            fieldSetData.add(fieldData);
        }
/*
        if(objectName == 'SymphonyLF__Client__c' && fieldSetName == 'HIGHLIGHTSPANEL' && recordId == 'a0TWr000007QKlRMAW'){
            FieldData fieldData = new FieldData();
            fieldData.label = 'Biswajit Address Testing';
            fieldData.fieldApiName = 'SymphonyLF__Address__c';
           // fieldData.value = record.get(field.getFieldPath());
            fieldData.isEditable = true;
            fieldData.editMode = false;
            fieldSetData.add(fieldData);
        }*/

        output.recordName = String.valueOf( objectToNameField.containsKey( objectName) ? record.get( objectToNameField.get( objectName ) )  : record.get('Name')  );

        if(objectToDocketNumber.containsKey( objectName ) ){
            String docketNumber = String.valueOf( record.get( objectToDocketNumber.get( objectName ) ) );
            if( String.isNotBlank( docketNumber ) ){
                output.docketNumber = docketNumber;
            }
        }

        return output;
    }

    public static Map<String, String> objectToDocketNumber = new Map<String, String>{
        'SymphonyLF__Client__c' => 'SymphonyLF__Client_Number_New__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Patent__c'=> 'SymphonyLF__Docket_Number__c'
    };

    public static Map<String, String> objectToNameField = new Map<String, String>{
        'SymphonyLF__Patent__c'=> 'SymphonyLF__Title__c'
    };

    public class AccordionFieldSet{
        @AuraEnabled public List<FieldData> fieldSetData;
        @AuraEnabled public String accordionLabel;
        @AuraEnabled public String accordionName;
    }

    public class Response{
        @AuraEnabled public List<FieldData> fieldSetData;
        @AuraEnabled public String recordName;
        @AuraEnabled public String docketNumber;
        @AuraEnabled public String objectLabel;
        @AuraEnabled public String logoUrl;
    }

    public class FieldData{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public Object value;
        @AuraEnabled public Boolean isEditable = false;
        @AuraEnabled public Boolean editMode = false;
    }


    public static Map<String, String> objectToLookupFieldForKeyword = new Map<String, String>{
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Trademark__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c'
    };
}