@isTest
private class cmpAPDocuSignTokenCtrlTest {

    static testMethod void myTestMethod() {  
        
        DocuSign__c ds = new DocuSign__c(name='Default',
                                         UserName__c = 'amar.p@maxval.com',
                                         UserPassword__c='f$J6sQ*pa#zt@6.',
                                         EndPoint__c='https://demo.docusign.net/restapi/v2/accounts/',
                                         IntegratorKey__c='97fe8b93-7601-48d2-acf5-e62932febef2',
                                         TokenUrl__c ='https://account-d.docusign.com/oauth/token',
                                         Authorization__c='Basic OTdmZThiOTMtNzYwMS00OGQyLWFjZjUtZTYyOTMyZmViZWYyOjRhMzdlZWQ2LThiYTEtNDcwNi05MzAxLWJjMDZjNDgzYTFjMw==');
        insert ds;
        
        List<DocuSignSetting__c> tstCont = new List<DocuSignSetting__c>();
        DocuSignSetting__c Person = new DocuSignSetting__c();
        Person.access_token__c = '';
        Person.refresh_token__c ='';
        tstCont.add(Person);
		insert Person;
        
         test.starttest();
        	cmpAPDocuSignTokenCtrl.setHeader(Person.Id,'', '');
        	cmpAPDocuSignTokenCtrl.getToken();
        	cmpAPDocuSignTokenCtrl.getRefreshToken();
        	cmpAPDocuSignTokenCtrl.DocuSignTokenFuture();
         test.stopTest();
    }
}