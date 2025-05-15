import { api, LightningElement } from 'lwc';
export default class RichTextAreaEdit extends LightningElement {

    handleChange(e) {
        //this.tempVal = e.target.value;
        alert(e.target.value);
    }
}