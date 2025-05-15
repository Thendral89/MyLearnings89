/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDocadd
 * @group             : 
 * @last modified on  : 04-23-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class mvEmailComposerController {


    private static Set<String> alreadyAddedPersonsToExclude = new Set<String>();
    private static String searchText;

    @AuraEnabled
    public static String getCurrentUserEmail() {
        return [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].Email;
    }

    @AuraEnabled(cacheable=true)
    public static List<OrgWideEmailAddress> getOrgWideEmails() {
        return [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress];
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isSandboxEnvironment() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    

    @AuraEnabled
    public static List<String> GetEmailSignature() {
        System.debug('GetEmailSignature called');
        try {
            User currentUser = [SELECT Profile.Name, Signature FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            String signature = currentUser.Signature;
            if (signature != null && signature != '') {
                signature = signature.replaceAll('(\r\n|\n|\r)', '<br/>');
            } else {
                signature = '';
            }
            System.debug('Signature: ' + signature);
            return new List<String>{ signature };
        } catch (Exception e) {
            System.debug('Error in GetEmailSignature: ' + e.getMessage());
            throw new AuraHandledException('Error fetching signature: ' + e.getMessage());
        }
    }


    /* @AuraEnabled
    public static Map<String, Object> getEmailTemplates(Id recordId) {
        Map<String, Object> response = new Map<String, Object>();

        if (Schema.sObjectType.EmailTemplate.isAccessible()) {
            String objectApiName = recordId.getSObjectType().getDescribe().getName();
            System.debug('objectApiName>>' + objectApiName);
            String metadataObjectName = objectApiName; 

            if (metadataObjectName == null) {
                response.put('templates', new List<EmailTemplate>());
                return response; 
            }

            // Querying folders with Type = 'EmailTemplate'
            List<Folder> folders = [
                SELECT Id, Name, DeveloperName
                FROM Folder
                WHERE Type = 'EmailTemplate'
            ];

            System.debug('folders.size():' + folders.size());

            Map<String, Id> developerNameToFolderId = new Map<String, Id>();
            for (Folder folder : folders) {
                developerNameToFolderId.put(folder.DeveloperName, folder.Id);
            }

            // Querying Email Templates from the correct folders
            List<EmailTemplate> emailTemplates = [
                SELECT Subject, Id, Name, DeveloperName, FolderId, Folder.DeveloperName, Folder.Name
                FROM EmailTemplate
                WHERE FolderId IN :developerNameToFolderId.values()
                ORDER BY FolderId, DeveloperName
            ];

            response.put('templates', emailTemplates);
        } else {
            response.put('templates', new List<EmailTemplate>());
        }

        return response;
    } */

    @AuraEnabled
    public static Map<String, Object> getEmailTemplates(Id recordId) {
        Map<String, Object> response = new Map<String, Object>();

        if (Schema.sObjectType.EmailTemplate.isAccessible() && Schema.sObjectType.Attachment.isAccessible()) {
            String objectApiName = recordId.getSObjectType().getDescribe().getName();
            System.debug('objectApiName>>' + objectApiName);
            String metadataObjectName = null;

                metadataObjectName = objectApiName; 

            if (metadataObjectName == null) {
                response.put('templates', new List<EmailTemplate>());
                //response.put('defaultFolderId', null);
                return response; 
            }

            /* List<AutoSelectEmailTemplateFolder__mdt> metadataList = [
                SELECT Object_Name__c, Template_Folders__c, Default_Folder__c
                FROM AutoSelectEmailTemplateFolder__mdt
                WHERE Object_Name__c = :metadataObjectName
            ]; */

            /* if (metadataList.isEmpty()) {
                response.put('templates', new List<EmailTemplate>());
                response.put('defaultFolderId', null);
                return response;
            }

            AutoSelectEmailTemplateFolder__mdt metadata = metadataList[0];
            System.debug('metadata>>>' + metadata);

            List<String> templateFolderDeveloperNames = new List<String>();
            if (String.isNotBlank(metadata.Template_Folders__c)) {
                for (String folderName : metadata.Template_Folders__c.split(',')) {
                    templateFolderDeveloperNames.add(folderName.trim());
                }
            }
            System.debug('templateFolderDeveloperNames:' + templateFolderDeveloperNames); */

            List<Folder> folders = [
                SELECT Id, Name, DeveloperName
                FROM Folder
                WHERE Type = 'Email' 
                //AND DeveloperName IN :templateFolderDeveloperNames
            ];

            System.debug('folders.size():' + folders.size());

            Map<String, Id> developerNameToFolderId = new Map<String, Id>();
            for (Folder folder : folders) {
                developerNameToFolderId.put(folder.DeveloperName, folder.Id);
            }

            List<EmailTemplate> emailTemplates = [
                SELECT Subject, Id, Name, DeveloperName, FolderId, Folder.DeveloperName, Folder.Name,
                    (SELECT Id, Name FROM Attachments)
                FROM EmailTemplate
                WHERE TemplateType IN ('custom', 'text', 'html', 'visualforce') AND FolderId IN :developerNameToFolderId.values()
                ORDER BY FolderId, DeveloperName
            ];

            response.put('templates', emailTemplates);

            /* if (String.isNotBlank(metadata.Default_Folder__c) && 
                developerNameToFolderId.containsKey(metadata.Default_Folder__c.trim())) {
                response.put('defaultFolderId', developerNameToFolderId.get(metadata.Default_Folder__c.trim()));
            } else {
                response.put('defaultFolderId', null);
            } */
        } else {
            response.put('templates', new List<EmailTemplate>());
            //response.put('defaultFolderId', null);
        }

        return response;
    }

    @AuraEnabled(cacheable=true)
    public static List<iManage_Documents__c> getDocumentDetails(List<Id> documentIds) {
        if (documentIds == null || documentIds.isEmpty()) {
            return new List<iManage_Documents__c>();
        }
        
        return [SELECT Id, name__c, iManageFileUrl__c FROM iManage_Documents__c WHERE Id IN :documentIds];
    }

    @AuraEnabled 
    public static EmailMsg getTemplateDetails(string templateId, String whoId, String whatId) {//, String whatId
        User currentUser = [SELECT Profile.Name, Signature FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        system.debug('183-' +whatId);
        string signature = currentUser.Signature;
        if (String.isBlank(signature)) {
            signature = ''; 
        } else {
            signature = signature.replaceAll('(\r\n|\n|\r)', '<br/>');
        }

        
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId, Messaging.AttachmentRetrievalOption.METADATA_ONLY);
        EmailMsg msg = new EmailMsg();
        msg.subject = email.getSubject();
        if (!String.isBlank(email.getHtmlBody())) {
            msg.Body = email.getHtmlBody() + '<br/>' + signature;
        } else if (!String.isBlank(email.getPlainTextBody())) {
            msg.Body = email.getPlainTextBody().replace('\n', '<br/>') + '<br/>' + signature;
        } else {
            msg.Body = signature;
        }

        
        List<Messaging.EmailFileAttachment> attachmentList = email.fileAttachments;
        List<FileAttachmentWrapper> fawList = new List<FileAttachmentWrapper>();
        
        for (Messaging.EmailFileAttachment efa : attachmentList) {
            FileAttachmentWrapper faw = new FileAttachmentWrapper();
            faw.attachId = efa.id;
            faw.filename = efa.filename;
            faw.isContentDocument = false;
            fawList.add(faw);
        }
        
        for (ContentDocumentLink cdl : [SELECT ContentDocument.Id, ContentDocument.title, ContentDocument.fileExtension
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId = :templateId]) {
            FileAttachmentWrapper faw = new FileAttachmentWrapper();
            faw.attachId = cdl.ContentDocument.Id;
            faw.isContentDocument = true;
            faw.filename = cdl.ContentDocument.title + '.' + cdl.ContentDocument.fileExtension;
            fawList.add(faw);
        }

        msg.fileAttachments = fawList != null ? fawList : new List<FileAttachmentWrapper>();
        //msg.fileattachments = fawList;
        system.debug('226-'+msg);
        return msg;
        
    }

    /* @AuraEnabled 
    public static EmailMsg getTemplateDetails(String templateId, String whoId, String whatId) {
        User currentUser = [SELECT Profile.Name, Signature FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String signature = currentUser.Signature;
        if (String.isBlank(signature)) {
            signature = ''; 
        } else {
            signature = signature.replaceAll('(\r\n|\n|\r)', '<br/>');
        }

        // Fetch Email Template details
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue
            FROM EmailTemplate
            WHERE Id = :templateId
            LIMIT 1
        ];

        EmailMsg msg = new EmailMsg();
        msg.subject = emailTemplate.Subject;
        msg.Body = (!String.isBlank(emailTemplate.HtmlValue)) ? emailTemplate.HtmlValue + '<br/>' + signature : signature;

        // Fetch attachments related to the template
        List<FileAttachmentWrapper> fawList = new List<FileAttachmentWrapper>();

        for (ContentDocumentLink cdl : [SELECT ContentDocument.Id, ContentDocument.title, ContentDocument.fileExtension
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId = :templateId]) {
            FileAttachmentWrapper faw = new FileAttachmentWrapper();
            faw.attachId = cdl.ContentDocument.Id;
            faw.isContentDocument = true;
            faw.filename = cdl.ContentDocument.title + '.' + cdl.ContentDocument.fileExtension;
            fawList.add(faw);
        }

        msg.fileAttachments = fawList != null ? fawList : new List<FileAttachmentWrapper>();

        return msg;   
    } */


    public class FileForwardWrapper{
        @AuraEnabled public String documentId;
        @AuraEnabled public String name;
        @AuraEnabled public boolean isContentDocument;
    }
    
     @AuraEnabled 
    public static List<FileForwardWrapper> getForwardAttachment(String whatId){
        List<FileForwardWrapper> msg = new List<FileForwardWrapper>();
        List<FileAttachmentWrapper> fawList = new List<FileAttachmentWrapper>();
        for(ContentDocumentLink cdl : [Select ContentDocument.Id, ContentDocument.title, ContentDocument.fileExtension
                                       from contentdocumentlink
                                       where linkedEntityId=:whatId 
                                       and linkedEntityId!=null]){
            FileForwardWrapper faw = new FileForwardWrapper();
            faw.documentId = cdl.ContentDocument.id;
            faw.isContentDocument = true;                               
            faw.name = cdl.ContentDocument.title+'.'+cdl.contentdocument.fileextension;
            msg.add(faw);
        }
        
        system.debug('msg' + msg);
        
        return msg;   
    }
    

    @AuraEnabled
    public static String sendAnEmailMsg(string fromAddress,string toAddressesStr,string ccAddressesStr,string bccAddressesStr,string subject, 
                                      string whoId, string whatId, string body, String senderDisplayName, List<String> contentDocumentIds,
                                      List<String> attachmentIds,Boolean createActivity){
       try{                                   
    	if(String.isNotblank(toAddressesStr) && Schema.sObjectType.ContentVersion.isAccessible()){
            toAddressesStr=toAddressesStr.replace('.com','.com');
            
            if(ccAddressesStr!='' && ccAddressesStr!=null)
                ccAddressesStr=ccAddressesStr.replace('.com','.com');
            
            String[] toAddresses = toAddressesStr.split(',');
            String[] fileIds = new String[]{};
            String[] ccAddresses = String.isNotBlank(ccAddressesStr) ? ccAddressesStr.split(',') : new String[]{};
            String[] bccAddresses = String.isNotBlank(bccAddressesStr) ? bccAddressesStr.split(',') : new String[]{};
            system.debug('contentDocumentIds****'+contentDocumentIds);    
            List<String> cvIds = new String[]{};
            for(ContentVersion cv : [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
                                     FROM ContentVersion
                                     WHERE isLatest = true AND ContentDocumentId IN :contentDocumentIds]){
            	cvIds.add(cv.id);
            }   
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(String.isNotBlank(fromAddress)){
                OrgWideEmailAddress[] owea = new List<OrgWideEmailAddress>([select Id
                                                                            from OrgWideEmailAddress
                                                                            where Address = :fromAddress]);
				if ( owea.size() > 0 ) {
    				email.setOrgWideEmailAddressId(owea.get(0).Id);
                    email.setUseSignature(false);
				}
            } else {
                OrgWideEmailAddress[] owea = new List<OrgWideEmailAddress>([select Id from OrgWideEmailAddress limit 1]);
				if ( owea.size() > 0 ) {
    				email.setOrgWideEmailAddressId(owea.get(0).Id);
                    email.setUseSignature(false);
				}
            }
            
            
            email.setToAddresses(toAddresses);
            email.setCCAddresses(ccAddresses);
            email.setBCCAddresses(bccAddresses);
            email.setSubject(subject);
            email.sethtmlBody(body);
            email.setUseSignature(false);
            if(whatId!='' && whatId!=null)
            email.setWhatId(whatId);
            //email.setTreatBodiesAsTemplate(true);
            if(String.isNotBlank(senderDisplayName)){
                email.setSenderDisplayName(senderDisplayName);
            } 
            system.debug('cvIds**'+cvIds);
            if(cvIds !=null && !(cvIds.isEmpty())){
                fileIds.addAll(cvIds);
            }
            if(attachmentIds !=null && !(attachmentIds.isEmpty())){
                fileIds.addAll(attachmentIds);
            } 
            if(!(fileIds.isEmpty())){
                email.setEntityAttachments(fileIds);
            }
            //email.setTargetObjectId(userinfo.getUserId());
            email.saveAsActivity = true;
            createActivity=false;
            
            List<Messaging.SendEmailResult> ser =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            system.debug('Email Sent'+ ser);
            if (ser[0].isSuccess()) {
                EmailMessage msg = [
                    SELECT Id 
                    FROM EmailMessage 
                    WHERE CreatedById = :UserInfo.getUserId()
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ];
                return msg.Id;
            }
            
    	}
       }catch(Exception e){
           	string status =e.getMessage() + '--' +e.getStackTraceString(); 
            System.debug('status Error' + status);
           throw new AuraHandledException('Something went wrong: ' +e.getMessage());
           //throw e;
       }
       return null;
    }

    @AuraEnabled
    public static void updateEmailMessage(String emailMessageId, Boolean syncToIManage) {
        try {
            if (String.isNotBlank(emailMessageId)) {
                EmailMessage emailMessage = [SELECT Id, Sync_to_iManage__c FROM EmailMessage WHERE Id = :emailMessageId LIMIT 1];
                emailMessage.Sync_to_iManage__c = syncToIManage;
                update emailMessage;
                System.debug('Sync_to_iManage__c updated successfully for EmailMessage: ' + emailMessageId);
            }
        } catch (Exception e) {
            System.debug('Error updating EmailMessage: ' + e.getMessage());
            throw new AuraHandledException('Failed to update EmailMessage: ' + e.getMessage());
        }
    }


    //Fetch original EmailMessage record for reply/replyAll/forward prepopulation
    public class EmailMessageWrapper {
        @AuraEnabled public String subject;
        @AuraEnabled public String htmlBody;
        @AuraEnabled public String fromAddress;
        @AuraEnabled public String toAddress;
        @AuraEnabled public String ccAddress;
        @AuraEnabled public String bccAddress;
        @AuraEnabled public List<FileAttachmentWrapper> fileAttachments;
    }

    @AuraEnabled
    public static EmailMessageWrapper getEmailMessageDetails(Id emailMessageId) {
        // Return nothing if no ID
        if (String.isBlank(emailMessageId)) return null;

        // Query the EmailMessage + any attached documents
        EmailMessage em = [
            SELECT
                Subject,
                HtmlBody,
                FromAddress,
                ToAddress,
                CcAddress,
                BccAddress,
                (SELECT
                    ContentDocument.Id,
                    ContentDocument.Title,
                    ContentDocument.FileExtension
                 FROM ContentDocumentLinks)
            FROM EmailMessage
            WHERE Id = :emailMessageId
            LIMIT 1
        ];

        EmailMessageWrapper wrapper = new EmailMessageWrapper();
        wrapper.subject = em.Subject;
        wrapper.htmlBody = em.HtmlBody;
        wrapper.fromAddress = em.FromAddress;
        wrapper.toAddress = em.ToAddress;
        wrapper.ccAddress = em.CcAddress;
        wrapper.bccAddress = em.BccAddress;

        List<FileAttachmentWrapper> fawList = new List<FileAttachmentWrapper>();
        for (ContentDocumentLink cdl : em.ContentDocumentLinks) {
            FileAttachmentWrapper faw = new FileAttachmentWrapper();
            faw.attachId = cdl.ContentDocument.Id;
            faw.fileName = cdl.ContentDocument.Title + '.' + cdl.ContentDocument.FileExtension;
            faw.isContentDocument = true;
            fawList.add(faw);
        }
        wrapper.fileAttachments = fawList;

        return wrapper;
    }

    @AuraEnabled
    public static List<EmailDirectoryWrapper> getRelatedLawFirmForDirectory(Id recordId) {
        try {
            if (recordId == null) {
                throw new IllegalArgumentException('Record ID is empty');
            }
            String objectApiName = recordId.getSObjectType().getDescribe().getName();
            system.debug('objectApiName:'+objectApiName);
            List<EmailDirectoryWrapper> emailDirectory = new List<EmailDirectoryWrapper>();

            List<GetRelatedEmailAddress__mdt> metadata = [
                SELECT Law_Firm__c, Where_Condition_for_LawFirm__c,Object_Name__c
                FROM GetRelatedEmailAddress__mdt
                WHERE Object_Name__c = :objectApiName
                LIMIT 1
            ];
            if(!metadata.isEmpty() && metadata[0].Law_Firm__c != null){
                String query = 'SELECT Id,' + metadata[0].Law_Firm__c + ' FROM ' + metadata[0].Object_Name__c  + ' WHERE Id = \''+recordId+ '\' LIMIT 1';
                System.debug('query==>>>' +query);
                SObject result = Database.query(query);
                System.debug('Fetched Record: ' + result);
                String lawFirmId = (String)result.get(metadata[0].Law_Firm__c);
                /* if (lawFirmId != null) {
                    fetchRelatedLawFirms(lawFirmId, metadata[0].Where_Condition_for_LawFirm__c, emailDirectory);
                } */
            }

            /* if (objectApiName == 'SymphonyLF__Law_Firm__c') {
                fetchRelatedLawFirms(recordId, '', emailDirectory);
            }
            else if (objectApiName == 'SymphonyLF__Patent__c') {
                List<Patent_Related_LawFirm__c> patentRelatedLawFirms = [
                    SELECT Id, Law_Firm_Type__c, Patent__c, Law_Firm__c 
                    FROM Patent_Related_LawFirm__c 
                    WHERE Patent__c = :recordId
                ];
                for (Patent_Related_LawFirm__c patentLawFirm : patentRelatedLawFirms) {
                    if (patentLawFirm.Law_Firm__c != null) {
                        fetchRelatedLawFirms(patentLawFirm.Law_Firm__c, 'Patent', emailDirectory);
                    }
                }
            } 
            else if (objectApiName == 'SymphonyLF__Invention_Disclosure_New__c') {
                SymphonyLF__Invention_Disclosure_New__c inventionDisclosure = [
                    SELECT Id, SymphonyLF__Related_Patent__c 
                    FROM SymphonyLF__Invention_Disclosure_New__c 
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                if (inventionDisclosure.SymphonyLF__Related_Patent__c != null) {
                    List<Patent_Related_LawFirm__c> patentRelatedLawFirms = [
                        SELECT Id, Law_Firm_Type__c, Patent__c, Law_Firm__c
                        FROM Patent_Related_LawFirm__c
                        WHERE Patent__c = :inventionDisclosure.SymphonyLF__Related_Patent__c
                    ];
                    for (Patent_Related_LawFirm__c patentLawFirm : patentRelatedLawFirms) {
                        if (patentLawFirm.Law_Firm__c != null) {
                            fetchRelatedLawFirms(patentLawFirm.Law_Firm__c, 'Patent', emailDirectory);
                        }
                    }
                }
            } 
            else if (objectApiName == 'SymphonyLF__Dispute_Opposition__c') {
                SymphonyLF__Dispute_Opposition__c disputeOpposition = [
                    SELECT Id, Team__c, Patent__c, Trademark__c 
                    FROM SymphonyLF__Dispute_Opposition__c 
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                if (disputeOpposition.Team__c == 'Patent Team' && disputeOpposition.Patent__c != null) {
                    Id patentId = disputeOpposition.Patent__c;
                    List<Patent_Related_LawFirm__c> patentRelatedLawFirms = [
                        SELECT Id, Law_Firm_Type__c, Patent__c, Law_Firm__c 
                        FROM Patent_Related_LawFirm__c 
                        WHERE Patent__c = :patentId
                    ];
                    for (Patent_Related_LawFirm__c patentLawFirm : patentRelatedLawFirms) {
                        if (patentLawFirm.Law_Firm__c != null) {
                            fetchRelatedLawFirms(patentLawFirm.Law_Firm__c, 'Patent', emailDirectory);
                        }
                    }
                } else if (disputeOpposition.Team__c == 'Trademark Team' && disputeOpposition.Trademark__c != null) {
                    Id trademarkId = disputeOpposition.Trademark__c;
                    SymphonyLF__Trademark_New__c trademarkRecord = [
                        SELECT Id, SymphonyLF__Outside_Counsel__c 
                        FROM SymphonyLF__Trademark_New__c 
                        WHERE Id = :trademarkId
                        LIMIT 1
                    ];
                    if (trademarkRecord.SymphonyLF__Outside_Counsel__c != null) {
                        fetchRelatedLawFirms(trademarkRecord.SymphonyLF__Outside_Counsel__c, 'Trademark', emailDirectory);
                    }
                }
            } */
            
            System.debug('emailDirectory=>'+emailDirectory);
            return emailDirectory;
        } catch (Exception e) {
            System.debug('Error fetching emails: ' + e.getMessage());
            throw new AuraHandledException('Error fetching Paralegal and Attorney emails: ' + e.getMessage());
        }  
    }

    
    /* private static void fetchRelatedLawFirms(Id lawFirmId, String type, List<EmailDirectoryWrapper> emailDirectory) {
        String query = 'SELECT Id, Name, Emails__c, Type__c,Law_Firm__r.Name FROM Related_LawFirm_Details__c WHERE Law_Firm__c = \''+lawFirmId+'\'';
        if (String.isNotEmpty(type)) {
            query += ' AND Type__c = \''+type+'\'';
        }
        List<Related_LawFirm_Details__c> relatedLawFirms = Database.query(query);
        for (Related_LawFirm_Details__c lawFirmDetail : relatedLawFirms) {
            if (String.isNotEmpty(lawFirmDetail.Emails__c)) {
                List<String> emails = new List<String>();
                emails.addAll(lawFirmDetail.Emails__c.split('[,;]'));
                
                for (String email : emails) {
                    email = email.trim();
                    if (String.isNotEmpty(email)) {
                        emailDirectory.add(new EmailDirectoryWrapper(
                            lawFirmDetail.Id,
                            lawFirmDetail.Law_Firm__r.Name,
                            email,
                            'Related Law Firm'
                        ));
                    }
                }
            }
        }
    } */

    @AuraEnabled
    public static List<EmailDirectoryWrapper> getRelatedEmailsForDirectory(Id recordId) {
    try {
        if (recordId == null) {
            throw new IllegalArgumentException('Record ID is empty');
        }
        String objectApiName = recordId.getSObjectType().getDescribe().getName();
        system.debug('objectApiName:'+objectApiName);
        List<EmailDirectoryWrapper> emailDirectory = new List<EmailDirectoryWrapper>();
        GetRelatedEmailAddress__mdt metadata = [
            SELECT Query__c, Paralegal_Email__c, Attorney_Email__c, Object_Name__c
            FROM GetRelatedEmailAddress__mdt
            WHERE Object_Name__c = :objectApiName
            LIMIT 1
        ];
        if (metadata == null || String.isBlank(metadata.Query__c) || String.isBlank(metadata.Object_Name__c)) {
            throw new AuraHandledException(
                'Invalid metadata configuration for object: ' + objectApiName + 
                '. Ensure Query__c and Object_Name__c are populated.'
            );
        }
        System.debug('metadata.Query__c>>>>>>>'+ metadata.Query__c);
        System.debug('metadata.Object_Name__c>>>>>>'+ metadata.Object_Name__c);
        System.debug('metadata.Paralegal_Email__c>>>>>>'+ metadata.Paralegal_Email__c);
        System.debug('metadata.Attorney_Email__c>>>>>>'+ metadata.Attorney_Email__c);
        String query = 'SELECT Id, ' + metadata.Query__c + ' FROM ' + metadata.Object_Name__c + ' WHERE Id = \''+recordId+ '\' LIMIT 1';
        System.debug('query=>'+query );
        SObject record = Database.query(query,AccessLevel.SYSTEM_MODE);
        
        system.debug('record=:'+record);
        if (metadata.Paralegal_Email__c != null) {
            String paralegalRelationship = metadata.Paralegal_Email__c.split('\\.')[0]; // Extract the relationship name
            SObject paralegalRecord = record.getSObject(paralegalRelationship); // Dynamically get related SObject
            if (paralegalRecord != null) {
                String paralegalEmail = (String) paralegalRecord.get('EmailAddress__c'); // Extract email
                String paralegalName = (String) paralegalRecord.get('Name'); // Extract name dynamically
                if (!String.isBlank(paralegalEmail) && !String.isBlank(paralegalName)) {
                    emailDirectory.add(new EmailDirectoryWrapper(
                        record.Id,
                        paralegalName,
                        paralegalEmail,
                        'Paralegal'
                    ));
                }
            }
        }
        
        if (metadata.Attorney_Email__c != null) {
            String attorneyRelationship = metadata.Attorney_Email__c.split('\\.')[0]; // Extract the relationship name
            SObject attorneyRecord = record.getSObject(attorneyRelationship); // Dynamically get related SObject
            if (attorneyRecord != null) {
                String attorneyEmail = (String) attorneyRecord.get('EmailAddress__c'); // Extract email
                String attorneyName = (String) attorneyRecord.get('Name'); // Extract name dynamically
                if (!String.isBlank(attorneyEmail) && !String.isBlank(attorneyName)) {
                    emailDirectory.add(new EmailDirectoryWrapper(
                        record.Id,
                        attorneyName,
                        attorneyEmail,
                        'Attorney'
                    ));
                }
            }
        }
        System.debug('emailDirectory=>'+emailDirectory);
        return emailDirectory;
    } catch (Exception e) {
        System.debug('Error fetching emails: ' + e.getMessage());
        throw new AuraHandledException('Error fetching Paralegal and Attorney emails: ' + e.getMessage());
    }  
    }

    @AuraEnabled
    public static List<EmailDirectoryWrapper> getQuickAddMatterEngagementModels(Id recordId) {
        List<EmailDirectoryWrapper> quickAddList = new List<EmailDirectoryWrapper>();
        
        try {
            List<mvWrappers.MatterEngagementModelWrapper> engagementModels = mvLawfirmUtilities.getMatterEngagementModels(recordId);
            
            for (mvWrappers.MatterEngagementModelWrapper model : engagementModels) {
                if (!String.isBlank(model.email) && !String.isBlank(model.contactName)) {
                    quickAddList.add(new EmailDirectoryWrapper(
                        model.recordId,
                        model.contactName,
                        model.email,
                        model.type 
                    ));
                }
            }
            
        } catch (Exception e) {
            System.debug('Error fetching engagement models: ' + e.getMessage());
            throw new AuraHandledException('Error fetching Matter Engagement Models: ' + e.getMessage());
        }

        return quickAddList;
    }


    /* @AuraEnabled
    public static List<EmailDirectoryWrapper> getLawFirmEmailsForDirectory(String searchText, List<Id> alreadyAddedPersonsToExclude, String clientId) {
    try {
        List<EmailDirectoryWrapper> emailDirectory = new List<EmailDirectoryWrapper>();
        List<SymphonyLF__Law_Firm__c> lawFirms = [SELECT Id, 
                                                           Name, 
                                                           SymphonyLF__Email__c, 
                                                           Professional_Email__c
                                                    FROM SymphonyLF__Law_Firm__c 
                                                    WHERE (Name LIKE :('%' + searchText + '%') 
                                                        OR SymphonyLF__Email__c LIKE :('%' + searchText + '%') 
                                                        OR Professional_Email__c LIKE :('%' + searchText + '%'))
                                                    AND Id NOT IN :alreadyAddedPersonsToExclude
                                                    AND ( SymphonyLF__Email__c != null OR Professional_Email__c != null )
                                                    AND Client_Id__c = :clientId
                                                    LIMIT 200];
        for (SymphonyLF__Law_Firm__c lawFirm : lawFirms) {
            String emailToAdd = (lawFirm.SymphonyLF__Email__c != null) ? lawFirm.SymphonyLF__Email__c : lawFirm.Professional_Email__c;
            emailDirectory.add(new EmailDirectoryWrapper(
                    lawFirm.Id,
                    lawFirm.Name,
                    emailToAdd,
                    'Law Firm'
                ));    
            
        }
        System.debug('emailDirectory=>'+emailDirectory);
        return emailDirectory;
    } catch (Exception e) {
        System.debug('Error fetching emails: ' + e.getMessage());
        throw new AuraHandledException('Error fetching Paralegal and Attorney emails: ' + e.getMessage());
    }  
    } */


    public class EmailDirectoryWrapper {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Label;
        @AuraEnabled
        public String Email;
        @AuraEnabled
        public String EmailOf;

        public EmailDirectoryWrapper(Id id, String label, String email, String emailOf) {
            this.Id = id;
            this.Label = label;
            this.Email = email;
            this.EmailOf = emailOf;
        }
    }
        
    public class FileAttachmentWrapper{
        @AuraEnabled public String attachId;
        @AuraEnabled public String fileName;
        @AuraEnabled public boolean isContentDocument;
    }
	public class EmailMsg{
        @AuraEnabled public string subject;
        @AuraEnabled public string body;        
        @AuraEnabled public List<FileAttachmentWrapper> fileAttachments;
       // @AuraEnabled publi List<String> attach
    }

    //Added for TO,CC and BCC fields auto-populate
    @AuraEnabled
    public static Map<String,List<String>> getAddressDetails(String templateId ,String  recordId){
        
        Map<String,List<String>> output = new Map<String,List<String>>{'to' => new List<String>{} , 'cc' => new List<String>{} , 'bcc' => new List<String>{},
                                                                         'ObjType' => new List<String>{} , 'Type' => new List<String>{}};
        
        if(String.isBlank(templateId) || String.isBlank(recordId)) return output;
            
        EmailTemplate emailTemplate = [
            SELECT 
                Id, 
                DeveloperName 
            FROM 
                EmailTemplate 
            WHERE 
                Id =: templateId LIMIT 1
        ];
            
        if(emailTemplate == Null || String.isBlank(emailTemplate.DeveloperName)){
            return output;
        }
            
        System.debug('templateId>>>>>>'+ templateId);
        System.debug('recordId>>>>>'+ recordId);
        String devName = emailTemplate.DeveloperName;

        Email_Addresses__mdt metadata = [
            SELECT 
                Id,To__c,Object_Name__c,Query__c,CC_Address__c,BCC__c,TemplateDeveloperName__c,Parent_Object_Type__c,Type__c 
            FROM 
                Email_Addresses__mdt 
            WHERE 
            TemplateDeveloperName__c =: devName LIMIT 1];
        
        if(metadata == Null || String.isBlank(metadata.Query__c)){
            return output;
        }

        System.debug('metadata.To__c>>>>>>>'+ metadata.To__c);
        System.debug('metadata.Object_Name__c>>>>>>'+ metadata.Object_Name__c);
        System.debug('metadata.Query__c>>>>>'+ metadata.Query__c);
        System.debug('metadata.Parent_Object_Type__c>>>>>'+ metadata.Parent_Object_Type__c);
        System.debug('metadata.Type__c>>>>>'+ metadata.Type__c);
        List<String> toAddressesList = new List<String>();
        
        String query = 'SELECT Id, '+ metadata.Query__c + ' FROM ' + metadata.Object_Name__c + ' WHERE Id = \''+recordId+ '\' LIMIT 1';
        /* if(metadata.Object_Name__c == 'SymphonyLF__Trademark_New__c'){
            if(metadata.To__c == 'Law_Firm'){
            	for(Related_LawFirm_Details__c rLawFirm : [SELECT Id, Name, Emails__c FROM Related_LawFirm_Details__c 
                                                           WHERE Type__c = 'Trademark' 
                                                           AND Law_Firm__c IN (
                                                               SELECT SymphonyLF__Outside_Counsel__c FROM SymphonyLF__Trademark_New__c WHERE Id =: recordId)]){
                    if(!String.isBlank(rLawFirm.Emails__c)){
                        toAddressesList.add(rLawFirm.Emails__c);                                               	    
                    }                                                   
            	}    
            }else if(metadata.To__c.contains('@')){
                toAddressesList.add(metadata.To__c);
            }
            
            
		} */
        
        SObject record = Database.query(query , AccessLevel.SYSTEM_MODE);
		
        /* if(metadata.Object_Name__c <> 'SymphonyLF__Trademark_New__c'){
        	toAddressesList = processEmails(record, metadata.TO__c);    
        } */
        List<String> ccAddressesList = processEmails(record, metadata.CC_Address__c);
        List<String> bccAddressesList = processEmails(record, metadata.BCC__c);  
        List<String> parentObjList = new List<String>{metadata.Parent_Object_Type__c};  
        List<String> typeList = new List<String>{metadata.Type__c};  
        
        System.debug('tovalue >>>>>>' + toAddressesList);
        System.debug('ccAddresses >>>>>>>' + ccAddressesList);
        System.debug('BccAddresses >>>>>>' + bccAddressesList);
        System.debug('parentObjList >>>>>>' + parentObjList);
        System.debug('typeList >>>>>>' + typeList);

        return new Map<String,List<String>>{'to' => toAddressesList , 'cc' => ccAddressesList , 'bcc' => bccAddressesList , 'ObjType' => parentObjList , 'Type' => typeList};
    }    
         
    

    /**
    * Helper method to process email fields
    */
    private static List<String> processEmails(SObject record, String emailField) {
        List<String> emailList = new List<String>();
        if (String.isBlank(emailField)) {
            return emailList;
        }
        List<String> fields = emailField.split(',');

        for (String field : fields) {
            field = field.trim(); 
            if (field.contains('@')) {
                emailList.add(field);
            } else if(field == 'Logged in User'){
                emailList.add(UserInfo.getUserEmail());
            }
            else {
                List<Object> emails = QueryUtils.extractValueFromParentOrChild(record, field);
                for(Object email : emails){
                    if (email != null) {
                        emailList.add(String.valueOf(email));
                    }
                }
            }
        }
        
        return emailList;
    }

    @AuraEnabled
    public static void linkFilesToDocket(Id docketId, List<Id> contentDocIds) {
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (Id docId : contentDocIds) {
        links.add(new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId   = docketId,
            ShareType        = 'V',
            Visibility       = 'AllUsers'
        ));
        }
        if (!links.isEmpty()) insert links;
    }

    @AuraEnabled
    public static void notifyReviewer(Id docketReportId, String templateName) {
        Docket_Report_External__c dr = [
            SELECT 
            Id,Name,
            Docketing_Activity__r.Name,
            CreatedBy.Name,
            Assigned_To__r.Email,
            Assigned_To__r.Name,
            CreatedBy.Email
            FROM Docket_Report_External__c
        WHERE Id = :docketReportId
        LIMIT 1
        ];
        if (dr.Assigned_To__r?.Email == null) return;
    
        EmailTemplate et = [
            SELECT Subject, HtmlValue
            FROM EmailTemplate
            WHERE Name = :templateName
            LIMIT 1
        ];
    
        String subj = et.Subject;
        String body = et.HtmlValue;  
    
        subj = subj.replace(
            '{{{Docket_Report_External__c.Docketing_Activity__c}}}',
            dr.Docketing_Activity__r.Name
        );
        body = body.replace(
            '{{{Docket_Report_External__c.Docketing_Activity__c}}}',
            dr.Docketing_Activity__r.Name
        );
        body = body.replace(
            '{{{Docket_Report_External__c.Assigned_To__c}}}',
            dr.Assigned_To__r.Name
        );
        body = body.replace(
            '{{{Docket_Report_External__c.CreatedById}}}',
            dr.CreatedBy.Name
        );
    
        String base = URL.getOrgDomainUrl().toExternalForm();
        String linkHtml = '<a href="' + base
                        + '/lightning/r/Docket_Report_External__c/'
                        + dr.Id
                        + '/view" target="_self">'
                        + dr.Name
                        + '</a>';
        body = body.replace('[Hyperlink_DOE]', linkHtml);
        
        String toAddr;
        if (templateName.equals('Docket Report Review Request')) {
        toAddr = dr.Assigned_To__r.Email;
        } else if (templateName.equals('Docket Report Review Request Changes')) {
        toAddr = dr.CreatedBy.Email;
        }
        if (String.isBlank(toAddr)) {
        return;
        }

        List<String> ccList = new List<String>{
            'saikeerthi.n@maxval.com',
            'swati.s@maxval.com'
        };
    
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        //msg.setToAddresses(new String[]{ dr.Assigned_To__r.Email });
        msg.setToAddresses(new String[]{ toAddr });
        //msg.setCcAddresses(new String[]{ 'saikeerthi.n@maxval.com' });
        msg.setCcAddresses(ccList);
        msg.setSubject(subj);
        msg.setHtmlBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ msg });
        }

}