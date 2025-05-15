import { LightningElement, track, api } from 'lwc';
import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent
} from "lightning/flowSupport";
import ToastContainer from 'lightning/toastContainer';
import saveFiles from '@salesforce/apex/FileUploadController.saveFiles';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';




export default class ModalPopupLWC extends LightningElement {

    @api test;
    @api contentIds = [];
    @api myVal;
    @api subValue;
    @api selectedRecords = [];
    @api selectedRecordsTo = [];
    @api selectedRecordsToOutput = [];
    @api selectedRecordsCCOutput = [];
    @api selectedRecordsCC = [];
    @api selectedRecordsOutput = [];
    @api availableActions = [];
    @api conIds = [];
    @track fileList = [];

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = true;

    connectedCallback() {
        console.log('opop', JSON.stringify(this.selectedRecords));
        this.selectedRecordsTo = this.selectedRecords;
        this.selectedRecordsToOutput = this.selectedRecords;
    }
    subChange(event) {
        this.subValue = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('subValue', this.subValue));

    }
    onToChange(event) {
        console.log('ere', JSON.stringify(event.detail.selRecords));
        this.selectedRecordsToOutput = event.detail.selRecords;
        console.log('qqq', JSON.stringify(this.selectedRecordsToOutput));

    }
    onCCChange(event) {
        this.selectedRecordsCCOutput = event.detail.selRecords;

    }

    onFileChange(event) {
        console.log('contentIds', JSON.stringify(event.detail.selRecords));
        this.contentIds = event.detail.contentDocumentIds;
        console.log('contentIds', JSON.stringify(this.contentIds));

    }

    handleChange(event) {
        this.myVal = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('myVal', this.myVal));

    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }


    openModal() {
        // to open modal set isModalOpen tarck value as true

        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        location.reload();
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        if (this.availableActions.find((action) => action === "NEXT")) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-right';
    }
    handleFileChange(event) {
        const fileInput = event.target;
        if (fileInput.files.length > 0) {
            for (let i = 0; i < fileInput.files.length; i++) {
                this.fileList.push({
                    id: this.generateId(),
                    name: fileInput.files[i].name
                });
                // Call the Apex method to save the file
                console.log('ttststs');
                saveFiles({ fileName: file.name, base64Data: file })
                    .then(result => {
                        console.log('srfsfy');
                        // Handle success
                    })
                    .catch(error => {
                        console.log('err', error);
                        // Handle errors
                    });
            }
            // You can also upload the files to a server here if needed
        }
    }

    generateId() {
        return '_' + Math.random().toString(36).substr(2, 9);
    }
}