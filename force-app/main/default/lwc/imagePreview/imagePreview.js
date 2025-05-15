import { LightningElement,api } from 'lwc';

export default class ImagePreview extends LightningElement {

    openPreview=false;
    imageUrl='';
    pdfUrl='';
    fileData;
    
    @api
    get attachmentData(){
        return this.imageData;
    }

    set attachmentData(value){
        console.log('value in Image', JSON.stringify(value));
        this.fileData=value;
        this.imageUrl='/sfc/servlet.shepherd/version/download/'+value.VersionId;
    }

    get isImage() {
        const imageTypes = ['PNG', 'JPG', 'JPEG', 'GIF'];
        return imageTypes.includes(this.fileData?.Type.toUpperCase());
    }
    
    get fileUrl() {
        return `/sfc/servlet.shepherd/document/download/${this.fileData.ContentDocumentId}`;
    }
    

    showPreview(){
        this.openPreview=true;
    }
    closePreview(){
        this.openPreview=false;
    }

    handleDownload(){
        window.open(this.imageUrl, '_blank');
    }

}