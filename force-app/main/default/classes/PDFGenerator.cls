/* Class Name: PDFGenerator
* Created On: January 24, 2025
* Description: The PDFGenerator class is responsible for generating PDF documents.
* -------------------------------------------------------------------*/
public class PDFGenerator {
    @InvocableMethod
    public static void generateIDFPDF(List < id > idf) {
        PDFGenerator.generateIDFPDFfuture(idf);
    }
    @Future(callout=true)
    public static void generateIDFPDFfuture(List < id > idf) {
        try{
            List<Task> idfs=[Select Id,WhatId,LastModifiedDate,Subject from Task where Id in: idf];
            for (Task invention: idfs) {
                PageReference TaskPDFPage = page.TaskPDFPage;
                TaskPDFPage.getParameters().put('Id', invention.Id);
                
                DateTime dt = invention.LastModifiedDate;
                Date datevalue = dt.date();
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; 
                conVer.PathOnClient = invention.Subject + '.pdf'; 
                if(!Test.isRunningTest()) {
                    conVer.VersionData = TaskPDFPage.getContent(); 
                } else {
                    conVer.VersionData = Blob.valueOf('testBlob file'); 
                }
                insert conVer;
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = invention.Id; 
                cDe.ShareType = 'I'; 
                cDe.Visibility = 'AllUsers';
                insert cDe;
            }
        } Catch(Exception Ex){
        }
    }
}