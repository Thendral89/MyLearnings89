public without sharing class FileUploadForEmailPreviewController {
    public FileUploadForEmailPreviewController() {

    }

    @AuraEnabled
    public static ComponentResponse getExistingFiles(String request){
        ComponentRequest req = (ComponentRequest) JSON.deserializeStrict(request, ComponentRequest.class);
        ComponentResponse res = new ComponentResponse();

        res.emailPreviewFiles = existingFiles(req);
        return res;
    }

    @AuraEnabled
    public static void deleteNewFilesUploaded(String request){
        ComponentRequest req = (ComponentRequest) JSON.deserializeStrict(request, ComponentRequest.class);

        List<String> contentDocumentIds = req.contentDocumentIds;

        if(contentDocumentIds == null || contentDocumentIds.size() == 0){
            return;
        }
        /*
        delete [
            SELECT Id, LatestPublishedVersionId, Title
            FROM ContentDocument
            WHERE Id IN :contentDocumentIds
        ];*/
    }

    private static List<EmailPreviewFiles> existingFiles(ComponentRequest req){
        List<EmailPreviewFiles> existingFiles = new List<EmailPreviewFiles>();

        List<String> contentDocumentIds = req.contentDocumentIds;
        
        List<ContentDocument> documents = [
            SELECT Id, LatestPublishedVersionId, Title
            FROM ContentDocument
            WHERE Id IN :contentDocumentIds
        ];

        for(ContentDocument d : documents){
            EmailPreviewFiles f = new EmailPreviewFiles();
            f.fileName = d.Title;
            f.documentId = d.Id;
            f.documentVersionId = d.LatestPublishedVersionId;

            existingFiles.add(f);
        }

        return existingFiles;
    }
}