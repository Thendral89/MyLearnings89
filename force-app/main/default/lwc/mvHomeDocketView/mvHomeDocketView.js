import { LightningElement, wire, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import FA from "@salesforce/resourceUrl/FA";
import { createElement } from 'lwc';
import mvDocketFields from 'c/mvDocketFields';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
//import CLIENT_ID_FIELD from '@salesforce/schema/User.Client_Id__c';
import ASSIGNED_TO_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Assigned_To_User__c";
import COMMENTS_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.Comments__c";
import COMPLETED_DATE_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Completion_Date__c";
import CLOSED_DATE_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Closed_Date__c";
import IS_COMPLETED_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Is_Completed__c";
import IS_CLOSED_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.SymphonyLF__Is_Closed__c";
import ID_FIELD from "@salesforce/schema/SymphonyLF__Docketing_Activity__c.Id";
import REPORTED_FIELD from '@salesforce/schema/SymphonyLF__Docketing_Activity__c.Reported__c';

import { updateRecord } from 'lightning/uiRecordApi';

import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    openSubtab,
} from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAttorneys from '@salesforce/apex/mvHomeDocketUtilities.getAttorneys';
import getHomeDocketActivities from '@salesforce/apex/mvHomeDocketUtilities.getHomeDocketActivities';
//import getHomeDocketActivities from '@salesforce/apex/mvHomeDocketUtilities.fetchDocketInfo';
import getCurrentUserProfile from '@salesforce/apex/mvHomeDocketUtilities.getCurrentUserProfile';

const PAGINATOR_DEFAULT_SIZE = 100;
const PAGINATOR_SIZE_SELECTOR = [25, 50, 100, 500];

export default class MvHomeDocketView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track selectedTabName = 'Docket Activities Next 7 Days';
    @track selectedTabIcon = 'standard:event';
    @track selectedTabCount = 0;
    @track attorneyTabCount = 0;
    @track isSpinner = false;

    // Variables for Edit Modal Popup and Selected Records
    @track showEditModal = false;
    @track selectedRowsData = [];
    @track showExpandModal = false;

    @track assignedTo = '';
    @track allComments = '';
    @track completionDate = '';
    @track closedDate = '';
    @track isCompleted = false;
    @track isClosed = false;

    @track selectedRecords = [];
    @track selectedFilter = 'NEXT7';
    @track attorneyId;

    @track clientId = '';
    clientIdCondition = '';

    @track userProfile;
    @track showAllFields = false;
    @track isLegalAssistant = false;
    adminProfiles = ['System Administrator', 'MCCIP Docketing Management','MCCIP Docketer'];

    currentFeatureSettings = {
        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR
    };

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;


    showAction = false;
    flowApiName = '';
    flowInputVariables = {};

    @wire(getCurrentUserProfile)
    wiredUserProfile({ error, data }) {
        if (data) {
            this.userProfile = data; 
            console.log('user profile--->',JSON.stringify(this.userProfile));
            if(this.userProfile == 'MCCIP Legal Assistant'){
                this.fetchAttorneys();
            }else{
                this.fetchDocketActivities();
            }  
            this.highlightSelectedTile(this.selectedFilter);   
            this.showAllFields = this.adminProfiles.includes(this.userProfile);
        } else if (error) {
            this.userProfile = undefined;
            this.showAllFields = false;
            console.error('Error fetching user profile: ', error);
        }
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

    handleCancelAndClose(){
       try{
        this.showAction = false;
        this.handleBulkUpdateReset();
       }catch(err){
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

            // Open a record as a subtab of the current tab
            await openSubtab(this.enclosingTabId, { recordId: recordIdrecordIdrecordIdrecordId, focus: true });

            /* // Open sub tab
             await openSubtab(this.enclosingTabId, {
                 pageReference: {
                     'type': type,
                     attributes: {
                         'objectApiName': objectApiName,
                         'actionName': actionName,
                         "recordId": recordId
                     }
                 }
             }); */
        }
        catch (err) {
            alert('JS Error : ccDashboard : findEnclosingTabAndOpenSubtab');
        }

    }

    handleExpandClick() {
        this.showExpandModal = true;
    }

    handleExpandModalClose() {
        this.showExpandModal = false;
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this[fieldName] = value;
    }

    handleAssignedToChange(event) {
        this.assignedTo = event.detail[0].Id;
    }

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
                        message: 'Please select records to update',
                        variant: 'error'
                    })
                );
                return;
            }

            const recordInputs = this.selectedRecords.map(e => {

                const fields = {};
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
                    console.log('All update failed');
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

    handleCancel() {
        // this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleFilters(event) {
        console.log('In Handle Filters');
        this.selectedFilter = event.currentTarget.dataset.filtertype;
        this.highlightSelectedTile(this.selectedFilter);
        this.fetchDocketActivities();
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

    filterAndUpdateTable(newSelection) {
        console.log('inisde filterAndUpdateTable-->', newSelection);
        // const today = new Date();

        // const getDifferenceInDays = (dueDateStr) => {
        //     const dueDateObj = new Date(dueDateStr);
        //     const differenceInTime = dueDateObj.getTime() - today.getTime();
        //     return differenceInTime / (1000 * 60 * 60 * 24);
        // };

        // const filteredData = this.records.filter((item) => {
        //     console.log('Item: ' + JSON.stringify(item));
            switch (newSelection) {

                case "NEXT7": {
                    this.selectedTabName = 'Docket Activities Next 7 Days';
                    this.selectedTabIcon = 'standard:event';
                    break;
                    // const diff = getDifferenceInDays(item.dueDate);
                    // return diff >= 0 && diff <= 7;
                }
                case "NEXT30": {
                    this.selectedTabName = 'Docket Activities Next 30 Days';
                    this.selectedTabIcon = 'standard:event';
                    break;
                    // const diff = getDifferenceInDays(item.dueDate);
                    // return diff >= 0 && diff <= 30;
                }
                case "NEXT60": {
                    this.selectedTabName = 'Docket Activities Next 60 Days';
                    this.selectedTabIcon = 'standard:event';
                    break;
                    // const diff = getDifferenceInDays(item.dueDate);
                    // return diff >= 0 && diff <= 60;
                }
                case "PASTDUE": {
                    this.selectedTabName = 'Docket Activities Past Due';
                    this.selectedTabIcon = 'standard:operating_hours';
                    break;
                    // const diff = getDifferenceInDays(item.dueDate);
                    // return (!item.isClosed && diff < 0);
                }
                case "ADHOC":
                    this.selectedTabName = 'Adhoc Docket Activities';
                    this.selectedTabIcon = 'standard:document_reference';
                    break;
                    // return item.docketTrigger === 'Ad-hoc Activity';

                case "EVENTS":
                    this.selectedTabName = 'Event Docket Activities';
                    this.selectedTabIcon = 'standard:events';
                    break;
                    // return item.docketTrigger !== 'Ad-hoc Activity';

                case "ALL":
                    this.selectedTabName = 'All Docket Activities';
                    this.selectedTabIcon = 'standard:event';
                    break;

                case "TODAY_AND_TOM":
                    this.selectedTabName = 'Today & Tomorrow Docket Activities';
                    this.selectedTabIcon = 'standard:event';

                default:
                    this.selectedTabName = 'Docket Activities Next 7 Days';
                    this.selectedTabIcon = 'standard:event';
                    break;
                    // return true;
            }
     //   });

      //  console.log('BB filteredData.length ', filteredData.length);
      //  this.selectedTabCount = filteredData.length;

        // try {
        //     const tableElement = this.template.querySelector('.lwcMvDataTable');
        //     if (tableElement) {
        //         tableElement.updateTableData(filteredData);
        //     }
        // } catch (err) {
        //     alert('JS Error :: updateTableData');
        //     console.error(err);
        // }
    }

    handleBulkUpdate() {
        if (!this.selectedRecords || this.selectedRecords.length === 0) {
            this.showToast('Error', 'Please select at least one record to update.', 'error');
            return;
        }
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
            width: "3%",
            cellClick: (e, cell) => {
                cell.getRow().toggleSelect();
            }
        },
       /* {
            title: "DA#", width: "10%", field: "recordName", frozen: true,
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
                        this.openTab('standard__recordPage', 'SymphonyLF__Docketing_Activity__c', recordId, 'view');
                    });
                }
                else {
                    output = "<span style='color:#c29304; font-weight:bold;'><a target='_blank' href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                }
                return output;
            }
        },*/
        {title:"Asset Type", width:"7%", headerFilter:true, field:"assetType", formatter: (cell, formatterParams) => {
            var value = cell.getValue();
            if (value=='Patent')
                return "<span class='greentag' style='font-weight:bold;'>" + value + "</span>";
            else if (value=='Trademark')
                return "<span class='orangetag' style='font-weight:bold;'>" + value + "</span>";
            else if (value=='Design')
                return "<span class='greytag' style='font-weight:bold;'>" + value + "</span>";
            else if (value=='Design Family')
                return "<span class='greytag' style='font-weight:bold;'>" + value + "</span>";
            else if (value=='Disputes')
                return "<span class='redtag' style='font-weight:bold;'>" + value + "</span>";
            else if (value=='Patent Family')
                return "<span class='greentag' style='font-weight:bold;'>" + value + "</span>";
            else if (value=='Mark')
                return "<span class='orangetag' style='font-weight:bold;'>" + value + "</span>";
            else if (value=='Copyright')
                return "<span class='browntag' style='font-weight:bold;'>" + value + "</span>";
            else 
                return "<span class='browntag' style='font-weight:bold;'>" + value + "</span>";
        }},
        {
            title: "Docket No.", width: "10%", headerFilter:true,field: "docketNumber", frozen: true,
            formatter: (cell, formatterParams) => {
                var value = cell.getValue();
                let recordId = cell.getRow().getData().parentAssetId;
                let output;
                if (this.isConsoleNavigation) {
                    output = document.createElement("a");
                    let href = this.sfdcURL + "/" + recordId;
                    output.href = href;
                    output.style.fontWeight = "bold";
                    output.textContent = value;
                    output.addEventListener("click", (event) => {
                        event.preventDefault();
                        this.openTab('standard__recordPage', '', recordId, 'view');
                    });
                }
                else {
                    output = "<span style='color:#c29304; font-weight:bold;'><a target='_blank' href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                }
                return output;
            }
        },
        {
            title: "Event Name", width: "25%", headerFilter: true, field: "docketAction", formatter: (cell, formatterParams) => {
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
                        this.openTab('standard__recordPage', 'SymphonyLF__Docketing_Activity__c', recordId, 'view');
                    });
                }
                else {
                    output = "<span style='color:#c29304; font-weight:bold;'><a target='_blank' href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                }
                return output;
            }
        },
        {
            title: "All Comments", width: "40%", headerFilter: true, field: "docketComments", formatter: "html",
            formatter: (cell, formatterParams) => {

                const commentValue = cell.getValue() || "";
                return `<div style="white-space: pre-wrap;">${commentValue}</div>`;
            }
        },
        {
            title: "Due Date", width: "10%", headerFilter: "input", field: "dueDate", sorter: "date", formatter: function(cell) {
                const date = new Date(cell.getValue());
                    return date.toLocaleDateString("en-US", {
                    year: "numeric",
                    month: "short",
                    day: "numeric"
                }); 
            },
            headerFilterFunc: function(headerValue, rowValue) {
                const date = new Date(rowValue);
                const formatted = date.toLocaleDateString("en-US", {
                    year: "numeric",
                    month: "short",
                    day: "numeric"
                }).toLowerCase();
                return formatted.includes(headerValue.toLowerCase());
            }
        },
        {
            title: "Status", width: "10%", headerFilter: true, field: "docketStatus"
        },
        {
            title: "Assigned To", width: "20%", headerFilter: true, field: "assignedTo", formatter: (cell, formatterParams) => {
                var value = cell.getValue();
                let recordId = cell.getRow().getData().assignedToId;
                let output;
                if (this.isConsoleNavigation) {
                    output = document.createElement("a");
                    let href = this.sfdcURL + "/" + recordId;
                    output.href = href;
                    output.style.fontWeight = "bold";
                    output.textContent = value;
                    output.addEventListener("click", (event) => {
                        event.preventDefault();
                        this.openTab('standard__recordPage', 'SymphonyLF__Person__c', recordId, 'view');
                    });
                }
                else {
                    output = "<span style='color:#c29304; font-weight:bold;'><a target='_blank' href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                }
                return output;
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
            }    
        },
        {
            title: "Docketed By", width: "10%", headerFilter: true, field: "docketedByName", formatter: (cell, formatterParams) => {
                var value = cell.getValue();
                let recordId = cell.getRow().getData().docketedById;
                let output;
                if (this.isConsoleNavigation) {
                    output = document.createElement("a");
                    let href = this.sfdcURL + "/" + recordId;
                    output.href = href;
                    output.style.fontWeight = "bold";
                    output.textContent = value;
                    output.addEventListener("click", (event) => {
                        event.preventDefault();
                        this.openTab('standard__recordPage', 'SymphonyLF__Docketing_Rule__c', recordId, 'view');
                    });
                }
                else {
                    output = "<span style='color:#c29304; font-weight:bold;'><a target='_blank' href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                }
                return output;
            }
        }
        // }, {
        //     title: "Trigger", width: "25%", headerFilter: true, field: "docketTrigger", formatter: (cell, formatterParams) => {
        //         var value = cell.getValue();
        //         if (value != undefined)
        //             return "<span style='font-weight:bold;'>" + value + "</span>";
        //     }
        // },
    ];

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
    attorneyRecords = [];
    showTable = false;

    connectedCallback() {
        //  this.fetchAttorneys();
        // if(this.userProfile == 'MCCIP Legal Assistant'){
        //     this.fetchAttorneys();
        // }else{
            // this.fetchDocketActivities();
            // this.highlightSelectedTile(this.selectedFilter);
        // }       
    }

    handleInlineSave(event) {
        try {
            this.fetchDocketActivities();
        } catch (err) {
            console.error(err);
        }

    }

    firstTimeLoad = true;
    showSpinner = true;

    fetchAttorneys(){
         try {
            this.showSpinner = true;
            this.showTable = true;
            getAttorneys({})
                .then(response => {
                    try {
                        this.attorneyRecords = JSON.parse(JSON.stringify(response));
                        console.log('Attorneys--->',this.attorneyRecords);
                        if(this.attorneyRecords.length > 0){
                            this.attorneyId = this.attorneyRecords[0].attorneyId;
                            this.attorneyTabCount = this.attorneyRecords.length;
                            this.isLegalAssistant = true;
                            this.fetchDocketActivities();
                        }
                       // this.filterAndUpdateTable(this.selectedFilter);
                       // this.selectedTabCount = this.records.length;
                      //  this.showTable = true;

                      } catch (err) {
                          console.error(JSON.stringify(err));
                          console.error(this.serializeError(err));
                      }
                })
                .catch(error => {
                    alert('Server error : mvHomeDocketView');
                    console.error(JSON.stringify(error));
                    console.error(this.serializeError(error));
                })
                .finally(() => {
                    this.showSpinner = false;
                })
        } catch (err) {
            alert('JS eroor');
            console.error(err);
            console.error(this.serializeError(err));
        }
        
    }


    fetchDocketActivities() {
        try {
            this.showSpinner = true;
            this.showTable = true;
            getHomeDocketActivities({
                'recordId': this.recordId,
                'filterType' : this.selectedFilter,
                'attorneyIds' :this.attorneyId,
                'profileName' :this.userProfile
            })
                .then(response => {
                    try {
                        this.records = JSON.parse(JSON.stringify(response));
                        console.log('Records Length : ' + this.records.length);
                        this.filterAndUpdateTable(this.selectedFilter);
                        this.selectedTabCount = this.records.length;
                      //  this.showTable = true;

                      try {
                        const tableElement = this.template.querySelector('.lwcMvDataTable');
                        if (tableElement) {
                         //   tableElement.showSpinner();
                            tableElement.updateTableData(this.records);
                            
                        }
                       } catch (err) {
                        alert('JS Error :: updateTableData');
                        console.error(err);
                        console.error(this.serializeError(err));
                      }
                      } catch (err) {
                          console.error(JSON.stringify(err));
                          console.error(this.serializeError(err));
                      }
                })
                .catch(error => {
                    alert('Server error : mvHomeDocketView');
                    console.error(JSON.stringify(error));
                    console.error(this.serializeError(error));
                })
                .finally(() => {
                    this.showSpinner = false;
                })
        } catch (err) {
            alert('JS eroor');
            console.error(err);
            console.error(this.serializeError(err));
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
        } catch (err) {
            alert('JS Error ::  :: handleCancel')
            console.error(err)
        }
    }

    handleBulkUpdateReset(){
       try{
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
       }catch(err){
           console.error('JS Error ::  :: handleBulkUpdateReset')
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

            // Promise.all([
            //     //   loadScript(this, MAXVALTABLEJS),
            //     //   loadStyle(this, MAXVALTABLECSS),
            //     loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            // ])
            //     .then(() => {
            //         /*  const defaultTile = this.template.querySelector('[data-filtertype="aggregateCollaborations"]');
            //           if (defaultTile) {
            //               defaultTile.classList.add('selected');
            //           } */
            //     });
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

    handleAttorneyClick(event){
        this.attorneyId = event.target.dataset.id;
        console.log('Clicked attorneyId:', this.attorneyId);
        this.fetchDocketActivities();
    }
}