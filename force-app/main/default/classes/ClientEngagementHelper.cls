public without sharing class ClientEngagementHelper {

    // Map of Attorney Fields → Corresponding Engagement Type
    private static final Map<String, String> ATTORNEY_TYPE_MAP = new Map<String, String>{
        'Managing_Supervising_Attorney__c' => 'Managing (Supervising) Attorney',
        'Originating_Attorney__c' => 'Originating Attorney',
        'Responsible_Billing_Attorney__c' => 'Responsible (Billing) Attorney',
        'Working_Assigned_Attorney__c' => 'Working Attorney'
    };

    public static void processClientEngagementModels(List<SymphonyLF__Client__c> clients , Map<Id,SymphonyLF__Client__c> oldMap) {
        List<SymphonyLF__Client_Engagement_Model__c> engagementRecords = new List<SymphonyLF__Client_Engagement_Model__c>();
        system.debug('clients.size()'+clients.size());

        Set<Id> personIds = new Set<Id>();

        for (SymphonyLF__Client__c cli : clients) {
            if(cli.Client_Status__c == 'Active' && oldMap <> Null 
               		&& oldMap.get(cli.Id).Client_Status__c == 'Yet to Engage'){

        		for (String fieldApi : ATTORNEY_TYPE_MAP.keySet()) {
                    Id personId = (Id) cli.get(fieldApi); 
            system.debug('personId fieldAPI' +personId +''+ fieldApi);  
                    if (personId != null ) {
                       

                        engagementRecords.add(new SymphonyLF__Client_Engagement_Model__c(
                            SymphonyLF__Person__c = personId,
                            SymphonyLF__Type__c = ATTORNEY_TYPE_MAP.get(fieldApi),
                            SymphonyLF__IP_Matters__c = 'All',
                            SymphonyLF__Applicable_to_all_jurisdiction__c = true,
                            Is_Active__c = true,
                            Is_Default__c = true,
                            SymphonyLF__Client__c = cli.Id
                        ));
                    }
            	}        
            }
        }

        if (!engagementRecords.isEmpty()) {
            INSERT engagementRecords;
        }
    }
    
    public static void createSharing(List<SymphonyLF__Client__c> clients){
        list<id> recIds = new list<id>();
        for(SymphonyLF__Client__c client : clients) {
            recIds.add(client.Id);
        }
        
        if(recIds.size()>0) {
            if(System.isFuture() || System.isBatch()){
                cmpAPTrgUtilCtrl.OrgRecordSharing('SymphonyLF__Client__Share', recIds);
            }else{
                cmpAPTrgUtilCtrl.OrgRecordSharingfuture('SymphonyLF__Client__Share', recIds);
            }
        }
        
    }
}