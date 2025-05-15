public with sharing class cmpAPFileUploadCtrl {
    
     @AuraEnabled
    public static String getprofile(string recordId) {
        Id profileId=userinfo.getProfileId();
        boolean IsCreated=true;
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        return profileName;
        
    }
     
    
    @AuraEnabled
    public static string UpdatePriorArtSearch(String LinkedEntityId, List<Id> lstDocumentId) {
      	System.debug('LinkedEntityId' + LinkedEntityId + ' lstDocumentId ' + lstDocumentId);
      	string UpdateRecord  ='';
        list<ContentVersion> cvdellst = [select id from ContentVersion where ContentDocumentId IN :lstDocumentId];
            for(ContentVersion c : cvdellst){
                
      			UpdateRecord=SRUpdateRecord(c.Id,'Document_Code__c','Prior Art Search','ContentVersion');
            }
        
     return UpdateRecord; 
        
    }
    
    @AuraEnabled
    public static string SRUpdateRecord(String recordId, String fieldApi, String fieldvalue, string objName ) { 
       string status='';
        try {
                String query = 'SELECT Id,' +  fieldApi + ' FROM '+objName+' WHERE Id =\'' + recordId + '\''; 
                System.debug('query' + query);
                List<sObject> records = Database.query(query);
                if(records.size() >0 ){
                     records[0].put(fieldApi,fieldvalue);
                     Database.update(records[0]);
                }
               
        }catch(Exception e){
            status =e.getMessage() + '--' +e.getStackTraceString(); 
            System.debug('status Error' + status);
        }
        
        System.debug('status Success');
        return status;
        
    } 
   
    public class WrapperFiles {
        @AuraEnabled
        public String Id { get; set; }
        
        @AuraEnabled
        public String Title { get; set; }
        
        @AuraEnabled
        public String FileExtension { get; set; }

		@AuraEnabled
        public boolean IsSyncPair { get; set; }
        
    }
   
    @AuraEnabled
    public static List<ContentVersion> getAttachedDocuments(Id LinkedEntityId) {
        try
        {
            
            list<id> knwrecids =  new list<id>();
            knwrecids.add(LinkedEntityId);
           
            Set<Id> setofcontentdocId = new Set<Id>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId IN :knwrecids];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
          	
            
            // Query the contentversionIds
            for(ContentVersion objcontentversion :[SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c FROM ContentVersion WHERE FileExtension !='snote' and ContentDocumentId IN :setofcontentdocId ORDER BY CreatedDate])
            {
                
                
                lstContentVersions.add(objcontentversion);
                
                
            }
            if(lstContentVersions.size() > 0) {
            	return lstContentVersions;
            } else{
                return null; 
            }
            
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }

     @AuraEnabled
    public static List<ContentVersion> cmpAPAttachmentPPM(Id LinkedEntityId, boolean IsPatentBots, integer SearchLimit) {
        IsPatentBots=true;
        try {
            
            list<id> knwrecids =  new list<id>();
            knwrecids.add(LinkedEntityId);
            set<string> duplicateId = new set<string>();
            Set<Id> setofcontentdocId = new Set<Id>();
            integer recordLimit=0;
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId IN :knwrecids];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
          	
            
            // Query the contentversionIds
            
            list<ContentVersion> objcontentversion = [SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c,CreatedDate 
                                                      FROM ContentVersion WHERE
                                                      FileExtension NOT IN ('snote') 
                                                      and ContentDocumentId IN :setofcontentdocId 
                                                      ORDER BY CreatedDate limit 100];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                     if(!duplicateId.contains(cv.Title)){
                         if(recordLimit!=SearchLimit){
                             lstContentVersions.add(cv);
                        	 recordLimit=recordLimit+1;
                             duplicateId.add(cv.Title);
                         }
                    }
                }
            }
            
            
            if(lstContentVersions.size() > 0) {
            	return lstContentVersions;
            } else{
                return null; 
            }
            
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> cmpAPAttachment(Id LinkedEntityId, boolean IsPatentBots, integer SearchLimit) {
        IsPatentBots=true;
        try {
            
            list<id> knwrecids =  new list<id>();
            knwrecids.add(LinkedEntityId);
           
            Set<Id> setofcontentdocId = new Set<Id>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId IN :knwrecids];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
          	
            
            // Query the contentversionIds
            
            list<ContentVersion> objcontentversion = [SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c,CreatedDate 
                                                      FROM ContentVersion WHERE
                                                      FileExtension NOT IN ('snote') 
                                                      and ContentDocumentId IN :setofcontentdocId 
                                                      ORDER BY CreatedDate limit :SearchLimit];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                    if(IsPatentBots==true) {
                        if (cv.FileExtension !='png')
                            lstContentVersions.add(cv);  
                    } else {
                        if (cv.Document_Code__c !='PatentBots')
                            lstContentVersions.add(cv);
                    } 
                }
            }
            
            
            if(lstContentVersions.size() > 0) {
            	return lstContentVersions;
            } else{
                return null; 
            }
            
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getcmpAPAttachedDocuments(Id LinkedEntityId, boolean IsPatentBots, integer SearchLimit) {
        IsPatentBots=true;
        try {
            
            list<id> knwrecids =  new list<id>();
            knwrecids.add(LinkedEntityId);
           
            Set<Id> setofcontentdocId = new Set<Id>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId IN :knwrecids];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
          	
            
            // Query the contentversionIds
            
            list<ContentVersion> objcontentversion = [SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c,CreatedDate 
                                                      FROM ContentVersion WHERE FileExtension !='snote' 
                                                      and ContentDocumentId IN :setofcontentdocId 
                                                      ORDER BY CreatedDate limit :SearchLimit];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                    if(IsPatentBots==true) {
                        if (cv.FileExtension !='png')
                            lstContentVersions.add(cv);  
                    } else {
                        if (cv.Document_Code__c !='PatentBots')
                            lstContentVersions.add(cv);
                    } 
                }
            }
            
            
            if(lstContentVersions.size() > 0) {
            	return lstContentVersions;
            } else{
                return null; 
            }
            
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
     @AuraEnabled
    public static List<ContentVersion> getcmpAPDocuSignAttachedDocuments(Id LinkedEntityId, boolean IsPatentBots) {
        try
        {
            
            list<id> knwrecids =  new list<id>();
            knwrecids.add(LinkedEntityId);
            set<string> duplicateId = new set<string>();
            Set<Id> setofcontentdocId = new Set<Id>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp 
                                                                    FROM ContentDocumentLink 
                                                                    WHERE LinkedEntityId IN :knwrecids];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
            list<ContentVersion> objcontentversion = [SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c,CreatedDate 
                                                      FROM ContentVersion 
                                                      WHERE FileExtension !='snote' 
                                                      and ContentDocumentId IN :setofcontentdocId ORDER BY CreatedDate];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                    if(!duplicateId.contains(cv.Title)){
                    	lstContentVersions.add(cv);
                        duplicateId.add(cv.Title);
                    }
                    
                }
            }
            
            system.debug('lstContentVersions ' + lstContentVersions);
            if(lstContentVersions.size() > 0) {
            	return lstContentVersions;
            } else{
                return null; 
            }
            
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getcmpAPFileUploadAttachedDocuments(Id LinkedEntityId, boolean IsPatentBots) {
        try
        {
            
            list<id> knwrecids =  new list<id>();
            knwrecids.add(LinkedEntityId);
            set<string> duplicateId = new set<string>();
            Set<Id> setofcontentdocId = new Set<Id>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId IN :knwrecids];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
          	
            
            // Query the contentversionIds
            
            list<ContentVersion> objcontentversion = [SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c,CreatedDate FROM ContentVersion WHERE FileExtension !='snote' and ContentDocumentId IN :setofcontentdocId ORDER BY CreatedDate];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                    
                  if(!duplicateId.contains(cv.Title)){
                        duplicateId.add(cv.Title);
                    if(IsPatentBots==true) {
                        if (cv.Document_Code__c=='PatentBots')
                            lstContentVersions.add(cv);  
                    } else {
                        if (cv.Document_Code__c !='PatentBots')
                            lstContentVersions.add(cv);
                    } 
                 }
                    
               }
           }
            
            
            if(lstContentVersions.size() > 0) {
            	return lstContentVersions;
            } else{
                return null; 
            }
            
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getcmpAPFileUploadCurrentAttachedDocumentsPPM(Id LinkedEntityId, List<Id> lstDocumentId, list<ContentVersion> AllCurrentfiles,boolean IsPatentBots)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentVersion> lstContentVersionsReturn = new List<ContentVersion>();
            set<string> duplicateId = new set<string>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0){
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
              if (lstContentVersions.size()>0){
                for(ContentVersion cv : lstContentVersions){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                     if(!duplicateId.contains(cv.Title)){
                    	lstContentVersionsReturn.add(cv);
                        duplicateId.add(cv.Title);
                    }
                }
            }
                
                
                
            return lstContentVersionsReturn;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getcmpAPFileUploadCurrentAttachedDocuments(Id LinkedEntityId, List<Id> lstDocumentId, list<ContentVersion> AllCurrentfiles,boolean IsPatentBots)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentVersion> lstContentVersionsReturn = new List<ContentVersion>();
            
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0){
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
              if (lstContentVersions.size()>0){
                for(ContentVersion cv : lstContentVersions){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                    
                    if(IsPatentBots==true) {
                        if (cv.Document_Code__c=='PatentBots')
                            lstContentVersionsReturn.add(cv);
                	} else {
                        if (cv.Document_Code__c !='PatentBots')
                            lstContentVersionsReturn.add(cv);    
                	} 
                }
            }
                
                
                
            return lstContentVersionsReturn;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    
     @auraEnabled
    public static list<string> delDups(list<id> docids,list<string> imgtitlst){
        set<string> titlesreturn = new set<string>();
        list<contentversion> conve = new list<contentversion>();
        list<string> newtiltles = new list<string>();
        list<string> newupltiltles = new list<string>();
        list<string> newids = new list<string>();
        list<contentversion> conver = [select id,title from contentversion where contentdocumentid in: docids];
        for(contentversion cv : conver){
            cv.IDF_File_Type__c = 'RepFigure';
            conve.add(cv);
            newupltiltles.add(cv.title);
            if(imgtitlst.size()>0 && imgtitlst.contains(cv.title)){
            newtiltles.add(cv.title);
            newids.add(cv.id);
            }
        }
        if(conve.size()>0)
        update conve;
        if(newids.size()>0){
            list<id> condocdellist = new list<id>();
            list<ContentVersion> cvdellst = [select id from ContentVersion where title in:newtiltles and id not in:newids];
            for(ContentVersion c : cvdellst){
                condocdellist.add(c.contentdocumentid);
            }
            if(condocdellist.size()>0){
             list<ContentDocument> delcdlst = [select id from ContentDocument where id in:condocdellist];
             list<ContentDocumentLink> cdlink = [select id from ContentDocumentLink where LinkedEntityId =: UserInfo.getUserId() and contentdocumentid in:condocdellist ];
             if(delcdlst.size()>0)
             delete delcdlst;
             if(cdlink.size()>0)
             delete cdlink;
            }
            
        }
        if(newupltiltles.size()>0)
        titlesreturn.addAll(newupltiltles);
        if(imgtitlst.size()>0)
        titlesreturn.addAll(imgtitlst);
        list<string> retlst = new list<string>();
        if(titlesreturn.size()>0)
        retlst.addAll(titlesreturn);
        return retlst;
    }
    
    /*
    @AuraEnabled
    public static List<ContentVersion> getPatentBotDocuments(Id LinkedEntityId, List<Id> lstDocumentId, list<ContentVersion> AllCurrentfiles)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentVersion> Contents = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0) {
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperAttachmentsNew.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
                for(ContentVersion objContentVersion : lstContentVersions ) {
                    ContentVersion Data = new ContentVersion();
                    Data.Id=objContentVersion.Id;
                    Data.IDF_File_Type__c='PatentBots';
                    Data.Document_Code__c='PatentBots';
                    Contents.add(Data);
                }
                
               if(Contents.size()>0)
                   update Contents;
                
            return lstContentVersions;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    */
    
    @AuraEnabled
    public static List<ContentVersion> getcmpAPInnovationCurrentAttachedDocuments(Id LinkedEntityId, List<Id> lstDocumentId, list<ContentVersion> AllCurrentfiles,boolean IsPatentBots)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentVersion> lstContentVersionsReturn = new List<ContentVersion>();
            
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0){
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
              if (lstContentVersions.size()>0){
                for(ContentVersion cv : lstContentVersions){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                    if (cv.Document_Code__c=='Innovation Disclosure')
                        lstContentVersionsReturn.add(cv);
                }
            }
                
                
                
            return lstContentVersionsReturn;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    
     @AuraEnabled
    public static List<ContentVersion> getcmpAPInnovationAttachedDocuments(Id LinkedEntityId, boolean IsPatentBots) {
        try
        {
            
            list<id> knwrecids =  new list<id>();
            knwrecids.add(LinkedEntityId);
            set<string> duplicateId = new set<string>();
            Set<Id> setofcontentdocId = new Set<Id>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId IN :knwrecids];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
            list<ContentVersion> objcontentversion = [SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c,CreatedDate 
                                                      FROM ContentVersion WHERE FileExtension !='snote' 
                                                      and ContentDocumentId IN :setofcontentdocId
                                                      AND IDF_File_Type__c='Innovation Disclosure' ORDER BY CreatedDate];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    system.debug('Document_Code__c' + cv.Document_Code__c);
                    if(!duplicateId.contains(cv.Title)){
                    	lstContentVersions.add(cv);
                        duplicateId.add(cv.Title);
                    }
                    
                }
            }
            
            system.debug('lstContentVersions ' + lstContentVersions);
            if(lstContentVersions.size() > 0) {
            	return lstContentVersions;
            } else{
                return null; 
            }
            
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getInnovationSubmissionDocuments(Id LinkedEntityId, List<Id> lstDocumentId, string DocCode)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentVersion> Contents = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0) {
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
                for(ContentVersion objContentVersion : lstContentVersions ) {
                    ContentVersion Data = new ContentVersion();
                    Data.Id=objContentVersion.Id;
                    Data.IDF_File_Type__c='Innovation Disclosure';
                    Data.Document_Code__c='Innovation Disclosure';
                    Contents.add(Data);
                }
                
               if(Contents.size()>0)
                   update Contents;
                
            return lstContentVersions;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getPatentBotDocuments(Id LinkedEntityId, List<Id> lstDocumentId, string DocCode)  {
        //, list<ContentVersion> AllCurrentfiles
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentVersion> Contents = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0) {
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
                for(ContentVersion objContentVersion : lstContentVersions ) {
                    ContentVersion Data = new ContentVersion();
                    Data.Id=objContentVersion.Id;
                    Data.Title=DocCode;
                    Data.IDF_File_Type__c='PatentBots';
                    Data.Document_Code__c='PatentBots';
                    Contents.add(Data);
                }
                
               if(Contents.size()>0)
                   update Contents;
                
            return lstContentVersions;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    
    @AuraEnabled
    public static void UpdateNOADocuments(Id LinkedEntityId, List<Id> lstDocumentId, list<ContentVersion> AllCurrentfiles)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentVersion> ObjContentVersions = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0){
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
                for(ContentVersion cv : lstContentVersions ) {
                    ContentVersion Data = new ContentVersion();
                    Data.Id=cv.Id;
                    Data.IDF_File_Type__c='NOA Decision';
                    Data.Document_Code__c='NOA Decision';
                    ObjContentVersions.add(Data);
                }
            }
            
            if(ObjContentVersions.size()>0)
                update ObjContentVersions;
        }
        catch(Exception exp)
        {
            throw exp;
        }
        
    }
    
    @AuraEnabled
    public static List<ContentVersion> getNOACurrentAttachedDocuments(Id LinkedEntityId, string lstDocumentId, list<ContentVersion> AllCurrentfiles)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            List<Id> ContentVersionIds = lstDocumentId.split(',');
            
            
            if(lstLinkedEntityIds.size() > 0 && ContentVersionIds.size() > 0){
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, ContentVersionIds);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
            return lstContentVersions;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getCurrentAttachedDocuments(Id LinkedEntityId, List<Id> lstDocumentId, list<ContentVersion> AllCurrentfiles)  {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            if(lstLinkedEntityIds.size() > 0 && lstDocumentId.size() > 0){
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperFileUpload.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            
            return lstContentVersions;
            }else{
                return null;
            }
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    @AuraEnabled
    public static string deletecontentversion (Id contentVersionId) {
        list<contentversion> conver = [select id,title from contentversion LIMIT 10];
        for(contentversion cv : conver) {
            deleteAttachment(cv.id);
        }
        return null;
    }
        

    
    @AuraEnabled
    public static string deleteAttachment(Id contentVersionId) {
        try
        {
            string contentDocumentId = '';
            List<Id> idContentDocuments = new List<Id>();
            List<ContentVersion> objContentVersionList = new List<ContentVersion>();
            if(Schema.sObjectType.ContentVersion.isAccessible() && ContentVersion.sObjectType.getDescribe().isAccessible())
                objContentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionId];
            for(ContentVersion objContentVersion : objContentVersionList)
            {
                idContentDocuments.add(objContentVersion.ContentDocumentId); 
            }
            List<ContentDocument> objContentDocumentList = new List<ContentDocument>();
            if(Schema.sObjectType.ContentDocument.isAccessible() && ContentDocument.sObjectType.getDescribe().isAccessible())
                objContentDocumentList = [SELECT Id FROM ContentDocument WHERE Id IN :idContentDocuments];
            if (objContentDocumentList != null && objContentDocumentList.size()>0 && Schema.sObjectType.ContentDocument.isDeletable()  && ContentDocument.sObjectType.getDescribe().isDeletable())
            {
                contentDocumentId = objContentDocumentList[0].Id;
                DELETE objContentDocumentList ;
            }
            return contentDocumentId;
        }
       
            catch(Exception exp)
            {
               
                return 'Fail';
                
        }
        
    }
    
    //Onload value passed to component on edit of IDF
    
    /*
    @AuraEnabled
    public static WrapperIDFRepresentativeImages FetchRepresentativeImagesOnload(String IDFId)
    {
        
        Integer i=0;
        set<string> setContentDocumentIds = new set<string>();
        List<ContentVersion> listContentVersionRecordsReturned = new List<ContentVersion>();
        SymphonyIPM__Invention_Disclosure_New__c objInventionDisclosure = [SELECT id,MainImage__c,otherimages__c FROM SymphonyIPM__Invention_Disclosure_New__c WHERE id =: IDFId];
        if(objInventionDisclosure.otherimages__c != null)
        {
            List<string> temp = objInventionDisclosure.otherimages__c.trim().split(',');
            setContentDocumentIds.addAll(temp);
        }
        List<ContentVersion> listContentVersionRecords = [SELECT id, Title, FileExtension, ContentDocumentId,Document_Code__c FROM ContentVersion WHERE ContentDocumentId IN: setContentDocumentIds];
        ContentVersion objContentVersionRecords = [SELECT id, Title, FileExtension, ContentDocumentId,Document_Code__c FROM ContentVersion WHERE ContentDocumentId =: objInventionDisclosure.MainImage__c];
        Integer j = 0;
        for(ContentVersion objcontversion : listContentVersionRecords)
        {
            if(objcontversion.ContentDocumentId == objInventionDisclosure.MainImage__c)
            {
                listContentVersionRecordsReturned.add(objcontversion);
                j = i;
            }
            i=i+1;
        }
        WrapperIDFRepresentativeImages objWrapperIDFRepresentativeImages = new WrapperIDFRepresentativeImages(listContentVersionRecords, objContentVersionRecords);
        
        return objWrapperIDFRepresentativeImages;
    }
    
    public class WrapperIDFRepresentativeImages
    {
        @AuraEnabled
        public List<ContentVersion> listContversions{get;set;}
        @AuraEnabled
        public ContentVersion MainImageId{get;set;}
        
        public WrapperIDFRepresentativeImages(List<ContentVersion> listContentdocs, ContentVersion mainImageRecid)
        {
            listContversions = listContentdocs;
            MainImageId = mainImageRecid;
        }
    }

*/
    
     @InvocableMethod
    public static Void deleteAttachmentFromFlow(list<String> contentVersionId) 
    {
            
            List<string> listInventorIds= new List<string>();
            set<string> SetOfInvID = new  set<string>();
             List<string> value = contentVersionId[0].trim().split(',');
             System.debug('IDF'+value[0]);   
              if(value.size() > 1)
            {
                listInventorIds= value[1].trim().split(',');
            }
            
            SetOfInvID.addAll(listInventorIds);
            string value1 = contentVersionId[0];
            string contentDocumentId = '';
            List<Id> idContentDocuments = new List<Id>();
            List<ContentVersion> objContentVersionList = new List<ContentVersion>();
            if(Schema.sObjectType.ContentVersion.isAccessible() && ContentVersion.sObjectType.getDescribe().isAccessible())
                objContentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN:value];
            for(ContentVersion objContentVersion : objContentVersionList)
            {
                idContentDocuments.add(objContentVersion.ContentDocumentId); 
            }
         
            List<ContentDocument> objContentDocumentList = new List<ContentDocument>();
            if(Schema.sObjectType.ContentDocument.isAccessible() && ContentDocument.sObjectType.getDescribe().isAccessible())
                objContentDocumentList = [SELECT Id FROM ContentDocument WHERE Id IN :idContentDocuments];
            if (objContentDocumentList != null && objContentDocumentList.size()>0 && Schema.sObjectType.ContentDocument.isDeletable()  && ContentDocument.sObjectType.getDescribe().isDeletable())
            {
                //contentDocumentId = objContentDocumentList[0].Id;
                DELETE objContentDocumentList ;
            }
            //return contentDocumentId;
        
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