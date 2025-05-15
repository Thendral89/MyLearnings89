global class cmpAPDocuSignCreateSignHereTabs implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful  {
    Public List<string> completedRecords{set;get;}
    public string Reviewer_Id{set;get;}
    public string query{set;get;}
    public string envelopeid{set;get;}
    public string Person_Id{set;get;}
    
    global cmpAPDocuSignCreateSignHereTabs(string ReviewerId, string envelope_id) {
        Reviewer_Id=ReviewerId;
        envelopeid=envelope_id;
        
        system.debug('Reviewer_Id' + Reviewer_Id);
        
        query = 'SELECT Id,Person__c,Email__c,Status__c,RecipientId__c,Inventor_Name__c FROM DocuSignReviewer__c Where  Id=:Reviewer_Id ';
        
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
       
         if (records.size()>0) {
             for(DocuSignReviewer__c recipients : records ) {
               		recipientId=integer.valueOf(recipients.RecipientId__c);
                    if(recipientId==null)
                        recipientId=1;
                        
                  if (signHereTabs == '') {
                      signHereTabs = '{';
                      signHereTabs += '"signHereTabs":[';
                      signHereTabs += cmpAPDocuSignHelper.getSignHereTabAnchorString('1', string.valueOf(recipientId).replaceall('.0',''),recipients.Inventor_Name__c, '', '','');    
                  } else {
                      signHereTabs += ', ' + cmpAPDocuSignHelper.getSignHereTabAnchorString('1', string.valueOf(recipientId).replaceall('.0',''),recipients.Inventor_Name__c, '', '', '');     
                  }
        
        signHereTabs += ']';
        signHereTabs += '}';
        apiBody=signHereTabs;
        
        string apiBodyLength = String.valueOf(apiBody.length());
        System.debug('apiBody' + apiBody);         
        DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
        HttpRequest req = new HttpRequest();
        string endpoint=objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes/' + envelopeid + '/recipients/'+ string.valueOf(recipientId).replaceall('.0','') + '/tabs';         
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
                       recipientId=recipientId+1;
                     }
                    
                  }
                    catch(Exception exp) {
                        
      				}
            
    	}
        
      }
   }
}
    
    global void finish(Database.BatchableContext bc){

    }    
}