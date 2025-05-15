public with sharing class ClientDomain {
    final static String CLIENT_AUTO_NUMBER = 'Client Auto Number Starting Point';
    final static Boolean MASTER_CLIENT = true;
    final static Set<String> CLIENT_CLASSIFICATION_TYPES_FOR_AUTONUMBER = new Set<String>{
        'Client'
    };

    private List<SymphonyLF__Client__c> newRecords;
    private Map<Id, SymphonyLF__Client__c> newMap;

    Id clientAutoNumberStartingPointId;
    Integer clientAutoNumberStartingPoint;
    List<SymphonyLF__Client__c> clientNumber = new List<SymphonyLF__Client__c>();

    public ClientDomain() {

    }

    public void setNewRecords(
        List<SymphonyLF__Client__c> newRecords, 
        Map<Id, SymphonyLF__Client__c> newMap
    ){
        this.newRecords = newRecords;
        this.newMap = newMap;
    }

    public void actionOnBeforeUpdate(){
        for(SymphonyLF__Client__c client : this.newRecords){
            clientNumber(client);
        }

        if(clientNumber.size() > 0){
            clientNumber();
        }
        
    }

    private void clientNumber(SymphonyLF__Client__c newRecord){
        if(
            String.isNotBlank(newRecord.SymphonyLF__Client_Number_New__c)
            ||
            String.isBlank(newRecord.SymphonyLF__Client_Classification__c)
        ){
            return;
        }

        Boolean isClientAutoNumber = false;
        for(String type : CLIENT_CLASSIFICATION_TYPES_FOR_AUTONUMBER){
            if(
                newRecord.SymphonyLF__Client_Classification__c.contains(type)
                && newRecord.Client_Status__c == 'Active'
                && newRecord.SymphonyLF__Master_Company__c == MASTER_CLIENT 
                && newMap.get(newRecord.Id).Client_Status__c == 'Yet to Engage'
            ){
                isClientAutoNumber = true;
                break;
            }
        }

        if(isClientAutoNumber){
            clientNumber.add(newRecord);
        }
    }

    private void clientNumber(){
        clientAutoNumberStartingPoint();

        for(SymphonyLF__Client__c client : clientNumber){
            client.SymphonyLF__Client_Number_New__c = (String.valueOf(this.clientAutoNumberStartingPoint)).leftPad(6, '0');
            this.clientAutoNumberStartingPoint++;
        }

        updateClientNumberStartingPoint();
    }


    private void clientAutoNumberStartingPoint(){
        Configuration__c clientAuto = [
            SELECT 
                Id , 
                Value__c
            FROM Configuration__c 
            WHERE Name = :CLIENT_AUTO_NUMBER
            LIMIT 1
            FOR UPDATE
        ];

        this.clientAutoNumberStartingPoint = Integer.valueOf (clientAuto.Value__c);
        this.clientAutoNumberStartingPointId = clientAuto.Id;
    }

    private void updateClientNumberStartingPoint(){
        Configuration__c c = new Configuration__c();
        c.Id = this.clientAutoNumberStartingPointId;
        c.Value__c = String.valueOf( this.clientAutoNumberStartingPoint );

        update c;
    }
}