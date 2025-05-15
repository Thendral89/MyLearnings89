import { LightningElement, api, track } from 'lwc';

export default class MvObjectFields extends LightningElement {

    @api recordId;
    @api objectName;
    @api fieldName
    @api updateableFieldName;
    @api value;
    @track isEditable = false;
    @api isFormattedText = false;

    isRendered = false;
    renderedCallback() {
        if( this.isRendered ) return;

        this.isRendered = true;
        this.removeExtraDateLabel();
    }

    connectedCallback(){
        console.log('connected callback mvObjectFields');
        console.log('value', this.value);
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

    timeoutId;

    handleChange(event){
       try{
            console.log('In Handle Change Event');
            console.log('event.target.name::', event.target.name);
            console.log('event.target.name::');
            console.log('event.target.value::', event.target.value)
            const newValue = event.target.value;
            this.value = newValue;

            window.clearTimeout(this.timeoutId);
            this.timeoutId = setTimeout(()=>{
                
                const valueChangeEvent = new CustomEvent('valuechanged', {
                    detail: { field: this.updateableFieldName, value: newValue },
                    bubbles: true,
                    composed: true
                });
                this.dispatchEvent(valueChangeEvent);
                console.log('Event Dispatched');
            }, 700);
       }catch(err){
           alert('JS Error :: mvObjectFields :: handleChange')
           console.error(err)
       }
    }
}