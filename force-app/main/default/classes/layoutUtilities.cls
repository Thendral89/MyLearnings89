public with sharing class layoutUtilities {

    @AuraEnabled(cacheable=true)
    public static Response getFieldSetData(String objectName, String fieldSetName, Id recordId, String headerField, String subHeaderField) {
        Response output = new Response();
        try{
       
        if(
            String.isBlank( objectName )
            ||
            String.isBlank( fieldSetName )
            ||
            String.isBlank( recordId )
        ){
            throw new AuraHandledException('Please ensure the required attributes like Object Name or Field Set Name and recordId are null');
        }


        List<FieldData> fieldSetData = new List<FieldData>();
        output.fieldSetData = fieldSetData;

        Schema.DescribeSObjectResult DescribeSObjectResultObj = ( (sObject) Type.forname( objectName ).newInstance() ).getSobjectType().getDescribe();

        Schema.FieldSet fieldSet = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        if(
            fieldSet == null
            ||
            fieldSet.getFields().isEmpty()
        ){
            throw new AuraHandledException('Please ensure that the field set is properly configured.');
        }


        output.objectLabel = DescribeSObjectResultObj.getLabel();

        // Build the SOQL query dynamically
        Set<String> fieldPaths = new Set<String>();
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            if(field.getFieldPath() <> 'Name')
              fieldPaths.add(field.getFieldPath());
        }
        // fieldPaths.add('Name');

        String joinedFields = String.join(fieldPaths, ',');
        System.debug(joinedFields);
        System.debug(headerField);
        System.debug(subHeaderField);
        String query = 'SELECT ';
        if (!String.join(fieldPaths, ',').contains(headerField) || headerField == 'Name')
           query+=  headerField + ',';
        
        if (!String.join(fieldPaths, ',').contains(subHeaderField) || subHeaderField == 'Name')
           query+=  subHeaderField + ',';

        query+= String.join(fieldPaths, ',') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
        System.debug(query);
        SObject record = Database.query(query);

        Boolean hasRecordEditAccess = hasRecordEditAccess(recordId);

        Boolean hasObjectEditAccess = DescribeSObjectResultObj.isUpdateable();

        output.headerValue = String.valueOf( record.get(headerField) );
        output.subHeaderValue = String.valueOf( record.get(subHeaderField));

        Map<String, Schema.SObjectField> fieldsMap = DescribeSObjectResultObj.fields.getMap();

        // Build the field set data
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            Boolean isFieldUpdateable = fieldsMap.get( field.getFieldPath() ).getDescribe().isUpdateable();
            FieldData fieldData = new FieldData();
            fieldData.label = field.getLabel();
            fieldData.fieldApiName = field.getFieldPath();
            String getpath = field.getFieldPath();
            fieldData.value = record.get(getpath);
            fieldData.isEditable = field.getRequired() && hasRecordEditAccess && hasObjectEditAccess && isFieldUpdateable;
            fieldData.editMode = false;
            fieldSetData.add(fieldData);
        }

        if(recordId != null && recordId.getSObjectType() == Conflict_Check__c.SObjectType){
            Conflict_Check__c ccRec = [SELECT 
                                           Id, 
                                           Logged_in_User_is_Creator__c, 
                                           Logged_in_User_is_Originating_Attorney__c 
                                       FROM 
                                       		Conflict_Check__c 
                                       WHERE 
                                       		id=:recordId];
            if(ccRec.Logged_in_User_is_Originating_Attorney__c == false && ccRec.Logged_in_User_is_Creator__c == false){
                output.showTaskButtons = true;
            }else{
                output.showTaskButtons = false;
            }
        }
        System.debug(output);
        
    }catch(Exception ex){
        system.debug('Error : '+ex.getMessage()+' line no.'+ex.getLineNumber());
    }
    return output;
    }

    private static Boolean hasRecordEditAccess(Id recordId){
        Boolean hasEditAccess = false;
        UserRecordAccess userRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =: recordId];
        hasEditAccess = userRecordAccess.HasEditAccess;

        return hasEditAccess;
    }

    public static List<Keyword> keywords(String objectName, Id recordId){

        Set<String> fields = new Set<String>{
            'Id',
            'SymphonyLF__Keyword__c',
            'SymphonyLF__Keyword__r.Name'
        };

        String query = ' SELECT ' + String.join( fields, ', ' ) +
            '   FROM SymphonyLF__Keyword_Association__c ' +
            '   WHERE ' + objectName + ' = :recordId AND SymphonyLF__Keyword__c != null' +
            '   ORDER BY SymphonyLF__Keyword__r.Name';

        SObject[] records = Database.query( query );

        List<Keyword> kws = new List<Keyword>();

        for(SObject r : records){
            Keyword k = new Keyword();
            k.keywordName = String.valueOf( r.getSObject('SymphonyLF__Keyword__r').get('Name') );
            k.associationId = String.valueOf( r.get('Id') );
            k.keywordId = String.valueOf( r.get('SymphonyLF__Keyword__c') );
            kws.add(k);
        }
        return kws;
    }

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

    public class FieldData{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public Object value;
        @AuraEnabled public Boolean isEditable = false;
        @AuraEnabled public Boolean editMode = false;
    }

    public class Response{
        @AuraEnabled public String objectLabel;
        @AuraEnabled public String logoUrl;
        @AuraEnabled public String headerValue;
        @AuraEnabled public String subHeaderValue;
        @AuraEnabled public List<FieldData> fieldSetData;
        @AuraEnabled public Boolean showTaskButtons;
    }

    public class Keyword{
        @AuraEnabled public String keywordName;
        @AuraEnabled public Id associationId;
        @AuraEnabled public Id keywordId;
    }

    public class AccordionFieldSet{
        @AuraEnabled public List<FieldData> fieldSetData;
        @AuraEnabled public String accordionLabel;
        @AuraEnabled public String accordionName;
    }

}