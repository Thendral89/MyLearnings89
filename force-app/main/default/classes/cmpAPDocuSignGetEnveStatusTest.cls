@isTest
public class cmpAPDocuSignGetEnveStatusTest {
    @isTest
      public static void testing() {
      
          
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standtss', Email='standardusers@testorgs.com',
        EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='newusers90099001@testorg.com');
        insert u1;
        
        DocuSign__c ds = new DocuSign__c(name='Default',
                                         UserName__c = 'amar.p@maxval.com',
                                         UserPassword__c='f$J6sQ*pa#zt@6.',
                                         EndPoint__c='https://demo.docusign.net/restapi/v2/accounts/',
                                         IntegratorKey__c='97fe8b93-7601-48d2-acf5-e62932febef2');
        insert ds;
        
        SymphonyLF__Person__c inv = new SymphonyLF__Person__c();
        inv.Name ='inventors';
        inv.SymphonyLF__Email__c='test@gmail.com.com';
        inv.SymphonyLF__User__c =u1.Id;
        inv.SymphonyLF__Type__c='Client';
        inv.SymphonyLF__Contact_Type__c='Author';
        insert inv ;
        
        SymphonyLF__Person__c inv1 = new SymphonyLF__Person__c();
        inv1 = inv.clone();
        insert inv1;
        

        SymphonyLF__Country__c Country = new SymphonyLF__Country__c();
        Country.SymphonyLF__Active__c=true;
        Country.SymphonyLF__Country_Code__c='IN';
        Country.Name='India';
		insert Country;        
            
        SymphonyLF__Client__c Client = new SymphonyLF__Client__c();
        Client.SymphonyLF__Active__c=true;
        Client.Name='India';
        Client.SymphonyLF__Entity_Size__c='Small';
        Client.SymphonyLF__Client_Number_New__c='000001';
		insert Client;    
        
        
            
        SymphonyLF__Patent__c pat = new SymphonyLF__Patent__c();
        pat.SymphonyLF__First_Named_Inventor__c =inv.Id;
        pat.SymphonyLF__Internal_Counsel__c = u1.id;
        pat.SymphonyLF__Patent_Number__c = '123test';
        pat.SymphonyLF__Case_Type__c='Continuation';
        pat.SymphonyLF__Client__c=Client.Id;
        pat.SymphonyLF__Country__c=Country.Id;
        insert pat; 
        
      
        
        SymphonyLF__Patent_Attachments__c Attachments = new SymphonyLF__Patent_Attachments__c();
        Attachments.SymphonyLF__Version__c = 'Final';
        Attachments.SymphonyLF__Document_Type__c='Application Draft';
        Attachments.SymphonyLF__Patent__c = pat.id;
        insert Attachments;
          
          
        EnvelopeInfo__c env =new EnvelopeInfo__c(Status__c='Initiated-completed',
                                                 recordId__c=pat.id,
                                                EnvelopeId__c='93bbbb89-827c-431d-92c1-d7c87ec8fd7b' );
        insert env;
          
          List<EnvelopeInfo__c> tstCont = new List<EnvelopeInfo__c>();
        for(integer i = 0; i < 25; i++) {
            EnvelopeInfo__c c = new EnvelopeInfo__c(recordId__c = pat.Id,Status__c='Initiated-completed');
            tstCont.add(c);
        }
        insert tstCont;
        
         Test.startTest();
     	 Database.executeBatch( new cmpAPDocuSignGetEnveStatus (pat.id));   
         Database.executeBatch( new cmpAPDocuSignGetEnveStatus ());   
         cmpAPDocuSignGetEnveStatus batget=new cmpAPDocuSignGetEnveStatus();
         batget.execute(null, tstCont);
          
         Database.executeBatch( new cmpAPDocuSignGetEnveStatus (env.id,''));  
         Database.executeBatch( new cmpAPDocuSignGetEnveStatus (pat.id,'','93bbbb89-827c-431d-92c1-d7c87ec8fd7b')); 
          
     	Test.stopTest();

      }
}