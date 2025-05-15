global class cmpAPDocuSignGetEnveStatus implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable, Database.Stateful  {
    Public List<string> completedRecords{set;get;}
    Public List<Id> EnvelopeId{set;get;}
    public string patentid{set;get;}
    public string query{set;get;}
    public string m_EnvelopeId{set;get;}
    
    //cmpAPDocuSignGetEnveStatus docuSign=new cmpAPDocuSignGetEnveStatus();
	//Database.executeBatch(docuSign,1);
	//System.schedule('cmpAPDocuSignGetEnveStatus', '0 0 1 * * ?', new cmpAPDocuSignGetEnveStatus());
    
    global cmpAPDocuSignGetEnveStatus() {
        completedRecords = new List<string>();
        EnvelopeId = new List<Id>();
        query = 'SELECT Id,EnvelopeId__c FROM EnvelopeInfo__c WHERE Status__c!=\'\' AND Status__c not in (\'completed\',\'Cancelled\') AND EnvelopeId__c!=null Order by createddate desc limit 100';
        system.debug('query' + query);
    }
    
    global cmpAPDocuSignGetEnveStatus(id patid) {
        completedRecords = new List<string>();
        EnvelopeId = new List<Id>();
        patentid = patid;
        system.debug('cmpAPDocuSignGetEnveStatus  fetch for :'+patid);
        query = 'SELECT Id,EnvelopeId__c FROM EnvelopeInfo__c WHERE recordId__c =:patentid AND Status__c not in (\'completed\',\'Cancelled\') AND EnvelopeId__c!=null  Order by createddate desc limit 100';
    }
    
    global cmpAPDocuSignGetEnveStatus(Id patid,string status) {
        completedRecords = new List<string>();
        EnvelopeId = new List<Id>();
        patentid = patid;
        system.debug('cmpAPDocuSignGetEnveStatus  fetch for :'+patid);
        query = 'SELECT Id,EnvelopeId__c FROM EnvelopeInfo__c WHERE Id =:patentid   Order by createddate desc limit 100';
    }
    
    global cmpAPDocuSignGetEnveStatus(id patid,string status,string menvelopeId) {
        completedRecords = new List<string>();
        EnvelopeId = new List<Id>();
        patentid = patid;
        m_EnvelopeId = menvelopeId;
        system.debug('cmpAPDocuSignGetEnveStatus  fetch for :'+patid);
        query = 'SELECT Id,EnvelopeId__c FROM EnvelopeInfo__c WHERE recordId__c =:patentid AND Status__c not in (\'completed\',\'Cancelled\') AND EnvelopeId__c=:m_EnvelopeId  Order by createddate desc limit 100';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('query :'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<EnvelopeInfo__c> records) {
        for(EnvelopeInfo__c evp : records) {
            string status = cmpAPDocuSignCtrl.getEnvelopeStatus(evp.EnvelopeId__c);
            system.debug('Status for '+evp.id+' :'+status);
            if(status == 'Initiated-completed') {
                EnvelopeId.add(evp.Id);
                completedRecords.add(evp.EnvelopeId__c);
            }
        }
        
    }
    
    global void execute(SchedulableContext ctx)  {
        Database.executeBatch(this);
    }
    
    global void finish(Database.BatchableContext bc) {
        
        if(EnvelopeId.size()>0) {
            cmpAPDocuSignSynced.DocuSignDocumentsSynced(EnvelopeId);
        }
    }    
}