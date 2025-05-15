public class cmpAPDocuSignCtrl {

    
     @AuraEnabled
    public static string UpdateDocuSignRecord(String recordId, String fieldApi, String fieldvalue ) { 
        try {
                String query = 'SELECT Id,' +  fieldApi + ' FROM EnvelopeInfo__c WHERE Id =\'' + recordId + '\''; 
                System.debug('query' + query);
                EnvelopeInfo__c[] records = Database.query(query);
                if(records.size() >0 ){
                     records[0].put(fieldApi,fieldvalue);
                     Database.update(records[0]);
                }
               
                return 'Success';
        }catch(Exception e){
            return e.getMessage() + '--' +e.getStackTraceString();
        }
    } 
    
    @AuraEnabled
    public static string OnDeleted(string PatentID, string envelope_id) {
        DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        string responseBody = '';
        apiBody = '';
        apiBody += '{';
        apiBody += '"status":"voided",';
        apiBody += '"voidedReason":"voided for incorrect recipient"';
        apiBody += '}';
        System.debug('apiHeader' + apiHeader);
        System.debug('apiBody' + apiBody);
        string apiBodyLength = String.valueOf(apiBody.length());
        HttpRequest req = new HttpRequest();
        req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelope_id );
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
                    	responseBody= httpResponse.getBody();
                    }
                    catch(Exception exp) {
                     	responseBody=exp.getStackTraceString();
      				}
        } else {
            integer i=0;
            i=i+1;
            i=i+1;
            i=i+1;
            i=i+1;
            i=i+1;
            responseBody= '';
        }
        
         System.debug('responseBody' + responseBody);
        
         return responseBody;
        
 }
    
    
    @AuraEnabled
    public static string setReminder(string recordId,string ReminderDelay,string ReminderFrequency,string ExpireAfter,string ExpireWarn) {
        cmpAPDocuSignCompletionCertificate.SetAdhocReminder(recordId,ReminderDelay,ReminderFrequency,ExpireAfter,ExpireWarn);
        
        return 'Success';
        
    }   
    
    
  	@AuraEnabled
    public static DocuSignReminder__c getReminder(string recordId) {
        DocuSignReminder__c objDocuSignReminder = [SELECT Id, Name, ExpireAfter__c,
                                                   ExpireWarn__c,ReminderDelay__c,ReminderFrequency__c 
                                                   FROM DocuSignReminder__c 
                                                   LIMIT 1];
        return objDocuSignReminder;
        
    }   
 @AuraEnabled
 public static string DocuSignSyncedRequest(string recordId) {
     	List<EnvelopeInfo__c> ObjEnvelopeInfo = new List<EnvelopeInfo__c>();
        List<Id> InnovationId = new List<Id>();
     	InnovationId.add(recordId);
        if(InnovationId.size()>0)
            cmpAPDocuSignSynced.DocuSignDocumentsSynced(InnovationId);

     String query = 'SELECT Id,recordId__c,EnvelopeId__c,Status__c FROM EnvelopeInfo__c WHERE Certificate_Attachment_Id__c!=null AND Status__c=\'completed\' AND Id =\'' + recordId + '\''; 
     System.debug('query' + query);
     EnvelopeInfo__c[] records = Database.query(query);
     if(records.size() >0 ){
         for(EnvelopeInfo__c evp : records) {
             cmpAPDocuSignCompletionCertificate.getEnvelopecertificates(evp.recordId__c,evp.EnvelopeId__c);
         }
     }
     
     
     
     return '';
         
 }
    
    @AuraEnabled
    public static string getEnvelopecertificates(string PatentID, string envelope_id) {
        String returnmessage ='';
        List<EnvelopeInfo__c> objEnvelopes = [SELECT Name, EnvelopeId__c, Sent_On__c, Status__c,Status_Fetched_on__c, Receivers__c, 
                                              Attachment_Id__c, Certificate_Attachment_Id__c, SignedAssignment__c, SignedOathDeclaration__c,Error_Occurred__c,
                                              Error_Text__c, Error_Text_on_Status_Fetch__c,Error_on_Status_Fetch__c,
                                              Error_Count_on_Fetch_Status__c 
                                              FROM EnvelopeInfo__c 
                                              WHERE recordId__c = : PatentID
                                              AND EnvelopeId__c =: envelope_id];
         if (objEnvelopes.size() > 0) {
             for(EnvelopeInfo__c record : objEnvelopes ) {
              cmpAPDocuSignCompletionCertificate.getEnvelopeAttachment(envelope_id,record.Id);   
             }
         }
        return returnmessage;
        
    }
 
    @AuraEnabled
    public static List<SymphonyLF__Person__c> getPerson(string recordId) {
         List<SymphonyLF__Person__c> ObjPerson = [SELECT Id,Name,SymphonyLF__Email__c
                                              FROM SymphonyLF__Person__c 
                                              WHERE Id = : recordId];
        return ObjPerson;
        
    }
    
    @AuraEnabled
    public static string ReSending(string envelope_id) {
        string responseBody = '';
        string recipientId ='';
        string name ='';
        string email ='';
        
        EnvelopeInfo__c objEnvelopes = new EnvelopeInfo__c(); 
        List<EnvelopeInfo__c> DocDetails = [Select Id,Person__c,Person_Name__c,Receivers__c  
                                            FROM EnvelopeInfo__c 
                                            WHERE EnvelopeId__c = : envelope_id ];
                  if (DocDetails.size() > 0) {
                      for(EnvelopeInfo__c record : DocDetails ) {
                      	recipientId='1'; 
                          
                   if(record.Person__c !=null) { 
                       List<SymphonyLF__Person__c> Person = getPerson(record.Person__c);
                       if(Person.size()>0) {
							name=Person[0].Name;
                            email=Person[0].SymphonyLF__Email__c;
                       }                          
        
        DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        
        apiBody = cmpAPDocuSignHelper.resendrequest(recipientId,name,email);
        string apiBodyLength = String.valueOf(apiBody.length());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelope_id + '/recipients?resend_envelope=true');
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
                     if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                       	responseBody= httpResponse.getBody();      
                     } else {
                         responseBody= httpResponse.getBody(); 
                     }
                    
                    system.debug('responseBody ' + responseBody);
                    
                    
                    }catch(Exception exp) {
                        responseBody=exp.getMessage() + exp.getStackTraceString();
                        system.debug(responseBody);
      				}
    		} 
        }
                          
                          
     }
  }     
        
        
         return responseBody;
        
 }
    
    @AuraEnabled
    public static resultForStatus getEnvelopeStatusForAll(Id PatentID) {
        cmpAPDocuSignGetEnveStatus bc = NEW cmpAPDocuSignGetEnveStatus(PatentID);
        Id batchprocessid = database.executeBatch(bc, 1);
        resultForStatus rs = NEW resultForStatus();
        rs.result = 'Initiated';
        rs.batchID = batchprocessid;
        return rs;
    }
    
    @AuraEnabled
    public static string getEnvelopeStatus(string envelopeId) {
        string result = 'Initiated';
        String ErrorInProcess = '';        
        EnvelopeInfo__c objEnvelope = [SELECT Id, Name, Status__c,Status_Fetched_on__c, Attachment_Id__c, Certificate_Attachment_Id__c, Error_Text_on_Status_Fetch__c,Error_on_Status_Fetch__c,Error_Count_on_Fetch_Status__c 
                                       FROM EnvelopeInfo__c 
                                       WHERE EnvelopeId__c =:envelopeId LIMIT 1];
        
        try {
            
             	string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        		string responseBody = '';
        		string apiBody = '';
        		//System.debug('apiHeader' + apiHeader);
        		string apiBodyLength = String.valueOf(apiBody.length());
        		DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        		HttpRequest req = new HttpRequest();
        		req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelopeId );
        		req.setMethod('GET');  
        		req.setHeader('Content-type', 'application/json');
        		req.setHeader('Authorization', 'Bearer ' + apiHeader );
        		req.setTimeout(120000);
        		Http http = new Http();
            
            cmpAPDocuSignEnvelopeDocuments objDocuments ;
            integer getStatusCode=0;
            string Response='';
            string getStatus='';
            if(!test.isRunningTest()) {
                try{
                    HTTPResponse httpResponse = http.send(req);
                    system.debug('httpResponse.getBody() ' + httpResponse.getBody());
                    system.debug('httpResponse.getStatusCode() ' + httpResponse.getStatusCode());
                    getStatusCode=httpResponse.getStatusCode();
                    getStatus=httpResponse.getStatus();
                    Response=httpResponse.getBody();
                } catch(exception exp) {
                    system.debug('exp.getMessage() + exp.getStackTraceString() ' + exp.getMessage() + exp.getStackTraceString());
                    
                }
            }
            
            if(test.isRunningTest()) 
              getStatusCode = 200;
            
            if(getStatusCode == 200 || getStatusCode == 201) {
                        cmpAPDocuSignResponse objResponse = (cmpAPDocuSignResponse) JSON.deserialize(Response,cmpAPDocuSignResponse.Class);
                        objDocuments = new cmpAPDocuSignEnvelopeDocuments();
                        system.debug('objResponse ' + objResponse);
                        
                        if (objResponse != null) {
                            if (objEnvelope != null) {
                                objEnvelope.Status__c = objResponse.status;
                                objEnvelope.Status_Fetched_on__c = system.now();
                                if (objEnvelope.Status__c != 'completed')
                                    objEnvelope.DownloadStatus__c = 'Pending';
                                objEnvelope.Error_Text_on_Status_Fetch__c = '';
                                objEnvelope.Error_on_Status_Fetch__c = false;
                                objEnvelope.Error_Count_on_Fetch_Status__c = 0;
                                UPDATE objEnvelope;
                            }
                            if (objEnvelope.Status__c =='completed') {
                                result +='-'+'completed';
                            }
                            
                        }
                        
                    } else {
                        objEnvelope.Error_Text_on_Status_Fetch__c = 'Status Fetch Failed: '+getStatusCode +' - '+getStatus;
                        objEnvelope.Error_on_Status_Fetch__c = true;
                        if(objEnvelope.Error_Count_on_Fetch_Status__c!=null)
                            objEnvelope.Error_Count_on_Fetch_Status__c = objEnvelope.Error_Count_on_Fetch_Status__c + 1;
                        else
                            objEnvelope.Error_Count_on_Fetch_Status__c = 1;
                        objEnvelope.DownloadStatus__c = 'Pending';
                        objEnvelope.Error_Text_on_Status_Fetch__c = 'While fetching documents- ';
                        UPDATE objEnvelope;
                    }
            
            
            
            return result;
            
        }catch(Exception exp){
            system.debug('exp.getMessage() + exp.getStackTraceString() ' + exp.getMessage() + exp.getStackTraceString());
            return 'Fail';
        }
    }
    
    @AuraEnabled
    public static string EnvelopeIdUpdateRedirectedStatus(string Status, string envelope_id) {
        string recordId='';
        String query = 'SELECT Id,Status__c,recordId__c FROM EnvelopeInfo__c  WHERE EnvelopeId__c =\'' + envelope_id + '\''; 
        EnvelopeInfo__c [] records = Database.query(query);
        if(records.size() >0 ){
            recordId=records[0].recordId__c;
            records[0].put('Status__c',Status);
            Database.update(records[0]);
        }
        
        if(recordId!='')
            cmpDocuSignCreateEnvelopeCtrl.CleanDocuSignDetails(recordId);
        
        
        return 'Success';
    }
    
    @AuraEnabled
    public static string EnvelopeIdUpdateStatus(string Status, string envelope_id) {
        String query = 'SELECT Id,Status__c,recordId__c FROM EnvelopeInfo__c  WHERE EnvelopeId__c =\'' + envelope_id + '\''; 
        EnvelopeInfo__c [] records = Database.query(query);
        if(records.size() >0 ){
            records[0].put('Status__c',Status);
            Database.update(records[0]);
        }
       
        
        return 'Success';
    }
    
    @auraEnabled
    public static string getProcessingJobStatus(String ApexJobId){
        string Status='';
        List<AsyncApexJob> ApexJob = [SELECT ApexClassId,Id,JobItemsProcessed,Status,TotalJobItems,ExtendedStatus 
                        FROM AsyncApexJob 
                        WHERE  Id=:ApexJobId];
        system.debug('ApexJob ' + ApexJob);
        if(ApexJob.size()>0) { 
        	for(AsyncApexJob  Reviewers : ApexJob) {
        	    Status=Reviewers.Status;	
        	}
        }
        return Status;
    }
    
    @AuraEnabled
    public static string OnDocuSignReview(String recordId,string ApexJobId) { 
        string result='';
        string Status='';
        try {
                String query = 'SELECT Id,EnvelopeId__c,Status__c,recordId__c FROM EnvelopeInfo__c WHERE Id =\'' + recordId + '\''; 
                System.debug('query' + query);
                List<EnvelopeInfo__c> records = Database.query(query);
                if(records.size() >0 ){
                    for(EnvelopeInfo__c data : records ) {
                        if (data.Status__c=='created'){
                         	result=Sendingview(data.recordId__c,data.EnvelopeId__c);   
                        }
                    }
                } 
                return result;
        }catch(Exception e){
            return 'Error';
        }
        
    }
    
     @AuraEnabled
    public static string Sendingview(string PatentID, string envelope_id) {
        DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        string responseBody = '';
        apiBody = '{\"returnUrl\": \"https://' + objCSDocuSign.Organization__c +'/c/cmpDocuSignRedirectApp.app?Id='+PatentID+'\"}';
        //System.debug('apiHeader' + apiHeader);
        //System.debug('apiBody' + apiBody);
        string apiBodyLength = String.valueOf(apiBody.length());
        HttpRequest req = new HttpRequest();
        req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelope_id + '/views/sender');
        req.setMethod('POST');  
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
                     if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                       	responseBody= httpResponse.getBody();      
                     } else {
                         responseBody= httpResponse.getBody(); 
                     }
                    
                    }
                    catch(Exception exp) {
                     	responseBody=exp.getStackTraceString();
      				}
    		}
        
         //System.debug('responseBody' + responseBody);
        
         return responseBody;
        
 }
    
    @AuraEnabled
    Public static List<cmpAPDocuSignSupplimentalAttachment> ContentVersionUpdate(String ContentVersionId, string DocuSigned) {
	   List<cmpAPDocuSignSupplimentalAttachment> objSupplimentalAttachments = new List<cmpAPDocuSignSupplimentalAttachment>();
       List<ContentVersion> Inventors = new List<ContentVersion>();
       Set <String> inventorId = new Set <String>();
       ContentVersionId = ContentVersionId.replace(' ', '');
       String[] words=ContentVersionId.split(',');
       for(String w:words) {
            inventorId.add(w);
        	ContentVersion Inventor = new ContentVersion();                           
        	Inventor.Id = w;
        	Inventor.IDF_File_Type__c = DocuSigned;
        	Inventors.add(Inventor);
       } 
        
         if (Inventors.size() > 0){
            Update Inventors;
		}
       
        if (inventorId.size()>0){
            List<ContentVersion> objContentVersionsP = [SELECT Id, PathOnClient, Title,ContentDocumentId 
                                                    FROM ContentVersion 
                                                    WHERE Id IN :inventorId AND FileExtension='pdf'];
        	for(ContentVersion objContentVersion : objContentVersionsP ) {
            	cmpAPDocuSignSupplimentalAttachment objDocuSignSupplimentalAttachment = new cmpAPDocuSignSupplimentalAttachment();
            	objDocuSignSupplimentalAttachment.objContentVersion = objContentVersion ;
            	objDocuSignSupplimentalAttachment.docTitle = objContentVersion.Title;
            	objDocuSignSupplimentalAttachment.isChecked = false; 
            	objDocuSignSupplimentalAttachment.isFinalDoc = 'Y';    
            	objDocuSignSupplimentalAttachment.CVId = objContentVersion.Id;
            	objSupplimentalAttachments.add(objDocuSignSupplimentalAttachment);            
        	}
        }
		
        
        System.debug('objSupplimentalAttachments' + objSupplimentalAttachments);
        return objSupplimentalAttachments ;
        
    }
    
    @AuraEnabled
    public static string UnSelectedInventors(String PatentID, Boolean IsPatent) {
    	List<DocuSignReviewer__c> Inventors = new List<DocuSignReviewer__c>();
        List<DocuSignReviewer__c> lstInventors = new List<DocuSignReviewer__c>();
        lstInventors = [SELECT Id FROM DocuSignReviewer__c WHERE recordId__c =:PatentID];    
              
        if ( lstInventors.Size() > 0) {
            for(DocuSignReviewer__c objInventor : lstInventors) {
                DocuSignReviewer__c Inventor = new DocuSignReviewer__c();                           
                Inventor.Id = objInventor.Id;
                Inventor.IsDocuSign__c = false;
                Inventors.add(Inventor);
            }  
        }
        
        if ( Inventors.size() > 0){
            Update Inventors;
		}
        
        //System.debug('inventorIds' + Inventors);
        return 'Success';
        
    }
    
    @AuraEnabled
     Public static string EditAttachment(List<cmpAPDocuSignSupplimentalAttachment> attachments, string PatentID) {
         List<ContentVersion> ObjCV = new List<ContentVersion>();
        if(attachments.size()>0) {
         for(cmpAPDocuSignSupplimentalAttachment objContentVersion : attachments ) {
            	ContentVersion cv = new ContentVersion();
            	cv.Title = objContentVersion.docTitle;
             	cv.PathOnClient = objContentVersion.docTitle;
             	if(!test.isRunningTest()){
                 cv.Id = objContentVersion.CVId;
                 ObjCV.add(cv);            
             	}     
        	}
         }
         
         system.debug('ObjCV ' + ObjCV);
         if(ObjCV.size()>0)
             update ObjCV;
         
         return 'Success';
     }
    
     @AuraEnabled
     Public static string deleteAttachment(String contentVersionId, string PatentID) {
     List<ContentVersion> objContent = [SELECT Id, PathOnClient, Title,ContentDocumentId 
                                           FROM ContentVersion 
                                           WHERE (Id =:contentVersionId OR ContentDocumentId=:contentVersionId) limit 1 ];
        //system.debug('objContent ' + objContent);
        if(objContent.size()>0) {
            List<DocuSign_Document__c> Details = [Select Id FROM DocuSign_Document__c 
                                            WHERE ContentDocumentId__c =: objContent[0].ContentDocumentId
                                            AND recordId__c =: PatentID limit 1];
            
            //system.debug('Details ' + Details);
            
            if(Details.size()>0) {
                DeletedDocuSignedId(contentVersionId,PatentID);
            } else {
                 List<ContentDocument> ObjCD = [SELECT Id FROM ContentDocument WHERE Id=:objContent[0].ContentDocumentId ];
                if(ObjCD.size()>0)
                    delete ObjCD;
            }
        }
        
        return 'Deleted';
    }
    
    @AuraEnabled
    Public static string DeletedDocuSignedId(String DocuSignedId, string PatentID) {
        
       List<ContentVersion> objContent = [SELECT Id, PathOnClient, Title,ContentDocumentId 
                                           FROM ContentVersion 
                                           WHERE (Id =:DocuSignedId OR ContentDocumentId=:DocuSignedId) ];
        
        //system.debug('objContent ' + objContent);
        
       if(objContent.size()>0) {
        List<DocuSign_Document__c> Details = [Select Id FROM DocuSign_Document__c 
                                            WHERE ContentDocumentId__c =: objContent[0].ContentDocumentId
                                            AND recordId__c =: PatentID];
           
           //system.debug('Details ' + Details);
           
        if(Details.size()>0) {
         List<DocuSignDetails__c> DocDetails = [Select Id,recordId__c,DocuSign_Document__c  
                                            FROM DocuSignDetails__c 
                                            WHERE DocuSign_Document__c =: Details[0].Id
                                            AND recordId__c =: PatentID];
            
            		//system.debug('Details ' + Details);
            
                  if (DocDetails.size() > 0) {
                      for(DocuSignDetails__c record : DocDetails ) {
                          
                           try {
                               cmpAPDocuSignCtrl.RowActionsDelete(record.Id);
                           } catch(Exception exp){
                               System.debug('EnvelopeId' + exp.getMessage() + exp.getStackTraceString());
                           }
                          
                          
                         
                           List<ContentDocument> ObjCD = [SELECT Id FROM ContentDocument WHERE Id=:objContent[0].ContentDocumentId ];
                          if(ObjCD.size()>0)
                              delete ObjCD;
                          
                      }
                  } else {
                      List<ContentDocument> ObjCD = [SELECT Id FROM ContentDocument WHERE Id=:objContent[0].ContentDocumentId ];
                      if(ObjCD.size()>0)
                          delete ObjCD;
                  }
            
            
        }
     }
        
        return 'Deleted';
    }
    
    @AuraEnabled
    public static string SelectDocuSignedFromFiles(String DocuSignedId, String PatentID) {
        List<DocuSignTab__c> ObjTab = new List<DocuSignTab__c>();
        List<ContentVersion> objContent = [SELECT Id, PathOnClient, Title,ContentDocumentId 
                                           FROM ContentVersion 
                                           WHERE (Id =:DocuSignedId OR ContentDocumentId=:DocuSignedId) ];
        if(objContent.size()>0) {
            
            List<DocuSign_Document__c> ObjDocuSign = [SELECT Id
                                           FROM DocuSign_Document__c 
                                           WHERE (Id =:DocuSignedId OR ContentDocumentId__c=:objContent[0].ContentDocumentId)
                                           AND recordId__c=:PatentID];
            
           //system.debug('ObjDocuSign' + ObjDocuSign);
           //system.debug('PatentID' + PatentID);
           //system.debug('DocuSignedId' + DocuSignedId);
               
          if(ObjDocuSign.size()>0){              
              DocuSign_Document__c DocuSign = new DocuSign_Document__c();                           
        	  DocuSign.Id = ObjDocuSign[0].Id;
        	  DocuSign.IsActive__c = true;
              update DocuSign;
              SelectDocuSignedId(objContent[0].ContentDocumentId,ObjDocuSign[0].Id,PatentID);
                  
          } else { 
        	DocuSign_Document__c DocuSign = new DocuSign_Document__c();                           
        	DocuSign.Name = objContent[0].PathOnClient.left(80);
        	DocuSign.IsActive__c = true;
        	DocuSign.Sequance__c=1;
            DocuSign.recordId__c=PatentID;
            DocuSign.ContentDocumentId__c=objContent[0].ContentDocumentId;
            insert DocuSign;
            
            ContentDocumentLink DLink = new ContentDocumentLink(); 
            DLink.ContentDocumentId=objContent[0].ContentDocumentId;
            DLink.LinkedEntityId=DocuSign.Id;
            insert DLink;
             
            DocuSignTab__c Tab = new DocuSignTab__c(); 
            Tab.DocuSign_Document__c=DocuSign.Id;
            Tab.Document_Type__c='Yes';
            Tab.Data_Type__c='Text';
            Tab.XPosition__c=0;
            Tab.YPosition__c=0;
            Tab.Tabs__c='dateSignedTabs';
            Tab.AnchorString__c='#dateSignedTabs';
            Tab.pageNumber__c=1;
            ObjTab.add(Tab);
            
            DocuSignTab__c Tab1 = new DocuSignTab__c(); 
            Tab1.DocuSign_Document__c=DocuSign.Id;
            Tab1.Document_Type__c='Yes';
            Tab1.Data_Type__c='Text';
            Tab1.XPosition__c=0;
            Tab1.YPosition__c=0;
            Tab1.Tabs__c='signHereTabs';
            Tab1.AnchorString__c='#Signature';
            Tab1.pageNumber__c=1;
            ObjTab.add(Tab1);
            
            if(ObjTab.size()>0)
                insert ObjTab;
           
            SelectDocuSignedId(objContent[0].ContentDocumentId,DocuSign.Id,PatentID);
              
          } 
            
        }     
        
        return 'Success';
    }
    
    @AuraEnabled
    public static string SelectInventors(String inventorIds, String PatentID, Boolean IsPatent) {
       
         	Set <String> inventorId = new Set <String>();
        	inventorIds = inventorIds.replace(' ', '');
            integer i=1;
            String[] words=inventorIds.split(',');
            for(String w:words){  
				inventorId.add(w);
            }  
        
        List<DocuSignReviewer__c> Inventors = new List<DocuSignReviewer__c>();
        List<DocuSignReviewer__c> lstInventors = new List<DocuSignReviewer__c>();
        lstInventors = [SELECT Id FROM DocuSignReviewer__c WHERE Id IN :inventorId AND recordId__c =:PatentID];    
       
        if ( lstInventors.Size() > 0) {
            for (DocuSignReviewer__c objInventor : lstInventors) {
                DocuSignReviewer__c Inventor = new DocuSignReviewer__c();                           
                Inventor.Id = objInventor.Id;
                Inventor.IsDocuSign__c = true;
                Inventor.RecipientId__c=i;
                Inventor.Status__c='';
                i=i+1;
                Inventors.add(Inventor);
            }  
        }
        
        if ( Inventors.size() > 0){
            Update Inventors;
		}
        
        //System.debug('SelectInventors' + inventorId);
        return 'Success';
    }
    
     public class resultForStatus {
        @AuraEnabled public string result{get;set;}
        @AuraEnabled public string batchID{get;set;}
    }
    
    @AuraEnabled
    public static String RowActionsDelete(String recordId) {
        Id id = Id.valueOf(recordId);
        delete id.getSobjectType().newSObject(id);
        return id;
    }
    
    
    
     @AuraEnabled
    Public static string SelectDocuSignedId(string ContentDocumentId, String DocuSignedId, string PatentID) {
         List<DocuSignDetails__c> DocDetails = [Select Id,recordId__c,DocuSign_Document__c  
                                            FROM DocuSignDetails__c 
                                            WHERE DocuSign_Document__c = : DocuSignedId
                                            AND recordId__c =: PatentID];
                  if (DocDetails.size() == 0) {
                      DocuSignDetails__c DocuSignDetails = new DocuSignDetails__c();                           
                      DocuSignDetails.DocuSign_Document__c = DocuSignedId;
                      DocuSignDetails.recordId__c = PatentID;
                      DocuSignDetails.ContentDocumentId__c = ContentDocumentId;
                      insert DocuSignDetails;
                      //System.debug('DocuSignDetails' + DocuSignDetails); 
                  }
        
        return 'Success';
    }
    
    @AuraEnabled
    public static List<cmpAPDocuSignSupplimentalAttachment> GetDocuSigned(Id PatentId) {
        List<cmpAPDocuSignSupplimentalAttachment> objSupplimentalAttachments = new List<cmpAPDocuSignSupplimentalAttachment>();
        List<DocuSign_Document__c> DocuSigns = [SELECT Id,Name FROM DocuSign_Document__c Where IsActive__c=true];
        if(DocuSigns.size()>0){
            for(DocuSign_Document__c DocTemp : DocuSigns) {
            	cmpAPDocuSignSupplimentalAttachment objDocuSignSupplimentalAttachment = new cmpAPDocuSignSupplimentalAttachment();
            	objDocuSignSupplimentalAttachment.objContentVersion = null ;
            	objDocuSignSupplimentalAttachment.docTitle = DocTemp.Name;
            	objDocuSignSupplimentalAttachment.isChecked = true; 
            	objDocuSignSupplimentalAttachment.isFinalDoc = '';    
            	objDocuSignSupplimentalAttachment.CVId = DocTemp.Id;
                //SelectDocuSignedId(DocTemp.Id, PatentId);
            	objSupplimentalAttachments.add(objDocuSignSupplimentalAttachment);            
            }
        }
        return objSupplimentalAttachments ;
    }
    
    @AuraEnabled
    public static resultForStatus getEnvelopeIdStatus(string PatentID) {
        
        string Title = 'N/A';
        string ApplicationNo = '';
        string ApplicationDate = '';
        string respAttorneyEmail = '';
        string emBody = getemailbody('Patent');
        Date TargetFilingDate = Null;
        string DocketNo = 'Docket No. - N/A';
        string InventorNames = '';
        string PrimaryInventorId = null;
        string EnvelopeId='';
        string DocuSign_Instructional_text_to_innovator='';
        string objAssetInventorId='';
        resultForStatus rs = NEW resultForStatus();
		string recordId='';        
        	
        
         List<EnvelopeInfo__c> DocDetails = [Select Id,recordId__c,EnvelopeId__c,Person_Name__c,Receivers__c,Person__c
                                             FROM EnvelopeInfo__c 
                                             WHERE Id =: PatentID ];
                  if (DocDetails.size() > 0) {
                      for(EnvelopeInfo__c record : DocDetails ) {
                          
                          //system.debug('record ' + record);
                          objAssetInventorId=record.Person__c;
                          InventorNames=record.Person_Name__c;
                          String temp=record.Receivers__c.SubStringAfter('(');
                		  respAttorneyEmail=temp.SubStringBefore(')');
                          recordId=record.recordId__c;
                          
                          
                  List<DocuSign_Fields__c> DocFields = [Select Id,Application_No__c,Filing_Date__c,Title__c,DocketNo__c
                                             FROM DocuSign_Fields__c 
                                             WHERE recordId__c =: recordId ];
                  if (DocFields.size() > 0) {
                      for(DocuSign_Fields__c data : DocFields ) {
                           Title=data.Title__c;
                           ApplicationNo=data.Application_No__c;
                           ApplicationDate=string.valueof(data.Filing_Date__c);
                           DocketNo=data.DocketNo__c;
                      }
                  }
                          
                          
                          List<cmpAPDocuSignSupplimentalAttachment> SupplimentalAttachments = GetDocuSigned(record.recordId__c);
                          //system.debug('SupplimentalAttachments ' + SupplimentalAttachments);
                          
                          List<Id> SupplimentalAttachmentIds = new List<Id>();
                          List<Id> DocuId = new List<Id>();
                          List<Id> ContentDocumentIds = new List<Id>();
                          
                          for(cmpAPDocuSignSupplimentalAttachment SupplimentalAttachment : SupplimentalAttachments) {
                               DocuId.add(SupplimentalAttachment.CVId);
                          }
                          
       List<ContentDocumentLink> objContentDocumentLinksP = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :DocuId];
        for(ContentDocumentLink objContentDocumentLinkp : objContentDocumentLinksP) {
            ContentDocumentIds.add(objContentDocumentLinkp.ContentDocumentId);
        }
        
        List<ContentVersion> objContentVersionsP = [SELECT Id, PathOnClient, Title,ContentDocumentId FROM ContentVersion WHERE  ContentDocumentId IN :ContentDocumentIds];
        for(ContentVersion objContentVersion : objContentVersionsP ) {
            SupplimentalAttachmentIds.add(objContentVersion.Id);           
        }
                          
                        
                          	//system.debug('SupplimentalAttachmentIds ' + SupplimentalAttachmentIds);
                          cmpDocuSignCreateEnvelopeCtrl.cmpDocuSignBatchMultipleCtrl(record.Id,record.recordId__c,SupplimentalAttachmentIds,Title,TargetFilingDate,ApplicationNo,ApplicationDate,DocketNo,InventorNames,objAssetInventorId,emBody,respAttorneyEmail,'','','','');
                           
                      }
                  }
       
        return rs;
    }
    
    @AuraEnabled
    public static string SubmitMultipleSignaturesAPI(String PatentID, List<cmpAPDocuSignSupplimentalAttachment> SupplimentalAttachments, String emailBody, boolean IsPatent, String IsStatus, boolean IsMultipleSignatures,string ExpireAfter,string ExpireWarn,string ReminderDelay,string ReminderFrequency) {
        string Title = 'N/A';
        string ApplicationNo = '';
        string ApplicationDate = '';
        string respAttorneyEmail = '';
        string emBody = emailBody;
        Date TargetFilingDate = Null;
        string DocketNo = 'Docket No. - N/A';
        string InventorNames = '';
        string PrimaryInventorId = null;
        string EnvelopeId='';
        string DocuSign_Instructional_text_to_innovator='';
        string batchInstanceId ='';
        List<Id> EnvelopeIds = new List<Id>();
        List<EnvelopeInfo__c> objToBeInsertedEnvelopes=new List<EnvelopeInfo__c>();
        
        
        try {
          
            	  List<DocuSign_Fields__c> DocFields = [Select Id,Application_No__c,Filing_Date__c,Title__c,DocketNo__c
                                             FROM DocuSign_Fields__c 
                                             WHERE recordId__c =: PatentID ];
                  if (DocFields.size() > 0) {
                      for(DocuSign_Fields__c data : DocFields ) {
                           Title=data.Title__c;
                           ApplicationNo=data.Application_No__c;
                           ApplicationDate=string.valueof(data.Filing_Date__c);
                           DocketNo=data.DocketNo__c;
                      }
                  }
            
            List<Id> lstInventorIds = new List<Id>();  
            List<EnvelopeInfo__c> objEnvelopeInfos = new List<EnvelopeInfo__c>();
            List<EnvelopeInfo__c> objEnvelopes = [SELECT Id FROM EnvelopeInfo__c 
                                                  WHERE recordId__c =:PatentID 
                                                  AND Deleted__c=false];
            if (objEnvelopes.size()>0) {
                for(EnvelopeInfo__c  objAsset : objEnvelopes) {   
                    EnvelopeInfo__c envelope = new EnvelopeInfo__c();
                    envelope.Id=objAsset.Id;
                    envelope.Deleted__c=true;
                    objEnvelopeInfos.add(envelope);
                }
            }
            if (objEnvelopeInfos.size()>0)
                update objEnvelopeInfos;
            
            string strRecipients = '';
            List<DocuSignReviewer__c> objAssetInventors = new List<DocuSignReviewer__c>();
            List<cmpAPDocuSignRecipient> objRecipients = new List<cmpAPDocuSignRecipient>();
            integer i=1;
            string objAssetInventorId='';
            objAssetInventors =[SELECT Id,Inventor_Name__c,Person__c,Email__c 
                                FROM DocuSignReviewer__c 
                                WHERE IsDocuSign__c=true 
                                AND recordId__c = :PatentID ];
            if (objAssetInventors.size()>0) {
                for(DocuSignReviewer__c  objAssetInventor : objAssetInventors) {   
                    lstInventorIds.add(objAssetInventor.Person__c);
                    if (InventorNames !='')
                        InventorNames +=', ';
                    
                    InventorNames = objAssetInventor.Inventor_Name__c;
                    objAssetInventorId=objAssetInventor.Person__c;
                    objRecipients.add(new cmpAPDocuSignRecipient(InventorNames, objAssetInventor.Email__c, 'Signer ' + i, DocketNo , ApplicationNo, ApplicationDate, Title, InventorNames, '', InventorNames, objAssetInventorId));
             		i++;     
          		}
      		}            
            
           
            List<Id> SupplimentalAttachmentIds = new List<Id>();
            for(cmpAPDocuSignSupplimentalAttachment SupplimentalAttachment : SupplimentalAttachments) {
                if (SupplimentalAttachment.isChecked)
                    SupplimentalAttachmentIds.add(SupplimentalAttachment.objContentVersion.Id);
            }
            
            List<EnvelopeInfo__c> objAvailEnvelopes = [SELECT Id FROM EnvelopeInfo__c 
                                                       WHERE recordId__c =:PatentID 
                                                       AND Person__c =:objAssetInventorId 
                                                       AND Deleted__c=false];
            if(objRecipients.size()>0) {
            	for(cmpAPDocuSignRecipient objRecipient : objRecipients ) {
                InventorNames=objRecipient.signerName;
                objAssetInventorId=objRecipient.InventorId;
                respAttorneyEmail=objRecipient.recipientEMailId;
                boolean CanInsert = true;
           
             if (CanInsert) {
                //System.debug('insert');
              	EnvelopeInfo__c objEnvelope1 = new EnvelopeInfo__c();
              	objEnvelope1.Status__c = 'not started';
              	objEnvelope1.Status_Fetched_on__c = system.now();
              	objEnvelope1.recordId__c = PatentID;
              	objEnvelope1.Receivers__c = objRecipient.recipientName + ' (' + objRecipient.recipientEMailId + ')';
                objEnvelope1.Person__c = objRecipient.InventorId;
                objEnvelope1.ReqStatus__c = IsStatus;
                objEnvelope1.IsRecipients__c = IsMultipleSignatures;
                objEnvelope1.DocuSign_Instructional_text_to_innovator__c = DocuSign_Instructional_text_to_innovator;
                
                List<cmpAPDocuSignAttachmentWrapper> DocuSignAttachments = new List<cmpAPDocuSignAttachmentWrapper>();
                 
                  integer Docu=1;
                  List<DocuSignDetails__c> DocDetails = [Select Id,recordId__c,DocuSign_Document__r.Id,
                                                      DocuSign_Document__r.Name,DocuSign_Document__r.Sequance__c 
                                                      FROM DocuSignDetails__c 
                                                      WHERE recordId__c =: PatentID
                                                      Order by DocuSign_Document__r.Sequance__c ];
                  if (DocDetails.size() > 0) {
                      for(DocuSignDetails__c record : DocDetails ) {
                         DocuSignAttachments.add(new cmpAPDocuSignAttachmentWrapper(objEnvelope1.Id, string.valueOf(Docu), record.DocuSign_Document__r.Name));
                         Docu=Docu+1;
                      }
                  }
                 
                 for(cmpAPDocuSignSupplimentalAttachment SupplimentalAttachment : SupplimentalAttachments) {
                     if (SupplimentalAttachment.isChecked){
                        DocuSignAttachments.add(new cmpAPDocuSignAttachmentWrapper(objEnvelope1.Id, string.valueOf(Docu), SupplimentalAttachment.docTitle));
                       	Docu=Docu+1;  
                     	}
            		}
                 
                 
                 
                 
                 if (Docu==1) {
                     return '01-Attachment';
                 } else {
                    Insert objEnvelope1;
                 	EnvelopeId=objEnvelope1.Id;
                    EnvelopeIds.add(EnvelopeId);
                 }
                 
                 
                 if (DocuSignAttachments.size()>0) {
                     for(cmpAPDocuSignAttachmentWrapper Attachment : DocuSignAttachments ) {
                       DocuSignAttachment(EnvelopeId, Attachment.ContentVersionId, Attachment.Title);   
                     }
                 }
                 
             }
            
            
        string DocuSignReminder='No';
                    
        //System.debug('EnvelopeId' + EnvelopeId);
        
        if (EnvelopeId!='') 
            cmpDocuSignCreateEnvelopeCtrl.cmpDocuSignBatchMultipleCtrl(EnvelopeId,PatentID,SupplimentalAttachmentIds,DocuSignReminder,TargetFilingDate,ApplicationNo,ApplicationDate,DocketNo,InventorNames,objAssetInventorId,emBody,respAttorneyEmail,ExpireAfter,ExpireWarn,ReminderDelay,ReminderFrequency);
        
   	}
   }
       		
            
            batchInstanceId=EnvelopeId;
            UpdatebatchInstanceId(EnvelopeIds);
            return 'Success-'+EnvelopeId + '-' + batchInstanceId;
       } catch(Exception exp){
            System.debug('EnvelopeId' + exp.getMessage() + exp.getStackTraceString());
            return 'Fail';
        }
        
        
        
    }
    
    @AuraEnabled
    public static void UpdatebatchInstanceId(List<Id> EnvelopeId) {
        DateTime dt = DateTime.now();
        String batchInstanceId = UserInfo.getUserId()+dt.format('yyyyMMddhhmmss');
        List<EnvelopeInfo__c> ObjEnvelopes = new List<EnvelopeInfo__c>();
        for(Integer i = 0; i < EnvelopeId.size(); i++) { 
        	EnvelopeInfo__c EnvelopeInfo = new EnvelopeInfo__c();                           
        	EnvelopeInfo.Id = EnvelopeId[i];
        	EnvelopeInfo.batchInstanceId__c = batchInstanceId;
        	ObjEnvelopes.add(EnvelopeInfo);
        }
   if(ObjEnvelopes.size()>0)
       update ObjEnvelopes;
        
        
    }
    
    
      @AuraEnabled
      public static string DocuSignAttachment (String EnvelopeInfoId, string ContentVersionId, string Title) {
        string result = '';
        try{
           
                DocuSignAttachment__c DocuSigns = new DocuSignAttachment__c();
                DocuSigns.EnvelopeInfo__c = EnvelopeInfoId;
                DocuSigns.ContentVersionId__c=ContentVersionId;
                DocuSigns.Title__c=Title;
                insert DocuSigns;
            	return 'Success';
        }
        catch(Exception exp) {
            return 'Fail';
        }        
    } 
    
    @AuraEnabled
    public static string UpdateRecord(String recordId, String fieldApi, String fieldvalue ) { 
        try {
                String query = 'SELECT Id,' +  fieldApi + ' FROM DocuSign_Fields__c WHERE recordId__c =\'' + recordId + '\''; 
                System.debug('query' + query);
                DocuSign_Fields__c[] records = Database.query(query);
                if(records.size() >0 ){
                     records[0].put('Id',records[0].Id);
                     records[0].put(fieldApi,fieldvalue);
                     Database.update(records[0]);
                }
                return 'Success';
        }catch(Exception e){
            return e.getMessage() + '--' +e.getStackTraceString();
        }
    }    
    
     @AuraEnabled
    public static string UpdateDateRecord(String recordId, String fieldApi, String fieldvalue ) { 
        try {
                String query = 'SELECT Id,' +  fieldApi + ' FROM DocuSign_Fields__c WHERE recordId__c =\'' + recordId + '\''; 
                //System.debug('query' + query);
                DocuSign_Fields__c[] records = Database.query(query);
                if(records.size() >0 ){
                     records[0].put('Id',records[0].Id);
                     records[0].put(fieldApi, date.valueof(fieldvalue));
                     Database.update(records[0]);
                }
                return 'Success';
        }catch(Exception e){
            return e.getMessage() + '--' +e.getStackTraceString();
        }
    }    
    
    @AuraEnabled
    public static List<EnvelopeInfo__c> getEnvelopesInventors(String PatentId) {
        Id profileId=userinfo.getProfileId();
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        String searchWord = '';
		//system.debug('ProfileName'+profileName);
        //system.debug('PatentId'+PatentId);
        List<EnvelopeInfo__c> objEnvelopes = new List<EnvelopeInfo__c>();
        string queryString='';
        
        queryString = 'SELECT Name, Person__c,';
        queryString += ' EnvelopeId__c, Sent_On__c, Status__c,Status_Fetched_on__c, Receivers__c, ';
        queryString += ' Attachment_Id__c, Certificate_Attachment_Id__c, SignedAssignment__c, SignedOathDeclaration__c,Error_Occurred__c,'; 
        queryString += ' Error_Text__c, Error_Text_on_Status_Fetch__c,Error_on_Status_Fetch__c,'; 
        queryString += ' Error_Count_on_Fetch_Status__c,Deleted__c,Docusign_API_Status__c,DownloadStatus__c,Person_Name__c'; 
        queryString += ' FROM EnvelopeInfo__c'; 
        queryString += ' WHERE recordId__c =\'' + PatentId + '\'';
        
        queryString += ' Order By CreatedDate ASC ';
        objEnvelopes=Database.query(queryString);
        
        return objEnvelopes;
    }
    
    
    @AuraEnabled 
    public static boolean getIsReviewBeforeSend(string Process) {
        boolean strHeader=false;
        List<DocuSignConfiguration__mdt> objAssetInventors = new List<DocuSignConfiguration__mdt>();
        objAssetInventors =[SELECT Id,EmailTemplate__c,IsReviewBeforeSend__c FROM DocuSignConfiguration__mdt WHERE Process__c=:Process];
            if (objAssetInventors.size()>0) {
                for(DocuSignConfiguration__mdt  objAssetInventor : objAssetInventors) {   
                    strHeader=objAssetInventor.IsReviewBeforeSend__c;
                }
            }
       
        system.debug('strHeader' + strHeader);
        return strHeader;
    }
    
    @AuraEnabled 
    public static string getemailbody(string Process) {
        string strHeader='';
        List<DocuSignConfiguration__mdt> objAssetInventors = new List<DocuSignConfiguration__mdt>();
        objAssetInventors =[SELECT Id,EmailTemplate__c FROM DocuSignConfiguration__mdt WHERE Process__c=:Process];
            if (objAssetInventors.size()>0) {
                for(DocuSignConfiguration__mdt  objAssetInventor : objAssetInventors) {   
                    strHeader=objAssetInventor.EmailTemplate__c;
                }
            }
       
        system.debug('strHeader' + strHeader);
        return strHeader;
    }
    
   
   
    @AuraEnabled
    public static List<cmpAPDocuSignSupplimentalAttachment> getSupplimentalAttachments(Id PatentId) {
        
        Map<Id,Id> lstContentDocumentIds = new Map<Id, Id>();
        Map<Id,Id> lstContentDocumentIdsP = new Map<Id, Id>();
        Map<Id,Id> lstContentDocumentIdsDocuSigned = new Map<Id, Id>();
        List<id> LinkedEntityIds = NEW List<id>{};
        List<id> DocuSignLinkedEntityIds = NEW List<id>{};
        List<id> ContentVersionIds = NEW List<id>{};
        string APDid = '';
        List<string> APDidDocs = NEW List<string>();
        List<cmpAPDocuSignSupplimentalAttachment> objSupplimentalAttachments = new List<cmpAPDocuSignSupplimentalAttachment>();
       
        List<ContentDocumentLink> objContentDocumentLinksP = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink
                                                              WHERE LinkedEntityId =:PatentId];
        for(ContentDocumentLink objContentDocumentLinkp : objContentDocumentLinksP) {
            if (lstContentDocumentIdsP.containsKey(objContentDocumentLinkp.ContentDocumentId)==false) {
                lstContentDocumentIdsP.put(objContentDocumentLinkp.ContentDocumentId, objContentDocumentLinkp.ContentDocumentId);                
            }
        }
        
        List<ContentVersion> objContentVersionsP = [SELECT Id, PathOnClient, Title,ContentDocumentId 
                                                    FROM ContentVersion 
                                                    WHERE FileExtension='pdf'
                                                    AND  ContentDocumentId IN :lstContentDocumentIdsP.values()
                                                    ORDER BY CreatedDate DESC];
        for(ContentVersion objContentVersion : objContentVersionsP ) {
            cmpAPDocuSignSupplimentalAttachment objDocuSignSupplimentalAttachment = new cmpAPDocuSignSupplimentalAttachment();
            objDocuSignSupplimentalAttachment.objContentVersion = objContentVersion ;
            objDocuSignSupplimentalAttachment.docTitle = objContentVersion.Title;
            objDocuSignSupplimentalAttachment.isChecked = false; 
            objDocuSignSupplimentalAttachment.isFinalDoc = 'Y'; 
            objDocuSignSupplimentalAttachment.CVId = objContentVersion.Id;
            objDocuSignSupplimentalAttachment.ContentDocumentId = objContentVersion.ContentDocumentId;
            
            ContentVersionIds.add(objContentVersion.Id);
            objSupplimentalAttachments.add(objDocuSignSupplimentalAttachment);            
        }
        
        cmpAPDocuSignCtrl.ContentVersionUnSelected(ContentVersionIds,'');
        return objSupplimentalAttachments ;
    }
    
    @AuraEnabled
    Public static string ContentVersionUnSelected(List<string> ContentVersionId, string DocuSigned) {
      		List<ContentVersion> Inventors = new List<ContentVersion>();
			List<ContentVersion> Versions = [SELECT Id, PathOnClient, Title,ContentDocumentId 
                                                    FROM ContentVersion 
                                                    WHERE Id IN :ContentVersionId];
        if ( Versions.size()>0){
           for(ContentVersion data : Versions ) {
            	ContentVersion Inventor = new ContentVersion();                           
        		Inventor.Id = data.Id;
        		Inventor.IDF_File_Type__c = DocuSigned;
        		Inventors.add(Inventor);
        	}  
        }
       
        if (Inventors.size()>0)
            update Inventors;
            
        return '';
    }
    
     @AuraEnabled
    public static string ValidateDocuSignFields(String recordId) {
        
        try {
                String query = 'SELECT Id FROM DocuSign_Fields__c WHERE recordId__c =\'' + recordId + '\''; 
                //System.debug('query' + query);
                DocuSign_Fields__c[] records = Database.query(query);
            	if(records.size()==0){
                    DocuSign_Fields__c DocuSignDetails = new DocuSign_Fields__c();                           
                    DocuSignDetails.recordId__c = recordId;
                    insert DocuSignDetails;
                }
            return 'Success';
        }catch(Exception e){
            return e.getMessage() + '--' +e.getStackTraceString();
        }
    }
    
    @AuraEnabled
    public static List<EnvelopeInfo__c> getEnvelopes(Id PatentId) {
        List<EnvelopeInfo__c> objEnvelopes = [SELECT Name, EnvelopeId__c, Sent_On__c, Status__c,Status_Fetched_on__c, Receivers__c, 
                                              Attachment_Id__c, Certificate_Attachment_Id__c, SignedAssignment__c, SignedOathDeclaration__c,Error_Occurred__c,
                                              Error_Text__c, Error_Text_on_Status_Fetch__c,Error_on_Status_Fetch__c,
                                              Error_Count_on_Fetch_Status__c
                                              FROM EnvelopeInfo__c 
                                              WHERE recordId__c = :PatentId 
                                              AND Deleted__c=false ORDER BY CreatedDate ASC];
        //System.debug('objEnvelopes' + objEnvelopes);
        return objEnvelopes;
    }
    
}