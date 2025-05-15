/* Copyright © 2023 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sandeep Talari, Jan 2024
 * Modified by Pranav G, Sept 2024
 */
public without sharing class SnowFieldVisibility{
    
    @AuraEnabled
    public static List<Boolean> CheckServiceNowAccess(string clientId){
        List<Boolean> serviceNowFlags = new List<Boolean>();
        Boolean isIpsuClient = false;
        Boolean serviceNowIntegrationRequired = false;
        Boolean isIpsuUser = false;
        Boolean status = false;
        string auditTrailLog = '';
        Boolean serviceNowOrgLevel = false;
        List<string> userRoles = new List<string>{ 'IPSU - Client Operations Support (COS)', 'IPSU Leaders', 'IPSU - Office Support Team (OST)' };
        /* if (!Test.isRunningTest()){
            serviceNowOrgLevel = AdminTriggerConfigSettings__c.getValues('Admin Trigger Config').Create_Service_Now_Cases__c;
        } else{
            serviceNowOrgLevel = true;
        } */
        try{
            auditTrailLog += 'checking service now org level->';
            if (serviceNowOrgLevel){
                Id userId = UserInfo.getUserId();
                User userRecord = [SELECT  UserRole.Name //Profile_Name__c is to be added ???
                                   FROM User
                                   WHERE Id = :userId
                                   LIMIT 1];
                if (userRecord != null){
                    auditTrailLog += ' checked current user->';
                    String userRoleName = userRecord.UserRole.Name;
                    /* if ((userRecord.Profile_Name__c == 'IPSU' && userRoleName == 'IPSU Data Management') || (userRecord.Profile_Name__c == 'Paralegal' && userRoles.contains(userRoleName))){
                        isIpsuUser = true;
                    } */
                }
                Id clientRecordId = (clientId != null) ? (Id.valueOf(clientId)) : null;
                /* if (clientRecordId != null){
                    Client__c clientRecord = [SELECT Id, Is_IPSU_Client__c, ServiceNow_Integration_Required__c
                                              FROM Client__c
                                              WHERE Id = :clientRecordId
                                              LIMIT 1];
                    auditTrailLog += 'checked client->';
                    if (clientRecord != null && clientRecord.ServiceNow_Integration_Required__c){
                        serviceNowIntegrationRequired = true;
                    }
                    if (clientRecord != null && clientRecord.Is_IPSU_Client__c){
                        isIpsuClient = true;
                    }
                } */
            }
            serviceNowFlags.add(serviceNowIntegrationRequired);
            serviceNowFlags.add(isIpsuClient);
            serviceNowFlags.add(isIpsuUser);
            auditTrailLog+='added the values to the list->response::'+serviceNowFlags;

        } catch (Exception servicenowException){
            system.debug('Exception - ' + servicenowException.getMessage() + '|Line number - ' + servicenowException.getLineNumber() + '|Cause - ' + servicenowException.getCause() + ' |StackTrace - ' + servicenowException.getStackTraceString());
            status = false;
            auditTrailLog += '\n Error by Catch Block: ' + servicenowException.getMessage() + servicenowException.getStacktraceString();
        } finally{
            HelperAudit.updateAudit('SnowFieldVisibility-CheckServiceNowAccess', auditTrailLog, status);
        }
        return serviceNowFlags;
    }

}