import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {getPopoverDataApex} from 'c/myTaskUtils'

export default class MyTaskPopoverContainer extends LightningElement {
    @api recordId;
    @api recordName;

    @track objectApiName;
    @track fieldList;
    @track themeInfo = {};

    get iconStyle() {
        return this.themeInfo && this.themeInfo.color ? 'background-color: #' + this.themeInfo.color + ';' : '';
    }

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    handleResult({error, data}) {
        if(data) {
            let objectInformation = data;
            this.themeInfo = objectInformation.themeInfo || {};
        }
    }
    
    connectedCallback() {
        this.getPopoverData();
    }

    async getPopoverData() {
        if(this.recordId) {
            const resp = await getPopoverDataApex({recordId: this.recordId});
            console.log('resp ==> '+JSON.stringify(resp));
            if(resp && resp.isSuccess) {
                const data = resp.data;
                this.objectApiName = data.objectName;
                this.fieldList = data.fieldList;
            }
        }
    }
}