public with sharing class CheckListContainerController {
    public CheckListContainerController() {

    }

    @AuraEnabled
    public static User getCurrentUser(){
        try {
            User currentUser = [SELECT Id, Double_Checker__c, Profile.Name  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            return currentUser;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Checklist_Instance__c> getCheckInstanceRec(String recordId){
        try {
            return [SELECT Id, Checklist__r.Name, Checklist__r.Checklist_Code__c, CreatedDate, Status__c, Attorney__c,  Attorney__r.Name, Double_Checker__c, Double_Checker__r.Name, Secretary__c, Secretary__r.Name, Attorney_Completed__c, Double_Checker_Completed__c, Secretary_Completed__c FROM Checklist_Instance__c WHERE Id =: recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<InstanceWrapper>  getCheckListInstances(Id recordId){
        
        String objectApiName = recordId.getSObjectType().getDescribe().getName();

        String strQuery = 'SELECT Id, Checklist__r.Name, Checklist__r.Checklist_Code__c, CreatedDate, Status__c, Attorney__c,  Attorney__r.Name, Double_Checker__c, Double_Checker__r.Name, Secretary__c, Secretary__r.Name, Attorney_Completed__c, Double_Checker_Completed__c, Secretary_Completed__c FROM Checklist_Instance__c WHERE ' ;
        if(ObjectApiName == 'SymphonyLF__Patent__c'){
            strQuery += 'Patent__c = \'' + recordId + '\'';
        }else if(ObjectApiName == 'SymphonyLF__Design__c'){
            strQuery += 'Design__c = \'' + recordId + '\'';
        }
        String userType = '';
        // Get the logged-in user's Id
        String userId = UserInfo.getUserId();
        
        // Query the User object to get custom field along with other details
        User currentUser = [SELECT Id, Double_Checker__c, Profile.Name  FROM User WHERE Id = :userId LIMIT 1];
        
        if(currentUser.profile.Name == Label.Paralegal_Profile || currentUser.profile.Name == Label.Legal_Assistant_Profile ){
            userType = 'Secretary';
        }else if(currentUser.profile.Name == Label.Attorney_Profile){
            userType = 'Attorney';
        }else if(currentUser.profile.Name == 'System Administrator' || FeatureManagement.checkPermission('CheckList_Admin')){
            userType = 'SystemAdmin';
        }

        String currentUserTyper = '';
        if(currentUser.profile.Name == Label.Paralegal_Profile ){
            currentUserTyper = 'Paralegal';
        }else if(currentUser.profile.Name == Label.Legal_Assistant_Profile){
            currentUserTyper = 'Legal Assistant';
        }

        System.debug('strQuery ' + strQuery);
        System.debug('userType ' + userType);
        List<Checklist_Instance__c> instanceResults = Database.query(strQuery);
        System.debug('instanceResults ' + instanceResults);
        List<InstanceWrapper> instanceWrapperList = new List<InstanceWrapper>();
        
        if(!instanceResults.isEmpty()){
        
            for(Checklist_Instance__c instance : instanceResults){
                InstanceWrapper wrap = new InstanceWrapper();
                wrap.checkListId = instance.Id;
                wrap.checkListName = instance.Checklist__r.Name;
                wrap.checkListCode = instance.Checklist__r.Checklist_Code__c;

                if(instance.Secretary__c != null && (userType == 'Secretary' || userType == 'SystemAdmin')){
                    //wrap.secretaryEdit = true;
                    if(currentUserTyper == 'Paralegal' && ( wrap.checkListCode == 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION' || wrap.checkListCode == 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION' ) ){
                        wrap.secretaryEdit = true;
                    }else if(( currentUserTyper == 'Paralegal' || currentUserTyper == 'Legal Assistant') && wrap.checkListCode == 'CHECKLIST FOR NEW U.S. APPLICATION'){
                        wrap.secretaryEdit = true;
                    }else if(currentUserTyper == 'Legal Assistant' && ( wrap.checkListCode ==  'CHECKLIST FOR NEW U.S. DESIGN APPLICATION' || wrap.checkListCode ==  'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE' || wrap.checkListCode ==  'CHECKLIST FOR NOTICE OF ALLOWANCE' || wrap.checkListCode ==  'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION')){
                        wrap.secretaryEdit = true;
                    }else if(userType == 'SystemAdmin'){
                        wrap.secretaryEdit = true;
                    }
                }
                if(instance.Secretary_Completed__c){
                    if(instance.Attorney__c == null && ( (instance.Secretary__c == (Id)userId  && userType == 'Secretary' ) || userType == 'SystemAdmin')){
                        wrap.attorneyEdit = true;
                    }else if(instance.Attorney__c != null && ( userType == 'Attorney' || userType == 'SystemAdmin')){
                        wrap.attorneyEdit = true;
                    }
                }
                if(instance.Attorney_Completed__c && instance.Status__c != 'Filing Documents with PTO' && instance.Status__c == 'Double Checking'){
                    if(instance.Double_Checker__c == null && ( (instance.Secretary__c == (Id)userId  && userType == 'Secretary' ) ||  userType == 'SystemAdmin')){
                        wrap.doubleCheckerEdit = true;
                    }else if(instance.Double_Checker__c != null && ( currentUser.Double_Checker__c == true ||  userType == 'SystemAdmin')){
                        if( currentUserTyper == 'Paralegal' && (wrap.checkListCode == 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION' || wrap.checkListCode == 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION')){
                            wrap.doubleCheckerEdit = true;
                        }else if( currentUserTyper == 'Legal Assistant' && (wrap.checkListCode == 'CHECKLIST FOR NEW U.S. DESIGN APPLICATION' || wrap.checkListCode == 'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE' || wrap.checkListCode == 'CHECKLIST FOR NOTICE OF ALLOWANCE' || wrap.checkListCode == 'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION')){
                            wrap.doubleCheckerEdit = true;
                        }else if( ( currentUserTyper == 'Paralegal' || currentUserTyper == 'Legal Assistant') && (wrap.checkListCode == 'CHECKLIST FOR NEW U.S. APPLICATION' )){
                            wrap.doubleCheckerEdit = true;
                        }else if(userType == 'SystemAdmin'){
                            wrap.doubleCheckerEdit = true;
                        }
                        
                    }
                }
                if(instance.Status__c == 'Completed'){
                    wrap.doubleCheckerEdit = false;
                    wrap.attorneyEdit = false;
                    wrap.secretaryEdit = false;
                }
               
                
                wrap.createdDate = instance.CreatedDate.format();
                wrap.status = instance.Status__c;
                wrap.secretary = instance.Secretary__c;
                wrap.doubleChecker = instance.Double_Checker__c;
                wrap.attorney = instance.Attorney__c;
                if(instance.Status__c == 'Initial Assignment Checklist In Progress' && instance.Secretary__c == null){
                    if(wrap.checkListCode == 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION' || wrap.checkListCode == 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION' ){
                        wrap.isWaringMessage = true;
                        wrap.initialAssignmentMessage = 'Add Paralegal MEM type on matter.';
                    }else if(wrap.checkListCode == 'CHECKLIST FOR NEW U.S. APPLICATION'){
                        wrap.isWaringMessage = true;
                        wrap.initialAssignmentMessage = 'Add Legal Assistant or Paralegal MEM type on matter.';
                    }else if(wrap.checkListCode ==  'CHECKLIST FOR NEW U.S. DESIGN APPLICATION' || wrap.checkListCode ==  'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE' || wrap.checkListCode ==  'CHECKLIST FOR NOTICE OF ALLOWANCE' || wrap.checkListCode ==  'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION'){
                        wrap.isWaringMessage = true;
                        wrap.initialAssignmentMessage = 'Add Legal Assistant MEM type on matter.';
                    }
                    
                }else{
                    wrap.secretaryUser = instance.Secretary__r.Name;
                }
               
                wrap.doubleCheckerUser = instance.Double_Checker__r.Name;
                wrap.attorneyUser = instance.Attorney__r.Name;
                instanceWrapperList.add(wrap);
            }
            return instanceWrapperList;
        }
        return null;
    }

    public class InstanceWrapper{
        @AuraEnabled
        public String checkListId;
        @AuraEnabled
        public String checkListName;
        @AuraEnabled
        public String checkListCode;
        @AuraEnabled
        public String createdDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String secretary;
        @AuraEnabled
        public String secretaryUser;
        @AuraEnabled
        public String initialAssignmentMessage;
        @AuraEnabled
        public Boolean isWaringMessage;
        @AuraEnabled
        public Boolean secretaryEdit;
        @AuraEnabled
        public String attorney;
        @AuraEnabled
        public String attorneyUser;
        @AuraEnabled
        public Boolean attorneyEdit;
        @AuraEnabled
        public String doubleChecker;
        @AuraEnabled
        public String doubleCheckerUser;
        @AuraEnabled
        public Boolean doubleCheckerEdit;


    }
}