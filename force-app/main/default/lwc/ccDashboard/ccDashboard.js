/* eslint-disable dot-notation */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    openSubtab,
    getFocusedTabInfo,
    refreshTab,
    setTabIcon,
    setTabLabel,
    setTabHighlighted,
    getAllTabInfo,
    focusTab
} from 'lightning/platformWorkspaceApi';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

/* Import Refresh Event*/
import { refreshApex } from '@salesforce/apex';

/* Import the Static Resources for Tabulator Open source libraries*/
import MCCTABLECSS from "@salesforce/resourceUrl/MCCTABLECSS";
import MCCTABLEJS from "@salesforce/resourceUrl/MCCTABLEJS";
import FA from "@salesforce/resourceUrl/FA";

/* Import Custom Labels for Announcement */
import ccAnnouncementHeader from '@salesforce/label/c.ccDashboardHeader';
import ccAnnouncementText from '@salesforce/label/c.ccDashboardAnnouncement';

/* Import Toast Events*/
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { createElement } from 'lwc';

/* This scoped module imports the current user profile name and User Id */
import profileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';


/* Import the Conflict Check Utilities Method */
import getConflictCheckRequests from '@salesforce/apex/conflictCheckUtilities.getConflictCheckMasterRequests';
import getRecentConflictCheckRequests from '@salesforce/apex/conflictCheckUtilities.getConflictCheckMasterRequests';


/* Import Conflict Check Search Result Fields to be used in the form */
import ISVERIFIED from '@salesforce/schema/Conflict_Check_Search_Result__c.Is_Verified__c';

import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import ccDashboardChild from 'c/ccDashboardChild';

export default class CcDashboard extends NavigationMixin(LightningElement) {

    // Make a Component Aware of Its Record Context
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_object_context
    @api recordId;
    @track clientRecordId;
    @track ccDashboardHeader = ccAnnouncementHeader;
    @track ccDashboardAnnouncement = ccAnnouncementText;

    @track isRenderedCallBackInitialized = false;

    @track wiredConflictCheckRequests; // Holding variable used in refreshApex for Conflict Check Requests (hold data and error)
    @track conflictCheckRequests;
    @track numberOfRequests;
    @track conflictCheckSelectedRecordId;
    @track selectedClientReferenceNumber;
    @track selectedClientGroupNumber;
    @track matterTitle;

    // Variables for Engage/Do Not engage
    @track isShowEngagementModal = false;
    @track isShowDoNotEngagementModal = false;

    // Variable to show/hide Conflict Check Form
    @track initiateCCForm = false;
    @track showannouncement = false;
    // Get the Conflict Check Requests related to the Originating Attorney and also fetch Master Detail Data  

    @track tabId;

    @track showInitiateCCButton = false;
    @track showEngageButton = false;
    @track showDonotEngageButton = false;
    @track userProfileName;

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;

    serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
            // ...error
        });
    }

    async openTab(type = 'standard__objectPage', objectApiName = 'Conflict_Check__c', recordId, actionName = 'list', focus = true, label = '') {
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
    async setTabTitle() {
        try {
            const tabInfo = await getFocusedTabInfo();
            const tabId = tabInfo.tabId;
            console.log('tabId :  ',tabId);
            await setTabLabel({
                tabId: tabId,
                label: 'CC Dashboard'
            });

            console.log(`Tab title set to CC Dashboard`);
        } catch (error) {
            console.error('Error setting tab label:', error);
        }
    }

    @wire(getRecord, { recordId: Id, fields: [profileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }
        }
    }

    connectedCallback() {
        this.showInitiateCCButton = this.recordId != undefined ? false : true;
        this.getConflictCheck();
        getFocusedTabInfo().then((tabInfo) => {
            this.tabId = tabInfo.tabId;
            console.log('this.tabId',this.tabId);
        })
        
    }

    getConflictCheck() {
        getConflictCheckRequests({ recordId: this.recordId }).then((data) => {
            // Clear the user enter values
            this.loadScripts();
            this.wiredConflictCheckRequests = data;
            if (this.recordId == undefined) {
                this.showEngageButton = (this.wiredConflictCheckRequests[0].Logged_in_User_is_Creator__c || this.wiredConflictCheckRequests[0].Logged_in_User_is_Originating_Attorney__c) ? false : true;
                this.showDonotEngageButton = this.showEngageButton;
                this.showannouncement = true;
                console.log('CREATOR ===> ', this.wiredConflictCheckRequests[0].Logged_in_User_is_Creator__c);
                console.log('OA ====>', this.wiredConflictCheckRequests[0].Logged_in_User_is_Originating_Attorney__c);
            }
            else {
                this.showEngageButton = false;
                this.showDonotEngageButton = false;
                this.showannouncement = false;
            }

            if(this.recordId != undefined){
                this.conflictCheckRequests = JSON.parse(JSON.stringify(data)).map(request => ({
                    ...request,
                    isExpanded: true,  // Set isExpanded to false initially
                }));
               } else{
                this.conflictCheckRequests = JSON.parse(JSON.stringify(data)).map(request => ({
                    ...request,
                    isExpanded: false,  // Set isExpanded to false initially
                }));
               }
            this.numberOfRequests = this.wiredConflictCheckRequests.length;
            console.log(`Conflict Check Requests : ${JSON.stringify(this.conflictCheckRequests)}`);
            this.initializeConflictCheckTable();
            //return refreshApex(this.wiredConflictCheckRequests);

        })
            .catch((error) => {
                console.log('Error connected call back Creation.', JSON.stringify(error));
            });
    }

    loadScripts() {
        loadScript(this, MCCTABLEJS).then(() => {
            loadStyle(this, MCCTABLECSS).then(() => {
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css').then(() => {
                    console.log('Scripts Loaded Successfully');
                    this.isRenderedCallBackInitialized = true;
                    this.initializeConflictCheckTable();
                });
            });
        });
    }

    onloadConflickCheckDashboard() {
        this.loadScripts();
    }

    renderedCallback() {
        if (this.isRenderedCallBackInitialized) {
            this.initializeConflictCheckTable()
            return;
        }
        console.log('recordId', this.recordId);

    }

    sfdcURL = window.location.origin;

    initializeConflictCheckTable() {
        this.component = this.template.querySelector('[data-id="MCCIPConflictCheckDashboard"]');
        console.log('In Method : Initializing Conflict Check Table');

        var hideIcon = function (cell, formatterParams, onRendered) { //plain text value
            return "<i class='fa fa-plus-circle'></i>";
        };
        if(this.recordId != undefined){
            this.conflictCheckRequests = this.conflictCheckRequests.map(row => {
               
                    return { ...row, isExpanded: true, isSelected: true };
                
                return row;
            });
        }
        //Initialize table
        var table = new Tabulator(this.component, {
            height: "100%",
            layout: "fitColumns",
            resizableColumns: false,
            reactiveData: true,
            data: this.conflictCheckRequests,
            pagination: "local",
            paginationSize: 10,
            responsiveLayout: "collapse",
            columns: [
                {
                    title: "", field: "isSelected", align: "center", resizable: false, frozen: true, headerSort: false,width: 10,
                    formatter: function (cell, formatterParams) {
                        if (cell.getRow().getData().isSelected) {
                            return "<i class='fa fa-check-circle'></i>";
                        } else {
                            return "<i class='fa fa-circle'></i>";
                        }
                    }, cellClick: function (e, cell) {

                        const isSelected = cell.getRow().getData().isSelected;
                        var vRows = table.getRows();
                        console.log('Number of Rows : ' + vRows.length);
                    
                        for (var i = 0; i < vRows.length; i++) {
                         try {

                                vRows[i].getData().isSelected = false;
                                // table.updateRow(vRows[i].getIndex(), vRows[i].getData());
                                console.log('Row Number : ' + i);

                            } catch (error) {
                                console.log('Error : ' + JSON.stringify(error));
                            }
                        }        
                        console.log('Setting to True');
                        // cell.getRow().getData().isSelected = true;
                        console.log('Before to True');
                        // table.updateRow(cell.getRow().getIndex(), cell.getRow().getData());
                        // console.log('After Setting to True');

                        cell.getRow().getData().isSelected = !isSelected;
                    }
                },
                {
                    title: "", field: "isExpanded", align: "center", resizable: false, frozen: true, headerSort: false, width: 50,
                    formatter: (cell) => {
                        const rowData = cell.getRow().getData();
                        if (rowData.isExpanded) {
                            return "<i class='fa fa-minus-circle'></i>";
                        } else {
                            return "<i class='fa fa-plus-circle'></i>";
                        }
                    },
                    cellClick: async (e, cell) => {
                        const rowData = cell.getRow().getData();
                        const id = rowData.recordId;
                        const isExpanded = rowData.isExpanded;
                        
                        cell.getRow().update({ isExpanded: !isExpanded });
                        const rowElement = cell.getRow().getElement();
                        const subTableSelector = `.subTable${id}`;
                        const subTables = rowElement.querySelectorAll(subTableSelector);
                        if (!isExpanded) {
                            subTables.forEach(async (subTable) => {
                                if (!subTable.hasChildNodes()) {
                                    try {
                                        let childComponent = createElement('c-cc-dashboard-child', { is: ccDashboardChild });
                                        childComponent.updateRecordId(id);
                                        subTable.appendChild(childComponent);
                                    } catch(error) {
                                        console.error('Error creating child cmp for recordId:', id, error);
                                    }
                                }
                                subTable.style.visibility = 'visible';
                                subTable.style.display = 'block';
                            });
                        } else {
                            subTables.forEach(subTable => {
                                subTable.style.visibility = 'hidden';
                                subTable.style.display = 'none';
                            });
                        }
                    }
                    /* formatter: function (cell, formatterParams) {
                        if (cell.getRow().getData().clientRecords.length > 0 || cell.getRow().getData().contributorRecords.length > 0 || cell.getRow().getData().keywordRecords.length > 0) {
                            if (cell.getRow().getData().isExpanded) {
                                return "<i class='fa fa-minus-circle'></i>";
                            } else {
                                return "<i class='fa fa-plus-circle'></i>";
                            }
                        }
                    }, cellClick: function (e, cell) {
                        if (cell.getRow().getData().clientRecords.length > 0 || cell.getRow().getData().contributorRecords.length > 0 || cell.getRow().getData().keywordRecords.length > 0) {
                            const isExpanded = cell.getRow().getData().isExpanded;
                            cell.getRow().getData().isExpanded = !isExpanded;
                            const id = cell.getRow().getData().recordId;
                            const visibility = isExpanded ? 'hidden' : 'visible';
                            const display = isExpanded ? 'none' : 'block';

                            document.querySelectorAll(".subTable" + id).forEach(childTable => {
                                childTable.style.visibility = visibility;
                                childTable.style.display = display;
                            });
                        }
                    } */
                },
                {
                    title: "Request # ", field: "recordName", headerFilter: true, formatter: (cell, formatterParams) => {
                        try {
                            console.log
                            var value = cell.getValue();
                            let recordId = cell.getRow().getData().recordId;
                            let output;
                            if (this.isConsoleNavigation) {
                                output = document.createElement("a");
                                output.href = this.sfdcURL + "/" + recordId;
                                output.style.fontWeight = "bold";
                                output.textContent = value;
                                output.addEventListener("click", (event) => {
                                    event.preventDefault();
                                    this.openTab('standard__recordPage', 'Conflict_Check__c', recordId, 'view');
                                });
                            }
                            else {
                                output = "<span style='color:#c29304; font-weight:bold;'><a href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                            }
                            return output;
                        } catch (err) {
                            alert('JS Error : Request # ');
                            console.error(err);
                            console.error(this.serializeError(err));
                        }
                    }
                },
                {
                    title: "Client Name", field: "clientName", headerFilter: true,
                    formatter: (cell, formatterParams) => {
                        try {
                            var value = cell.getValue();
                            let recordId = cell.getRow().getData().clientId;
                            let output;
                            if (this.isConsoleNavigation) {
                                output = document.createElement("a");
                                output.href = this.sfdcURL + "/" + recordId;
                                output.style.fontWeight = "bold";
                                output.textContent = value;
                                output.addEventListener("click", (event) => {
                                    event.preventDefault();
                                    this.openTab('standard__recordPage', 'SymphonyLF__Client__c', recordId, 'view');
                                });
                            }
                            else {
                                output = "<span style='color:#c29304; font-weight:bold;'><a href='" + this.sfdcURL + "/" + recordId + "'>" + value + "</a></span>";
                            }
                            return output;
                        } catch (err) {
                            alert('JS Error : Client Name ');
                            console.error(err);
                            console.error(this.serializeError(err));
                        }
                    }
                },
                {
                    title: "Client Reference Number", field: "clientReferenceNumber", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='font-weight:bold;'>" + value + "</span>";
                    }
                },
                {
                    title: "Matter Name", field: "matterNames", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='font-weight:bold;'>" + value + "</span>";
                    }
                },
                {
                    title: "Area Of Law", field: "areaOfLaw", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='font-weight:bold;'>" + value + "</span>";
                    }
                },
                {
                    title: "Adverse Parties", field: "adverseParties", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='font-weight:bold;'>" + value + "</span>";
                    }
                },
                {
                    title: "Related Parties", field: "relatedParties", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='font-weight:bold;'>" + value + "</span>";
                    }
                },
                {
                    title: "Contributor(s)", field: "contributors", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='font-weight:bold;'>" + value + "</span>";
                    }
                },
                {
                    title: "Keyword(s)", field: "keywords", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='font-weight:bold;'>" + value + "</span>";
                    }
                },
                {
                    title: "Approve Count", field: "approveCount", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='color:#32a852;font-weight:bold;'>" + value + "/" + cell.getRow().getData().totalCount + "</span>";
                    }
                },
                {
                    title: "Discuss Count", field: "discussCount", headerFilter: true, formatter: function (cell, formatterParams) {
                        var value = cell.getValue();
                        if (value === undefined)
                            return "<span style='color:#ff0000; font-weight:bold;'></span>";
                        return "<span style='color:#f51905;font-weight:bold;'>" + value + "/" + cell.getRow().getData().totalCount + "</span>";
                    }
                },
            ],
            rowSelectionChanged: function (data, rows) {
                console.log('Rows sSelected ++++ ' + JSON.stringify(rows));

                //rows - array of row components for the selected rows in order of selection
                //data - array of data objects for the selected rows in order of selection
            },
            rowFormatter: (row) => {
                const rowData = row.getData();
                const id = rowData.recordId;
                const existingSubTable = row.getElement().querySelector(".subTable" + id);
                if (!existingSubTable) {
                    const subTable = document.createElement("div");
                    subTable.className = "subTable" + id;
                    subTable.style.cssText = `
                        box-sizing: border-box;
                        padding: 10px;
                        background: #ddd;
                        visibility: hidden;
                        display: none;
                    `;
                    row.getElement().appendChild(subTable);
                }
            }
     
        });
        try{
            table.on('dataLoaded', () => {
                console.log('Data loaded — delaying row expansion');
                if(this.recordId != null){
                // Small delay to ensure the DOM is fully rendered
                setTimeout(() => {
                    const firstRow = table.getRows()[0]; // use `table` here, not `this.table`
                    console.log('first row :'+firstRow);
                    if (firstRow) {
                        const rowData = firstRow.getData();
                        const id = rowData.recordId;
                        const isExpanded = rowData.isExpanded;
                        console.log('is expanded :'+isExpanded);
                        // Flip the isExpanded value
                        //firstRow.update({ isExpanded: !isExpanded });
            
                        const rowElement = firstRow.getElement();
                        const subTableSelector = `.subTable${id}`;
                        const subTables = rowElement.querySelectorAll(subTableSelector);
            
                        if (isExpanded) {
                            console.log('inside expanded');
                            subTables.forEach((subTable) => {
                                if (!subTable.hasChildNodes()) {
                                    try {
                                        const childComponent = createElement('c-cc-dashboard-child', {
                                            is: ccDashboardChild
                                        });
                                        childComponent.updateRecordId(id);
                                        subTable.appendChild(childComponent);
                                    } catch (error) {
                                        console.error('Error creating child cmp for recordId:', id, error);
                                    }
                                }
                                subTable.style.visibility = 'visible';
                                subTable.style.display = 'block';
                            });
                        } 
                        const iconCell = firstRow.getCell('isExpanded'); // replace with your actual field name
                        console.log('icon :'+iconCell);
                if (iconCell) {
                    const newHtml = isExpanded
                        ? "<i class='fa fa-minus-circle'></i>"
                        : "<i class='fa fa-plus-circle'></i>";
                    console.log('icon cell :'+newHtml);
                    iconCell.getElement().innerHTML = newHtml;
                }
                    }
                }, 0); // You can increase this to 100–200ms if needed
            }
            });
            
    }catch(ex){
        console.log('ex :'+ex+' '+JSON.stringify(ex));
    }


    }

    initiateNewConflictCheck() {
        this.initiateCCForm = true;
    }
    hideModalBox() {
        this.initiateCCForm = false;
    }
    onclosepopup(event) {
        this.initiateCCForm = false;
        this.refreshTable();

    }

    @track areaOfLaw;
    onAreaOfLawSelected(event) {
        this.areaOfLaw = event.detail;
        this.isAreaOfLawNotExists = false;
        this.isPatentIntakeForm = false;
        this.isDisignIntakeForm = false;
        this.isCopyrightIntakeForm = false;
        this.isTrademarkIntakeForm = false;
        this.isDisputeIntakeForm = false;
        this.isGMIntakeForm = false;
        this.isAgreementIntakeForm = false;
        this.isShowEngagementModal = true;
        if (this.areaOfLaw == 'Patent') {
            this.isPatentIntakeForm = true;
            this.modalName = 'Patent';
            this.areaOfLaw = 'Patent';
        }
        else if (this.areaOfLaw == 'Design') {
            this.isDisignIntakeForm = true;
            this.modalName = 'Design';
            this.areaOfLaw = 'Design';
        }
        else if (this.areaOfLaw == 'Copyright') {
            this.isCopyrightIntakeForm = true;
            this.modalName = 'Copyright';
            this.areaOfLaw = 'Copyright';
        } else if (this.areaOfLaw == 'Trademark') {
            this.isTrademarkIntakeForm = true;
            this.modalName = 'Trademark';
            this.areaOfLaw = 'Trademark';
        }
        else if (this.areaOfLaw == 'Opposition' || this.areaOfLaw == 'Due Diligence' || this.areaOfLaw == 'Cancellation Action' || this.areaOfLaw == 'Opinion' || this.areaOfLaw == 'Litigation') {

            this.isDisputeIntakeForm = true;
            this.modalName = 'Dispute/Opposition';
            this.areaOfLaw = 'Opposition';
        }
        //Modified for General Matter Application form
        else if (this.areaOfLaw == 'Counseling' || this.areaOfLaw == 'Discipline' || this.areaOfLaw == 'Board of Governors' || this.areaOfLaw == 'Bankruptcy') {

            this.isGMIntakeForm = true;
            this.modalName = 'General Matters';
            this.areaOfLaw = 'General Matters';
        }
        else if (this.areaOfLaw == 'Agreement') {
            this.isAgreementIntakeForm = true;
            this.modalName = 'Agreement';
            this.areaOfLaw = 'Agreement';
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Not Configured ' + this.areaOfLaw + ' Intake Forms. Please reachout to your system administrator for further.',
                    mode: 'dismissable',
                    variant: 'error'
                })
            );
        }
    }
    hideAreaOfLawModal(event) {
        this.isAreaOfLawNotExists = false;
    }

    @track selectedClientId;
    @track isDisignIntakeForm = false;
    @track isTrademarkIntakeForm = false;
    @track isDisputeIntakeForm = false;
    @track isGMIntakeForm = false;
    @track isPatentIntakeForm = false;
    @track isCopyrightIntakeForm = false;
    @track isAgreementIntakeForm = false;
    @track modalName;
    @track isAreaOfLawNotExists = false;
    selectedClientStatus = '';
    engageClient(event) {
        //console.log('Conflict Check Data : ' , JSON.stringify(this.conflictCheckRequests));
        // Verify atleast 1 Conflict Check record is selected. 
        // If selected, show the engagement model
        // If no record is selected, throw a toast message with error that atleast one conflict check record must be selected
        let selectedConflictCheck = [];
        selectedConflictCheck = this.conflictCheckRequests.filter(function (element) {
            return element.isSelected == true
        });

        console.log('Conflict Checks Selected : ' + JSON.stringify(selectedConflictCheck));
        if (selectedConflictCheck.length > 0) {
            if (selectedConflictCheck.length == 1) {
                this.conflictCheckSelectedRecordId = selectedConflictCheck[0].recordId;
                this.selectedClientId = selectedConflictCheck[0].clientId;
                this.selectedClientStatus = selectedConflictCheck[0].clientStatus;
                this.selectedClientReferenceNumber = selectedConflictCheck[0].clientReferenceNumber;//.replace(/’/g, "'");
                this.selectedClientGroupNumber = selectedConflictCheck[0].clientGroupNumber;
                this.matterTitle = selectedConflictCheck[0].matterNames;
                if (selectedConflictCheck[0].isRecordCreator || selectedConflictCheck[0].isOriginatingAttorney || this.userProfileName == 'System Administrator' || this.userProfileName == 'Docketing Management') {
                    this.isAreaOfLawNotExists = false;
                    this.isPatentIntakeForm = false;
                    this.isDisignIntakeForm = false;
                    this.isCopyrightIntakeForm = false;
                    this.isTrademarkIntakeForm = false;
                    this.isDisputeIntakeForm = false;
                    this.isGMIntakeForm = false;
                    this.isAgreementIntakeForm = false;
                    console.log ('Area of Law : ' + selectedConflictCheck[0].areaOfLaw);

                    if (selectedConflictCheck[0].areaOfLaw != null && selectedConflictCheck[0].areaOfLaw == 'Patent') {
                        this.isPatentIntakeForm = true;
                        this.openApplicationIntakeForm();
                    }
                    else if (selectedConflictCheck[0].areaOfLaw != null && selectedConflictCheck[0].areaOfLaw == 'Design') {

                        this.isDisignIntakeForm = true;
                        this.modalName = 'Design';
                        this.areaOfLaw = 'Design';
                    }
                    else if (selectedConflictCheck[0].areaOfLaw != null && selectedConflictCheck[0].areaOfLaw == 'Copyright') {

                        this.isCopyrightIntakeForm = true;
                        this.modalName = 'Copyright';
                        this.areaOfLaw = 'Copyright';
                    }
                    else if (selectedConflictCheck[0].areaOfLaw != null && selectedConflictCheck[0].areaOfLaw == 'Trademark') {

                        this.isTrademarkIntakeForm = true;
                        this.openApplicationIntakeForm();

                    }
                    else if (selectedConflictCheck[0].areaOfLaw != null && (selectedConflictCheck[0].areaOfLaw == 'Opposition' || selectedConflictCheck[0].areaOfLaw == 'Due Diligence' || selectedConflictCheck[0].areaOfLaw == 'Litigation' || selectedConflictCheck[0].areaOfLaw == 'Opinion' || selectedConflictCheck[0].areaOfLaw == 'Cancellation Action')) {

                        this.isDisputeIntakeForm = true;
                        this.openApplicationIntakeForm();
                       // this.modalName = 'Dispute/Opposition';
                       // this.areaOfLaw = 'Opposition';
                    }
                    //Modified for General Matter Application form
                    else if (selectedConflictCheck[0].areaOfLaw != null && (selectedConflictCheck[0].areaOfLaw == 'Counseling' || selectedConflictCheck[0].areaOfLaw == 'Discipline' || selectedConflictCheck[0].areaOfLaw == 'Board of Governors' || selectedConflictCheck[0].areaOfLaw == 'Bankruptcy')) {

                        this.isGMIntakeForm = true;
                        // this.modalName = 'General Matter';
                        // this.areaOfLaw = 'General Matter';
                        this.openApplicationIntakeForm();
                    }
                    else if (selectedConflictCheck[0].areaOfLaw != null && selectedConflictCheck[0].areaOfLaw == 'Agreement') {
                        this.isAgreementIntakeForm = true;
                        this.modalName = 'Agreement';
                        this.areaOfLaw = 'Agreement';
                    }
                    // else if(selectedConflictCheck[0].areaOfLaw!=null && selectedConflictCheck[0].areaOfLaw != 'Patent' || selectedConflictCheck[0].areaOfLaw != 'Design'){
                    //     this.dispatchEvent(
                    //         new ShowToastEvent({
                    //             title: 'Error',
                    //             message: 'Not Configured '+selectedConflictCheck[0].areaOfLaw+' Intake Forms. Please reachout to your system administrator for further.',
                    //             mode:'dismissable',
                    //             variant: 'error'
                    //         })
                    //     );
                    // }
                    else {
                        //Open a popup to select are of law
                        this.isAreaOfLawNotExists = true;
                    }
                    // else if(selectedConflictCheck[0].areaOfLaw == null){
                    //     this.dispatchEvent(
                    //         new ShowToastEvent({
                    //             title: 'Error',
                    //             message: 'Area of law if mandate to Engage this Conflict Check.',
                    //             mode:'dismissable',
                    //             variant: 'error'
                    //         })
                    //     );
                    // }
                    // else if(selectedConflictCheck[0].areaOfLaw != 'Patent' || selectedConflictCheck[0].areaOfLaw != 'Design'){
                    //     this.dispatchEvent(
                    //         new ShowToastEvent({
                    //             title: 'Error',
                    //             message: 'Not Configured '+selectedConflictCheck[0].areaOfLaw+' Intake Forms. Please reachout to your system administrator for further.',
                    //             mode:'dismissable',
                    //             variant: 'error'
                    //         })
                    //     );
                    // }

                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Only CC Initiator or Originating Attorney can Engage this Conflict Check.',
                            mode: 'dismissable',
                            variant: 'error'
                        })
                    );
                }

            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select one Conflict Check record at  a time.',
                        mode: 'dismissable',
                        variant: 'error'
                    })
                );
            }
        } else {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a Conflict Check record to proceed.',
                    mode: 'dismissable',
                    variant: 'error'
                })
            );
        }

    }

    openApplicationIntakeForm(clientId){
        try {
            /*
                Bibliography
                1. https://soobink.medium.com/open-lwc-page-from-a-lwc-without-an-aura-component-b9e38dad6d21
                2. https://medium.com/@johanissac_27372/how-to-open-lwc-from-a-parent-lwc-in-a-subtab-using-workspace-api-e8c89626e863#:~:text=openSubtab()%20%E2%80%94%20As%20the%20name,it%20takes%20the%20following%20parameters.&text=parentTabId%20(string)%3A%20ID%20of,content%20of%20the%20new%20subtab.
            */
            // Ensure that we're in a console app and that we have a tab open
            console.log('if conditions       --> '+this.isConsoleNavigation+' '+this.enclosingTabId);
            console.log('intake form         --> '+this.isPatentIntakeForm);
            console.log('isConsoleNavigation -->',this.isConsoleNavigation);
            console.log('enclosingTabId      -->',this.enclosingTabId);
            console.log('Selected Client ID  -->',this.enclosingTabId);
            // if (!this.isConsoleNavigation || !this.enclosingTabId) {
            //     return;
            // }

            // Get Lightning Console API
            if (this.isConsoleNavigation) {
                // Open a subtab under the current tab
             if (this.isPatentIntakeForm) {
                //     let compDefinition = {
                //         componentDef: "c:assetIntakeForm",
                //         attributes:{
                //             "clientId": this.selectedClientId,
                //             "conflictCheckId":  this.conflictCheckSelectedRecordId,
                //             "clientReferenceNumber": this.selectedClientReferenceNumber,
                //             "clientGroupNumber": this.selectedClientGroupNumber,
                //             "isPatent":true
                //         }
                //     };
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Asset_Intake_Form'
                        },
                        state: {
                            c__randomId: Date.now(),
                            c__clientId: this.selectedClientId,
                            c__conflictCheckId:  this.conflictCheckSelectedRecordId,
                            c__clientReferenceNumber: this.selectedClientReferenceNumber,
                            c__isPatent:true,
                            c__clientGroupNumber : this.selectedClientGroupNumber,
                            c__matterTitle : this.matterTitle,
                            
                        },
                        focus: true,
                        label: 'Asset Intake Form'
                    });
                
                    // // Base64 encode the compDefinition JS object
                    // let encodedDef = btoa(JSON.stringify(compDefinition));
                    // let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'Patent Intake Form' };
                    // openSubtab(this.tabId, params);
                } else if (this.isTrademarkIntakeForm){
                    // let compDefinition = {
                    //     componentDef: "c:assetIntakeForm",
                    //     attributes:{
                    //         "clientId": this.selectedClientId,
                    //         "conflictCheckId":  this.conflictCheckSelectedRecordId,
                    //         "clientReferenceNumber": this.selectedClientReferenceNumber,
                    //         "isTrademark":true,
                    //         "apiName":"Asset_Intake_Form"
                    //     }
                    // };
                
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Asset_Intake_Form'
                        },
                        state: {
                            c__randomId: Date.now(),
                            c__clientId: this.selectedClientId,
                            c__conflictCheckId:  this.conflictCheckSelectedRecordId,
                            c__clientReferenceNumber: this.selectedClientReferenceNumber,
                            c__clientGroupNumber : this.selectedClientGroupNumber,
                            c__matterTitle : this.matterTitle,
                            c__isTrademark:true,
                            // "clientId": this.selectedClientId,
                            // "conflictCheckId":  this.conflictCheckSelectedRecordId,
                            // "clientReferenceNumber": this.selectedClientReferenceNumber,
                            // "isTrademark":true,
                            // //"apiName":"Asset_Intake_Form"
                        },
                        focus: true,
                        label: 'Asset Intake Form'
                    });

                    // // Base64 encode the compDefinition JS object
                    // let encodedDef = btoa(JSON.stringify(compDefinition));
                    // let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'Trademark Intake Form' };
                    // openSubtab(this.tabId, params);           
    
                }else if (this.isDisputeIntakeForm){
                    let compDefinition = {
                        componentDef: "c:assetIntakeForm",
                        attributes:{
                            "clientId": this.selectedClientId,
                            "conflictCheckId":  this.conflictCheckSelectedRecordId,
                            "clientReferenceNumber": this.selectedClientReferenceNumber,
                            "isDispute":true
                        }
                    };
                
                    // Base64 encode the compDefinition JS objects
                    let encodedDef = btoa(JSON.stringify(compDefinition));
                    let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'Dispute Intake Form' };
                    openSubtab(this.tabId, params);                
                }
                else if (this.isGMIntakeForm){
                    // let compDefinition = {
                    //     componentDef: "c:assetIntakeGeneralMatter",
                    //     attributes:{
                    //         "clientId": this.selectedClientId,
                    //         "conflictCheckId":  this.conflictCheckSelectedRecordId,
                    //         "clientReferenceNumber": this.selectedClientReferenceNumber,
                    //         // "isGeneralMatter":true
                    //     }
                    // };
                
                    // // Base64 encode the compDefinition JS object
                    // let encodedDef = btoa(JSON.stringify(compDefinition));
                    // let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'General Matter Intake Form' };
                    // openSubtab(this.tabId, params);    
                    
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Asset_Intake_General_Matters'
                        },
                        state: {
                            c__clientId: this.selectedClientId,
                            c__conflictCheckId:  this.conflictCheckSelectedRecordId,
                            c__clientReferenceNumber: this.selectedClientReferenceNumber,
                        },
                        focus: true,
                        label: 'Asset Intake Form'
                    });

                }
            }


        }
        catch (err) {
            alert('JS Error : ccDashboard : findEnclosingTabAndOpenSubtab');
        } 
    }

    donotEngageClient(event) { 
        // TODO: 
        // Either Filter or loop through for isSelected (this.conflictCheckRequests)= true and 
        // verify atleast 1 record is selected. 
        // If selected, show the engagement model
        // If no record is selected, throw a toast message with error that atleast one conflict check record must be selected
        let selectedConflictCheck = [];
        selectedConflictCheck = this.conflictCheckRequests.filter(function (element) {
            return element.isSelected == true
        });

        if (selectedConflictCheck.length > 0) {
            if (selectedConflictCheck.length == 1) {
                this.conflictCheckSelectedRecordId = selectedConflictCheck[0].recordId;
                this.selectedClientStatus = selectedConflictCheck[0].clientStatus;
                this.selectedClientId = selectedConflictCheck[0].clientId;

                if ((selectedConflictCheck[0].isRecordCreator || selectedConflictCheck[0].isOriginatingAttorney) || this.userProfileName === 'System Administrator' || this.userProfileName === 'Docketing Management') {
                    this.isShowDoNotEngagementModal = true;
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Only CC Initiator or Originating Attorney can perform Do Not Engage on this Conflict Check.',
                            mode: 'dismissable',
                            variant: 'error'
                        })
                    );
                }

            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select one Conflict Check record at  a time.',
                        mode: 'dismissable',
                        variant: 'error'
                    })
                );
            }

        } else {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a Conflict Check record to proceed.',
                    mode: 'dismissable',
                    variant: 'error'
                })
            );
        }
    }

    refreshTable() {
        getRecentConflictCheckRequests({ recordId: this.recordId }).then((data) => {
            // Clear the user enter values
            this.wiredConflictCheckRequests = data;
            this.conflictCheckRequests = JSON.parse(JSON.stringify(data)).map(request => ({
                ...request,
                isExpanded: false,  // Set isExpanded to false initially
            }));
            this.numberOfRequests = this.wiredConflictCheckRequests.length;
            this.initializeConflictCheckTable();
            return refreshApex(this.wiredConflictCheckRequests);

        })
            .catch((error) => {
                console.log('Error during Client record Creation.', JSON.stringify(error));
            });
    }


    // TODO: Why we have multiple methods doing the same logic? 
    closeEngagementModal(event) {
        this.isShowEngagementModal = false;
        this.connectedCallback();
    }

    closeDonotEngagementModal(event) {
        this.isShowDoNotEngagementModal = false;
        try {
            this.refreshTable();
        }
        catch (error) {
            console.log(JSON.stringify(error));
        }

        //this.dispatchEvent(new RefreshEvent());
    }
    hideEngagementModal() {
        this.isShowEngagementModal = false;
    }
    hideDonotEngagementModal() {
        this.isShowDoNotEngagementModal = false;

    }


}