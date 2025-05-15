global with sharing class cmpAPDocuSignHelper {
    
    public static string getHeader() {
        string strHeader='';
        List<DocuSignSetting__c> objCSworkday = [SELECT Id,access_token__c,refresh_token__c  FROM DocuSignSetting__c LIMIT 1];
         if (objCSworkday.size() > 0) {
             for(DocuSignSetting__c record : objCSworkday ) {
                 
                 System.debug('objCSworkday ' + objCSworkday);
        		 System.debug('objCSworkday[0].access_token__c ' + record.access_token__c);
        		 strHeader=record.access_token__c;
        		 System.debug('strHeader ' + strHeader);
                 
             }
         }
        
        return strHeader;
    }
    
    public static string CreatedToSent(string email,string recipientName, string recipientId ) {
            string Qstr = '';
            Qstr += '{'; 
    		Qstr += '"status": "sent",'; 
    		Qstr += '"recipients": '; 
    		Qstr += '{'; 
        	Qstr += '"signers":'; 
        	Qstr += '['; 
            Qstr += '{'; 
            Qstr += '"email":"' + email + '",';  
            Qstr += '"name":"' + recipientName + '",';  
            Qstr += '"recipientId":"' + recipientId + '"'; 
         	Qstr += '}'; 
        	Qstr += ']'; 
    		Qstr += '}'; 
			Qstr += '}'; 
        
        	return Qstr;
       }    
            
   
    public static string UseCaseID() {
        try
        {
            
            string Qstr = '';
            Qstr += ',"customFields" : {';
            Qstr += '"listCustomFields": [';
            Qstr += '{';
            Qstr += '"name":"UseCaseID"';
            Qstr += ',"value":"Patents_MaxVal_Salesforce"';
            Qstr += ',"show":"true"';
            Qstr += ',"required":"true"';
            Qstr += ',"listItems": ["Patents_MaxVal_Salesforce"]';
            Qstr += '}';
            Qstr += ']';
            Qstr += '}';
            
            return Qstr;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string resendrequest(string recipientId, string name, string email) {
        try
        {
            
            string Qstr = '';
            Qstr += '{';
            Qstr += '"signers": [';
            Qstr += '{';
            Qstr += '"recipientId":"'+recipientId+'",';
            Qstr += '"name":"'+name+'",';
            Qstr += '"email":"'+email+'"';
            Qstr += '}';
            Qstr += ']';
            Qstr += '}';
            
            return Qstr;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
   public static string getdocusignreminder() {
        try
        {
            DocuSignReminder__c objDocuSignReminder = [SELECT Id, Name, ExpireAfter__c,
                                                       ExpireWarn__c,ReminderDelay__c,ReminderFrequency__c 
                                                       FROM DocuSignReminder__c 
                                                       LIMIT 1];
            string Qstr = '';
            Qstr += '"useAccountDefaults": "false",';
            Qstr += '"reminders": {';
            Qstr += '"reminderEnabled":"true",';
            Qstr += '"reminderDelay":"' + objDocuSignReminder.ReminderDelay__c + '",';
            Qstr += '"reminderFrequency":"' + objDocuSignReminder.ReminderFrequency__c + '"';
            Qstr += '},';
            Qstr += '"expirations": {';
            Qstr += '"expireEnabled":"true",';
            Qstr += '"expireAfter":"' + objDocuSignReminder.ExpireAfter__c + '",';
            Qstr += '"expireWarn":"' + objDocuSignReminder.ExpireWarn__c + '"';
            Qstr += '}';
            
            return Qstr;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
   
    public static string getDocument(string DocumentName, string DocumentId, string DocumentOrder) {
        try
        {
            DocuSign_Document__c objDocuSignDocument = null;
            ContentDocumentLink objContentDocumentLink = null;
            ContentVersion objContentVersion = null;
            
            List<DocuSign_Document__c> objDocuSignDocuments = [SELECT Id, Name FROM DocuSign_Document__c WHERE Name=:DocumentName ORDER BY CreatedDate DESC];
            if (objDocuSignDocuments != null && objDocuSignDocuments.size()>0)
                objDocuSignDocument = objDocuSignDocuments[0];
            if (objDocuSignDocument != null) {
                List<ContentDocumentLink> objContentDocumentLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:objDocuSignDocument.Id ];    
                if (objContentDocumentLinks != null && objContentDocumentLinks.size()>0)
                    objContentDocumentLink = objContentDocumentLinks[0];
            }
            
            if (objContentDocumentLink != null) {
                List<ContentVersion> objContentVersions = [SELECT Id, Title,VersionData, FileType FROM ContentVersion WHERE ContentDocumentId =:objContentDocumentLink.ContentDocumentId ORDER BY CreatedDate DESC];    
                if (objContentVersions != null && objContentVersions.size()>0) 
                    objContentVersion = objContentVersions[0];
            }
            string strDocument = '';
            
            strDocument += '{';
            strDocument += '"documentBase64":"' + EncodingUtil.base64Encode(objContentVersion.VersionData)+ '"';
            strDocument += ', "documentId":"' + DocumentId + '"';
            strDocument += ', "fileExtension":"' + objContentVersion.FileType + '"';
            strDocument += ', "name":"' + DocumentName + '"';
            strDocument += ', "order":"' + DocumentOrder + '"';
            strDocument += '}';
          
            return strDocument;
        }
        catch(Exception exp) {
            return '';//+exp.getMessage()
        }
    }
    
    
    public static string getSupplimentalDocument(string ContentVersionId, string DocumentId, string DocumentOrder) {
        try
        {
            ContentVersion objContentVersion = [SELECT Id, ContentDocumentId, Title, VersionData, FileExtension FROM ContentVersion WHERE Id = :ContentVersionId LIMIT 1];    
            string strDocument = '';
            strDocument += '{';
            strDocument += '"documentBase64":"' + EncodingUtil.base64Encode(objContentVersion.VersionData)+ '"';
            strDocument += ', "documentId":"' + DocumentId + '"';
            strDocument += ', "fileExtension":"' + objContentVersion.FileExtension + '"';
            strDocument += ', "name":"' + objContentVersion.Title+ '"';
            strDocument += ', "order":"' + DocumentOrder + '"';
            strDocument += '}';
           
            return strDocument;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    @AuraEnabled
    public static string ReplaceWards(string Wards) {
        
        if (Wards==null | Wards =='')
           return Wards; 
        
       	String strText = Wards;
		strText = strText.replaceAll('""', '');
        return strText; 
    }
    
    public static string getTextTabValues(string PatentID,string ObjectName, string textTabsField) {
        try
        {
            string strDocument='-';
            String query='';
            query = 'SELECT Id,' +  textTabsField + ' FROM '+ObjectName+' WHERE Id =\'' + PatentID + '\' ';     
            List<sObject> records = Database.query(query);
            System.debug('records' + records);
            System.debug('query' + query);
            if(records.size() >0 ) {
                for(sObject objgroups : records ) {
                    strDocument = String.valueof(objgroups.get(textTabsField));
                    strDocument = strDocument.replace('"','');
                }
            }
            
            System.debug('strDocument' + strDocument);
            if(strDocument==null)
                strDocument='-';
            
            return ReplaceWards(strDocument);
        }
        catch(Exception exp)
        {
            return '-';
        }
        
    }
    
   
    public static string getSupplimentalDocuments(string PatentID, string DocumentId, string DocumentOrder) {
        try
        {
            ContentVersion objContentVersion = null;
            
            Map<Id,Id> mapIds = new Map<Id,Id>();
            List<ContentDocumentLink> objContentDocumentLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:PatentID  ];    
            if (objContentDocumentLinks != null && objContentDocumentLinks.size()>0)
            {
                for(ContentDocumentLink objContentDocumentLink : objContentDocumentLinks)
                {
                    if (mapIds.containsKey(objContentDocumentLink.ContentDocumentId)==false)
                        mapIds.put(objContentDocumentLink.ContentDocumentId,objContentDocumentLink.ContentDocumentId ); 
                }
            }
            
            List<Id> lstIds = mapIds.values();
            if (lstIds != null && lstIds.size()>0 )
            {
                List<ContentVersion> objContentVersions = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :lstIds  AND Title LIKE '%_Filing%' ORDER BY CreatedDate DESC];    
                if (objContentVersions != null && objContentVersions.size()>0) 
                    objContentVersion = objContentVersions[0];
            }
            string strDocument = '';
            
            strDocument += '{';
            strDocument += '"documentBase64":"' + EncodingUtil.base64Encode(objContentVersion.VersionData)+ '"';
            strDocument += ', "documentId":"' + DocumentId + '"';
            strDocument += ', "fileExtension":"' + objContentVersion.FileExtension + '"';
            strDocument += ', "name":"' + objContentVersion.Title+ '"';
            strDocument += ', "order":"' + DocumentOrder + '"';
            strDocument += '}';
            
            return strDocument;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
   
    public static string addRecipients(string SignerEmailId, string SignerName, string recipientId) {
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"email":"' + SignerEmailId + '"';
            strSigner += ', "name":"' + SignerName + '"';
            strSigner += ', "recipientId":"' + recipientId+ '"';
            strSigner += ', "routingOrder":"' + recipientId+ '"';
            strSigner += ', "requireIdLookup":"true"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getSigner(string SignerEmailId, string SignerName, string RecipientOrder, string RoutingOrder, string Tabs) {
        try
        {
            DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
            
            string strSigner = '';
            if(SignerName!='' && SignerName!=null)
                SignerName = SignerName.replaceAll('"','');
            
            strSigner += '{';
            strSigner += '"email":"' + SignerEmailId + '"';
            strSigner += ', "name":"' + SignerName + '"';
            strSigner += ', "recipientId":"' + RecipientOrder + '"';
            strSigner += ', "routingOrder":"' + RoutingOrder+ '"';
            strSigner += ', "signInEachLocation":"' + objCSDocuSign.signInEachLocation__c +' "';
            strSigner += ', "tabs":{';
            strSigner += Tabs;
            strSigner += '}';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getCC(string ccEmailId, string ccName, string RecipientOrder, string RoutingOrder) {
        try
        {
            string strCC = '';
            
            strCC += '{';
            strCC += '"email":"' + ccEmailId + '"';
            strCC += ', "name":"' + ccName + '"';
            strCC += ', "recipientId":"' + RecipientOrder + '"';
            strCC += ', "routingOrder":"' + RoutingOrder+ '"';
            strCC += '}';
            
            return strCC;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getNotesTab(string DocumentId, string anchorString, string Value, integer XPosition, integer YPosition){
        try
        {
            string strSigner = '';
            if(Value!='' && Value!=null)
                Value = Value.replace('"','');
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "font":"Arial"';
            strSigner += ', "fontColor":"Black"';
            strSigner += ', "fontSize":"Size10"';
            strSigner += ', "value":"' + Value + '"';
            strSigner += ', "anchorString":"' + anchorString + '"';
            strSigner += ', "anchorXOffset":"'+XPosition+'"';
            strSigner += ', "anchorYOffset":"'+YPosition+'"';
            strSigner += ', "anchorIgnoreIfNotPresent":"true"';
            strSigner += ', "width":1';
            strSigner += ', "height":2';
            strSigner += ', "anchorUnits":"mms"';
            strSigner += ', "locked":"true"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getTextTab(string DocumentId, string PageNumber, string Value, integer XPosition, integer YPosition){
        try
        {
            string strSigner = '';
            if(Value!='' && Value!=null)
                Value = Value.replace('"','');
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "font":"Arial"';
            strSigner += ', "fontColor":"Black"';
            strSigner += ', "fontSize":"Size10"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "value":"' + Value + '"';
            strSigner += ', "xPosition":"' + XPosition + '"';
            strSigner += ', "yPosition":"' + YPosition + '"';
            strSigner += ', "disableAutoSize":"false"';
            strSigner += ', "height":"110"';
            strSigner += ', "width":"650"';
            strSigner += ', "locked":"true"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
     public static string getTextTabAnchorString(string DocumentId, string vrecipientId, string anchorString, string Value, integer XPosition, integer YPosition){
        try
        {
            string strSigner = '';
            if(Value!='' && Value!=null)
                Value = Value.replace('"','');
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "font":"Arial"';
            strSigner += ', "fontColor":"Black"';
            strSigner += ', "fontSize":"Size10"';
            if (Value.length()>=90){
            strSigner += ', "width":"500"';
            strSigner += ', "height":"40"';
            strSigner += ', "disableAutoSize":"false"';
            }
            strSigner += ', "locked":"true"';
            strSigner += ', "value":"' + Value + '"';
            strSigner += ', "anchorString":"' + anchorString + '"';
            strSigner += ', "anchorXOffset":"0"';
            strSigner += ', "anchorYOffset":"-2"';
            strSigner += ', "anchorIgnoreIfNotPresent":"true"';
            strSigner += ', "recipientId":"'+vrecipientId+'"';
            strSigner += ', "anchorUnits":"mms"';
            
            
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getSignHereTabAnchorString(string DocumentId, string vrecipientId, string anchorString, string PageNumber, string XPosition, string YPosition) {
       
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"anchorString":"' + anchorString + '"';
            strSigner += ', "documentId":"' + DocumentId + '"';
            strSigner += ', "anchorXOffset":"0"';
            strSigner += ', "anchorYOffset":"-2"';
            strSigner += ', "anchorIgnoreIfNotPresent":"true"';
            strSigner += ', "anchorUnits":"mms"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "recipientId":"'+vrecipientId+'"';
            strSigner += ', "locked":"true"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getSignatureHereTabAnchorString(string DocumentId,string anchorString, string PageNumber, string XPosition, string YPosition) {
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "anchorString":"' + anchorString + '"';
            strSigner += ', "anchorIgnoreIfNotPresent":"true"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "anchorUnits":"mms"';
            strSigner += ', "anchorXOffset":"0"';
            strSigner += ', "anchorYOffset":"-2"';
            strSigner += ', "locked":"true"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getSignHereTab(string DocumentId, string PageNumber, integer XPosition, integer YPosition) {
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "anchorIgnoreIfNotPresent":"true"';
            strSigner += ', "xPosition":"' + XPosition + '"';
            strSigner += ', "yPosition":"' + YPosition + '"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getCheckboxTab(string DocumentId, string PageNumber, string TabLabel, integer XPosition, integer YPosition) {
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "tabLabel":"' + TabLabel + '"';
            strSigner += ', "xPosition":"' + XPosition + '"';
            strSigner += ', "yPosition":"' + YPosition + '"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getCheckboxTab(string DocumentId, string PageNumber, string TabLabel, integer XPosition, integer YPosition, boolean IsSelected, boolean IsLocked) {
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "tabLabel":"' + TabLabel + '"';
            strSigner += ', "xPosition":"' + XPosition + '"';
            strSigner += ', "yPosition":"' + YPosition + '"';
            if (IsSelected)
                strSigner += ', "selected":"true"';    
            if (IsLocked)
                strSigner += ', "locked":"true"';    
            strSigner += '}';
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getDateSignedTabAnchorString(string DocumentId,string anchorString, string PageNumber, string XPosition, string YPosition) {
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "anchorString":"' + anchorString + '"';
            strSigner += ', "anchorIgnoreIfNotPresent":"true"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "anchorUnits":"mms"';
            strSigner += ', "anchorXOffset":"-2"';
            strSigner += ', "anchorYOffset":"0"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
    
    public static string getDateSignedTab(string DocumentId, string PageNumber, integer XPosition, integer YPosition) {
        try
        {
            string strSigner = '';
            
            strSigner += '{';
            strSigner += '"documentId":"' + DocumentId + '"';
            strSigner += ', "pageNumber":"' + PageNumber + '"';
            strSigner += ', "anchorIgnoreIfNotPresent":"true"';
            strSigner += ', "xPosition":"' + XPosition + '"';
            strSigner += ', "yPosition":"' + YPosition + '"';
            strSigner += '}';
            
            return strSigner;
        }
        catch(Exception exp)
        {
            return '';
        }
    }
  
}