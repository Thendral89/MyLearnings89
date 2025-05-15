public without sharing class ApexSharingService {
    /*
        String lockIdValue = 'AwardPolicyGiveAward.giveAwards';
        LockerService.applyLocksAcrossServices(lockIdValue);

        ApexSharingService.addLock(lockIdValue);

        ApexSharingService a = new ApexSharingService();
        a.setModuleName('Inventor Award');
        a.setShareObject('SymphonyIPM__Inventor_Award_v1__Share');
        a.setRecordId(inventorAward.Id);
        a.setUserIds(new Set<Id>{ inventorAward.SymphonyIPM__Approver__c });
        a.setRowCause('SymphonyIPM__Approver__c'); 
        a.setAccessLevel('Edit');
        a.addShare();
        a.removeShare();

        ApexSharingService.removeLock(lockIdValue);
        ApexSharingService.addAndThenRemoveSharesInService();
        ApexSharingService.clearService();

        LockerService.releaseLockAcrossServices(lockIdValue);
    */

    /*
        Select Id,Parent.Name,UserOrGroup.Name,AccessLevel,RowCause  FROM SymphonyLF__Patent__Share ORDER BY LastModifiedDate DESC LIMIT 200
    */
    private Id clientId;
    private Id recordId;  
    private String shareObject;
    private String rowCause;
    private String accessLevel;
    private Set<Id> personIds = new Set<Id>();
    private Set<Id> userIds = new Set<Id>();
    private Set<String> groupDeveloperNames = new Set<String>();
    private Set<Id> groupIds = new Set<Id>();

    private String module;

    private Id apexSharingRecordId;
    private String futureStatus = 'Pending';
    private Id futureUser;

    private final static GovernorLimitsMeasure governorLimitsOfService = new GovernorLimitsMeasure();

    public static GovernorLimitsMeasure getGovernorLimits(){
        return governorLimitsOfService;
    }

    private static Boolean doNotCache = true;
    private static Boolean serviceIsAsynchronous = false;
    private static Boolean throwErrorIfSingleRecordDmlFails = false;
    private static Boolean matchPersonAndUserField = false;
    static String personFieldForMatching;
    static String userFieldForMatching;

    static{
        List<Global_Settings__mdt> e = [
            SELECT Toggle__c
            FROM Global_Settings__mdt
            WHERE DeveloperName = 'ThrowErrorInApexSharingIfRecordFails'
        ];
        if(e == null || e.size() == 0){
            return;
        }
        if(e[0].Toggle__c == true){
            throwErrorIfSingleRecordDmlFails = true;
        }
        
        List<Global_Settings__mdt> g = [
            SELECT Toggle__c
            FROM Global_Settings__mdt
            WHERE DeveloperName = 'Do_Not_Cache_Apex_Service_Records'
        ];
        if(g == null || g.size() == 0){
            return;
        }
        if(g[0].Toggle__c == true){
            doNotCache = true;
        }

        List<Global_Settings__mdt> a = [
            SELECT Toggle__c
            FROM Global_Settings__mdt
            WHERE DeveloperName = 'Make_Apex_Sharing_Service_Asynchronous'
        ];
        if(a == null || a.size() == 0){
            return;
        }
        if(a[0].Toggle__c == true){
            // Making Apex Sharing Synchronous for now.
          //  serviceIsAsynchronous = true;
        }   

        List<Global_Settings__mdt> m = [
            SELECT Toggle__c, Value__c
            FROM Global_Settings__mdt
            WHERE DeveloperName = 'ApexSharing_MatchPersonAndUserField'
        ];
        if(m == null || m.size() == 0){
            return;
        }
        if(m[0].Toggle__c == true){
            matchPersonAndUserField = true;
            if(
                String.isBlank(m[0].Value__c)
                ||
                (m[0].Value__c.split(',')).size() < 2
            ){
                throw new PersonFieldAndUserConfigurationMandatoryException(
                    'Providing Person Field And User Field respectively for matching separated by a comma is mandatory when "ApexSharing_MatchPersonAndUserField" global toggle setting is enabled.'
                );
            }
            List<String> split = m[0].Value__c.split(',');
            personFieldForMatching = split[0];
            userFieldForMatching = split[1];
        } 
        
    }

    private static List<ApexSharingService> addSharesInService = new List<ApexSharingService>();
    private static List<ApexSharingService> removeSharesInService = new List<ApexSharingService>();

    private static Set<Id> personIdsInService = new Set<Id>();
    private static Set<Id> userIdsInService = new Set<Id>();
    private static Set<String> groupDeveloperNamesInService = new Set<String>();
    private static Set<Id> groupIdsInService = new Set<Id>();
    private static Set<Id> clientIdsInService = new Set<Id>();
//    private static Set<Id> recordIdsInService = new Set<Id>(){get;set;}
    private static set<Id> recordIdsInService {
        get {
            if(recordIdsInService == null) {
                recordIdsInService = new Set<Id>();
            }
            return recordIdsInService;
        }
        set;        
    }
    private static set<String> shareObjectTypeOnAdd {
        get {
            if(shareObjectTypeOnAdd == null) {
                shareObjectTypeOnAdd = new Set<String>();
            }
            return shareObjectTypeOnAdd;
        }
        set;        
    }

    private static Map<Id, SymphonyLF__Person__c> personRecordsForPersonIds = new Map<Id, SymphonyLF__Person__c>();
    private static Map<Id, Set<Id>> personIdsByUserId = new Map<Id, Set<Id>>();
    private static Map<Id, User> userRecordsForUserIds = new Map<Id, User>();
    private static Map<String, Group> groupRecordsForGroupDeveloperNames = new Map<String, Group>();
    private static Map<Id, Group> groupRecordsForGroupIds = new Map<Id, Group>();
    private static List<Access_Restriction__c> wallOffRecords = new List<Access_Restriction__c>();
    private static Set<Id> wallOffUserIds = new Set<Id>();
    private static Set<String> notAllowedWalledOffs = new Set<String>();

    private static Set<String> lookupFieldsToWallOff = findLookupFieldOnWallOff();

    private static Map<String, ApexSharing__c> apexSharingsByKeyForAddService = new Map<String, ApexSharing__c>();
    private static Map<String, ApexSharing__c> apexSharingsByKeyForRemoveService = new Map<String, ApexSharing__c>();

    private static Boolean lockApplied = false;
    private static String lockId;

    public ApexSharingService() {

    }

    public static void removeLastListElementInAddShare(){
        if(addSharesInService.size() > 0){
            addSharesInService.remove( addSharesInService.size() - 1);
        }
    }

    public static void removeLastListElementInRemoveShare(){
        if(removeSharesInService.size() > 0){
            removeSharesInService.remove( removeSharesInService.size() - 1);
        }
    }

    public static List<ApexSharingService> getAddSharesInService(){
        return addSharesInService;
    }

    public String getFutureStatus(){
        return futureStatus;
    }

    public Id getFutureUser(){
        return futureUser;
    }

    public void setClientId(Id clientId){
        if(clientId == null){
            System.debug('default id');
        clientId = 'a0TWr000007jG9XMAU'; 
            
        }
        System.debug('191 clientId'+ clientId);
        System.debug('192 clientId'+ Id.valueOf(clientId));
        this.clientId = Id.valueOf(clientId);
        

        if (clientIdsInService == null) {
        clientIdsInService = new Set<Id>();
    }
    clientIdsInService.add( clientId );
    }

    public void setApexSharingRecordId(Id apexSharingRecordId){
        this.apexSharingRecordId = apexSharingRecordId;
    }

    public void setRecordId(Id recordId){
        this.recordId = recordId;
        System.debug('Test ApexSharingService:setRecordId ' + recordId + ' , ' + recordIdsInService);
        recordIdsInService.add( recordId );
    }

    public void setPersonIds(Set<Id> personIds){
        if(personIds == null || personIds.size() == 0){
            return;
        }
        if(personIds.contains(null)){
            personIds.remove(null);
        }

        this.personIds.addAll(personIds);
        personIdsInService.addAll(personIds);
    }

    public void setUserIds(Set<Id> userIds){
        if(userIds == null || userIds.size() == 0){
            return;
        }
        if(userIds.contains(null)){
            userIds.remove(null);
        }

        this.userIds.addAll(userIds);

        if (userIdsInService == null) {
        userIdsInService = new Set<Id>();
    }
        userIdsInService.addAll(userIds);
    }

    public void setGroupIds(Set<Id> groupIds){
        if(groupIds == null || groupIds.size() == 0){
            return;
        }
        if(groupIds.contains(null)){
            groupIds.remove(null);
        }

        this.groupIds.addAll(groupIds);
        groupIdsInService.addAll(groupIds);
    }

    public void setGroupDeveloperNames(Set<String> groupDeveloperNames){
        if(groupDeveloperNames == null || groupDeveloperNames.size() == 0){
            return;
        }
        if(groupDeveloperNames.contains('null')){
            groupDeveloperNames.remove('null');
        }

        Set<String> groupDeveloperNamesTemp = new Set<String>();
        for(String s : groupDeveloperNames){
            if(String.isNotBlank(s)){
                groupDeveloperNamesTemp.add(s);
            }
        }

        this.groupDeveloperNames.addAll(groupDeveloperNamesTemp);
        groupDeveloperNamesInService.addAll(groupDeveloperNamesTemp);
    }

    public void setShareObject(String shareObject){
        if(String.isBlank(shareObject)){
            return;
        }
        if(shareObject == 'null'){
            return;
        }

        this.shareObject = shareObject;
    }

    public void setRowCause(String rowCause){
        if(String.isBlank(rowCause)){
            return;
        }
        
        this.rowCause = rowCause;
    }

    public void setAccessLevel(String accessLevel){
        if(String.isBlank(accessLevel)){
            return;
        }
        
        this.accessLevel = accessLevel;
    }

    public static void addLock(String lockIdValue){
        if(lockApplied == true){
            return;
        }
        lockId = lockIdValue;
        lockApplied = true;
    }

    public static void removeLock(String lockIdValue){
        if(lockIdValue == lockId){
            lockApplied = false;
        }
    }

    public static void clearService(){
        if(lockApplied == true){
            return;
        }
        addSharesInService = new List<ApexSharingService>();
        removeSharesInService = new List<ApexSharingService>();
        governorLimitsOfService.clear();
        personIdsInService = new Set<Id>();
        userIdsInService = new Set<Id>();
        groupIdsInService = new Set<Id>();
        groupDeveloperNamesInService = new Set<String>();
        personRecordsForPersonIds = new Map<Id, SymphonyLF__Person__c>();
        userRecordsForUserIds = new Map<Id, User>();
        groupRecordsForGroupDeveloperNames = new Map<String, Group>();
        groupRecordsForGroupIds = new Map<Id, Group>();
        apexSharingsByKeyForAddService = new Map<String, ApexSharing__c>();
        apexSharingsByKeyForRemoveService = new Map<String, ApexSharing__c>();
        shareObjectTypeOnAdd = new Set<String>();
        shareObjectTypeOnRemove = new Set<String>();
        clientIdsInService = new Set<Id>();
        recordIdsInService = new Set<Id>();
        notAllowedWalledOffs = new Set<String>();
        wallOffRecords = new List<Access_Restriction__c>();
        wallOffUserIds = new Set<Id>();
        personIdsByUserId = new Map<Id, Set<Id>>();
    }

    public void setModuleName(String module){
        if(String.isBlank(module)) return;
        this.module = module;
    }

   // private static Set<String> shareObjectTypeOnAdd = new Set<String>();
    private static Set<String> shareObjectTypeOnRemove = new Set<String>();

    public void addShare(){
        validateRequiredFields();
        shareObjectTypeOnAdd.add(this.shareObject);
        addSharesInService.add(this);
        governorLimitsConsumedByService();
    }

    public void removeShare(){
        validateRequiredFields();
        if (shareObjectTypeOnRemove == null) {
        shareObjectTypeOnRemove = new Set<String>();
    }
        shareObjectTypeOnRemove.add(this.shareObject);

        if (clientIdsInService == null) {
        clientIdsInService = new Set<Id>();
    }

    if (removeSharesInService == null) {
        removeSharesInService = new List<ApexSharingService>();
    }
        removeSharesInService.add(this);
        governorLimitsConsumedByService();
    }

    public void addShare(Boolean putValueInStaticProperties){
        validateRequiredFields();

        shareObjectTypeOnAdd.add(this.shareObject);
        setModuleName(this.module);
        setShareObject(this.shareObject);
        setRecordId(this.recordId);
        setPersonIds(this.personIds);
        setUserIds(this.userIds);
        setGroupIds(this.groupIds);
        setGroupDeveloperNames(this.groupDeveloperNames);
        setRowCause(this.rowCause);
        setAccessLevel(this.accessLevel);
        setClientId(this.clientId);

        addSharesInService.add(this);

        governorLimitsConsumedByService();
    }

    public void removeShare(Boolean putValueInStaticProperties){
        validateRequiredFields();

        shareObjectTypeOnRemove.add(this.shareObject);
        setModuleName(this.module);
        setShareObject(this.shareObject);
        setRecordId(this.recordId);
        setPersonIds(this.personIds);
        setUserIds(this.userIds);
        setGroupIds(this.groupIds);
        setGroupDeveloperNames(this.groupDeveloperNames);
        setRowCause(this.rowCause);
        setAccessLevel(this.accessLevel);
        setClientId(this.clientId);

        removeSharesInService.add(this);

        governorLimitsConsumedByService();
    }
    
    private static GovernorLimitsMeasure governorLimitsConsumedByService(){
        Integer soqls = 0;
        if(personIdsInService != null && personIdsInService.size() != 0){
            soqls = soqls + 1;
        }
        if(userIdsInService != null && userIdsInService.size() != 0){
            soqls = soqls + 1;
        }
        if(
            (groupDeveloperNamesInService != null && groupDeveloperNamesInService.size() != 0)
            ||
            (groupIdsInService != null && groupIdsInService.size() != 0)
        ){
            soqls = soqls + 1;
        }
        if (addSharesInService == null) {
        addSharesInService = new List<ApexSharingService>();
    }

        if(addSharesInService.size() > 0){
            soqls = soqls + 1;
        }
        soqls = soqls + shareObjectTypeOnAdd.size();
        if(removeSharesInService.size() > 0){
            soqls = soqls + 1;
        }
        soqls = soqls + shareObjectTypeOnRemove.size();

        Integer dmlsToConsume = 0;
        if(addSharesInService.size() > 0){
            dmlsToConsume = dmlsToConsume + 2;
        }
        if(removeSharesInService.size() > 0){
            dmlsToConsume = dmlsToConsume + 2;
        }

        governorLimitsOfService.soqlsToConsume = soqls;
        governorLimitsOfService.dmlsToConsume = dmlsToConsume;

        return governorLimitsOfService;
    }

    private void validateRequiredFields(){
        if(this.shareObject == null){
            throw new ShareObjectTypeMissingException();
        }
        if(this.recordId == null){
            throw new RecordToShareMissingException();
        }
        if(this.rowCause == null){
            throw new RowCauseMissingException();
        }
        if(this.accessLevel == null){
            throw new AccessLevelMissingException();
        }
        if(this.personIds.size() == 0 && this.userIds.size() == 0 && this.groupDeveloperNames.size() == 0 && this.groupIds.size() == 0){
            throw new UserAndPersonAndGroupToBeSharedWithMissingException();
        }
    }

    public class ShareObjectTypeMissingException extends Exception{

    }

    public class RowCauseMissingException extends Exception{

    }

    public class RecordToShareMissingException extends Exception{

    }

    public class AccessLevelMissingException extends Exception{

    }

    public class UserAndPersonAndGroupToBeSharedWithMissingException extends Exception{

    }

    public static void addAndThenRemoveSharesInService(){
        if(lockApplied == true){
            return;
        }

        if( (addSharesInService == null || addSharesInService.size() == 0) &&
            (removeSharesInService == null || removeSharesInService.size() == 0)  
        ){
            return;
        }
/*
        if(serviceIsAsynchronous == true && (!System.isBatch() && !System.isFuture()) ){
            moveTheProcessToAsynchronousJob();
            return;
        }

        if(governorLimitsOfService.canCrossBandGap()){
            moveTheProcessToAsynchronousJob();
            return;
        }
*/
        fetchWallOff();
        fetchPersonRecords();
        fetchUserRecords();
        fetchGroupRecords();
        runStatisticsOnPersonRecords();
        makeWallOffIdentifiers();
       

        if( addSharesInService != null && addSharesInService.size() > 0 ){
            apexSharingsByKeyForAddService = apexSharingsByAllPossibleKeys(addSharesInService);
            Map<String, ServiceStatistics> serviceStatisticsBySObject = serviceStatistics(addSharesInService);
            insertSObjectShareRecordsAndApexShareServiceRecordsForSharingsThatDidNotQualify(serviceStatisticsBySObject);
        }

        if( removeSharesInService != null && removeSharesInService.size() > 0 ){
            apexSharingsByKeyForRemoveService = apexSharingsByAllPossibleKeys(removeSharesInService);
            Map<String, ServiceStatistics> serviceStatisticsBySObject = serviceStatistics(removeSharesInService);
            removeSObjectShareRecordsAndRemoveApexSharingServiceRecords(serviceStatisticsBySObject);
        }
    }

    private static void runStatisticsOnPersonRecords(){
        for(SymphonyLF__Person__c p : personRecordsForPersonIds.values()){
            if(p.SymphonyLF__User__c == null){
                continue;
            }

            Set<Id> personIds = personIdsByUserId.get(p.SymphonyLF__User__c);
            if(personIds == null){
                personIds = new Set<Id>();
                personIdsByUserId.put(p.SymphonyLF__User__c, personIds);
            }
            personIds.add(p.Id);
        }
    }

    private static void shareObjectMap(Map<String, List<sObject>> shareObjectMap, sObject shareObject, Id parentId){
        String parentIdString = parentId;
        String objectCode = parentIdString.substring(0,3);
        if(shareObjectMap.containsKey(objectCode)){
            shareObjectMap.get(objectCode).add(shareObject);
        }else{
            shareObjectMap.put(objectCode, new List<Sobject>{shareObject});
        }
    }

    private static void insertSObjectShareRecordsAndApexShareServiceRecordsForSharingsThatDidNotQualify(Map<String, ServiceStatistics> serviceStatisticsBySObject){
        Map<String, List<sObject>> toInsertByShareObject = new Map<String, List<sObject>>();
        List<ApexSharing__c> toInsertApexShareService = new List<ApexSharing__c>();
        List<ApexSharing__c> toAbandonApexShareService = new List<ApexSharing__c>();

        Set<String> toInsertUnique = new Set<String>();
        Set<String> toInsertApexShareServiceUnique = new Set<String>();
        Set<Id> toAbandonApexShareServiceUnique = new Set<Id>();

        for(String sObjectShare : serviceStatisticsBySObject.keySet()){
            ServiceStatistics s = serviceStatisticsBySObject.get(sObjectShare);
            Set<Id> recordIds = s.recordIds;
            Set<String> rowCauses = s.rowCauses;
            Set<Id> userOrGroupIds = new Set<Id>();
            for(Id i : s.personIds){


                //htthr
                Id userId = personRecordsForPersonIds.get(i).SymphonyLF__User__c;
                if(userId != null){
                    userOrGroupIds.add(userId);
                }
            }
            for(String g : s.groupDeveloperNames){
                Group grp = groupRecordsForGroupDeveloperNames.get(g);
                if(grp != null){
                    userOrGroupIds.add( grp.Id );
                }
            }
            userOrGroupIds.addAll(s.userIds);
            userOrGroupIds.addAll(s.groupIds);
            
            ShareObjectSelector shareObjectSelector = new ShareObjectSelector(sObjectShare);
            List<ShareObjectSelectorJSON> sObjectShares = shareObjectSelector.selectByParentIdAndUserOrGroupIdAndRowCause(recordIds, userOrGroupIds, rowCauses);

            Map<String, sObject> sObjectShareRecordByKey = new Map<String, sObject>();
            for(ShareObjectSelectorJSON sJSON : sObjectShares){
                sObjectShareRecordByKey.put( key(sJSON) , sJSON.record);
            }
            
          //  System.debug('sObjectShareRecordByKey :: ' + JSON.serialize(sObjectShareRecordByKey));

            for(ApexSharingService a : s.sharesOfSameSObject){
                Id parentId = a.recordId;
                Id clientId = a.clientId;
                String rowCause = a.rowCause;
                String accessLevel = a.accessLevel;
                for(Id i : a.userIds){
                    Id userId = i;

                    if(ignoreForSharingDueToWallOff(clientId, parentId, userId)){
                        continue;
                    }

                    ShareServiceRecordCreator rc = new ShareServiceRecordCreator(apexSharingsByKeyForAddService);
                    rc.determineForUserId(a, userId);
                    if(rc.needToCreate() && rc.discrepancyDetected()){
                        ApexSharing__c asr = rc.getCreatedRecord();
                        asr.Client__c = clientId;
                        String keyed = key(asr.ShareObject__c, asr.RecordId__c, asr.UserToShareWith__c, asr.RowCause__c, asr.AccessLevel__c);
                        if(!toInsertApexShareServiceUnique.contains(keyed)){
                            toInsertApexShareService.add( rc.getCreatedRecord() );
                            toInsertApexShareServiceUnique.add(keyed);
                        }  

                        String keyWithUserIdOnRemove = keyOnRemove(a.shareObject, parentId, userId, rowCause, accessLevel);
                        if(apexSharingsByKeyForAddService.containsKey(keyWithUserIdOnRemove)){
                            ApexSharing__c asror = apexSharingsByKeyForAddService.get(keyWithUserIdOnRemove);
                            if(asror.AccessLevel__c != accessLevel && !toAbandonApexShareServiceUnique.contains(asror.Id)){
                                asror.FutureStatus__c = 'Access Level Changed';
                                toAbandonApexShareService.add(asror);
                                toAbandonApexShareServiceUnique.add(asror.Id);
                            }
                        }
                    }
                    else {
                        String keyWithUserId = key(a.shareObject, parentId, userId, rowCause, accessLevel);
                        String keyedOwner = key(a.shareObject, parentId, userId, 'Owner', 'All');
                        if( (!sObjectShareRecordByKey.containsKey(keyWithUserId)) && (!sObjectShareRecordByKey.containsKey(keyedOwner)) && (!rc.discrepancyDetected()) ){
                            if(!toInsertUnique.contains(keyWithUserId)){
                                shareObjectMap(toInsertByShareObject, prepareShareObjectRecord(a, userId), parentId);
                                toInsertUnique.add(keyWithUserId);
                            }
                            
                            if(a.apexSharingRecordId != null){
                                a.futureStatus = 'Shared';
                                a.futureUser = userId;
                            }
                        }
                    }
                }

                for(Id i : a.groupIds){
                    Id groupId = i;

                    ShareServiceRecordCreator rc = new ShareServiceRecordCreator(apexSharingsByKeyForAddService);
                    rc.determineForGroupId(a, groupId);
                    if(rc.needToCreate() && rc.discrepancyDetected()){
                        ApexSharing__c asr = rc.getCreatedRecord();
                        String keyed = key(asr.ShareObject__c, asr.RecordId__c, asr.GroupIdToShareWith__c, asr.RowCause__c, asr.AccessLevel__c);
                        if(!toInsertApexShareServiceUnique.contains(keyed)){
                            toInsertApexShareService.add( rc.getCreatedRecord() );
                            toInsertApexShareServiceUnique.add(keyed);
                        }  

                        String keyWithGroupIdOnRemove = keyOnRemove(a.shareObject, parentId, groupId, rowCause, accessLevel);
                        if(apexSharingsByKeyForAddService.containsKey(keyWithGroupIdOnRemove)){
                            ApexSharing__c asror = apexSharingsByKeyForAddService.get(keyWithGroupIdOnRemove);
                            if(asror.AccessLevel__c != accessLevel && !toAbandonApexShareServiceUnique.contains(asror.Id)){
                                asror.FutureStatus__c = 'Access Level Changed';
                                toAbandonApexShareService.add(asror);
                                toAbandonApexShareServiceUnique.add(asror.Id);
                            }
                        }
                    }
                    else {
                        Group grp = groupRecordsForGroupIds.get(groupId);
                        if(grp != null){
                            String keyWithGroupId = key(a.shareObject, parentId, groupId, rowCause, accessLevel);
                            if( (!sObjectShareRecordByKey.containsKey(keyWithGroupId)) && (!rc.discrepancyDetected()) ){
                                if(!toInsertUnique.contains(keyWithGroupId)){
                                    shareObjectMap(toInsertByShareObject, prepareShareObjectRecord(a, groupId), parentId);
                                    toInsertUnique.add(keyWithGroupId);
                                }

                                if(a.apexSharingRecordId != null){
                                    a.futureStatus = 'Shared';
                                }
                            }
                        }
                    }
                }

                for(Id i : a.personIds){
                    Id personId = i;

                    if(ignoreForSharingDueToWallOff(clientId, parentId, personId)){
                        continue;
                    }

                    ShareServiceRecordCreator rc = new ShareServiceRecordCreator(apexSharingsByKeyForAddService);
                    rc.determineForPersonId(a, personId);
                    if(rc.needToCreate() && rc.discrepancyDetected()){
                        ApexSharing__c asr = rc.getCreatedRecord();
                        asr.Client__c = clientId;
                        String keyed = key(asr.ShareObject__c, asr.RecordId__c, asr.PersonToShareWith__c, asr.RowCause__c, asr.AccessLevel__c);
                        if(!toInsertApexShareServiceUnique.contains(keyed)){
                            toInsertApexShareService.add( rc.getCreatedRecord() );
                            toInsertApexShareServiceUnique.add(keyed);
                        }

                        String keyWithPersonIdOnRemove = keyOnRemove(a.shareObject, parentId, personId, rowCause, accessLevel);
                        if(apexSharingsByKeyForAddService.containsKey(keyWithPersonIdOnRemove)){
                            ApexSharing__c asror = apexSharingsByKeyForAddService.get(keyWithPersonIdOnRemove);
                            if(asror.AccessLevel__c != accessLevel && !toAbandonApexShareServiceUnique.contains(asror.Id)){
                                asror.FutureStatus__c = 'Access Level Changed';
                                toAbandonApexShareService.add(asror);
                                toAbandonApexShareServiceUnique.add(asror.Id);
                            }
                        }
                    }
                    else {
                        Id userId = personRecordsForPersonIds.get(i).SymphonyLF__User__c;
                        if(userId != null){
                            String keyWithUserId = key(a.shareObject, parentId, userId, rowCause, accessLevel);
                            String keyedOwner = key(a.shareObject, parentId, userId, 'Owner', 'All');
                            if( (!sObjectShareRecordByKey.containsKey(keyWithUserId)) && (!sObjectShareRecordByKey.containsKey(keyedOwner)) && (!rc.discrepancyDetected())){
                                if(!toInsertUnique.contains(keyWithUserId)){
                                    shareObjectMap(toInsertByShareObject, prepareShareObjectRecord(a, userId), parentId);
                                    toInsertUnique.add(keyWithUserId);
                                }
                                
                                if(a.apexSharingRecordId != null){
                                    a.futureStatus = 'Shared';
                                    a.futureUser = userId;
                                }
                            }

                        }
                    }
                }

                for(String i : a.groupDeveloperNames){
                    String groupDeveloperName = i;
                    ShareServiceRecordCreator rc = new ShareServiceRecordCreator(apexSharingsByKeyForAddService);
                    rc.determineForGroupDeveloperName(a, groupDeveloperName);
                    if(rc.needToCreate() && rc.discrepancyDetected()){
                        ApexSharing__c asr = rc.getCreatedRecord();
                        String keyed = key(asr.ShareObject__c, asr.RecordId__c, asr.GroupToShareWith__c, asr.RowCause__c, asr.AccessLevel__c);
                        if(!toInsertApexShareServiceUnique.contains(keyed)){
                            toInsertApexShareService.add( rc.getCreatedRecord() );
                            toInsertApexShareServiceUnique.add(keyed);
                        } 
                        
                        String keyWithGroupDeveloperNameOnRemove = keyOnRemove(a.shareObject, parentId, groupDeveloperName, rowCause, accessLevel);
                        if(apexSharingsByKeyForAddService.containsKey(keyWithGroupDeveloperNameOnRemove)){
                            ApexSharing__c asror = apexSharingsByKeyForAddService.get(keyWithGroupDeveloperNameOnRemove);
                            if(asror.AccessLevel__c != accessLevel && !toAbandonApexShareServiceUnique.contains(asror.Id)){
                                asror.FutureStatus__c = 'Access Level Changed';
                                toAbandonApexShareService.add(asror);
                                toAbandonApexShareServiceUnique.add(asror.Id);
                            }
                        }
                    }
                    else{
                        Group grp = groupRecordsForGroupDeveloperNames.get(groupDeveloperName);
                        if(grp != null){
                            Id groupId = grp.Id;
                            String keyWithGroupId = key(a.shareObject, parentId, groupId, rowCause, accessLevel);
                            if( (!sObjectShareRecordByKey.containsKey(keyWithGroupId)) && (!rc.discrepancyDetected()) ){
                                if(!toInsertUnique.contains(keyWithGroupId)){
                                    shareObjectMap(toInsertByShareObject, prepareShareObjectRecord(a, groupId), parentId);
                                    toInsertUnique.add(keyWithGroupId);
                                }

                                if(a.apexSharingRecordId != null){
                                    a.futureStatus = 'Shared';
                                }
                            }
                        }
                    }
                }
            }
        }

        List<List<sObject>> toInsert10ChunkTypes = new List<List<sObject>>();
        Database.SaveResult[] dmlToInsertResult = new List<Database.SaveResult>();
        
        if(toInsertByShareObject.size() > 0){
          List<sObject> temp;
          Integer chunk = 0;

          for(String sObjectType : toInsertByShareObject.keySet()){
            if(chunk == 0){
                temp = new List<sObject>();
            }
            temp.addAll( toInsertByShareObject.get(sObjectType) );

            chunk++;

            if(chunk == 9){
                chunk = 0;
                toInsert10ChunkTypes.add( temp );
            }
          }

          if(!temp.isEmpty()){
            toInsert10ChunkTypes.add( temp );
          }

          for(List<sObject> chunkOf10 : toInsert10ChunkTypes){
            dmlToInsertResult.addAll( Database.insert(chunkOf10, false) );
          }
          
          
        }
        
        List<String> errorMessages = new List<String>();
        System.debug('toInsert toInsert10ChunkTypes ' + toInsert10ChunkTypes);
        if( dmlToInsertResult.size() > 0 ){
            for(Database.SaveResult sr : dmlToInsertResult){
                if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                  
                        errorMessages.add(String.valueOf(err.getStatusCode()));
                        errorMessages.add(err.getMessage());
                        errorMessages.add(String.valueOf(err.getFields()));
                    }
                }
            }
        }
        
        if(errorMessages.size() > 0){
            
            System.debug('errorMessagestoInsert :: ' + toInsert10ChunkTypes);
            System.debug('errorMessages :: ' + String.join(errorMessages, ' ::'));
        
            if(throwErrorIfSingleRecordDmlFails == true){
            	throw new CustomException(String.join(errorMessages, ' ::'));   
            } 
        }

        if(toAbandonApexShareService.size() > 0){
            if(doNotCache == true){
                delete toAbandonApexShareService;
            }
            else{
                update toAbandonApexShareService;
            }
        }

        if(toInsertApexShareService.size() > 0){
            insert toInsertApexShareService;
        }
    }

    public class ShareServiceRecordCreator{
        private Boolean discrepancyDetected = false;
        private Boolean needToCreate = false;

        private String PERSON = 'Person';
        private String USER = 'User';
        private String GROUP_LEVEL = 'Group';

        private String USER_RECORD_ABSENT = 'User Record Absent';
        private String USER_IS_INACTIVE = 'User Is Inactive';
        private String KEY_MISSING = 'Key Missing On Person/ User';
        private String KEY_MISMATCH = 'Key Mismatch Between Person Record And User Record';
        private String GROUP_MISSING = 'Group Missing';

        public ApexSharing__c recordCreated = new ApexSharing__c();

        Map<String, ApexSharing__c> apexSharingsByAllPossibleKeys;
        public ShareServiceRecordCreator(Map<String, ApexSharing__c> apexSharingsByAllPossibleKeys){
            this.apexSharingsByAllPossibleKeys = apexSharingsByAllPossibleKeys;
        }

        public Boolean needToCreate(){
            return needToCreate;
        }

        public Boolean discrepancyDetected(){
            return discrepancyDetected;
        }

        public ApexSharing__c getCreatedRecord(){
            return recordCreated;
        }

        public void determineForPersonId(ApexSharingService a, Id personId){
            String keyForPersonId = key(a.shareObject, a.recordId, personId, a.rowCause, a.accessLevel);
            if(apexSharingsByAllPossibleKeys.containsKey(keyForPersonId)){
                needToCreate = false;
            }else{
                needToCreate = true;
            }
            

            if(personRecordsForPersonIds.get(personId).SymphonyLF__User__c == null){
                recordCreated.ReasonForNotSharing__c = USER_RECORD_ABSENT;
                discrepancyDetected = true;
            }
            else if(personRecordsForPersonIds.get(personId).SymphonyLF__User__r.IsActive == false){
                recordCreated.ReasonForNotSharing__c = USER_IS_INACTIVE;
                discrepancyDetected = true;
            }

            if(matchPersonAndUserField){
                sObject personRecord = personRecordsForPersonIds.get(personId);
                String personFieldForMatchingValue = String.valueOf(
                    personRecord.get(personFieldForMatching)
                );

                sObject userRecord = personRecord.getSObject('SymphonyLF__User__r');
                String userFieldForMatchingValue = String.valueOf(
                    userRecord.get(userFieldForMatching)
                );

                if(
                    String.isBlank(personFieldForMatchingValue) 
                    || 
                    String.isBlank(userFieldForMatchingValue) 
                    ||
                    personFieldForMatchingValue == null
                    ||
                    userFieldForMatchingValue == null
                ){
                    recordCreated.ReasonForNotSharing__c = KEY_MISSING;
                    discrepancyDetected = true;
                }
                else if( personFieldForMatchingValue != userFieldForMatchingValue ){
                    recordCreated.ReasonForNotSharing__c = KEY_MISMATCH;
                    recordCreated.PersonKey__c = personFieldForMatchingValue;
                    recordCreated.UserKey__c = userFieldForMatchingValue;
                    recordCreated.UserKeyUser__c = personRecordsForPersonIds.get(personId).SymphonyLF__User__c;
                    discrepancyDetected = true;
                }
            }
            

            if(discrepancyDetected == false){
                return;
            }

            recordCreated.ShareObject__c = a.shareObject;
            recordCreated.RecordId__c = a.recordId;
            recordCreated.PersonToShareWith__c = personId;
            recordCreated.RowCause__c = a.rowCause;
            recordCreated.AccessLevel__c = a.accessLevel;
            recordCreated.Module__c = a.module;

            recordCreated.InitiationPoint__c = PERSON;
        }

        public void determineForUserId(ApexSharingService a, Id userId){
            String keyForUserId= key(a.shareObject, a.recordId, userId, a.rowCause, a.accessLevel);
            if(apexSharingsByAllPossibleKeys.containsKey(keyForUserId)){
                needToCreate = false;
            }else{
                needToCreate = true;
            }

            if(userRecordsForUserIds.get(userId).IsActive == false){
                recordCreated.ReasonForNotSharing__c = USER_IS_INACTIVE;
                discrepancyDetected = true;
            }

            if(discrepancyDetected == false){
                return;
            }

            recordCreated.ShareObject__c = a.shareObject;
            recordCreated.RecordId__c = a.recordId;
            recordCreated.UserToShareWith__c = userId;
            recordCreated.RowCause__c = a.rowCause;
            recordCreated.AccessLevel__c = a.accessLevel;
            recordCreated.Module__c = a.module;

            recordCreated.InitiationPoint__c = USER;
        }

        public void determineForGroupId(ApexSharingService a, Id groupId){
            String keyForGroupId= key(a.shareObject, a.recordId, groupId, a.rowCause, a.accessLevel);
            if(apexSharingsByAllPossibleKeys.containsKey(keyForGroupId)){
                needToCreate = false;
            }else{
                needToCreate = true;
            }

            if(groupRecordsForGroupIds.get(groupId) == null){
                recordCreated.ReasonForNotSharing__c = GROUP_MISSING;
                discrepancyDetected = true;
            }

            if(discrepancyDetected == false){
                return;
            }

            recordCreated.ShareObject__c = a.shareObject;
            recordCreated.RecordId__c = a.recordId;
            recordCreated.GroupIdToShareWith__c = groupId;
            recordCreated.RowCause__c = a.rowCause;
            recordCreated.AccessLevel__c = a.accessLevel;
            recordCreated.Module__c = a.module;

            recordCreated.InitiationPoint__c = GROUP_LEVEL;
        }

        public void determineForGroupDeveloperName(ApexSharingService a, String groupDeveloperName){
            String keyForGroupDeveloperName = key(a.shareObject, a.recordId, groupDeveloperName, a.rowCause, a.accessLevel);
            if(apexSharingsByAllPossibleKeys.containsKey(keyForGroupDeveloperName)){
                needToCreate = false;
            }else{
                needToCreate = true;
            }

            if(groupRecordsForGroupDeveloperNames.get(groupDeveloperName) == null){
                recordCreated.ReasonForNotSharing__c = GROUP_MISSING;
                discrepancyDetected = true;
            }

            if(discrepancyDetected == false){
                return;
            }

            recordCreated.ShareObject__c = a.shareObject;
            recordCreated.RecordId__c = a.recordId;
            recordCreated.GroupToShareWith__c = groupDeveloperName;
            recordCreated.RowCause__c = a.rowCause;
            recordCreated.AccessLevel__c = a.accessLevel;
            recordCreated.Module__c = a.module;

            recordCreated.InitiationPoint__c = GROUP_LEVEL;
        }
    }

    private static sObject prepareShareObjectRecord(ApexSharingService a, Id userOrGroupId){
        sObject newShare = (sObject) Type.forName(a.shareObject).newInstance();
        newShare.put('RowCause', a.rowCause);
        newShare.put('AccessLevel', a.accessLevel);
        newShare.put('ParentId', a.recordId);
        newShare.put('UserOrGroupId', userOrGroupId);

        system.debug('newSharenewSharenewShare ' + newShare);
        return newShare;
    }

    private static void removeSObjectShareRecordsAndRemoveApexSharingServiceRecords(Map<String, ServiceStatistics> serviceStatisticsBySObject){
        Map<String, List<sObject>> toDeleteByShareObject = new Map<String, List<sObject>>();
        List<ApexSharing__c> toDeleteApexShareService = new List<ApexSharing__c>();
        Set<Id> toDeleteUnique = new Set<Id>();
        Set<Id> toDeleteApexShareServiceUnique = new Set<Id>();

        for(String sObjectShare : serviceStatisticsBySObject.keySet()){
            ServiceStatistics s = serviceStatisticsBySObject.get(sObjectShare);
            Set<Id> recordIds = s.recordIds;
            Set<String> rowCauses = s.rowCauses;
            Set<Id> userOrGroupIds = new Set<Id>();
            for(Id i : s.personIds){
                Id userId = personRecordsForPersonIds.get(i).SymphonyLF__User__c;
                if(userId != null){
                    userOrGroupIds.add(userId);
                }
            }
            for(String g : s.groupDeveloperNames){
                Group grp = groupRecordsForGroupDeveloperNames.get(g);
                if(grp != null){
                    userOrGroupIds.add( grp.Id );
                }
            }
            userOrGroupIds.addAll(s.userIds);
            userOrGroupIds.addAll(s.groupIds);
            
            ShareObjectSelector shareObjectSelector = new ShareObjectSelector(sObjectShare);
            List<ShareObjectSelectorJSON> sObjectShares = shareObjectSelector.selectByParentIdAndUserOrGroupIdAndRowCause(recordIds, userOrGroupIds, rowCauses);

            Map<String, sObject> sObjectShareRecordByKey = new Map<String, sObject>();
            for(ShareObjectSelectorJSON sJSON : sObjectShares){
                sObjectShareRecordByKey.put( keyOnRemove(sJSON) , sJSON.record);
            }

            for(ApexSharingService a : s.sharesOfSameSObject){
                Id parentId = a.recordId;
                String rowCause = a.rowCause;
                String accessLevel = a.accessLevel;
                for(Id i : a.userIds){
                    Id userId = i;
                    String keyWithUserId = keyOnRemove(a.shareObject, parentId, userId, rowCause, accessLevel);
                    if(sObjectShareRecordByKey.containsKey( keyWithUserId )){
                        Id keyed = (Id) sObjectShareRecordByKey.get(keyWithUserId).get('Id');
                        if(!toDeleteUnique.contains( keyed )){
                            shareObjectMap(toDeleteByShareObject, sObjectShareRecordByKey.get(keyWithUserId), parentId);
                            toDeleteUnique.add(keyed);
                        }
                    }
                    if(apexSharingsByKeyForRemoveService.containsKey(keyWithUserId)){
                        Id keyed = apexSharingsByKeyForRemoveService.get(keyWithUserId).Id;
                        if(!toDeleteApexShareServiceUnique.contains(keyed)){
                            toDeleteApexShareService.add(apexSharingsByKeyForRemoveService.get(keyWithUserId));
                            toDeleteApexShareServiceUnique.add(keyed);
                        }
                    }
                }

                for(Id i : a.groupIds){
                    Id groupId = i;
                    String keyWithGroupId = keyOnRemove(a.shareObject, parentId, groupId, rowCause, accessLevel);
                    if(sObjectShareRecordByKey.containsKey( keyWithGroupId )){
                        Id keyed = (Id) sObjectShareRecordByKey.get(keyWithGroupId).get('Id');
                        if(!toDeleteUnique.contains( keyed )){
                            shareObjectMap(toDeleteByShareObject, sObjectShareRecordByKey.get(keyWithGroupId), parentId);
                            toDeleteUnique.add(keyed);
                        }
                    }
                    if(apexSharingsByKeyForRemoveService.containsKey(keyWithGroupId)){
                        Id keyed = apexSharingsByKeyForRemoveService.get(keyWithGroupId).Id;
                        if(!toDeleteApexShareServiceUnique.contains(keyed)){
                            toDeleteApexShareService.add(apexSharingsByKeyForRemoveService.get(keyWithGroupId));
                            toDeleteApexShareServiceUnique.add(keyed);
                        }
                    }
                }

                for(Id i : a.personIds){
                    Id personId = i;
                    Id userId = personRecordsForPersonIds.get(i).SymphonyLF__User__c;
                    if(userId != null){
                        String keyWithUserId = keyOnRemove(a.shareObject, parentId, userId, rowCause, accessLevel);
                        if(sObjectShareRecordByKey.containsKey( keyWithUserId )){
                            Id keyed = (Id) sObjectShareRecordByKey.get(keyWithUserId).get('Id');
                            if(!toDeleteUnique.contains( keyed )){
                                shareObjectMap(toDeleteByShareObject, sObjectShareRecordByKey.get(keyWithUserId), parentId);
                                toDeleteUnique.add(keyed);
                            }
                        }
                    }
                    String keyWithPersonId = keyOnRemove(a.shareObject, parentId, personId, rowCause, accessLevel);
                    if(apexSharingsByKeyForRemoveService.containsKey(keyWithPersonId)){
                        Id keyed = apexSharingsByKeyForRemoveService.get(keyWithPersonId).Id;
                        if(!toDeleteApexShareServiceUnique.contains(keyed)){
                            toDeleteApexShareService.add(apexSharingsByKeyForRemoveService.get(keyWithPersonId));
                            toDeleteApexShareServiceUnique.add(keyed);
                        }
                    }
                }

                for(String i : a.groupDeveloperNames){
                    String groupDeveloperName = i;
                    Group grp = groupRecordsForGroupDeveloperNames.get(groupDeveloperName);
                    if(grp != null){
                        Id groupId = grp.Id;
                        String keyWithGroupId = keyOnRemove(a.shareObject, parentId, groupId, rowCause, accessLevel);
                        if(sObjectShareRecordByKey.containsKey( keyWithGroupId )){
                            Id keyed = (Id) sObjectShareRecordByKey.get(keyWithGroupId).get('Id');
                            if(!toDeleteUnique.contains( keyed )){
                                shareObjectMap(toDeleteByShareObject, sObjectShareRecordByKey.get(keyWithGroupId), parentId);
                                toDeleteUnique.add(keyed);
                            }
                        }
                    }
                    String keyWithGroupDeveloperName = keyOnRemove(a.shareObject, parentId, groupDeveloperName, rowCause, accessLevel);
                    if(apexSharingsByKeyForRemoveService.containsKey(keyWithGroupDeveloperName)){
                        Id keyed = apexSharingsByKeyForRemoveService.get(keyWithGroupDeveloperName).Id;
                        if(!toDeleteApexShareServiceUnique.contains(keyed)){
                            toDeleteApexShareService.add(apexSharingsByKeyForRemoveService.get(keyWithGroupDeveloperName));
                            toDeleteApexShareServiceUnique.add(keyed);
                        }
                    }
                }
            }
        }

        List<List<sObject>> toDelete10ChunkTypes = new List<List<sObject>>();
        if(toDeleteByShareObject.size() > 0){
            List<sObject> temp;
            Integer chunk = 0;

          for(String sObjectType : toDeleteByShareObject.keySet()){
            if(chunk == 0){
                temp = new List<sObject>();
            }
            temp.addAll( toDeleteByShareObject.get(sObjectType) );

            chunk++;

            if(chunk == 9){
                chunk = 0;
                toDelete10ChunkTypes.add( temp );
            }
          }
          if(!temp.isEmpty()){
            toDelete10ChunkTypes.add( temp );
          }

          for(List<sObject> chunkOf10 : toDelete10ChunkTypes){
             delete chunkOf10;
          }
            
        }

        if(toDeleteApexShareService.size() > 0){
            delete toDeleteApexShareService;
        }
    }

    private static String key(ShareObjectSelectorJSON s){
        return s.shareObjectName + '|' + s.parentId + '|' + s.userOrGroupId + '|' + s.rowCause + '|' + s.accessLevel;
    }

    private static String key(String shareObjectName, Id parentId, Id userOrGroupOrPersonId, String rowCause, String accessLevel){
        return shareObjectName + '|' + parentId + '|' + userOrGroupOrPersonId + '|' + rowCause + '|' + accessLevel;
    }

    private static String key(String shareObjectName, Id parentId, String groupDeveloperName, String rowCause, String accessLevel){
        return shareObjectName + '|' + parentId + '|' + groupDeveloperName + '|' + rowCause + '|' + accessLevel;
    }

    private static String keyOnRemove(ShareObjectSelectorJSON s){
        return s.shareObjectName + '|' + s.parentId + '|' + s.userOrGroupId + '|' + s.rowCause;
    }

    private static String keyOnRemove(String shareObjectName, Id parentId, Id userOrGroupOrPersonId, String rowCause, String accessLevel){
        return shareObjectName + '|' + parentId + '|' + userOrGroupOrPersonId + '|' + rowCause;
    }

    private static String keyOnRemove(String shareObjectName, Id parentId, String groupDeveloperName, String rowCause, String accessLevel){
        return shareObjectName + '|' + parentId + '|' + groupDeveloperName + '|' + rowCause;
    }

    private static Map<String, ApexSharing__c> apexSharingsByAllPossibleKeys(List<ApexSharingService> addOrRemoveServicesList){
        Set<String> shareObjects = new Set<String>();
        Set<String> rowCauses = new Set<String>();
        Set<Id> recordIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> personIds = new Set<Id>();
        Set<String> groupDeveloperNames = new Set<String>();
        Set<Id> groupIds = new Set<Id>();

        for(ApexSharingService a : addOrRemoveServicesList){
            shareObjects.add( a.shareObject );
            rowCauses.add( a.rowCause );
            recordIds.add( a.recordId );
            userIds.addAll( a.userIds );
            personIds.addAll( a.personIds );
            groupDeveloperNames.addAll( a.groupDeveloperNames );
            groupIds.addAll( a.groupIds );
        }

        List<ApexSharing__c> apexSharings = [
            SELECT Id, 
                ShareObject__c,
                RowCause__c,
                RecordId__c,
                AccessLevel__c,
                UserToShareWith__c,
                PersonToShareWith__c,
                GroupToShareWith__c,
                GroupIdToShareWith__c
            FROM ApexSharing__c
            WHERE FutureStatus__c = 'Pending'
                AND ShareObject__c IN :shareObjects
                AND RowCause__c IN :rowCauses
                AND RecordId__c IN :recordIds
                AND ( UserToShareWith__c IN :userIds
                        OR 
                     PersonToShareWith__c IN :personIds 
                        OR
                     GroupToShareWith__c IN :groupDeveloperNames
                        OR
                     GroupIdToShareWith__c IN :groupIds
                    )
            FOR UPDATE
        ];

        Map<String, ApexSharing__c> apexSharingsByKey = new Map<String, ApexSharing__c>();
        for(ApexSharing__c a : apexSharings){
            if(a.UserToShareWith__c != null){
                String keyWithUserId = key(a.ShareObject__c, a.RecordId__c, a.UserToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithUserId, a);
                
                keyWithUserId = keyOnRemove(a.ShareObject__c, a.RecordId__c, a.UserToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithUserId, a);
            }

            if(a.PersonToShareWith__c != null){
                String keyWithPersonId = key(a.ShareObject__c, a.RecordId__c, a.PersonToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithPersonId, a);

                keyWithPersonId = keyOnRemove(a.ShareObject__c, a.RecordId__c, a.PersonToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithPersonId, a);
            }
            
            if(String.isNotBlank(a.GroupToShareWith__c)){
                String keyWithGroupDeveloperName = key(a.ShareObject__c, a.RecordId__c, a.GroupToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithGroupDeveloperName, a);

                keyWithGroupDeveloperName = keyOnRemove(a.ShareObject__c, a.RecordId__c, a.GroupToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithGroupDeveloperName, a);
            } 

            if(a.GroupIdToShareWith__c != null){
                String keyWithGroupId = key(a.ShareObject__c, a.RecordId__c, a.GroupIdToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithGroupId, a);

                keyWithGroupId = keyOnRemove(a.ShareObject__c, a.RecordId__c, a.GroupIdToShareWith__c, a.RowCause__c, a.AccessLevel__c);
                apexSharingsByKey.put(keyWithGroupId, a);
            }
        }

        return apexSharingsByKey;
    }

    private static Map<String, ServiceStatistics> serviceStatistics(List<ApexSharingService> sharesInService){
        Map<String, ServiceStatistics> statisticsBySObject = new Map<String, ServiceStatistics>();
        for(ApexSharingService r : sharesInService){
            String shareObject = r.shareObject;
            if(statisticsBySObject.containsKey(shareObject)){
                ServiceStatistics s = statisticsBySObject.get(shareObject);
                s.include(r);
            }else{
                statisticsBySObject.put(shareObject, new ServiceStatistics(r));
            }
        }
        return statisticsBySObject;
    }

    public class ServiceStatistics{
        public List<ApexSharingService> sharesOfSameSObject = new List<ApexSharingService>();
        public Set<Id> recordIds = new Set<Id>();
        public Set<Id> personIds = new Set<Id>();
        public Set<Id> userIds = new Set<Id>();
        public Set<Id> groupIds = new Set<Id>();
        public Set<String> groupDeveloperNames = new Set<String>();
        public Set<String> rowCauses = new Set<String>();
        public Set<Id> clientIds = new Set<Id>();

        public ServiceStatistics(ApexSharingService a){
            calculate(a);
        }

        public void include(ApexSharingService a){
            calculate(a);
        }

        private void calculate(ApexSharingService a){
            sharesOfSameSObject.add(a);
            recordIds.add(a.recordId);
            personIds.addAll(a.personIds);
            userIds.addAll(a.userIds);
            groupIds.addAll(a.groupIds);
            rowCauses.add(a.rowCause);
            groupDeveloperNames.addAll(a.groupDeveloperNames);
            clientIds.add(a.clientId);
        }
    }

    private static void fetchPersonRecords(){
        if( (personIdsInService == null || personIdsInService.size() == 0) && ( wallOffUserIds == null || wallOffUserIds.size() == 0 ) ){
            return;
        }
        PersonSelector personSelector = new PersonSelector();
        setPersonFields(personSelector);
        personRecordsForPersonIds = personSelector.selectByIdOrUserIds(personIdsInService, wallOffUserIds);
    }

    private static void setPersonFields(PersonSelector personSelector){
        List<String> personFields = new List<String>{
            'Id',
            'SymphonyLF__Email__c',
            'SymphonyLF__User__c',
           // 'SymphonyIPM__Employee_ID__c',
            'SymphonyLF__User__r.IsActive',
            'SymphonyLF__User__r.FederationIdentifier'
        };

        if(matchPersonAndUserField){
            personFields.add(personFieldForMatching);
            personFields.add('SymphonyLF__User__r.' + userFieldForMatching);
        }

        personSelector.setFields(personFields);
    }

    private static void fetchUserRecords(){
        if(userIdsInService == null || userIdsInService.size() == 0){
            return;
        }

        UserSelector userSelector = new UserSelector();
        setUserFields(userSelector);
        userRecordsForUserIds = userSelector.selectById(userIdsInService);
    }

    private static void setUserFields(UserSelector userSelector){
        List<String> userFields = new List<String>{
            'Id',
            'IsActive'
        };
        
        if(matchPersonAndUserField){
            userFields.add(userFieldForMatching);
        }
        userSelector.setFields(userFields);
    }

	private static void fetchGroupRecords(){
        if(
            groupDeveloperNamesInService.size() == 0 
            &&
            groupIdsInService.size() == 0
        ){
            return;
        }

        List<Group> groups = [
            SELECT Id, DeveloperName
            FROM Group
            WHERE DeveloperName IN :groupDeveloperNamesInService
                OR Id IN :groupIdsInService
        ];

        for(Group g : groups){
            groupRecordsForGroupDeveloperNames.put(g.DeveloperName, g);
            groupRecordsForGroupIds.put(g.Id, g);
        }
	} 

    private static void fetchWallOff(){
        if(clientIdsInService == null || clientIdsInService.size() == 0){
            return;
        }

        Set<String> fieldsToFetch = new Set<String>{
            'Client__c',
            'User__c'
        };
        fieldsToFetch.addAll( lookupFieldsToWallOff );

        String query = ' SELECT ' + String.join(fieldsToFetch, ', ') +
                        ' FROM ' +
                        '   Access_Restriction__c ' +
                        ' WHERE ' +
                        '   Client__c IN :clientIdsInService ' +
                        '   AND ' +
                        '   User__c != null ';
        
        {
            List<String> whereIn = new List<String>();
            for(String l : lookupFieldsToWallOff){
                whereIn.add( l + ' IN :recordIdsInService ');
            }

            if(whereIn.size() > 0){
                query += ' AND ( ' + String.join(whereIn, ' OR ') + ' ) ';
            }
        }

        List<sObject> wallOffRecords = Database.query( query );
        for(sObject wallOff : wallOffRecords){
            Id userId = (Id) wallOff.get('User__c');
            wallOffUserIds.add( userId );
        }
    }

    private static void makeWallOffIdentifiers(){
        for(sObject wallOff : wallOffRecords){
            Id clientId = (Id) wallOff.get('Client__c');
            Id userId = (Id) wallOff.get('User__c');

            for(String lookup : lookupFieldsToWallOff){
                Id notAllowId = (Id) wallOff.get(lookup);
                if(notAllowId == null){
                    continue;
                }

                notAllowedWalledOffs.add( wallOffKeyMaker(clientId, notAllowId, userId )  );

                Set<Id> personIds = personIdsByUserId.get( userId );
                if(personIds == null){
                    continue;
                }

                for(Id personId : personIds){
                    notAllowedWalledOffs.add( wallOffKeyMaker(clientId, notAllowId, personId )  );
                }
            }
        }
    }

    private static String wallOffKeyMaker(Id clientId, Id recordId, Id personOrUserId){
        return clientId + '-' + recordId + '-' + personOrUserId;
    }

    private static Boolean ignoreForSharingDueToWallOff(Id clientId, Id recordId, Id personOrUserId){
        if(clientId == null){
            return false;
        }

        if(
            notAllowedWalledOffs.contains(
                wallOffKeyMaker( clientId, recordId, personOrUserId )
            )
        ){
            return true;
        }

        if(
            notAllowedWalledOffs.contains(
                wallOffKeyMaker( clientId, clientId, personOrUserId )
            )
        ){
            return true;
        }

        return false;
    }

    private static Set<String> findLookupFieldOnWallOff(){
        Set<String> output = new Set<String>();

        Map<String, Schema.SObjectField> fieldsMap = Access_Restriction__c.sObjectType.getDescribe().fields.getMap();

        for (Schema.SObjectField field : fieldsMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                output.add(fieldDescribe.getName());
            }
        }

        output.remove('LastModifiedById');
        output.remove('CreatedById');
        output.remove('Client__c');

        return output;
    }
/*
	private static void moveTheProcessToAsynchronousJob(){
        ApexSharingServiceQueable queueable = new ApexSharingServiceQueable();
        queueable.setAddSharesInServiceLeftToBeProcessed(addSharesInService);
        queueable.setRemoveSharesInServiceLeftToBeProcessed(removeSharesInService);

        QueueableGovernor g = new QueueableGovernor();
        g.setQueableObject(queueable);
        g.registerToQueue();
        QueueableGovernor.startExecutingQueue();
	}
*/
    @InvocableMethod
    public static List<InvocableReponse> get(List<InvocableRequest> requestList) {
      //  try{
            String lockIdValue = LockerSerVice.generateUniqueLockId('ApexSharingService.get(List<ApexSharingService.InvocableRequest> requestList)');
            List<InvocableReponse> results = new List<InvocableReponse>();
            LockerService.applyLocksAcrossServices(lockIdValue);
            for(InvocableRequest r : requestList){

                if(String.isBlank(r.UserId) && String.isBlank(r.personId) && String.isBlank(r.groupDeveloperName) && String.isBlank(r.groupId)){

                }else{
                    ApexSharingService a = new ApexSharingService();
                    a.setShareObject(r.shareObject);
                    a.setRecordId(r.parentId);
                    if(String.isNotBlank(r.rowCause)){
                        a.setRowCause(r.rowCause);
                    }else{
                        a.setRowCause('Manual');
                    }

                    if(String.isNotBlank(r.clientId)){
                        a.setClientId( r.clientId );
                    }
                    
                    if(String.isNotBlank(r.UserId)){
                        a.setUserIds(new Set<Id>{r.UserId});
                    }
                    if(String.isNotBlank(r.personId)){
                        a.setPersonIds(new Set<Id>{r.personId});
                    }
                    if(String.isNotBlank(r.groupId)){
                        a.setGroupIds(new Set<Id>{r.groupId});
                    }
                    if(String.isNotBlank(r.groupDeveloperName)){
                        a.setGroupDeveloperNames(new Set<String>{r.groupDeveloperName});
                    }
                    a.setAccessLevel(r.accessLevel);

                    if(r.removeShare != null && r.removeShare == true){
                        a.removeShare();
                    }else{
                        a.addShare();
                    }
                }

                InvocableReponse result = new InvocableReponse();
                results.add(result);
            }
            LockerService.releaseLockAcrossServices(lockIdValue);
            return results;
        /*}catch(Exception ex){
            throw new CustomException(ex.getStackTraceString() + ' ---> ' + ex.getMessage() + ' ---> ' + ex.getCause() + '--->' + ex.getCause() + ' ---> ' +ex.getNumDml()  + ex.getCause() + ' ---> ' +ex.getTypeName() + ex.getCause() + ' ---> ' );
        }*/
    }

    public class CustomException extends Exception{

    }

    public class InvocableRequest {
        @InvocableVariable 
        public String shareObject;

        @InvocableVariable 
        public String parentId;

        @InvocableVariable
        public String UserId;

        @InvocableVariable
        public String personId;

        @InvocableVariable
        public String groupId;

        @InvocableVariable
        public String groupDeveloperName;

        @InvocableVariable
        public String rowCause;

        @InvocableVariable
        public String accessLevel;

        @InvocableVariable
        public Boolean removeShare;

        @InvocableVariable
        public String clientId;
    }

    public class InvocableReponse {
        @InvocableVariable 
        public String shareRecordId;
    }

    public class PersonFieldAndUserConfigurationMandatoryException extends Exception{

    }
    
    
}

/*
     The Sharing Object.

This is a bit complex to get at. atleast for me. You might be aware that every object has its own Share object. So, Account has AccountShare and Customobj__c has Customobj__Share
When you insert or update records in this object you might receive the same error message. There are a number of reasons for this to happen.

    If you are trying to share "Record X" with "User Y" and you yourself do not have access to "Record x", this error happens.
    If you are trying to share "Record X" with "User Y" and "User Y" does not have access to the object (the profile level permission, create read edit delete), this error happens.
    If you are trying to share "Record X" with "User Y" and "User Y" already has access to "Record X" this error happens.
     */