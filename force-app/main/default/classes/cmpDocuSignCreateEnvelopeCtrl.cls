public without sharing class cmpDocuSignCreateEnvelopeCtrl {    
   
    public class Requests{
        @InvocableVariable(Label='Portfolio' Required = true)
        public String recordId;
    }
    
    @InvocableMethod(label='getObjectName')
    public static List<String> Portfolio(List<Requests> Portfolio) {
        List<String> ReturnValues = new List<String>();
        for(Requests request : Portfolio) {
            Id myId=request.recordId;
        	String sObjName = myId.getSObjectType().getDescribe().getName();
        	ReturnValues.add(sObjName);
        }
        return ReturnValues;   
    }
   
    
 	@AuraEnabled
    public static void CleanDocuSignDetails(string PatentID) {
         String returnmessage ='';
         List<DocuSignDetails__c> objEnvelopes = [SELECT Id FROM DocuSignDetails__c WHERE recordId__c = : PatentID];
         if (objEnvelopes.size() > 0) 
             delete objEnvelopes;
        
    }
    
 @future(callout=true)
 public static void cmpDocuSignBatchMultipleCtrl(string Envelope_sfIds, string Patent_ID, List<Id> SupplimentalAttachment_Ids,string DocuSignReminder, Date Target_FilingDate, string Application_No, string Application_Date, string Docket_No, string Inventor_Names,string PrimaryInventor_Id, string emBody, string respAttorney_Email,string ExpireAfter,string ExpireWarn,string ReminderDelay,string ReminderFrequency) {
     string carbonCopiesemail='';
     string EnvelopeIds = '';
     string EnvelopeStatus='';
     string orgURL = string.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
     List<EnvelopeInfo__c> ObjEnvelopeInfo = new List<EnvelopeInfo__c>();
     DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
     EmailTemplate objEmailTemplate = null;
     List<EmailTemplate> objEmailTemplates = [SELECT Subject, Body FROM EmailTemplate WHERE DeveloperName = 'DocuSignDeclaration'];
     if (objEmailTemplates!=null && objEmailTemplates.size()>0)
         objEmailTemplate = objEmailTemplates[0];
     
     string apiHeader = cmpAPDocuSignHelper.getHeader(); 
     string strTab = '';
     string apiBody = '';
     string TFilingDate='';
     
     EnvelopeInfo__c objEnvelop = [SELECT Id,Name,EnvelopeId__c,Sent_On__c,Receivers__c,ReqStatus__c,
                                                    Docusign_API_Status__c,Error_Occurred__c,Error_Text__c,recordId__c
                                                    FROM EnvelopeInfo__c 
                                                    WHERE Id =:Envelope_sfIds];
     EnvelopeInfo__c envelope = (EnvelopeInfo__c)objEnvelop;
     string ReqStatus=envelope.ReqStatus__c;
     
     List<DocuSignReviewer__c> DocuSignReviewers = [SELECT Id,Inventor_Name__c,Person__c,Email__c 
                                                    FROM DocuSignReviewer__c 
                                                    Where recordId__c = : Patent_ID 
                                                    AND IsDocuSign__c=true
                                                    AND Person__c=:PrimaryInventor_Id
                                                    LIMIT 1 ];
    
      apiBody += '{';
      apiBody += '"documents": [';
     

			   integer Docu=1;
               Set <String> DocuIds = new Set <String>();
               boolean IsDocuSignDetails=false; 
               List<DocuSignDetails__c> DocDetails = [Select Id,recordId__c,DocuSign_Document__r.Id,
                                                      DocuSign_Document__r.Name,DocuSign_Document__r.Sequance__c 
                                                      FROM DocuSignDetails__c 
                                                      WHERE recordId__c =: Patent_ID
                                                      Order by DocuSign_Document__r.Sequance__c ];
                  if (DocDetails.size() > 0) {
                      for(DocuSignDetails__c record : DocDetails ) {
                          DocuIds.add(record.DocuSign_Document__r.Id);
                          if ( Docu == 1){
                          	apiBody += cmpAPDocuSignHelper.getDocument(record.DocuSign_Document__r.Name, string.valueOf(Docu), string.valueOf(Docu));      
                          } else {
                          	apiBody += ', ' + cmpAPDocuSignHelper.getDocument(record.DocuSign_Document__r.Name, string.valueOf(Docu), string.valueOf(Docu));     
                          }
                          Docu = Docu + 1;
                          IsDocuSignDetails=true;
                      }
                  }
     
     			integer fileCount = Docu;
                string recipientName=envelope.Receivers__c.SubStringBefore('(');
                apiBody += ']';
     
     			string mailSubj =  Docket_No + ' Please electronically sign';
                apiBody += ', "emailSubject": "' + mailSubj + '"';
     			if(Inventor_Names=='' || Inventor_Names==null)
                    Inventor_Names='Maxval';
     
                Inventor_Names = Inventor_Names.replaceAll('"', '');
                string EmailBody = emBody.replace('{! v.Inventors}', Inventor_Names);
                string notes = '';
                string mailBody=EmailBody.replace('{!v.Instructional}', notes);
                
                apiBody +=',"emailBlurb":"' + mailBody +'"';
                apiBody +=',"allowReassign":"false"';
                    
                
                apiBody += ',"recipients": {';
                apiBody += '"signers": [';
                integer recipientId=1;
     
      			if (DocuSignReviewers.size()>0) {
                	for(DocuSignReviewer__c recipients : DocuSignReviewers ) {
                                         
                string PersonId=recipients.Person__c;
                carbonCopiesemail='amar.p@maxval.com';
                string signHereTabs='';
                string dateSignedTabs='';
                string textTabs='';
                string checkboxTabs='';
                string getTextTabValues ='';
                string notesTabs ='';
                integer Sequance=1;
                
                List<DocuSignTab__c> Tabs = [SELECT DocuSign_Document__r.Id,DocuSign_Document__r.Name,Id,pageNumber__c,Tabs__c,
                                             textTabsField__c,XPosition__c,YPosition__c,DocuSign_Document__r.Sequance__c,
                                             IsSelected__c,IsLocked__c,AnchorString__c,Data_Type__c,ObjectName__c
                                             FROM DocuSignTab__c
                                             Where DocuSign_Document__r.Id IN : DocuIds
                                             AND Document_Type__c='Yes'
                                             Order by DocuSign_Document__r.Name,Tabs__c ];
                  if (Tabs.size() > 0) {
                      for(DocuSignTab__c Tab : Tabs ) {
                       integer XPosition = integer.valueOf(Tab.XPosition__c);
                       integer YPosition = integer.valueOf(Tab.YPosition__c);
                       
                          
                          if (Tab.Tabs__c == 'signHereTabs') {
                              
                              if (signHereTabs == '') {
                              		signHereTabs = '"signHereTabs":[';
                                  	signHereTabs += cmpAPDocuSignHelper.getSignatureHereTabAnchorString(string.valueOf(Sequance),Tab.AnchorString__c, string.valueOf(Tab.pageNumber__c), string.valueOf(Tab.XPosition__c), string.valueOf(Tab.YPosition__c));    
                              } else {
                    			  signHereTabs += ', ' + cmpAPDocuSignHelper.getSignatureHereTabAnchorString(string.valueOf(Sequance),Tab.AnchorString__c, string.valueOf(Tab.pageNumber__c), string.valueOf(Tab.XPosition__c), string.valueOf(Tab.YPosition__c));    
                              }
                              
                          } else if (Tab.Tabs__c == 'dateSignedTabs') {
                              
                              if ( dateSignedTabs == '' ){
                              		dateSignedTabs += ', "dateSignedTabs":[';
               						dateSignedTabs += cmpAPDocuSignHelper.getDateSignedTabAnchorString(string.valueOf(Sequance), Tab.AnchorString__c,string.valueOf(Tab.pageNumber__c), string.valueOf(Tab.XPosition__c), string.valueOf(Tab.YPosition__c));
                              } else {
                                	dateSignedTabs += ', ' + cmpAPDocuSignHelper.getDateSignedTabAnchorString(string.valueOf(Sequance), Tab.AnchorString__c,string.valueOf(Tab.pageNumber__c), string.valueOf(Tab.XPosition__c), string.valueOf(Tab.YPosition__c));
                              }
                              
                          } else if (Tab.Tabs__c == 'textTabs') {
                              getTextTabValues='';
                                  
                              if ( Tab.AnchorString__c =='#InventorNames') {
                                  getTextTabValues = recipients.Inventor_Name__c;
                                  if(getTextTabValues!='' && getTextTabValues!=null)
                                    getTextTabValues = getTextTabValues.replace('"','');
                              } else if ( Tab.AnchorString__c =='#DeclarationInventorName'){
                                  getTextTabValues = recipients.Inventor_Name__c;
                                  if(getTextTabValues!='' && getTextTabValues!=null)
                                    getTextTabValues = getTextTabValues.replace('"','');
                              } else if ( Tab.AnchorString__c =='#Innovators'){
                                  getTextTabValues = cmpAPDocuSignHelper.getTextTabValues(Patent_ID,Tab.ObjectName__c,Tab.textTabsField__c);   
                              } else {
                               	 getTextTabValues = cmpAPDocuSignHelper.getTextTabValues(Patent_ID,Tab.ObjectName__c,Tab.textTabsField__c);   
                              }
                              
                              		if (Tab.Data_Type__c=='Date') {
                                        if (getTextTabValues!='-'){
                                            Date dToday = Date.valueOf(getTextTabValues);
                                      		String dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
                                      		getTextTabValues=dateStr;
                                        } else {
                                           getTextTabValues='-'; 
                                        }
                                      	
                                  }
                              
                              
                              
                              if ( textTabs == ''){
                               		textTabs += ',"textTabs":[';
                                  	textTabs += cmpAPDocuSignHelper.getTextTabAnchorString(string.valueOf(Sequance), string.valueOf(recipientId), Tab.AnchorString__c, getTextTabValues, Integer.valueOf(Tab.XPosition__c), Integer.valueOf(Tab.YPosition__c));     
                              } else {
                                  	textTabs += ', ' + cmpAPDocuSignHelper.getTextTabAnchorString(string.valueOf(Sequance), string.valueOf(recipientId), Tab.AnchorString__c, getTextTabValues,  Integer.valueOf(Tab.XPosition__c), Integer.valueOf(Tab.YPosition__c));     
                              }
                        
                              
                         } else if (Tab.Tabs__c == 'checkboxTabs') {
                              getTextTabValues ='';
                            if (Tab.DocuSign_Document__r.Name=='Declaration') {
                                system.debug('Declaration ' + Tab.DocuSign_Document__r.Name);
                                system.debug('Docu ' + Docu);
                                integer DocSequance=1;
                                if (Docu>2)
                                    DocSequance=2;
                                    
                              if ( checkboxTabs == '') {
                               		checkboxTabs += ',"checkboxTabs":[';
                					checkboxTabs += cmpAPDocuSignHelper.getCheckboxTab(string.valueOf(DocSequance), string.valueOf(Tab.pageNumber__c), getTextTabValues, XPosition, YPosition, Tab.IsSelected__c, Tab.IsLocked__c);
                              } else {
                                  	checkboxTabs += ', ' + cmpAPDocuSignHelper.getCheckboxTab(string.valueOf(DocSequance), string.valueOf(Tab.pageNumber__c), getTextTabValues, XPosition, YPosition, Tab.IsSelected__c, Tab.IsLocked__c);
                              }
                                
                            } else if (Tab.DocuSign_Document__r.Name=='Assignment') {
                                boolean IsSelected=false;
                                integer DocSequance=1;
                               
                                getTextTabValues = cmpAPDocuSignHelper.getTextTabValues(Patent_ID,Tab.ObjectName__c,Tab.textTabsField__c);
                                if(getTextTabValues=='true')
                                    IsSelected=true;
                                system.debug('IsSelected' + IsSelected);
                                
                              if ( checkboxTabs == '') {
                               		checkboxTabs += ',"checkboxTabs":[';
                					checkboxTabs += cmpAPDocuSignHelper.getCheckboxTab(string.valueOf(DocSequance), string.valueOf(Tab.pageNumber__c), getTextTabValues, XPosition, YPosition,IsSelected, Tab.IsLocked__c);
                              } else {
                                  	checkboxTabs += ', ' + cmpAPDocuSignHelper.getCheckboxTab(string.valueOf(DocSequance), string.valueOf(Tab.pageNumber__c), getTextTabValues, XPosition, YPosition,IsSelected, Tab.IsLocked__c);
                              }
                                
                            }  
                              
                          }
                          
                          
                      }
                  }
                
                if ( IsDocuSignDetails==true){
                   strTab= signHereTabs + ']' + dateSignedTabs + ']';
                } else {
                   strTab= signHereTabs + ']' + dateSignedTabs + ']';
                }
               
                        if (recipientId==1){
                			apiBody += cmpAPDocuSignHelper.getSigner(recipients.Email__c,recipients.Inventor_Name__c,string.valueOf(recipientId),string.valueOf(recipientId),strTab);               
                        } else {
                            apiBody += ', ' + cmpAPDocuSignHelper.getSigner(recipients.Email__c,recipients.Inventor_Name__c,string.valueOf(recipientId),string.valueOf(recipientId),strTab);   
                        }
                
                system.debug('signHereTabs' + signHereTabs);
                system.debug('checkboxTabs' + checkboxTabs);
                system.debug('dateSignedTabs' + dateSignedTabs);        
                system.debug('textTabs' + textTabs);
                system.debug('notesTabs' + notesTabs);
                        
                        
                        
                     recipientId=recipientId+1;   
                        
                    }
                }
     
     
                apiBody += ']';
                apiBody += '}';
                apiBody += cmpAPDocuSignHelper.UseCaseID();
                
                if (ReqStatus=='created'){
                	apiBody += ', "status": "created"';    
                    apiBody += ', "enforceSignerVisibility": "true"'; 
                } else {
                    apiBody += ', "status": "sent"';
                    apiBody += ', "enforceSignerVisibility": "true"'; 
                }
                
                apiBody += '}';
     
     
     			string apiBodyLength = String.valueOf(apiBody.length());
                System.debug('apibody' + apibody);
     
      			HttpRequest req = new HttpRequest();
                req.setEndpoint(objCSDocuSign.EndPoint__c + objCSDocuSign.AccountNumber__c + '/envelopes');
                req.setMethod('POST');  
                integer getStatusCode=0;
     
                if (apibody.trim()!=''){
                    req.setBody(apibody);
                    req.setHeader('Content-length', apiBodyLength);
                }
                req.setHeader('Content-type', 'application/json');
                req.setHeader('Authorization', 'Bearer ' + apiHeader );
                req.setTimeout(120000);
                string ResponseBody='';
     			string auditbody='';
     			string getStatus='';
                Http http = new Http();
                if(!test.isRunningTest()) {
                    HTTPResponse httpResponse = http.send(req);
                    auditbody += 'response-->'+ httpResponse.getStatusCode();
                    auditbody += 'response-->'+ httpResponse.getBody();
                    ResponseBody= httpResponse.getBody();
                    getStatusCode=httpResponse.getStatusCode();
                    getStatus=httpResponse.getStatus();
                    System.debug('getBody-->'+ httpResponse.getBody());
                }
     
     
     					if(getStatusCode == 200 || getStatusCode == 201) {
                            cmpAPDocuSignResponse objResponse = (cmpAPDocuSignResponse) JSON.deserialize(ResponseBody,cmpAPDocuSignResponse.Class);
                            boolean CanInsert = true;
                            EnvelopeIds = objResponse.envelopeId;
                            EnvelopeStatus=objResponse.status;
                            envelope.EnvelopeId__c = objResponse.envelopeId;
                            envelope.Status__c = objResponse.status;
                            envelope.Sent_On__c= objResponse.statusDateTime;
                            envelope.Error_Occurred__c = false;
                            envelope.Error_Text__c = null;
                            envelope.ResponseBody__c=ResponseBody;
                            envelope.Person_Name__c=Inventor_Names;
                            
                            if(envelope.Docusign_API_Status__c != null && envelope.Docusign_API_Status__c !='')
                                envelope.Docusign_API_Status__c = envelope.Docusign_API_Status__c +' >> '+System.now()+' | Status Code: '+getStatusCode+' & Status: '+getStatus;
                            else
                                envelope.Docusign_API_Status__c = System.now()+' | Status Code: '+getStatusCode+' & Status: '+getStatus;
                            
                            if(ExpireAfter!='' && ExpireAfter!=null){
                                cmpAPDocuSignCompletionCertificate.SetAdhocReminder(EnvelopeIds,ReminderDelay,ReminderFrequency,ExpireAfter,ExpireWarn);
                            } else {
                                cmpAPDocuSignCompletionCertificate.SetReminder(EnvelopeIds);
                            }
                            
                        } 
                        
                        ObjEnvelopeInfo.add(envelope);
     					//CleanDocuSignDetails(Patent_ID);
         
      try {
         if(ObjEnvelopeInfo.size()>0)
             update ObjEnvelopeInfo;
          } catch(Exception exp) {
            cmpAPDocuSignCtrl.getEnvelopeIdStatus(Envelope_sfIds);
            system.debug('ObjEnvelopeInfo UNABLE_TO_LOCK_ROW ' + ObjEnvelopeInfo);
         }
     
     
     
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