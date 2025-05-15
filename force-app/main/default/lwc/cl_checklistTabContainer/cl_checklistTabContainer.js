import { api, LightningElement, track } from 'lwc';
import getSectionListApex from '@salesforce/apex/CL_ChecklistController.getSectionList';

export default class Cl_checklistTabContainer extends LightningElement {
    @api recordId;
    @api checklistInstanceId;
    @api isSecretary;
    @api isAttorney;
    @api isDoubleChecker;
    @api isSecretaryEditable;
    @api isAttorneyEditable;
    @api isDoubleCheckerEditable;

    @track sectionList;

    connectedCallback() {
        this.getSectionList();
    }

    async getSectionList() {
        const resp = await getSectionListApex({checklistInstanceId: this.checklistInstanceId});

        // console.log('getSectionListApex resp----', resp);
        
        if(resp && resp.isSuccess) {
            const data = resp.data;
            this.sectionList = data.sectionList;
        } else {
            // Show Toast
        }
    }
}