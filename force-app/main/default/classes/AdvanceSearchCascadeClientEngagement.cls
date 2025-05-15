global with sharing class AdvanceSearchCascadeClientEngagement extends advs.ProcessingExtension {
    global AdvanceSearchCascadeClientEngagement() {

    }

    global override void finish() {
        Map<String, Object> argumentsMap = (Map<String, Object>) JSON.deserializeUntyped(this.arguments);
        Boolean cascadeToMemAndDockets = Boolean.valueOf(argumentsMap.get('cascadeToMemAndDockets'));
        if(cascadeToMemAndDockets == false){
            return;
        }

        Database.executeBatch(new AdvsCascadeMatterEngagementModel(this.records, this.jobStartTimeOverall, this.jobEndTimeOverall), 500);
       // AdvsCascadeMatterEngagementModel.execute(this.records, this.jobStartTimeOverall, this.jobEndTimeOverall);
    }

    
}