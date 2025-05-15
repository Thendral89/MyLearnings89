import { LightningElement, api, wire, track } from 'lwc';
import getFieldSetDataAccordion from '@salesforce/apex/layoutUtilities.getFieldSetDataAccordion';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DetailsPanel extends LightningElement {
    @api objectApiName;
    @api fieldSetsName;  // Configurable: API name of the field set
    @api recordId;
    @api noDocketFooter = false;

    @track editMode = false;
    @track accordionToFields = [];
    error;
    isLoading = false;
    activeSections = [];

    connectedCallback() {
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

    @wire(getFieldSetDataAccordion, {
        objectName: '$objectApiName',
        fieldSetsName: '$fieldSetsName',
        recordId: '$recordId'
    })
    wiredFieldSetData({ error, data }) {
        if ( data ) {
            let accordionToFields = JSON.parse( JSON.stringify( data ) );
            let activeSections = [];
            accordionToFields.forEach( e => {
                activeSections.push(e.accordionName);
                e.fieldSetData.forEach(field => {
                    field.isEditableCss = (field.isEditable ? '' : 'hiddenVisibility');
                });
            });

            this.accordionToFields = accordionToFields;

            this.activeSections = activeSections;
            this.error = undefined;

            this.addStyleToAccordion();
        } else if (error) {
            this.error = error;
            this.fieldSetData = [];
        }
    }

    addStyleToAccordion(){
       try{
            window.setTimeout( () => {
                let style = document.createElement('style');
                style.innerText += '.newStyleForAccordionSection .slds-accordion__summary-content{font-size: 1rem; font-weight: bold;}';
                let allTables = this.template.querySelectorAll('.accordionTitle');
                allTables.forEach(e => {
                    e.appendChild(style);
                });  
            }, 100);
       }catch(err){
           console.error(err);
       }
    }

    handleEdit(event){
       try{

        if(this.editMode) return;

            const fieldApiName = event?.currentTarget?.dataset?.fieldapiname;
            let selectedFieldIsEditable = true;
           
            console.log('accordionToFields 1', JSON.stringify(this.accordionToFields));

            let accordionToFields = JSON.parse(JSON.stringify(this.accordionToFields));
           accordionToFields.forEach(accordion => {
               accordion.fieldSetData.forEach(field => {
                   field.editMode = field.isEditable;

                   if(fieldApiName){
                       if(fieldApiName === field.fieldApiName){
                            selectedFieldIsEditable = field.isEditable;
                       }
                   }
               });
               
           });

           if(!selectedFieldIsEditable){
            return;
           }


           this.editMode = true;

           this.accordionToFields = accordionToFields;

           window.setTimeout( () => {
            try{
                const inputFields = this.template.querySelectorAll('lightning-input-field');

                    inputFields.forEach(inputField => {
                        if(inputField.fieldName === fieldApiName){
                            inputField.focus();
                        }
                        
                    });
                }catch(err){
                    console.error(err);
                }
            }, 500);
       }catch(err){
           console.error(err);
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

            let accordionToFields = this.accordionToFields;
           accordionToFields.forEach(accordion => {
               accordion.fieldSetData.forEach(field => {
                   field.editMode = false;
               });
               
           });

           this.editMode = false;

           this.accordionToFields = accordionToFields;

            this.isLoading = false;
        }catch(err){
            console.error(err);
        }
     }

     handleSubmit(event){
        try{
            this.isLoading = true;
        }catch(err){
            console.error(err);
        }
     }

    handleSuccess(){
       try{
           console.log('Handle success');
           this.showToast('Success', 'success', 'The changes have been applied successfully.');
           this.handleClose();
            this.isLoading = false;
       }catch(err){
           console.error(err);
       }
    }

    get
    footerCss(){
    try{
        return (this.noDocketFooter) ? 'slds-m-top_medium slds-align_absolute-center' : 'slds-docked-form-footer slds-m-top_medium slds-align_absolute-center';
    }catch(err){
        alert('JS Error ::  :: footerCss')
        console.error(err)
    }
    }

    handleError(event){
        try{
            const errorDetails = event.detail;
            console.error('Error occurred while saving the record:', errorDetails);
            const errorMessage = this.extractErrorMessage(errorDetails);

            this.showToast('Error', 'error', errorMessage);
            this.isLoading = false;
        }catch(err){
            console.error(err);
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