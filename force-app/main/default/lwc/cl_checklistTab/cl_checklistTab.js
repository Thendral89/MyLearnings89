import { api, LightningElement, track } from 'lwc';
import getSubSectionListApex from '@salesforce/apex/CL_ChecklistController.getSubSectionList';

export default class Cl_checklistTab extends LightningElement {
    @api recordId;
    @api checklistInstanceId;
    @api parentSectionId;
    @api isSecretary;
    @api isAttorney;
    @api isDoubleChecker;
    @api isSecretaryEditable;
    @api isAttorneyEditable;
    @api isDoubleCheckerEditable;

    @track subSectionList = [];

    get hasSubSections() {
        return this.subSectionList && this.subSectionList.length > 0
    }

    connectedCallback() {
        console.log('isSecretaryEditable----',this.isSecretaryEditable);
        console.log('isAttorneyEditable----',this.isAttorneyEditable);
        console.log('isDoubleCheckerEditable----',this.isDoubleCheckerEditable);
        
        this.getSubSectionList();
    }

    async getSubSectionList() {
        const resp = await getSubSectionListApex({checklistInstanceId: this.checklistInstanceId, parentSectionId: this.parentSectionId});

        console.log('getSubSectionListApex resp----', resp);
        
        if(resp && resp.isSuccess) {
            const data = resp.data;
            this.subSectionList = data.subSectionList;
        } else {
            // Show Toast
        }
    }
}