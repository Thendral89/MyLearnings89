/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-19-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class cmpAPiManagDocumentCtrl {
    
    
    
    @AuraEnabled
    public static void getDuplicateBytedanceRecordsDeleted (List<Id> PatentIds) {
        Set<String> FamilyIds = new Set<String>();
        Set<String> Docket_Number_Family_ID = new Set<String>();
        List<string> BytedanceFamiliesIds= new List<string>();
        
        List<iManage_Folders__c> duplicateRecords = new List<iManage_Folders__c>();
        List<iManage_Folders__c> IsDuplicateRecords = new List<iManage_Folders__c>();
        
        try {
            List<iManage_Folders__c> ObjIDFFamily = [
                SELECT Id,name__c,CreatedDate
                FROM iManage_Folders__c  
                WHERE recordId__c IN :PatentIds
                ORDER BY CreatedDate DESC LIMIT 50000
            ];
            
            Map<String, iManage_Folders__c> emailToContactMap = new Map<String, iManage_Folders__c>();
            for (iManage_Folders__c existing : ObjIDFFamily) {
                String key = existing.name__c;
                if (emailToContactMap.containsKey(key)) {
                    duplicateRecords.add(emailToContactMap.get(key));
                }
                emailToContactMap.put(key, existing);
            }
            
            
            for (iManage_Folders__c icon : ObjIDFFamily) {
                if (icon.name__c != null) {
                    String key = icon.name__c;
                    if (emailToContactMap.containsKey(key) && emailToContactMap.get(key) != icon) {
                        BytedanceFamiliesIds.add(icon.Id);
                    }
                }
            }
            
            
            if (!BytedanceFamiliesIds.isEmpty()) {
                cmpAPiManagObjectUtilWebservice.deleteObjects(BytedanceFamiliesIds, 'iManage_Folders__c');
            }
            
        } catch (Exception e) {
            system.debug('e.getMessage() ' + e.getMessage());
        }
        
        
        
    }
    
    @AuraEnabled
    public static List<iManage_Events__c> ManageEvent(string PatentId) {
        List<iManage_Events__c> ObjFolders  = [SELECT Id,recordId__c,IsProcessed__c,ObjectName__c,CreatedDate 
                                               FROM iManage_Events__c  
                                               Where recordId__c=:PatentId];
        if(ObjFolders.IsEmpty()){
            Id recordId = PatentId;
            String objectName = recordId.getSObjectType().getDescribe().getName();
            String queryStr = 'SELECT Id FROM ' + objectName + ' WHERE Id = :PatentId';
            List<SObject> ObjPatent = Database.query(queryStr);
            if(!ObjPatent.IsEmpty()){
                cmpAPiManageEventCtrl.PatentiManageEvent(ObjPatent); 
            }
        }
        
        
        return ObjFolders;
        
    }
    
    
    @AuraEnabled
    public static List<iManage_Folders__c> getiManageFolders(string PatentId) {
        List<iManage_Folders__c> ObjClientFolders  = [SELECT Id,name__c,recordId__c,CreatedDate,ParentId__c,
                                                      iManage_Workspace__r.id__c,iManage_Folders__c.id__c
                                                      FROM iManage_Folders__c 
                                                      WHERE  recordId__c=:PatentId
                                                      AND iManage_Workspace__r.id__c!=null
                                                      Order by name__c ];
        
        
        return ObjClientFolders;
        
    }
    
    
    
    
    
    @AuraEnabled
    public static String getFileContentAsText(String contentDocumentId) {
        ContentVersion contentVersion = [
            SELECT VersionData, Title 
            FROM ContentVersion 
            WHERE ContentDocumentId = :contentDocumentId 
            LIMIT 1
        ];
        
        Blob fileBlob = contentVersion.VersionData;
        String fileContent = fileBlob.toString();  // Converts the Blob to string (text content)
        
        return fileContent;
    }
    
    @future(callout=true)
    public static void UploadDocumentEMLfuture(List<string> emailmessageIds) {
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        UploadDocumentEML(emailmessageIds,access_token);
    }
    
    //@future(callout=true)
    public static void UploadDocumentEML(List<string> emailmessageIds,string access_token) {
        integer retried=0;
        string recordId='';
        string FolderName='';
        try {
            List<EmailMessage> ObjEmail  = [SELECT Id,RelatedToId,ContentVersionID__c 
                                            FROM EmailMessage WHERE Id IN : emailmessageIds 
                                            AND RelatedToId!=null
                                            AND ContentVersionID__c!=null limit 1];
            if(ObjEmail.size()>0){
                for(EmailMessage Data: ObjEmail){
                    recordId=Data.RelatedToId;
                    Id myId=recordId;
                    String sObjName = myId.getSObjectType().getDescribe().getName();
                    List<iManageTemplates__mdt> iManageTemplates= cmpAPAPIHeaderCtrl.iManageTemplatesEmailSetting(sObjName);
                    if(iManageTemplates.size()>0){
                        FolderName=iManageTemplates[0].FolderName__c;
                        
                        string query = 'SELECT Id, id__c, name__c FROM iManage_Folders__c WHERE name__c=:FolderName AND recordId__c=:recordId';
                        List<iManage_Folders__c> ObjFolders = Database.query(query);
                        if(ObjFolders.size()>0){
                            cmpAPiMangUploadDocCtrl.EmailToIManageFolder(access_token,ObjFolders[0].Id,ObjFolders[0].id__c,Data.ContentVersionID__c,recordId,Data.Id);  
                        }
                        
                    }
                    
                }
            }
        } catch (Exception ex) {
            System.debug('Error in uploadEmailsToIManage: ' + ex.getMessage());
        }
        
        
    }
    
    
    @AuraEnabled
    public static string iManageDocketingEmail(string PatentId, string iManageDocumentIds) {
        cmpAPiMngDocketingEmails.iMngEmails (PatentId,iManageDocumentIds);
        return 'success';	
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> getDocketingFolders(string PatentId) {
        Id myId=PatentId;
        String sObjName = myId.getSObjectType().getDescribe().getName();
        string FolderName='';
        List<iManageTemplates__mdt> objiManage = cmpAPAPIHeaderCtrl.iManageTemplatesSetting(sObjName);
        if(objiManage.size()>0){
            for(iManageTemplates__mdt Data: objiManage){
                FolderName=Data.FolderName__c;
            }
        }
        
        string query = 'SELECT Id, id__c, name__c FROM iManage_Folders__c WHERE name__c=:FolderName AND recordId__c=:PatentId';
        List<iManage_Folders__c> ObjFolders = Database.query(query);
        system.debug('ObjFolders ' + ObjFolders);
        
        return ObjFolders;
        
    }
    
    
    @AuraEnabled
    public static string UpdateEmailSubject(string PatentId,string DocumentName) {
        system.debug('PatentId ' + PatentId);
        system.debug('DocumentName ' + DocumentName);
        
        List<EmailMessage> lstContentVersions = new List<EmailMessage>();
        List<EmailMessage> objcontentversion = [SELECT Id,Subject__c
                                                FROM EmailMessage 
                                                WHERE Id =:PatentId 
                                                ORDER BY CreatedDate ];
        
        if (objcontentversion.size() > 0) {
            for (EmailMessage cv : objcontentversion) {
                cv.Id = cv.Id;
                cv.Subject__c = DocumentName;
                lstContentVersions.add(cv);
            }
        }
        
        system.debug('lstContentVersions ' + lstContentVersions);
        
        if(lstContentVersions.size()>0)
            update lstContentVersions;
        
        return 'success';	
    }
    
    @AuraEnabled
    public static string UpdateDocumentsTitle(string PatentId,string DocumentName) {
        system.debug('PatentId ' + PatentId);
        system.debug('DocumentName ' + DocumentName);
        
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        List<ContentVersion> objcontentversion = [SELECT Id, selectedItems__c, Title, PathOnClient, FileExtension, iManage_Folder_Name__c,
                                                  ContentDocumentId, CreatedDate, IsiManageDocument__c,
                                                  ContentSize, FileType, LastModifiedDate, iManagedStatus__c
                                                  FROM ContentVersion 
                                                  WHERE Id =:PatentId 
                                                  ORDER BY CreatedDate ];
        
        if (objcontentversion.size() > 0) {
            for (ContentVersion cv : objcontentversion) {
                cv.Title = DocumentName;
                cv.Title__c = DocumentName;
                
                lstContentVersions.add(cv);
            }
        }
        
        system.debug('lstContentVersions ' + lstContentVersions);
        
        if(lstContentVersions.size()>0)
            update lstContentVersions;
        
        return 'success';	
    }
    
    @AuraEnabled
    public static string DocumentsRenamed(string PatentId,string DocumentName) {
        string access_token='';
        List<iManage_Documents__c> ObjFolders  = [SELECT Id,id__c
                                                  FROM iManage_Documents__c 
                                                  WHERE (id__c =: PatentId OR Id=:PatentId) Limit 1];
        if (ObjFolders.size()>0) { 
            for(iManage_Documents__c Data: ObjFolders){
                iManage_Documents__c Documents = new iManage_Documents__c();
                Documents.Id=Data.Id;
                Documents.name__c=DocumentName;
                access_token=cmpAPAPIHeaderCtrl.getToken();
                access_token= cmpAPiMangDocumentRenameCtrl.iMngRenamed(access_token,DocumentName,Data.id__c,PatentId); 
                if(access_token=='success')
                    update Documents;
                
            }
        }
        
        return access_token;
        
    }
    
    
    @AuraEnabled
    public static string EmailsDocuSignUpload(String PatentId,string recordId) {
        List<string> ContentVersionsIds = new List<string>();
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        Set<Id> setofcontentdocId = new Set<Id>();
        string FolderName='';
        List<string> recordIds = new List<string>();
        string sObjName='';
        
        List<SymphonyLF__Email_Tracker__c> ObjEmailTracker = [SELECT Id FROM SymphonyLF__Email_Tracker__c 
                                                              Where  SymphonyLF__Email_Message_Id__c=:PatentId LIMIT 10 ];
        
        if(ObjEmailTracker.size()>0){
            for(SymphonyLF__Email_Tracker__c Tracker: ObjEmailTracker){
                recordIds.add(Tracker.Id);
            }
        }
        
        List<EmailMessage> ObjMessage = [SELECT Id FROM EmailMessage 
                                         Where  Id=:PatentId LIMIT 10 ];
        
        if(ObjMessage.size()>0){
            for(EmailMessage eTracker: ObjMessage){
                recordIds.add(eTracker.Id);
            }
        }
        
        
        
        List<ContentDocumentLink>  listofContentDocumentLink = [SELECT ContentDocumentId,Id,
                                                                IsDeleted,LinkedEntityId,
                                                                ShareType,SystemModstamp 
                                                                FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIds];
        for(ContentDocumentLink doclink : listofContentDocumentLink) {
            setofcontentdocId.add(doclink.ContentDocumentId);
        }
        
        
        List<ContentVersion> ObjCV = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                      Origin,PathOnClient,Title,VersionData,LastModifiedDate,
                                      iManage_Folder_Name__c,iManagedStatus__c,IsiManageDocument__c
                                      FROM ContentVersion 
                                      Where ContentDocumentId IN :setofcontentdocId LIMIT 10];
        
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(recordId);
        if(ws.size()>0) {
            sObjName=ws[0].sObjName;  
            
            
            List<iManageTemplates__mdt> ObjWT  = [SELECT Id,FolderName__c,IsEmails__c
                                                  FROM iManageTemplates__mdt 
                                                  Where IsEmails__c=true
                                                  AND ObjectName__c=:sObjName LIMIT 1 ];
            if(ObjWT.size()>0) {
                List<iManage_Folders__c> lstmanagers  = [SELECT Id,recordId__c,id__c
                                                         FROM iManage_Folders__c 
                                                         WHERE recordId__c =: recordId
                                                         AND name__c=:ObjWT[0].FolderName__c LIMIT 10];
                
                system.debug('ObjWT[0].FolderName__c' + ObjWT[0].FolderName__c);
                if (lstmanagers.Size() >0 ) {
                    if(ObjCV.size()>0){
                        for(ContentVersion Data: ObjCV){
                            cmpAPiManagDocumentCtrl.UploadDocumentfuture(lstmanagers[0].id__c,Data.ContentDocumentId,lstmanagers[0].Id); 
                        }
                    }
                }
            }
        }
        
        return 'Success';
        
    }
    
    
    @AuraEnabled
    public static string MultiDocMovetoFolder(string PatentId, string destinationId, string documentsId, string selectedItems) {
        string API5data;
        string access_token='';
        access_token=cmpAPAPIHeaderCtrl.getToken();
        string iManageFoldersId='';
        List<string> ObjSelectedItems = new List<string>();
        ObjSelectedItems = selectedItems.split(',');
        
        system.debug('PatentId ' + PatentId  + ' destinationId ' + destinationId + ' documentsId ' + documentsId + 'ObjSelectedItems ' + ObjSelectedItems  );
        
        List<iManage_Folders__c> ObjFolders = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                               From iManage_Folders__c 
                                               Where id__c=:destinationId Order by name__c];
        if(ObjFolders.size()>0){ 
            iManageFoldersId=ObjFolders[0].Id;
            
            List<ContentVersion> ObjDocuments = [SELECT Id,ContentDocumentId
                                                 FROM ContentVersion 
                                                 Where Id IN :ObjSelectedItems];
            if (ObjDocuments.size()>0) {
                for(ContentVersion folders: ObjDocuments){
                    cmpAPiManagDocumentCtrl.UploadDocumentfuture(destinationId,folders.ContentDocumentId,iManageFoldersId); 
                    API5data='success';
                }
            }
        } 
        
        return API5data;
        
    }
    
    @AuraEnabled
    public static List<Documentsitem> getSDocuDetails(string PatentId) {
        List<Documentsitem> Objitems = new List<Documentsitem>();
        List<String> ContentDocumentIds = new List<String>();
        List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id,ContentDocumentId
                                                            FROM ContentDocumentLink Where LinkedEntityId=:PatentId];
        if(lstContentDocumentLink.size()>0){
            for(ContentDocumentLink ldata: lstContentDocumentLink){
                ContentDocumentIds.add(ldata.ContentDocumentId);
            }
        }
        
        List<ContentVersion> ObjContentVersion = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                                  Origin,PathOnClient,Title,VersionData,LastModifiedDate,
                                                  iManage_Folder_Name__c,iManagedStatus__c,IsiManageDocument__c
                                                  FROM ContentVersion 
                                                  Where ContentDocumentId IN :ContentDocumentIds];
        if (ObjContentVersion.Size() >0 ) {
            for(ContentVersion Data: ObjContentVersion){
                Documentsitem subitem = new Documentsitem();
                subitem.Id=Data.Id;
                subitem.ContentDocumentId=Data.ContentDocumentId;
                subitem.iManagedStatus=Data.iManagedStatus__c;
                subitem.LastModifiedDate= Data.LastModifiedDate;
                subitem.name= Data.Title;
                if(Data.Title==null || Data.Title=='')
                    subitem.name= Data.PathOnClient;
                
                subitem.size=string.valueof(Data.ContentSize);
                subitem.last_user='';
                subitem.type=Data.FileExtension;
                subitem.version='1';
                subitem.is_checked_out='true';
                Objitems.add(subitem);
            }
        }
        
        
        return Objitems;
        
    }
    
    
    @AuraEnabled
    public static void getDocuSignToiManage(List<string> DocumentId) {
        
        List<iManageTemplates__mdt> ObjWT=IsDocuSign();
        if(ObjWT.size()>0) { 
            List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id,LinkedEntityId,ContentDocumentId
                                                                FROM ContentDocumentLink 
                                                                Where ContentDocumentId IN:DocumentId limit 5];
            if(lstContentDocumentLink.size()>0){
                for(ContentDocumentLink cdl: lstContentDocumentLink){  
                    String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                    if(sObjName == 'EnvelopeInfo__c') { 
                        List<EnvelopeInfo__c> ObjInfo  = [SELECT Id,recordId__c
                                                          FROM EnvelopeInfo__c Where Id=:cdl.LinkedEntityId ];
                        if(ObjInfo.size()>0){
                            List<iManage_Folders__c> ObjFolders=getiMngFolderByName(ObjInfo[0].recordId__c,ObjWT[0].FolderName__c);
                            if(ObjFolders.size()>0){
                                if(System.isFuture() || System.isBatch()){
                                    UploadDocument(ObjFolders[0].id__c,cdl.ContentDocumentId,ObjFolders[0].Id);
                                }else{
                                    UploadDocumentfuture(ObjFolders[0].id__c,cdl.ContentDocumentId,ObjFolders[0].Id);
                                }
                            }
                        }
                    } 
                }
            }
        }
        
        
    }
    
    @AuraEnabled
    public static List<iManageTemplates__mdt> IsDocuSign() {
        List<iManageTemplates__mdt> ObjWT  = [SELECT Id,FolderName__c,IsDocuSign__c 
                                              FROM iManageTemplates__mdt 
                                              Where IsDocuSign__c=true];
        return ObjWT;
        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> getiMngFolderByName(string PatentId, string name ) {
        List<iManage_Folders__c> lstmanagers  = [SELECT Id,recordId__c,id__c
                                                 FROM iManage_Folders__c 
                                                 WHERE recordId__c =: PatentId
                                                 AND name__c=:name LIMIT 1];
        
        return lstmanagers;
        
    }
    
    @AuraEnabled
    public static string DocuSignToiManageUpload(String PatentId,string ContentVersionId) {
        List<string> ContentVersionsIds = new List<string>();
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        string FolderName='';
        List<ContentVersion> ObjCV = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                      Origin,PathOnClient,Title,VersionData,LastModifiedDate,
                                      iManage_Folder_Name__c,iManagedStatus__c,IsiManageDocument__c
                                      FROM ContentVersion 
                                      Where (Id =:ContentVersionId OR ContentDocumentId =:ContentVersionId) LIMIT 1];
        List<iManageTemplates__mdt> ObjWT  = [SELECT Id,FolderName__c,IsDocuSign__c
                                              FROM iManageTemplates__mdt Where IsDocuSign__c=true LIMIT 1 ];
        system.debug('ObjWT ' + ObjWT);
        system.debug('PatentId ' + PatentId);
        
        if(ObjWT.size()>0) {
            List<iManage_Folders__c> lstmanagers  = [SELECT Id,recordId__c,id__c
                                                     FROM iManage_Folders__c 
                                                     WHERE recordId__c =: PatentId
                                                     AND name__c=:ObjWT[0].FolderName__c LIMIT 1];
            if (lstmanagers.Size() >0 ) {
                if(ObjCV.size()>0){
                    for(ContentVersion Data: ObjCV){
                        cmpAPiManagDocumentCtrl.UploadDocumentfuture(lstmanagers[0].id__c,Data.ContentDocumentId,lstmanagers[0].Id); 
                    }
                }
            }
        }
        
        return 'Success';
        
    }
    
    
    @AuraEnabled
    public static string DocuSignUpload(String PatentId,string ContentVersionId) {
        List<string> ContentVersionsIds = new List<string>();
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        
        Id myId=PatentId;
        String sObjName = myId.getSObjectType().getDescribe().getName();
        
        string FolderName='';
        List<ContentVersion> ObjCV = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                      Origin,PathOnClient,Title,VersionData,LastModifiedDate,
                                      iManage_Folder_Name__c,iManagedStatus__c,IsiManageDocument__c
                                      FROM ContentVersion 
                                      Where (Id =:ContentVersionId OR ContentDocumentId =:ContentVersionId) LIMIT 1];
        
        List<iManageTemplates__mdt> ObjWT  = [SELECT Id,FolderName__c,IsDocuSign__c
                                              FROM iManageTemplates__mdt 
                                              Where IsDocuSign__c=true
                                              AND ObjectName__c=:sObjName LIMIT 1 ];
        system.debug('ObjWT ' + ObjWT);
        system.debug('PatentId ' + PatentId);
        system.debug('ContentVersionId ' + ContentVersionId);
        
        if(ObjWT.size()>0) {
            List<iManage_Folders__c> lstmanagers  = [SELECT Id,recordId__c,id__c
                                                     FROM iManage_Folders__c 
                                                     WHERE recordId__c =: PatentId
                                                     AND name__c=:ObjWT[0].FolderName__c LIMIT 1];
            if (lstmanagers.Size() >0 ) {
                if(ObjCV.size()>0){
                    for(ContentVersion Data: ObjCV){
                        if(Data.IsiManageDocument__c==true || Data.IsiManageDocument__c!=true){
                            cmpAPiManagDocumentCtrl.UploadDocumentfuture(lstmanagers[0].id__c,Data.ContentDocumentId,lstmanagers[0].Id); 
                        } 
                    }
                }
            }
        }
        
        return 'Success';
        
    }
    
    @future(callout=true)
    public static void UploadDocumentfuture(string access_token,string iManageFoldersId,string createdFolderId,string ContentVersionId,string recordId) {
        cmpAPiMangUploadDocCtrl.iMngCreateFolder(access_token,iManageFoldersId,createdFolderId,ContentVersionId,recordId);
    }
    
    @future(callout=true)
    public static void UploadDocumentfuture(string createdFolderId,string ContentVersionId, string iManageFoldersId) {
        UploadDocument(createdFolderId,ContentVersionId,iManageFoldersId);
    }
    
    @AuraEnabled
    public static string UploadDocument(string createdFolderId,string ContentVersionId, string iManageFoldersId) {
        string recordId='';
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,id__c,recordId__c FROM iManage_Folders__c WHERE id__c =: createdFolderId limit 1];
        if(ObjFolders.size()>0)
            recordId=ObjFolders[0].recordId__c;
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        cmpAPiMangUploadDocCtrl.iMngCreateFolder(access_token,ObjFolders[0].Id,createdFolderId,ContentVersionId,recordId);
        return ContentVersionId;
    }
    
    @AuraEnabled
    public static string UploadDocketingDocument(string createdFolderId,string ContentVersionId, string iManageFoldersId,string iManageEmailObjectId) {
        string recordId='';
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,id__c,recordId__c FROM iManage_Folders__c WHERE id__c =: createdFolderId limit 1];
        if(ObjFolders.size()>0)
            recordId=ObjFolders[0].recordId__c;
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        system.debug('iManageEmailObjectId ' + iManageEmailObjectId);
        cmpAPiMangUploadDocCtrl.iMngUploadDocketing(access_token,ObjFolders[0].Id,createdFolderId,ContentVersionId,recordId,iManageEmailObjectId);
        return ContentVersionId;
    }
    
    @AuraEnabled
    public static List<Documentsitem> getDocuSignDocumentDetail(String PatentId) {
        system.debug('PatentId ' + PatentId);
        
        List<Documentsitem> Objitems = new List<Documentsitem>();
        List<ContentVersion> ObjContentVersion = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                                  Origin,PathOnClient,Title,VersionData,LastModifiedDate,
                                                  iManage_Folder_Name__c,iManagedStatus__c,IsiManageDocument__c,Title__c
                                                  FROM ContentVersion 
                                                  Where ContentDocumentId =:PatentId];
        
        if (ObjContentVersion.Size() >0 ) {
            for(ContentVersion Data: ObjContentVersion){
                Documentsitem subitem = new Documentsitem();
                subitem.Id=Data.Id;
                subitem.ContentDocumentId=Data.ContentDocumentId;
                subitem.iManagedStatus=Data.iManagedStatus__c;
                subitem.LastModifiedDate= Data.LastModifiedDate;
                subitem.name= Data.Title;
                if(Data.Title==null || Data.Title==''){
                    subitem.name=Data.PathOnClient;
                } else if(Data.Title=='false'){
                    if(Data.Title__c!=null){
                        subitem.name=Data.Title__c;
                    } else {
                        subitem.name=Data.PathOnClient;    
                    }
                    
                }
                
                
                subitem.size=string.valueof(Data.ContentSize);
                subitem.last_user='';
                subitem.type=Data.FileExtension;
                subitem.version='1';
                subitem.is_checked_out='true';
                Objitems.add(subitem);
            }
        }
        
        
        return Objitems;
        
    }
    
    @AuraEnabled
    public static List<ContentVersion> getDocuSignDetails(string PatentId) {
        system.debug('PatentId ' + PatentId);
        List<string> ContentVersionsIds = new List<string>();
        List<string> ContentDocumentIds = new List<string>();
        List<string> LinkedEntityIds = new List<string>();
        
        List<EnvelopeInfo__c> ObjWS  = [SELECT Id,recordId__c
                                        FROM EnvelopeInfo__c 
                                        WHERE recordId__c =: PatentId];
        if (ObjWS.size()>0) { 
            for(EnvelopeInfo__c ldata: ObjWS){
                LinkedEntityIds.add(ldata.Id);
            }
        }
        
        
        
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        List<ContentDocumentLink> ObjContentDocumentLink = new List<ContentDocumentLink>();
        
        
        List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id,ContentDocumentId
                                                            FROM ContentDocumentLink Where LinkedEntityId IN :LinkedEntityIds];
        if(lstContentDocumentLink.size()>0){
            for(ContentDocumentLink ldata: lstContentDocumentLink){
                ContentDocumentIds.add(ldata.ContentDocumentId);
            }
        }
        
        //AND iManagedStatus__c!='Success'
        List<ContentVersion> ObjContentVersion = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                                  Origin,PathOnClient,Title,VersionData,LastModifiedDate,
                                                  iManage_Folder_Name__c,iManagedStatus__c,IsiManageDocument__c
                                                  FROM ContentVersion Where ContentDocumentId IN :ContentDocumentIds
                                                 ];
        if(ObjContentVersion.size()>0){
            for(ContentVersion Data: ObjContentVersion){
                ContentDocumentLink CvDataLink = new ContentDocumentLink();
                CvDataLink.ContentDocumentId=Data.ContentDocumentId;
                CvDataLink.LinkedEntityId=PatentId;
                if(!ContentDocumentIds.contains(Data.ContentDocumentId))
                    ObjContentDocumentLink.add(CvDataLink);
            }
        }
        if(ObjContentDocumentLink.size()>0)
            insert ObjContentDocumentLink;
        
        return ObjContentVersion;
    }
    
    @AuraEnabled
    public static List<iManage__mdt> getiManageSetting(String ParentId) {
        
        List<iManage__mdt> iManage = [SELECT Id,IsDocuSign__c,IsEmail__c,IsSDocs__c
                                      From iManage__mdt];
        return iManage;
    }
    
    
    
    @future(callout=true)
    public static void CreateFolderfuture(string access_token,string recordId, string foldername, string workspaces,string SFrecordId) {
        cmpAPiManageCreateFolderCtrl.iMngCreateFolder(access_token,recordId,foldername,workspaces,SFrecordId);
    }
    
    
    @AuraEnabled
    public static List<iManage_Configuration__c> getClientWorkspaceId(string PatentId,string access_token,string recordId) {
        List<iManage_Configuration__c> ObjFolders = new List<iManage_Configuration__c>();
        string ObjectName='';
        string workspaceId='';
        string foldername='';
        Id myId=PatentId;
        ObjectName = myId.getSObjectType().getDescribe().getName();
        
        String query = 'SELECT Id, recordId__c, WorkspaceId__c,ObjectName__c FROM iManage_Configuration__c WHERE ObjectName__c=:ObjectName AND recordId__c =:PatentId';
        ObjFolders = Database.query(query);
        if(ObjFolders.IsEmpty()) {
            if(ObjectName=='SymphonyLF__Client__c') {
                foldername='SYMP'+cmpAPAPIHeaderCtrl.getClientId(PatentId);   
                if(foldername!='')
                    workspaceId=cmpAPiMngClientWorkSpaceCtrl.iMngGetWS(access_token,foldername,recordId,ObjectName,PatentId);
                if(workspaceId=='' || workspaceId==null)
                    workspaceId=cmpAPiMngClientCreateWorkSpaceCtrl.iMngCreateWorkSpaceCtrl(access_token,recordId,foldername,ObjectName,PatentId);
                
                ObjFolders  = [SELECT Id, recordId__c, WorkspaceId__c,ObjectName__c 
                               FROM iManage_Configuration__c  
                               WHERE recordId__c =: PatentId
                               AND ObjectName__c=:ObjectName];
                if(!ObjFolders.IsEmpty()){
                    workspaceId=ObjFolders[0].WorkspaceId__c;
                }  
            }
        } else {
            workspaceId=ObjFolders[0].WorkspaceId__c;
        }
        
        system.debug('workspaceId ' + workspaceId);
        
        
        return ObjFolders;
        
    }
    
    @AuraEnabled
    public static List<iManage_Configuration__c> getClientObjectWorkspaceId(string PatentId,string workspaceId,string access_token) {
        List<iManage_Configuration__c> ObjFolders = new List<iManage_Configuration__c>();
        string ObjectName='';
        string foldername='';
        string FolderId='';
        Id myId=PatentId;
        ObjectName = myId.getSObjectType().getDescribe().getName();
        ObjectName=ObjectName.replace('SymphonyLF__','');
        ObjectName=ObjectName.replace('__c','');
        FolderId=cmpAPiMngClientSearchObjectFolderCtrl.iMngCreateFolder(access_token,PatentId,ObjectName,workspaceId);
        
        if(FolderId=='' || FolderId==null){  
            FolderId=cmpAPiMngClientCreateFolderCtrl.iMngCreateFolder(access_token,PatentId,ObjectName,workspaceId);     
        } 
        
        //system.debug('getClientObjectWorkspaceId-workspaceId ' + workspaceId);
        //system.debug('getClientObjectWorkspaceId-ObjectName ' + ObjectName);
        
        ObjFolders  = [SELECT Id, recordId__c, WorkspaceId__c,ObjectName__c,FolderId__c 
                       FROM iManage_Configuration__c  
                       Where ObjectName__c=:ObjectName];
        
        //system.debug('getClientObjectWorkspaceId-ObjFolders ' + ObjFolders);
        return ObjFolders;
        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> CreateBatchClientWorkspaceFolders(string PatentId,string FolderId,string access_token,string workspaceId) {
        List<iManage_Folders__c> ObjFolders = new List<iManage_Folders__c>();
        string foldername='';
        string LegacyID='';
        string WorkspaceFolderId='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) {
            foldername=ws[0].name;    
            LegacyID=ws[0].LegacyID;    
        }
        
        if(foldername!='' && foldername!=null){
            List<iManage_Folders__c> ObjiMngFolders=cmpAPiMngClientSearchSubFolderCtrl.iMngBatchCreateFolder(access_token,PatentId,foldername,workspaceId,FolderId);         
            
            if(ObjiMngFolders.IsEmpty()){
                List<iManage_Folders__c> ObjSubFolders= cmpAPiMngClientCreateSubFolderCtrl.iMngBatchCreateFolder(access_token,foldername,PatentId,FolderId,workspaceId);
                
                if(!ObjSubFolders.IsEmpty())
                    ObjFolders.addall(ObjSubFolders);
            }
            
            
            if(!ObjiMngFolders.IsEmpty())
                ObjFolders.addall(ObjiMngFolders);
            
            if(!ObjFolders.IsEmpty())
                insert ObjFolders;
            
            
            ObjFolders  = [SELECT Id,id__c,iManage_Workspace__r.id__c 
                           FROM iManage_Folders__c  
                           WHERE name__c=:foldername 
                           AND recordId__c =:PatentId limit 1];
            
            
        }
        
        
        
        return ObjFolders;
        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> CreateClientWorkspaceFolders(string PatentId,string FolderId,string access_token,string workspaceId) {
        List<iManage_Folders__c> ObjFolders = new List<iManage_Folders__c>();
        string foldername='';
        string LegacyID='';
        string WorkspaceFolderId='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) {
            foldername=ws[0].name;    
            LegacyID=ws[0].LegacyID;    
        }
        
        if(foldername!='' && foldername!=null){
            List<iManage_Folders__c> iMngBatchCreateFolder=cmpAPiMngClientSearchSubFolderCtrl.iMngBatchCreateFolder(access_token,PatentId,foldername,workspaceId,FolderId);         
            system.debug('CreateClientWorkspaceFolders-WorkspaceFolderId' + iMngBatchCreateFolder);
            if(!iMngBatchCreateFolder.IsEmpty())
                insert iMngBatchCreateFolder;
            
            if(iMngBatchCreateFolder.IsEmpty())
                cmpAPiMngClientCreateSubFolderCtrl.iMngCreateFolder(access_token,foldername,PatentId,FolderId,workspaceId);
            
            ObjFolders  = [SELECT Id,id__c,iManage_Workspace__r.id__c 
                           FROM iManage_Folders__c  
                           WHERE name__c=:foldername 
                           AND recordId__c =:PatentId limit 1];
        } 
        return ObjFolders;
        
    }
    
    @AuraEnabled
    public static string CreateClientSubFoldersWorkSpace(string recordId,string sObjName,string FolderId,string access_token,string workspaceId) {
        
        List<AsyncApexJob> ObjWorkspace  = [SELECT id,Status From AsyncApexJob 
                                            Where ApexClass.Name='cmpAPiMngClientCreateFolderBatch' 
                                            and Status in ('Queued', 'Processing', 'Preparing', 'Holding')];
        system.debug('CreateClientSubFoldersWorkSpace ' + ObjWorkspace);
        
        if (ObjWorkspace.IsEmpty()) {
            cmpAPiMngClientCreateFolderBatch AwardDeclined = NEW cmpAPiMngClientCreateFolderBatch(access_token,recordId,FolderId,sObjName,workspaceId);
            database.executeBatch(AwardDeclined, 1);
        }   
        
        return '';
        
    }
    
    @future(callout=true)
    public static void iMngClientFolderWorkspaceIdfuture(String recordId) {
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        cmpAPiManagDocumentCtrl.getClientFolderWorkspaceId(recordId,access_token);
    }
    
    @AuraEnabled
    public static string SetClientWorkspace(string PatentId) {
        List<iManage_Configuration__c> ObjFolders = new List<iManage_Configuration__c>();
        List<iManage_Folders__c> ObjClientFolders = new List<iManage_Folders__c>();
        
        string ObjectName='';
        string workspaceId='';
        string access_token='';
        string foldername='';
        string FolderId='';
        string query='';
        Id myId=PatentId;
        ObjectName = myId.getSObjectType().getDescribe().getName();
        string ClientId='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) 
            ClientId=ws[0].ClientId;    
        
        access_token=cmpAPAPIHeaderCtrl.getToken();  
        List<iManage_Configuration__c> workspaceIds=getClientWorkspaceId(ClientId,access_token,PatentId);
        if(workspaceIds.size()>0){
            workspaceId=workspaceIds[0].WorkspaceId__c;
        }
        
        
        return workspaceId;
        
    }
    
    @AuraEnabled
    public static string SetClientWorkspaceFolder(string PatentId,string access_token,string workspaceId) {
        string FolderId='';
        List<iManage_Configuration__c> FolderIds = getClientObjectWorkspaceId(PatentId,workspaceId,access_token);
        if(FolderIds.size()>0)
            FolderId=FolderIds[0].FolderId__c; 
        
        return FolderId;
        
    }
    
    @AuraEnabled
    public static string SetCreateClientWorkspaceFolders(string PatentId,string FolderId,string access_token,string workspaceId) {
        Id myId=PatentId;
        string ObjectName = myId.getSObjectType().getDescribe().getName();
        List<iManage_Folders__c> SubFolders=CreateClientWorkspaceFolders(PatentId,FolderId,access_token,workspaceId);
        system.debug('SetCreateClientWorkspaceFolders SubFolders-' + SubFolders);
        if(!SubFolders.IsEmpty()){
            CreateClientSubFoldersWorkSpace(PatentId,ObjectName,SubFolders[0].id__c,access_token,workspaceId);
        }
        return FolderId;
        
    }
    
    @AuraEnabled
    public static string SearchNewWorkspace(string PatentId) {
        string foldername='';
        string workspaceId='';
        string access_token='';
        string ClientId='';
        
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) {
            ClientId=ws[0].ClientId;
            foldername=ws[0].name;
        }
        
        List<iManage_Workspace__c> ObjFolders  = [SELECT Id,id__c,name__c
                                                  FROM iManage_Workspace__c 
                                                  WHERE recordId__c =: ClientId];
        
        system.debug('ObjFolders ' + ObjFolders);
        if (ObjFolders.size()>0) { 
            for(iManage_Workspace__c Data: ObjFolders){
                List<iManage_Folders__c> ObjiFolders = [SELECT Id,description__c,folder_type__c,id__c,name__c
                                                        FROM iManage_Folders__c 
                                                        WHERE recordId__c	 =:PatentId Order by name__c];
                if(ObjiFolders.IsEmpty()){
                    access_token=cmpAPAPIHeaderCtrl.getToken();
                    cmpAPiManagDocumentCtrl.getClientFolderWorkspaceId(PatentId,access_token);
                }
                return Data.id__c;
            }
        } else {
            access_token=cmpAPAPIHeaderCtrl.getToken();
            cmpAPiManagDocumentCtrl.getClientFolderWorkspaceId(PatentId,access_token);
            return foldername;
            
        }
        
        return foldername;
        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> getimanagefolder(String PatentId) {
        List<string> ContentVersionsIds = new List<string>();
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        List<iManage_Folders__c> lstmanagers  = [SELECT Id,recordId__c,id__c,name__c,LastModifiedDate,
                                                 iManage_Workspace__r.name__c,
                                                 iManage_Workspace__r.id__c
                                                 FROM iManage_Folders__c 
                                                 WHERE recordId__c =: PatentId 
                                                 AND recordId__c!=null 
                                                 Order by name__c desc];
        system.debug('getimanagefolder ' + lstmanagers);
        if (lstmanagers.Size() >0 ) {
            List<ContentVersion> ContentVersionsDetails=cmpAPiManagDocumentCtrl.getAttachedDocuments(PatentId);
            
            
            if(ContentVersionsDetails.size()>0){
                for(ContentVersion Data: ContentVersionsDetails){
                    if(Data.IsiManageDocument__c==true && Data.iManage_Folder_Name__c!=null && Data.iManage_Folder_Name__c!=''){
                        List<iManage_Setting__c> ObjiMng = cmpAPAPIHeaderCtrl.getiManageSettings(Data.iManage_Folder_Name__c,lstmanagers[0].iManage_Workspace__r.id__c);
                        system.debug('ObjiMng ' + ObjiMng);
                        if(ObjiMng.size()>0)
                            cmpAPiManagDocumentCtrl.UploadDocumentfuture(ObjiMng[0].Folder_Id__c,Data.ContentDocumentId,lstmanagers[0].Id); 
                    } 
                }
            }
        } 
        
        
        
        
        
        return lstmanagers;
        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> SetiManageClientFolderWorkspaceId(string PatentId) {
        List<iManage_Folders__c> ObjClientFolders = new List<iManage_Folders__c>();
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        ObjClientFolders=cmpAPiManagDocumentCtrl.getiManageClientFolderWorkspaceId(PatentId,access_token);
        
        return ObjClientFolders;        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> getiManageClientFolderWorkspaceId(string PatentId,string access_token) {
        List<iManage_Configuration__c> ObjFolders = new List<iManage_Configuration__c>();
        List<iManage_Folders__c> ObjClientFolders = new List<iManage_Folders__c>();
        
        string ObjectName='';
        string workspaceId='';
        string foldername='';
        string FolderId='';
        string query='';
        Id myId=PatentId;
        ObjectName = myId.getSObjectType().getDescribe().getName();
        string ClientId='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0){
            foldername=ws[0].Name;
            ClientId=ws[0].ClientId;
        }
        
        
        system.debug('foldername ' + foldername);
        
        ObjClientFolders  = [SELECT Id,name__c,recordId__c,CreatedDate,ParentId__c,
                             iManage_Workspace__r.id__c,iManage_Folders__c.id__c
                             FROM iManage_Folders__c 
                             WHERE name__c =: foldername 
                             AND recordId__c=:PatentId
                             AND iManage_Workspace__r.id__c!=null
                             Order by name__c ];
        system.debug('getiManageClientFolderWorkspaceId ObjWS ' + ObjClientFolders);
        if (ObjClientFolders.size()>0) { 
            CreateClientSubFoldersWorkSpace(PatentId,ObjectName,ObjClientFolders[0].id__c,access_token,ObjClientFolders[0].iManage_Workspace__r.id__c);
        } else {
            if(ClientId!='' && ClientId!=null){
                List<iManage_Configuration__c> ObjConfigs=[SELECT Id,name__c,ObjectName__c,recordId__c,
                                                           WorkspaceId__c,CreatedDate 
                                                           FROM iManage_Configuration__c
                                                           Where recordId__c=: ClientId limit 1];
                if (ObjConfigs.size()>0) { 
                    
                    string iObjectName='';
                    iObjectName=ObjectName.replace('SymphonyLF__','');
                    iObjectName=iObjectName.replace('__c','');
                    List<iManage_Configuration__c> ObjiConfigs=[SELECT Id,name__c,ObjectName__c,recordId__c,
                                                                WorkspaceId__c,CreatedDate 
                                                                FROM iManage_Configuration__c
                                                                Where recordId__c=: ClientId
                                                                AND ObjectName__c=:iObjectName limit 1];
                    if (ObjiConfigs.size()>0) {
                        List<iManage_Folders__c> SubFolders=CreateClientWorkspaceFolders(PatentId,ObjiConfigs[0].FolderId__c,access_token,ObjiConfigs[0].WorkspaceId__c);
                        return SubFolders;
                    } else {
                        ObjClientFolders= getClientFolderWorkspaceId(PatentId,access_token);
                    }
                } else {
                    ObjClientFolders= getClientFolderWorkspaceId(PatentId,access_token);   
                }
                
                ObjClientFolders= getClientFolderWorkspaceId(PatentId,access_token);
                return ObjClientFolders;
            }
        }
        
        
        
        
        return ObjClientFolders;
        
    }
    
    @AuraEnabled
    public static List<iManage_Folders__c> getClientFolderWorkspaceId(string PatentId,string access_token) {
        List<iManage_Configuration__c> ObjFolders = new List<iManage_Configuration__c>();
        List<iManage_Folders__c> ObjClientFolders = new List<iManage_Folders__c>();
        
        string ObjectName='';
        string workspaceId='';
        string foldername='';
        string FolderId='';
        string query='';
        Id myId=PatentId;
        ObjectName = myId.getSObjectType().getDescribe().getName();
        string ClientId='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) 
            ClientId=ws[0].ClientId;    
        
        List<iManage_Configuration__c> workspaceIds=getClientWorkspaceId(ClientId,access_token,PatentId);
        if(workspaceIds.size()>0){
            workspaceId=workspaceIds[0].WorkspaceId__c;
            system.debug('getClientFolderWorkspaceId-workspaceId' + workspaceId);
            if(workspaceId!='' && workspaceId!=null){
                List<iManage_Configuration__c> FolderIds = getClientObjectWorkspaceId(PatentId,workspaceId,access_token);
                if(FolderIds.size()>0){
                    
                    system.debug('getClientFolderWorkspaceId-FolderIds' + FolderIds);
                    
                    if(FolderIds[0].FolderId__c!=FolderIds[0].ObjectName__c){
                        system.debug('getClientFolderWorkspaceId-FolderId__c' + FolderIds[0].FolderId__c);
                        system.debug('getClientFolderWorkspaceId-ObjectName__c' + FolderIds[0].ObjectName__c);
                        
                        FolderId=FolderIds[0].FolderId__c; 
                        List<iManage_Folders__c> SubFolders=CreateClientWorkspaceFolders(PatentId,FolderId,access_token,workspaceId);
                        system.debug('SubFolders-' + SubFolders);
                        if(!SubFolders.IsEmpty()){
                            CreateClientSubFoldersWorkSpace(PatentId,ObjectName,SubFolders[0].id__c,access_token,workspaceId);
                        }
                    }                     
                }
                
                
            }
            
            
        }
        
        
        system.debug('workspaceId ' + ObjClientFolders);
        
        
        return ObjClientFolders;
        
    }
    
    
    
    @AuraEnabled
    public static string CreateWorkSpace(string recordId) {
        string foldername;
        string access_token='';
        string sObjName='';
        access_token=cmpAPAPIHeaderCtrl.getToken();
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(recordId);
        if(ws.size()>0){
            foldername=ws[0].name;  
            sObjName=ws[0].sObjName;  
        } 
        
        
        string workspaceSFId='';
        if(!test.isRunningTest()) 
            workspaceSFId=cmpAPiMngCreateWorkSpaceCtrl.iMngCreateWorkSpaceCtrl(access_token,recordId,foldername); 
        
        List<iManage_Workspace__c> ObjWS  = [SELECT Id,id__c,name__c
                                             FROM iManage_Workspace__c 
                                             WHERE Id =: workspaceSFId];
        if (ObjWS.size()>0) { 
            
            List<AsyncApexJob> ObjWorkspace  = [SELECT id,Status 
                                                From AsyncApexJob 
                                                Where ApexClass.Name='cmpAPiMngCreateFolderBatch' 
                                                and Status in ('Queued', 'Processing', 'Preparing', 'Holding')];
            if (ObjWorkspace.IsEmpty()) {
                cmpAPiMngCreateFolderBatch AwardDeclined = NEW cmpAPiMngCreateFolderBatch(access_token,recordId,ObjWS[0].Id__c,ObjWS[0].Id,sObjName);
                database.executeBatch(AwardDeclined, 1);
            }   
            
        }
        
        
        
        return '';
        
    }
    
    @AuraEnabled
    public static string getWorkspaceName(string PatentId) {
        string DocketNumber='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) 
            DocketNumber=ws[0].name;
        
        //foldername='SYMP'+cmpAPAPIHeaderCtrl.getClientId(PatentId);
        
        return DocketNumber;
        
    }
    
    @AuraEnabled
    public static List<iManage_Configuration__c> getWorkspaceId(string PatentId) {
        List<iManage_Configuration__c> ObjFolders = new List<iManage_Configuration__c>();
        string ObjectName='';
        string workspaceId='';
        string foldername='';
        Id myId=PatentId;
        ObjectName = myId.getSObjectType().getDescribe().getName();
        ObjectName='SymphonyLF__Client__c';
        string access_token='';
        string ClientId='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) 
            ClientId=ws[0].ClientId;
        system.debug('ClientId ' + ClientId);
        
        String query = 'SELECT Id, recordId__c, WorkspaceId__c,ObjectName__c,name__c,FolderId__c FROM iManage_Configuration__c WHERE ObjectName__c=:ObjectName AND recordId__c =:ClientId';
        ObjFolders = Database.query(query);
        if(ObjFolders.IsEmpty()) {
            if(ObjectName=='SymphonyLF__Client__c') {
                access_token = cmpAPAPIHeaderCtrl.getToken(); 
                foldername='SYMP'+cmpAPAPIHeaderCtrl.getClientId(ClientId);  
                
                system.debug('foldername ' + foldername);
                
                
                if(foldername!='')
                    workspaceId=cmpAPiMngClientWorkSpaceCtrl.iMngGetWS(access_token,foldername,PatentId,ObjectName,ClientId);
                if(workspaceId=='' || workspaceId==null)
                    workspaceId=cmpAPiMngClientCreateWorkSpaceCtrl.iMngCreateWorkSpaceCtrl(access_token,PatentId,foldername,ObjectName,ClientId);
                
                ObjFolders  = [SELECT Id, recordId__c, WorkspaceId__c,ObjectName__c,name__c 
                               FROM iManage_Configuration__c  
                               WHERE recordId__c =: PatentId
                               AND ObjectName__c=:ObjectName];
            }
        }    
        
        system.debug('ObjFolders ' + ObjFolders);
        
        return ObjFolders;
        
    }
    
    @AuraEnabled
    public static List<iManage_Workspace__c> OLDgetWorkspaceId(string PatentId) {
        List<iManage_Workspace__c> ObjFolders = new List<iManage_Workspace__c>();
        string foldername='';
        string LegacyID='';
        string workspaceId='';
        string access_token='';
        string workspace='';
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) {
            foldername=ws[0].name;    
            LegacyID=ws[0].LegacyID;    
        }
        
        
        foldername=foldernamesplit(foldername);
        String foldernameWithWildcard='';
        
        if(LegacyID!=null && LegacyID!='') {
            string LegacyIDfoldername='';
            if (foldername.startsWith('0')) 
                LegacyIDfoldername = foldername.substring(1);
            foldernameWithWildcard = LegacyIDfoldername + '%';
        } else {
            foldernameWithWildcard = foldername + '%';
        }
        
        
        system.debug('foldername ' + foldername);
        system.debug('LegacyID ' + LegacyID);
        
        
        String query = 'SELECT Id, id__c, name__c FROM iManage_Workspace__c WHERE name__c LIKE :foldernameWithWildcard';
        ObjFolders = Database.query(query);
        system.debug('ObjFolders ' + ObjFolders);
        if(LegacyID!=null && LegacyID!='' && ObjFolders.IsEmpty()) {
            access_token=cmpAPAPIHeaderCtrl.getToken();
            if (foldername.startsWith('0')) 
                foldername = foldername.substring(1);
            workspace=cmpAPiMngSearchWorkSpaceCtrl.iMngGetWS(access_token,foldername,PatentId);
            
            system.debug('workspaceId ' + workspaceId);
            ObjFolders  = [SELECT Id,id__c,name__c FROM iManage_Workspace__c  WHERE id__c =: workspace];
            if(!ObjFolders.IsEmpty()){
                workspaceId=ObjFolders[0].Id;
            }
            if(workspace!='400' && workspace !=null && workspace !='')
                cmpAPiMngSearchFolderWorkspaceIdCtrlFuture(access_token,workspace,PatentId,workspaceId);
            
        } else {
            
            query = 'SELECT Id, id__c, name__c FROM iManage_Workspace__c WHERE name__c LIKE :foldernameWithWildcard'; 
            ObjFolders = Database.query(query);
            system.debug('ObjFolders ' + ObjFolders);
            if(ObjFolders.IsEmpty())
                CreateWorkSpace(PatentId);
        }
        
        return ObjFolders;
        
    }
    
    @AuraEnabled
    public static List<Workspace> getIPMatterNumberWorkSpaceId(string PatentId) {
        list<Workspace> ObjWS = new list<Workspace>();
        
        string access_token='';
        Id myId=PatentId;
        String sObjName = myId.getSObjectType().getDescribe().getName();
        string query='';
        string foldername='';
        string Field_API_Name='';
        string Legacy_ID='';
        string workspaceId='';
        string ClientId='';
        
        List<iManageFolder__mdt> objiManage = cmpAPAPIHeaderCtrl.iManageFolderSetting(sObjName);
        if(objiManage.size()>0){
            for(iManageFolder__mdt Data: objiManage){
                Field_API_Name=Data.Folder_Field_API_Name__c;
                Legacy_ID=Data.Legacy_ID__c;
                ClientId=Data.ClientId__c;
                query='SELECT Id,'+ Field_API_Name + ',' + Legacy_ID + ',' + ClientId + ' FROM ' + sObjName +' WHERE Id =:PatentId';
            }
        }
        
        //List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
        system.debug('query ' + query);
        List<sObject> sobjList = Database.query(query);
        if(sobjList.size()>0){
            for (sObject record: sobjList) {
                Workspace WS = new Workspace();
                WS.name=string.valueOf(record.get(Field_API_Name));
                WS.Id=string.valueOf(record.get('Id'));
                WS.LegacyID=string.valueOf(record.get(Legacy_ID));
                WS.ClientId=string.valueOf(record.get(ClientId));
                WS.sObjName=sObjName;
                ObjWS.add(WS);
            }
        }
        
        system.debug('ObjWS ' + ObjWS);
        return ObjWS; 
    }
    
    
    
    @AuraEnabled
    public static List<ContentVersion> getFinishedAttachmentDetails(string PatentId) {
        system.debug('PatentId ' + PatentId);
        List<string> ContentVersionsIds = new List<string>();
        List<string> ContentDocumentIds = new List<string>();
        
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        List<ContentDocumentLink> ObjContentDocumentLink = new List<ContentDocumentLink>();
        
        
        List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id,ContentDocumentId
                                                            FROM ContentDocumentLink Where LinkedEntityId=:PatentId];
        if(lstContentDocumentLink.size()>0){
            for(ContentDocumentLink ldata: lstContentDocumentLink){
                ContentDocumentIds.add(ldata.ContentDocumentId);
            }
        }
        List<ContentVersion> ObjContentVersion = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                                  Origin,PathOnClient,Title,VersionData,
                                                  iManage_Folder_Name__c,iManagedStatus__c,IsiManageDocument__c
                                                  FROM ContentVersion Where ContentDocumentId IN :ContentDocumentIds
                                                  AND iManagedStatus__c!='Success'];
        if(ObjContentVersion.size()>0){
            for(ContentVersion Data: ObjContentVersion){
                ContentDocumentLink CvDataLink = new ContentDocumentLink();
                CvDataLink.ContentDocumentId=Data.ContentDocumentId;
                CvDataLink.LinkedEntityId=PatentId;
                if(!ContentDocumentIds.contains(Data.ContentDocumentId))
                    ObjContentDocumentLink.add(CvDataLink);
            }
        }
        if(ObjContentDocumentLink.size()>0)
            insert ObjContentDocumentLink;
        
        return ObjContentVersion;
    }
    
    @AuraEnabled
    public static string DocumentsCheckIn(string PatentId) {
        string access_token='';
        List<iManage_Documents__c> ObjFolders  = [SELECT Id,id__c
                                                  FROM iManage_Documents__c 
                                                  WHERE (id__c =: PatentId OR Id=:PatentId) Limit 1];
        if (ObjFolders.size()>0) { 
            for(iManage_Documents__c Data: ObjFolders){
                iManage_Documents__c Documents = new iManage_Documents__c();
                Documents.Id=Data.Id;
                Documents.is_checked_out__c='false';
                access_token=cmpAPAPIHeaderCtrl.getToken();
                access_token= cmpAPiManageCreateCheckInCtrl.iMngCheckIn(access_token,Data.id__c,PatentId); 
                if(access_token=='success')
                    update Documents;
                
            }
        }
        
        return access_token;
        
    }
    
    @AuraEnabled
    public static string DocumentsCheckOut(string PatentId,string comments,string due_date) {
        string access_token='';
        List<iManage_Documents__c> ObjFolders  = [SELECT Id,id__c
                                                  FROM iManage_Documents__c 
                                                  WHERE (id__c =: PatentId OR Id=:PatentId) Limit 1];
        if (ObjFolders.size()>0) { 
            for(iManage_Documents__c Data: ObjFolders){
                iManage_Documents__c Documents = new iManage_Documents__c();
                Documents.Id=Data.Id;
                Documents.is_checked_out__c='true';
                access_token=cmpAPAPIHeaderCtrl.getToken();
                access_token= cmpAPiManageCreateCheckOutCtrl.iMngCheckOut(access_token,comments,due_date,Data.id__c,PatentId); 
                if(access_token=='success')
                    update Documents;
                
            }
        }
        
        return access_token;
        
    }
    
    @AuraEnabled
    public static string EmailAttachedMoveToiManage(String PatentId,string destinationId, string documentsId) {
        system.debug('destinationId ' + destinationId  + ' documentsId ' + documentsId);
        List<ContentVersion> ContentVersionsIds = new List<ContentVersion>();
        string access_token='';
        list<iManage_Folders__c> ObjFolders = [SELECT Id,description__c,folder_type__c,id__c,name__c
                                               FROM iManage_Folders__c 
                                               WHERE recordId__c	 =:PatentId
                                               AND id__c=:destinationId];
        if(ObjFolders.size()>0) {
            
            List<ContentVersion> Details  = [SELECT Id,ContentDocumentId
                                             FROM ContentVersion 
                                             WHERE Id =: documentsId ];
            if(Details.size()>0){
                List<ContentVersion> ContentVersionsDetails  = [SELECT Id,ContentDocumentId
                                                                FROM ContentVersion 
                                                                WHERE ContentDocumentId =: Details[0].ContentDocumentId ORDER BY VersionNumber DESC LIMIT 1];
                if(ContentVersionsDetails.size()>0){
                    for(ContentVersion Data: ContentVersionsDetails) {
                        ContentVersion CvData = new ContentVersion();
                        CvData.Id=Data.Id;
                        access_token=cmpAPAPIHeaderCtrl.getToken();
                        cmpAPiMangUploadDocCtrl.iMngCreateFolder(access_token,ObjFolders[0].Id,destinationId,Data.ContentDocumentId,PatentId); 
                        
                        if(access_token==Data.ContentDocumentId){
                            CvData.iManagedStatus__c='success';
                            ContentVersionsIds.add(CvData); 
                            access_token='success';
                        }
                        
                    }
                }
            }
        }
        if(ContentVersionsIds.size()>0)
            update ContentVersionsIds;
        
        return access_token;
        
    }
    
    @AuraEnabled
    public static List<cmpAPiMngSearchCtrl.data> GetEmailLibSearchFolders(string PatentId,string searchString) {
        List<cmpAPiMngSearchCtrl.data> API5data = new List<cmpAPiMngSearchCtrl.data>();
        List<string> FolderIds = new List<string>();
        searchString = '%' + searchString + '%';
        list<iManage_Folders__c> objcontentversion = [SELECT Id,description__c,folder_type__c,id__c,name__c
                                                      FROM iManage_Folders__c 
                                                      WHERE recordId__c	 =:PatentId
                                                      AND (name__c LIKE :searchString) ORDER BY name__c];
        if (objcontentversion.size()>0){
            for(iManage_Folders__c folder : objcontentversion){
                cmpAPiMngSearchCtrl.data data = new cmpAPiMngSearchCtrl.data();
                data.description=folder.description__c;
                data.folder_type=folder.folder_type__c;
                data.id=folder.id__c;
                data.name=folder.name__c;
                if(folder.name__c.LEFT(5) !='.Show'){
                    if (!FolderIds.contains(folder.name__c))
                        API5data.add(data);
                    FolderIds.add(folder.name__c);
                }
                
            }
        }
        
        system.debug('API5data ' + API5data); 
        
        return API5data;
        
    }
    
    
    
    @AuraEnabled
    public static List<ContentVersion> getEmailAttachedDocuments(string PatentId) {
        try {
            system.debug('PatentId ' + PatentId);
            
            List<string> setofcontentdocId = new List<string>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT Id,ContentDocumentId,LinkedEntityId 
                                                                    FROM ContentDocumentLink 
                                                                    WHERE LinkedEntityId =:PatentId];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
            list<ContentVersion> objcontentversion = [SELECT Id, selectedItems__c,Title, PathOnClient,FileExtension,iManage_Folder_Name__c,
                                                      ContentDocumentId,CreatedDate,IsiManageDocument__c,
                                                      ContentSize,FileType,LastModifiedDate,iManagedStatus__c
                                                      FROM ContentVersion 
                                                      WHERE ContentDocumentId IN :setofcontentdocId ORDER BY CreatedDate];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    lstContentVersions.add(cv);
                }
            }
            
            system.debug('lstContentVersions ' + lstContentVersions);
            return lstContentVersions;
            
        }
        catch(Exception exp) {
            throw exp;
        }
        
    }
    
    public class Emailsitem{
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public datetime LastModifiedDate {get; set;}
        @AuraEnabled
        public String size {get; set;}
        @AuraEnabled
        public String last_user {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String version {get; set;}
        @AuraEnabled
        public boolean IsiManageProcessed {get; set;}
        
        
    }
    @AuraEnabled
    public static List<Emailsitem> getEmailsDetail(String PatentId) {
        List<Emailsitem> Objitems = new List<Emailsitem>();
        List<string> DocumentId = new List<string>();
        system.debug('PatentId -' +  PatentId);
        
        List<EmailMessage> lstmanagers  = [SELECT Id,HasAttachment,Subject,Status,LastModifiedDate,Type__c,Created_By_Name__c,
                                           FromAddress,HtmlBody,IsiManageProcessed__c,Subject__c
                                           From EmailMessage
                                           Where Id=:PatentId];
        if (lstmanagers.Size() >0 ) {
            for(EmailMessage Data: lstmanagers){
                Emailsitem subitem = new Emailsitem();
                subitem.Id=Data.Id;
                subitem.LastModifiedDate= Data.LastModifiedDate;
                subitem.name= Data.Subject;
                if(Data.Subject__c!=null && Data.Subject__c!='')
                    subitem.name= Data.Subject__c;
                
                subitem.size=Data.FromAddress;
                subitem.last_user=Data.Created_By_Name__c;
                subitem.type=Data.Type__c;
                subitem.version=Data.HtmlBody;
                if(Data.HtmlBody!=null && Data.HtmlBody.length()>200)
                    subitem.version=Data.HtmlBody.left(200);
                subitem.IsiManageProcessed=Data.IsiManageProcessed__c;
                
                Objitems.add(subitem);
            }
        }
        
        
        return Objitems;
        
    }
    
    @AuraEnabled
    public static List<Emailsitem> getiManageEmailsDetail(String PatentId) {
        List<Emailsitem> Objitems = new List<Emailsitem>();
        List<string> DocumentId = new List<string>();
        system.debug('PatentId -' +  PatentId);
        
        List<EmailMessage> lstmanagers  = [SELECT Id,HasAttachment,Subject,Status,LastModifiedDate,Type__c,Created_By_Name__c,
                                           FromAddress,HtmlBody,IsiManageProcessed__c,Subject__c
                                           From EmailMessage
                                           Where RelatedToId=:PatentId];
        if (lstmanagers.Size() >0 ) {
            for(EmailMessage Data: lstmanagers){
                Emailsitem subitem = new Emailsitem();
                subitem.Id=Data.Id;
                subitem.LastModifiedDate= Data.LastModifiedDate;
                subitem.name= Data.Subject;
                if(Data.Subject__c!=null && Data.Subject__c!='')
                    subitem.name= Data.Subject__c;
                
                subitem.size=Data.FromAddress;
                subitem.last_user=Data.Created_By_Name__c;
                subitem.type=Data.Type__c;
                subitem.version=Data.HtmlBody;
                if(Data.HtmlBody!=null && Data.HtmlBody.length()>200)
                    subitem.version=Data.HtmlBody.left(200);
                
                subitem.IsiManageProcessed=Data.IsiManageProcessed__c;
                Objitems.add(subitem);
            }
        }
        
        
        return Objitems;
        
    }
    
    public class Emails {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public List<Emails> items {get; set;}
        @AuraEnabled
        public Boolean hasChildren {get; set;}
        @AuraEnabled
        public Boolean expanded {get; set;}
    }
    
    @AuraEnabled
    public static List<Emails> getEmails(String ParentId) {
        List<Emails> EmailItem = new List<Emails>();
        List<Emails> ObjEmails = new List<Emails>();
        List<EmailMessage> parentKeywordList = [SELECT Id,HasAttachment,Subject,Status,Subject__c	
                                                From EmailMessage Where RelatedToId=:ParentId];
        if(parentKeywordList.size() > 0) { 
            for(EmailMessage keyObj : parentKeywordList) {
                Emails item = new Emails();
                item.label=keyObj.Subject;
                if(keyObj.Subject__c!=null && keyObj.Subject__c!='')
                    item.name= keyObj.Subject__c;
                item.name=keyObj.Id;
                item.items=EmailItem;
                item.hasChildren=false;
                item.expanded=false;
                ObjEmails.add(item);
            }
        }
        
        System.debug('sobjectList::: ' + ObjEmails);
        return ObjEmails;
    }
    
    @AuraEnabled
    public static List<string> getContentiManageDocument(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ContentVersion.iManage_Folder_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());    
        }
        return pickListValuesList;  
    }
    
    @AuraEnabled
    public static void updatedoctype(string recid,string value){
        ContentVersion atc = [select id,iManage_Folder_Name__c from ContentVersion where id =:recid];
        if(value != 'Not Specified'){
            atc.iManage_Folder_Name__c = value;
        } else{
            atc.iManage_Folder_Name__c = '';
        }
        update atc;
    }
    
    @AuraEnabled
    public static string SearchWorkspacebyName(string access_token,string recordId,string workspaces,string workspaceId) {
        system.debug('IPMatterNumber 2' + workspaces);
        workspaces=cmpAPiMngSearchWorkSpaceCtrl.iMngGetWS(access_token,workspaces,recordId);
        if(workspaces!='400' && workspaces !=null && workspaces !='')
            cmpAPiMngSearchFolderWorkspaceIdCtrlFuture(access_token,workspaces,recordId,workspaceId);
        
        return workspaces;
        
    }
    
    @future(callout=true)
    public static void cmpAPiMngSearchFolderWorkspaceIdCtrlFuture(string access_token,string workspaces,string recordId,string workspaceId) {
        cmpAPiMngSearchFolderWorkspaceIdCtrl.iMngWSFolder(access_token,workspaces,recordId,workspaceId);
    }
    
    public class Workspace {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String sObjName {get; set;}
        @AuraEnabled
        public String LegacyID {get; set;}
        @AuraEnabled
        public String ClientId {get; set;}
        
        
    }
    
    
    
    @AuraEnabled
    public static string foldernamesplit(string foldername) {
        List<String> Workdas = new List<String>();
        if(foldername!='' && foldername!=null)
            Workdas = foldername.split('-');
        if(Workdas.size()==3)
            foldername=Workdas[2] + ' (' + Workdas[0] + '-' + Workdas[1] + ')';
        
        return foldername;
    }
    
    
    
    @AuraEnabled
    public static string SearchNewWorkspaceOLD(string PatentId) {
        string access_token='';
        string foldername='';
        string workspaceId='';
        
        List<Workspace> ws=getIPMatterNumberWorkSpaceId(PatentId);
        if(ws.size()>0) {
            foldername=ws[0].name;    
            workspaceId=ws[0].Id;
        }
        
        foldername=foldernamesplit(foldername);
        
        List<iManage_Workspace__c> ObjFolders  = [SELECT Id,id__c,name__c
                                                  FROM iManage_Workspace__c 
                                                  WHERE name__c =: foldername];
        system.debug('ObjFolders ' + ObjFolders);
        
        if (ObjFolders.size()>0) { 
            for(iManage_Workspace__c Data: ObjFolders){
                access_token=cmpAPAPIHeaderCtrl.getToken();
                cmpAPiMngSearchFolderWorkspaceIdCtrl.iMngWSFolder(access_token,Data.id__c,PatentId,Data.Id);
                return Data.id__c;
            }
        } else {
            if(foldername!=''){
                access_token=cmpAPAPIHeaderCtrl.getToken();
                foldername=cmpAPiManagDocumentCtrl.SearchWorkspacebyName(access_token,PatentId,foldername,workspaceId);
                return foldername;
            } else {
                foldername='Not Found';
            }
        }
        
        return foldername;
        
    }
    
    private static KeywordHierarchyWrapper createNode(Id objId, Map<Id, iManage_Folders__c> allKeywordMap, Map<Id, List<iManage_Folders__c>> parentChildRoleMap) {
        KeywordHierarchyWrapper n = new KeywordHierarchyWrapper();
        n.label = allKeywordMap.get(objId).name__c;
        n.name = objId;
        if (parentChildRoleMap.containsKey(objId)){
            n.hasChildren = true;
            List<KeywordHierarchyWrapper> lst = new List<KeywordHierarchyWrapper>();
            for (iManage_Folders__c r : parentChildRoleMap.get(objId)) {
                lst.add(createNode(r.Id, allKeywordMap, parentChildRoleMap));
            }           
            n.items = lst;
        }
        else {
            n.hasChildren = false;
        }
        return n;
    }
    
    
    @AuraEnabled
    public static List<KeywordHierarchyWrapper> getTreeJSON(String ParentId) {
        
        List<iManage_Folders__c> symphonyKeywordList = [SELECT id__c, name__c,ParentId__c 
                                                        From iManage_Folders__c Where recordId__c!=null Order by name__c limit 49999];
        
        Map<Id, iManage_Folders__c> allKeywordMap = new Map<Id, iManage_Folders__c>();
        for(iManage_Folders__c symphonyKeywordObj : symphonyKeywordList) {
            allKeywordMap.put(symphonyKeywordObj.Id, symphonyKeywordObj);
        }
        
        Map<Id, List<iManage_Folders__c>> parentChildRoleMap = new Map <Id, List<iManage_Folders__c>>();
        List<iManage_Folders__c> allKeywordMapTemp = new List<iManage_Folders__c>();
        for(iManage_Folders__c keywordObj : allKeywordMap.values()) {
            allKeywordMapTemp.add(keywordObj);
            List<iManage_Folders__c> tempList;
            if (!parentChildRoleMap.containsKey(keywordObj.ParentId__c)){
                tempList = new List<iManage_Folders__c>();
                tempList.Add(keywordObj);
                parentChildRoleMap.put(keywordObj.ParentId__c, tempList);
            } else {
                tempList = (List<iManage_Folders__c>)parentChildRoleMap.get(keywordObj.ParentId__c);
                tempList.add(keywordObj);
                parentChildRoleMap.put(keywordObj.ParentId__c, tempList);
            }
        }
        
        
        List<iManage_Folders__c> parentKeywordList = [SELECT id__c, name__c,ParentId__c 
                                                      From iManage_Folders__c 
                                                      Where recordId__c=:ParentId 
                                                      AND ParentId__c=null AND recordId__c!=null
                                                      Order by name__c ];
        if(parentKeywordList.size() > 0) 
            allKeywordMapTemp = parentKeywordList;
        
        List<KeywordHierarchyWrapper> sobjectList = new List<KeywordHierarchyWrapper>();
        List<JSONGenerator> genList = new List<JSONGenerator>();
        for(iManage_Folders__c keyObj : allKeywordMapTemp) {
            if(allKeywordMap.containsKey(keyObj.Id)) {
                if(keyObj.name__c.LEFT(5) !='.Show'){
                    KeywordHierarchyWrapper node = createNode(keyObj.Id, allKeywordMap, parentChildRoleMap);
                    sobjectList.add(node);
                }
                
            }
        }
        System.debug('sobjectList::: ' + sobjectList);
        return sobjectList;
    }
    
    public class KeywordHierarchyWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public List<KeywordHierarchyWrapper> items {get; set;}
        @AuraEnabled
        public Boolean hasChildren {get; set;}
        @AuraEnabled
        public Boolean expanded {get; set;}
    }
    
    @AuraEnabled
    public static string getiManagedId(string recordId){
        List<iManage_Folders__c> ObjFolders = [SELECT Id,id__c, name__c From iManage_Folders__c Where Id=:recordId];
        if(ObjFolders.size()>0)
            recordId=ObjFolders[0].id__c;
        
        return recordId;
    }
    
    
    
    @AuraEnabled
    public static string DocMovetoFolder(string PatentId, string destinationId, string documentsId) {
        string API5data;
        string access_token='';
        access_token=cmpAPAPIHeaderCtrl.getToken();
        string iManageFoldersId='';
        
        system.debug('PatentId ' + PatentId  + ' destinationId ' + destinationId + ' documentsId ' + documentsId  );
        
        List<iManage_Folders__c> ObjFolders = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                               From iManage_Folders__c 
                                               Where id__c=:destinationId];
        if(ObjFolders.size()>0){ 
            iManageFoldersId=ObjFolders[0].Id;
            List<iManage_Documents__c> ObjDocuments  = [SELECT Id,name__c,id__c,iManage_Folders__r.id__c
                                                        FROM iManage_Documents__c 
                                                        WHERE Id =: documentsId Limit 1];
            if (ObjDocuments.size()>0) {
                API5data=cmpAPiMngDocMoveCtrl.iMngDocMove(access_token,ObjDocuments[0].iManage_Folders__r.id__c,ObjDocuments[0].id__c,destinationId,iManageFoldersId,ObjDocuments[0].Id,PatentId); 
                system.debug('API5data ' + API5data); 
            }
        } 
        
        return API5data;
        
    }
    
    @AuraEnabled
    public static string GetFolder(string PatentId, string recordId) {
        string API5data;
        string access_token='';
        access_token=cmpAPAPIHeaderCtrl.getToken();
        API5data=cmpAPiMngGetFolderCtrl.iMngGetFolder(access_token,recordId,PatentId,recordId); 
        system.debug('API5data ' + API5data); 
        
        return API5data;
        
    }
    
    
    @AuraEnabled
    public static List<cmpAPiMngSearchCtrl.data> GetLibSearchFolders(string searchString, string PatentId) {
        system.debug('PatentId ' + searchString);
        List<cmpAPiMngSearchCtrl.data> API5data = new List<cmpAPiMngSearchCtrl.data>();
        string access_token='';
        access_token=cmpAPAPIHeaderCtrl.getToken();
        API5data=cmpAPiMngSearchCtrl.iMngSearch(access_token,searchString,PatentId); 
        system.debug('API5data ' + API5data); 
        
        return API5data;
        
    }
    
    @AuraEnabled
    public static string GetLibDocAccessUsers(string PatentId) {
        system.debug('PatentId ' + PatentId);
        string access_token='';
        string UserName='';
        List<User> ObjUser  = [SELECT Id,FederationIdentifier FROM User WHERE Id=:UserInfo.getUserId()];
        if(ObjUser.size()>0)
            UserName=ObjUser[0].FederationIdentifier;
        UserName='symphonysandbox';
        if(UserName!=null && UserName!=''){ 
            
            List<iManage_Documents__c> ObjFolders  = [SELECT Id,name__c,ContentVersionId__c,id__c,recordId__c
                                                      FROM iManage_Documents__c 
                                                      WHERE Id =: PatentId Limit 1];
            if (ObjFolders.size()>0) {
                UserName=UserName.replaceall('@MICHEALBEST.COM','');
                access_token=cmpAPAPIHeaderCtrl.getToken();
                access_token=cmpAPiMngDocumentAccessCtrl.iMngDocAccess(access_token,ObjFolders[0].id__c,UserName,ObjFolders[0].recordId__c); 
                system.debug('iMngSearchUsers ' + access_token); 
            } else {
                access_token='FederationIdentifier as a iManage Username Not Found';
            }
        }  
        return access_token;
        
    }
    
    @AuraEnabled
    public static string GetLibFolderUsers(string PatentId) {
        string access_token='';
        string UserName='';
        List<User> ObjUser  = [SELECT Id,FederationIdentifier FROM User WHERE Id=:UserInfo.getUserId()];
        if(ObjUser.size()>0)
            UserName=ObjUser[0].FederationIdentifier;
        UserName='symphonysandbox';
        if(UserName!=null && UserName!=''){ 
            access_token=cmpAPAPIHeaderCtrl.getToken();
            access_token=cmpAPiManageSearchUsersCtrl.iMngSearchUsers(access_token,UserName,PatentId); 
            system.debug('iMngSearchUsers ' + access_token); 
        } else {
            access_token='FederationIdentifier as a iManage Username Not Found';
        }
        
        return access_token;
        
    }
    
    @AuraEnabled
    public static List<item> getConfiguredFolder(string PatentId) {
        List<item> items = new List<item>();
        integer subfolder=0;
        List<string> FolderId = new List<string>();
        
        List<iManage_Folders__c> ObjFolders = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                               From iManage_Folders__c 
                                               Where recordId__c=:PatentId
                                               Order by name__c ASC LIMIT 100];
        if(ObjFolders.size()>0) {
            for(iManage_Folders__c folders: ObjFolders){
                FolderId.add(folders.id__c);
            }
        }
        
        List<iManage_Setting__c> objCSworkday = cmpAPAPIHeaderCtrl.getiManageConfiguredFolders();
        if(objCSworkday.size()>0){
            for(iManage_Setting__c folder: objCSworkday){
                if(FolderId.contains(folder.Folder_Id__c)){
                    item subitem = new item(folder.Name__c + '-' + folder.Jurisdiction__c,folder.Folder_Id__c, 'false', null,null);
                    items.add(subitem);
                }
            }
        }          
        return items;
    }
    
    @AuraEnabled
    public static List<item> getParentFolder(string PatentId) {
        List<item> items = new List<item>();
        integer subfolder=0;
        List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
        string workspacesId=objCSworkday[0].workspaces__c;
        
        Map<string,List<iManage_Folders__c>> Mapfolders = new Map<string,List<iManage_Folders__c>>();
        List<iManage_Folders__c> acctList = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                             From iManage_Folders__c 
                                             Where recordId__c=:PatentId
                                             AND IsConfigured__c=false
                                             Order by name__c ASC LIMIT 100];
        if(acctList.size()>0) {
            for(iManage_Folders__c folders: acctList){
                if(Mapfolders.containsKey(folders.parent_id__c)){
                    Mapfolders.get(folders.parent_id__c).add(folders);
                } else {
                    Mapfolders.put(folders.parent_id__c, new List<iManage_Folders__c>{folders});
                } 
            }
        }
        
        List<iManage_Folders__c> ParentFolder = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                                 From iManage_Folders__c 
                                                 Where recordId__c=:PatentId
                                                 AND IsConfigured__c=false
                                                 AND parent_id__c=:workspacesId
                                                 Order by name__c];
        if(ParentFolder.size()>0){
            for(iManage_Folders__c folder: ParentFolder){
                
                List<iManage_Folders__c> ObjInn = new List<iManage_Folders__c>();
                if(!Mapfolders.isEmpty())
                    ObjInn=Mapfolders.get(folder.id__c);
                if(!Mapfolders.isEmpty() && ObjInn !=null ) 
                    subfolder=ObjInn.size();
                
                item subitem = new item(folder.name__c,folder.id__c, 'false', null,subfolder);
                items.add(subitem);
            }
        }          
        return items;
    }
    
    @AuraEnabled
    public static List<item> getSubNodes(string PatentId, string selectedFolderId,string SubselectedFolderId) {
        List<item> items = new List<item>();
        integer subfolder=0;
        Map<string,List<iManage_Folders__c>> Mapfolders = new Map<string,List<iManage_Folders__c>>();
        List<iManage_Folders__c> acctList = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                             From iManage_Folders__c 
                                             Where recordId__c=:PatentId
                                             AND IsConfigured__c=false
                                             Order by name__c ASC LIMIT 100];
        if(acctList.size()>0) {
            for(iManage_Folders__c folders: acctList){
                if(Mapfolders.containsKey(folders.parent_id__c)){
                    Mapfolders.get(folders.parent_id__c).add(folders);
                } else {
                    Mapfolders.put(folders.parent_id__c, new List<iManage_Folders__c>{folders});
                } 
            }
        } 
        
        List<iManage_Folders__c> ObjFolders = [SELECT Id,name__c,id__c,parent_id__c,has_subfolders__c 
                                               FROM iManage_Folders__c 
                                               Where recordId__c=:PatentId
                                               AND IsConfigured__c=false
                                               AND parent_id__c=:SubselectedFolderId Order by name__c ASC];
        for(iManage_Folders__c folder: ObjFolders){
            
            List<iManage_Folders__c> ObjInn = new List<iManage_Folders__c>();
            if(!Mapfolders.isEmpty())
                ObjInn=Mapfolders.get(folder.id__c);
            if(!Mapfolders.isEmpty() && ObjInn !=null ) 
                subfolder=ObjInn.size();
            
            item subitem = new item(folder.name__c,folder.id__c, 'false', null,subfolder);
            items.add(subitem);
        }
        
        system.debug('items ' + items);
        
        return items;
    }
    
    @AuraEnabled
    public static List<item> getAllNodes(string PatentId, string selectedFolderId) {
        List<item> items = new List<item>();
        integer subfolder=0;
        Map<string,List<iManage_Folders__c>> Mapfolders = new Map<string,List<iManage_Folders__c>>();        
        List<iManage_Folders__c> acctList = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
                                             From iManage_Folders__c 
                                             Where recordId__c=:PatentId
                                             AND IsConfigured__c=false
                                             Order by name__c ASC LIMIT 100];
        if(acctList.size()>0) {
            for(iManage_Folders__c folders: acctList){
                if(Mapfolders.containsKey(folders.parent_id__c)){
                    Mapfolders.get(folders.parent_id__c).add(folders);
                } else {
                    Mapfolders.put(folders.parent_id__c, new List<iManage_Folders__c>{folders});
                } 
            }
        } 
        
        List<iManage_Folders__c> ObjFolders = [SELECT Id,name__c,id__c,parent_id__c,has_subfolders__c 
                                               FROM iManage_Folders__c 
                                               Where recordId__c=:PatentId
                                               AND IsConfigured__c=false
                                               AND parent_id__c=:selectedFolderId Order by name__c ASC];
        for(iManage_Folders__c folder: ObjFolders){
            
            List<iManage_Folders__c> ObjInn = new List<iManage_Folders__c>();
            if(!Mapfolders.isEmpty())
                ObjInn=Mapfolders.get(folder.id__c);
            if(!Mapfolders.isEmpty() && ObjInn !=null ) 
                subfolder=ObjInn.size();
            
            item subitem = new item(folder.name__c,folder.id__c, 'false', null,subfolder);
            items.add(subitem);
        }
        
        
        
        return items;
    }
    
    
    /*
@AuraEnabled
public static List<item> getAccountTree(string PatentId){

List<item> items = new List<item>();
List<string> folderid = new List<string>();
List<string> Subfolderid = new List<string>();
List<string> Subfolderitemid = new List<string>();
List<string> SelectedSubfolderid = new List<string>();
Map<string,string> Mapfolderid = new Map<string,string>();
Map<string,List<iManage_Folders__c>> Mapfolders = new Map<string,List<iManage_Folders__c>>();
List<iManage_Folders__c> acctList = [SELECT Id, Name,name__c,id__c,parent_id__c,has_subfolders__c 
From iManage_Folders__c 
Where recordId__c=:PatentId
AND IsConfigured__c=false
Order by CreatedDate ASC LIMIT 100];
if(acctList.size()>0) {
for(iManage_Folders__c folders: acctList){
if(Mapfolders.containsKey(folders.parent_id__c)){
Mapfolders.get(folders.parent_id__c).add(folders);
} else {
Mapfolders.put(folders.parent_id__c, new List<iManage_Folders__c>{folders});
} 
}
} 

for(iManage_Folders__c acc: acctList){
List<item> conitems = new List<item>();

List<iManage_Folders__c> ObjInn = new List<iManage_Folders__c>();
if(!Mapfolders.isEmpty())
ObjInn=Mapfolders.get(acc.id__c);
if(!Mapfolders.isEmpty() && ObjInn !=null ) { 
for(iManage_Folders__c con : ObjInn ) {


List<iManage_Folders__c> ObjInnSub = new List<iManage_Folders__c>();
if(!Mapfolders.isEmpty())
ObjInnSub=Mapfolders.get(con.id__c);
if(!Mapfolders.isEmpty() && ObjInnSub !=null ){ 
List<item> conitemssub = new List<item>();
for(iManage_Folders__c consub : ObjInnSub ) {

List<iManage_Folders__c> ObjInnSub2 = new List<iManage_Folders__c>();
if(!Mapfolders.isEmpty())
ObjInnSub2=Mapfolders.get(consub.id__c);
if(!Mapfolders.isEmpty() && ObjInnSub2 !=null ){ 
List<item> conitemssub2 = new List<item>();
for(iManage_Folders__c consub2 : ObjInnSub2 ) {


List<iManage_Folders__c> ObjInnSub3 = new List<iManage_Folders__c>();
if(!Mapfolders.isEmpty())
ObjInnSub3=Mapfolders.get(consub2.id__c);
if(!Mapfolders.isEmpty() && ObjInnSub3 !=null ){ 
List<item> conitemssub3 = new List<item>();
for(iManage_Folders__c consub3 : ObjInnSub3 ) {

List<iManage_Folders__c> ObjInnSub4 = new List<iManage_Folders__c>();
if(!Mapfolders.isEmpty())
ObjInnSub4=Mapfolders.get(consub3.id__c);
if(!Mapfolders.isEmpty() && ObjInnSub4 !=null ){ 
List<item> conitemssub4 = new List<item>();
for(iManage_Folders__c consub4 : ObjInnSub4 ) {

List<iManage_Folders__c> ObjInnSub5 = new List<iManage_Folders__c>();
if(!Mapfolders.isEmpty())
ObjInnSub5=Mapfolders.get(consub4.id__c);
if(!Mapfolders.isEmpty() && ObjInnSub5 !=null ){ 
List<item> conitemssub5 = new List<item>();
for(iManage_Folders__c consub5 : ObjInnSub5 ) {
item conitemsub5 = new item(consub5.name__c, String.valueOf(consub5.id__c), 'false', null,0);
conitemssub5.add(conitemsub5);
SelectedSubfolderid.add(consub5.id__c);
system.debug('5.1' + consub5.name__c);
}

item conitem5 = new item(consub4.name__c, String.valueOf(consub4.id__c), 'false', conitemssub5,0);
if(conitemssub5.size()>0)
conitemssub2.add(conitem5);
SelectedSubfolderid.add(consub4.id__c);
system.debug('5.2' + consub4.name__c);
} else {
item conitem5 = new item(consub4.name__c, String.valueOf(consub4.id__c), 'false', null,0);
conitemssub2.add(conitem5);
SelectedSubfolderid.add(consub4.id__c);
system.debug('5.3' + consub4.name__c);
}


}

item conitem4 = new item(consub3.name__c, String.valueOf(consub3.id__c), 'false', conitemssub4,0);
if(conitemssub4.size()>0)
conitemssub2.add(conitem4);
SelectedSubfolderid.add(consub3.id__c);
system.debug('4.2' + consub3.name__c);
} 
}


item conitem3 = new item(consub2.name__c, String.valueOf(consub2.id__c), 'false', conitemssub3,0);
if(conitemssub3.size()>0)
conitemssub2.add(conitem3);
SelectedSubfolderid.add(consub2.id__c);
system.debug('3.2' + consub2.name__c);    
}
}

item conitem = new item(consub.name__c, String.valueOf(consub.id__c), 'false', conitemssub2,0);
if(conitemssub2.size()>0)
conitemssub.add(conitem);
system.debug('2.2' + consub.name__c);

}
}

item conitem = new item(con.name__c, String.valueOf(con.id__c), 'false', conitemssub,0);
conitems.add(conitem);
system.debug('2' + con.name__c);



} else {
item conitem = new item(con.name__c, String.valueOf(con.id__c), 'false', null,0);
conitems.add(conitem); 
system.debug('3' + con.name__c);
}
SelectedSubfolderid.add(con.id__c);
}
}



system.debug('conitems' + conitems);
item accitem = new item(acc.name__c, String.valueOf(acc.id__c), 'false', conitems,0);
if(!SelectedSubfolderid.contains(acc.id__c))
items.add(accitem);
SelectedSubfolderid.add(acc.id__c);

}

system.debug('items' + items);

return items;
}
*/
    
    //Item Wrapper Class
    public class item{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String expanded {get; set;}
        @AuraEnabled
        public List<item> items {get; set;}
        @AuraEnabled
        public integer subfolder {get; set;}
        
        public item(String label, String name, String expanded, List<item> items, integer subfolder){
            this.label = label;
            this.name = name;
            this.expanded = expanded;
            this.items = items;
            this.subfolder = subfolder;
        }
    }
    
    @AuraEnabled
    public static string DocumentsPreview(string PatentId) {
        string access_token='';
        string ContentVersionId='';
        List<ContentVersion> Workdas = new List<ContentVersion>();
        List<iManage_Documents__c> ObjFolders  = [SELECT Id,name__c,ContentVersionId__c,id__c
                                                  FROM iManage_Documents__c 
                                                  WHERE (id__c =: PatentId OR Id =: PatentId) Limit 1];
        if (ObjFolders.size()>0) { 
            for(iManage_Documents__c Data: ObjFolders){
                access_token=cmpAPAPIHeaderCtrl.getToken();
                ContentVersionId=cmpAPiMangDownloadDocCtrl.iMngDownloadDocument(access_token,Data.id__c,PatentId); 
                return ContentVersionId;
            }
        }
        return ContentVersionId;
        
    }
    
    @AuraEnabled
    public static List<ContentVersion> OnPreview(string ContentVersionId) {
        system.debug('ContentVersionId' + ContentVersionId);
        
        List<ContentVersion> Workdas = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                        Origin,PathOnClient,Title,VersionData 
                                        FROM ContentVersion Where Id=:ContentVersionId];
        return Workdas;
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
    
    @AuraEnabled
    public static List<ContentVersion> UploadDocumentFinished(string PatentId,string ContentVersionId) {
        system.debug('ContentVersionId ' + ContentVersionId);
        system.debug('PatentId ' + PatentId);
        
        List<string> ContentVersionsIds = new List<string>();
        List<string> ContentDocumentIds = new List<string>();
        
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        List<ContentDocumentLink> ObjContentDocumentLink = new List<ContentDocumentLink>();
        
        
        List<ContentDocumentLink> lstContentDocumentLink = [SELECT Id,ContentDocumentId
                                                            FROM ContentDocumentLink Where LinkedEntityId=:PatentId];
        if(lstContentDocumentLink.size()>0){
            for(ContentDocumentLink ldata: lstContentDocumentLink){
                ContentDocumentIds.add(ldata.ContentDocumentId);
            }
        }
        List<ContentVersion> ObjContentVersion = [SELECT Id,ContentDocumentId,ContentSize,FileExtension,FileType,
                                                  Origin,PathOnClient,Title,VersionData 
                                                  FROM ContentVersion Where ContentDocumentId=:ContentVersionId];
        if(ObjContentVersion.size()>0){
            for(ContentVersion Data: ObjContentVersion){
                ContentVersion CvData = new ContentVersion();
                CvData.Id=Data.Id;
                CvData.IsiManageDocument__c=true;
                lstContentVersions.add(CvData);
                
                ContentDocumentLink CvDataLink = new ContentDocumentLink();
                CvDataLink.ContentDocumentId=Data.ContentDocumentId;
                CvDataLink.LinkedEntityId=PatentId;
                if(!ContentDocumentIds.contains(Data.ContentDocumentId))
                    ObjContentDocumentLink.add(CvDataLink);
            }
        }
        
        if(lstContentVersions.size()>0)
            update lstContentVersions;
        
        if(ObjContentDocumentLink.size()>0)
            insert ObjContentDocumentLink;
        
        List<ContentVersion> ContentVersionsDetails=cmpAPiManagDocumentCtrl.getAttachedDocuments(PatentId);
        
        
        return ContentVersionsDetails;
    }
    
    
    @AuraEnabled
    public static List<ContentVersion> getAttachedDocuments(string PatentId) {
        try
        {
            system.debug('PatentId ' + PatentId);
            
            List<string> setofcontentdocId = new List<string>();
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<ContentDocumentLink>  listofContentDocumentLink = [SELECT Id,ContentDocumentId,LinkedEntityId 
                                                                    FROM ContentDocumentLink 
                                                                    WHERE LinkedEntityId =:PatentId];
            for(ContentDocumentLink doclink : listofContentDocumentLink) {
                setofcontentdocId.add(doclink.ContentDocumentId);
            }
            
            list<ContentVersion> objcontentversion = [SELECT Id, Title, FileExtension,iManage_Folder_Name__c,
                                                      ContentDocumentId,CreatedDate,IsiManageDocument__c 
                                                      FROM ContentVersion 
                                                      WHERE ContentDocumentId IN :setofcontentdocId
                                                      AND IsiManageDocument__c=true ORDER BY CreatedDate];
            if (objcontentversion.size()>0){
                for(ContentVersion cv : objcontentversion){
                    lstContentVersions.add(cv);
                }
            }
            
            system.debug('lstContentVersions ' + lstContentVersions);
            return lstContentVersions;
            
        }
        catch(Exception exp) {
            throw exp;
        }
        
    }
    
    @AuraEnabled
    public static string getIPMatterNumber(string PatentId) {
        string access_token='';
        Id myId=PatentId;
        String sObjName = myId.getSObjectType().getDescribe().getName();
        string query='';
        string foldername='';
        string Field_API_Name='';
        
        List<iManageFolder__mdt> objiManage = cmpAPAPIHeaderCtrl.iManageFolderSetting(sObjName);
        if(objiManage.size()>0){
            for(iManageFolder__mdt Data: objiManage){
                Field_API_Name=Data.Folder_Field_API_Name__c;
                query='SELECT Id,'+ Field_API_Name +' FROM ' + sObjName +' WHERE Id =:PatentId';
            }
        }
        
        system.debug('query ' + query);
        List<sObject> sobjList = Database.query(query);
        if(sobjList.size()>0){
            for (sObject record: sobjList) {
                foldername=string.valueOf(record.get(Field_API_Name));
                System.debug('foldername ' + foldername);
            }
        }
        
        return foldername;
    }
    
    @AuraEnabled
    public static string SearchNewFolder(string PatentId) {
        string access_token='';
        string foldername=getIPMatterNumber(PatentId);
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,recordId__c,id__c
                                                FROM iManage_Folders__c 
                                                WHERE recordId__c =: PatentId];
        if (ObjFolders.size()>0) { 
            for(iManage_Folders__c Data: ObjFolders){
                return Data.id__c;
            }
        } else {
            if(foldername!=''){
                access_token=cmpAPAPIHeaderCtrl.getToken();
                foldername=cmpAPiMngSearchFolderDocCtrl.iMngSearchFolder(access_token,PatentId,foldername,PatentId);
                return foldername;
            } else {
                foldername='Not Found';
            }
        }
        
        return foldername;
        
    }
    
    @AuraEnabled
    public static string CreateNewSubFolder(string PatentId,string foldername, string createdFolderId) {
        string access_token='';
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,recordId__c,id__c
                                                FROM iManage_Folders__c 
                                                WHERE recordId__c =: PatentId 
                                                AND name__c=:foldername];
        if (ObjFolders.size()>0) { 
            for(iManage_Folders__c Data: ObjFolders){
                return Data.id__c;
            }
        } else {
            List<iManage_Folders__c> ObjFolder  = [SELECT Id,recordId__c,id__c
                                                   FROM iManage_Folders__c 
                                                   WHERE Id =: createdFolderId ];
            if(ObjFolder.size()>0)
                createdFolderId=ObjFolder[0].id__c;
            
            access_token=cmpAPAPIHeaderCtrl.getToken();
            return cmpAPiManageCreateSubFolderCtrl.iMngCreateFolder(access_token,foldername,PatentId,createdFolderId);
        }
        
        return '';
        
    }
    
    @AuraEnabled
    public static string CreateNewFolder(string PatentId,string foldername, string description) {
        string access_token='';
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,recordId__c,id__c
                                                FROM iManage_Folders__c 
                                                WHERE recordId__c =: PatentId 
                                                AND name__c=:foldername];
        if (ObjFolders.size()>0) { 
            for(iManage_Folders__c Data: ObjFolders){
                return Data.id__c;
            }
        } else {
            access_token=cmpAPAPIHeaderCtrl.getToken();
            return cmpAPiManageCreateFolderCtrl.iMngCreateFolder(access_token,PatentId,foldername,description,PatentId);
        }
        
        return '';
        
    }
    
    
    
    @AuraEnabled
    public static List<iManage_Folders__c> getselectedfolder(String PatentId) {
        List<string> ContentVersionsIds = new List<string>();
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        List<iManage_Folders__c> lstmanagers  = [SELECT Id,recordId__c,id__c,name__c,LastModifiedDate
                                                 FROM iManage_Folders__c 
                                                 WHERE id__c =: PatentId AND recordId__c!=null];
        if (lstmanagers.Size() >0 ) {
            return lstmanagers; 
        }
        
        
        return lstmanagers;
        
    }
    
    
    
    @AuraEnabled
    public static string DownloadDocuments(string PatentId) {
        string access_token='';
        List<iManage_Documents__c> ObjFolders  = [SELECT Id,name__c,ContentVersionId__c,id__c,
                                                  iManage_Folders__r.recordId__c
                                                  FROM iManage_Documents__c 
                                                  WHERE (id__c =: PatentId OR Id =: PatentId) Limit 1];
        if (ObjFolders.size()>0) { 
            for(iManage_Documents__c Data: ObjFolders){
                access_token=cmpAPAPIHeaderCtrl.getToken();
                return cmpAPiMangDownloadDocCtrl.iMngDownloadDocument(access_token,Data.id__c,Data.iManage_Folders__r.recordId__c);  
            }
        }
        
        return '';
        
    }
    
    
    @AuraEnabled
    public static String getDownloadedFileAsBase64(String docId) {
        String contentVersionId = cmpAPiManagDocumentCtrl.DownloadDocuments(docId);
        if (String.isBlank(contentVersionId)) {
            return '';
        }
        
        try {
            ContentVersion cv = [
                SELECT Id, VersionData, Title, PathOnClient
                FROM ContentVersion
                WHERE Id = :contentVersionId
                LIMIT 1
            ];
            return EncodingUtil.base64Encode(cv.VersionData);
            
        } catch (Exception e) {
            System.debug('Error retrieving ContentVersion data: ' + e.getMessage());
            return '';
        }
    }
    
    @AuraEnabled
    public static string GetUsers(string PatentId) {
        string UserName='';
        List<User> ObjUser  = [SELECT Id,FederationIdentifier FROM User WHERE Id=:UserInfo.getUserId()];
        if(ObjUser.size()>0)
            UserName=ObjUser[0].FederationIdentifier;
        UserName='symphonysandbox';
        if(UserName!=null && UserName!=''){ 
            UserName=UserName.replaceall('@mcciplaw.com.mccuat','');
            UserName=UserName.replaceall('@mcciplaw.com','');
        }
        return UserName;
    }
    
    @AuraEnabled
    public static string GetiManageAccessUsers(string PatentId) {
        system.debug('PatentId ' + PatentId);
        string access_token='';
        string iManageResponse='';
        string UserName=GetUsers(PatentId);
        
        if(UserName!=null && UserName!=''){ 
            access_token=cmpAPAPIHeaderCtrl.getToken();
            iManageResponse=cmpAPiMngLibraryAccessCtrl.iMngDocAccess(access_token,UserName,PatentId); 
            system.debug('iMngSearchUsers ' + access_token); 
        }  
        return iManageResponse;
        
    }
    
    @AuraEnabled
    public static string DeletedDocuments(string PatentId) {
        string access_token='';
        List<iManage_Documents__c> ObjFolders  = [SELECT Id,name__c,ContentVersionId__c,id__c,
                                                  iManage_Folders__r.recordId__c
                                                  FROM iManage_Documents__c 
                                                  WHERE id__c =: PatentId];
        if (ObjFolders.size()>0) { 
            for(iManage_Documents__c Data: ObjFolders){
                string UserName=GetUsers(PatentId);
                access_token=cmpAPAPIHeaderCtrl.getToken();
                string iManageResponse=cmpAPiMngLibraryAccessCtrl.iMngDocAccess(access_token,UserName,PatentId);
                if(iManageResponse=='Access'){
                    return cmpAPiMangDeletedDocCtrl.iMngDeletedDocument(access_token,Data.id__c,Data.iManage_Folders__r.recordId__c);   
                }
            }
        }
        
        return '';
        
    }
    
    @AuraEnabled
    public static string SyncSubFolderDocuments(string PatentId) {
        string access_token='';
        system.debug('SyncSubFolderDocuments - PatentId ' + PatentId);
        access_token=cmpAPAPIHeaderCtrl.getToken();
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,recordId__c,id__c,has_subfolders__c
                                                FROM iManage_Folders__c 
                                                WHERE id__c =: PatentId AND recordId__c!=null Limit 1];
        system.debug('ObjFolders - ' + ObjFolders);
        if (ObjFolders.size()>0) { 
            for(iManage_Folders__c Data: ObjFolders){
                
                cmpAPiMngGetFolderDocCtrl.iMngGetDoc(access_token,Data.id__c,Data.Id,Data.recordId__c);  
            }
        }
        
        return '';
        
    }
    
    @AuraEnabled
    public static string SyncSubFolderDocumentsFuture(string PatentId) {
        string access_token='';
        access_token=cmpAPAPIHeaderCtrl.getToken();
        system.debug('access_token ' + access_token);
        
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,recordId__c,id__c,has_subfolders__c
                                                FROM iManage_Folders__c 
                                                WHERE id__c =: PatentId AND recordId__c!=null Limit 1];
        system.debug('ObjFolders ' + ObjFolders);
        if (ObjFolders.size()>0) { 
            for(iManage_Folders__c Data: ObjFolders){
                system.debug('Data.recordId__c ' + Data.recordId__c);
                system.debug('Data.id__c ' + Data.id__c);
                cmpAPiManagDocumentCtrl.UpdatedSubFoldersfuture(access_token,Data.recordId__c,Data.id__c);
            }
        }
        
        return '';
        
    }
    
    @AuraEnabled
    public static string SyncFolderDocuments(string PatentId) {
        string access_token='';
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,recordId__c,id__c
                                                FROM iManage_Folders__c 
                                                WHERE recordId__c =: PatentId AND recordId__c!=null Limit 1];
        if (ObjFolders.size()>0) { 
            for(iManage_Folders__c Data: ObjFolders){
                access_token=cmpAPAPIHeaderCtrl.getToken();
                return cmpAPiMngGetFolderDocCtrl.iMngGetDoc(access_token,Data.id__c,Data.Id,Data.recordId__c);  
            }
        }
        
        return '';
        
    }
    
    @future(callout=true)
    public static void UpdatedSubFoldersfuture(string access_token,string recordId,string createdFoldername) {
        cmpAPiMngUpdatedFolderCtrl.iMngUpdatedFolder(access_token,createdFoldername,recordId);
    }
    
    @future(callout=true)
    public static void UploadedFoldersfuture(string access_token,string recordId,string createdFoldername) {
        cmpAPiManagDocumentCtrl.SyncSubFolders(access_token,recordId,createdFoldername);
    }
    
    @AuraEnabled
    public static void SyncSubFolders(string access_token,string recordId,string createdFoldername) {
        cmpAPiMngGetSubFolderDocCtrl.iMngSearchSubFolder(access_token,recordId,createdFoldername,recordId);
    }
    
    @AuraEnabled
    public static string UploadedFolders(string recordId, string createdFoldername) {
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        string iManageFoldersId=cmpAPiMngUpdatedFolderCtrl.iMngUpdatedFolder(access_token,createdFoldername,recordId);
        
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,id__c,has_subfolders__c FROM iManage_Folders__c WHERE Id =: iManageFoldersId limit 1];
        if (ObjFolders.size()>0) { 
            for(iManage_Folders__c record: ObjFolders){
                if(record.has_subfolders__c=='true'){
                    cmpAPiManagDocumentCtrl.UploadedFoldersfuture(access_token,recordId,record.id__c);
                }
            }
        }
        
        return iManageFoldersId; 
    }
    
    
    
    @future(callout=true)
    public static void UploadDocumentAPIDetails(string createdFolderId,string ContentVersionId, string iManageFoldersId) {
        string recordId='';
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,id__c,recordId__c FROM iManage_Folders__c WHERE id__c =: createdFolderId limit 1];
        if(ObjFolders.size()>0)
            recordId=ObjFolders[0].recordId__c;
        
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        cmpAPiMangUploadDocCtrl.iMngCreateFolder(access_token,iManageFoldersId,createdFolderId,ContentVersionId,recordId);
        
    }
    
    public static void UploadDocumentAPIDetailsBatch(string createdFolderId,string ContentVersionId, string iManageFoldersId) {
        string recordId='';
        List<iManage_Folders__c> ObjFolders  = [SELECT Id,id__c,recordId__c FROM iManage_Folders__c WHERE id__c =: createdFolderId limit 1];
        if(ObjFolders.size()>0)
            recordId=ObjFolders[0].recordId__c;
        
        string access_token=cmpAPAPIHeaderCtrl.getToken();
        cmpAPiMangUploadDocCtrl.iMngCreateFolder(access_token,iManageFoldersId,createdFolderId,ContentVersionId,recordId);
        
    }
    
    
    
    public class Documentsitem{
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String ContentDocumentId {get; set;}
        @AuraEnabled
        public String iManagedStatus {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public datetime LastModifiedDate {get; set;}
        @AuraEnabled
        public String size {get; set;}
        @AuraEnabled
        public String last_user {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String version {get; set;}
        @AuraEnabled
        public String is_checked_out {get; set;}
        
    }
    
    @AuraEnabled
    public static List<Documentsitem> getiManageDocumentFoldersDetail(String PatentId,string createdFolderId) {
        List<Documentsitem> Objitems = new List<Documentsitem>();
        List<string> DocumentId = new List<string>();
        List<string> ContentVersionId = new List<string>();
        List<string> PatentIds = new List<string>();
        PatentIds.add(PatentId);
        getDuplicateBytedanceRecordsDeleted (PatentIds);
        
        system.debug('PatentId -' +  PatentId);
        system.debug('PatentId -' +  createdFolderId);
        
        List<iManage_Documents__c> lstmanagers  = [SELECT Id,Name,access__c,author_description__c,author__c,class_code__c,class_description__c,
                                                   ContentVersionId__c,content_type__c,CreatedById,CreatedDate,create_date__c,create_profile_date__c,database__c,declared__c,
                                                   default_security__c,document_number__c,edit_date__c,edit_profile_date__c,extension__c,file_create_date__c,
                                                   file_edit_date__c,id__c,indexable__c,in_use__c,IsDeleted,is_checked_out__c,
                                                   is_declared__c,is_external_as_normal__c,is_external__c,is_hipaa__c,is_in_use__c,iwl__c,
                                                   last_user_description__c,last_user__c,location__c,name__c,operator_description__c,operator__c,
                                                   retain_days__c,size__c,system_edit_date__c,type_description__c,type__c,version__c,workspace_id__c,
                                                   workspace_name__c,wstype__c,Folder_Name__c,LastModifiedDate
                                                   FROM iManage_Documents__c
                                                   Where iManage_Folders__r.recordId__c=:PatentId
                                                   AND iManage_Folders__r.id__c=:createdFolderId];
        system.debug('lstmanagers ' + lstmanagers);
        if (lstmanagers.Size() >0 ) {
            for(iManage_Documents__c Data: lstmanagers){
                Documentsitem subitem = new Documentsitem();
                subitem.Id=Data.Id;
                subitem.LastModifiedDate= Data.LastModifiedDate;
                subitem.name= Data.name__c;
                subitem.size=Data.size__c;
                subitem.last_user=Data.last_user__c;
                subitem.type=Data.type__c;
                subitem.version=Data.version__c;
                subitem.is_checked_out=Data.is_checked_out__c;
                if(Data.ContentVersionId__c!='' && Data.ContentVersionId__c!=null)
                    ContentVersionId.add(Data.ContentVersionId__c);
                if (!DocumentId.contains(Data.id__c))
                    Objitems.add(subitem);
                DocumentId.add(Data.id__c);
            }
        }
        
        
        return Objitems;
        
    }
    
    @AuraEnabled
    public static List<Documentsitem> getiManageDocumentDetail(String PatentId) {
        List<Documentsitem> Objitems = new List<Documentsitem>();
        List<string> ContentVersionId = new List<string>();
        List<string> DocumentId = new List<string>();
        system.debug('PatentId -' +  PatentId);
        
        List<string> PatentIds = new List<string>();
        PatentIds.add(PatentId);
        getDuplicateBytedanceRecordsDeleted (PatentIds);
        
        List<iManage_Documents__c> lstmanagers  = [SELECT Id,Name,access__c,author_description__c,author__c,class_code__c,class_description__c,
                                                   ContentVersionId__c,content_type__c,CreatedById,CreatedDate,create_date__c,create_profile_date__c,database__c,declared__c,
                                                   default_security__c,document_number__c,edit_date__c,edit_profile_date__c,extension__c,file_create_date__c,
                                                   file_edit_date__c,id__c,indexable__c,in_use__c,IsDeleted,is_checked_out__c,
                                                   is_declared__c,is_external_as_normal__c,is_external__c,is_hipaa__c,is_in_use__c,iwl__c,
                                                   last_user_description__c,last_user__c,location__c,name__c,operator_description__c,operator__c,
                                                   retain_days__c,size__c,system_edit_date__c,type_description__c,type__c,version__c,workspace_id__c,
                                                   workspace_name__c,wstype__c,Folder_Name__c,LastModifiedDate
                                                   FROM iManage_Documents__c
                                                   Where iManage_Folders__r.recordId__c=:PatentId];
        if (lstmanagers.Size() >0 ) {
            for(iManage_Documents__c Data: lstmanagers){
                Documentsitem subitem = new Documentsitem();
                subitem.Id=Data.Id;
                subitem.LastModifiedDate= Data.LastModifiedDate;
                subitem.name= Data.name__c;
                subitem.size=Data.size__c;
                subitem.last_user=Data.last_user__c;
                subitem.type=Data.type__c;
                subitem.version=Data.version__c;
                subitem.is_checked_out=Data.is_checked_out__c;
                if(Data.ContentVersionId__c!='' && Data.ContentVersionId__c!=null)
                    ContentVersionId.add(Data.ContentVersionId__c);
                if (!DocumentId.contains(Data.id__c))
                    Objitems.add(subitem);
                DocumentId.add(Data.id__c);
            }
        }
        
        
        return Objitems;
        
    }
    
    
    @AuraEnabled
    public static List<Documentsitem> getDocumentDetail(String PatentId) {
        List<Documentsitem> Objitems = new List<Documentsitem>();
        List<string> DocumentId = new List<string>();
        List<string> ContentVersionId = new List<string>();
        system.debug('PatentId -' +  PatentId);
        
        List<string> PatentIds = new List<string>();
        PatentIds.add(PatentId);
        getDuplicateBytedanceRecordsDeleted (PatentIds);
        
        List<iManage_Documents__c> lstmanagers  = [SELECT Id,Name,access__c,author_description__c,author__c,class_code__c,class_description__c,
                                                   ContentVersionId__c,content_type__c,CreatedById,CreatedDate,create_date__c,create_profile_date__c,database__c,declared__c,
                                                   default_security__c,document_number__c,edit_date__c,edit_profile_date__c,extension__c,file_create_date__c,
                                                   file_edit_date__c,id__c,indexable__c,in_use__c,IsDeleted,is_checked_out__c,
                                                   is_declared__c,is_external_as_normal__c,is_external__c,is_hipaa__c,is_in_use__c,iwl__c,
                                                   last_user_description__c,last_user__c,location__c,name__c,operator_description__c,operator__c,
                                                   retain_days__c,size__c,system_edit_date__c,type_description__c,type__c,version__c,workspace_id__c,
                                                   workspace_name__c,wstype__c,Folder_Name__c,LastModifiedDate
                                                   FROM iManage_Documents__c
                                                   Where Id=:PatentId];
        system.debug('lstmanagers ' + lstmanagers);
        if (lstmanagers.Size() >0 ) {
            for(iManage_Documents__c Data: lstmanagers){
                Documentsitem subitem = new Documentsitem();
                subitem.Id=Data.Id;
                subitem.LastModifiedDate= Data.LastModifiedDate;
                subitem.name= Data.name__c;
                subitem.size=Data.size__c;
                subitem.last_user=Data.last_user__c;
                subitem.type=Data.type__c;
                subitem.version=Data.version__c;
                subitem.is_checked_out=Data.is_checked_out__c;
                if(Data.ContentVersionId__c!='' && Data.ContentVersionId__c!=null)
                    ContentVersionId.add(Data.ContentVersionId__c);
                
                if (!DocumentId.contains(Data.id__c))
                    Objitems.add(subitem);
                DocumentId.add(Data.id__c);
            }
        }
        
        
        return Objitems;
        
    }
    
    
}