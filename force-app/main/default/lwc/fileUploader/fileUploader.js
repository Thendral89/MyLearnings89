// fileUploader.js
import { LightningElement, api, track,wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CUSTOM_CHATTER_COMPONENT_CHANNEL from '@salesforce/messageChannel/Custom_Chatter_Component__c';
import saveFiles from '@salesforce/apex/CustomChatterUtility.saveFiles';

export default class FileUploader extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track uploadedFiles = []; // To keep track of all uploaded files
    @api property;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        console.log('recordId',this.recordId,'property',this.property);
    }

    get acceptedFormats(){
        console.log('property',this.property);
        if(this.property === 'Attach File'){
            return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt'];
        }else if(this.property === 'Add Image'){
            return ['.png', '.jpg', '.jpeg'];
        }
    }

    openFileInput() {
        const fileInput = this.template.querySelector('.fileInput');
        console.log('fileInput called',fileInput);
        fileInput.click();
    }


    // handleFileChange(event) {
    //     try {
    //         const files = event.target.files;
    //         if (!files || files.length === 0) return;
            
    //         this.isLoading = true;
    //         console.log('Files selected:', files.length);

    //         [...files].forEach(file => {
    //             // Check if file already exists
    //             const fileExists = this.uploadedFiles.some(f => 
    //                 f.filename === file.name && 
    //                 f.size === file.size
    //             );

    //             if (fileExists) {
    //                 console.log('File already exists:', file.name);
    //                 return; // Skip this file
    //             }

    //             console.log('Processing file:', file.name);
    //             const reader = new FileReader();

    //             reader.onload = (() => {
    //                 return (e) => {
    //                     try {
    //                         console.log('File read successfully');
    //                         const base64 = e.target.result.split(',')[1];
                            
    //                         const fileData = {
    //                             filename: file.name,
    //                             // base64: base64,
    //                             type: file.type,
    //                             size: file.size,
    //                             uploadedDate: new Date().toLocaleString()
    //                         };

    //                         // Add to uploaded files array
    //                         this.uploadedFiles = [...this.uploadedFiles, fileData];
    //                         console.log('Updated uploadedFiles:', JSON.stringify(this.uploadedFiles));

    //                     } catch (error) {
    //                         console.error('Error in onload:', error);
    //                     }
    //                 };
    //             })();

    //             reader.onerror = (() => {
    //                 return (error) => {
    //                     console.error('Error reading file:', error);
    //                     this.isLoading = false;
    //                 };
    //             })();

    //             // Read the file
    //             try {
    //                 reader.readAsDataURL(file);
    //             } catch (error) {
    //                 console.error('Error in readAsDataURL:', error);
    //             }
    //         });
            
    //         event.target.value = '';
    //         this.isLoading = false;
            
    //     } catch (error) {
    //         console.error('Main error handler:', error);
    //         this.isLoading = false;
    //     }
    // }

    // Method to remove a file
    async handleFileChange(event) {
        try {
            const files = event.target.files;
            if (!files || files.length === 0) return;
            
            const processedFiles = [];
    
            for (const file of Array.from(files)) {
                const fileData = await this.processFile(file);
                if (fileData) {
                    processedFiles.push(fileData);
                }
            }
    
            this.uploadedFiles = [...this.uploadedFiles, ...processedFiles];
            console.log('All files processed:', this.uploadedFiles.length);
            
            if (this.uploadedFiles.length > 0) {
                // Call apex to save files in database
                this.handleSaveFiles();
                
            }
    
        } catch (error) {
            console.error('Error:', error);
        } finally {
            this.isLoading = false;
        }
    }
    
    processFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            
            reader.onload = (e) => {
                const base64 = e.target.result.split(',')[1];
                resolve({
                    fileName: file.name,
                    base64: base64,
                    type: file.type,    
                    size: file.size,
                    uploadedDate: new Date().toLocaleString()
                });
            };
            
            reader.onerror = () => reject(new Error('File reading failed'));
            reader.readAsDataURL(file);
        });
    }

    @api
    removeFile(fileName) {
        this.uploadedFiles = this.uploadedFiles.filter(file => file.fileName !== fileName);
        
        // Dispatch event for file removal
        this.dispatchEvent(new CustomEvent('fileremoved', {
            detail: {
                fileName: fileName,
                allFiles: this.uploadedFiles
            }
        }));
    }

    // Method to clear all files
    @api
    clearAllFiles() {
        this.uploadedFiles = [];
        this.dispatchEvent(new CustomEvent('filescleared'));
    }

    // Get current files
    @api
    get currentFiles() {
        return this.uploadedFiles;
    }

    handleSaveFiles() {
        // isLoading = true;
        this.dispatchEvent(new CustomEvent('uploadstart'));
        console.log('handleSaveFiles called');
        if (this.uploadedFiles.length > 0) {
            console.log('Files to save:', this.uploadedFiles.length);
            const filesData = JSON.stringify(this.uploadedFiles);
            
            saveFiles({ filesData: filesData })
                .then(result => {
                    this.uploadedFiles=result;
                    console.log('Files saved successfully:', this.uploadedFiles);
                    const data = {
                        detail: {
                            type: 'Add File',
                            data: this.uploadedFiles
                        }
                    }
                    publish(this.messageContext, CUSTOM_CHATTER_COMPONENT_CHANNEL, data);
                })
                .catch(error => {
                    console.error('Error saving files:', error); 
                });
        } else {
            console.log('No files to save');
        }
    }
}