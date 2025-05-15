import { LightningElement, api, track } from 'lwc';
import imageFromMark from "@salesforce/apex/TrademarkImageController.fetchContentFromMark";

export default class LwcMvTrademarkImage extends LightningElement {
    @api recordId;
    @api objectApiName;

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            },
            {
                name: 'objectAPIName',
                type: 'String',
                value: 'Mark__c'
            }
        ];
    }
    
    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            // set behavior after a finished flow interview
        }
    }

    baseUrl = window.location.origin;
    contentId;

    connectedCallback(){
       try{
           this.fetchImageFromMark();
       }catch(err){
           alert('JS Error ::  :: connectedCallback')
           console.error(err)
       }
    }

    fetchImageFromMark(){
       try{
           imageFromMark({
            "recordId": this.recordId,
            "objectApiName": this.objectApiName
           })
           .then( response => {
               try{
                   this.contentId = response;
                   this.isLoading = false;
               }catch(err){
                   alert('JS Error in Server callback ::  :: fetchImageFromMark');
               }
           })
           .catch( error => {
               alert('Server Error ::  :: fetchImageFromMark :: apexMethod => imageFromMark');
               console.error(JSON.stringify(error));
           })
       }catch(err){
           alert('JS Error ::  :: fetchImageFromMark')
           console.error(err)
       }
    }

    get
    imageFound(){
       try{
           return (this.contentId) ? true : false;
       }catch(err){
           alert('JS Error ::  :: imageFound')
           console.error(err)
       }
    }

    get
    imageUrl(){
       try{
           return `${this.baseUrl}/sfc/servlet.shepherd/version/download/${this.contentId}`
       }catch(err){
           alert('JS Error ::  :: imageUrl')
           console.error(err)
       }
    }

    showFullImage = false;
    isLoading = true;

    handleImage(){
       try{
           this.showFullImage = true;
       }catch(err){
           alert('JS Error ::  :: handleImage')
           console.error(err)
       }
    }

    handleCancel(){
       try{
        this.showFullImage = false;
       }catch(err){
           alert('JS Error ::  :: handleCancel')
           console.error(err)
       }
    }

    handleSave(){
       try{
        this.showFullImage = false;
       }catch(err){
           alert('JS Error ::  :: handleSave')
           console.error(err)
       }
    }

    get acceptedFormats() {
        return ['.jpg','.jpeg', '.png'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }

    selectFile() {
        try{
        // Create an invisible file input dynamically
        let fileInput = document.createElement('input');
        fileInput.type = 'file';
        fileInput.accept = '.jpg,.png,.jpeg'; // Allowed file types
        fileInput.style.display = 'none'; // Hide the file input
        document.body.appendChild(fileInput);

        // Listen for file selection
        fileInput.addEventListener('change', (event) => {
            this.handleFileSelection(event);
        });

        // Open the file picker dialog
        fileInput.click();
    }catch(err){
        alert('JS Error ::  :: handleReplace')
        console.error(err)
    }
    }

    handleFileSelection(event) {
        const file = event.target.files[0]; // Get the selected file
        if (file) {
            let reader = new FileReader();
            reader.onload = () => {
                let base64 = reader.result.split(',')[1]; // Extract Base64 content
                console.log('base64 base64 ', base64);
                this.uploadFile(file.name, base64);
            };
            reader.readAsDataURL(file);
        }
    }

    uploadFile(fileName, base64Data) {
        uploadFileApex({ fileName: fileName, base64Data: base64Data, recordId: this.recordId })
            .then(() => {
                console.log('File uploaded successfully');
            })
            .catch(error => {
                console.error('Error uploading file:', error);
            });
    }

    handleReplace(){
       try{
        console.log('handleReplace ');
    //    this.template.querySelector('.file-input').click();
        
        const fileUpload = this.template.querySelector('lightning-file-upload');

        if (fileUpload) {
            console.log('1', fileUpload);
            console.log('1', JSON.stringify(fileUpload));

            // const inputElement = fileUpload.querySelector('input');
            // console.log('inputElement ', inputElement);
            // inputElement.click();

            if (fileUpload) {
                // Simulate user interaction using a label trigger
                fileUpload.dispatchEvent(new MouseEvent('click', { bubbles: true }));
            }

            // Access the Shadow DOM
            const shadowRoot = fileUpload.shadowRoot;
            console.log('2', shadowRoot);
            if (shadowRoot) {
                console.log('3');
                const fileInput = shadowRoot.querySelector('input[type="file"]');
                console.log('4', fileInput);
                if (fileInput) {
                    console.log('5');
                    fileInput.click(); // Trigger the file selection dialog
                    console.log('6');
                }
            }
        }
       }catch(err){
           alert('JS Error ::  :: handleReplace')
           console.error(err)
       }
    }

    fileData;
}