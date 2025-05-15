/* Copyright © 2024 MaxVal Group. All Rights Reserved.
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Modified by Dinesh R, 08/01/25 
* 
* Jira Ticket#MCC-1708
Test Class: MatterEngagementModelDomainTest
*/
trigger MatterEngagementModelTrigger on SymphonyLF__Matter_Engagement_Model__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
       mvSObjectDomain.triggerHandler(MEMTriggerHandler.class);
}