public with sharing class FileUploadController {
    @AuraEnabled
    public static void saveFiles(String fileName, String base64Data) {
        // Create ContentVersion and ContentDocumentLink records to store the file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = UserInfo.getUserId();
        cdl.ShareType = 'V';
        insert cdl;
    }
}