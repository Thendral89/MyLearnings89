import { LightningElement, api, track, wire } from 'lwc';
import LEGAL_ASSISTANT_PF from '@salesforce/label/c.Legal_Assistant_Profile';
import ATTORNEY_PF from '@salesforce/label/c.Attorney_Profile';
import PARALEGAL_PF from '@salesforce/label/c.Paralegal_Profile';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCheckListInstances from '@salesforce/apex/CheckListContainerController.getCheckListInstances';
import getCheckInstanceRec from '@salesforce/apex/CheckListContainerController.getCheckInstanceRec';
import getCurrentUser from '@salesforce/apex/CheckListContainerController.getCurrentUser';
export default class LwcCheckListContainer extends LightningElement {
    @api recordId; //recordId.getSObjectType().getDescribe().getName();
    @track instancesData = [];
    isShowSpinner = false;

    isUserDoubleChecker = false;
   
    connectedCallback() {
        this.isShowSpinner = true;
        getCurrentUser()
        .then(res =>{
            console.log('res  === ' + JSON.stringify(res));
            
            if(res != null){
                console.log('res  === ' + JSON.stringify(res));
                this.isUserDoubleChecker = res.Double_Checker__c;
                console.log('res  === ' + JSON.stringify(this.isUserDoubleChecker));
            }
        })
        getCheckListInstances({ recordId: this.recordId })
            .then(res => {
                console.log('res --- ' + JSON.stringify(res));

                this.instancesData = res;
                this.isShowSpinner = false;
            })
    }
    handleSelectedAttorney(event) {
        if (event.detail != null && event.detail.length > 0) {
            console.log(event.detail[0].Id);
        }
    }

    userFilterCondition = '';
    modalHeading = '';
    searchFields = '';
    queryFields = '';
    userId = '';
    placeholder = '';
    userType = '';
    checkListId = '';
    isError = false;
    isChecklistError = false;
    @track isShowModal = false;

    hideModalBox() {
        this.isShowModal = false;
        this.userFilterCondition = '';
        this.modalHeading = '';
        this.searchFields = '';
        this.queryFields = '';
        this.userId = '';
        this.placeholder = '';
        this.userType = '';
        this.checkListId = '';
        this.isError = false;
        this.isChecklistError = false;
    }
    handleEditClick(event) {
        this.checkListId = event.currentTarget.dataset.checklistid;
        this.userType = event.currentTarget.dataset.usertype;
        this.userId = event.currentTarget.dataset.userid;

        let checkListCode = event.currentTarget.dataset.checklistcode;
        console.log('this.userId ' + this.userId);

        this.searchFields = 'Name';
        this.queryFields = 'Name, Profile.Name, Double_Checker__c';
        if (this.userType == 'Secretary') {

            this.modalHeading = 'Secretary Assignment';
            if(checkListCode == 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION' || checkListCode == 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION' ){
                this.placeholder = 'Select Paralegal Secretary';
                this.userFilterCondition = ' isActive = true AND  Profile.Name = \'' + PARALEGAL_PF + '\'  ';

            }else if(checkListCode == 'CHECKLIST FOR NEW U.S. APPLICATION'){
                this.placeholder = 'Select Paralegal/Legal Assistant Secretary';
                this.userFilterCondition = ' isActive = true AND ( Profile.Name = \'' + LEGAL_ASSISTANT_PF + '\' OR Profile.Name = \'' + PARALEGAL_PF + '\' ) ';
            
            }else if(checkListCode ==  'CHECKLIST FOR NEW U.S. DESIGN APPLICATION' || checkListCode ==  'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE' || checkListCode ==  'CHECKLIST FOR NOTICE OF ALLOWANCE' || checkListCode ==  'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION'){
                this.placeholder = 'Select Legal Assistant Secretary';
                this.userFilterCondition = ' isActive = true AND Profile.Name = \'' + LEGAL_ASSISTANT_PF + '\'  ';
            }
            
        } else if (this.userType == 'Attorney') {

            this.modalHeading = 'Attorney Assignment';
            this.placeholder = 'Select Attorney';
            this.userFilterCondition = ' isActive = true AND Profile.Name = \'' + ATTORNEY_PF + '\'';

        } else if (this.userType == 'DoubleChecker') {

            this.modalHeading = 'Double Checker Assignment';
            

            this.userFilterCondition = ' isActive = true AND Double_Checker__c = true AND ';
            if (checkListCode == 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION') { // PCT US Nat Phase
                this.placeholder = 'Select Paralegal Double Checker';
                this.userFilterCondition += 'Profile.Name = \'' + PARALEGAL_PF + '\'';
            } else if (checkListCode == 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION') { // PCT
                this.placeholder = 'Select Paralegal Double Checker';
                this.userFilterCondition += 'Profile.Name = \'' + PARALEGAL_PF + '\'';
            } else if (checkListCode == 'CHECKLIST FOR NEW U.S. APPLICATION') { // Utility
                this.placeholder = 'Select Paralegal/Legal Assistant Double Checker';
                this.userFilterCondition += ' ( Profile.Name = \'' + LEGAL_ASSISTANT_PF + '\' OR Profile.Name = \'' + PARALEGAL_PF + '\' ) ';
            } else if (checkListCode == 'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION') { // Patent Provisional
                this.placeholder = 'Select Legal Assistant Double Checker';
                this.userFilterCondition += 'Profile.Name = \'' + LEGAL_ASSISTANT_PF + '\'';
            } else if (checkListCode == 'CHECKLIST FOR NOTICE OF ALLOWANCE') { // Patent NOA
                this.placeholder = 'Select Legal Assistant Double Checker';
                this.userFilterCondition += 'Profile.Name = \'' + LEGAL_ASSISTANT_PF + '\'';
            } else if (checkListCode == 'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE') { // Design NOA
                this.placeholder = 'Select Legal Assistant Double Checker';
                this.userFilterCondition += 'Profile.Name = \'' + LEGAL_ASSISTANT_PF + '\'';
            } else if (checkListCode == 'CHECKLIST FOR NEW U.S. DESIGN APPLICATION') { // Design Filing
                this.placeholder = 'Select Legal Assistant Double Checker';
                this.userFilterCondition += 'Profile.Name = \'' + LEGAL_ASSISTANT_PF + '\'';
            }

        }

        this.isShowModal = true;
        this.isError = false;
        this.isChecklistError = false;
        console.log(this.modalHeading);
        console.log(this.userFilterCondition);
        console.log(this.isShowModal);

    }

    handleSelectedUserRecord(event) {
        this.userId = '';
        if (event.detail != null && event.detail.length > 0) {
            console.log(' event.detail[0].Id ' + event.detail[0].Id);
            this.userId = event.detail[0].Id;
        }
    }

    OpenCheckListInstance(event){
        const checklistInstanceId = event.currentTarget.dataset.checklistid;
        window.open('/lightning/cmp/c__cl_checklistContainer?c__recordId=' + this.recordId + '&c__checklistInstanceId=' + checklistInstanceId);
    }

    async handleSave() {
        this.isError = false;
        this.isChecklistError = false;
        if (this.userId == '') {
            this.isError = true;
        } else {
            await getCheckInstanceRec({ recordId: this.checkListId })
                .then(res => {
                    if (res.length > 0) {
                        let checklistRec = res[0];
                        console.log('checklistRec' + JSON.stringify(checklistRec));
                        console.log('checklistRec' + JSON.stringify(this.userType) + this.isUserDoubleChecker);

                        if ((checklistRec.Secretary__c == this.userId && this.userType == 'DoubleChecker' && this.isUserDoubleChecker) || (checklistRec.Double_Checker__c == this.userId && this.userType == 'Secretary')){
                            this.isChecklistError = true;
                        }  else {
                            this.isChecklistError = false;
                            this.isError = false;

                            const fields = {};
                            fields['Id'] = this.checkListId;
                            if (this.userType == 'Secretary') {
                                fields['Secretary__c'] = this.userId;
                            } else if (this.userType == 'Attorney') {
                                fields['Attorney__c'] = this.userId;
                            } else if (this.userType == 'DoubleChecker') {
                                fields['Double_Checker__c'] = this.userId;
                            }

                            console.log(JSON.stringify(fields));

                            const recordInput = { fields };
                            this.isShowSpinner = true;
                            updateRecord(recordInput)
                                .then(() => {
                                    // Show success toast
                                    this.showToast('Success', 'Record updated successfully', 'success');
                                    this.hideModalBox();
                                    this.connectedCallback();
                                    this.isShowSpinner = false;
                                })
                                .catch((error) => {
                                    // Show error toast
                                    this.isShowSpinner = false;
                                    console.log(JSON.stringify(error));

                                    this.showToast('Error', 'Error updating record: ' + error.body.message, 'error');
                                });
                        }
                    }
                })

        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event); // Dispatch the event to show the toast
    }
    handleRefresh() {
        this.connectedCallback();
    }
    // per checklist instance -- who user logged in and at which stage that particular instance is... for which user it can do anything..(custom permission)
    //{name: 'checkListCode', sectoryuser : '', attorneyuser :'', doublecheckuser:'', createdDate:'', status:''}

}