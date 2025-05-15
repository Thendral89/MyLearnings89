global with sharing class cmpAPDocuSignCompletionCertificate {

    
    @AuraEnabled
    public static void SetAdhocReminder(string envelope_id,string ReminderDelay,string ReminderFrequency,string ExpireAfter,string ExpireWarn)  {
       
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        string responseBody = '';
        integer recipientId=2;
        boolean IsSent=false;
       
        string Qstr = '{';
            Qstr += '"useAccountDefaults": "false",';
            Qstr += '"reminders": {';
            Qstr += '"reminderEnabled":"true",';
            Qstr += '"reminderDelay":"' + ReminderDelay + '",';
            Qstr += '"reminderFrequency":"' + ReminderFrequency + '"';
            Qstr += '},';
            Qstr += '"expirations": {';
            Qstr += '"expireEnabled":"true",';
            Qstr += '"expireAfter":"' + ExpireAfter + '",';
            Qstr += '"expireWarn":"' + ExpireWarn + '"';
            Qstr += '}';
        	Qstr += '}';
        
        apiBody=Qstr;
        system.debug('apiBody ' + apiBody);
        
        string apiBodyLength = String.valueOf(apiBody.length());
        DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelope_id + '/notification');
        req.setMethod('PUT');  
        req.setBody(apibody);
        req.setHeader('Content-length', apiBodyLength);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + apiHeader );
        req.setTimeout(120000);
        Http http = new Http();
        if(!test.isRunningTest()) {
            
       			try {
                     HTTPResponse httpResponse = http.send(req); 
                     system.debug('response-->'+ httpResponse.getBody());
                  }  catch(Exception exp) {
                        
      			  }
    	}
 }
    
    @AuraEnabled
    public static void SetReminder(string envelope_id)  {
       
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        string responseBody = '';
        string signHereTabs='';
        integer recipientId=2;
        boolean IsSent=false;
       
        signHereTabs = '{';
        signHereTabs += cmpAPDocuSignHelper.getdocusignreminder();
        signHereTabs += '}';
        apiBody=signHereTabs;
        
        string apiBodyLength = String.valueOf(apiBody.length());
        DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelope_id + '/notification');
        req.setMethod('PUT');  
        
        if (apibody.trim()!='') {
            req.setBody(apibody);
            req.setHeader('Content-length', apiBodyLength);
        }
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + apiHeader );
        req.setTimeout(120000);
        Http http = new Http();
        if(!test.isRunningTest()) {
            
       			try {
                     HTTPResponse httpResponse = http.send(req);   
                  }  catch(Exception exp) {
                        
      			  }
    	}
 }
    
    @AuraEnabled
    public static void CreateSignHereTabs(string PatentID, string envelope_id, string PersonId) {
       
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        string responseBody = '';
        string signHereTabs='';
        integer recipientId=2;
        List<DocuSignReviewer__c> DocuSignReviewers = [SELECT Person__c,Email__c,RecipientId__c 
                                                       FROM DocuSignReviewer__c 
                                                       Where recordId__c = : PatentID 
                                                       AND IsDocuSign__c=true];
         if (DocuSignReviewers.size()>0) {
             for(DocuSignReviewer__c recipients : DocuSignReviewers ) {
              	  cmpAPDocuSignCreateSignHereTabs CreateSignHereTabs = NEW cmpAPDocuSignCreateSignHereTabs(recipients.Id,envelope_id);
        		  database.executeBatch(CreateSignHereTabs, 1); 
     	}
   	}   
        
        
 }
    
    @AuraEnabled
    public static void Sendrecipients(string PatentID, string envelope_id, string PersonId) {
       
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        string responseBody = '';
        string signHereTabs='';
        integer recipientId=2;
        boolean IsSent=false;
        List<DocuSignReviewer__c> SignReviewers = new List<DocuSignReviewer__c>();
        
        List<DocuSignReviewer__c> DocuSignReviewers = [SELECT Id,Person__c,Inventor_Name__c,Email__c,Status__c,RecipientId__c 
                                                       FROM DocuSignReviewer__c 
                                                       Where recordId__c = : PatentID 
                                                       AND IsDocuSign__c=true];
         if (DocuSignReviewers.size()>0) {
             for(DocuSignReviewer__c recipients : DocuSignReviewers ) {
                 cmpAPDocuSignRecipients BatchRecipients = NEW cmpAPDocuSignRecipients(recipients.Id,envelope_id);
        		 database.executeBatch(BatchRecipients, 1);
                 
      		}
    	}
      
        
 }
    
    Public static void getEnvelopecertificates(string PatentID, string envelope_id) {
          String returnmessage ='';
        List<EnvelopeInfo__c> objEnvelopes = [SELECT Name, EnvelopeId__c, Sent_On__c, Status__c,Status_Fetched_on__c, Receivers__c, 
                                              Attachment_Id__c, Certificate_Attachment_Id__c, SignedAssignment__c, SignedOathDeclaration__c,Error_Occurred__c,
                                              Error_Text__c, Error_Text_on_Status_Fetch__c,Error_on_Status_Fetch__c,
                                              Error_Count_on_Fetch_Status__c 
                                              FROM EnvelopeInfo__c 
                                              Where EnvelopeId__c =: envelope_id];
         if (objEnvelopes.size() > 0) {
             for(EnvelopeInfo__c record : objEnvelopes ) {
               getEnvelopeAttachment(envelope_id,record.Id);   
             }
         }
     }
    
    @AuraEnabled
    public static void getEnvelopeAttachment(string envelopeId, string envelopeSFId) {
        try 
        {
            system.debug('envelopeId :'+envelopeId+'|envelopeSFId :'+envelopeSFId+'');
            string apiHeader = cmpAPDocuSignHelper.getHeader(); 
            
            DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelopeId + '/documents/certificate');
            req.setMethod('GET');  
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + apiHeader );
            req.setTimeout(120000);
            
            Http http = new Http();
            if(!test.isRunningTest())
            {
                string errortext='';
                EnvelopeInfo__c objEnvelope = [SELECT Id, Name, Status__c, Attachment_Id__c, Certificate_Attachment_Id__c FROM EnvelopeInfo__c WHERE Id=:envelopeSFId LIMIT 1];
                if (objEnvelope != null)
                {
                    try
                    {
                        
                        HTTPResponse httpResponse = http.send(req);
                        if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                            Blob contentFile= httpResponse.getBodyAsBlob();
                            string strContent = EncodingUtil.base64Encode(contentFile);
                            
                            ContentVersion cv = new ContentVersion();
                            cv.ContentLocation = 'S';
                            cv.VersionData = EncodingUtil.base64Decode(strContent);
                            cv.Title = 'Completion Certificate';
                            cv.PathOnClient = 'Completion Certificate.pdf'; 
                            INSERT cv;
                            
                            
                            ContentDocumentLink link = new ContentDocumentLink();
                            link.LinkedEntityId = envelopeSFId;
                            link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                            link.ShareType = 'V';
                            link.Visibility = 'AllUsers';
                            INSERT link;
                           
                            objEnvelope.Certificate_Attachment_Id__c = cv.Id;
                           
                        } 
                    }
                    catch(exception e)
                    {
                        objEnvelope.DownloadStatus__c = 'Pending';
                        
                    }
                    
                    UPDATE objEnvelope;
                }
                
            }
            
            
            			if(test.isRunningTest()){
                            string strContent ='192301931212310';
                            
                            ContentVersion cv = new ContentVersion();
                            cv.ContentLocation = 'S';
                            cv.VersionData = EncodingUtil.base64Decode(strContent);
                            cv.Title = 'Completion Certificate';
                            cv.PathOnClient = 'Completion Certificate.pdf'; 
                            INSERT cv;
                            
                            
                            ContentDocumentLink link = new ContentDocumentLink();
                            link.LinkedEntityId = envelopeSFId;
                            link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                            link.ShareType = 'V';
                            link.Visibility = 'AllUsers';
                            INSERT link;
                
            }
        }
        catch(Exception exp) {
            system.debug('SignReviewers' + exp.getStackTraceString() );
        }
        
       
    }
    
    
}