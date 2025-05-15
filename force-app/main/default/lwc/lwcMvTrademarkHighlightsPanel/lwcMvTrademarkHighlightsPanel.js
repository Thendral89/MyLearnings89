import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getFieldSetData from '@salesforce/apex/FieldSetController.getFieldSetData';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LwcMvTrademarkHighlightsPanel extends LightningElement {
    @api objectApiName;
    @api fieldSetByImage;
    @api fieldSetName;  // Configurable: API name of the field set
    @api recordId;

    disableAutoDropdown = true;

    @api readOnly = false;

    nameField = '';
    fieldList = [];

    @track fieldSetData = [];
    @track fieldSetData2Column = [];
    error;

    isLoading = false;
    editMode = false;

    docketNumber;
    recordName;         // Holds the record name to display in the header
    logoUrl;            // Holds the logo URL for the object
    objectLabel;

    summary;

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

    
    // Fetch the object information to get the object logo
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({ error, data }) {
        if (data) {
            this.logoUrl = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    @wire(getFieldSetData, {
        objectName: '$objectApiName',
        fieldSetName: '$fieldSetName',
        recordId: '$recordId'
    })
    wiredFieldSetData({ error, data }) {
        try{
        if (data && data.fieldSetData && data.fieldSetData.length > 0) {
            let fieldSetDataTemp = JSON.parse( JSON.stringify( data.fieldSetData ) );
            let fieldSetData = fieldSetDataTemp.forEach(field => {
                field.isEditableCss = (field.isEditable && !this.readOnly ? '' : 'hiddenVisibility');
            });
            this.fieldSetData = fieldSetDataTemp;

            console.log('this.fieldSetData highlightpanel ' + JSON.stringify(this.fieldSetData) );

            this.recordName = data.recordName;
            this.docketNumber = data.docketNumber;
            this.objectLabel = data.objectLabel;
            this.error = undefined;
            
        } else if (error) {
            this.error = error;
            this.fieldSetData = [];
        }
    }catch(err){
        alert('JS Error :: wiredFieldSetData');
        console.error(this.serializeError(err))
    }
    }

    @wire(getFieldSetData, {
        objectName: '$objectApiName',
        fieldSetName: '$fieldSetByImage',
        recordId: '$recordId'
    })
    wiredFieldSetData2Column({ error, data }) {
        try{
        if (data && data.fieldSetData && data.fieldSetData.length > 0) {
            let fieldSetDataTemp = JSON.parse( JSON.stringify( data.fieldSetData ) );
            let fieldSetData = fieldSetDataTemp.forEach(field => {
                field.isEditableCss = (field.isEditable && !this.readOnly ? '' : 'hiddenVisibility');
            });
            this.fieldSetData2Column = fieldSetDataTemp;

            console.log('this.fieldSetData2Column highlightpanel ' + JSON.stringify(this.fieldSetData) );

            this.recordName = data.recordName;
            this.docketNumber = data.docketNumber;
            this.objectLabel = data.objectLabel;
            this.error = undefined;
            
        } else if (error) {
            this.error = error;
            this.fieldSetData2Column = [];
        }
    }catch(err){
        alert('JS Error :: wiredFieldSetData2Column');
        console.error(this.serializeError(err))
    }
    }

    handleEdit(event){
        try{
        if(this.readOnly) return;
        
         console.log('Handle edit called')
 
         if(this.editMode) return;
 
             const fieldApiName = event?.currentTarget?.dataset?.fieldapiname;
             let selectedFieldIsEditable = true;
            
             console.log('accordionToFields 1', JSON.stringify(this.accordionToFields));
 
             let fieldSetData = JSON.parse(JSON.stringify(this.fieldSetData));
            fieldSetData.forEach(field => {
                field.editMode = field.isEditable;

                if(fieldApiName){
                    if(fieldApiName === field.fieldApiName){
                            selectedFieldIsEditable = field.isEditable;
                    }
                }
            });
 
            console.log('selectedFieldIsEditable', selectedFieldIsEditable)
 
            console.log('fieldSetData 2', JSON.stringify(this.fieldSetData));
            if(!selectedFieldIsEditable){
             return;
            }
 
            console.log('Yes is editable');
 
            this.editMode = true;
 
            this.fieldSetData = fieldSetData;
 
            window.setTimeout( () => {
             try{
                 const inputFields = this.template.querySelectorAll('lightning-input-field');
 
                     inputFields.forEach(inputField => {
                         if(inputField.fieldName === fieldApiName){
                             inputField.focus();
                         }
                         
                     });
                 }catch(err){
                     alert('JS Error :: lwcMvDetailsLayout :: handleEdit :: setTimeout')
                 }
             }, 500);
        }catch(err){
            alert('JS Error :: lwcMvDetailsLayout :: handleEdit')
            console.error(this.serializeError(err))
        }
     }

     handleEditByImage(event){
        try{
        if(this.readOnly) return;
        
         console.log('Handle edit called')
 
         if(this.editMode) return;
 
             const fieldApiName = event?.currentTarget?.dataset?.fieldapiname;
             let selectedFieldIsEditable = true;
            
             console.log('accordionToFields 1', JSON.stringify(this.accordionToFields));
 
             let fieldSetData2Column = JSON.parse(JSON.stringify(this.fieldSetData2Column));
            fieldSetData2Column.forEach(field => {
                field.editMode = field.isEditable;

                if(fieldApiName){
                    if(fieldApiName === field.fieldApiName){
                            selectedFieldIsEditable = field.isEditable;
                    }
                }
            });
 
            console.log('selectedFieldIsEditable', selectedFieldIsEditable)
 
            console.log('fieldSetData2Column 2', JSON.stringify(this.fieldSetData2Column));
            if(!selectedFieldIsEditable){
             return;
            }
 
            console.log('Yes is editable');
 
            this.editMode = true;
 
            this.fieldSetData2Column = fieldSetData2Column;
 
            window.setTimeout( () => {
             try{
                 const inputFields = this.template.querySelectorAll('lightning-input-field');
 
                     inputFields.forEach(inputField => {
                         if(inputField.fieldName === fieldApiName){
                             inputField.focus();
                         }
                         
                     });
                 }catch(err){
                     alert('JS Error :: lwcMvDetailsLayout :: handleEdit :: setTimeout')
                 }
             }, 500);
        }catch(err){
            alert('JS Error :: lwcMvDetailsLayout :: handleEdit')
            console.error(this.serializeError(err))
        }
     }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

        this.handleClose();
     }

     handleClose(){
        try{

            let fieldSetData = this.fieldSetData;
           fieldSetData.forEach(field => {
                field.editMode = false;
           });

           this.editMode = false;

           this.fieldSetData = fieldSetData;

            this.isLoading = false;
        }catch(err){
            alert('JS Error :: lwcMvDetailsLayout :: handleClose')
            console.error(err)
        }
     }

     handleSubmit(event){
        try{
            this.isLoading = true;
        }catch(err){
            alert('JS Error ::  :: handleSubmit')
            console.error(err)
        }
     }

    handleSuccess(){
       try{
           console.log('Handle success');
           this.showToast('Success', 'success', 'Record updated');
           this.handleClose();
            this.isLoading = false;
       }catch(err){
           alert('JS Error ::  :: handleSuccess')
           console.error(err)
       }
    }

    handleError(event){
        try{
           // alert('Handle Error');
            const errorDetails = event.detail;
            console.error('Error occurred while saving the record:', errorDetails);

            // Display a custom error message to the user (optional)
            const errorMessage = this.extractErrorMessage(errorDetails);

            this.showToast('Error', 'error', errorMessage); // 'Record not updated'
            this.isLoading = false;
        }catch(err){
            alert('JS Error ::  :: handleError')
            console.error(err)
        }
     }

    get
    textHeading(){
       try{
           return !this.docketNumber ? 'slds-text-heading_large' : 'textHeadingWithSubTitle slds-text-heading_large';
       }catch(err){
           alert('JS Error ::  :: textHeading')
           console.error(err)
       }
    }

    /*
    handleBlur(event){
       try{
           console.log('Handle blur');
           window.setTimeout( () => {
            try{
                const form = this.template.querySelector('lightning-record-edit-form');
                if (form) {
                    const fields = {};
                    const inputFields = this.template.querySelectorAll('lightning-input-field');
                    
                    let fieldSetDataMap = {};
                    let fieldSetData = this.fieldSetData;
                    fieldSetData.forEach( each => {
                        fieldSetDataMap[each.fieldApiName] = each;
                    });

                    console.log('inputFields length', inputFields.length);

                    inputFields.forEach(inputField => {
                        const fieldApiName = inputField.fieldName;
                        const value = inputField.value;
                        const fieldDetail = fieldSetDataMap[fieldApiName];
                        if(! fieldDetail){
                            return;
                        }
                        
                        if(! fieldDetail.isEditable){
                            return;
                        }
                        fieldDetail.editMode = false;
                        fieldDetail.value = value;

                        fields[fieldApiName] = value;

                        inputField.removeEventListener('focusout');
                    });
     
                    console.log('Reach fields ', JSON.stringify(fields));
                  

                  console.log('Final ', JSON.stringify(fieldSetData))
                  this.fieldSetData = fieldSetData;
                    console.log('Final  this.fieldSetData', JSON.stringify(this.fieldSetData));
                  form.submit( fields );
                } else {
                    console.error('lightning-record-edit-form not found');
                }
            }catch(err){
                alert('JS Error :: lwcMvHighlightsPanel :: handleBlur :: setTimeout');
                console.error( err );
                console.error( this.serializeError( err ) );
            }
        }, 500);
       }catch(err){
           alert('JS Error :: saveData :: handleBlur')
           console.error( this.serializeError( err ) );
       }
    }
*/

    handleSave(){
       try{
        const inputFields = this.template.querySelectorAll('lightning-input-field');
 
        const fields = {};

        inputFields.forEach(inputField => {
            fields[inputField.fieldName] = inputField.value;
        });

        this.template.querySelector('lightning-record-edit-form').submit(fields);
       }catch(err){
           alert('JS Error ::  :: handleSave');
           console.error(err)
       }
    }

    // Helper method to extract error messages
    extractErrorMessage(errorDetails) {
        try{
        if (errorDetails && errorDetails.body) {
            if (errorDetails.body.output && errorDetails.body.output.errors.length > 0) {
                return errorDetails.body.output.errors[0].message; // Record-level error
            } else if (errorDetails.body.message) {
                return errorDetails.body.message; // Top-level error
            }
        }
        return errorDetails.detail;
        }catch(err){
            alert('JS Error ::  :: extractErrorMessage');
            console.error(err);
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