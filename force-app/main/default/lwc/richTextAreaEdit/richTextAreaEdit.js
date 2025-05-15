import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RichTextAreaEdit extends LightningElement {
    @api name;
    @api val;
    @api editable;
    tempVal;
    edit = false;
    handleEdit(){
        this.edit = true;
        this.tempVal = this.val;
    }
    handleCancel(){
        this.edit = false;
    }
    handleSave(){
        this.edit = false;
        this.val = this.tempVal;
        const event = new CustomEvent('rtachange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                pmrName: this.name,
                val: this.val
            },
        });
        this.dispatchEvent(event);
    }
    handleChange(e) {
        this.tempVal = e.target.value;
    }
}