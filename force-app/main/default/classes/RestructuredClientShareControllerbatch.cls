/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class RestructuredClientShareControllerbatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<Access_Restriction__c> accessRestrictions;
    private Map<String, Access_Restriction__c> accessRecordMap = new Map<String, Access_Restriction__c>();
    private Map<Id, Id> grantAccess = new Map<Id, Id>();
    private Map<Id, Id> removeAccess = new Map<Id, Id>();
    private ShareableObjects__mdt currentMetadata;
    List<ShareableObjects__mdt> metadataList;
    private Integer currentIndex;
    private Set<String> ExcludeStdRowCauses = new Set<String>{'Owner', 'Rule', 'ImplicitChild', 'ImplicitParent', 'Team', 'Territory', 'FullAccess'};

    private static final String TO_BE_GRANTED = 'To Be Granted';
    private static final String TO_BE_ENFORCED = 'To Be Enforced';

    global RestructuredClientShareControllerbatch(List<Access_Restriction__c> accessRestrictions , Integer currentIndex) {
        this.accessRestrictions = accessRestrictions;
        this.currentIndex = currentIndex;

        for (Access_Restriction__c record : accessRestrictions) {
            if (record.Person__r?.SymphonyLF__User__c != null) {

                Id userId = record.Person__r.SymphonyLF__User__c;
                Id clientId = record.Client__c;
                String key = userId + '_' + clientId;
                accessRecordMap.put(key, record);
                if (record.Status__c == TO_BE_GRANTED) {
                    grantAccess.put(userId, clientId);
                } else if (record.Status__c == TO_BE_ENFORCED) {
                    removeAccess.put(userId, clientId);
                }
                System.debug(record.Lookup_Fields__c);
                //Process if single record or All
                if(record.Lookup_Fields__c == Null){    
                    metadataList = [SELECT Label, Share_Object_API_Name__c, Parent_Relationship_Path__c
                                    FROM ShareableObjects__mdt
                                    WHERE isActive__c = true
                                    AND Parent_Relationship_Path__c <> Null
                                    ORDER BY Label];   

                }else{
                    metadataList = [SELECT Label, Share_Object_API_Name__c, Parent_Relationship_Path__c
                                    FROM ShareableObjects__mdt
                                    WHERE isActive__c = true
                                    AND Parent_Relationship_Path__c <> Null
                                    AND Label =: record.ObjectName__c
                                    ORDER BY Label];   
                }
                System.debug('metadataList:::' + metadataList.size());
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> clientIds = new Set<Id>();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();

        for (Access_Restriction__c ar : accessRestrictions) {
            if (ar.Lookup_Fields__c == Null) clientIds.add(ar.Client__c);
            if (ar.Lookup_Fields__c != null) recordIds.add(ar.Lookup_Fields__c);
            if (ar.Person__r.SymphonyLF__User__c <> Null) userIds.add(ar.Person__r.SymphonyLF__User__c); 
        }

        if (!metadataList.isEmpty()) {
            currentMetadata = metadataList[currentIndex];
            String objectLabel = currentMetadata.Label;
            String shareObject = currentMetadata.Share_Object_API_Name__c;
            String relationshipField = currentMetadata.Parent_Relationship_Path__c;

            String query = '';

            // --- Revoke Access ---
            if (!removeAccess.isEmpty()) {
                if (!recordIds.isEmpty()) {
                    query = 'SELECT Id FROM ' + shareObject +
                            ' WHERE ParentId IN :recordIds ' +
                            ' AND UserOrGroupId = :userIds' + 
                            ' AND RowCause NOT IN :ExcludeStdRowCauses';
                    System.debug('REMOVE access by record: ' + query);
                } else if (!clientIds.isEmpty()) {
                    query = 'SELECT Id FROM ' + shareObject +
                            ' WHERE Parent.' + relationshipField + ' IN :clientIds ' +
                            ' AND UserOrGroupId = :userIds' + 
                            ' AND RowCause NOT IN :ExcludeStdRowCauses';
                    System.debug('REMOVE access by client: ' + query);
                }
            }

            // --- Grant Access ---
            else if (!grantAccess.isEmpty()) {
                if (!recordIds.isEmpty()) {
                    query = 'SELECT Id FROM ' + objectLabel + ' WHERE Id IN :recordIds';
                    System.debug('GRANT access by record: ' + query);
                } else if (!clientIds.isEmpty()) {
                    query = 'SELECT Id FROM ' + objectLabel +
                            ' WHERE ' + relationshipField + ' IN :clientIds';
                    System.debug('GRANT access by client: ' + query);
                }
            }

            if (!String.isBlank(query)) {
                System.debug('FINAL QUERY:::' + query);
                return Database.getQueryLocator(query);
            }
        }

        return Database.getQueryLocator([SELECT Id FROM Account WHERE Id = NULL]);
    }


    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<SObject> toInsert = new List<SObject>();
        List<SObject> toDelete = new List<SObject>();

        for (SObject record : scope) {
            Id parentId = record.Id;

            for (Id userId : grantAccess.keySet()) {
                Id clientId = grantAccess.get(userId);
                String key = userId + '_' + clientId;
                if (accessRecordMap.containsKey(key)) {
                    SObject share = createShareRecord(parentId, userId);
                    if (share != null) {
                        System.debug('Record to be CREATED' + record);
                        toInsert.add(share);
                    }
                }
            }

            for (Id userId : removeAccess.keySet()) {
                Id clientId = removeAccess.get(userId);
                String key = userId + '_' + clientId;
                if (accessRecordMap.containsKey(key)) {
                    System.debug('Record to be DELETED' + record);
                    toDelete.add(record);
                }
            }
        }

        if (!toInsert.isEmpty()) {
            try {
                insert toInsert;
                System.debug('Inserted share records: ' + toInsert.size());
            } catch (DmlException e) {
                System.debug('Insert error: ' + e.getMessage());
            }
        }

        if (!toDelete.isEmpty()) {
            try {
                delete toDelete;
                System.debug('Deleted share records: ' + toDelete.size());
            } catch (DmlException e) {
                System.debug('Delete error: ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        
        if (currentIndex < metadataList.size() - 1) {
            currentIndex ++;
            Database.executeBatch(new NewClientShareControllerbatch(accessRestrictions , currentIndex), 150);
            return;
        }
        updateAccessRestrictions();

    }

    private SObject createShareRecord(Id recordId, Id userId) {
        try {
            String parentObject = recordId.getSObjectType().getDescribe().getName();
            String shareObjectName = parentObject.replace('__c', '__Share');

            Schema.SObjectType shareObjectType = Schema.getGlobalDescribe().get(shareObjectName);
            if (shareObjectType == null) return null;

            SObject shareRecord = shareObjectType.newSObject();
            shareRecord.put('ParentId', recordId);
            shareRecord.put('UserOrGroupId', userId);
            shareRecord.put('AccessLevel', 'Edit');
            shareRecord.put('RowCause', 'Manual');
            return shareRecord;
        } catch (Exception ex) {
            System.debug('Error creating share record: ' + ex.getMessage());
            return null;
        }
    }

    private void updateAccessRestrictions() {
        List<Access_Restriction__c> toUpdate = new List<Access_Restriction__c>();
        List<Access_Restriction__c> toDelete = new List<Access_Restriction__c>();

        for (Access_Restriction__c rec : accessRestrictions) {
            if (rec.Status__c == TO_BE_ENFORCED) {
                rec.Status__c = 'Enforced';
                toUpdate.add(rec);
            } else if (rec.Status__c == TO_BE_GRANTED) {
                toDelete.add(rec);
            }
        }

        if (!toUpdate.isEmpty()) update toUpdate;
        if (!toDelete.isEmpty()) delete toDelete;
    }
}