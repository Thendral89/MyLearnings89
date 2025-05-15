trigger AssetIntakeJurisdictionTrigger on Asset_Intake_Jurisdiction__c (after update) {
    if(UserInfo.getUserName() == 'mccadmin@maxval.com.mccuat'){
        mvSObjectDomain.triggerHandler(AssetIntakeJurisdictionTriggerHandler.class);
    }
}