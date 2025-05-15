import { LightningElement, api } from 'lwc';
import uploadFileToImanage from '@salesforce/apex/IManageProxyController.uploadToIManage';

const ACCESS_TOKEN = 'PiHulrw3XmrgAiid+gMjDgPdKIpYRC25MtpnPlTk/MGmA8Kt/f6Ambzajg2kI8kf';

export default class LwcImanageFileUpload extends LightningElement {
    @api recordId;

    openFileDialog() {
        try{
            console.log('Called openFileDialog');
            let element = this.template.querySelectorAll('.fileInput');
            element[0].click();
        }catch(err){
            alert('JS Error ::  :: openFileDialog')
            this.handleAllErrorTypes(err);
        }
    }

    handleFileChange(event) {
        try{
            console.log('Called handleFileChange');

            const file = event.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onloadend = () => {

                try{
                    const base64 = reader.result.split(',')[1]; // strip metadata
                    uploadFileToImanage({
                        fileName: file.name,
                        base64Data: base64,
                        folderId: 'ACTIVE!1453263', // replace with actual folder ID
                        libraryId: 'ACTIVE'     // replace with actual library/ workspace ID
                    })
                    .then(result => {
                        console.log('Upload successful:', result);
                    })
                    .catch(error => {
                        console.error('Upload failed:', error);
                    });

                }catch(err){
                    alert('JS Error ::  :: handleFileChange :: onloadend')
                    this.handleAllErrorTypes(err);
                }
            };
            reader.readAsDataURL(file);

        }catch(err){
            alert('JS Error ::  :: handleFileChange')
            this.handleAllErrorTypes(err);
        }
    }

    handleAllErrorTypes(err){
        try{
            console.error(err);
            console.error( JSON.stringify(err) );
            console.error( this.serializeError(err) );
        }catch(err){
            alert('JS Error ::  :: handleAllErrorTypes')
            console.error(err)
        }
     }

     serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
           // ...error
        });
    }
      
}