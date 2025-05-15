public class EmailService {
    private static Boolean EmailDeliverabilityEnabled = true;
    private String emailTemplateDeveloperName;
    private Id whatId;
    private List<String> toAddresses = new List<String>();
    private List<String> ccAddress = new List<String>();
    private Set<String> personIds = new Set<String>();
    private static List<String> bccAddressWhileTesting = new List<String>();
    public String senderDisplayName = 'MCCIP';
    public String recursionIdentifierInThisInstance;
    public Id finalWhatId;
    
    private Boolean templateNotAvailable = false;
    
    public List<Messaging.SingleEmailMessage> mailToBeSentInThisInstance = new List<Messaging.SingleEmailMessage>();
    public static List<Messaging.SingleEmailMessage> allMailsToBeSent = new List<Messaging.SingleEmailMessage>();
    public static Messaging.SendEmailResult[] sendEmailresults;

    public List<EmailMessage> emailMessageInThisInstance = new List<EmailMessage>();
    public static List<EmailMessage> allEmailMessage = new List<EmailMessage>();

    private static Map<Id, Map<Id, Messaging.SingleEmailMessage>> emailByWhatIdByTemplateId = new Map<Id, Map<Id, Messaging.SingleEmailMessage>>();

    Map<Id, Id> whatIdByEmailId = new Map<Id, Id>();
    
    public static List<OrgWideEmailAddress> orgWideAddresses;
    
    public static Set<String> alreadyProcessedInService = new Set<String>();
    public static Set<String> emailTemplateDeveloperNameAlreadyProcessed = new Set<String>();
    public static Map<String, Id> emailTemplateIdByName = new Map<String, Id>();
    public static Map<Id, String> emailTemplateNameById = new Map<Id, String>();

    private List<String> formattingBody;
    private List<String> formattingSubject;

    private static Boolean developerLogOn = false;
    private String classMethodName;
    private Boolean saveAsActivity = true;

    static {
        String label = 'psodevsupport@maxval.com';//System.Label.SymphonyEmailCCsForTesting;
        String developerLogOnLabel = 'true';//System.Label.SymphonyEmailDeveloperLog;
        if(developerLogOnLabel == 'true'){
            developerLogOn = true;
        }else{
            developerLogOn = false;
        }

    }

    public void setFinalWhatId(Id finalWhatId){
        this.finalWhatId = finalWhatId;
    }

    public EmailService setDeveloperLog(String classMethodName){
        this.classMethodName = classMethodName;
        return this;
    }

    public EmailService setFormattingEmailBody(List<String> dynamicallyReplacingBody ){
        this.formattingBody = dynamicallyReplacingBody;
        return this;
    }

    public EmailService setFormattingEmailSubject(List<String> dynamicallyReplacingSubject ){
        this.formattingSubject = dynamicallyReplacingSubject;
        return this;
    }
    
    public EmailService setCCAddress(String ccEmailAddress){
        if(String.isBlank(ccEmailAddress)) return this;
        this.ccAddress.addAll(new List<String>{ccEmailAddress});
        return this;
    }

    public EmailService setCCAddress(List<String> ccEmailAddresses){
        if(ccEmailAddresses == null) return this;
        for(String s : ccEmailAddresses){
            if(String.isNotBlank(s))
            this.ccAddress.add(s);
        }
        return this;
    }
    
    public EmailService setEmailTemplate(String emailTemplateDeveloperName){
        this.emailTemplateDeveloperName = emailTemplateDeveloperName;
        if(this.recursionIdentifierInThisInstance != null &&
          alreadyProcessedInService.contains(this.recursionIdentifierInThisInstance)
          ) return this;
        
        if(
          emailTemplateDeveloperNameAlreadyProcessed.contains(emailTemplateDeveloperName)
          ) return this;
        
        List<EmailTemplate> emailTemplate = [SELECT Id,DeveloperName
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = :emailTemplateDeveloperName];
        if(emailTemplate.size() == 0) {
            System.debug( 'Email Template DeveloperName not found => ' + emailTemplateDeveloperName);
            templateNotAvailable = true;
            return this;
        }
        emailTemplateDeveloperNameAlreadyProcessed.add( emailTemplateDeveloperName );
        emailTemplateIdByName.put(emailTemplateDeveloperName, emailTemplate[0].Id);
        emailTemplateNameById.put(emailTemplate[0].Id, emailTemplateDeveloperName);
        return this;
    }
    
    public EmailService setWhatId(Id whatId){
        this.whatId = whatId;
        return this;
    }
    
    public EmailService turnOffStandardEmailLogging(){
        this.saveAsActivity = false;
        return this;
    }

    public EmailService setToAddresses(List<String> receiverEmailAddress){
        if(receiverEmailAddress == null) return this;
        List<String> filtered = new List<String>();
        for(String s : receiverEmailAddress){
            if(!String.isBlank(s))
            filtered.add(s);
        }
        this.toAddresses.addAll( filtered );
        return this;
    }

    public EmailService setToAddresses(String receiverEmailAddress){
        if(String.isEmpty(receiverEmailAddress)) return this;
        this.toAddresses.add( receiverEmailAddress );
        return this;
    }
    
    public EmailService setToAddresses(Set<Id> receiverUserOrPersonIds){
        if(receiverUserOrPersonIds == null) return this;
        Set<Id> filtered = new Set<Id>();
        for(Id i : receiverUserOrPersonIds){
            if(i != null){
                filtered.add(i);

                if(i.getSobjectType() == SymphonyLF__Person__c.sObjectType){
                    personIds.add(i);
                }
            }
        }
        this.toAddresses.addAll( (List<String>) new List<Id>(filtered) );
        return this;
    }
    
    public EmailService setCurrentRecursiveIdentifier(String recursionId){
        recursionIdentifierInThisInstance = recursionId;
        return this;
    }
    
    public static void setRecursiveCheckInService(String resursionId){
        alreadyProcessedInService.add( resursionId );
    }
    
    public List<Messaging.SingleEmailMessage> getMailToBeSentInThisInstance(){
        return mailToBeSentInThisInstance;
    }
    
    public static List<Messaging.SingleEmailMessage> getAllMailsToBeSentInService(){
        return allMailsToBeSent;
    }
    
    public void sendPreparedEmailInThisInstance(){
        if(mailToBeSentInThisInstance == null || mailToBeSentInThisInstance.size() == 0) return;
        if(templateNotAvailable) return;
        if(!Test.isRunningTest()) {
            sendEmailresults = Messaging.sendEmail(mailToBeSentInThisInstance);

            if(this.emailMessageInThisInstance.size() == 0) return;
            insert this.emailMessageInThisInstance;
        }
    }
    
    public static void sendPreparedEmailInService(){
        if(allMailsToBeSent == null || allMailsToBeSent.size() == 0) return;

        replacePersonOrUserIdsWithEmailAddress();

        if(!Test.isRunningTest()) {
            sendEmailresults = Messaging.sendEmail( allMailsToBeSent );

            system.debug('allEmailMessage' + allEmailMessage);
            
            if(allEmailMessage.size() == 0) return;
            insert allEmailMessage;
        }
    }

    public static void replacePersonOrUserIdsWithEmailAddress(){
        List<String> addresses = new List<String>();
        for(Messaging.SingleEmailMessage m : allMailsToBeSent){
            addresses.addAll(m.getToAddresses());
            addresses.addAll(m.getCcAddresses());
        }

        List<SymphonyLF__Person__c> persons = [
            SELECT Id, SymphonyLF__User__c, SymphonyLF__Email__c
            FROM SymphonyLF__Person__c
            WHERE Id IN :addresses OR SymphonyLF__User__c IN :addresses
        ];

        Map<String, SymphonyLF__Person__c> personById18 = new Map<String, SymphonyLF__Person__c>();
        Map<String, SymphonyLF__Person__c> personByUserId18 = new Map<String, SymphonyLF__Person__c>();
        Map<String, SymphonyLF__Person__c> personById15 = new Map<String, SymphonyLF__Person__c>();
        Map<String, SymphonyLF__Person__c> personByUserId15 = new Map<String, SymphonyLF__Person__c>();

        for(SymphonyLF__Person__c p : persons){
            String personIdAsString = (p.Id == null) ? '' : String.valueOf(p.Id);
            String userIdAsString = (p.SymphonyLF__User__c == null) ? '' : String.valueOf(p.SymphonyLF__User__c);

            Integer personIdAsStringLength = personIdAsString.length();
            Integer userIdAsStringLength = userIdAsString.length();

            if(personIdAsStringLength == 18){
                personById18.put(personIdAsString, p);
                personById15.put(personIdAsString.substring(0, 15), p);
            }else if(personIdAsStringLength == 15){
                personById15.put(personIdAsString, p);
            }

            if(userIdAsStringLength == 18){
                personByUserId18.put(userIdAsString, p);
                personByUserId15.put(userIdAsString.substring(0, 15), p);
            }else if(userIdAsStringLength == 15){
                personByUserId15.put(userIdAsString, p);
            }
        }

        for(Messaging.SingleEmailMessage m : allMailsToBeSent){
            List<String> toAddressTemp = new List<String>();
            for(String add : m.getToAddresses()){
                if(personById18.containsKey(add)){
                    toAddressTemp.add(personById18.get(add).SymphonyLF__User__c);
                }else if(personByUserId18.containsKey(add)){
                    toAddressTemp.add(personByUserId18.get(add).SymphonyLF__User__c);
                }else if(personById15.containsKey(add)){
                    toAddressTemp.add(personById15.get(add).SymphonyLF__User__c);
                }else if(personByUserId15.containsKey(add)){
                    toAddressTemp.add(personByUserId15.get(add).SymphonyLF__User__c);
                }else{
                    toAddressTemp.add(add);
                }
            }
            m.toaddresses = toAddressTemp;
        }

        for(Messaging.SingleEmailMessage m : allMailsToBeSent){
            List<String> ccAddressTemp = new List<String>();
            for(String add : m.getccAddresses()){
                if(personById18.containsKey(add)){
                    ccAddressTemp.add(personById18.get(add).SymphonyLF__User__c);
                }else if(personByUserId18.containsKey(add)){
                    ccAddressTemp.add(personByUserId18.get(add).SymphonyLF__User__c);
                }else if(personById15.containsKey(add)){
                    ccAddressTemp.add(personById15.get(add).SymphonyLF__User__c);
                }else if(personByUserId15.containsKey(add)){
                    ccAddressTemp.add(personByUserId15.get(add).SymphonyLF__User__c);
                }else{
                    ccAddressTemp.add(add);
                }
            }
            m.ccaddresses = ccAddressTemp;
        }
    }

    public static List<MailDeliveredValidity> validateMailDeliveryInService(){
        if(!Test.isRunningTest()){
            if( sendEmailresults == null || sendEmailresults.size() == 0 ) return null;
        }
        List< MailDeliveredValidity > validity = new List< MailDeliveredValidity >();
        
        for( Integer i = 0; i < allMailsToBeSent.size(); i++){
            MailDeliveredValidity v = new MailDeliveredValidity();
            
            v.whatId = allMailsToBeSent[i].getWhatId();
            v.emailTemplateName = emailTemplateNameById.get( allMailsToBeSent[i].getTemplateId() );
            if(!Test.isRunningTest()){
                if( sendEmailresults[i].success ){
                    v.isSuccessful = true;
                }else{
                    v.isSuccessful = false;
                }
            }
            else{
                v.isSuccessful = true;
            }

            validity.add( v );
        }
        return validity;
    }
    
    public static void clearService(){
        if(allMailsToBeSent.size() == 0) return;
        allMailsToBeSent.clear();

        if(allEmailMessage.size() == 0) return;
        allEmailMessage.clear();
    }
      
    public void prepareEmail(){
        if(templateNotAvailable) return;
        if(toAddresses == null || toAddresses.size() == 0) return;
        
        if(this.recursionIdentifierInThisInstance != null && 
           alreadyProcessedInService.contains( this.recursionIdentifierInThisInstance) 
          ) return;
        
        if(!emailTemplateIdByName.containsKey( this.emailTemplateDeveloperName )) return;
        
        Id emailTemplateId = emailTemplateIdByName.get( this.emailTemplateDeveloperName );
        
        if(orgWideAddresses == null)
        orgWideAddresses = [SELECT Id ,Address, DisplayName
                            FROM OrgWideEmailAddress 
                            WHERE DisplayName = 'MCCIP'];
        
        Messaging.SingleEmailMessage email;
        
        if(! ( emailByWhatIdByTemplateId.containsKey(whatId) && emailByWhatIdByTemplateId.get(whatId).containsKey(emailTemplateId))){
            email = Messaging.renderStoredEmailTemplate(emailTemplateId, null, whatId);
        }else{
            email = emailByWhatIdByTemplateId.get(whatId).get(emailTemplateId);
        }
        
        String emailSubject = email.getSubject();
        if(developerLogOn == true){
            //emailSubject = this.emailTemplateDeveloperName + ' :: ' +this.classMethodName +   ' >>>> ' + emailSubject;
            emailSubject = emailSubject;
        }
        String emailHTMLBody = email.getHTMLBody();
        String plainTextBody = email.getPlainTextBody();
        //String emailTextBody = email.getPlainTextBody();
        System.debug('!!!!!!!!!!!!!!!!!!!!!!! CCCCCCc !!!');
        System.debug('this.formattingBody ' + this.formattingBody);
        if( this.formattingBody != null ){
            System.debug('1 In Formatting Email Body');
            
            System.debug('emailHTMLBody Before :: ' + emailHTMLBody);
            emailHTMLBody = String.format( emailHTMLBody, this.formattingBody);
            plainTextBody = String.format( plainTextBody, this.formattingBody);
            System.debug('emailHTMLBody After :: ' + emailHTMLBody);
            //emailTextBody = String.format( emailTextBody, this.formattingBody);
        }

        if( this.formattingSubject != null){
            emailSubject =  String.format( emailSubject, this.formattingSubject);
        }

        email.setOrgWideEmailAddressId(orgWideAddresses[0].Id);
        email.setSubject(emailSubject);
        email.setHTMLBody(emailHTMLBody);
        email.setPlainTextBody(stripOutHtmlTags(plainTextBody));
        //email.setSenderDisplayName(senderDisplayName);
        if(this.saveAsActivity == true){
            email.saveAsActivity = true; // Creates Email Message and task record(part of Activity feature) with status of completed.
        }
        else{
            email.saveAsActivity = false;
        }
        
        //determineReceiverEmailAddressFromPersonRecord();

        email.toAddresses = this.toAddresses;
        email.ccaddresses = this.ccAddress;
        email.BccAddresses = bccAddressWhileTesting;

        if(this.finalWhatId != null){
            email.setWhatId(this.finalWhatId);
        }
        
        mailToBeSentInThisInstance.add( email );
        allMailsToBeSent.add( email );
      
    }

    

    public class MailDeliveredValidity{
        public String emailTemplateName;
        public String whatId;
        public Boolean isSuccessful;
    }

    private String stripOutHtmlTags(String htmlInput){
        htmlInput = htmlInput.replaceAll('<br/>', '\n');
        htmlInput = htmlInput.replaceAll('<[/a-zAZ0-9]*>','');
        htmlInput = htmlInput.replaceAll('&nbsp;','');
        return htmlInput;
    }

    @InvocableMethod
    public static List<InvocableResponse> get(List<InvocableRequest> requestList) {
        List<InvocableResponse> invocableResponses = new List<InvocableResponse>();

        for(InvocableRequest r : requestList){
            EmailService e = new EmailService();
            e.setEmailTemplate( r.emailTemplateDeveloperName );

            if( String.isNotBlank(r.toAddress)){
                e.setToAddresses( new Set<Id>{ r.toAddress } );
            }

            if(r.toAddresses != null){
                for(String s : r.toAddresses){
                    if( String.isNotBlank(s)){
                        e.setToAddresses( new Set<Id>{ s } );
                    }
                }
            }

            e.setWhatId( r.whatId );

            if(String.isNotBlank(r.finalWhatId)){
                e.setFinalWhatId(r.finalWhatId);
            }
            
            e.setDeveloperLog('EmailService.get(List<EmailService.InvocableRequest> requestList)');
            e.prepareEmail();
            EmailService.sendPreparedEmailInService();

            EmailService.clearService();
        }


        EmailService.sendPreparedEmailInService();
        EmailService.clearService();

        return invocableResponses;
    }

    public class InvocableRequest {
        @InvocableVariable 
        public String uniqueIdentifier_Invocable;

        @InvocableVariable 
        public String emailTemplateDeveloperName;
        
        @InvocableVariable 
        public String whatId;

        @InvocableVariable 
        public String finalWhatId;

        @InvocableVariable 
        public String toAddress;

        @InvocableVariable 
        public List<String> toAddresses;
    }

    public class InvocableResponse {
        public InvocableResponse() {
            
        }
        
        @InvocableVariable
        public String resultStatus;
    }



}