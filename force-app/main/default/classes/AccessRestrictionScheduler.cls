/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class AccessRestrictionScheduler implements Schedulable {

    private static final String TO_BE_GRANTED = 'To Be Granted';
    private static final String TO_BE_ENFORCED = 'To Be Enforced';
    private static final String PATENT = 'Patent';
    private static final String CLIENT = 'Client';
    private static final String TRADEMARK = 'Trademark';
    private static final String COPYRIGHT = 'Copyright';
    private static final String DESIGN = 'Design';
    private static final String DISPUTE = 'Dispute/Opposition';
    private static final String AGREEMENTCONTRACT = 'Agreement and Contract';
    private static final String PATENTFAMILY = 'Patent Family';
    private static final String DESIGNFAMILY = 'Design Family';
    private static final String MARK = 'Mark';
    global void execute(SchedulableContext SC) {
        List<Access_Restriction__c> accessRecords = [SELECT Id, Type__c, Patent_Family__c, Design_Family__c, Mark__c, Patent__c, Trademark__c, Design__c, Copyright__c, Agreement_and_Contract__c, Dispute_Opposition__c, Status__c, Person__r.SymphonyLF__User__c, Client__c, CreatedBy.Email, Client__r.Name
                                                        FROM Access_Restriction__c
                                                        WHERE Status__c IN (:TO_BE_GRANTED, :TO_BE_ENFORCED)];

        Map<Id,Id> grantAccess = new Map<Id,Id>();
        Map<Id,Id> removeAccess = new Map<Id,Id>();
        Map<String,Access_Restriction__c> accessRecordMap = new Map<String,Access_Restriction__c>();

        for (Access_Restriction__c record : accessRecords) {
            if (record.Person__r.SymphonyLF__User__c != null && record.Client__c != null) {
                system.debug(record.Type__c);
              Id objectId = record.Type__c == PATENT ? record.Patent__c 
              : record.Type__c == CLIENT ? record.Client__c 
              : record.Type__c == TRADEMARK ? record.Trademark__c 
              : record.Type__c == COPYRIGHT ? record.Copyright__c
              : record.Type__c == DESIGN ? record.Design__c
              : record.Type__c == AGREEMENTCONTRACT ? record.Agreement_and_Contract__c
              : record.Type__c == DISPUTE ? record.Dispute_Opposition__c
              : record.Type__c == PATENTFAMILY ? record.Patent_Family__c
              : record.Type__c == DESIGNFAMILY ? record.Design_Family__c
              : record.Type__c == MARK ? record.Mark__c
              : null; 

             accessRecordMap.put( String.valueOf(record.Person__r.SymphonyLF__User__c)+String.valueOf(objectId) , record);
              if (record.Status__c == TO_BE_GRANTED) {
                    grantAccess.put(record.Person__r.SymphonyLF__User__c , objectId);
                  } else if (record.Status__c == TO_BE_ENFORCED) {
                    removeAccess.put(record.Person__r.SymphonyLF__User__c , objectId);
                 }
            }
        }

        if (!grantAccess.isEmpty()) {
            for (Id userId : grantAccess.keySet()) {
                Id clientId = grantAccess.get(userId);
                Access_Restriction__c record = accessRecordMap.get(String.valueOf(userId)+String.valueOf(clientId));
                ClientShareControllerBatch grantBatch = new ClientShareControllerBatch(false, userId, clientId, new List<Access_Restriction__c>{record});
                Database.executeBatch(grantBatch, 150);
            }
        }

        if (!removeAccess.isEmpty()) {
            for (Id userId : removeAccess.keySet()) {
                Id clientId = removeAccess.get(userId);
                Access_Restriction__c record = accessRecordMap.get(String.valueOf(userId)+String.valueOf(clientId));
                ClientShareControllerBatch removeBatch = new ClientShareControllerBatch(true, userId, clientId, new List<Access_Restriction__c>{record});
                Database.executeBatch(removeBatch, 200);
            }
        }
    }
}