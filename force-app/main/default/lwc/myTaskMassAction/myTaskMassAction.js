import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/Task.Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {saveTaskDataApex, deleteTaskRecordsApex} from 'c/myTaskUtils'
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const FIELDS = ['User.Profile.Name'];


export default class MyTaskMassAction extends LightningElement {
    @api 
    get selectedRecords() {
        return this._selectedRecords;
    }

    set selectedRecords(value) {
        this._selectedRecords = value;
    }

    @track statusOptions = []
    isOwnerAction;
    isStatusAction;
    isDueDateAction;
    isDeleteAction;
    showMassActionModal;

    @track updatedValue;

    @track isSystemAdmin= false;

    @wire(getPicklistValues, { 
        recordTypeId: '012000000000000AAA', 
        fieldApiName: STATUS_FIELD 
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.statusOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    userProfile({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.value.fields.Name.value;
            this.isSystemAdmin = profileName === 'System Administrator';
        } else if (error) {
            console.error('Error fetching user profile:', error);
        }
    }

    handleOwnerChange(event) {
        console.log('details---'+JSON.stringify(event.detail));
        this.updatedValue = event.detail.recordId;
    }

    handleStatusChange(event) {
        this.updatedValue = event.detail.value;
    }

    handleDueDateChange(event) {
        this.updatedValue = event.target.value;
    }

    handleClick(event) {
        const action = event.currentTarget.dataset.action;

        switch (action) {
            case 'owner':
                this.isOwnerAction = true;
                this.showMassActionModal = true;
                break;
            case 'status':
                this.isStatusAction = true;
                this.showMassActionModal = true;
                break;
            case 'duedate':
                this.isDueDateAction = true;
                this.showMassActionModal = true;
                break;
            case 'delete':
                this.isDeleteAction = true;
                this.showMassActionModal = true;
                break;
            case 'cancel':
                this.handleCancel();
                break;
            case 'save':
                this.saveTaskData();
                break;
            case 'delete-apex':
                this.deleteTaskRecords();
                break;
        
            default:
                break;
        }
    }

    handleCancel() {
        this.isStatusAction = false;
        this.isOwnerAction = false;
        this.isDueDateAction = false;
        this.isDeleteAction = false;
        this.showMassActionModal = false;
    }

    async saveTaskData() {
        const taskList = [];

        this._selectedRecords.forEach(ele => {
            const taskObj = {
                Id: ele.Id
            }
            if(this.isOwnerAction) {
                taskObj['OwnerId'] = this.updatedValue;
            } else if(this.isDueDateAction) {
                taskObj['ActivityDate'] = this.updatedValue;
            } else if(this.isStatusAction) {
                taskObj['Status'] = this.updatedValue;
            }
            taskList.push(taskObj);
        })

        console.log('taskList----'+JSON.stringify(taskList));
        
        const resp = await saveTaskDataApex({taskList: taskList});

        if(resp && resp.isSuccess) {
            this.showToast('Success!!', 'Records Updated Successfully.', 'success');
            this.sendRefreshEventToParent();
            this.handleCancel();
        } else {
            this.showToast('Error!!', resp.errorMessage, 'error');
        }

    }

    async deleteTaskRecords() {
        const taskIds = [];

        this._selectedRecords.forEach(ele => {
            taskIds.push(ele.Id);
        });

        const resp = await deleteTaskRecordsApex({taskIds: taskIds});

        if(resp && resp.isSuccess) {
            this.showToast('Success!!', 'Record Deleted Successfully.', 'success');
            this.sendRefreshEventToParent();
            this.handleCancel();
        } else {
            this.showToast('Error!!', resp.errorMessage, 'error');
        }


    }

    sendRefreshEventToParent() {
        this.dispatchEvent(new CustomEvent('refresh', {
            detail: {}
        }));
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({title, message, variant});
        this.dispatchEvent(event);
    }  

}