import { LightningElement, api , wire , track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord , getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningAlert from 'lightning/alert';
import Toast from 'lightning/toast';
//import theCustomSettingFieldValue from '@salesforce/customSettings/Conflict_Check_Email_Settings__c.Show_Comments_For_Discuss__c';
import USER_ID from '@salesforce/user/Id';
import taskForDiscuss from '@salesforce/apex/votingApproveDiscussCtrl.taskForDiscuss';
import updateDiscussComments from '@salesforce/apex/votingApproveDiscussCtrl.updateDiscussComments';
//import DISCUSS_USERS_FIELD from "@salesforce/schema/Conflict_Check__c.Name";
import DISCUSS_USERS_FIELD from "@salesforce/schema/Conflict_Check__c.Discuss_Needed_Users__c";


const FIELDS = [DISCUSS_USERS_FIELD];
export default class LwcVotingDiscuss extends LightningElement {
    @api recordId;
    @track conflictCheckData;
    @track showComments = false;
    
    @wire (taskForDiscuss,{conflictCheckId : '$recordId'})
	wiredAccounts({data, error}){
        console.log (data);
        console.log (error);
		if(data) {
			if(data == 'Already Discussion Initiated'){
                this.dispatchEvent(new CloseActionScreenEvent());
                this.openErrorAlertModal();
            }
            else if(data == 'Already Approved'){
                this.dispatchEvent(new CloseActionScreenEvent());
                this.openAlreadyApprovedAlertModal();
            }
            else if(data == 'Task Record Not Found'){
                this.dispatchEvent(new CloseActionScreenEvent());
                this.openTaskNotFound();
                
            }else if(data == 'Show Comment'){
                this.showComments = true;
            }else {
                this.dispatchEvent(new CloseActionScreenEvent());
                const result = LightningAlert.open({
                    label: 'Configuration Update Needed!',
                    message: 'Please review the configruation for Comment visibility.',
                    theme: 'error'
                });

            }
		}else {
			console.log('Error ==> ',JSON.stringify(error));
		}
	}

    @track comments='';
    onCommentsChange(event){
        this.comments = event.target.value;
    }
    onclickSubmit(event){
        console.log('Handle Submit');
        if(this.comments == null || this.comments == ''){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Comments are required.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('Handle Submit Error');
            return;
        }
        else{
            console.log('Going to update');
            this.handleUpdate();
            console.log('update');
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    handleUpdate() {
        updateDiscussComments({conflictCheckId :this.recordId, comments:this.comments}).then((result)=>{
            if(result === 'Success') {
                this.openSuccessAlertModal();
            }else {
                const result = LightningAlert.open({
                    label: 'Error.',
                    message: 'Failed to update comment, please check with System Administartor for more information.',
                    theme: 'error'
                });
            }
        })
    }


    async openSuccessAlertModal() {
		const result = await LightningAlert.open({
			label: 'Discussion Needed.',
			message: 'Requested for a discussion.',
            theme: 'success'
		});

        window.location.reload();
	}
    async openErrorAlertModal() {
		const result = await LightningAlert.open({
			label: 'Disuccion Already Initiated!.',
			message: 'Already Discussion Initiated.',
            theme: 'error'
		});
	}

    async openTaskNotFound(){
        const result = await LightningAlert.open({
			label: 'Task Not Fond!.',
			message: 'There is no Task Record to vote this Conflict check.',
            theme: 'error'
		});
    }
    async openAlreadyApprovedAlertModal(){
        const result = await LightningAlert.open({
			label: 'Already Approved!.',
			message: 'Already approved this conflict check.',
            theme: 'error'
		});
    }
       
}