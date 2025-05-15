import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import checkFieldEditAccess from '@salesforce/apex/mvLawfirmUtilities.hadFieldEditAccess';
import checkRecordEditAccess from '@salesforce/apex/mvLawfirmUtilities.hasRecordEditAccess';

import REPORTED_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.Reported__c";

export default class MvDocketFields extends LightningElement {

    @api recordId;
    @api objectName;
    @api fieldName
    @api updateableFieldName;
    hasEditAccess = false;
    @api value;
    @track isEditable = false;
    @api isFormattedText = false;
    @api applyGreenTag = false;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [REPORTED_FIELD]
    })
    reportedToData;

    async connectedCallback(){
        try{
            let hasFieldEditAccess = await checkFieldEditAccess({
                 'objectName': this.objectName
                , 'fieldName': this.fieldName
            });

            let hasRecordEditAccess = await checkRecordEditAccess({
                'recordId': this.recordId
            });

            this.hasEditAccess = hasFieldEditAccess && hasRecordEditAccess;
        }catch(err){
            console.log('Error in wired reportedToData : ' + err);
        }
    }

    renderedCallback() {
        console.log('Reported Data : ' + JSON.stringify(this.reportedToData));
        if (this.isEditable) {
            this.removeExtraDateLabel();
        }
    }

    removeExtraDateLabel() {
        console.log('Called :: removeExtraDateLabel');
        const inputField = this.template.querySelector(`[data-field='${this.updateableFieldName}']`);
        console.log('Found inputField =>', inputField);
        if (inputField) {
            let style = document.createElement('style');
            style.innerText = 'div.slds-form-element__help { display: none; }';
            inputField.appendChild(style);
        }
    }

    handleEdit(event) {
        if(!this.hasEditAccess) return;

        this.isEditable = true;
        this.dispatchEvent(new CustomEvent('recordeditmode', {
            detail: {
                recordId: [this.recordId]
            }, bubbles: true, composed: true
        }));
    }

    handleSave(event) {
        if(!this.hasEditAccess) return;

        const inputFields = this.template.querySelectorAll('lightning-input-field');
        const fields = {};
        inputFields.forEach(inputField => {
            fields[inputField.fieldName] = inputField.value;
        });
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.isEditable = false;
    }

    handleSubmit(event) {
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
    }

    handleSuccess() {
        this.dispatchEvent(new CustomEvent('recordsuccess', {
            detail: {
                recordId: [this.recordId]
            }, bubbles: true, composed: true
        }));
    }

}