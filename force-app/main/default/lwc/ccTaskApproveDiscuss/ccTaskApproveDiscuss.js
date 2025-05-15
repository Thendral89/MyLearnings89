import { LightningElement, track, wire, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import taskForApprove from '@salesforce/apex/votingApproveDiscussCtrl.taskForApprove';
import taskForDiscuss from '@salesforce/apex/votingApproveDiscussCtrl.taskForDiscuss';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import updateDiscussComments from '@salesforce/apex/votingApproveDiscussCtrl.updateDiscussComments';

export default class CcTaskApproveDiscuss extends LightningElement {
    RECORD_CREATE_SUCCESS_MESSAGE = 'New keyword created successfully.';
    @track isValidKeyword = false;
    @track newKeywords = '';
    @track showComments = false;
    @api objectApiName;
    @api fieldSetName;  
    @api recordId;

    @api readOnly = false;

    nameField = '';
    fieldList = [];

    @track fieldSetData = [];
    error;

    isLoading = false;
    editMode = false;

    docketNumber;
    recordName;        
    logoUrl;            
    objectLabel;

    showKeywords = true;
    @track isConflictCheck = false;
    keywords;

    summary;

    showToast(title, variant, message) {
        console.log('Executing showToast');
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

    connectedCallback() {
        console.log('Executing connectedCallback :'+this.objectApiName);
        if(this.objectApiName == 'Conflict_Check__c'){
            this.isConflictCheck = true;
        }else{this.isConflictCheck = false;}
        console.log('api name :'+this.isConflictCheck);
    }

    
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({ error, data }) {
        if (data) {
            this.logoUrl = data.themeInfo.iconUrl;
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    handleApproveClick() {
        console.log('record id :'+this.recordId);
        taskForApprove({ conflictCheckId : this.recordId })
            .then(async result => {
                console.log('result :'+result);
                if (result === 'Success') {
                    console.log('Approved');
                    await this.openSuccessAlertModalA();
                } else if (result === 'Already Approved') {
                    console.log('Already Approved');
                    await this.openErrorAlertModalA();
                } else if (result === 'Already Initiated For Discussion') {
                    await this.openWarningAlertModalA();
                } else if (result === 'Task Record Not Found') {
                    await this.openTaskNotFoundA();
                }
            })
            .catch(error => {
                console.error('Approval Error', error+JSON.stringify(error));
            });
    }

    handleDiscussClick() {
        try{
            console.log('record id :'+this.recordId);
        taskForDiscuss({ conflictCheckId: this.recordId })
            .then((data) => {
                console.log('discuss data :'+data+' '+JSON.stringify(data));
                if (data === 'Already Discussion Initiated') {
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.openErrorAlertModal();
                } else if (data === 'Already Approved') {
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.openAlreadyApprovedAlertModal();
                } else if (data === 'Task Record Not Found') {
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.openTaskNotFound();
                } else if (data === 'Show Comment') {
                    this.showComments = true;
                } else {
                    this.dispatchEvent(new CloseActionScreenEvent());
                    LightningAlert.open({
                        label: 'Configuration Update Needed!',
                        message: 'Please review the configuration for Comment visibility.',
                        theme: 'error'
                    });
                }
            })
            .catch((error) => {
                console.error('Error in handleDiscussClick:', error+' '+JSON.stringify(error));
            });
    }catch(ex){
        console.log('error :'+ex+' '+JSON.stringify(ex));
    }
}

    async openSuccessAlertModalA() {
        console.log('Executing openSuccessAlertModal');
        await LightningAlert.open({
            label: 'Approve.',
            message: 'Thanks for approving this client.',
            theme: 'success'
        });
    }
    
    async openErrorAlertModalA() {
        console.log('Executing openErrorAlertModal');
        await LightningAlert.open({
            label: 'Already Approved!.',
            message: 'Already Approved.',
            theme: 'error'
        });
    }
    
    async openWarningAlertModalA() {
        console.log('Executing openWarningAlertModal');
        await LightningAlert.open({
            label: 'Discussion!.',
            message: 'Already Initiated For Discussion.',
            theme: 'warning'
        });
    }
    
    async openTaskNotFoundA() {
        console.log('Executing openTaskNotFound');
        await LightningAlert.open({
            label: 'Task Not Found!',
            message: 'There is no Task Record to vote this Conflict check.',
            theme: 'error'
        });
    }

    async openSuccessAlertModal() {
        await LightningAlert.open({
            label: 'Discussion Needed.',
            message: 'Requested for a discussion.',
            theme: 'success'
        });
        window.location.reload();
    }
    
    async openErrorAlertModal() {
        await LightningAlert.open({
            label: 'Discussion Already Initiated!',
            message: 'Already Discussion Initiated.',
            theme: 'error'
        });
    }
    
    async openTaskNotFound() {
        await LightningAlert.open({
            label: 'Task Not Found!',
            message: 'There is no Task Record to vote this Conflict Check.',
            theme: 'error'
        });
    }
    
    async openAlreadyApprovedAlertModal() {
        await LightningAlert.open({
            label: 'Already Approved!',
            message: 'Already approved this conflict check.',
            theme: 'error'
        });
    }
    
    onCommentsChange(event) {
        this.comments = event.target.value;
    }
    
    onclickSubmit() {
        if (!this.comments) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Comments are required.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
            return;
        }
    
        updateDiscussComments({ conflictCheckId: this.recordId, comments: this.comments })
            .then((result) => {
                if (result === 'Success') {
                    this.openSuccessAlertModal();
                } else {
                    LightningAlert.open({
                        label: 'Error.',
                        message: 'Failed to update comment, please check with System Administrator for more information.',
                        theme: 'error'
                    });
                }
            })
            .catch((error) => {
                console.error('Error in onclickSubmit:', error);
            });
    }
}