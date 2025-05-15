import { api, LightningElement, track } from 'lwc';

export default class Checkbox extends LightningElement {
    @api label = 'Yes';
    @api variant = 'standard';
    @track _checked = false;
    @api disabled = false;
    @api keyField;
    @api rowKey;
    @api fieldName;
    
    @api
    get checked(){
        console.log('_checked: '+this._checked);
        return this._checked;
    }
    set checked(val){
        console.log('val: '+val);
        this._checked = val;
        console.log('_checked: '+this._checked);
    }
    handleChange(event){
        const evt = new CustomEvent('checkboxvaluechange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: { [this.keyField]: this.rowKey, [this.fieldName]: event.target.checked }
        });
        this.dispatchEvent(evt);
    }
}