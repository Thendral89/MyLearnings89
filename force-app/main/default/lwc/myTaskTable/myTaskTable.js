import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/Task.Status';
import PRIORITY_FIELD from '@salesforce/schema/Task.Priority';
import {saveTaskDataApex} from 'c/myTaskUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    openSubtab,
    getTabInfo
} from 'lightning/platformWorkspaceApi'

const today = new Date();
export default class MyTaskTable extends NavigationMixin(LightningElement) {

    @api hideRelated;
    @api hideStatus;
    @api hidePriority;
    @api additionalFieldOne;
    @api additionalFieldOneLabel;
    @api additionalFieldTwo;
    @api additionalFieldTwoLabel;

    @api createOrAssignedField;
    @api createOrAssignedLabel;

    priorityValueToLabelMap = {};
    statusValueToLabelMap = {};

    @api
    get taskList() {
        console.log('this._taskList get:',JSON.stringify(this._taskList));
        return this._taskList;
    }
    set taskList(value) {
        console.log('createOrAssignedField:',this.createOrAssignedField);
        console.log('createOrAssignedLabel:',this.createOrAssignedLabel);
        
        this._taskList = (value || []).map(ele => ({
            ...ele,
            dueDateClass: ele.ActivityDate ? this.getDueDateClass(ele.ActivityDate) : '',
            additionalFieldOneVal: ele[this.additionalFieldOne] ? ele[this.additionalFieldOne] : '',
            additionalFieldTwoVal: ele[this.additionalFieldTwo] ? ele[this.additionalFieldTwo] : '',
            statusStyle: this.getStatusStyle(ele.Status_Color__c),
            priorityStyle: this.getPriorityStyle(ele.Priority_Color__c),
            createOrAssignedFieldVal: this.createOrAssignedField === 'Assigned_To__r.Name'  ? (ele.Assigned_To__r && ele.Assigned_To__r.Name) || '' 
                                    : this.createOrAssignedField === 'CreatedBy.Name' ? (ele.CreatedBy && ele.CreatedBy.Name) || '' 
                                        : '',
            userOrAssignedID: this.createOrAssignedField === 'Assigned_To__r.Name' ? ele.Assigned_To__c || '' 
                                : this.createOrAssignedField === 'CreatedBy.Name'  ? ele.CreatedById || '' 
                                : ''
        }));
        console.log('this._taskList set:',JSON.stringify(this._taskList));
    }

    @track _taskList;
    @track statusOptions = [];
    @track priorityOptions = [];
    @track massSelectedTaskRecords = [];
    @track allRecordsSelected = false;
    showSpinner = false;

    get hasTask() {
        return this._taskList && this._taskList.length > 0
    }

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: STATUS_FIELD })
    wiredStatusPicklist({ error, data }) {
        if (data) {
            this.statusOptions = data.values.map(item => ({
                label: item.value,
                value: item.value
            }));
        }
        if (error) {
            this.showToast('Error', 'Error loading Status picklist values', 'error');
        }
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: PRIORITY_FIELD })
    wiredPriorityPicklist({ error, data }) {
        if (data) {
            this.priorityOptions = data.values.map(item => ({
                label: item.value,
                value: item.value
            }));
            console.log('this.priorityOptions:,',JSON.stringify(this.priorityOptions));
        }
        if (error) {
            this.showToast('Error', 'Error loading Priority picklist values', 'error');
        }
    }

    @api
    selectAll(checked) {
        this._taskList = this._taskList.map(ele => ({
            ...ele,
            checked: checked
        }));

        this.sendSelectedRecordsToParent();
    }

    getDueDateClass(activityDateStr) {
        const activityDate = new Date(activityDateStr);
        return activityDate < today ? 'recordCell truncate red' : 'recordCell truncate green'
    }

    getStatusStyle(statusColor) {
        return statusColor ? 'background:' + statusColor + '; color:white;' : ''
    }

    getPriorityStyle(priorityColor) {
        return priorityColor ? 'background:' + priorityColor + '; color:white;' : ''
    }

    handleTaskEdit(event) {
        const index = event.currentTarget.dataset.index;
        const field = event.currentTarget.dataset.field;
        const taskList = this._taskList;

        taskList[index][field] = true;
        this._taskList = taskList;
    }

    handleTaskFieldChange(event) {
        const taskId = event.currentTarget.dataset.id;
        const field = event.currentTarget.dataset.field;
        const value = event.detail.value;

        const taskList = [
            {
                Id: taskId,
                [field]: value
            }
        ];
        
        this.saveTaskData(taskList);
    }

    async saveTaskData(taskList) {
        this.showSpinner = true;
        const resp = await saveTaskDataApex({ taskList: taskList });
        this.showSpinner = false;
        if (resp && resp.isSuccess) {
            this.showToast('Success!!', 'Record Updated Successfully.', 'success');
        } else {
            this.showToast('Error!!', resp.errorMessage, 'error');
        }

        this.sendRefreshEventToParent();

    }

    handleRecordClick(event) {
        const taskId = event.currentTarget.dataset.id;
        this.dispatchEvent(new CustomEvent('edit', {
            detail: {
                taskId: taskId
            }
        }));
    }

    handleCbxChange(event) {
        const index = event.currentTarget.dataset.index;
        const checked = event.target.checked;
        const taskList = this._taskList;
        taskList[index]['checked'] = checked;
        this._taskList = taskList;
        
        this.sendSelectedRecordsToParent();
    }

    sendSelectedRecordsToParent() {
        const selectedTasks = this._taskList.filter(ele => {
            return ele.checked
        })

        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                selectedTasks
            }
        }));
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

    handleNavigateToWhatId(event) {
        const whatId = event.currentTarget.dataset.recordId;
        if (whatId) {
            // console.log('Navigating to WhatId:', whatId);
            // const recordPageUrl = `/lightning/r/Record/${whatId}/view`;
    
            // window.open(recordPageUrl, '_blank');
            this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', whatId, 'view');
        }
        
    }

    handleNavigateToTaskDetail(event){
        const taskId = event.currentTarget.dataset.recordId;
        console.log('taskId:',taskId);
        if (taskId) {
            // console.log('Navigating to taskId:', taskId);
            // const recordPageUrl = `/lightning/r/Record/${taskId}/view`;
    
            // window.open(recordPageUrl, '_blank');
            this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', taskId, 'view');
        }
    }

    handleNavigateToUserorAssignedDetail(event){
        const recordId= event.currentTarget.dataset.recordId;
        if (recordId) {
            // console.log('Navigating to recordId:', recordId);
            // const recordPageUrl = `/lightning/r/Record/${recordId}/view`;
    
            // window.open(recordPageUrl, '_blank');
            this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
        }

    }

    formatDateTimeToLocal(dateTime) {
        const dateObj = new Date(dateTime);
        const options = { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' };
        return dateObj.toLocaleDateString('de-DE', options).replace(', ', ', ');
    }


    async findEnclosingTabAndOpenSubtab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
        try {
            console.log('findEnclosingTabAndOpenSubtab', type, objectApiName, recordId, actionName);
            // Ensure that we're in a console app and that we have a tab open
            // if (!this.isConsoleNavigation || !this.enclosingTabId) {
            //     return;
            // }
            // Open a record as a subtab of the current tab
            let tabInfo = await getTabInfo(this.enclosingTabId);
            console.log('BBBB tabInfo', JSON.stringify(tabInfo));

            let finalTabId = tabInfo.parentTabId ? tabInfo.parentTabId : this.enclosingTabId;
            // Open sub tab
            await openSubtab(finalTabId, {
                pageReference: {
                    'type': type,
                    attributes: {
                        'objectApiName': objectApiName,
                        'actionName': actionName,
                        "recordId": recordId,
                        "focus": true
                    }
                }
            });
        }
        catch (err) {
            this.openAsNewTab(type, objectApiName, recordId, actionName);
        }

    }

    async openAsNewTab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
        try {
            // Open sub tab
            await openTab({
                pageReference: {
                    'type': type,
                    attributes: {
                        'objectApiName': objectApiName,
                        'actionName': actionName,
                        "recordId": recordId,
                        "focus": true
                    }
                }
            });
        }
        catch (err) {
            try {
                console.error(this.serializeError(err));
            } catch (e) { }

            try {
                console.error(err);
                console.error(JSON.stringify(err));
            } catch (e) { }

        }
    }
}