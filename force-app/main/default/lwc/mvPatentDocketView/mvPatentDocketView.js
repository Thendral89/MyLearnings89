import { LightningElement, wire, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import FA from "@salesforce/resourceUrl/FA";
import { createElement } from 'lwc';
import mvDocketFields from 'c/mvDocketFields';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
//import CLIENT_ID_FIELD from '@salesforce/schema/User.Client_Id__c';
import DOCKET_OBJECT from '@salesforce/schema/SymphonyLF__Docketing_Activity__c';
import ASSIGNED_TO_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Assigned_To_User__c";
import COMMENTS_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.Comments__c";
import COMPLETED_DATE_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Completion_Date__c";
import CLOSED_DATE_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Closed_Date__c";
import IS_COMPLETED_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Is_Completed__c";
import IS_CLOSED_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Is_Closed__c";
import ID_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.Id";
import DUE_DATE_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Due_Date__c";
import REASON_TO_CLOSE_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Reason_to_Close__c";
import REASON_TO_COMPLETE_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Reason_to_Complete__c";
import STATUS_FIELD from '@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Status__c';
import REPORTED_FIELD from '@salesforce/schema/SymphonyLF__Docketing_Activity__c.Reported__c';
import MassFilesDownload from 'c/lwcDocketViewSubContent';
import { updateRecord } from 'lightning/uiRecordApi';

/* Check for User Permissions */
import hasDocketAddAdhocPermission from '@salesforce/customPermission/Docket_Add_Adhoc_Activity';
import hasDocketAddEventPermission from '@salesforce/customPermission/Docket_Add_Event';
import hasDocketReportExternalPermission from '@salesforce/customPermission/Docket_Report_External';
import hasDocketReportInternalPermission from '@salesforce/customPermission/Docket_Report_Internal';
import hasDocketUpdatePermission from '@salesforce/customPermission/Docket_Update';

import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    getTabInfo,
    openSubtab,
} from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPatentDocketActivities from '@salesforce/apex/mvPatentDocketUtilities.getPatentDocketActivities';
import getCurrentUserProfile from '@salesforce/apex/mvPatentDocketUtilities.getCurrentUserProfile';
import reportInternal from '@salesforce/apex/mvDocketUtilities.reportInternal';
import downloadDocuments from '@salesforce/apex/cmpAPiManagDocumentCtrl.DownloadDocuments';

const PAGINATOR_DEFAULT_SIZE = 100;
const PAGINATOR_SIZE_SELECTOR = [25, 50, 100, 500];

export default class MvPatentDocketView extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track selectedTabName = 'Open Docket Activities';
    @track selectedTabIcon = 'standard:product_request';
    @track selectedTabCount = 0;
    @track isSpinner = false;

    // Variables for Edit Modal Popup and Selected Records
    @track showEditModal = false;
    @track selectedRowsData = [];
    @track showExpandModal = false;

    @track assignedTo = '';
    @track allComments = '';
    @track dueDate = '';
    @track completionDate = '';
    @track closedDate = '';
    @track isCompleted = false;
    @track isClosed = false;
    @track reportToClient = false;
    @track reasonToComplete = '';
    @track reasonToClose = '';

    @track selectedRecords = [];
    @track selectedFilter = 'OPEN';
    @track status = '';
    @track statusOptions = [];
    @track reportedOptions = [];
    @track userProfile;
    @track showAllFields = false;
    @track fromEditIcon = false;
    adminProfiles = ['System Administrator', 'MCCIP Docketing Management','MCCIP Docketer'];


    @wire(getObjectInfo, { objectApiName: DOCKET_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    wiredStatusPicklist({ error, data }) {
        if (data) {
            this.statusOptions = data.values;
            console.log('status options--->',JSON.stringify(this.statusOptions));
        } else if (error) {
            console.error('Error fetching status picklist values:', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REPORTED_FIELD
    })
    wiredReportPicklist({ error, data }) {
        if (data) {
            this.reportedOptions = data.values;
        } else if (error) {
            console.error('Error fetching reported picklist values:', error);
        }
    }

    @wire(getCurrentUserProfile)
    wiredUserProfile({ error, data }) {
        if (data) {
            this.userProfile = data; 
            console.log('user profile--->',JSON.stringify(this.userProfile));
            this.showAllFields = this.adminProfiles.includes(this.userProfile);
        } else if (error) {
            this.userProfile = undefined;
            this.showAllFields = false;
            console.error('Error fetching user profile: ', error);
        }
    }

    @track clientId = '';
    clientIdCondition = '';

    currentFeatureSettings = {
        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR
    };

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;


    showAction = false;
    flowApiName = '';
    flowInputVariables = {};

    get reportExternalAccess() {
        return hasDocketReportExternalPermission;
    }

    get reportInternalAccess() {
        return hasDocketReportInternalPermission;
    }

    get hasAddAdhocActivityAccess() {
        return hasDocketAddAdhocPermission;
    }

    get hasAddEventAccess() {
        return hasDocketAddEventPermission;
    }

    get hasDocketUpdateAccess() {
        return hasDocketUpdatePermission;
    }

    handleFlowStatusChange(event) {
        try {
            if (event.detail.status === 'FINISHED') {
                this.showAction = false;
                this.fetchDocketActivities();
            }
        } catch (err) {
            alert('JS Error ::  :: handleFlowStatusChange')
            console.error(err)
        }
    }

    handleCancelAndClose() {
        try {
            this.showAction = false;
        } catch (err) {
            alert('JS Error ::  :: handleCancelAndClose')
            console.error(err)
        }
    }

    handleAddEvent() {
        try {
            this.flowApiName = 'SymphonyLF__Docket_UI_Add_Event_Workflow';
            this.flowInputVariables = [
                {
                    name: 'parentId', // Maybe
                    type: 'String',
                    value: this.recordId
                }
            ];
            this.showAction = true;
        } catch (err) {
            alert('JS Error ::  :: handleAddEvent')
            console.error(err)
        }
    }

    handleAdHoc() {
        try {
            this.flowApiName = 'SymphonyLF__Create_Adhoc_Activity';
            this.flowInputVariables = [
                {
                    name: 'parentId',
                    type: 'String',
                    value: this.recordId
                }
            ];
            this.showAction = true;
        } catch (err) {
            alert('JS Error ::  :: handleAddEvent')
            console.error(err)
        }
    }

    @track emailMessageId = null; 
    @track emailAction; 
    handleNewEmailClose() {
        this.reportToClient = false;
    }

    @track docketId = null;
    handleReportExternal() { 
        if (!this.selectedRecords || this.selectedRecords.length === 0) {
            this.showToast('Error', 'Please select at least one record to report external.', 'error');
            return;
        } else if (!this.selectedRecords || this.selectedRecords.length > 1) {
            this.showToast('Error', 'Please select only one record to report external.', 'error');
            return;
        }
        console.log('Selected Records:', JSON.stringify(this.selectedRecords));
        this.docketId = this.selectedRecords[0].recordId;
        this.reportToClient = true;
        this.emailMessageId = null; 
        this.emailAction = 'new';
    }

    handleEmailSent() {
        if (this.selectedRecords.length === 0) {
            return;
        }
    
        let recordInputs = this.selectedRecords.map(record => {
            return {
                fields: {
                    Id: record.recordId,
                    Reported__c: 'Reported to Client'
                }
            };
        });
    
        Promise.all(recordInputs.map(recordInput => updateRecord(recordInput)))
            .then(() => {
                //this.showToast('Success', 'Email sent and records updated successfully!', 'success');
                this.reportToClient = false;
                this.fetchDocketActivities(); // Refresh table
            })
            .catch(error => {
                console.error('Error updating records:', error);
                this.showToast('Error', 'Error updating records. Please try again.', 'error');
            });
    }

    handleCheckboxChange(event) {
        const field = event.target.name;
        if (field === "isCompleted") {
            this.isCompleted = event.target.checked;
            if (this.isCompleted) {
                this.completionDate = this.getTodayDate(); 
            } else {
                this.completionDate = '';
                this.reasonToComplete = '';
            }
        }
        if (field === "isClosed") {
            this.isClosed = event.target.checked;
            if (this.isClosed) {
                this.closedDate = this.getTodayDate(); 
            } else {
                this.closedDate = '';
                this.reasonToClose = '';
            }
        }
    }

    getTodayDate() {
        return new Date().toISOString().split('T')[0];
    }

    
    handleReportOut() {
        try {
            if (
                !this.selectedRecords
                ||
                !this.selectedRecords.length
            ) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select records to Report Internal',
                        variant: 'error'
                    })
                );
                return;
            }

            console.log('this.selectedRecords', JSON.stringify(this.selectedRecords));
            let selectedRecordList = this.selectedRecords.map(e => { return e.recordId });
            reportInternal({
                'assetId': this.recordId,
                'docketEntries': selectedRecordList,
                'emailTemplate': 'Reports_Out_Internal'
            })
                .then(response => {
                    try {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Docketed items reported successfully',
                                variant: 'success'
                            })
                        );
                    } catch (err) {
                        alert('JS Error in Server callback ::  :: handleReportOut');
                    }
                })
                .catch(error => {
                    alert('Server Error ::  :: handleReportOut :: apexMethod => reportInternal');
                    console.error(JSON.stringify(error));
                })
        } catch (err) {
            alert('JS Error ::  :: handleReportOut')
            console.error(err)
            console.error(this.serializeError(err))
        }
    }

    serviceRepositoryForApplicableRulesName;
    showApplicableRules = false;

    setServiceRepositoryForApplicableRulesName() {
        try {
          //  return "patentApplicableRules";
            console.log('serviceRepositoryForApplicableRulesName this.objectApiName', this.objectApiName);
            if (this.objectApiName == 'SymphonyLF__Patent__c') {
                this.serviceRepositoryForApplicableRulesName = 'patentApplicableRules';
            }
            else if(this.objectApiName == 'SymphonyLF__Trademark__c'){
                this.serviceRepositoryForApplicableRulesName = 'trademarkApplicableRules';
            }
            else{
                console.log('Applicable rules : Else statement executed')
            }
            console.log('this.serviceRepositoryForApplicableRulesName ', this.serviceRepositoryForApplicableRulesName)
            this.showApplicableRules = true;
        } catch (err) {
            alert('JS Error ::  :: serviceRepositoryForApplicableRulesName')
            console.error(err)
        }
    }

    /* @wire(getRecord, { recordId: USER_ID, fields: [CLIENT_ID_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.clientId = data.fields.Client_Id__c.value;
            this.clientIdCondition = this.clientId ? `Client_Id__c ='Syngenta'` : '';
        } else if (error) {
            console.error(error);
        }
    } */

    async openTab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list', focus = true, label = '') {
        try {
            console.log('openTab');
            // Ensure that we're in a console app
            if (!this.isConsoleNavigation) {
                return;
            }

            // Open contact list a new tab
            await openTab({
                pageReference: {
                    "type": type,
                    attributes: {
                        "objectApiName": objectApiName,
                        "actionName": actionName,
                        "recordId": recordId
                    }
                },
                "focus": focus,
                "label": label
            });
        }
        catch (err) {
            alert('JS Error : ccDashboard : openTab');
        }
    }


    async findEnclosingTabAndOpenSubtab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
        try {
            // Ensure that we're in a console app and that we have a tab open
            if (!this.isConsoleNavigation || !this.enclosingTabId) {
                return;
            }

            let tabInfo = await getTabInfo(this.enclosingTabId);

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
            alert('JS Error : mvPatentDocketView : findEnclosingTabAndOpenSubtab');
            console.error(err);
            console.error(JSON.stringify(err));
            console.error(this.serializeError(err));
        }

    }

    handleExpandClick() {
        this.showExpandModal = true;
    }

    handleExpandModalClose() {
        this.showExpandModal = false;
    }

    /* handleInputChange(event) {
        const fieldName = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this[fieldName] = value;
    } */
    handleInputChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.target.value;
    }

    handleAssignedToChange(event) {
        this.assignedTo = event.detail[0].Id;
    }

    isMassUpdating = false;
    handleSave() {
        try {
            if (
                !this.selectedRecords
                ||
                !this.selectedRecords.length
            ) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select records to Update',
                        variant: 'error'
                    })
                );
                return;
            }

            this.isMassUpdating = true;

            const recordInputs = this.selectedRecords.map(e => {

                const fields = {};

                if(e.recordId)
                fields[ID_FIELD.fieldApiName] = e.recordId;

                if(this.assignedTo)
                fields[ASSIGNED_TO_FIELD.fieldApiName] = this.assignedTo;

                if(this.allComments)
                fields[COMMENTS_FIELD.fieldApiName] = this.allComments;

                if(this.completionDate)
                fields[COMPLETED_DATE_FIELD.fieldApiName] = this.completionDate;

                if(this.closedDate)
                fields[CLOSED_DATE_FIELD.fieldApiName] = this.closedDate;

                if(this.isCompleted)
                fields[IS_COMPLETED_FIELD.fieldApiName] = this.isCompleted;

                if(this.isClosed)
                fields[IS_CLOSED_FIELD.fieldApiName] = this.isClosed;

                if(this.dueDate)
                fields[DUE_DATE_FIELD.fieldApiName] = this.dueDate;

                if(this.reasonToClose)
                fields[REASON_TO_CLOSE_FIELD.fieldApiName] = this.reasonToClose;

                if(this.reasonToComplete)
                fields[REASON_TO_COMPLETE_FIELD.fieldApiName] = this.reasonToComplete;

                if(this.docketStatus)
                fields[STATUS_FIELD.fieldApiName] = this.docketStatus;

                if(this.docketReporting)
                fields[REPORTED_FIELD.fieldApiName] = this.docketReporting;
                

                return { fields };
            });

            const promises = recordInputs.map(recordInput => updateRecord(recordInput));

            Promise.all(promises)
                .then(result => {
                    console.log('All update successful');

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records updated successfully',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    console.log('All update failed',error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );


                })
                .finally(() => {
                    this.showEditModal = false;
                    this.fetchDocketActivities();
                    this.handleBulkUpdateReset();
                });
                this.isMassUpdating = false;
        } catch (err) {
            alert('JS Error :: handleSave');
            console.error(JSON.stringify(err));
            console.error(this.serializeError(err));
        }

    }

    handleRowSelection(event) {
        console.log('Row Event Selection Called');
        console.log(JSON.stringify(event));
        this.selectedRecords = event.detail.rows;
        console.log('Selected Records : ' + JSON.stringify(this.selectedRecords));
    }

    handleFilters(event) {
        console.log('In Handle Filters');
        this.selectedFilter = event.currentTarget.dataset.filtertype;
         this.highlightSelectedTile(this.selectedFilter);
        this.filterAndUpdateTable(this.selectedFilter);
    }

    highlightSelectedTile(selectedFilter) {

            setTimeout(() => {
            const allTiles = this.template.querySelectorAll('.slds-badge');
            
            allTiles.forEach(tile => {
                tile.classList.remove('highlighted');
            });

            let selectedTile = this.template.querySelector(`[data-filtertype="${selectedFilter}"]`);
            if (selectedTile) {
                selectedTile.classList.add('highlighted');
            }
        }, 0);
    }

    filteredData = [];
    get
    finalData(){
         setTimeout(() => {
            console.log('inside finalData filtered data -->', JSON.stringify(this.filteredData));
            console.log('inside finalData records -->', JSON.stringify(this.records));
        }, 0);
        
       try{
           return this.filteredData.length ? this.filteredData : this.records;
       }catch(err){
           alert('JS Error ::  :: finalData')
           console.error(err)
       }
    }

    // filterAndUpdateTable(newSelection) {
    //     const today = new Date();

    //     const getDifferenceInDays = (dueDateStr) => {
    //         const dueDateObj = new Date(dueDateStr);
    //         const differenceInTime = dueDateObj.getTime() - today.getTime();
    //         return differenceInTime / (1000 * 60 * 60 * 24);
    //     };

    //     const filteredData = this.records.filter((item) => {
    //         console.log('Item: ' + JSON.stringify(item));
    //         switch (newSelection) {
    //             case "OPEN":
    //                 this.selectedTabName = 'Open Docket Activities';
    //                 this.selectedTabIcon = 'standard:product_request';
    //                 return item.isOpen === true;

    //             case "CLOSED":
    //                 this.selectedTabName = 'Closed Docket Activities';
    //                 this.selectedTabIcon = 'standard:survey';
    //                 return item.isClosed === true;

    //             case "NEXT30": {
    //                 this.selectedTabName = 'Docket Activities Next 30 Days';
    //                 this.selectedTabIcon = 'standard:event';
    //                 const diff = getDifferenceInDays(item.dueDate);
    //                 return diff >= 0 && diff <= 30;
    //             }
    //             case "NEXT60": {
    //                 this.selectedTabName = 'Docket Activities Next 60 Days';
    //                 this.selectedTabIcon = 'standard:event';
    //                 const diff = getDifferenceInDays(item.dueDate);
    //                 return diff >= 0 && diff <= 60;
    //             }
    //             case "PASTDUE": {
    //                 this.selectedTabName = 'Docket Activities Past Due';
    //                 this.selectedTabIcon = 'standard:operating_hours';
    //                 const diff = getDifferenceInDays(item.dueDate);
    //                 return (!item.isClosed && diff < 0);
    //             }
    //             case "ADHOC":
    //                 this.selectedTabName = 'Adhoc Docket Activities';
    //                 this.selectedTabIcon = 'standard:document_reference';
    //                 if(item.docketTriggerType === 'Event' && (!item.docketedById) ){
    //                     return true;
    //                 }else{
    //                     return false;
    //                 }

    //             case "EVENTS":
    //                 this.selectedTabName = 'Event Docket Activities';
    //                 this.selectedTabIcon = 'standard:events';
    //                 if(item.docketTriggerType === 'Event' && (item.docketedById) ){
    //                     return true;
    //                 }else{
    //                     return false;
    //                 }

    //             case "ALL":
    //                 this.selectedTabName = 'All Docket Activities';
    //                 this.selectedTabIcon = 'standard:work_plan_template';
    //                 return item.isOpen === true;

    //             default:
    //                 this.selectedTabName = 'Open Docket Activities';
    //                 this.selectedTabIcon = 'standard:product_request';
    //                 return item.isOpen === true;
    //         }
    //     });

    //     this.filteredData = filteredData;

    //     this.selectedTabCount = filteredData.length;

    //     console.log('newSelection ', newSelection);
    //     console.log('this.selectedTabCount ', this.selectedTabCount);
    //     console.log('this.selectedTabName ', this.selectedTabName);
    //     try {
    //         const tableElement = this.template.querySelector('.lwcMvDataTable');
    //         console.log('tableElement ', tableElement);
    //         if (tableElement) {
    //             tableElement.updateTableData(filteredData);
    //         }
    //     } catch (err) {
    //         alert('JS Error :: updateTableData');
    //         console.error(err);
    //     }
    // }

    filterAndUpdateTable(newSelection) {
    const today = new Date();

    // 1. Set tab name and icon once
    switch (newSelection) {
        case "OPEN":
            this.selectedTabName = 'Open Docket Activities';
            this.selectedTabIcon = 'standard:product_request';
            break;
        case "CLOSED":
            this.selectedTabName = 'Closed Docket Activities';
            this.selectedTabIcon = 'standard:survey';
            break;
        case "NEXT30":
            this.selectedTabName = 'Docket Activities Next 30 Days';
            this.selectedTabIcon = 'standard:event';
            break;
        case "NEXT60":
            this.selectedTabName = 'Docket Activities Next 60 Days';
            this.selectedTabIcon = 'standard:event';
            break;
        case "PASTDUE":
            this.selectedTabName = 'Docket Activities Past Due';
            this.selectedTabIcon = 'standard:operating_hours';
            break;
        case "ADHOC":
            this.selectedTabName = 'Adhoc Docket Activities';
            this.selectedTabIcon = 'standard:document_reference';
            break;
        case "EVENTS":
            this.selectedTabName = 'Event Docket Activities';
            this.selectedTabIcon = 'standard:events';
            break;
        case "ALL":
            this.selectedTabName = 'All Docket Activities';
            this.selectedTabIcon = 'standard:work_plan_template';
            break;
        default:
            this.selectedTabName = 'Open Docket Activities';
            this.selectedTabIcon = 'standard:product_request';
            break;
    }

    // 2. Filter the data separately
    const getDifferenceInDays = (dueDateStr) => {
        const dueDateObj = new Date(dueDateStr);
        const differenceInTime = dueDateObj.getTime() - today.getTime();
        return differenceInTime / (1000 * 60 * 60 * 24);
    };

    const filteredData = this.records.filter((item) => {
        switch (newSelection) {
            case "OPEN":
                return item.isClosed === false;
            case "CLOSED":
                return item.isClosed === true;
            case "NEXT30": {
                const diff = getDifferenceInDays(item.dueDate);
                return diff >= 0 && diff <= 30;
            }
            case "NEXT60": {
                const diff = getDifferenceInDays(item.dueDate);
                return diff >= 0 && diff <= 60;
            }
            case "PASTDUE": {
                const diff = getDifferenceInDays(item.dueDate);
                return (!item.isClosed && diff < 0);
            }
            case "ADHOC":
                return item.docketTriggerType === 'Event' && (!item.docketedById);
            case "EVENTS":
                return item.docketTriggerType === 'Event' && item.docketedById;
            case "ALL":
                return true;
            default:
                return true;
        }
    });

    this.filteredData = filteredData;
    console.log('filtered data--->',JSON.stringify(this.filteredData));
    this.selectedTabCount = filteredData.length;

    try {
        const tableElement = this.template.querySelector('.lwcMvDataTable');
        if (tableElement) {
            tableElement.updateTableData(filteredData);
        }
    } catch (err) {
        alert('JS Error :: updateTableData');
        console.error(err);
    }
}


    handleBulkUpdate() {
        if (!this.selectedRecords || this.selectedRecords.length === 0) {
            this.showToast('Error', 'Please select at least one record to update.', 'error');
            return;
        }
        this.fromEditIcon = false;
        this.isMassUpdating = false;
        this.showEditModal = true;
    }

    handleCancelEdit() {
        this.showEditModal = false;
    }

    showToast(title, message, variant) {
        console.log('Called :: showNotification');
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    sfdcURL = window.location.origin;
    columns = [
        {
            formatter: "rowSelection",
            titleFormatter: "rowSelection",
            field: "isSelected",
            hozAlign: "center",
            frozen: true,
            headerSort: false,
            width: "1%",
            cellClick: (e, cell) => {
                cell.getRow().toggleSelect();
            }
        },
        // { formatter: "rownum", hozAlign: "center", width: 40 },
        {
            title: "", field: "isExpanded", hozAlign: "center",frozen: true, headerSort: false, width: "1%",
            formatter: function (cell, formatterParams) {
                const rowData = cell.getRow().getData();
              //  if (rowData.documentRecords && rowData.documentRecords.length > 0) {
                    return rowData.isExpanded
                        ? "<i class='fa fa-minus-circle' title='Collapse'></i>"
                        : "<i class='fa fa-plus-circle' title='Expand'></i>";
             //   }
             //   return "";
            },
            cellClick: (e, cell) => {
                const rowData = cell.getRow().getData();
              //  if (rowData.documentRecords && rowData.documentRecords.length > 0) {
                    const isNowExpanded = !rowData.isExpanded;
                    cell.getRow().update({ isExpanded: isNowExpanded });

                    const rowElement = cell.getRow().getElement();
                    let container = rowElement.querySelector('.lwcMvDataTable');
                    if (!container) {
                        container = document.createElement('div');
                        container.classList.add('lwcMvDataTable');
                        rowElement.appendChild(container);
                    }

                    container.innerHTML = '';

                    if (isNowExpanded) {
                        const childComponent = createElement('c-lwc-docket-view-sub-content', {
                            is: MassFilesDownload
                        });
                        childComponent.recordId = rowData.recordId;
                        childComponent.numberOfFiles = rowData.documentRecords?.length
                        // childComponent.objectApiName = 'iManage_Documents__c';
                        
                        container.appendChild(childComponent);
                        this.template.querySelector('.lwcMvDataTable').updateTableHeight();
                    }

                    /* if (!isNowExpanded) {
                        
                    } else {
                        this.template.querySelector('.lwcMvDataTable').updateTableHeight('800px');
                       // this.template.querySelector('.lwcMvDataTable').updateTableHeight();
                    } */


                    
              //  }
            }

        },
        /* {
            title: "",
            width: "1%",
            hozAlign: "center",
            frozen: true,
            formatter: function (cell, formatterParams) {
                const rowData = cell.getRow().getData();
                if (rowData.documentRecords && rowData.documentRecords.length > 0) {
                    return "<i style='width:32px;height:32px;' class='fa fa-cloud-download downloadIcon' title='Download Document'></i>";
                } else {
                    return "<span></span>";
                }
            },
            cellClick: (e, cell) => {
                const rowData = cell.getRow().getData();
                if (rowData.documentRecords && rowData.documentRecords.length > 0) {
                    const docId = rowData.documentRecords[0].documentId;
                    const docTitle = rowData.documentRecords[0].documentTitle;

                    this.downloadIManageDoc(docId, docTitle);
                }
            }
        }, */
        {
            title: "",field: "Document", width: '1%', hozAlign: "center", frozen: true,headerSort: false, 
            formatter: function (cell, formatterParams) {
                return "<i style='width:32px;height:32px;' class='fa fa-cloud-upload' title='Document'></i>"; // Default icon 
            },
            cellClick: (e, cell) => {
                const rowData = cell.getRow().getData();
                const iManageEmailObjectId = rowData.recordId;
                const parentAssetId = this.recordId;
                console.log("iManageEmailObjectId: " + iManageEmailObjectId);
                console.log(
                    "recordId: " + parentAssetId);
                this.handleImanageInit(iManageEmailObjectId, parentAssetId);
            }
        },
        // {
        //     title: "DA#", width: "11%", field: "recordName", frozen: true,
        //     formatter: (cell, formatterParams) => {
        //         var value = cell.getValue();
        //         let recordId = cell.getRow().getData().recordId;
        //         let output;
        //         if (this.isConsoleNavigation) {
        //             output = document.createElement("a");
        //             let href = this.sfdcURL + "/" + recordId;
        //             output.href = href;
        //             output.style.fontWeight = "bold";
        //             output.textContent = value;
        //             output.addEventListener("click", (event) => {
        //                 event.preventDefault();
        //                 this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
        //             });
        //         }
        //         else {
        //             output = "<span style='color:#c29304; font-weight:bold;'><a target='_blank' href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
        //         }
        //         return output;
        //     }
        // },
        {
            title: "Event Name", width: "20%", headerFilter: true, frozen: true, field: "docketAction", 
            formatter: (cell, formatterParams) => {
                var value = cell.getValue();
                let recordId = cell.getRow().getData().recordId;
                let output;
                if (this.isConsoleNavigation) {
                    output = document.createElement("a");
                    let href = this.sfdcURL + "/" + recordId;
                    output.href = href;
                    output.style.fontWeight = "bold";
                    output.textContent = value;
                    output.addEventListener("click", (event) => {
                        event.preventDefault();
                        this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
                    });
                }
                else {
                    output = "<span style='color:#c29304; font-weight:bold;'><a target='_blank' href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                }
                return output;
            }
        },
        {
            title: "Comments", width: "27%", headerFilter: "input", field: "docketComments", formatter: "html",
            formatter: (cell, formatterParams) => {

                const commentValue = cell.getValue() || "";
                return `<div style="white-space: pre-wrap;">${commentValue}</div>`;

                /* var isClosed = cell.getRow().getData().isClosed;
                var value = cell.getValue();

                var docketId = cell.getRow().getData().recordId;
                console.log('Docket ID : + ' + docketId);

                var cellEl = cell.getElement(); //get cell DOM element

                try {

                    const divComponent = document.createElement('div');
                    divComponent.id = docketId;
                    const childComponent = createElement('c-mv-docket-fields', {
                        is: mvDocketFields
                    });
                    console.log(childComponent);
                    // Assign properties correctly
                    childComponent.recordId = docketId;
                    childComponent.objectName = 'SymphonyLF__Docketing_Activity__c';
                    childComponent.fieldName = 'SymphonyLF__Comments__c';
                    childComponent.value = value;

                    childComponent.isFormattedText = true;
                    childComponent.updateableFieldName = 'Comments__c';
                    //childComponent.updateRecordId(docketId);
                    divComponent.appendChild(childComponent);

                    //add buttons to cell
                    // return cellEl.appendChild(childComponent);
                    return divComponent;

                } catch (err) {
                    // alert('JS Error :');
                    console.log('Err :  ' + err);
                    console.error(JSON.stringify(err));
                } */
            }
        },        
        {
            title: "Due Date", width: "9%", headerFilter: "input", field: "dueDate", formatter: (cell, formatterParams) => {
                var value = cell.getValue();
                var recordSatus = cell.getRow().getData().recordStatus;
                var isClosed = cell.getRow().getData().isClosed;

                console.log('Record Status : ' + recordSatus);
                console.log('Due Date : ' + value);
                value = moment(value).format("ll");
                if (recordSatus == 'FUTURE')
                    if (!isClosed)
                        return "<span class='greentag' style='font-weight:bold;'>" + value + "</span>";
                    else
                        return "<span class='greentag' style='font-weight:bold;text-decoration:line-through'>" + value + "</span>";

                else if (recordSatus == 'PAST')
                    if (!isClosed)
                        return "<span class='redtag' style='font-weight:bold;'>" + value + "</span>";
                    else
                        return "<span class='redtag' style='font-weight:bold;text-decoration:line-through'>" + value + "</span>";
                else
                    return "<span style='font-weight:bold;'></span>";

            },
            headerFilterFunc: function(headerValue, rowValue) {
                if (!rowValue) return false;
                const formatted = moment(rowValue).format("ll").toLowerCase(); // e.g., "may 25, 2024"
                return formatted.includes(headerValue.toLowerCase());
            }
        },
        {
            title: "Status", width: "7%", headerFilter: "input", field: "docketStatus", 
            // headerFilterFunc: function(headerValue, rowValue) {
            //    return rowValue?.toLowerCase().includes(headerValue.toLowerCase());
            // },
            // mutator: function(value, data) {
            //     return data.docketStatus;
            // },
            formatter: (cell, formatterParams) => {
                let status;
                const row = cell.getRow().getData();
                const statusValue = row.docketStatus;
                const isClosed = cell.getRow().getData().isClosed;
                const isOpen = cell.getRow().getData().isOpen;
                console.log("isOpen:",isOpen);
                console.log("isClosed:",isClosed);
                console.log("Row data:", row);
                console.log("Status value:", statusValue);
                
                return `<div>${statusValue || ''}</div>`;
                

               

                /*var isClosed = cell.getRow().getData().isClosed;
                var value = cell.getValue();

                var docketId = cell.getRow().getData().recordId;
                console.log('Docket ID : + ' + docketId);

                var cellEl = cell.getElement(); //get cell DOM element

                try {

                    const divComponent = document.createElement('div');

                    const childComponent = createElement('c-mv-docket-fields', {
                        is: mvDocketFields
                    });
                    console.log(childComponent);
                    // Assign properties correctly
                    childComponent.recordId = docketId;
                    childComponent.objectName = 'SymphonyLF__Docketing_Activity__c';
                    childComponent.fieldName = 'SymphonyLF__Status__c';
                    childComponent.updateableFieldName = 'SymphonyLF__Status__c';
                    //childComponent.updateRecordId(docketId);
                    divComponent.appendChild(childComponent);
                    //add buttons to cell
                    // return cellEl.appendChild(childComponent);
                    return divComponent;

                } catch (err) {
                    // alert('JS Error :');
                    console.log('Err :  ' + err);
                    console.error(JSON.stringify(err));
                }*/
            }
        }, 
        {
            title: "Assigned To", width: "17%", headerFilter: true, field: "assignedTo", formatter: (cell, formatterParams) => {

                const assignedToValue = cell.getValue() || "";
                return `<div style="white-space: pre-wrap;">${assignedToValue}</div>`;

               /*var isClosed = cell.getRow().getData().isClosed;
                var value = cell.getValue();


                var docketId = cell.getRow().getData().recordId;
                console.log('Docket ID : + ' + docketId);

                var cellEl = cell.getElement(); //get cell DOM element

                 try {

                    const divComponent = document.createElement('div');

                    const childComponent = createElement('c-mv-docket-fields', {
                        is: mvDocketFields
                    });
                    console.log(childComponent);
                    // Assign properties correctly
                    childComponent.recordId = docketId;
                    childComponent.objectName = 'SymphonyLF__Docketing_Activity__c';
                    childComponent.fieldName = 'SymphonyLF__Assigned_To_User__c';
                    childComponent.updateableFieldName = 'SymphonyLF__Assigned_To_User__c';
                    //childComponent.updateRecordId(docketId);
                    divComponent.appendChild(childComponent);
                    //add buttons to cell
                    // return cellEl.appendChild(childComponent);
                    return divComponent;

                } catch (err) {
                    // alert('JS Error :');
                    console.log('Err :  ' + err);
                    console.error(JSON.stringify(err));
                }*/
                // if (value != undefined)
                // return "<span style='font-weight:bold;'>" + cellEl.appendChild(childComponent) + "</span>";
            }
        },
        {
            title: "Reported?", width: "9%", headerFilter: "input", field: "docketReporting", formatter: "html",
            formatter: (cell, formatterParams) => {
                
                var value = cell.getValue();
                if(value === 'Reported to Client')
                    return "<span class='greentag'>Reported to Client</span>";
                else if (value === 'To be Reported')
                    return "<span class='greytag'>" + value + "</span>";
                
                return "<span class='redtag'>" + value + "</span>";

               /*var isClosed = cell.getRow().getData().isClosed;
                var value = cell.getValue();

                var docketId = cell.getRow().getData().recordId;
                console.log('Docket ID : + ' + docketId);

                var cellEl = cell.getElement(); //get cell DOM element

                 try {

                    const divComponent = document.createElement('div');
                    divComponent.id = docketId;
                    const childComponent = createElement('c-mv-docket-fields', {
                        is: mvDocketFields
                    });
                    console.log(childComponent);
                    // Assign properties correctly
                    childComponent.recordId = docketId;
                    childComponent.objectName = 'SymphonyLF__Docketing_Activity__c';
                    childComponent.fieldName = 'Reported__c';
                    childComponent.value = value;
                    
                    if (value == 'Reported to Client') {
                        childComponent.applyGreenTag = true;
                    }

                    childComponent.isFormattedText = true;
                    childComponent.updateableFieldName = 'Reported__c';
                    //childComponent.updateRecordId(docketId);
                    divComponent.appendChild(childComponent);

                    //add buttons to cell
                    // return cellEl.appendChild(childComponent);
                    return divComponent;

                } catch (err) {
                    // alert('JS Error :');
                    console.log('Err :  ' + err);
                    console.error(JSON.stringify(err));
                }*/
            }    
        },
        {
            title: "", field: "actions", hozAlign: "center", headerSort: false, width: 40, formatter: () => {
                return `<i class="fa fa-regular fa-edit edit-icon" title="Edit" style="padding-right: 0.5rem; cursor:pointer;"></i>`;
            },
            cellClick: this.handleEditIconClick.bind(this)
        },
    ];

    handleEditIconClick(e, cell) {
    e.stopPropagation();
    const rowData = cell.getRow().getData();
    console.log('edit icon row data --->', JSON.parse(JSON.stringify(rowData)));

    if (e.target.classList.contains('edit-icon')) {
        this.selectedRecords = [rowData];
        this.fromEditIcon = true;
        this.showEditModal = true;
        }
    }

     get modalTitle() {
        return this.fromEditIcon ? 'Update Record' : 'Update Selected Records';
    }


    downloadIManageDoc(docId, docTitle) {
        this.isSpinner = true;
        downloadDocuments({ PatentId: docId })
            .then((result) => {
                console.log('Attachments fetched:', result);
                let attachmentIds = '';
                if (result && result.length > 0) {
                    attachmentIds = result.join('/') + '/';
                    attachmentIds = attachmentIds.replace(/.$/, '?');
                }
                console.log('attachmentIds fetched:', attachmentIds);
                if (attachmentIds) {
                    const downloadUrl = `/sfc/servlet.shepherd/version/download/${attachmentIds}&filename=${docTitle}`;
                    console.log('Navigating to download URL:', downloadUrl);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: downloadUrl,
                        },
                    });
                } else {
                    console.warn('No attachments found for record ID:', docId);
                }
                this.isSpinner = false;
            })
            .catch((error) => {
                this.isSpinner = false;
                console.error('Error fetching attachments:', error);
            });
    }

    flowApiName;
    flowInputVariables;
    showImanageAdd = false;
    handleImanageInit(recordId, parentAssetId) {
        try {
            this.flowApiName = 'cmpAPDockets';
            this.flowInputVariables = [
                {
                    name: "iManageEmailObjectId",
                    type: "String",
                    value: recordId
                },
                {
                    name: "recordId",
                    type: "String",
                    value: parentAssetId
                }
            ];
            this.showImanageAdd = true;
            this.startFlow();
        } catch (err) {
            alert('JS Error ::  :: handleImanageInit')
            console.error(err)
        }
    }

    handleCancelImanage() {
        try {
            this.showImanageAdd = false;
            this.fetchDocketActivities();
        } catch (err) {
            alert('JS Error :: LwcMvRelatedList :: handleCancelImanage')
            console.error(this.serializeError(err));
        }
    }

    startFlow() {
        const flowContainer = this.template.querySelector("lightning-flow");
        if (flowContainer) {
            flowContainer.startFlow(this.flowApiName, this.flowInputVariables);
        }
    }
    handleSaveImanage(event) {
        try {
            if (event.detail.status === 'FINISHED') {
                this.isLoading = true;

                this.showImanageAdd = false;
                this.fetchDocketActivities();
            }
        } catch (err) {
            console.error(this.serializeError(err));
        }
    }

    handleActionEditClick(cell) {
        try {
            const recordId = cell.getRow().getData().recordId;
            this.clientEngagementModelId = recordId;
            this.showAddEdit = true;
        } catch (err) {
            alert('JS Error ::  :: handleActionEditClick')
            console.error(this.serializeError(err));
        }
    }

    handleActionClick(cell) {
        try {
            alert('Reached handleActionClick');


            const clickedButton = cell.getElement();
            console.log('clickedButton ', clickedButton);

        } catch (err) {
            alert('JS Error ::  :: handleActionClick')
            console.error(err)
        }
    }

    records = [];
    showTable = false;

    connectedCallback() {
        this.fetchDocketActivities();
        this.setServiceRepositoryForApplicableRulesName();
    }

    handleInlineSave(event) {
        try {
            this.fetchDocketActivities();
        } catch (err) {
            console.error(err);
        }

    }

    firstTimeLoad = true;

    fetchDocketActivities() {
        try {
            getPatentDocketActivities({
                'recordId': this.recordId
            })
                .then(response => {
                    try {
                        this.records = JSON.parse(JSON.stringify(response));
                        console.log('Patent Docket Activity Records--->'+this.records);
                        console.log('Records Length : ' + this.records.length);
                        console.log('this.selectedFilter--->',this.selectedFilter);
                        this.highlightSelectedTile(this.selectedFilter);
                        this.filterAndUpdateTable(this.selectedFilter);
                        this.showTable = true;
                    } catch (err) {
                        console.error(JSON.stringify(error));
                    }
                })
                .catch(error => {
                    console.error(JSON.stringify(error));
                })
        } catch (err) {
            console.error(err);
        }
    }

    serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
            // ...error
        });
    }

    clientEngagementModelId;
    showAddEdit = false;
    isLoading = false;

    handleAdd() {
        try {
            this.showAddEdit = true;
        } catch (err) {
            alert('JS Error ::  :: handleAdd')
            console.error(err)
        }
    }

    handleAddEditSuccess() {
        try {
            this.showAddEdit = false;
            this.isLoading = false;
            this.fetchClientPortfolio();
        } catch (err) {
            alert('JS Error ::  :: handleAddEditSuccess')
            console.error(err)
        }
    }

    handleAddEditError(event) {
        try {
            alert('Error');

            // alert('Handle Error');
            const errorDetails = event.detail;
            console.error('Error occurred while saving the record:', errorDetails);

            // Display a custom error message to the user (optional)
            const errorMessage = this.extractErrorMessage(errorDetails);

            this.showToast('Error', 'error', errorMessage); // 'Record not updated'
            this.isLoading = false;
        } catch (err) {
            alert('JS Error ::  :: handleAddEditError')
            console.error(err)
        }
    }

    handleCancel() {
        try {
            this.showEditModal = false;
            this.handleBulkUpdateReset();
        } catch (err) {
            alert('JS Error ::  :: handleCancel')
            console.error(err)
        }
    }


    get
        showAddEditVisible() {
        try {
            return this.showAddEdit ? 'slds-show' : 'slds-hide';
        } catch (err) {
            alert('JS Error ::  :: showAddEditVisible')
            console.error(err)
        }
    }


    isRenderedCallBackInitialized = false;

    renderedCallback() {
        try {
            if (this.isRenderedCallBackInitialized) return;
            this.isRenderedCallBackInitialized = true;

            Promise.all([
                //     //   loadScript(this, MAXVALTABLEJS),
                //     //   loadStyle(this, MAXVALTABLECSS),
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
                .then(() => {
                    console.log('Loaded FA Styles');
                    /*  const defaultTile = this.template.querySelector('[data-filtertype="aggregateCollaborations"]');
            //           if (defaultTile) {
            //               defaultTile.classList.add('selected');
            //           } */
                });
        } catch (err) {
            alert('JS Error ::  :: renderedCallback')
            console.error(err)
        }
    }

    // Helper method to extract error messages
    extractErrorMessage(errorDetails) {
        try {
            if (errorDetails && errorDetails.body) {
                if (errorDetails.body.output && errorDetails.body.output.errors.length > 0) {
                    return errorDetails.body.output.errors[0].message; // Record-level error
                } else if (errorDetails.body.message) {
                    return errorDetails.body.message; // Top-level error
                }
            }
            return errorDetails.detail;
        } catch (err) {
            alert('JS Error ::  :: extractErrorMessage');
            console.error(err);
        }
    }

    handleBulkUpdateReset(){
        try{
            console.log('Start handleBulkUpdateReset');
             this.assignedTo = '';
             this.allComments = '';
             this.dueDate = '';
             this.completionDate = '';
             this.closedDate = '';
             this.isCompleted = false;
             this.isClosed = false;
             this.reportToClient = false;
             this.reasonToComplete = '';
             this.reasonToClose = '';

            console.log('End handleBulkUpdateReset');
        }catch(err){
            console.error('JS Error ::  :: handleBulkUpdateReset')
            console.error(err)
        }
     }
 
}