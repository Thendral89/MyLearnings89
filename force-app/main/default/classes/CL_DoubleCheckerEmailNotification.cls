public without sharing class CL_DoubleCheckerEmailNotification {
    @InvocableMethod(label='Send Email To Double Checkers' description='Send Email to All Double Checkers' category='Checklist_Instance__c')
    public static void sendEmail(List<InputClass> inputRecords) {

        try {
            Messaging.reserveSingleEmailCapacity(1);
        } catch (System.NoAccessException e) {
            if(!Test.isRunningTest()) return;
        }

        Set<String> paralegalEmailSet = new Set<String>();
        Set<String> legalAssistantEmailSet = new Set<String>();

        for(User usr: [SELECT ID, Email, Profile.Name FROM USER WHERE Double_Checker__c = true AND IsActive = true LIMIT 1000]) {
            if(usr.Profile.Name == 'Paralegal') {
                paralegalEmailSet.add('priyanka.k@maxval.com');
                // paralegalEmailSet.add(usr.Email);
            } else if(usr.Profile.Name == 'Legal Assistant') {
                legalAssistantEmailSet.add('priyanka.k@maxval.com');
                // legalAssistantEmailSet.add(usr.Email);
            }
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (InputClass record : inputRecords) {
            Set<String> recipientEmailSet = new Set<String>();

            if(record.legalAssistant) {
                recipientEmailSet.addAll(legalAssistantEmailSet);
            }

            if(record.paralegal) {
                recipientEmailSet.addAll(paralegalEmailSet);
            }

            if(!recipientEmailSet.isEmpty()) {
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(record.emailTemplateId, null, record.recordId);
                email.setSaveAsActivity(false);
                List<String> recipientEmailList = new List<String>();
                recipientEmailList.addAll(recipientEmailSet);
                email.setToAddresses(recipientEmailList);
                emailList.add(email);
            }
        }

        if(!emailList.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
        }
    }


    public class InputClass {
        @InvocableVariable(label='Email Template Id' description='Email Template Id' required=true)
        public String emailTemplateId;
        @InvocableVariable(label='Record Id' description='Record Id' required=true)
        public String recordId;
        @InvocableVariable(label='Legal Assistant' description='Legal Assistant' required=true)
        public Boolean legalAssistant;
        @InvocableVariable(label='Paralegal' description='Paralegal' required=true)
        public Boolean paralegal;
    }
}