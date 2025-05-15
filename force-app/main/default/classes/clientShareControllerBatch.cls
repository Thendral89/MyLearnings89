global without sharing class clientShareControllerBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Boolean isRemoveAccess; 
    private Id userIdParam;
    private Id clientId;
    private List<Access_Restriction__c> accessRecord;
    private Set<String> ExcludeStdRowCauses = new Set<String>{'Owner', 'Rule', 'ImplicitChild', 'ImplicitParent', 'Team', 'Territory', 'FullAccess'};
    private static final String TO_BE_GRANTED = 'To Be Granted';
    private static final String TO_BE_ENFORCED = 'To Be Enforced';

    global ClientShareControllerBatch(Boolean isRemoveAccess, Id userIdParam, Id clientId, List<Access_Restriction__c> accessRecord) {
        this.isRemoveAccess = isRemoveAccess;
        this.userIdParam = userIdParam;
        this.clientId = clientId;
        this.accessRecord = accessRecord;
    }


    global Iterable<SObject> start(Database.BatchableContext BC) {
        List<SObject> allRecords = new List<SObject>();

        for (ShareableObjects__mdt objMeta : ShareableObjects__mdt.getAll().values()) {
            system.debug(clientId);
            ID RecordId = Id.valueOf(clientId);
            Schema.SObjectType sobjectType = RecordId.getSObjectType();
             system.debug(string.valueof(sobjectType));
            system.debug(string.valueof(objMeta.Parent_Relationship_Path__c));
            system.debug(string.valueof(objMeta.isActive__c));
            system.debug(string.valueof(sobjectType) == objMeta.Type__c);
            system.debug(objMeta.Type__c);
            if (!String.isBlank(objMeta.Parent_Relationship_Path__c) && objMeta.isActive__c && string.valueof(sobjectType) == objMeta.Type__c) {
                String query = '';

                if (isRemoveAccess) {
                    query = 'SELECT Id FROM ' + objMeta.Share_Object_API_Name__c + 
                            ' WHERE Parent.' + objMeta.Parent_Relationship_Path__c + ' =:clientId ' + 
                            ' AND UserOrGroupId = :userIdParam' + 
                            ' AND RowCause NOT IN :ExcludeStdRowCauses';
                } else {
                    query = 'SELECT Id FROM ' + objMeta.Label + 
                            ' WHERE ' +  objMeta.Parent_Relationship_Path__c +' =:clientId';
                }

                System.debug('Executing Query: ' + query);
                
                try {
                    System.debug('Queried Rows' + objMeta.Share_Object_API_Name__c + ' BEFORE:::' + Limits.getLimitQueryRows());
                    
                    List<SObject> records = Database.query(query);
                    
                    System.debug('Queried Rows' + objMeta.Share_Object_API_Name__c + ' AFTER:::' + Limits.getLimitQueryRows());
                    allRecords.addAll(records);
                } catch (Exception e) {
                    System.debug('Query failed for: ' + objMeta.Share_Object_API_Name__c + ' Error: ' + e.getMessage());
                }
            }
        }
        return allRecords;
    }


    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('Processing clientShareControllerBatch:::' + scope.size() + ' records in batch.');

        if (isRemoveAccess) {
            removeAccess(scope);
        } else {
            grantAccess(scope);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job completed.here is the Access Record ' + accessRecord);
        List<Access_Restriction__c> deleteAccessRecords = new List<Access_Restriction__c>();
        List<Access_Restriction__c> accessRecords = new List<Access_Restriction__c>();
        for (Access_Restriction__c record : accessRecord) {
            System.debug('accessRecord' + accessRecord);
            if(record.Status__c == TO_BE_GRANTED){
                deleteAccessRecords.add(record);
            }
            else if(record.Status__c == TO_BE_ENFORCED){
                record.Status__c = 'Enforced';
                accessRecords.add(record);
            }
        }

        if (accessRecords.size() > 0) {
            update accessRecords;
        }
        if(deleteAccessRecords.size() > 0){
            delete deleteAccessRecords;
        }
        //TO be checked as we are already using future method from EmailMessage trigger.
        //sendConfirmationEmail(accessRecord);
    }

    private void grantAccess(List<SObject> scope) {
        List<SObject> shareRecords = new List<SObject>();

        for (SObject record : scope) {
            SObject shareRecord = createShareRecord(record.Id, userIdParam, 'Manual', 'Edit');
            if (shareRecord != null) {
                shareRecords.add(shareRecord);
            }
        }

        if (!shareRecords.isEmpty()) {
            try {
                insert shareRecords;
                System.debug('Inserted ' + shareRecords.size() + ' share records.');
            } catch (DmlException e) {
                System.debug('Error inserting share records: ' + e.getMessage());
            }
        }
    }

    private void removeAccess(List<SObject> scope) {
        if (!scope.isEmpty()) {
            try {
                delete scope;
                System.debug('Deleted ' + scope.size() + ' share records.');
            } catch (DmlException e) {
                System.debug('Error deleting share records: ' + e.getMessage());
            }
        }
    }

    private SObject createShareRecord(Id recordId, Id userIdParam, String rowCause, String accessLevel) {
        try {
            String parentObject = recordId.getSObjectType().getDescribe().getName();
            System.debug('parentObject' + parentObject);
            String shareObject = parentObject.replace('__c' , '__Share');
            System.debug('shareObject' + shareObject);
            Schema.SObjectType shareObjectType = Schema.getGlobalDescribe().get(shareObject);
            SObject shareRecord = shareObjectType.newSObject();
            shareRecord.put('ParentId', recordId);
            shareRecord.put('UserOrGroupId', userIdParam);
            shareRecord.put('RowCause', rowCause);
            shareRecord.put('AccessLevel', accessLevel);
            return shareRecord;
        } catch (Exception e) {
            System.debug('Error creating share record: ' + e.getMessage());
            return null;
        }
    }

    // TO BE UPDATED AS PER THE REQUIREMENT
    /*private void sendConfirmationEmail(List<Access_Restriction__c> accessRecord) {
        System.debug('Finished Send Confirmation Email' + accessRecord);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Access Restriction Update Confirmation');

        for (Access_Restriction__c record : accessRecord) {
            System.debug('Finished Send Confirmation Email record' + record);
            //FOR NOW IT WILL BE HARDCODED
            mail.setToAddresses(new String[] { 'pranav.g@maxval.com' });  
            //mail.setToAddresses(new String[] { record.CreatedBy.Email });  
            if(record.Status__c == TO_BE_GRANTED){
                mail.setPlainTextBody('The scheduled batch job for Access Restriction updates has been completed successfully and the CLIENT :' + record.Client__r.Name  + ' has been granted Access');
            }
            else if(record.Status__c == TO_BE_ENFORCED){
                mail.setPlainTextBody('The scheduled batch job for Access Restriction updates has been completed successfully and the CLIENT :' + record.Client__r.Name  + ' access has been Revoked');
            }
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }*/
}