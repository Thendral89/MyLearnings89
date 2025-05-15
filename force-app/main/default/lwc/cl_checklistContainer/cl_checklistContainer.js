import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getCheckListConfigDataApex from '@salesforce/apex/CL_ChecklistController.getCheckListConfigData';
import { updateRecord } from "lightning/uiRecordApi";
import isChecklistAdmin from "@salesforce/customPermission/CheckList_Admin";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from "lightning/platformResourceLoader";
import checklist from "@salesforce/resourceUrl/checklist";
import {
    IsConsoleNavigation,
    getFocusedTabInfo,
    setTabLabel,
    setTabIcon,
    refreshTab

} from 'lightning/platformWorkspaceApi';


const NEXT_STATUS_MAPPING = {
    'Initial Assignment Checklist In Progress' : 'Attorney Checklist In Progress',
    'Attorney Checklist In Progress' : 'Filing Documents with PTO',
    'Filing Documents with PTO' : 'Double Checking'
}

export default class Cl_checklistContainer extends LightningElement {

    @track checklistInstance;

    showSpinner;

    get recordId() {
        return this.currentPageRef.state.c__recordId;
    }

    get checklistInstanceId() {
        return this.currentPageRef.state.c__checklistInstanceId;
    }

    get formName() {
        return this.checklistInstance && this.checklistInstance.formName ? this.checklistInstance.formName : ''
    }

    get isSecretary() {
        return (this.checklistInstance && this.checklistInstance.isSecretary) || isChecklistAdmin
    }

    get isAttorney() {
        return (this.checklistInstance && this.checklistInstance.isAttorney) || isChecklistAdmin
    }

    get isDoubleChecker() {
        return (this.checklistInstance && this.checklistInstance.isDoubleChecker) || isChecklistAdmin
    }

    get isShowSubmit() {
        return this.checklistInstance && this.checklistInstance.status 
        && (isChecklistAdmin || 
            ((this.checklistInstance.status === 'Initial Assignment Checklist In Progress' || this.checklistInstance.status === 'Filing Documents with PTO') && this.checklistInstance.isSecretary) || 
            (this.checklistInstance.status === 'Attorney Checklist In Progress' && this.checklistInstance.isAttorney)
        )
        && (this.checklistInstance.status !== 'Completed' && this.checklistInstance.status !== 'Modification In Progress' && this.checklistInstance.status !== 'Double Checker Approved' && this.checklistInstance.status !== 'Double Checking')

    }

    get isDoubleChecking() {
        return this.checklistInstance && this.checklistInstance.status && this.checklistInstance.status === 'Double Checking' && (
            isChecklistAdmin || this.checklistInstance.isDoubleChecker
        )
    }

    get isShowMarkAsCompleted() {
        return this.checklistInstance && this.checklistInstance.status && (this.checklistInstance.status === 'Double Checker Approved' || this.checklistInstance.status === 'Modification In Progress') && (
            isChecklistAdmin || this.checklistInstance.isSecretary
        )
    }

    get isSecretaryEditable() {
        return this.checklistInstance && this.checklistInstance.status && ((isChecklistAdmin && this.checklistInstance.status !== 'Completed') || (this.checklistInstance.isSecretary && (this.checklistInstance.status === 'Initial Assignment Checklist In Progress' || this.checklistInstance.status === 'Modification In Progress')))
    }

    get isAttorneyEditable() {
        return this.checklistInstance && this.checklistInstance.status && ((isChecklistAdmin && this.checklistInstance.status !== 'Completed') || (this.checklistInstance.isAttorney && (this.checklistInstance.status === 'Attorney Checklist In Progress' || this.checklistInstance.status === 'Modification In Progress')))
    }

    get isDoubleCheckerEditable() {
        return this.checklistInstance && this.checklistInstance.status && ((isChecklistAdmin && this.checklistInstance.status !== 'Completed') || (this.checklistInstance.isDoubleChecker && this.checklistInstance.status === 'Double Checking'))
    }

    @wire(CurrentPageReference)
    currentPageRef;

    async setCurrentTabLabel() {
            // console.log('Console Navigation : ' + this.isConsoleNavigation);
            // if (!this.isConsoleNavigation) {
            //     return;
            // }
            const { tabId } = await getFocusedTabInfo();
            setTabLabel(tabId, 'Checklist');
            setTabIcon( tabId, 'utility:edit_gpt', {
                iconAlt: 'Account Insights'
            });
        }

    connectedCallback() {
        this.setCurrentTabLabel();
        Promise.all([loadStyle(this, checklist + "/checklist.css")]).then(() => {
            console.log('loaded');
        });
        this.getCheckListConfigData();
    }

    async getCheckListConfigData() {
        const resp = await getCheckListConfigDataApex({checklistInstanceId: this.checklistInstanceId});
        
        if(resp && resp.isSuccess) {
            const data = resp.data;
            this.checklistInstance = data.checklistInstance;
        } else {
            // Show Toast
        }
    }

    handleSubmit(event) {

        const nextStatus = NEXT_STATUS_MAPPING[this.checklistInstance.status]

        const fields = {};
        fields['Id'] = this.checklistInstanceId;
        fields['Status__c'] = nextStatus;

        if(nextStatus === 'Attorney Checklist In Progress') {
            fields['Secretary_Completed__c'] = true;
        } else if(nextStatus === 'Filing Documents with PTO') {
            fields['Attorney_Completed__c'] = true;
        }

        const recordInput = { fields };

        this.saveRecordData(recordInput, true);
    }

    handleRequestForModification(event) {
        const fields = {};
        fields['Id'] = this.checklistInstanceId;
        fields['Status__c'] = 'Modification In Progress';
        fields['Double_Checker_Completed__c'] = true;

        const recordInput = { fields };

        this.saveRecordData(recordInput, true);
    }

    handleApprove(event) {

        const fields = {};
        fields['Id'] = this.checklistInstanceId;
        fields['Status__c'] = 'Double Checker Approved';
        fields['Double_Checker_Completed__c'] = true;

        const recordInput = { fields };

        this.saveRecordData(recordInput, true);
    }

    handleMarkAsCompleted(event) {

        const fields = {};
        fields['Id'] = this.checklistInstanceId;
        fields['Status__c'] = 'Completed';

        const recordInput = { fields };

        this.saveRecordData(recordInput, true);
    }

    handleNotesBlur(event) {
        const fields = {};
        fields['Id'] = this.checklistInstanceId;
        fields['Double_Checker_Notes__c'] = event.target.value;

        const recordInput = { fields };

        this.saveRecordData(recordInput, false);
    }

    saveRecordData(recordInput, showSuccessToast) {

        try {
            updateRecord(recordInput).then(() => {

                if(showSuccessToast) {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Saved Successfully',
                        variant: 'success',
                      });
                      this.dispatchEvent(evt);
                }
                this.getCheckListConfigData();
            }).catch((error) => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                  });
                  this.dispatchEvent(evt);
                console.log('error----'+error.body.message);
            });
        } catch (error) {
            console.log('error-----'+error.message);
            
        }
    }
    get doublecheckNotesDisabled(){
        return !this.isDoubleChecking;
    }
}