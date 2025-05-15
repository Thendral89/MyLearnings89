import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import saveTask from '@salesforce/apex/TaskFormHelper.saveTask';
import getTaskFieldsData from '@salesforce/apex/TaskFormHelper.getTaskFieldsData';
import uploadFilesWithTask from '@salesforce/apex/TaskFormHelper.uploadFilesWithTask';

import getLoggedInUser from '@salesforce/apex/TaskFormHelper.getLoggedInUser';
import getTaskById from '@salesforce/apex/TaskFormHelper.getTaskById';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import { getRecord } from 'lightning/uiRecordApi';

//import checkUserPermissions from '@salesforce/apex/TaskFormHelper.checkUserPermissions';
//import createFinalDocuments from '@salesforce/apex/TaskFormHelper.createFinalDocuments';
//import USER_ID from '@salesforce/user/Id';
//import CLIENT_ID_FIELD from '@salesforce/schema/User.Client_Id__c';
//import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

//const USER_FIELDS = [CLIENT_ID_FIELD, PROFILE_NAME_FIELD];


const RelatedObjectOptions = [
    'SymphonyLF__Patent__c','SymphonyLF__Trademark__c','SymphonyLF__Design__c','SymphonyLF__General_Matter__c',
    'SymphonyLF__Copyright__c','SymphonyLF__Dispute_Opposition__c','SymphonyLF__Design_Family__c','SymphonyLF__Patent_Family__c',
    'Conflict_Check__c','SymphonyLF__Mark__c'
];



export default class TaskFormLWC extends LightningElement {

    @api relatedRecordId;
    @api recordId;
    
    @track loading = true;

    @track subjectOptions = [];
    @track directionOptions = [];
    @track taskTypeOptions = [];
    @track priorityOptions = [];
    @track statusOptions = [];
    @track relatedToObjects = [];
    
    @track assignedToObjectApi;
    @track selectedRelatedToObject;
    @track taskRecordResult;
    @track relatedRecordResult;

    @track isNotAgent = true;
    @track isNotParalegal = true;
    @track isNotAttorney= true;
    
    @track relatedToName;
    
    @track task = {
        Subject: 'Other',
        //SymphonyLF__Title__c: '',
        OwnerId: '',
        Direction__c: 'IN',
        Task_Type__c: '',
        Priority: 'Normal',
        Status: 'Not Started',
        Description: '',
        // Paralegal_Comment__c: '',
        // Attorney_Comment__c: '',
        // Agent_Comment__c: '',
        IsReminderSet: true,
        ReminderDateTime: new Date(new Date().setMinutes(new Date().getMinutes() >= 30 ? 60 : 30, 0, 0)).toISOString(),
        ActivityDate: null,
        WhatId: '',
    };
    
    collectionFieldNames = 'Name';
    collectionfieldsToQuery = 'Name';
    clientIdCondition = '';
    clientRelatedtoCondition='';
    @track selectedAssignedId;
    @track selectedRelatedId;
    @track files = [];
    @track uploadedFiles=[];
    @track finalDocumentfiles = [];
    @track preSelectedRows=[];
    columns = [
        { label: 'File Name', fieldName: 'ContentDownloadUrl', 
            type: 'url', 
            typeAttributes: {
                label: { fieldName: 'displayName' },
                target: '_blank'
            }
        },
        { 
            label: 'Type', 
            fieldName: 'type',
            type: 'text' 
        }
    ];


    /* @wire(checkUserPermissions)
    wiredPermissions({ error, data }) {
        if (data) {
            console.log('Permissions:', JSON.stringify(data));
            this.isNotParalegal = !data.isParalegal;
            this.isNotAttorney = !data.isAttorney;
            this.isNotAgent = !data.isAgent;
            
        } else if (error) {
            console.error('Error checking user permissions:', error);
        }
    } */

    @wire(getLoggedInUser)
    wiredInventorId({ error, data }) {
        if (data) {
            console.log('getLoggedInUser:', JSON.stringify(data));
            if(!this.recordId){
            this.selectedAssignedId = data;
            this.task.OwnerId = data;
            console.log('Fetched inventorId in wire: ' + this.selectedAssignedId);
            console.log('OwnerId set to: ' + this.task.OwnerId);
            }
        } else if (error) {
            this.selectedAssignedId = '';
            this.task.OwnerId = '';
            console.error('Error fetching logged-in user Inventor ID:', error);
        }
    }

    @wire(getTaskById, { taskId: '$recordId' })
    taskRecord(result) {
        this.taskRecordResult = result;
        const { error, data } = result;
        if (data) {
            this.task = { ...data.task }; 
            this.relatedRecordId = this.task.WhatId;
            this.selectedRelatedId = this.task.WhatId;
            if(this.task.OwnerId){
                this.selectedAssignedId = this.task.OwnerId;
            }
            this.files = result.data.files.map(file => {
                return {
                    ...file,
                     ContentDownloadUrl: `/sfc/servlet.shepherd/document/download/${file.Id}`,
                     displayName: file.Title,
                     type: file.FileType,
                     moveToFinalDocs: file.moveToFinalDocs
                 
                };
            });
            this.preSelectedRows = this.files
                .filter(file => file.moveToFinalDocs)
                .map(file => file.Id);


            console.log('Task data fetched successfully:', JSON.stringify(this.task));
            console.log('Task files fetched successfully:', JSON.stringify(this.files));
            console.log('this.selectedAssignedId in gettaskbyid:',this.selectedAssignedId);
        } else if (error) {
            console.error('Error fetching Task data:', error);
        }
        this.checkLoadingStatus();
    }

    @wire(getRecord, { recordId: '$relatedRecordId', layoutTypes: ['Full'] })
    relatedRecord(result) {
        this.relatedRecordResult = result;
        const { error, data } = result;
        if (data) {
            console.log('data of relatedrecordid:',JSON.stringify(data));
            this.task.WhatId = data.id; 
            this.selectedRelatedId = this.task.WhatId;
            this.selectedRelatedToObject = data.apiName;
            this.relatedToName=data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching related data:', error);
        }
    }
    


    @wire(getTaskFieldsData)
    wiredTaskFieldsData({ error, data }) {
        if (data) {
            data.forEach(field => {
                switch (field.value) {
                    case 'Subject':
                        this.subjectOptions = field.picklistValues || [];
                        console.log('this.subjectOptions:',JSON.stringify(this.subjectOptions));
                        break;
                    case 'Priority':
                        this.priorityOptions = field.picklistValues || [];
                        console.log('this.priorityOptions:',JSON.stringify(this.priorityOptions));
                        break;
                    case 'Direction__c':
                        this.directionOptions = field.picklistValues || [];
                        break;
                    case 'Status':
                        this.statusOptions = field.picklistValues || [];
                        break;
                    case 'Task_Type__c':
                        this.taskTypeOptions = field.picklistValues || [];
                        break;
                    case 'OwnerId':
                        this.assignedToObjectApi = 'User'; 
                        console.log('assignedToObjectApi:'+this.assignedToObjectApi);
                        break;
                    case 'WhatId':
                        this.relatedToObjects = field.referenceToObjects.filter(object => 
                            RelatedObjectOptions.includes(object.value)
                        );
                       /* if(!this.relatedRecordId || this.recordId){ // task is edited or created from myTaskComp
                        this.relatedToObjects = field.referenceToObjects.filter(object => 
                            RelatedObjectOptions.includes(object.value)
                        );
                        }
                        else {// task is created from collaboration tab from record
                            this.relatedToObjects = field.referenceToObjects;
                        }*/
                        break;
                }
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
        this.checkLoadingStatus();
    }

    /* @wire(getRecord, { recordId: USER_ID, fields: USER_FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            console.log('user data:', JSON.stringify(data));
            this.clientId = data.fields.Client_Id__c.value;
            const profileName = data.fields.Profile.value.fields.Name.value;
            console.log('clientId:',this.clientId);
            if(this.clientId){
                this.clientIdCondition = "Client_Id__c = '" + this.clientId + "' AND Active__c = true AND SymphonyLF__User__c != NULL AND SymphonyLF__User__r.IsActive = true";
                console.log('this.clientIdCondition:'+this.clientIdCondition)  
                this.clientRelatedtoCondition = "Client_Id__c ='" + this.clientId + "'";
                console.log('this.clientRelatedtoCondition:',this.clientRelatedtoCondition);
            }
            else{
                this.clientIdCondition = '';
                this.clientRelatedtoCondition ='';
            }
            
        } else if (error) {
            console.error(error);
        }
        this.checkLoadingStatus();
    
    } */


    checkLoadingStatus() {
        if (!this.recordId && this.assignedToObjectApi  ){
            this.loading = false; 
        }else if(this.recordId && this.assignedToObjectApi && this.taskRecordResult){
            this.loading = false; 
            console.log('this.loading in checkloading status:'+this.loading);
        }
    }

    handleObjectChange(event) {
        this.selectedRelatedToObject = event.detail.value; 
        console.log('this.selectedRelatedToObject:',this.selectedRelatedToObject);     
    }


    handleInputChange(event) {
        const field = event.target.dataset.field;
        if (event.target.type === 'checkbox') {
            this.isReminderSet = event.target.checked;
            this.task[field] = this.isReminderSet; 
            if (!this.isReminderSet) {
                this.task['ReminderDateTime'] = null;
                this.reminderDateTime = null;
            }
        } else {
            this.task[field] = event.target.value; 
        }
    }


    handleRelatedToSelection(event) {
        if (event.detail != null && event.detail.length == 1) {
            this.selectedRelatedId = event.detail[0].Id;
            this.task.WhatId = this.selectedRelatedId;
            this.relatedToName=event.detail[0].Name;
            console.log('this.task.Whatid in handle relatedtoselection:',this.task.WhatId);
            }else{
                this.selectedRelatedId = null;
                this.task.WhatId       = null;
                this.relatedToName     = '';
            }
    }

    handleAssignedToSelection(event) {
        if (event.detail != null && event.detail.length == 1) {
        this.selectedAssignedId = event.detail[0].Id;
        this.task.OwnerId = this.selectedAssignedId;
        console.log('this.task.OwnerId in handle assignedtoselection:',this.task.OwnerId);
        }else{
            this.selectedAssignedId = '';
            this.task.OwnerId = this.selectedAssignedId;
        }
        
    }

    
    // Save Task
    async handleSave() {

        const requiredFields = [
            //{ field: this.task.OwnerId, label: 'OwnerId' },
            { field: this.task.Subject, label: 'Subject' },
            { field: this.task.Priority, label: 'Priority' },
            { field: this.task.Status, label: 'Status' }
        ];
        
        let missingFields = requiredFields
            .filter(item => !item.field) 
            .map(item => item.label);   
        
        if (missingFields.length > 0) {
            const missingFieldsMessage = 'These required fields must be completed: ' + missingFields.join(', ');
            this.showToast('Error', missingFieldsMessage, 'error');
            return;
        }
  
        try {
            let { Owner, ...taskData } = this.task; // explicitly remove Owner object
            console.log('taskData:',JSON.stringify(taskData));
            //delete taskData.OwnerId;
            const result = await saveTask({ taskFields: taskData });
                this.taskId = result; 
                //for uploading files for created task
                if (this.uploadedFiles.length > 0) {
                    console.log('this.uploadedFiles.length:',this.uploadedFiles.length);
                    await this.uploadFiles(this.uploadedFiles.map(file => file.documentId), this.taskId);
                }
                //for creating Final documents for selected files
                /* if (this.finalDocumentfiles.length > 0) {
                    await this.createFinalDocuments(this.selectedRelatedToObject, this.finalDocumentfiles, this.selectedRelatedId);
                } */
            this.showToast('Success', 'Task saved successfully!', 'success');

            this.dispatchEvent(new CustomEvent('action', {
                detail: { status: 'save', taskId: this.taskId }
            }));
            this.dispatchEvent(new CustomEvent('refresh'));
             this.dispatchEvent(new CustomEvent('savecomplete', {
            detail: { taskId: this.taskId } // Pass any necessary data
        }));
            this.clearForm();
            await refreshApex(this.relatedRecordResult);
            await refreshApex(this.taskRecordResult);
        } catch (error) {
            this.showToast('Error', 'Task creation failed', 'error');
            console.log('Error while saving the task:',JSON.stringify(error));
        }

        
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }


    clearForm() {
        this.task = {
            Subject: 'Other',
            //SymphonyLF__Title__c: '',
            OwnerId: '',
            Direction__c: 'IN',
            Task_Type__c: '',
            Priority: 'Normal',
            Status: 'Not Started',
            Description: '',
            // Paralegal_Comment__c: '',
            // Attorney_Comment__c: '',
            // Agent_Comment__c: '',
            IsReminderSet: true,
            ReminderDateTime: new Date(new Date().setMinutes(new Date().getMinutes() >= 30 ? 60 : 30, 0, 0)).toISOString(),
            ActivityDate: null,
            WhatId: null,
        };
    }

    handleCancel() {
        this.clearForm();
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                status: 'close'
            }
        }));
        this.dispatchEvent(new CustomEvent('refresh'));
    }

    handleUploadFinished(event) {
        const newFiles = event.detail.files;
        console.log('event.detail in files:',JSON.stringify(event.detail));
        console.log('this.newFiles:', JSON.stringify(newFiles));
        const mappedNewFiles = newFiles.map(file => {
            return {
                ...file,
                ContentDownloadUrl: `/sfc/servlet.shepherd/document/download/${file.documentId}`,
                displayName: file.name ,
                type: file.mimeType
            };
        });

        this.files = [...this.files, ...mappedNewFiles]; 
        this.uploadedFiles = [...this.uploadedFiles, ...newFiles];// only new files

        console.log('Updated files:', JSON.stringify(this.files));//files used to display in datatable
        console.log('this.uploadedFiles:', JSON.stringify(this.uploadedFiles));


    }

    async uploadFiles(fileIds, taskId) {
    
        try {
            await uploadFilesWithTask({ taskId: taskId, fileIds: fileIds });
        } catch (error) {
            console.error('Error linking files to task:', error);
        }
    }


    /* async createFinalDocuments(selectedRelatedToObject, finalDocumentfiles,selectedRelatedId) {
    
        try {
            await createFinalDocuments({ selectedRelatedToObject: selectedRelatedToObject, finalDocumentfiles: finalDocumentfiles,selectedRelatedId:selectedRelatedId });
        } catch (error) {
            console.error('Error linking files to task:', error);
        }
    } */

    async renderedCallback() {
        this.removeExtraDateLabel();
    }

    removeExtraDateLabel(){
        let style = document.createElement('style');
        style.innerText = 'div[class=slds-form-element__help]{display:none;}';
    
        let reminderDateTimeInput = this.template.querySelector("lightning-input[data-field='ReminderDateTime']");
        let activityDateInput = this.template.querySelector("lightning-input[data-field='ActivityDate']");
    
        if (reminderDateTimeInput) {
            reminderDateTimeInput.appendChild(style.cloneNode(true));
        }
        if (activityDateInput) {
            activityDateInput.appendChild(style.cloneNode(true));
        }
    }

    get headerText() {
        return this.recordId ? 'Edit Task' : 'New Task';
    }

    handleNavigateToWhatId(event) {
        const whatId = event.currentTarget.dataset.recordId;
        if (whatId) {
            console.log('Navigating to WhatId:', whatId);
            const recordPageUrl = `/lightning/r/Record/${whatId}/view`;
    
            window.open(recordPageUrl, '_blank');
        }
    }

    
    handleRowSelection(event) {
        let selectedRows = event.detail.selectedRows;
        let nonPreSelectedRows=[];
        if (this.preSelectedRows && this.preSelectedRows.length > 0) {
            const deselectedPreSelectedRows = this.preSelectedRows.filter(
                preSelectedRow => !selectedRows.some(row => row.Id === preSelectedRow)
            );

            if (deselectedPreSelectedRows.length > 0) {
                this.showToast('Info', 'This file is already added to Final Documents and cannot be deselected..', 'info');

                const restoredRows = deselectedPreSelectedRows.map(rowId => ({
                    Id: rowId
                }));
                selectedRows = [...selectedRows, ...restoredRows];
                this.preSelectedRows = [...this.preSelectedRows];
            }
            nonPreSelectedRows = selectedRows.filter(
                row => !this.preSelectedRows.includes(row.Id)
            );
        }else{
            nonPreSelectedRows = selectedRows;
        }
        
        const assetTypeMapping = {
            'SymphonyLF__Patent__c': 'Patent',
            'SymphonyLF__Trademark__c' : 'Trademark',
            'SymphonyLF__Design__c': 'Design',
            'SymphonyLF__General_Matter__c': 'General Matter',
            'SymphonyLF__Copyright__c': 'Copyright',
            'SymphonyLF__Dispute_Opposition__c': 'Dispute Opposition',
            'SymphonyLF__Design_Family__c': 'Design Family',
            'SymphonyLF__Patent_Family__c': 'Patent Family',
            'Conflict_Check__c': 'Conflict Check',
            'SymphonyLF__Mark__c': 'Mark'
        };
        const assetTypeValue = assetTypeMapping[this.selectedRelatedToObject] || '';
        
        this.finalDocumentfiles = nonPreSelectedRows.map(row => ({
            Id: row.Id || row.documentId, 
            displayName: row.displayName,
            assetTypeValue: assetTypeValue
        }));
        console.log('this.finalDocumentfiles=>', JSON.stringify(this.finalDocumentfiles));
    }

    get getBooleanValue() {
        /* const NotRequiredObjectsForFinalDocs = [
            'SymphonyLF____Adverse_Party_Assets__c',
            'SymphonyLF____Adverse_Party__c',
            'SymphonyLF__Trademark_Search__c',
            'SymphonyLF____D_O_Adverse_Parties__c',
            'Related_Entities__c',
            'Search_Instruction__c',
            'Copyright_Registration__c',
        ]; */
        //if (!this.selectedRelatedToObject) {
            //console.log('returned getbooleanValue: true');
            return true;
        //}
    
        //return NotRequiredObjectsForFinalDocs.includes(this.selectedRelatedToObject);
    }

}