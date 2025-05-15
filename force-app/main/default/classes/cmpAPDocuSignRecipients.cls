global class cmpAPDocuSignRecipients implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful  {
    Public List<string> completedRecords{set;get;}
    public string Reviewer_Id{set;get;}
    public string query{set;get;}
    public string envelopeid{set;get;}
    public string Person_Id{set;get;}
    public string Patent_ID{set;get;}
    
    global cmpAPDocuSignRecipients(string ReviewerId, string envelope_id) {
        Reviewer_Id=ReviewerId;
        envelopeid=envelope_id;
        system.debug('Reviewer_Id' + Reviewer_Id);
        
        query = 'SELECT Id,Inventor_Name__c,Person__c,Email__c,Status__c,RecipientId__c,recordId__c FROM DocuSignReviewer__c Where  Id=:Reviewer_Id ';
        
        system.debug('query' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('query :'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<DocuSignReviewer__c> records) {
        
        string apiHeader = cmpAPDocuSignHelper.getHeader(); 
        string apiBody = '';
        string responseBody = '';
        string signHereTabs='';
        integer recipientId=2;
        boolean IsSent=false;
        List<DocuSignReviewer__c> SignReviewers = new List<DocuSignReviewer__c>();
        
        if (records.size()>0) {
             for(DocuSignReviewer__c recipients : records ) {
               DocuSignReviewer__c Reviewer = new DocuSignReviewer__c();
               Reviewer.Id=recipients.Id;
               Reviewer.Status__c='sent';
               Patent_ID=recipients.recordId__c;
               recipientId= integer.valueOf(recipients.RecipientId__c);
               if (recipientId==null)
                   recipientId=1;
                 
                 System.debug('Name' + recipients.Inventor_Name__c);
                 System.debug('RecipientId' + recipients.RecipientId__c);
                 
                 if (signHereTabs == '') {
                     	signHereTabs = '{';
                        signHereTabs += '"signers":[';
                    	signHereTabs += cmpAPDocuSignHelper.addRecipients(recipients.Email__c, recipients.Inventor_Name__c, string.valueOf(recipientId).replaceall('.0',''));
                     } else {
                    	signHereTabs += ', ' + cmpAPDocuSignHelper.addRecipients(recipients.Email__c, recipients.Inventor_Name__c, string.valueOf(recipientId).replaceall('.0',''));
                 }
                 
              	
                       
        signHereTabs += ']';
        signHereTabs += '}';
        apiBody=signHereTabs;
        System.debug('apiBody' + apiBody);         
                 
        string apiBodyLength = String.valueOf(apiBody.length());
        DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        HttpRequest req = new HttpRequest();
        string endpoint= objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelopeid + '/recipients';  
        system.debug('endpoint' + endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('POST');  
        
        if (apibody.trim()!='') {
            req.setBody(apibody);
            req.setHeader('Content-length', apiBodyLength);
        }
        req.setHeader('Content-type', 'application/json');
        req.setHeader('X-DocuSign-Authentication', apiHeader );
        req.setTimeout(120000);
        Http http = new Http();
        if(!test.isRunningTest()) {
            
       			try {
                     HTTPResponse httpResponse = http.send(req); 
                     System.debug('httpResponse()' + httpResponse.getBody());
                     System.debug('getStatusCode()' + httpResponse.getStatusCode());
                    
                     if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                    	System.debug('getStatusCode()' + httpResponse.getStatusCode());
                        SignReviewers.add(Reviewer); 
                     }
                    
                  }
                    catch(Exception exp) {
                     system.debug('SignReviewers' + exp.getStackTraceString());   
      			 }
            
    		}
      	}
            if (SignReviewers.size()>0)
                update SignReviewers;
            
        	system.debug('SignReviewers' + SignReviewers);
            
    	}
             
    }
    
    global void finish(Database.BatchableContext bc) {
		
        //DocuSignCreateSignHereTabs CreateSignHereTabs = NEW DocuSignCreateSignHereTabs(Reviewer_Id,envelopeid);
        //database.executeBatch(CreateSignHereTabs, 1);
    }    
}