import { LightningElement, api, wire } from 'lwc';
//import updateFilesAfterUpload from '@salesforce/apex/FileUploadForEmailPreviewController.updateFilesAfterUpload';
import getExistingFiles from '@salesforce/apex/FileUploadForEmailPreviewController.getExistingFiles';
import deleteNewFilesUploaded from '@salesforce/apex/FileUploadForEmailPreviewController.deleteNewFilesUploaded';


import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ID_FIELD from '@salesforce/schema/User.Id';


const COLUMNS = [
    { label: "Delete Icon", fieldName: "documentId", 
        fixedWidth: 70  ,
        cellAttributes: { alignment: 'left' },
        type: "clickableFileUploadIconsInEmails", 
        typeAttributes: { contentDocumentId: {fieldName: "documentId"}, sourceType: 'ContentDocumentDeletion' }
    },
    { label: "File Name", fieldName: "fileName", type: "text" }
  ];

export default class LwcFileUploadForFlows extends LightningElement {
    emailPreviewComponent = 'Email Preview Component';
    columns = COLUMNS;
    data = [];

    @api uploadedFilesTableLabel = '&nbsp;<b>Attachments</b>'
    @api fileUploadLabel;
    @api acceptedFormats = [];

    _multipleUploadsAllowed = true;
    @api multipleUploadsAllowed = false;
    @api hideFileUpload = false;

    @api contentVersionIds = [];
    @api contentDocumentIds = [];
    @api maxFileUploads = 10000;

    @api acceptedFormatsCommaSeparated;

    @api recordId;
    @api emailTemplateInstance;

    isLoading = false;

    userId;

    connectedCallback(){
        try{
            this.fetchExistingFiles();
        }catch(err){
            alert('JS Error :: lwcFileUploadForEmailPreview :: connectedCallback')
            console.error(err)
        }
    }

    newFilesUploaded = [];
    disconnectedCallback(){
        try{
            deleteNewFilesUploaded({'request' : JSON.stringify(
                {
                    "contentDocumentIds" : this.newFilesUploaded
                }
            )})
            .then( response => {
                try{
                    
                }catch(err){
                    alert('JS Error in Server callback :: lwcFileUploadForEmailPreview :: disconnectedCallback');
                }
            })
            .catch( error => {
                alert('Server Error :: lwcFileUploadForEmailPreview :: disconnectedCallback :: apexMethod => deleteNewFilesUploaded');
                console.error(error);
            })
        }catch(err){
            alert('JS Error :: lwcFileUploadForEmailPreview :: disconnectedCallback')
            console.error(this.analyzeError(err));
        }
    }

    analyzeError(error){
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        return message;
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, USER_ID_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            alert('Error in wire');
         //  this.error = error ; 
        } else if (data) {
            this.userId = data.fields.Id.value;
        }
    }

    fetchExistingFiles(){
        try{
            getExistingFiles({'request' : JSON.stringify(
                {
                  //  "placeOfUpload" : this.placeOfUpload,
                  //  "placeOfUploadInstanceId" : this.placeOfUploadInstanceId,
                   "recordId" : this.recordId,
                   "emailTemplateInstance" : this.emailTemplateInstance,
                   "contentDocumentIds" : this.contentDocumentIds
                }
            )})
            .then( response => {
                try{
                    this.data = response.emailPreviewFiles;
/*
                    console.log('this.contentDocumentIds <<<>>> ', JSON.stringify(this.contentDocumentIds));
                    response.emailPreviewFiles.forEach(e => {
                        console.log('e', JSON.stringify(e));
                        this.contentDocumentIds.push( e.documentId );
                        console.log('e2');
                    });*/
                }catch(err){
                    alert('JS Error in Server callback ::  :: fetchExistingFiles');
                }
            })
            .catch( error => {
                alert('Server Error :: BsFileUploadForFlows :: fetchExistingFiles :: apexMethod => getExistingFiles');
                console.error(error);
            })
        }catch(err){
            alert('JS Error :: BsFileUploadForFlows :: fetchExistingFiles')
            console.error(err)
        }
    }

    handleUploadFinished(event) {
        try{
            // Get the list of uploaded files
            const uploadedFiles = event.detail.files;
            //alert('No. of files uploaded : ' + uploadedFiles.length);
            console.log('uploadedFiles', JSON.stringify(uploadedFiles));
            // uploadedFiles [{"name":"Axiom-IdpCert (1).cer","documentId":"069DT000001Yt0wYAC","contentVersionId":"068DT000001YtBUYA0","contentBodyId":"05TDT000005EdJo2AK","mimeType":"application/x-x509-ca-cert"}]

            console.log('event.detail', JSON.stringify(event.detail));
            // event.detail {"files":[{"name":"Axiom-IdpCert (1).cer","documentId":"069DT000001Yt0wYAC","contentVersionId":"068DT000001YtBUYA0","contentBodyId":"05TDT000005EdJo2AK","mimeType":"application/x-x509-ca-cert"}]}
            let contentVersionIds = [];
            let contentDocumentIds = [... this.contentDocumentIds];
            let data = [... this.data];
            let newFilesUploaded = [... this.newFilesUploaded];
            if(uploadedFiles && Array.isArray(uploadedFiles) && uploadedFiles.length > 0){
                uploadedFiles.forEach(e => {
                    newFilesUploaded.push(e.documentId);
                    contentVersionIds.push(e.contentVersionId);
                    contentDocumentIds.push(e.documentId);
console.log('e', JSON.stringify(e));
                    data.push({
                        "fileName" : e.name,
                        "documentId" : e.documentId,
                        "documentVersionId" : e.contentVersionId
                    });
                });
            }

            this.newFilesUploaded = newFilesUploaded;
            this.contentDocumentIds = contentDocumentIds;
            console.log('con',JSON.stringify(contentDocumentIds));
            this.data = data;
            const selectedEvent = new CustomEvent('file', { detail: { contentDocumentIds }, });
        
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
            

            /*
            this.contentVersionIds = contentVersionIds;
            this.contentDocumentIds = contentDocumentIds;
            updateFilesAfterUpload({'request' : JSON.stringify(
                {
                   "placeOfUpload" : this.placeOfUpload,
                   "placeOfUploadInstanceId" : this.placeOfUploadInstanceId,
                   "parentObjectId" : this.relatedRecordId,
                   "contentVersionIds" : contentVersionIds
                }
            )})
            .then( response => {
                try{
                    this.data = response.files;
                }catch(err){
                    alert('JS Error in Server callback :: BsFileUploadForFlows :: handleUploadFinished');
                }
            })
            .catch( error => {
                alert('Server Error :: BsFileUploadForFlows :: handleUploadFinished :: apexMethod => updateFilesAfterUpload');
                console.error(error);
            })
            */
        }catch(err){
            alert('JS Error :: BsFileUploadForFlows :: handleUploadFinished')
            console.error(err)
        }
    }

    handleDeleteIcon(event){
        try{
           // this.isLoading = true;
            let contentDocumentId = event.detail.contentDocumentId;
            let sourceType = event.detail.sourceType;

            let data = [... this.data];
            let contentDocumentIds = [... this.contentDocumentIds];
            console.log('contentDocumentId', contentDocumentId);
console.log('data 1', JSON.stringify(data));
console.log('contentDocumentIds 1', JSON.stringify(contentDocumentIds));
            let dataTemp = data.filter( e => {
                return e.documentId !== contentDocumentId;
            });

            let contentDocumentIdsTemp = contentDocumentIds.filter( e => {
                return e !== contentDocumentId;
            });
            console.log('data 2', JSON.stringify(dataTemp));
            console.log('contentDocumentIds 2', JSON.stringify(contentDocumentIdsTemp));
            this.data = dataTemp;
            this.contentDocumentIds = contentDocumentIdsTemp;

           // this.isLoading = false;
            /*
            deleteFiles({'request' : JSON.stringify(
                {
                    "placeOfUpload" : this.placeOfUpload,
                   "parentObjectId" : this.relatedRecordId,
                   "contentDocumentIds" : [contentDocumentId]
                }
            )})
            .then( response => {
                try{
                    this.data = response.files;
                    this.isLoading = false;
                }catch(err){
                    alert('JS Error in Server callback ::  :: handleDeleteIcon');
                    this.isLoading = false;
                }
            })
            .catch( error => {
                alert('Server Error :: lwcFileUploadForEmailPreview :: handleDeleteIcon :: apexMethod => deleteFiles');
                console.error(error);
                this.isLoading = false;
            })
            */
        }catch(err){
            alert('JS Error :: lwcFileUploadForEmailPreview :: handleDeleteIcon')
            console.error(err);
            this.isLoading = false;
        }
    }

    get
    showTable(){
        try{
            if(this.data && Array.isArray(this.data) && this.data.length > 0){
                return true;
            }

            return false;
        }catch(err){
            alert('JS Error :: lwcFileUploadForEmailPreview :: showTable')
            console.error(err)
        }
    }

    get
    isDisabled(){
        try{
            if(this.data.length >= this.maxFileUploads){
                return true;
            }

            return false;
        }catch(err){
            alert('JS Error :: lwcFileUploadForEmailPreview :: isDisabled')
            console.error(err)
        }
    }
}