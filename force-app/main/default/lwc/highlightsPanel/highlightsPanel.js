import { LightningElement, wire, track, api } from 'lwc';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getFieldSetData from '@salesforce/apex/layoutUtilities.getFieldSetData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HighlightsPanel extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api readOnly = false;
    @api numberOfColumns = 3;
    @api headerField;
    @api subHeaderField;
    @track headerFields = [];
    @api cssLibrary;
    @api fieldSetName;

    editMode = false;  // Variable to control edit mode
    @track fieldSetData = [];
    error;
    @track recordHeader;
    recordSubHeader;
    isLoading = false;
    showTaskButtons = false;
   
    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$headerFields',
    })
    recordData;
    
    // Fetch the object information to get the object logo
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({ error, data }) {
        console.log('objectApiName :'+this.objectApiName);
        if (data) {
            this.logoUrl = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    @wire(getFieldSetData, {
        objectName: '$objectApiName',
        fieldSetName: '$fieldSetName',
        recordId: '$recordId',
        headerField: '$headerField',
        subHeaderField: '$subHeaderField'
    })
    wiredFieldSetData({ error, data }) {
        try {
            if (data && data.fieldSetData && data.fieldSetData.length > 0) {

                console.group(
                    "%cHighlight Panel Header Data",
                    "background-color:darkgrey; color: #ffffff ; font-weight: bold ; padding: 4px ;"
                );
                console.log(
                    "%c" + JSON.stringify(data),
                    "display: inline-block ; border: 3px solid grey ; border-radius: 7px ; " +
                    "padding: 10px ; margin: 20px ;"
                );

                console.groupEnd();

                this.recordHeader = data.headerValue;
                this.recordSubHeader = data.subHeaderValue;
                let fieldSetDataTemp = JSON.parse(JSON.stringify(data.fieldSetData));
                let fieldSetData = fieldSetDataTemp.forEach(field => {
                    field.isEditableCss = (field.isEditable && !this.readOnly ? '' : 'hiddenVisibility');
                });
                this.fieldSetData = fieldSetDataTemp;

            } if(data.showTaskButtons){
                console.log('showTaskButtons :'+data.showTaskButtons);
                    this.showTaskButtons = data.showTaskButtons;
                }
                else if (error) {
                this.fieldSetData = [];
                console.log(error);
            }
        } catch (err) {
            console.group(
                "%cError",
                "background-color:darkgrey; color:rgb(216, 38, 38) ; font-weight: bold ; padding: 4px ;"
            );
            console.log(
                "%c" + err,
                "display: inline-block ; border: 3px solid red ; border-radius: 7px ; " +
                "padding: 10px ; margin: 20px ;"
            );

            console.groupEnd();
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

    handleClose() {
        try {

            let fieldSetData = this.fieldSetData;
            fieldSetData.forEach(field => {
                field.editMode = false;
            });

            this.editMode = false;

            this.fieldSetData = fieldSetData;

            this.isLoading = false;
        } catch (err) {
            console.group(
                "%cError",
                "background-color:darkgrey; color:rgb(216, 38, 38) ; font-weight: bold ; padding: 4px ;"
            );
            console.log(
                "%c" + err,
                "display: inline-block ; border: 3px solid red ; border-radius: 7px ; " +
                "padding: 10px ; margin: 20px ;"
            );

            console.groupEnd();
        }
    }

    matterchangedName = '';
    handleSave() {
        this.isLoading = true;
        try {
            const inputFields = this.template.querySelectorAll('lightning-input-field');
            const fields = {};
            inputFields.forEach(inputField => {
                fields[inputField.fieldName] = inputField.value;
                if(inputField.fieldName === 'Name') {
                    this.matterchangedName = inputField.value;
                }
            });

            this.template.querySelector('lightning-record-edit-form').submit(fields);

        } catch (err) {
            console.group(
                "%cError",
                "background-color:darkgrey; color:rgb(216, 38, 38) ; font-weight: bold ; padding: 4px ;"
            );
            console.log(
                "%c" + err,
                "display: inline-block ; border: 3px solid red ; border-radius: 7px ; " +
                "padding: 10px ; margin: 20px ;"
            );

            console.groupEnd();
            this.isLoading = false;
        }
    }

    handleSuccess() {
        try {
            this.recordHeader = this.matterchangedName;
            this.showToast('Success', 'success', 'The changes have been applied successfully.');
            this.handleClose();
            this.isLoading = false;
            console.group(
                "%cSuccess",
                "background-color:darkgrey; color: green; font-weight: bold ; padding: 4px ;"
            );
            console.log(
                "%c" + 'Successfully applied the changes',
                "display: inline-block ; border: 3px solid green ; border-radius: 7px ; " +
                "padding: 10px ; margin: 20px ;"
            );

            console.groupEnd();
        } catch (err) {
            console.group(
                "%cError",
                "background-color:darkgrey; color:rgb(216, 38, 38) ; font-weight: bold ; padding: 4px ;"
            );
            console.log(
                "%c" + err,
                "display: inline-block ; border: 3px solid red ; border-radius: 7px ; " +
                "padding: 10px ; margin: 20px ;"
            );

            console.groupEnd();
        }
    }

    handleError(event) {
        try {
            const errorDetails = event.detail;
            console.group(
                "%cError",
                "background-color:darkgrey; color:rgb(216, 38, 38) ; font-weight: bold ; padding: 4px ;"
            );
            console.log(
                "%c" + errorDetails,
                "display: inline-block ; border: 3px solid red ; border-radius: 7px ; " +
                "padding: 10px ; margin: 20px ;"
            );

            console.groupEnd();

            // Display a custom error message to the user (optional)
            console.log(JSON.stringify(errorDetails));
            const errorMessage = this.extractErrorMessage(errorDetails);
            
            this.showToast('Error', 'error', errorMessage); // 'Record not updated'
            this.isLoading = false;
        } catch (err) {
            console.group(
                "%cError",
                "background-color:darkgrey; color:rgb(216, 38, 38) ; font-weight: bold ; padding: 4px ;"
            );
            console.log(
                "%c" + err,
                "display: inline-block ; border: 3px solid red ; border-radius: 7px ; " +
                "padding: 10px ; margin: 20px ;"
            );

            console.groupEnd();
        }
    }


    handleEdit(event) {
        try {
            const fieldApiName = event?.currentTarget?.dataset?.fieldapiname;
            let selectedFieldIsEditable = true;
            let fieldSetData = JSON.parse(JSON.stringify(this.fieldSetData));
            fieldSetData.forEach(field => {
                field.editMode = field.isEditable;

                if (fieldApiName) {
                    if (fieldApiName === field.fieldApiName) {
                        selectedFieldIsEditable = field.isEditable;
                    }
                }
            });

            if (!selectedFieldIsEditable) {
                return;
            }
            this.editMode = true;
            this.fieldSetData = fieldSetData;

            window.setTimeout(() => {
                try {
                    const inputFields = this.template.querySelectorAll('lightning-input-field');

                    inputFields.forEach(inputField => {
                        if (inputField.fieldName === fieldApiName) {
                            inputField.focus();
                        }
                    });
                } catch (err) {
                    console.log(err);
                }
            }, 500);
        } catch (err) {
            console.log(err);
        }
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }
    
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

}