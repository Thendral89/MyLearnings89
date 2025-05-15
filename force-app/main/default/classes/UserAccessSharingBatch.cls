global class UserAccessSharingBatch implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {
    private Id userId;
    private ShareableObjects__mdt meta;

    // Transients
    private String objectName;
    private String shareObjectName;
    private String rowCause;
    private String clientFieldAPI;

    public UserAccessSharingBatch(Id userId, ShareableObjects__mdt meta) {
        this.userId = userId;
        this.meta = meta;

        this.objectName = meta.MasterLabel;
        this.shareObjectName = meta.Share_Object_API_Name__c;
        this.rowCause = meta.Row_Cause__c;
        this.clientFieldAPI = meta.Parent_Relationship_Path__c;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Get access-restricted clients for this user
        Set<Id> restrictedClientIds = new Set<Id>();
        for (Access_Restriction__c ar : [
            SELECT Client__c FROM Access_Restriction__c WHERE User__c = :userId
        ]) {
            restrictedClientIds.add(ar.Client__c);
        }

        // Dynamic SOQL based on metadata
        String query = 'SELECT Id FROM ' + objectName;

        if (clientFieldAPI != null && !restrictedClientIds.isEmpty()) {
            String whereClause = clientFieldAPI + ' NOT IN :restrictedClientIds';
            query += ' WHERE ' + whereClause;
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<SObject> shareRecords = new List<SObject>();

        for (SObject obj : scope) {
            SObject shareObj = (SObject) Type.forName(shareObjectName).newInstance();
            shareObj.put('ParentId', obj.Id);
            shareObj.put('UserOrGroupId', userId);
            shareObj.put('AccessLevel', 'Edit');
            shareObj.put('RowCause', rowCause);
            shareRecords.add(shareObj);
        }

        if (!shareRecords.isEmpty()) {
            Database.SaveResult[] results = Database.insert(shareRecords, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Insert failed: ' + err.getMessage());
                    }
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {}
}