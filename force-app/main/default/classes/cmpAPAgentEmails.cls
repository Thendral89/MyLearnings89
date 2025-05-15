public without sharing class cmpAPAgentEmails {
    
    @AuraEnabled
    public static boolean GetRoles(String PatentId) {
        boolean Docketer=true;
        
        return Docketer;
            
    }
    
 /*
 @AuraEnabled
 public static void EMRCurrentUser(string recordId) {
      try {
            Map<String, Object> params = new Map<String, Object>();       
        	params.put('recordId', recordId);
        	Flow.Interview.cmpAPEmail_Message_Relation yourFlow = new Flow.Interview.cmpAPEmail_Message_Relation(params);
        	yourFlow.start();
    	} catch (Exception e) {
        	system.debug('e.getMessage() ' + e.getMessage()); 
    	} 
 }
   */
    
    public static string splitEmail(String email) {
        String localPart = '';
        String domainPart = '';
        
        // Ensure the input email is not null or empty
        if (String.isEmpty(email)) {
            System.debug('The email address is empty or null.');
            return '';
        }

        // Split the email address at '@'
        String[] parts = email.split('@');

        // Check if the split resulted in exactly two parts
        if (parts.size() == 2) {
            localPart = parts[0];
            domainPart = parts[1];
            
            System.debug('Local Part: ' + localPart);
            System.debug('Domain Part: ' + domainPart);
        } else {
            System.debug('The email address is not in a valid format.');
        }
        
        return domainPart;
        
    }
    
    public static string getprofilename() {
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.Profile.Name;
        
    }
    public static final Map<String, String> emailMessageStatusMapping = new Map<String, String> {
        '0' => 'New',
            '1' => 'Read',
            '2' => 'Replied',
            '3' => 'Sent',
            '4' => 'Forwarded',
            '5' => 'Draft'
            };
                
    @AuraEnabled
    public static EmailsWrapper  getemailAddress(String EMsgId){
        EmailsWrapper objOption = new EmailsWrapper();
        string emid = EMsgId;
        List<EmailMessage> passemid = [select id,FromAddress,CcAddress,BccAddress,TextBody,ToAddress,Subject,HtmlBody,Incoming 
                                       from EmailMessage WHERE id =: emid limit 1];
        if(passemid.size()>0){
            objOption.FromAddress=passemid[0].FromAddress;
            objOption.HtmlBody=passemid[0].HtmlBody;
            objOption.ToAddress=passemid[0].ToAddress;
            objOption.Subject=passemid[0].Subject;
            objOption.CcAddress=passemid[0].CcAddress;
            objOption.BccAddress=passemid[0].BccAddress;            
        } else {
            List<SymphonyLF__Email_Tracker__c> record = [SELECT Id, Review_Comments_RT__c,
                                                         Email_Message_Id__c, 
                                                         CreatedDate,CreatedBy.Name, 
                                                         From_Address__c, 
                                                         Email_Type__c, Direction__c, 
                                                         Assigned_To_User__r.Name, 
                                                         SymphonyLF__Short_Subject__c, 
                                                         SymphonyLF__Email_Status__c, 
                                                         Attachment_Available__c 
                                                         FROM SymphonyLF__Email_Tracker__c WHERE Id =:  emid];
            if(record.size()>0){
              List<EmailMessage> Emails = [select id,FromAddress,CcAddress,BccAddress,TextBody,ToAddress,Subject,HtmlBody,Incoming 
                                       from EmailMessage WHERE id =: record[0].Email_Message_Id__c limit 1];
                if(Emails.size()>0){
                    objOption.FromAddress=Emails[0].FromAddress;
            		objOption.HtmlBody=Emails[0].HtmlBody;
            		objOption.ToAddress=Emails[0].ToAddress;
            		objOption.Subject=Emails[0].Subject;
            		objOption.CcAddress=Emails[0].CcAddress;
            		objOption.BccAddress=Emails[0].BccAddress;
                }
                
            }
        }
      
        
            
        return objOption;
    }
    
    @AuraEnabled
    public static void UpdateReadEmail(String PatentId) {
        system.debug('PatentId ' + PatentId);
        
        EmailMessage objOption = new EmailMessage();
        objOption.Id=PatentId;
        objOption.IsOpened__c=true;
        update objOption;
        
    }
    
  
    @AuraEnabled
    public static List<EmailsWrapper> GetAssignedDisclosure(String PatentId, String objFilter) {
        Set <String> inventionId = new Set <String>();
        List<EmailsWrapper> objOptions = new List<EmailsWrapper>();
        string PersonEmailId=splitEmail(UserInfo.getUserEmail());
      
        if(objFilter == 'All' || objFilter == 'Email') {
            Map<String, SymphonyLF__Email_Tracker__c> emailTrackerByMessageId = new Map<String, SymphonyLF__Email_Tracker__c>();
            String shortId = PatentId.subString(0,15);
            
            for(SymphonyLF__Email_Tracker__c record : [SELECT Id, Review_Comments_RT__c,
                                                       Email_Message_Id__c, 
                                                       CreatedDate,CreatedBy.Name, 
                                                       From_Address__c, 
                                                       Email_Type__c, 
                                                       Direction__c, 
                                                       Assigned_To_User__r.Name, 
                                                       SymphonyLF__Short_Subject__c, 
                                                       SymphonyLF__Email_Status__c, 
                                                       Attachment_Available__c 
                                                       FROM SymphonyLF__Email_Tracker__c WHERE RelatedTo_ID__c =:  shortId] ) {
                emailTrackerByMessageId.put(record.Email_Message_Id__c, record);
                system.debug('record ' + record);
            }

            
            
            for (EmailMessage record : [
                    SELECT Id, FromAddress, FromName, Subject, Status, ToAddress, MessageDate, CreatedBy.Name,
                            CcAddress, BccAddress, IsOpened__c, HtmlBody, HasAttachment, Incoming
                    FROM EmailMessage
                    WHERE RelatedToId = :PatentId
                    Order by MessageDate desc
            ]) {
				
              
                if (!emailTrackerByMessageId.containsKey(record.Id)) {
                    if(getprofilename()=='Platform Outside Counsel'){
                        if (checkAccess(record, PersonEmailId)) 
                            objOptions.add(new EmailsWrapper(record));
                    } else {
                        objOptions.add(new EmailsWrapper(record));
                    }
                } else {
                    if(getprofilename()=='Platform Outside Counsel'){
                        if (checkAccess(record, PersonEmailId)) 
                            objOptions.add(new EmailsWrapper(emailTrackerByMessageId.get(record.Id), record));
                    } else {
                        objOptions.add(new EmailsWrapper(emailTrackerByMessageId.get(record.Id), record));
                    }
                    
                }
              
            }
        }
        
        if(objFilter == 'All' || objFilter == 'Task') {
            for(Task record : [SELECT Id,Subject,Priority,Status,
                               TaskSubtype,Type,
                               Description,CreatedDate,IsReminderSet, 
                               CreatedBy.Name, 
                               Direction__c, 
                               Task_Type__c, 
                               Paralegal_Comment__c, 
                               Attorney_Comment__c, 
                               Agent_Comment__c, 
                               Owner.Name
                               FROM Task 
                               WHERE WhatId = :PatentId 
                               AND ( CreatedById =: UserInfo.getUserId()  OR OwnerId =: UserInfo.getUserId()) 
                               AND TaskSubtype != 'Email' Order by CreatedDate desc] ) {
                                   EmailsWrapper objOption = new EmailsWrapper();
                                   objOption.Id = record.Id;
                                   objOption.Message='Task';
                                   objOption.FromAddress = record.TaskSubtype;
                                   objOption.Subject = record.Subject;
                                   objOption.Status = record.Status;
                                   objOption.ToAddress = record.Type;
                                   objOption.HtmlBody = record.Description;
                                   objOption.MessageDate = record.CreatedDate;
                                   objOption.Priority = record.Priority;
                                   objOption.IsReminderSet = record.IsReminderSet;
                                   objOption.CreatedBy = record.CreatedBy.Name;
                                   objOption.Direction = record.Direction__c;
                                   objOption.Type = record.Task_Type__c;
                                   objOption.CommentOne = record.Paralegal_Comment__c;
                                   objOption.CommentTwo = record.Attorney_Comment__c;
                                   objOption.CommentThree = record.Agent_Comment__c;
                                   objOption.AssignedTo = record.Owner.Name;
                                   objOption.Attachment = false;
                                   
                                   objOptions.add(objOption);
                                   
                               }
        }
        return objOptions;
    }

    public static Boolean checkAccess(EmailMessage record, string PersonEmailId) {
        Boolean isAccess = false;
        List <String> lstmails = new List<String>();
        string ObjectEmails=record.FromAddress + ';' + record.ToAddress + ';' + record.CcAddress + ';' + record.BccAddress;
        
        if(ObjectEmails!='' && ObjectEmails!=null)
            lstmails = ObjectEmails.split(';');
        
        system.debug('lstmails ' + lstmails);
        
        if(lstmails.size()>0){
            if(ObjectEmails.contains(PersonEmailId) || ObjectEmails.contains(splitEmail(UserInfo.getUserEmail()))) {
                isAccess=true;
                system.debug('isAccess ' + isAccess);
            }
        }
        
      
        return isAccess;
    }
    
    public class EmailsWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Message { get; set; }
        @AuraEnabled public String FromAddress { get; set; }
        @AuraEnabled public String HtmlBody { get; set; }
        @AuraEnabled public String FromName { get; set; }
        @AuraEnabled public String Subject { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public String ToAddress { get; set; }
        @AuraEnabled public String CcAddress { get; set; }
        @AuraEnabled public String BccAddress { get; set; }
        @AuraEnabled public datetime MessageDate { get; set; }
        @AuraEnabled public boolean IsOpened { get; set; }
        @AuraEnabled public boolean HasAttachment { get; set; }
        @AuraEnabled public boolean IsReminderSet { get; set; }   
        @AuraEnabled public String Incoming { get; set; }
        @AuraEnabled public String Priority { get; set; }
        @AuraEnabled public String CreatedBy { get; set; }
        @AuraEnabled public String Direction { get; set; }
        @AuraEnabled public String Type { get; set; }
        @AuraEnabled public String CommentOne { get; set; }
        @AuraEnabled public String CommentTwo { get; set; }
        @AuraEnabled public String CommentThree { get; set; }
        @AuraEnabled public String AssignedTo { get; set; }
        @AuraEnabled public Boolean Attachment { get; set; }
        


        public EmailsWrapper() {
        }

        public EmailsWrapper(EmailMessage record) {
            this.Id = record.Id;
            this.Message='Email';
            this.FromAddress = record.FromAddress;
            this.FromName = record.FromName;
            this.Subject = record.Subject;
            this.Status = emailMessageStatusMapping.get(record.Status);
            this.ToAddress = record.ToAddress;
            this.CcAddress = record.CcAddress;
            this.BccAddress = record.BccAddress;
            this.MessageDate = record.MessageDate;
            this.IsOpened = record.IsOpened__c;
            this.HtmlBody = record.HtmlBody;
            this.HasAttachment = record.HasAttachment;
            this.Direction = record.Incoming ? 'In' : 'Out';
            this.CreatedBy = record.FromAddress;
            this.Incoming ='Sent';
            if(record.Incoming==true) {
                this.Incoming ='Received';
            }
        }

        public EmailsWrapper(SymphonyLF__Email_Tracker__c trackerRecord, EmailMessage messageRecord) {
            this.Id = trackerRecord.Id;
            if(trackerRecord.Email_Message_Id__c!=null)
                this.Id = trackerRecord.Email_Message_Id__c;
            
            this.Message = 'Email';
            this.Status = trackerRecord.SymphonyLF__Email_Status__c;
            this.MessageDate = trackerRecord.CreatedDate;
            this.Type = trackerRecord.Email_Type__c;
            if (String.isNotBlank(trackerRecord.Review_Comments_RT__c)) {
                this.CommentOne = trackerRecord.Review_Comments_RT__c.stripHtmlTags();
            }
            this.AssignedTo = trackerRecord.Assigned_To_User__r.Name;
            this.Attachment = trackerRecord.Attachment_Available__c;

            this.Direction = messageRecord.Incoming ? 'In' : 'Out';
            this.FromAddress = messageRecord.FromAddress;
            this.FromName = messageRecord.FromName;
            this.Subject = messageRecord.Subject;
            this.ToAddress = messageRecord.ToAddress;
            this.CcAddress = messageRecord.CcAddress;
            this.BccAddress = messageRecord.BccAddress;
            this.IsOpened = messageRecord.IsOpened__c;
            this.HtmlBody = messageRecord.HtmlBody;
            
            
            this.HasAttachment = messageRecord.HasAttachment;
            if (trackerRecord.Attachment_Available__c==true) 
                this.HasAttachment=true;
            
            this.CreatedBy = messageRecord.FromAddress;
            this.CommentOne = trackerRecord.Review_Comments_RT__c;
            this.CommentTwo = '';
            this.CommentThree = '';
            
            this.Incoming ='Sent';
            if(messageRecord.Incoming==true) {
                this.Incoming ='Received';
            }
        }

    }
  
}