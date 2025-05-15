public class cmpAPiMngDocketingEmailsSendBatch implements Database.Batchable<SObject> {
    public List<string> iManageDocumentIds;
    public String PatentId;
	public String iManageEmailId;
    public List<string> DocketingActivitiesIds;
    
    public cmpAPiMngDocketingEmailsSendBatch(List<string> iManageDocumentIds, String PatentId,List<string> DocketingActivitiesIds, String iManageEmailId) {
        this.iManageDocumentIds = iManageDocumentIds;
        this.PatentId = PatentId;
        this.DocketingActivitiesIds = DocketingActivitiesIds;
        this.iManageEmailId = iManageEmailId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,DocketActityIds__c,iManageDocumentIds__c,recordId__c ' + 
                       'FROM iManage_Emails__c ' +
                       'WHERE Id =:iManageEmailId ';
                       
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<iManage_Emails__c> scope) {
        
        
        if (scope.size() > 0) {
            for (iManage_Emails__c Data : scope) {
                
                cmpAPiMngDocketingEmailsSendTable.EmailMsg DocketingActivities =cmpAPiMngDocketingEmailsSendTable.getTemplateDetails('iManage_Docketing_Email',null,PatentId,iManageDocumentIds,DocketingActivitiesIds);
                List<cmpAPiMngDocketingEmailsSendTable.FileAttachmentWrapper> fawList = new List<cmpAPiMngDocketingEmailsSendTable.FileAttachmentWrapper>();
                fawList=DocketingActivities.fileAttachments;
                List<string> ContentDocumentIds = new List<string>();
                for (cmpAPiMngDocketingEmailsSendTable.FileAttachmentWrapper faw : fawList) {
                    ContentDocumentIds.add(faw.attachId);
                }
                
                List<string> ToAddress = new List<string>();
                List<string> CcAddress = new List<string>();
                List<string> BCcAddress = new List<string>();
                
                ToAddress.add('amar.p@maxval.com');
                ToAddress.add(UserInfo.getUserEmail());
                
                List<SendMail.MailParameter> ObjMailParameter = new List<SendMail.MailParameter>();
                
                SendMail.MailParameter mailparameter = new SendMail.MailParameter();
                mailparameter.whatId=PatentId;
                mailparameter.ConDocIDs=ContentDocumentIds;
                mailparameter.tosub=DocketingActivities.subject;
                mailparameter.messageBody=DocketingActivities.body;
                mailparameter.sendTo=ToAddress;
                mailparameter.ccAddresses=CcAddress;
                mailparameter.bccAddresses=BCcAddress;
                ObjMailParameter.add(mailparameter);
                
                SendMail.SendMailMethod(ObjMailParameter);
                    
                
                
                
                System.debug('Batch DocketingActivities.' + DocketingActivities);
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch processing completed.');
    }
}