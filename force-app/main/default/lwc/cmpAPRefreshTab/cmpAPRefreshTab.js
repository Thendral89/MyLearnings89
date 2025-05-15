import { LightningElement, api } from 'lwc';
export default class CmpAPRefreshTab extends LightningElement {
    @api recordId;

    refreshPage(){
        let reloadEventDetail = true;
        let reloadEvent = new CustomEvent('pageReload',{
            detail: {reloadEventDetail},
        });
        this.dispatchEvent(reloadEvent);
    }
}