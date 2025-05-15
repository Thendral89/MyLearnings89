import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createFeedItem from '@salesforce/apex/CustomChatterUtility.createFeedItem';
import { publish, MessageContext,subscribe } from 'lightning/messageService';
import CUSTOM_CHATTER_COMPONENT_CHANNEL from '@salesforce/messageChannel/Custom_Chatter_Component__c';
export default class PostComponent extends LightningElement {
    openFileUploader = false;
    @track uploadedFiles;
    @api currentRecordId;
    @track showRichText = false;
    @track richTextValue = '';
    @api type = '';
    @api showShareButton = false;
    @api placeholder; // This will receive the placeholder text from parent
    property;
    @track isActive = false;

    formats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'clean',
    ];

    connectedCallback(){    
        subscribe(this.messageContext, CUSTOM_CHATTER_COMPONENT_CHANNEL, (message) => {
            console.log('isActive ', this.isActive+' message received :', JSON.stringify(message) );
            if(message && message?.detail?.type === 'Add File' && this.isActive){
                this.handleSelectedFiles(message);
            }

        });
    }
    handleAddimage() {
        this.property = 'Add Image';
        this.openFileUploader = true;
        this.isActive = true;
    }
    handleAttachFile(){
        this.property = 'Attach File';
        this.openFileUploader = true;
        this.isActive = true;
    }
    get inputPlaceholder() {
        return this.placeholder || 'Share an update...'; 
    }

    get isShareDisable() {
        // Remove HTML tags, decode HTML entities, and trim whitespace
        const plainText = this.richTextValue
            ?.replace(/<[^>]*>/g, '') // Remove HTML tags
            ?.replace(/&nbsp;/g, ' ') // Replace &nbsp; with space
            ?.trim(); // Remove leading/trailing whitespace
        return !plainText;
    }

    @wire(MessageContext)
    messageContext;

    @api handleInputClick() {
        this.showRichText = true;
        this.isActive = true;
        
    }
    
    handleChange(e){
        this.richTextValue = e.target.value;
        console.log('rich text value ', this.richTextValue);
         
        const plainText = this.richTextValue
            ?.replace(/<[^>]*>/g, '') // Remove HTML tags
            ?.replace(/&nbsp;/g, ' ') // Replace &nbsp; with space
            ?.trim();
        console.log('palin text value ', plainText);
    }
    handleAddUser() {
        const inputRichText = this.template.querySelector(
            'lightning-input-rich-text'
        );
        console.log('inputRichText: ',inputRichText);
        
        let format = inputRichText.getFormat();
    }
    handleAddEmoji(){
        console.log('add emoji clicked');
        
    }
    handleInputClick(){
        this.showRichText = true;
    }
    handleSelectedFiles(event) {
        console.log('event.detail ', JSON.stringify(event.detail));
        
        this.openFileUploader = false;
        const { type, data } = event.detail;
        const selectedFiles = data;
        // Create a new array combining existing and new files
        const allFiles = [...(this.uploadedFiles || []), ...selectedFiles];
        
        // Remove duplicates based on file name and size
        this.uploadedFiles = allFiles.filter((file, index, self) =>
            index === self.findIndex((f) => (
                f.Name === file.Name && f.Size === file.Size && f.Id === file.Id
            ))
        );
    }
    handleShare(){
        if(this.uploadedFiles.length > 0){
        console.log('uploadedFiles ', JSON.stringify(this.uploadedFiles));
        
        let uploadedFileMap = this.uploadedFiles.map(file => {
            return {Id:file.Id,Name:file.Name}
            }
        );
        
        console.log('share clicked currentRecordId ', this.currentRecordId,
            'richTextValue ', this.richTextValue,
            'type ', this.type,
            'uploadedFileMap ', JSON.stringify(uploadedFileMap)
        );
        
        if(this.type === 'FeedItem' ){
            if(this.currentRecordId && this.richTextValue && uploadedFileMap.length > 0){
                    createFeedItem({Body:this.richTextValue,ParentId:this.currentRecordId,VersionMap:uploadedFileMap})
                    .then(result=>{
                        console.log('result ', result);
                        this.showToast('Success','success','Post shared successfully');
                        const message = {
                            type: 'Refresh',
                            data: ''
                        }
                        publish(this.messageContext, CUSTOM_CHATTER_COMPONENT_CHANNEL,message);
                    })
                    .catch(error=>{
                        console.log('error ',error.body.message);
                        this.showToast('Error','Error',error.body.message);
                    });
                    this.handleClose();
            }
        }else if(this.type == 'FeedComment'){
            let value = this.richTextValue ? this.richTextValue : '';
                const event = new CustomEvent("createfeedcomment", { detail: value});
                this.dispatchEvent(event);
                this.handleClose();

            }
}
    }
    handleClose(){
        this.showRichText = false;
        this.isActive = false;
        this.uploadedFiles = [];
    }
    handleCloseFileModal(){
        this.openFileUploader = false;
    }
    showToast(title,variant,message){ 
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }
    // Parent component handler
    // handleFileAdded(event) {
    //     const { file, allFiles } = event.detail;
    //     this.uploadedFiles=event.detail.allFiles;
    //     console.log('New file added:', file.filename);
    //     console.log('All files:', this.uploadedFiles.length);
    //     // Handle the file data as needed
    // }

    // handleFileRemoved(event) {
    //     const { filename, allFiles } = event.detail;
    //     this.uploadedFiles = event.detail.allFiles;
    //     console.log('File removed:', filename);
    //     console.log('Remaining files:', allFiles);
    // }
    handleRemoveFile(event){
        console.log(event.target);
        const fileId = event.target.dataset.id;
        console.log('fileId out of filter', fileId);
        
        this.uploadedFiles = this.uploadedFiles.filter(file => 
            file.Id !== fileId)
        console.log('uploadedFiles ', JSON.stringify(this.uploadedFiles));
    }
}