public without sharing class cmpAPiMngDocketingEmails {
    

    
    @AuraEnabled
    public static string iMngEmails (string recordId, string iManageDocumentId) {
        string apiIds ='';
        string returnresponse='';
        string PatentId='';
        List<string> DocketActityIds = new List<string>();
        List<string> iManageDocumentIds = new List<string>();
        
        if(iManageDocumentId!=null && iManageDocumentId!='')
            iManageDocumentIds= iManageDocumentId.split(',');
        system.debug('iManageDocumentIds__c ' + iManageDocumentIds);
        
        
        try {
            List<iManage_Emails__c> ObjEmails = [SELECT Id,DocketActityIds__c,iManageDocumentIds__c,recordId__c 
                                                 FROM iManage_Emails__c
                                                 Where Id=: recordId];
            
            if (ObjEmails.size() > 0) {
                for (iManage_Emails__c email : ObjEmails) {
                    PatentId=email.recordId__c;
                    if(email.DocketActityIds__c!=null && email.DocketActityIds__c!='')
                        DocketActityIds= email.DocketActityIds__c.split(',');
                   email.DocketActityIds__c=String.join(DocketActityIds, ','); 
                   email.iManageDocumentIds__c=String.join(iManageDocumentIds, ',');
                   update email;
                }
            }
            
            
            if (iManageDocumentIds != null && !iManageDocumentIds.isEmpty()) {
                cmpAPiMngDocketingEmailsBatch batch = new cmpAPiMngDocketingEmailsBatch(iManageDocumentIds, PatentId,DocketActityIds,recordId);
                Database.executeBatch(batch, 100);
            }
            
                
        } catch(Exception exp) {
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API1','Pending','');
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',exp.getMessage(),recordId);
        }
        
        
        return returnresponse;
    }
}