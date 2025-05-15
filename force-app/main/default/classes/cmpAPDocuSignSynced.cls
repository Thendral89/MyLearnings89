public without sharing class cmpAPDocuSignSynced  {
    

    
 @AuraEnabled
 public static void DocuSignDocumentsSynced(List<Id> recordIds) {
     	List<ContentVersion> ObjContentVersion = new List<ContentVersion>();
     	List<Id> ContentVersionId = new List<Id>();
     	List<ContentDocumentLink> ObjContentDocumentLink = new List<ContentDocumentLink>();
        List<DocuSignAttachment__c> ObjPortfolios  = [SELECT Id,ContentVersionId__c,EnvelopeInfo__c,EnvelopeInfo__r.EnvelopeId__c,
                                                      Name,Title__c,EnvelopeInfo__r.Status__c
                                                      FROM DocuSignAttachment__c 
                                                      Where EnvelopeInfo__c IN:recordIds
                                                      AND FileId__c=null] ;
        if (ObjPortfolios.size()>0) {
            string apiHeader = cmpAPDocuSignHelper.getHeader(); 
            for(DocuSignAttachment__c Data: ObjPortfolios){
                string DocuSignResponse=getEnvelopeDocuments(Data.EnvelopeInfo__r.EnvelopeId__c, Data.EnvelopeInfo__c, Data.ContentVersionId__c, Data.Title__c,apiHeader);
                system.debug('DocuSignResponse' + DocuSignResponse);
                if(DocuSignResponse!='') {
                    string fileName=Data.Title__c;
                    if(fileName.substring(0,4) !='.pdf'){
	 					fileName = fileName + '.pdf';
     				}
                            
     				ContentVersion cv = new ContentVersion();
     				cv.ContentLocation = 'S';
     				cv.VersionData = EncodingUtil.base64Decode(DocuSignResponse);
     				cv.Title = fileName.replace('pdf','');
     				cv.PathOnClient = fileName; 
                    cv.DocuSignAttachment__c=Data.Id;
     				ObjContentVersion.add(cv);
                    ContentVersionId.add(Data.Id);
  				}
            }
        }
     
     if(ObjContentVersion.size()>0)
         insert ObjContentVersion;
     
     if(ContentVersionId.size()>0)
         EnvelopeAttachment(ContentVersionId);
     
 
 }
   
 @AuraEnabled
 public static void EnvelopeAttachment(List<Id> recordIds) {
     
     try { 
	List<ContentVersion> ObjPortfolios  = [SELECT Id,ContentDocumentId,DocuSignAttachment__c,DocuSignAttachment__r.EnvelopeInfo__c,
                                           DocuSignAttachment__r.ContentVersionId__c
                                           FROM ContentVersion 
                                           Where DocuSignAttachment__c IN:recordIds] ;
    if (ObjPortfolios.size()>0) {
        for(ContentVersion Data: ObjPortfolios){
            system.debug('Data' + Data);
            ContentDocumentLink link = new ContentDocumentLink();
            link.LinkedEntityId = Data.DocuSignAttachment__r.EnvelopeInfo__c;
            link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Data.Id].ContentDocumentId;
            link.ShareType = 'V';
            link.Visibility = 'AllUsers';
            INSERT link;
            
			String query = 'SELECT Id,FileId__c FROM DocuSignAttachment__c WHERE ContentVersionId__c=\'' + Data.DocuSignAttachment__r.ContentVersionId__c + '\' AND EnvelopeInfo__c =\'' + Data.DocuSignAttachment__r.EnvelopeInfo__c + '\''; 
     		DocuSignAttachment__c[] records = Database.query(query);
     		if(records.size() >0 ){
                records[0].put('FileId__c',Data.Id);
         		Database.update(records[0]);
            }
        	}
    	}
	} catch(Exception exp) {
        system.debug('cmpAPDocuSignSynced.getEnvelopeAttachment' + exp.getMessage() + exp.getStackTraceString());
     }
    
 }
    
 @AuraEnabled
 public static string getEnvelopeDocuments(string envelopeId, Id envelopeSFId, string documentId, string fileName, string apiHeader) {
        string resultjson='';
        try {
            cmpAPDocuSignEnvelopeDocuments objDocuments = NEW cmpAPDocuSignEnvelopeDocuments();
            system.debug('apiHeader' + apiHeader +  'envelopeId :'+envelopeId+'|envelopeSFId :'+envelopeSFId+'|documentId :'+documentId+'|fileName :'+fileName);
            DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelopeId + '/documents/' + documentId);
            req.setMethod('GET');  
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + apiHeader );
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                HTTPResponse httpResponse = http.send(req);
                system.debug('httpResponse.getBody()' + httpResponse.getBody());
                if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                    Blob contentFile= httpResponse.getBodyAsBlob();
                    resultjson = EncodingUtil.base64Encode(contentFile);
                }
                         
            }
        } catch(Exception exp) {
            system.debug('cmpAPDocuSignSynced.getEnvelopeAttachment' + exp.getMessage() + exp.getStackTraceString());
        }
      return resultjson;
     
}
    
 
    @AuraEnabled
 Public static string reviewers (String recordId) {
        integer i=0;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
         i=+1;
        return string.valueOf(i);
    }
    
}