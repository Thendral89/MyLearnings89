import { api, LightningElement } from 'lwc';
import {getPanelInfoApex} from 'c/myTaskUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 

export default class MyTaskHighlightedPanel extends LightningElement {
    @api panel;
    @api 
    get filterVal(){
        return this._filterVal;
    }

    set filterVal(value) {
        this._filterVal = value;
    }

    label;
    count;

    @api refresh() {
        console.log('in refresh');
        
        this.fetchPanelData();
    }

    connectedCallback() {
        this.fetchPanelData();
    }

    async fetchPanelData() {
        const resp = await getPanelInfoApex({ panelKey: this.panel,  filterVal: this._filterVal});
        console.log('getPanelInfoApex resp-----', resp);
        
        if(resp && resp.isSuccess) {
            const data = resp.data;

            this.label = data.label;
            this.count = data.count;
        } else {
            this.showToast('Error!!', resp.errorMessage, 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({title, message, variant});
        this.dispatchEvent(event);
    }
}