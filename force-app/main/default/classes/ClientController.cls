public without sharing class ClientController {
    public ClientController() {

    }

    @AuraEnabled
    public static Boolean canModifyRestriction(String clientId){
        List<User> loggeduser = [
        SELECT Id, Profile.Name 
        FROM User 
        WHERE Id = :userInfo.getUserId()
    ];

    if(
        APPLICATION.DEFAULT_PROFILE_WITH_RESTRICTION_ACCESS.contains( loggeduser[0].Profile.Name )
    ){
        return true;
    }
    
    ID RecordId = Id.valueOf(clientId);
    Schema.SObjectType sobjectType = RecordId.getSObjectType();
    
if(sobjectType == SymphonyLF__Client__c.SObjectType){
    
    List<SymphonyLF__Client_Engagement_Model__c> cems = [SELECT 
    Id FROM SymphonyLF__Client_Engagement_Model__c
    WHERE SymphonyLF__Client__c = :clientId  AND SymphonyLF__Type__c = :APPLICATION.DEFAULT_CEM_ROLE_WITH_RESTRICTION_ACCESS
    AND SymphonyLF__Person__r.SymphonyLF__User__c = :userInfo.getUserId() AND Is_Active__c = true LIMIT 1];

if(cems.size()>0 ){
    return true;
}

}else{

     Set<String> cemType = APPLICATION.DEFAULT_CEM_ROLE_WITH_RESTRICTION_ACCESS;
     Id userId = UserInfo.getUserId();
     String baseQuery = 'SELECT Id FROM SymphonyLF__Matter_Engagement_Model__c WHERE ';
     
     List<String> fieldsToCheck = new List<String>{
        'SymphonyLF__Patent__c',
        'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Design__c',
        'SymphonyLF__Design_Family__c',
        'SymphonyLF__Mark__c',
        'SymphonyLF__Trademark__c',
        'SymphonyLF__Copyright__c',
        'SymphonyLF__General_Matter__c',
        'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__Agreements_Contracts__c'
    };
     List<String> conditions = new List<String>();
    for(String field : fieldsToCheck){
        conditions.add(field + ' = :clientId');
    }
    
    String combinedConditions = '(' + String.join(conditions, ' OR ') + ')';
    baseQuery += combinedConditions;
    
    baseQuery += ' AND SymphonyLF__Type__c = :cemType';
    baseQuery += ' AND Person__r.SymphonyLF__User__c = :userId';
    baseQuery += ' AND Is_Active__c = true LIMIT 1';

   List<SymphonyLF__Matter_Engagement_Model__c> Mems = Database.query(baseQuery);
    
    if(Mems.size()>0 ){
    return true;
}
}
        
        return false;
    }

    @AuraEnabled
    public static String addOrRemoveRestriction(Id accessRestrictionId, String personId, String clientId, Boolean grantAccess) {
        List<Access_Restriction__c> Accesrestrictlst= new List<Access_Restriction__c>();
        system.debug(accessRestrictionId);
        List<Access_Restriction__c> currentAccessRestriction = [
            SELECT Id, Status__c 
            FROM Access_Restriction__c 
            WHERE Id = :accessRestrictionId
        ];
        
        if(currentAccessRestriction.size() != 0){
            if( currentAccessRestriction[0].Status__c == APPLICATION.RESTRICTION_STATUS_TO_GRANT){
                currentAccessRestriction[0].Status__c = APPLICATION.RESTRICTION_STATUS_ENFORCED;
                update currentAccessRestriction;
                return APPLICATION.RETURN_CODE_DELETED;
            }
            else if(currentAccessRestriction[0].Status__c == APPLICATION.RESTRICTION_STATUS_TO_ENFORCE){
                delete currentAccessRestriction;
                return APPLICATION.RETURN_CODE_DELETED;
            }
        }
        
        ID RecordId = Id.valueOf(clientId);
        Schema.SObjectType sobjectType = RecordId.getSObjectType();
        Access_Restriction__c a = new Access_Restriction__c();
        a.Id = accessRestrictionId;
        
        if(grantAccess){
            a.Status__c = APPLICATION.RESTRICTION_STATUS_TO_GRANT;
            Accesrestrictlst.add(a);
        }else{
            List<SymphonyLF__Person__c> person = [
                SELECT Id, SymphonyLF__User__c  FROM SymphonyLF__Person__c  WHERE Id = :personId];
            
            if(sobjectType == SymphonyLF__Patent__c.SObjectType){
                List<SymphonyLF__Patent__c> PatLst=[select id,SymphonyLF__Client__c from SymphonyLF__Patent__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Patent',clientId,PatLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            }
            else if(sobjectType == SymphonyLF__Trademark__c.SObjectType){
                List<SymphonyLF__Trademark__c> TMLst=[select id,SymphonyLF__Client__c from SymphonyLF__Trademark__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Trademark',clientId,TMLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            }
            else if(sobjectType == SymphonyLF__Client__c.SObjectType){
                List<SymphonyLF__Trademark__c> TMLst=[select id,SymphonyLF__Client__c from SymphonyLF__Trademark__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Client',clientId,clientId,person[0].SymphonyLF__User__c,personId));
            }
            else if(sobjectType == SymphonyLF__Design__c.SObjectType){
                List<SymphonyLF__Design__c> DesLst=[select id,SymphonyLF__Client__c from SymphonyLF__Design__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Design',clientId,DesLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            }
            else if(sobjectType == SymphonyLF__Copyright__c.SObjectType){
                List<SymphonyLF__Copyright__c> CopLst=[select id,SymphonyLF__Client__c from SymphonyLF__Copyright__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Copyright',clientId,CopLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            }
            else if(sobjectType == SymphonyLF__Agreement_Contract__c.SObjectType){
                List<SymphonyLF__Agreement_Contract__c> AgreeLst=[select id,SymphonyLF__Client__c from SymphonyLF__Agreement_Contract__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Agreement and Contract',clientId,AgreeLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            }
            else if(sobjectType == SymphonyLF__Dispute_Opposition__c.SObjectType){
                List<SymphonyLF__Dispute_Opposition__c> DisLst=[select id,SymphonyLF__Client__c from SymphonyLF__Dispute_Opposition__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Dispute/Opposition',clientId,DisLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
                
            }
            else if(sobjectType == SymphonyLF__Patent_Family__c.SObjectType){
                List<SymphonyLF__Patent_Family__c> PatfamLst=[select id,SymphonyLF__Client__c from SymphonyLF__Patent_Family__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Patent Family',clientId,PatfamLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            
            }
             else if(sobjectType == SymphonyLF__Design_Family__c.SObjectType){
                List<SymphonyLF__Design_Family__c> DesfamLst=[select id,SymphonyLF__Client__c from SymphonyLF__Design_Family__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Design Family',clientId,DesfamLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            }
            else if(sobjectType == SymphonyLF__Mark__c.SObjectType){
                List<SymphonyLF__Mark__c> DesfamLst=[select id,SymphonyLF__Client__c from SymphonyLF__Mark__c where id=:clientId];
                Accesrestrictlst.add(UpsertAccessrestriction(grantAccess,'Mark',clientId,DesfamLst[0].SymphonyLF__Client__c,person[0].SymphonyLF__User__c,personId));
            }
        }
        try{
            if(Accesrestrictlst.size()>0)
                upsert Accesrestrictlst;}
        catch(Exception e){ throw  e;}
        return APPLICATION.RETURN_CODE_UPSERTED;
    }

    Public static Access_Restriction__c UpsertAccessrestriction(Boolean grantAccess,String Type,String CurrentrecordId ,String clientId,String UserId,String personId){
        
        Access_Restriction__c a = new Access_Restriction__c();
        if(grantAccess){
            a.Status__c = APPLICATION.RESTRICTION_STATUS_TO_GRANT;
        }else{
            if(Type == 'Patent'){
            a.Patent__c= CurrentrecordId;
            a.Client__c = clientId;
            }
            else if(Type == 'Trademark'){
            a.Trademark__c= CurrentrecordId;
            a.Client__c = clientId;
           }
            else if(Type == 'Client'){
            a.Client__c = CurrentrecordId;
            a.ClientRecord__c = clientId;
           }
            else if(Type == 'Design'){
            a.Design__c = CurrentrecordId;
            a.Client__c = clientId;
            }
            else if(Type == 'Copyright'){
            a.Copyright__c = CurrentrecordId;
            a.Client__c = clientId;
            }
            else if(Type == 'Agreement and Contract'){
            a.Agreement_and_Contract__c = CurrentrecordId;
            a.Client__c = clientId;
            }
            else if(Type == 'Dispute/Opposition'){
            a.Dispute_Opposition__c = CurrentrecordId;
            a.Client__c = clientId;
            }
             else if(Type == 'Patent Family'){
            a.Patent_Family__c = CurrentrecordId;
            a.Client__c = clientId;
            }
             else if(Type == 'Design Family'){
            a.Design_Family__c = CurrentrecordId;
            a.Client__c = clientId;
            }
             else if(Type == 'Mark'){
            a.Mark__c = CurrentrecordId;
            a.Client__c = clientId;
            }
            a.Type__c=Type;
            a.Person__c = personId;
            a.User__c = UserId;
            a.Status__c = APPLICATION.RESTRICTION_STATUS_TO_ENFORCE;
        }

        return a;
    } 
    @AuraEnabled
    public static SymphonyLF__Client__c saveClient(SymphonyLF__Client__c objClient) {
    if (objClient == null) {
        throw new AuraHandledException('Client object cannot be null.');
    }    
    try {
        insert objClient;
        return objClient;
        } catch (DmlException ex) {
        System.debug('Error while inserting Client: ' + ex.getDMLMessage(0));
        throw new AuraHandledException('Failed to save client: ' + ex.getDMLMessage(0));
        }
    }

        @AuraEnabled
    public static boolean deleteClientRecord(String recordId){
        Conflict_Check__c cc = [
            SELECT Id, 
            Client_Name__c,
            Client_Name__r.Client_Status__c
            FROM Conflict_Check__c
            WHERE ID =: recordId AND Client_Name__c!=NULL
            LIMIT 1
        ];
        
        if(cc != null){
            List<SObject> recordsToDelete = new List<SObject>();
            recordsToDelete.add(cc);
            if(cc.Client_Name__r.Client_Status__c == 'Yet to Engage'){
                SymphonyLF__Client__c client = new SymphonyLF__Client__c();
                client.Id = cc.Client_Name__c;
                recordsToDelete.add(client);
                
            }
            if(recordsToDelete.size()>0){
                delete recordsToDelete;
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string WHERE_CONDITION='';
        string ActivePicklist = 'Active';
        String fields='';
        if(sObjectApiName == 'SymphonyLF__Client__c'){
            WHERE_CONDITION = 'Client_Status__c =: ActivePicklist AND ';
            fields = ',Client_Status__c';
        }
        string sQuery = 'Select Id,Name'+fields+' From ' + sObjectApiName + ' Where '+ WHERE_CONDITION+' Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }

}