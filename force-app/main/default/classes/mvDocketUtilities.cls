public with sharing class mvDocketUtilities {
    @AuraEnabled
    public static void reportInternal(String assetId, List<Id> docketEntries, String emailTemplate) {
        EmailTemplate tempID = [SELECT Id
                                     , Name
                                     , Body
                                     , HTMLValue 
                                  FROM EmailTemplate 
                                 WHERE DeveloperName = :emailtemplate];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String emailBody = tempID.HTMLValue;

        String[] ToAddresses = new String[] {};
        String[] CCAddresses = new String[] {};

        List<SymphonyLF__Matter_Engagement_Model__c> matterEngagementModels = [SELECT Id, SymphonyLF__Assign_to_User__r.SymphonyLF__Email__c, SymphonyLF__Type__c
                                                                      FROM SymphonyLF__Matter_Engagement_Model__c
                                                                     WHERE SymphonyLF__Patent__c =:assetId
                                                                       AND SymphonyLF__Assign_to_User__r.RecordType.Name = 'Internal'
                                                                       AND (SymphonyLF__Type__c IN ( 'Paralegal', 'Legal Assistant','Docketer')
                                                                          OR SymphonyLF__Type__c LIKE '%Attorney%')
                                                                       AND SymphonyLF__Assign_to_User__r.SymphonyLF__Email__c != null ];
        


        String[] ToEmails = new List<String>();
        String[] CCEmails = new List<String>();

        if(matterEngagementModels.size() > 0 ){

            for (SymphonyLF__Matter_Engagement_Model__c eachEngagementModel : matterEngagementModels) {
                System.debug('Email : ' + eachEngagementModel.SymphonyLF__Assign_to_User__r.SymphonyLF__Email__c);
                if (eachEngagementModel.SymphonyLF__Type__c == 'Working Attorney' || eachEngagementModel.SymphonyLF__Type__c == 'Legal Assistant')

                    ToEmails.add(eachEngagementModel.SymphonyLF__Assign_to_User__r.SymphonyLF__Email__c);
                else 
                    CCEmails.add(eachEngagementModel.SymphonyLF__Assign_to_User__r.SymphonyLF__Email__c);
            }
            
            List<String> FinalToAddresses = new list<String>();
            FinalToAddresses.addAll(ToEmails);

            List<String> FinalCCAddresses = new list<String>();
            FinalCCAddresses.addAll(CCEmails);
            System.debug('To Emails : ' + ToEmails);
            System.debug('CC Emails : ' + CCEmails);
            System.debug('To Addressess : ' + FinalToAddresses);
            System.debug('CC Addressess : ' + FinalCCAddresses);
            
            email.setToAddresses(FinalToAddresses);
            email.setCCAddresses(FinalCCAddresses);

            email.setHtmlBody(emailBody);
            String clientData = '<table class="blueTable">';

            SymphonyLF__Patent__c thisPatent = [SELECT Id
                                                     , SymphonyLF__Title__c
                                                     , SymphonyLF__Docket_Number__c
                                                     , SymphonyLF__Country__c
                                                     , SymphonyLF__Case_Type__c
                                                     , SymphonyLF__Client_Reference__c
                                                     , SymphonyLF__Client__r.Name
                                                     , SymphonyLF__Application_Date__c
                                                     , SymphonyLF__Filing_Number__c
                                                     , SymphonyLF__Patent_Status__c	
                                                     , SymphonyLF__Sub_Status__c
                                                     , Matter_Engagement_Model_Group__r.Attorney__c
                                                     , Matter_Engagement_Model_Group__r.Working_Attorneys__c
                                                     , Matter_Engagement_Model_Group__r.Paralegals__c
                                                  FROM SymphonyLF__Patent__c
                                                 WHERE Id = :assetId
                                               ];    
            
            email.setSubject('Docket Report Out - ' + thisPatent.SymphonyLF__Docket_Number__c);
            email.setHtmlBody(emailBody);
            if (thisPatent.SymphonyLF__Docket_Number__c!=null)
                clientData = clientData + '<tr><th scope="col">Docket Number</th><td><b><a href="https://mcc-ip-law--mccuat.sandbox.lightning.force.com/' + thisPatent.Id +'">' + thisPatent.SymphonyLF__Docket_Number__c + '</a></b></td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Docket Number</th><td></td></tr>';
            
            if (thisPatent.SymphonyLF__Client_Reference__c!=null)
                clientData = clientData + '<tr><th scope="col">Client Reference Number</th><td>' + thisPatent.SymphonyLF__Client_Reference__c + '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Client Reference Number</th><td></td></tr>';

            if (thisPatent.SymphonyLF__Client__r.Name!= null)    
                clientData = clientData + '<tr><th scope="col">Client</th><td>' + thisPatent.SymphonyLF__Client__r.Name + '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Client</th><td></td></tr>';
            
            if(thisPatent.SymphonyLF__Case_Type__c!=null)
                clientData = clientData + '<tr><th scope="col">Case Type</th><td>' +  thisPatent.SymphonyLF__Case_Type__c + '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Case Type</th><td></td></tr>';
            
            if(thisPatent.SymphonyLF__Title__c!=null)
                clientData = clientData + '<tr><th scope="col">Title</th><td>' + thisPatent.SymphonyLF__Title__c+ '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Title</th><td></td></tr>';

            if (thisPatent.SymphonyLF__Application_Date__c != null)
                clientData = clientData + '<tr><th scope="col">Filing Date</th><td>' + DateTime.newInstance(thisPatent.SymphonyLF__Application_Date__c, Time.newInstance(0,0,0,0)).format('MM-dd-yyyy') + '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Filing Date</th><td></td></tr>';

            if(thisPatent.SymphonyLF__Filing_Number__c!=null)
                clientData = clientData + '<tr><th scope="col">Application Number</th><td>' + thisPatent.SymphonyLF__Filing_Number__c+ '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Application Number</th><td></td></tr>';

            if(thisPatent.SymphonyLF__Patent_Status__c!=null)
                clientData = clientData + '<tr><th scope="col">Status</th><td>' + thisPatent.SymphonyLF__Patent_Status__c+ '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Status</th><td></td></tr>';
            
            if(thisPatent.SymphonyLF__Sub_Status__c!=null)
                clientData = clientData + '<tr><th scope="col">Sub-status</th><td>' + thisPatent.SymphonyLF__Sub_Status__c+ '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Sub-status</th><td></td></tr>';
            
            if(thisPatent.Matter_Engagement_Model_Group__r.Attorney__c != null)
                clientData = clientData + '<tr><th scope="col">Attorneys</th><td>' + thisPatent.Matter_Engagement_Model_Group__r.Attorney__c+ '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Attorneys</th><td></td></tr>';
            
            if(thisPatent.Matter_Engagement_Model_Group__r.Working_Attorneys__c!=null)
                clientData = clientData + '<tr><th scope="col">Working Attorneys</th><td>' + thisPatent.Matter_Engagement_Model_Group__r.Working_Attorneys__c + '</td></tr>';
            else 
                clientData = clientData + '<tr><th scope="col">Working Attorneys</th><td></td></tr>';

            if(thisPatent.Matter_Engagement_Model_Group__r.Paralegals__c !=null)
                clientData = clientData + '<tr><th scope="col">Paralegals</th><td>' + thisPatent.Matter_Engagement_Model_Group__r.Paralegals__c + '</td></tr>';            
            else 
                clientData = clientData + '<tr><th scope="col">Paralegals</th><td></td></tr>';

            clientData = clientData + '</table>';

            System.debug(emailBody);
            emailBody = emailBody.replace('<CLIENT_TABLE>',clientData);

            String docketActivityData = '<table class="blueTable"><thead><tr><th>Event Name</th><th>Comments</th><th>Due Date</th><th>Event Date</th><th>iManage Link</th></tr></thead><tbody>';
            SymphonyLF__Docketing_Activity__c [] activityData = [  SELECT Id
                                                                        , SymphonyLF__Due_Date__c
                                                                        , SymphonyLF__Comments__c
                                                                        , SymphonyLF__Event_Name__c
                                                                        , SymphonyLF__Event_Date__c
                                                                        ,  (SELECT id
                                                                                  , name__c
                                                                                  , iManageFileUrl__c
                                                                                  , content_type__c
                                                                                  , id__c    
                                                                               FROM iManage_Documents__r 
                                                                               Where DocketingActivityId__c !=null)
                                                                        FROM SymphonyLF__Docketing_Activity__c
                                                                        WHERE ID IN :docketEntries
                                                                    ];

            for (SymphonyLF__Docketing_Activity__c currentItem: activityData) {
                if(currentItem.SymphonyLF__Event_Name__c!=null)
                    docketActivityData = docketActivityData + '<tr><td style="width:25%"><a href="https://mcc-ip-law--mccuat.sandbox.lightning.force.com/' + currentItem.Id +'"><b>'  +  currentItem.SymphonyLF__Event_Name__c + '</b></a></td>';
                else 
                    docketActivityData = docketActivityData + '<tr><td style="width:25%"></td>';
                
                if(currentItem.SymphonyLF__Comments__c != null )
                    docketActivityData = docketActivityData + '<td style="width:35%">' + currentItem.SymphonyLF__Comments__c + '</td>';
                else 
                    docketActivityData = docketActivityData + '<td style="width:35%"></td>';
                
                if (currentItem.SymphonyLF__Due_Date__c !=null )
                    docketActivityData = docketActivityData + '<td style="width:10%">' + DateTime.newInstance(currentItem.SymphonyLF__Due_Date__c, Time.newInstance(0,0,0,0)).format('MM-dd-yyyy') + '</td>';
                else 
                    docketActivityData = docketActivityData + '<td style="width:10%"></td>';
                
                if (currentItem.SymphonyLF__Event_Date__c !=null )
                    docketActivityData = docketActivityData + '<td style="width:10%">' + DateTime.newInstance(currentItem.SymphonyLF__Event_Date__c, Time.newInstance(0,0,0,0)).format('MM-dd-yyyy') + '</td>';
                else 
                    docketActivityData = docketActivityData + '<td style="width:10%"></td>';

                docketActivityData = docketActivityData + '<td style="width:20%">';
                for (iManage_Documents__c eachDocument : currentItem.iManage_Documents__r) {
                    if (eachDocument.name__c !=null )
                        docketActivityData = docketActivityData + '<a href="' + eachDocument.iManageFileUrl__c + '">' + eachDocument.name__c + '</a><br>';
                    
                }
                docketActivityData = docketActivityData + '</td></tr>';


                
            }
            docketActivityData = docketActivityData + '</tbody></table>';
            emailBody = emailBody.replace('<DOCKET_ACTIVITIES>',docketActivityData);

            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

            efa.setFileName('Docket Report Out - ' + thisPatent.SymphonyLF__Docket_Number__c + '.html');
    
            efa.setBody(Blob.valueOf(emailBody));
    
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            system.debug(emailBody);
            email.setHtmlBody(emailBody);
            System.debug('email about to send :::: '+email);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });        
        }
 
    }
}