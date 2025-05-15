@isTest
public class cmpAPDocuSignEnvelopeDocumentsTest {
    static testmethod void documentDocuSign(){
        cmpAPDocuSignEnvelopeDocument ddsd = new cmpAPDocuSignEnvelopeDocument();
        cmpAPDocuSignEnvelopeDocument.AvailableDocumentType ddsda = new cmpAPDocuSignEnvelopeDocument.AvailableDocumentType();
        ddsda.type = 'test';
        ddsda.isDefault = 'test';
        ddsd.documentId = 'tetst';
        ddsd.name = 'tetst';
        ddsd.type = 'tetst';
        ddsd.order = 'tetst';
        ddsd.pages = 'tetst';
        ddsd.availableDocumentTypes = new list<cmpAPDocuSignEnvelopeDocument.AvailableDocumentType>{ddsda};
        ddsd.display = 'tetst';
        ddsd.includeInDownload = 'tetst';
        ddsd.signerMustAcknowledge = 'tetst';
        ddsd.authoritativeCopy = 'tetst';
        ddsd.uri = 'tetst';
        
        cmpAPDocuSignEnvelopeDocuments ddsdenvolop = new cmpAPDocuSignEnvelopeDocuments();
        ddsdenvolop.envelopeId = 'test';
        ddsdenvolop.envelopeDocuments = new list<cmpAPDocuSignEnvelopeDocument>{ddsd};
        
    }
}