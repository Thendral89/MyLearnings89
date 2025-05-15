import { LightningElement,api,wire,track } from 'lwc';
import fileUploadFuture from '@salesforce/apex/cmpAPiManagFileInvockableCtrl.FileUpload';
export default class ApFileupload extends LightningElement {
@api fileContent;
fileExtension;

handleFileChange(event) {
    const file = event.target.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onloadend = () => {
            const result = reader.result;
            this.fileContent =file;
            const fileName = file.name;
            this.fileExtension = this.getFileExtension(fileName);

            this.uploadFile(fileName, this.fileExtension, this.fileContent);
        };
        reader.readAsDataURL(file);

    }
}

decodeFile(base64String) {
    const byteCharacters = atob(base64String); // Decode Base64 string to binary string
    const byteArrays = new Uint8Array(byteCharacters.length);

    // Convert binary string to an array of bytes
    for (let i = 0; i < byteCharacters.length; i++) {
        byteArrays[i] = byteCharacters.charCodeAt(i);
    }

    // Now decode the binary data into ISO-8859-1
    const decoder = new TextDecoder('ISO-8859-1');
    this.fileContent = decoder.decode(byteArrays);
}

getFileExtension(filename) {
return filename.split('.').pop().toLowerCase();
}
uploadFile(filename, extension, fileContent) {

    console.log('fileContent-', fileContent);
    console.log('filename-', filename);
    console.log('extension', extension);

    fileUploadFuture({ FileContent: fileContent, filename: filename, extension: extension })
        .then((result) => {
            // Handle the success result from Apex if needed
            console.log('File uploaded successfully!', result);
        })
        .catch((error) => {
            // Handle error from Apex call
            console.error('Error uploading file:', error);
        });
}

}