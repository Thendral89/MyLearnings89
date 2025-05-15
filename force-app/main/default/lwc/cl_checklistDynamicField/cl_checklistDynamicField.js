import { api, LightningElement } from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";

export default class Cl_checklistDynamicField extends LightningElement {
    @api fieldData;
    @api checklistInstanceItemId;
    @api disabled;
    @api isSecretary;
    @api isAttorney;
    @api isDoubleChecker;
    @api submitBySecretory;
    @api submitByAttorney;
    @api submitByDoubleChecker;

    get isText() {
        return this.fieldData && this.fieldData.type === 'STRING'
    }

    get isAmountField() {
        return this.fieldData?.apiName === 'Amount__c';
    }

    get isDate() {
        return this.fieldData && this.fieldData.type === 'DATE'
    }

    get isNumber() {
        return this.fieldData && this.fieldData.type === 'DOUBLE'
    }

    get isPicklist() {
        return this.fieldData && this.fieldData.type === 'PICKLIST'
    }

    get isCheckbox() {
        return this.fieldData && this.fieldData.type === 'BOOLEAN'
    }

    get isMultiPicklist() {
        return this.fieldData && this.fieldData.type === 'MULTIPICKLIST'
    }

    get isDisabled() {
        return this.disabled || (this.isSecretary && !this.submitBySecretory) || (this.isAttorney && !this.submitByAttorney) || (this.isDoubleChecker && !this.submitByDoubleChecker)
    }

    handleBlur(event) {
        const value = event.target?.value ? event.target?.value : event.detail?.value

        const fields = {};
        fields['Id'] = this.checklistInstanceItemId;
        fields[this.fieldData.apiName] = (value || null);

        const recordInput = { fields };

        this.saveRecordData(recordInput);
    }

    handleCbxChange(event) {
        const checked = event.target.checked

        const fields = {};
        fields['Id'] = this.checklistInstanceItemId;
        fields[this.fieldData.apiName] = checked;

        const recordInput = { fields };

        this.saveRecordData(recordInput);
    }

    handleCbxGroupBlur(event) {
        const values = event.detail.value

        const fields = {};
        fields['Id'] = this.checklistInstanceItemId;
        fields[this.fieldData.apiName] = values.join(';');

        const recordInput = { fields };

        this.saveRecordData(recordInput);
    }

    saveRecordData(recordInput) {

        console.log('recordInput----'+JSON.stringify(recordInput));
        try {
            updateRecord(recordInput).then(() => {
                console.log('record Saved');
            }).catch((error) => {
                console.log('error----'+error.body.message);
            });
        } catch (error) {
            console.log('error-----'+error.message);
            
        }
    }
}