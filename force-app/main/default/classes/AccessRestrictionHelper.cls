public without sharing class AccessRestrictionHelper {
    
    private static final String TO_BE_GRANTED = 'To Be Granted';
    private static final String TO_BE_ENFORCED = 'To Be Enforced';
    private static final String ENFORCED = 'Enforced';
    private static final String ROWCAUSE_MANUAL = 'Manual';

    public static void processSharing(List<Access_Restriction__c> accessRecords , Map<Id,Access_Restriction__c> oldMap) {
        List<Access_Restriction__c> toUpdate = new List<Access_Restriction__c>();
        List<Access_Restriction__c> toDelete = new List<Access_Restriction__c>();

        for (Access_Restriction__c ar : accessRecords) {
            System.debug('Access_Restriction__c>>>>>' + ar);
            String objectApiName = ar.ObjectName__c;
            Id recordId = ar.Lookup_Fields__c;
            Id userId = ar.User__c;
			
            System.debug('userId >>>>>>>' + userId);   
            if ( userId == Null || recordId == Null || String.isBlank(objectApiName)){
            	continue;    
            } 
            
            System.debug('Access_Restriction__c BEFORE >>>>>>>' + ar.Status__c);   
            if(oldMap <> Null && oldMap.get(ar.Id).Status__c == ENFORCED && ar.Status__c == TO_BE_GRANTED
               || ((ar.Status__c == TO_BE_ENFORCED 
               || ar.Status__c == TO_BE_GRANTED ) && oldMap == Null)){
                 
                System.debug('Access_Restriction__c STATUS>>>>>>>' + ar.Status__c);   
                ShareableObjects__mdt meta = [
                    SELECT Share_Object_API_Name__c, Parent_Relationship_Path__c 
                    FROM ShareableObjects__mdt 
                    WHERE Label = :objectApiName 
                    LIMIT 1
                ];
    
                Boolean success = false;
    
                if (ar.Status__c == TO_BE_GRANTED) {
                    success = createShare(recordId, userId, meta.Share_Object_API_Name__c, ar);
                    if (success) {
                        Access_Restriction__c deleteRecord = new Access_Restriction__c(
                            Id = ar.Id
                        );
                        toDelete.add(deleteRecord);
                    }
                } 
                else if (ar.Status__c == TO_BE_ENFORCED) {
                    success = deleteShare(recordId, userId, meta.Share_Object_API_Name__c, ar);
                    if (success) {
                        Access_Restriction__c updateRecord = new Access_Restriction__c(
                            Id = ar.Id,
                            Status__c = ENFORCED
                        );
                        toUpdate.add(updateRecord);
                    }
                }
            }
    	}
        if (!toUpdate.isEmpty()) update toUpdate;
        if (!toDelete.isEmpty()) delete toDelete;
            
    }

    private static Boolean createShare(Id recordId, Id userId, String shareObjectApiName, Access_Restriction__c accessRecord) {
        try {
            System.debug('CREATE SHARE>>>>>>>' + accessRecord);
            Schema.SObjectType sType = Schema.getGlobalDescribe().get(shareObjectApiName);
            if (sType == null) return false;

            SObject share = sType.newSObject();
            share.put('ParentId', recordId);
            share.put('UserOrGroupId', userId);
            share.put('AccessLevel', 'Edit');
            share.put('RowCause', ROWCAUSE_MANUAL);

            insert share;
            return true;
        } catch (Exception e) {
            System.debug('Error inserting share record: ' + e.getMessage());
            return false;
        }
    }

    private static Boolean deleteShare(Id recordId, Id userId, String shareObjectApiName, Access_Restriction__c accessRecord) {
        try {
            System.debug('DELETE SHARE>>>>>>>' + accessRecord);
            String query = 'SELECT Id FROM ' + shareObjectApiName +
                           ' WHERE ParentId = :recordId AND UserOrGroupId = :userId ' +
                           'AND RowCause = :ROWCAUSE_MANUAL';
			System.debug('query' + recordId + userId + ROWCAUSE_MANUAL);   
            List<SObject> toDelete = Database.query(query);
            if (!toDelete.isEmpty()) {
                delete toDelete;
                return true;
            }
        } catch (Exception e) {
            System.debug('Error deleting share record: ' + e.getMessage());
        }
        return false;
    }
}