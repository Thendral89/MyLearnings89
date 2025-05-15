global class clientControllerBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Boolean isExecuted;
    private Boolean isRemoveAccess; 
    private String shareObjectApi;
    private String objectApiName;
    private String relationshipPath;
    private String rowCause;
    private String accessLevel;
    private Id userIdParam;
    private Id clientId;
    List<ShareableObjects__mdt> shareObjects = new List<ShareableObjects__mdt>();

    global clientControllerBatch(
        boolean isExecuted,
        boolean isRemoveAccess, 
        String shareObjectApi,
        String objectApiName,
        String relationshipPath,
        String rowCause,
        String accessLevel,
        Id userIdParam,
        Id clientId
    ) {
        this.isExecuted = isExecuted;
        this.isRemoveAccess = isRemoveAccess;
        this.shareObjectApi = shareObjectApi;
        this.objectApiName = objectApiName;
        this.relationshipPath = relationshipPath;
        this.rowCause = rowCause;
        this.accessLevel = accessLevel;
        this.userIdParam = userIdParam;
        this.clientId = clientId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> ExcludeStdRowCauses = new Set<String>{'Owner', 'Rule', 'ImplicitChild', 'ImplicitParent', 
        'Team', 'Territory', 'FullAccess'};
        if(isRemoveAccess== true){
            if (relationshipPath == 'child') {
                String childQuery = 'SELECT Id FROM '+ shareObjectApi +' WHERE Parent.SymphonyLF__Client__c = :clientId AND UserOrGroupId = :userIdParam AND RowCause NOT IN :ExcludeStdRowCauses';
                return Database.getQueryLocator(childQuery);
            }else{
             String grandchildQuery = 'SELECT Id FROM SymphonyLF__Inventor_Designer_Author__Share WHERE (Parent.SymphonyLF__Patent__r.SymphonyLF__Client__c = :clientId OR Parent.SymphonyLF__Design__r.SymphonyLF__Client__c = :clientId ' + 
              'OR Parent.SymphonyLF__Copyright__r.SymphonyLF__Client__c = :clientId OR Parent.SymphonyLF__Patent_Family__r.SymphonyLF__Client__c = :clientId OR Parent.SymphonyLF__Design_Family__r.SymphonyLF__Client__c = :clientId) AND UserOrGroupId = :userIdParam';
    
            return Database.getQueryLocator(grandchildQuery); 
            }
        }

        if(isRemoveAccess== false) {
            if (relationshipPath == 'child') {
                String childQuery = 'SELECT Id, SymphonyLF__Client__c FROM '+ objectApiName +' WHERE SymphonyLF__Client__c = :clientId';
                return Database.getQueryLocator(childQuery);
            }else{
             String grandchildQuery = 'SELECT Id FROM SymphonyLF__Inventor_Designer_Author__c WHERE SymphonyLF__Patent__r.SymphonyLF__Client__c = :clientId OR SymphonyLF__Patent_Family__r.SymphonyLF__Client__c = :clientId OR SymphonyLF__Design__r.SymphonyLF__Client__c = :clientId OR SymphonyLF__Design_Family__r.SymphonyLF__Client__c = :clientId OR SymphonyLF__Copyright__r.SymphonyLF__Client__c = :clientId';
    
            return Database.getQueryLocator(grandchildQuery); 
            }
    	}
    	return Database.getQueryLocator([SELECT Id FROM SymphonyLF__Client__c WHERE Id = :clientId LIMIT 1]);
	}
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        System.debug('Processing records in batch scope: ' + scope);
    
        if (isRemoveAccess) {
            removeAccess(scope);
        } else {
            grantAccess(scope);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if (isExecuted){
        System.debug('Batch job completed.');
        return;
        }
        shareObjects = [SELECT Label,Share_Object_API_Name__c, Parent_Relationship_Path__c, Row_Cause__c, Access_Level__c FROM ShareableObjects__mdt where Share_Object_API_Name__c !='SymphonyLF__Client__c'];
          for (ShareableObjects__mdt metadata : shareObjects) {
              if (!String.isBlank(metadata.Parent_Relationship_Path__c)) {
                clientControllerBatch childBatch = new clientControllerBatch(
                  true,
                  isRemoveAccess,
                  metadata.Share_Object_API_Name__c,
                  metadata.Label,
                  metadata.Parent_Relationship_Path__c,
                  metadata.Row_Cause__c,
                  metadata.Access_Level__c,
                  userIdParam, clientId);
                  if (userIdParam!=null && clientId!=null && !Test.isRunningTest()) {
                      System.debug('childBatch----'+childBatch);
                      clientChildShareObjWrapper wrapper = new clientChildShareObjWrapper(childBatch);
                      String uniqueJobName = 'ChildBatchJob ' + metadata.Share_Object_API_Name__c + ' ' + Datetime.now().getTime();
                      String cronExpression = Datetime.now().addMinutes(2).format('s m H d M ? yyyy');
                      String jobId = System.schedule(uniqueJobName, cronExpression, wrapper);
                      System.debug('jobId'+jobId);
                  }
              }
              System.debug('All child batches executed successfully.');
          }
    }

    private void grantAccess(List<SObject> scope) {
       
        List<SObject> shareRecords = new List<SObject>();
        

        Schema.SObjectType shareObjectType = Schema.getGlobalDescribe().get(shareObjectApi);

            for (SObject recordPatent : scope) {
                        SObject shareRecord = createShareRecord(shareObjectType, recordPatent.Id, userIdParam, 'Manual', 'Edit');
                        if (shareRecord != null) {
                            shareRecords.add(shareRecord);
                }
            }
        

       
        if (!shareRecords.isEmpty()) {
            try {
                insert shareRecords;
                System.debug('Successfully inserted ' + shareRecords.size() + ' share records.');
            } catch (DmlException e) {
                System.debug('Error inserting share records: ' + e.getMessage());
            }
        }

    }

    private void removeAccess(List<SObject> scope) {
        List<SObject> deleteRecords = new List<SObject>();
        
      
        Schema.SObjectType shareObjectType = Schema.getGlobalDescribe().get(shareObjectApi);
        if (shareObjectType == null) {
            System.debug('Invalid Share Object API Name: ' + shareObjectApi);
            throw new IllegalArgumentException('Invalid SObject API Name: ' + shareObjectApi);
        }
    
        if (userIdParam == null) {
            System.debug('Error: userIdParam is null');
            throw new IllegalArgumentException('User Id parameter cannot be null');
        }
        
        System.debug('scope 145: ' + scope);
       
    
        if (!scope.isEmpty()) {
            try {
                delete scope;
                System.debug('Successfully deleted ' + scope.size() + ' share records.');
            } catch (DmlException e) {
                System.debug('Error deleting share records: ' + e.getMessage());
            }
        }
    }
    

    private SObject createShareRecord(Schema.SObjectType shareObjectType, Id recordId, Id userIdParam, String rowCause, String accessLevel) {
        try {
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

    private SObject deleteShareRecord(Schema.SObjectType shareObjectType, Id recordId, Id userIdParam, String rowCause, String accessLevel) {
        try {
            SObject deleteRecord = shareObjectType.newSObject();
            deleteRecord.put('ParentId', recordId);  
            deleteRecord.put('UserOrGroupId', userIdParam); 
            deleteRecord.put('RowCause', rowCause);
            deleteRecord.put('AccessLevel', accessLevel);  
            return deleteRecord;
        } catch (Exception e) {
            System.debug('Error deleting share record: ' + e.getMessage());
            return null;
        }
    }
}