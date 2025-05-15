/* ccDashboardChild.js */
/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
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
    focusTab,
    getTabInfo
} from 'lightning/platformWorkspaceApi';

import getConflictCheckRequests from '@salesforce/apex/conflictCheckUtilities.getConflictCheckRequests';

import { updateRecord } from 'lightning/uiRecordApi';
import IS_VERIFIED_FIELD from '@salesforce/schema/Conflict_Check_Search_Result__c.Is_Verified__c';

/** Tabulator resources */
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import MCCTABLEJS from "@salesforce/resourceUrl/MCCTABLEJS";
import MCCTABLECSS from "@salesforce/resourceUrl/MCCTABLECSS";
import FA from "@salesforce/resourceUrl/FA";

export default class CcDashboardChild extends LightningElement {
    @api recordId;   // The conflict check RecordId, passed from the parent
    @track conflictCheckRecords = []; // We'll store the entire list of conflictCheckWrapper
    @track isLoading = false;

    tabulatorLoaded = false;

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

    @wire(EnclosingTabId) enclosingTabId;

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
            alert('JS Error : ccDashboardChild : openTab');
        }
    }

    findEnclosingTabAndOpenSubtab() {
        try {
            // Ensure that we're in a console app and that we have a tab open
            if (!this.isConsoleNavigation || !this.enclosingTabId) {
                return;
            }

            // Open sub tab
            openSubtab(this.enclosingTabId, {
                pageReference: {
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Account',
                        actionName: 'list'
                    }
                }
            });
        }
        catch (err) {
            alert('JS Error : ccDashboardChild : findEnclosingTabAndOpenSubtab');
        }
    }

    async refreshTab() {
        try {
            // Ensure that we're in a console app
            if (!this.isConsoleNavigation) {
                return;
            }

            // Refresh current tab
            const { tabId } = await getFocusedTabInfo();
            await refreshTab(tabId, {
                includeAllSubtabs: true
            });
        }
        catch (err) {
            alert('JS Error : ccDashboardChild : refreshTab');
        }
    }

    async setTabIcon() {
        try {
            // Ensure that we're in a console app
            if (!this.isConsoleNavigation) {
                return;
            }

            // Change current tab icon
            const { tabId } = await getFocusedTabInfo();
            setTabIcon(tabId, TAB_ICON, {
                iconAlt: TAB_ICON_ALT_TEXT
            });
        }
        catch (err) {
            alert('JS Error : ccDashboardChild : setTabIcon');
        }
    }

    async setTabLabel() {
        try {
            // Ensure that we're in a console app
            if (!this.isConsoleNavigation) {
                return;
            }

            // Change current tab label
            const { tabId } = await getFocusedTabInfo();
            setTabLabel(tabId, TAB_LABEL);
        }
        catch (err) {
            alert('JS Error : ccDashboardChild : setTabLabel');
        }
    }

    async highlightTab(event) {
        try {
            // Ensure that we're in a console app
            if (!this.isConsoleNavigation) {
                return;
            }

            // Toggle highlight for current tab
            const highlighted = event.detail.checked;
            const { tabId } = await getFocusedTabInfo();
            setTabHighlighted(tabId, highlighted, {
                pulse: true,
                state: 'success'
            });
        }
        catch (err) {
            alert('JS Error : ccDashboardChild : highlightTab');
        }
    }

    async focusNextTab() {
        try {
            // Ensure that we're in a console app
            if (!this.isConsoleNavigation) {
                return;
            }

            // Get current tab and figure out which tab is next
            const { tabId } = await getFocusedTabInfo();
            const allTabs = await getAllTabInfo();
            const selectedTabIndex = allTabs.findIndex(
                (possibleNextTab) => possibleNextTab.tabId === tabId
            );
            const nextTabId = allTabs[selectedTabIndex + 1].tabId;

            // Focus on next tab
            await focusTab(nextTabId);
        }
        catch (err) {
            alert('JS Error : ccDashboardChild : focusNextTab');
        }
    }

    async closeTab() {
        try {
            // Ensure that we're in a console app
            if (!this.isConsoleNavigation) {
                return;
            }

            // Close current tab
            const { tabId } = await getFocusedTabInfo();
            await closeTab(tabId);
        }
        catch (err) {
            alert('JS Error : ccDashboardChild : closeTab');
        }
    }

    @api updateRecordId(value){
        try{
           this.recordId = value; 
           getConflictCheckRequests({ recordId: this.recordId })
            .then((result) => {
                this.conflictCheckRecords = JSON.parse(JSON.stringify(result));
                console.log('Child LWC fetched: ', JSON.stringify(this.conflictCheckRecords));
                this.isLoading = false;
                this.loadTabulator();
            })
            .catch(error => {
                console.error('Error in child fetch: ', error);
                this.isLoading = false;
                this.conflictCheckRecords = [];
            });
        }catch(err){
            alert('JS Error ::  :: setRecordId')
            console.error(err)
        }
     }

    /* connectedCallback() {
        this.isLoading = true;
        getConflictCheckRequests({ recordId: this.recordId })
            .then((result) => {
                // We store the entire array. 
                // If the apex method returns multiple conflictCheckWrappers, we show them all.
                this.conflictCheckRecords = JSON.parse(JSON.stringify(result));
                console.log('Child LWC fetched: ', JSON.stringify(this.conflictCheckRecords));
                this.isLoading = false;
                // Now load Tabulator resources
                this.loadTabulator();
            })
            .catch(error => {
                console.error('Error in child fetch: ', error);
                this.isLoading = false;
                this.conflictCheckRecords = [];
            });
    } */

    loadTabulator() {
        if (this.tabulatorLoaded) {
            this.initializeTables();
            return;
        }
        this.tabulatorLoaded = true;
        Promise.all([
            loadScript(this, MCCTABLEJS),
            loadStyle(this, MCCTABLECSS),
            loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
        ])
        .then(() => {
            this.initializeTables();
        })
        .catch(err => {
            console.error('Error loading Tabulator in child: ', err);
        });
    }

    renderedCallback() {
        // If we already loaded Tabulator and have data, re-initialize 
        if (this.tabulatorLoaded && this.conflictCheckRecords.length > 0) {
            this.initializeTables();
        }
    }

    sfdcURL = window.location.origin;

    async findEnclosingTabAndOpenSubtab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
        try {
            // Ensure that we're in a console app and that we have a tab open
            if (!this.isConsoleNavigation || !this.enclosingTabId) {
                return;
            }

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
           // this.openAsNewTab(type, objectApiName, recordId, actionName);
            alert('JS Error : ccDashboardChild : findEnclosingTabAndOpenSubtab');
            try{
                console.error(this.serializeError(err));
            }catch(e){}

            try{
                console.error(err);
                console.error(JSON.stringify(err));
            }catch(e){}
        }

    }

    formatRecordLink(value, recordId){
       try{
        // let output = document.createElement("span");
        let hyperlink = document.createElement("a");
        let href = this.sfdcURL + "/" + recordId;
        hyperlink.href = href
        hyperlink.textContent = value;
        hyperlink.style.fontWeight = "bold";
        hyperlink.style.color = "#c29304";
        hyperlink.addEventListener("click", (event) => {
            event.preventDefault();
            if (this.isConsoleNavigation) {
                this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
            }
            else {
                window.open(href);
            }
        });

        //output.appendChild(hyperlink);
        return hyperlink;
       }catch(err){
           alert('JS Error ::  :: formatRecordLink')
           console.error(err);
           console.error(this.serializeError(err));
       }
    }

    initializeTables() {
        const baseUrl = window.location.origin;

        // If no data, skip
        if (!this.conflictCheckRecords || this.conflictCheckRecords.length === 0) {
            return;
        }
        
        // Loop over each conflictCheckWrapper 
        this.conflictCheckRecords.forEach(ccRec => {

            // 1) clientRecords
            if (ccRec.clientRecords && ccRec.clientRecords.length > 0) {
                const selector = `.client-subtable[data-record-id="${ccRec.recordId}"]`;
                let clientDiv = this.template.querySelector(selector);
                if (clientDiv && !clientDiv.dataset.initDone) {
                    clientDiv.dataset.initDone = 'true';
                    new Tabulator(clientDiv, {
                        layout: 'fitColumns',
                        data: ccRec.clientRecords,
                        pagination: 'local',
                        paginationSize: 20,
                        columns: [
                            {
                                title: "Client",
                                field: "clientName",
                                formatter: (cell) => {
                                    const rowData = cell.getRow().getData();
                                    const val = cell.getValue() || '';
                                    return this.formatRecordLink(val, rowData.clientId);
                                }
                            },
                            { title: "Client Number", field: "clientNumber" },
                            { title: "Group Number", field: "groupNumber" },
                            { title: "Classification", field: "classification" },
                            {
                                title: "Active",
                                field: "isActive",
                                formatter: 'tickCross'
                            },
                            {
                                title: "Verified",
                                field: "isVerified",
                                formatter: (cell) => {
                                    return cell.getValue()
                                        ? "<i class='fa fa-toggle-on'></i>"
                                        : "<i class='fa fa-toggle-off'></i>";
                                },
                                cellClick: (e, cell) => {
                                    this.toggleIsVerified(cell);
                                }
                            }
                        ]
                    });
                }
            }

            // 2) contributorRecords
            if (ccRec.contributorRecords && ccRec.contributorRecords.length > 0) {
                const selector = `.contributor-subtable[data-record-id="${ccRec.recordId}"]`;
                let contribDiv = this.template.querySelector(selector);
                if (contribDiv && !contribDiv.dataset.initDone) {
                    contribDiv.dataset.initDone = 'true';
                    new Tabulator(contribDiv, {
                        layout: 'fitColumns',
                        data: ccRec.contributorRecords,
                        pagination: 'local',
                        paginationSize: 20,
                        columns: [
                            {
                                title: "Name",
                                field: "contributorName",
                                formatter: (cell) => {
                                    const rowData = cell.getRow().getData();
                                    const val = cell.getValue() || '';
                                    return this.formatRecordLink(val, rowData.inventorId);
                                }
                            },
                            { title: "Type", field: "contributorType" },
                            { title: "Matter Type", field: "matterType" },
                            { title: "Docket #", field: "docketNumber" },
                            {
                                title: "Verified",
                                field: "isVerified",
                                formatter: (cell) => {
                                    return cell.getValue()
                                        ? "<i class='fa fa-toggle-on'></i>"
                                        : "<i class='fa fa-toggle-off'></i>";
                                },
                                cellClick: (e, cell) => {
                                    this.toggleIsVerified(cell);
                                }
                            }
                        ]
                    });
                }
            }

            // 3) keywordRecords
            if (ccRec.keywordRecords && ccRec.keywordRecords.length > 0) {
                const selector = `.keyword-subtable[data-record-id="${ccRec.recordId}"]`;
                let keywordDiv = this.template.querySelector(selector);
                if (keywordDiv && !keywordDiv.dataset.initDone) {
                    keywordDiv.dataset.initDone = 'true';
                    new Tabulator(keywordDiv, {
                        layout: 'fitColumns',
                        data: ccRec.keywordRecords,
                        pagination: 'local',
                        paginationSize: 20,
                        columns: [
                            {
                                title: "Keyword",
                                field: "keyword",
                                formatter: (cell) => {
                                    const rowData = cell.getRow().getData();
                                    const val = cell.getValue() || '';
                                    return this.formatRecordLink(val, rowData.keywordId);
                                }
                            },
                            { title: "Matter Type", field: "matterType" },
                            { title: "Matter Name", field: "matterName" },
                            { title: "Docket #", field: "docketNumber" },
                            {
                                title: "Verified",
                                field: "isVerified",
                                formatter: (cell) => {
                                    return cell.getValue()
                                        ? "<i class='fa fa-toggle-on'></i>"
                                        : "<i class='fa fa-toggle-off'></i>";
                                },
                                cellClick: (e, cell) => {
                                    this.toggleIsVerified(cell);
                                }
                            }
                        ]
                    });
                }
            }

            // 4) entityRecords
            if (ccRec.entityRecords && ccRec.entityRecords.length > 0) {
                const selector = `.entity-subtable[data-record-id="${ccRec.recordId}"]`;
                let entityDiv = this.template.querySelector(selector);
                if (entityDiv && !entityDiv.dataset.initDone) {
                    entityDiv.dataset.initDone = 'true';
                    new Tabulator(entityDiv, {
                        layout: 'fitColumns',
                        data: ccRec.entityRecords,
                        pagination: 'local',
                        paginationSize: 20,
                        columns: [
                            {
                                title: "Entity Name",
                                field: "entityName",
                                formatter: (cell) => {
                                    const rowData = cell.getRow().getData();
                                    const val = cell.getValue() || '';
                                    return this.formatRecordLink(val, rowData.entityId);
                                }
                            },
                            { title: "Entity Type", field: "entityType" },
                            { title: "Primary Contact", field: "entityContact" },
                            {
                                title: "Active",
                                field: "entityActive",
                                formatter: 'tickCross'
                            },
                            {
                                title: "Verified",
                                field: "isVerified",
                                formatter: (cell) => {
                                    return cell.getValue()
                                        ? "<i class='fa fa-toggle-on'></i>"
                                        : "<i class='fa fa-toggle-off'></i>";
                                },
                                cellClick: (e, cell) => {
                                    this.toggleIsVerified(cell);
                                }
                            }
                        ]
                    });
                }
            }

            // 5) chainOfTitleRecords
            if (ccRec.chainOfTitleRecords && ccRec.chainOfTitleRecords.length > 0) {
                const selector = `.chain-subtable[data-record-id="${ccRec.recordId}"]`;
                let chainDiv = this.template.querySelector(selector);
                if (chainDiv && !chainDiv.dataset.initDone) {
                    chainDiv.dataset.initDone = 'true';
                    new Tabulator(chainDiv, {
                        layout: 'fitColumns',
                        data: ccRec.chainOfTitleRecords,
                        pagination: 'local',
                        paginationSize: 20,
                        columns: [
                            {
                                title: "Client",
                                field: "title",
                                formatter: (cell) => {
                                    const rowData = cell.getRow().getData();
                                    const val = cell.getValue() || '';
                                    return this.formatRecordLink(val, rowData.chainOfTitleId);
                                }
                            },
                            { title: "Applicant/Assignee Name", field: "applicantName" },
                            { title: "Classification", field: "classification" },
                            { title: "Role", field: "role" },
                            { title: "From Date", field: "fromDate" },
                            { title: "To Date", field: "toDate" },
                            { title: "Matter Type", field: "matterType" },
                            { title: "Docket #", field: "docketNumber" },
                            {
                                title: "Verified",
                                field: "isVerified",
                                formatter: (cell) => {
                                    return cell.getValue()
                                        ? "<i class='fa fa-toggle-on'></i>"
                                        : "<i class='fa fa-toggle-off'></i>";
                                },
                                cellClick: (e, cell) => {
                                    this.toggleIsVerified(cell);
                                }
                            }
                        ]
                    });
                }
            }

            // 6) matterRecords
            if (ccRec.matterRecords && ccRec.matterRecords.length > 0) {
                const selector = `.matter-subtable[data-record-id="${ccRec.recordId}"]`;
                let matterDiv = this.template.querySelector(selector);
                if (matterDiv && !matterDiv.dataset.initDone) {
                    matterDiv.dataset.initDone = 'true';
                    new Tabulator(matterDiv, {
                        layout: 'fitColumns',
                        data: ccRec.matterRecords,
                        pagination: 'local',
                        paginationSize: 20,
                        columns: [
                            //{ title: "Matter Id", field: "matterId" },
                            { title: "Docket #", field: "docket_Number",
                                formatter: (cell) => {
                                    const rowData = cell.getRow().getData();
                                    const val = cell.getValue() || '';
                                    return this.formatRecordLink(val, rowData.matterId);
                                }
                            },
                             { title: "Title", field: "title" },
                            { title: "Matter Name", field: "Matter_Name" },
                            { title: "Status", field: "status" }
                        ]
                    });
                }
            }

        });
    }

    toggleIsVerified(cell) {
        const rowData = cell.getRow().getData();
        rowData.isVerified = !rowData.isVerified;

        let fields = {};
        fields[IS_VERIFIED_FIELD.fieldApiName] = rowData.isVerified;
        fields['Id'] = rowData.recordId; // the Conflict_Check_Search_Result__c Id

        updateRecord({ fields })
            .then(() => {
                console.log('Updated isVerified successfully');
                cell.getRow().update(rowData);
            })
            .catch(error => {
                console.error('Error updating isVerified: ', error);
            });
    }
}