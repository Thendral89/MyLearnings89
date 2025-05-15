public with sharing class MatterStatusUpdateService {
    List<SymphonyLF__Patent__c> newRecords;
    Map<Id, SymphonyLF__Patent__c> oldMap;

    static Boolean statusUpdateEnabledForPatent = false; 
    static Set<String> statusUpdateResrictedValuesForPatent = new Set<String>();

    static {
        List<SymphonyLF__MatterStatusUpdate__mdt> statusUpdateSettings = [
            SELECT 
                SymphonyLF__IP_Matter__c
                , SymphonyLF__Active__c
            FROM SymphonyLF__MatterStatusUpdate__mdt	
            WHERE 
                SymphonyLF__IP_Matter__c = 'Patent'
                AND
                SymphonyLF__Active__c = true
        ];

        if(statusUpdateSettings.size() > 0) {
            statusUpdateEnabledForPatent = true;
        }

        List<SymphonyLF__Asset_Status_Automation_Restrict_Config__mdt> statusRestrictConfig = [
            SELECT 
                SymphonyLF__Asset_Type__c
                , SymphonyLF__RestrictValues__c
            FROM SymphonyLF__Asset_Status_Automation_Restrict_Config__mdt
            WHERE 
                SymphonyLF__Asset_Type__c = 'Patent'
        ];

        if(
            statusRestrictConfig.size() > 0
        ){
            if(String.isNotBlank(statusRestrictConfig[0].SymphonyLF__RestrictValues__c)){
                statusUpdateResrictedValuesForPatent.addAll( 
                    statusRestrictConfig[0].SymphonyLF__RestrictValues__c.split(',')
                );
            }
        }

    }

    public MatterStatusUpdateService() {

    }

    public void setNewRecords(List<SymphonyLF__Patent__c> newRecords){
        this.newRecords = newRecords;
    }

    public void setOldMap(Map<Id, SymphonyLF__Patent__c> oldMap){
        this.oldMap = oldMap;
    }

    static Set<Id> matterIds_r = new Set<Id>();

    public void handleBeforeUpdatePatent(){
        for(SymphonyLF__Patent__c newRecord : this.newRecords){
            SymphonyLF__Patent__c oldRecord = oldMap.get(newRecord.Id);

            handlePatentStatus(newRecord, oldRecord);
        }
    }

    private void handlePatentStatus(SymphonyLF__Patent__c newRecord, SymphonyLF__Patent__c oldRecord){
        if( !statusUpdateEnabledForPatent ){
            return;
        }

        String patentStatus = newRecord.SymphonyLF__Patent_Status__c;

        if( 
            String.isNotBlank( patentStatus ) 
            && 
            statusUpdateResrictedValuesForPatent.contains( patentStatus ) 
        ){
            return;
        }

        if(
            matterIds_r.contains(newRecord.Id)
        )
        {
            return;
        }

        if(
            newRecord.SymphonyLF__Patent_Status__c != oldRecord.SymphonyLF__Patent_Status__c
            &&
            (
                newRecord.SymphonyLF__Patent_Status__c == 'Abandoned'
                ||
                newRecord.SymphonyLF__Patent_Status__c == 'Expired'
            )
        ){
            matterIds_r.add(newRecord.Id);
        }
        else if(
            newRecord.SymphonyLF__Application_Date__c != oldRecord.SymphonyLF__Application_Date__c
            ||
            newRecord.SymphonyLF__Earliest_Publication_Date__c != oldRecord.SymphonyLF__Earliest_Publication_Date__c
            ||
            newRecord.SymphonyLF__Grant_Issue_Date__c != oldRecord.SymphonyLF__Grant_Issue_Date__c
            ||
            newRecord.SymphonyLF__Patent_Status__c != oldRecord.SymphonyLF__Patent_Status__c
        ){
            if(
                newRecord.SymphonyLF__Patent_Status__c == 'Opposed'
            ){
                matterIds_r.add(newRecord.Id);
            }
            else if(
                newRecord.SymphonyLF__Application_Date__c == null 
                &&
                newRecord.SymphonyLF__Earliest_Publication_Date__c == null
                &&
                newRecord.SymphonyLF__Grant_Issue_Date__c == null
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Application Preparation';
                newRecord.SymphonyLF__Sub_Status__c = null;
                newRecord.SymphonyLF__Active__c = true;
            }
            else if(
                newRecord.SymphonyLF__Application_Date__c != null 
                &&
                newRecord.SymphonyLF__Earliest_Publication_Date__c == null
                &&
                newRecord.SymphonyLF__Grant_Issue_Date__c == null
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Pending';
                newRecord.SymphonyLF__Sub_Status__c = null;
                newRecord.SymphonyLF__Active__c = true;
            }
            else if(
                newRecord.SymphonyLF__Application_Date__c != null 
                &&
                newRecord.SymphonyLF__Earliest_Publication_Date__c != null
                &&
                newRecord.SymphonyLF__Sub_Status__c == 'Allowed'
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Pending';
                newRecord.SymphonyLF__Sub_Status__c = 'Allowed';
                newRecord.SymphonyLF__Active__c = true;
            }
            else if(
                newRecord.SymphonyLF__Application_Date__c != null 
                &&
                newRecord.SymphonyLF__Earliest_Publication_Date__c != null
                &&
                newRecord.SymphonyLF__Grant_Issue_Date__c == null
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Pending';
                newRecord.SymphonyLF__Sub_Status__c = 'Published';
                newRecord.SymphonyLF__Active__c = true;
            }
            else if(
                newRecord.SymphonyLF__Application_Date__c != null 
                &&
                newRecord.SymphonyLF__Grant_Issue_Date__c != null
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Granted';
                newRecord.SymphonyLF__Sub_Status__c = null;
                newRecord.SymphonyLF__Active__c = true;
            }
        }
        else if(
            newRecord.SymphonyLF__Abandonment_Status__c != oldRecord.SymphonyLF__Abandonment_Status__c 
            &&
            (
                newRecord.SymphonyLF__Abandonment_Status__c == 'Withdrawn'
                ||
                newRecord.SymphonyLF__Abandonment_Status__c == 'Unintended Lapse'
                ||
                newRecord.SymphonyLF__Abandonment_Status__c == 'Lapsed'
                ||
                newRecord.SymphonyLF__Abandonment_Status__c == 'Rejected/Refused/Invalidated'
            )
        ){
            if(
                newRecord.SymphonyLF__Abandonment_Status__c == 'Withdrawn'
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Abandoned';
                newRecord.SymphonyLF__Sub_Status__c = 'Withdrawn';
                newRecord.SymphonyLF__Active__c = false;
            }
            else if(
                newRecord.SymphonyLF__Abandonment_Status__c == 'Unintended Lapse'
            ){
                newRecord.SymphonyLF__Sub_Status__c = 'Unintentional';
            }
            else if(
                newRecord.SymphonyLF__Abandonment_Status__c == 'Lapsed'
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Abandoned';
                newRecord.SymphonyLF__Sub_Status__c = 'Lapsed';
                newRecord.SymphonyLF__Active__c = false;
            }
            else if(
                newRecord.SymphonyLF__Abandonment_Status__c == 'Rejected/Refused/Invalidated'
            ){
                matterIds_r.add(newRecord.Id);
                newRecord.SymphonyLF__Patent_Status__c = 'Abandoned';
                newRecord.SymphonyLF__Sub_Status__c = 'Rejected/Refused/Invalidated';
                newRecord.SymphonyLF__Active__c = false;
            }
        }
        
    }
}