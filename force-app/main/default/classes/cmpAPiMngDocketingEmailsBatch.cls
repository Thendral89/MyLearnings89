public class cmpAPiMngDocketingEmailsBatch implements Database.AllowsCallouts,Database.Batchable<SObject> {
    public List<string> iManageDocumentIds;
    public String PatentId;
    public String access_token;
	public String iManageEmailId;
    public List<string> DocketingActivitiesIds;
    
    public cmpAPiMngDocketingEmailsBatch(List<string> iManageDocumentIds, String PatentId,List<string> DocketingActivitiesIds, String iManageEmailId) {
        this.iManageDocumentIds = iManageDocumentIds;
        this.PatentId = PatentId;
        this.DocketingActivitiesIds = DocketingActivitiesIds;
        this.iManageEmailId = iManageEmailId;
        
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        this.access_token=cmpAPAPIHeaderCtrl.getToken();
        String query = 'SELECT Id, id__c, ContentVersionId__c, iManage_Folders__c, document_number__c, CreatedDate ' + 
                       'FROM iManage_Documents__c ' +
                       'WHERE Id IN :iManageDocumentIds ' + 
                       'ORDER BY CreatedDate DESC ' + 
                       'LIMIT 100';
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<iManage_Documents__c> scope) {
        if (scope.size() > 0) {
            for (iManage_Documents__c Data : scope) {
                if (PatentId != null && PatentId != '' && Data.id__c != null && Data.id__c != '') {
                    cmpAPiMangDownloadDocCtrl.iMngDownloadDocument(access_token, Data.id__c, PatentId);
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        cmpAPiMngDocketingEmailsSendBatch batch = new cmpAPiMngDocketingEmailsSendBatch(iManageDocumentIds,PatentId,DocketingActivitiesIds,iManageEmailId);
        Database.executeBatch(batch, 1);
    }
}