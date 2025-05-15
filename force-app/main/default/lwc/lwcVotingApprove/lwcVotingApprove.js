import { LightningElement, api , wire , track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Toast from 'lightning/toast';
import LightningAlert from 'lightning/alert';
import { updateRecord , getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import taskForApprove from '@salesforce/apex/votingApproveDiscussCtrl.taskForApprove';
import APPROVED_USERS_FIELD from "@salesforce/schema/Conflict_Check__c.Name";


const FIELDS = [APPROVED_USERS_FIELD];
export default class LwcVotingApprove extends LightningElement {
    @api recordId;
    @track conflictCheckData;

    // @wire(getRelatedListRecords, {
    //     parentRecordId: "$recordId",
    //     relatedListId: 'Tasks',
    //     fields: ['Task.Name','Task.Id']
    //   })
    //   listInfo({ error, data }) {
    //     if (data) {
    //       this.conflictCheckData = data.records;
    //       this.error = undefined;
    //       console.log('this cc data ===> ',JSON.stringify(this.conflictCheckData));
    //     } else if (error) {
    //             let message = "Unknown error";
    //             if (Array.isArray(error.body)) {
    //                 message = error.body.map((e) => e.message).join(", ");
    //             } else if (typeof error.body.message === "string") {
    //                 message = error.body.message;
    //             }
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                 title: "Error loading contact",
    //                 message,
    //                 variant: "error",
    //                 }),
    //             );
    //         }
    //   }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
        let message = "Unknown error";
        if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
        } else if (typeof error.body.message === "string") {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
            title: "Error loading contact",
            message,
            variant: "error",
            }),
        );
        } else if (data) {
            this.conflictCheckData = data;
            this.handleApprove();
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    handleApprove(){

        console.log('Current Record Data ===> ', JSON.stringify(this.conflictCheckData));

        taskForApprove({ conflictCheckId : this.recordId })
		.then(result => {

            if(result == 'Success'){
                console.log('Approved');
                this.openSuccessAlertModal();
                
            }else if(result === 'Already Approved'){
                console.log('Already Approved');
                this.openErrorAlertModal();
            }
            else if(result === 'Already Initiated For Discussion'){
                this.openWarningAlertModal();
            }
            else if(result === 'Task Record Not Found'){
                this.openTaskNotFound();
            }
		})
		.catch(error => {
            console.log(error);
		})
        
    }

    async openSuccessAlertModal() {
		const result = await LightningAlert.open({
			label: 'Approve.',
			message: 'Thanks for approving this client.',
            theme: 'success'
		});
		// Alert modal has been closed, user clicked 'OK' 
	}
    async openErrorAlertModal() {
		const result = await LightningAlert.open({
			label: 'Already Approved!.',
			message: 'Already Approved.',
            theme: 'error'
		});
		// Alert modal has been closed, user clicked 'OK' 
	}
    async openWarningAlertModal() {
		const result = await LightningAlert.open({
			label: 'Discussion!.',
			message: 'Already Initiated For Discussion.',
            theme: 'warning'
		});
		// Alert modal has been closed, user clicked 'OK' 
	}

    async openTaskNotFound(){
        const result = await LightningAlert.open({
			label: 'Task Not Fond!.',
			message: 'There is no Task Record to vote this Conflict check.',
            theme: 'error'
		});
    }

    //use updaterecord
    // Visibility create two custom field to store approve
    // add task related list to the cc

    
}