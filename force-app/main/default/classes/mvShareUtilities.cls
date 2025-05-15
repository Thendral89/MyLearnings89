public with sharing class mvShareUtilities {

    // Cache global describe for performance
	public static Map<String, Schema.SObjectType> globalDescribe {
		get {
			if(globalDescribe == null) {
				globalDescribe = Schema.getGlobalDescribe();
			}
			return globalDescribe;
		}
		private set;
	}

	public static Map<String,Schema.DescribeSObjectResult> cachedDescribes = new Map<String,Schema.DescribeSObjectResult>();
	public static Map<String,Map<String, Schema.SObjectField>> cachedFieldMaps = new Map<String,Map<String, Schema.SObjectField>>();

    // Get describe result and maintain cache
	public static Schema.DescribeSObjectResult describe(String objectAPIName) {
		if(cachedDescribes.containsKey(objectAPIName)) {
			System.debug('Describe: Returning from cache: '+cachedDescribes.get(objectAPIName));
			return cachedDescribes.get(objectAPIName);
		}
		else {
			if(globalDescribe.containsKey(objectAPIName)) {
				Schema.SObjectType objType = globalDescribe.get(objectAPIName);
				Schema.DescribeSObjectResult describe = objType.getDescribe();
				cachedDescribes.put(objectAPIName, describe);
				System.debug('Describe: Returning from global: '+describe);
				return describe;
			}
			else {
				System.debug('Describe: Couldnt find');
				return null;
			}
		}
	}

	// Return a map of all sharing reasons for a particular object
	public static Map<String,String> getSharingReasons(String objectApiName) {
		Map<String,String> reasons = new Map<String,String>();

		// Get the SOBjectField corresponding to RowCause on the share object
		Schema.SObjectType objectType = getSObjectTypeFromName(objectApiName);
		Schema.SObjectType shareObjectType = getShareObject(objectType);
		Schema.SObjectField rowCauseField = getSObjectFieldFromName('RowCause', shareObjectType);

		for(PicklistEntry entry : rowCauseField.getDescribe().getPicklistValues()) {

			// Only add custom reasons (ones ending in __c)
			if(entry.getValue().right(3) == '__c') {
				reasons.put(entry.getValue(), entry.getLabel());
			}
		}

		return reasons;
	}

    // Return SObjectType token from API name
	public static Schema.SObjectType getSObjectTypeFromName(String objectAPIName) {
		System.debug('Checking describe for object: '+objectAPIName);
		System.debug('Describe: '+describe(objectAPIName));
		Schema.SObjectType type = describe(objectAPIName).getSobjectType();
		return type;
	}

    private static String getShareObjectNameFromSObject(Schema.SObjectType type) {
		Schema.SObjectType shareObject;
		String typeName = type.getDescribe().getName();
		
		// For custom objects, remove the final "c" from the __c suffix
		if(type.getDescribe().isCustom()) {
			typeName = typeName.left(typeName.length()-1);
		}

		return typeName + 'Share';
	}

    public static String getShareObjectNameFromSObjectName(String sObjectName) {
		Schema.SObjectType type = getSObjectTypeFromName(sObjectName);
		return getShareObjectNameFromSObject(type);
	}

    public static Schema.SObjectType getShareObject(Schema.SObjectType type) {
		String shareObjectName = getShareObjectNameFromSObject(type);
		Schema.SObjectType shareObject = globalDescribe.get(shareObjectName);
		return shareObject;
	}

    public static Schema.sObjectField getSObjectFieldFromName(String fieldNameString, Schema.SOBjectType type) {
        Map<String, Schema.SObjectField> fieldsMapByName = type.getDescribe().fields.getMap();
        Schema.SObjectField sObjField = fieldsMapByName.get(fieldNameString.toLowerCase());
        return sObjField;
    }

    private static List<Id> getActiveUsers() {

		List<Id> Users = new List<Id>();

		List<User> activeUserMap = 
			[SELECT Id FROM User 
			WHERE IsActive = true
			AND profile.Name <> 'System Administrator'
			AND Profile.UserLicense.Name IN ('Salesforce','Salesforce Platform')];

		if(activeUserMap.size()>0){
            for(User data : activeUserMap){
                Users.add(data.Id);   
            }   
        }

		return Users;
	}    


	// Created to check Access_Restriction__c before record sharing
    public static Map<Id, Set<Id>> getRestrictedUsers(List<Id> userIds) {
        Map<Id, Set<Id>> accessRestrictionsMap = new Map<Id, Set<Id>>();
        
        List<Access_Restriction__c> accessRestrictionRecords = [
            SELECT User__c, Client__c, Patent__c, Design__c, Trademark__c, Copyright__c, 
            Agreement_and_Contract__c, General_Matter__c
            FROM Access_Restriction__c 
            WHERE Revoke_Record_Access__c = true 
              AND User__c IN :userIds
            LIMIT 50000
        ];
        
        // Populate the map only if lookup fields are not null
        for (Access_Restriction__c accessRestriction : accessRestrictionRecords) {
            addToRestrictions(accessRestrictionsMap, accessRestriction.Client__c, accessRestriction.User__c);
        }
        
        return accessRestrictionsMap;
    }
        
	private static void addToRestrictions(Map<Id, Set<Id>> accessRestrictionsMap, Id recordId, Id userId) {
        if (recordId == null) {
            return; // Skip null record IDs
        }
        if (!accessRestrictionsMap.containsKey(recordId)) {
            accessRestrictionsMap.put(recordId, new Set<Id>());
        }
        accessRestrictionsMap.get(recordId).add(userId);
    }// end of code Wall of User check

	@future
    public static void OrgRecordSharingfuture(string ObjectName,List<Id> recordId) {
        mvShareUtilities.OrgRecordSharing(ObjectName,recordId, new Map<Id, Id>());
    }

    public static void OrgRecordSharing(String ObjectName, List<Id> recordIds) {
        OrgRecordSharing(ObjectName, recordIds, new Map<Id, Id>());
    }  

    public static void OrgRecordSharing(String ObjectName, List<Id> recordIds, Map<Id, Id> ClientIdMap) {
        List<Id> clientID = new List<Id>();
        List<Id> ClientUsers = new List<Id>();
        List<Id> DplicateIds = new List<Id>();
        Map<String, sObject> recordsObjToUpdate = new Map<String, sObject>();
        Map<String, sObject> recordsToUpdate = new Map<String, sObject>();
        if (clientIdMap == null) {
            clientIdMap = new Map<Id, Id>();}
        List<Id> GroupId= mvShareUtilities.getActiveUsers();
		System.debug('Users : ' + groupId);
        if (GroupId.isEmpty()) {
            return; 
        }
        
        
        string SymObject=ObjectName.replace('__Share','__c');
        
        
      	Map<Id, Set<Id>> accessRestrictionsMap = mvShareUtilities.getRestrictedUsers(GroupId);     
      	try {
			for (Id recordId : recordIds) {              
				for(Integer i = 0; i < GroupId.size(); i++) {  
					if(accessRestrictionsMap != null && clientIdMap!=null){
						Id clientRecId = ClientIdMap?.get(recordId);
						if (clientId!=null && accessRestrictionsMap.containsKey(clientRecId) && accessRestrictionsMap.get(clientRecId).contains(GroupId[i])) {
							continue;}
					}
					
					sObject newRecord = Schema.getGlobalDescribe().get(ObjectName).newSObject();  
					newRecord.put('UserOrGroupId', GroupId[i]);
					newRecord.put('ParentId', recordId);
					newRecord.put('RowCause', 'Manual');
					newRecord.put('AccessLevel', 'Edit');
					recordsToUpdate.put(GroupId[i] + '-' + recordId, newRecord);
				}
			}  
      
      } catch (Exception e) {
          System.debug('Error during insert: ' + e.getMessage());
      }
        
        system.debug('recordsToUpdate ' + recordsToUpdate);
    
        
        if (!recordsToUpdate.isEmpty()) {//recordsToUpdate.values()
            try {
                Database.SaveResult[] saveResults = Database.insert(recordsToUpdate.values(), false);
                for (Database.SaveResult sr : saveResults) {
                    if (!sr.isSuccess()) {
                        // If not successful, log the error and the failed record
                        System.debug('Failed to insert record with Id: ' + sr.getId());
                        System.debug('Error message: ' + sr.getErrors()[0].getMessage());
                    }
                }
            } catch (Exception e) {
                System.debug('Error during insert: ' + e.getMessage());
            }
        }
          
    }
}