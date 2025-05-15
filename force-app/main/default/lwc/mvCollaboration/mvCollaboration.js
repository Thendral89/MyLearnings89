import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { createElement } from 'lwc';
import mvEmailMessageDisplay from 'c/mvEmailMessageDisplay';
//import mvFinalDocumentDisplay from 'c/mvFinalDocumentDisplay';
//import cmpNADocuments from 'c/cmpNADocuments';

import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import lwcTaskRecordView from 'c/lwcTaskRecordView';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
/* Import Refresh Event*/
import { refreshApex } from '@salesforce/apex';

/* Import the Static Resources for Tabulator Open source libraries*/
import MAXVALTABLECSS from "@salesforce/resourceUrl/MAXVALTABLECSS";
import MAXVALTABLEJS from "@salesforce/resourceUrl/MAXVALTABLEJS";
import FA from "@salesforce/resourceUrl/FA";

/* Import the Apex Method */
import getCollaborationRecords from '@salesforce/apex/mvCollaborationService.getCollaborationRecords';
import taskCount from '@salesforce/apex/mvCollaborationService.taskCount';
import emailCount from '@salesforce/apex/mvCollaborationService.emailCount';
import getAttachement from '@salesforce/apex/mvCollaborationService.getAttachement';
import getTaskDirection from '@salesforce/apex/mvCollaborationService.getTaskDirection';
import createEmlFromEmail from '@salesforce/apex/mvEmailUtilities.createEmlFromEmail';
import getHtmlBody from '@salesforce/apex/mvEmailUtilities.getHtmlBody';

let aggregateValues = {
    aggregateCollaborations: 0,
    aggregateEmails: 0,
    aggregateTasks: 0,
    aggregateEmailReceived: 0,
    aggregateEmailsOut: 0,
    aggregateFinalDocument: 0
}

const COLLABORATION_TYPE_EMAIL = 'EMAIL';
const COLLABORATION_TYPE_TASK = 'TASK';
const COLLABORATION_TYPE_FINAL_DOCUMENT = 'FINAL_DOCUMENT';

export default class MvCollaboration extends NavigationMixin(LightningElement) {
    componentConstructor;
    @api recordId;
    @api objectApiName;
    @api disableColors = false;
    @track isSpinner = false;
    @track isRenderedCallBackInitialized = false;
    @track wiredCollaborationRecords; // Holding variable used in refreshApex for Collaboration Records
    @track wiredCollaborationCounts = aggregateValues;  // Holding variable used in refreshApex for Collaboration Counts
    _collaborationRecords = [];
    collaborationRecords = [];
    tileFilter;
    table;
    paginationSize = 25;
    taskId;
    finalDocId;
    @track emailAction; 
    @track headerLabel;
    @track emailMessageId = null; 
    @track showNewTaskModal = false;
    @track showEditTaskModal = false;
    @track showEditFinalDocModal = false;
    @track showNewEmailModal= false;
    @track isEdited = false;
    
    connectedCallback() {
        console.log('Connected Callback');
        this.tileFilter = "aggregateCollaborations";
        this.getCollaborationData();
        //this.getEmailCount();
    }

    renderedCallback() {
        if (this.isRenderedCallBackInitialized) return;
        this.isRenderedCallBackInitialized = true;
    
        Promise.all([
            loadScript(this, MAXVALTABLEJS),
            loadStyle(this, MAXVALTABLECSS),
            loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
        ])
        .then(() => {
            const defaultTile = this.template.querySelector('[data-filtertype="aggregateCollaborations"]');
            if (defaultTile) {
                defaultTile.classList.add('selected');
            }
        });
    }

    handleFilters(event) { 
        try { 
            this.isSpinner = true;
            const newSelection = event.currentTarget.dataset.filtertype;
            if (this.tileFilter === newSelection && this.isEdited === false ) {
                console.log("Same filter selected, no action taken.");
                this.isSpinner = false; 
                return; 
            }

            // Remove the 'selected' class from any currently selected element
            const previousSelection = this.template.querySelector('.selected');
            if (previousSelection) {
                previousSelection.classList.remove('selected');
            }

            // Add 'selected' class to the new selection and update the tileFilter
            event.currentTarget.classList.add('selected');
            this.tileFilter = newSelection;
    
            let filteredData = this._collaborationRecords.filter((item) => {
                switch (this.tileFilter) {
                    case "aggregateCollaborations":
                        return true; // Its sum of all other tabs
                    case "aggregateEmails":
                        return item.recordType === COLLABORATION_TYPE_EMAIL;
                    case "aggregateTasks":
                        return item.recordType === COLLABORATION_TYPE_TASK;
                    case "aggregateEmailReceived":
                        // return item.isIncoming === true;
                        return (item.isIncoming || '').toUpperCase() === 'IN';
                    case "aggregateEmailsOut":
                        // return item.isIncoming === false;
                        return (item.isIncoming || '').toUpperCase() === 'OUT';
                    case "aggregateFinalDocument":
                        return item.recordType === COLLABORATION_TYPE_FINAL_DOCUMENT;
                    default:
                        return true;
                }
            });
    
            this.collaborationRecords = filteredData;
            this.initializeCollaborationTable();
        } catch (err) {
            console.error(err);
        }
    }
    
    getCollaborationData() {
        /* if (!forceRefresh && this.hasFetchedCollaborationData) {
            console.log('Data already fetched, skipping.');
            return Promise.resolve();
        } */
       console.log('Collaboration data Called');
        getCollaborationRecords({ recordId: this.recordId })
        .then((data) => {
            console.log('Data',JSON.stringify(data));
            if(data){
                this.isSpinner = true;
            }
            
            console.log(JSON.stringify(data));
            this.wiredCollaborationRecords = data;
            let _collaborationRecords = JSON.parse(JSON.stringify(data)).map(request => ({
                ...request,
                isExpanded: false,  // Set isExpanded to false initially
            }));
            this._collaborationRecords = _collaborationRecords;
            this.collaborationRecords = _collaborationRecords;
            
            this.prepareStatistics();
            //this.initializeCollaborationTable(this.tileFilter);
            this.initializeCollaborationTable();
            this.hasFetchedCollaborationData = true;
        })
        .catch(err => {
            console.error( JSON.stringify(this.serializeError( err ) ) );
        });
    }

    /* handleOpenFileUpload() {
        try {
            // Remove any existing component instance before adding a new one
            const existingComponent = this.template.querySelector('c-cmp-n-a-documents');
            if (existingComponent) {
                existingComponent.remove();
            }
            const childComponent = createElement('c-cmp-n-a-documents', {
                is: cmpNADocuments
            });

            // Assign properties correctly
            childComponent.recordId = this.recordId;
            childComponent.objectApiName = this.objectApiName;
            childComponent.showRecordPupup = true;
            childComponent.addEventListener('close', () => {
                childComponent.remove();
            });

            this.template.appendChild(childComponent);
            // Append to the template's DOM
            this.template.appendChild(childComponent);
        } catch (error) {
            console.error('Error creating or appending cmpNADocuments:', error);
        }
    } */
    getCollaborationData2(forceRefresh = false) {
        if (!forceRefresh && this.hasFetchedCollaborationData) {
            console.log('Data already fetched, skipping.');
            return Promise.resolve();
        }
        getCollaborationRecords({ recordId: this.recordId })
            .then((data) => {
                if(data){
                    this.isSpinner = true;
                }
                
                console.log(JSON.stringify(data));
                let mvcollaborationsCount = 0;
                let emailsCount=0;
                let emailReceivedCount = 0;
                let emailOutCount = 0;                
                let taskCount = 0;
                let finalDocumentCount = 0;
        
                let _collaborationRecords = JSON.parse(JSON.stringify(data)).map(request => {
                    mvcollaborationsCount++;
        
                    if (request.recordType === COLLABORATION_TYPE_EMAIL) {
                        emailsCount++;
                    }
        
                    console.log('request.isIncoming:', request.isIncoming);
                    const normalizedIncomingValue = request.isIncoming ? request.isIncoming.toUpperCase() : '';
                    console.log('normalizedIncomingValue:', normalizedIncomingValue);
        
                    if (normalizedIncomingValue === 'IN') {
                        emailReceivedCount++;
                    } else if (normalizedIncomingValue === 'OUT') {
                        emailOutCount++;  
                    } else {
                        console.log('other value for request.isIncoming:', request.isIncoming);
                    }
        
                    if (request.recordType === COLLABORATION_TYPE_TASK) {
                        taskCount++;
                    }        
                    if (request.recordType === COLLABORATION_TYPE_FINAL_DOCUMENT) {
                        finalDocumentCount++;
                    }
        
                    return { ...request, isExpanded: false }; 
                });
        
                this._collaborationRecords = _collaborationRecords;
                this.collaborationRecords = _collaborationRecords;
                this.hasFetchedCollaborationData = true;
        
                this.wiredCollaborationCounts = {
                    aggregateCollaborations: mvcollaborationsCount,
                    aggregateEmails: emailsCount,
                    aggregateTasks: taskCount,
                    aggregateEmailReceived: emailReceivedCount,
                    aggregateEmailsOut: emailOutCount,
                    aggregateFinalDocument: finalDocumentCount
                };
        
                const selectedTile = this.template.querySelector(`[data-filtertype="${this.tileFilter}"]`);
                if (selectedTile) {
                    this.handleFilters({ currentTarget: selectedTile });
                }
                this.isEdited = false;
        
            })
            .catch(err => {
                console.error(JSON.stringify(this.serializeError(err)));
            });  
    }
        

    prepareStatistics(){
       try{
            const wiredCollaborationCounts = {...this.wiredCollaborationCounts};
            console.log('wiredCollaborationCounts:', JSON.stringify(wiredCollaborationCounts));
            console.log('this._collaborationRecords:', JSON.stringify(this._collaborationRecords));
            this._collaborationRecords.forEach( item => {
                wiredCollaborationCounts.aggregateCollaborations ++;

                if(item.recordType === COLLABORATION_TYPE_EMAIL){//COLLABORATION_TYPE_TASK
                    wiredCollaborationCounts.aggregateEmails ++;
                    // console.log('item.isIncoming:', item.isIncoming);
                    // if(item.isIncoming === true){
                    //     wiredCollaborationCounts.aggregateEmailReceived ++;
                    //     console.log('wiredCollaborationCounts.aggregateEmailReceived++:' ,wiredCollaborationCounts.aggregateEmailReceived);
                    // }
                    // else{
                    //     wiredCollaborationCounts.aggregateEmailsOut ++;
                    // }
                }
                console.log('item.isIncoming:', item.isIncoming);
                    // if(item.isIncoming === true){
                    //     wiredCollaborationCounts.aggregateEmailReceived ++;
                    //     console.log('wiredCollaborationCounts.aggregateEmailReceived++:' ,wiredCollaborationCounts.aggregateEmailReceived);
                    // }
                    // else{
                    //     wiredCollaborationCounts.aggregateEmailsOut ++;
                    // }
                    const normalizedIncomingValue = item.isIncoming ? item.isIncoming.toUpperCase() : '';
                    if (normalizedIncomingValue === 'IN') {
                        wiredCollaborationCounts.aggregateEmailReceived++;
                        console.log('wiredCollaborationCounts.aggregateEmailReceived++:', wiredCollaborationCounts.aggregateEmailReceived);
                    } else if (normalizedIncomingValue === 'OUT') {
                        wiredCollaborationCounts.aggregateEmailsOut++;
                    } else {
                        console.log('other value for item.isIncoming:', item.isIncoming);
                    }

                if(item.recordType === COLLABORATION_TYPE_TASK){
                    wiredCollaborationCounts.aggregateTasks ++;
                }

                if(item.recordType === COLLABORATION_TYPE_FINAL_DOCUMENT){
                    wiredCollaborationCounts.aggregateFinalDocument ++;
                }

            });
            this.wiredCollaborationCounts = wiredCollaborationCounts;
       }catch(err){
           console.error( JSON.stringify(this.serializeError( err ) ) );
       }
    }
    getTotalCollobrationCount() {
        let mvcollaborationsCount = 0;
        let emailReceivedCount = 0;
        let emailOutCount = 0;
        let taskCount = 0;
        let finalDocumentCount = 0;
    
        getCollaborationRecords({ recordId: this.recordId })
            .then((data) => {
                if (data) {
                    console.log('total collab data', JSON.stringify(data));
                    
                    data.forEach(item => {
                        mvcollaborationsCount++;
    
                        if(item.recordType === COLLABORATION_TYPE_EMAIL){
                            emailOutCount++;
                        }
                        console.log('item.isIncoming:', item.isIncoming);
                            const normalizedIncomingValue = item.isIncoming ? item.isIncoming.toUpperCase() : '';
                            console.log('normalizedIncomingValue:',normalizedIncomingValue);
                            if (normalizedIncomingValue === 'IN') {
                                emailReceivedCount++;
                            } else if (normalizedIncomingValue === 'OUT') {
                                emailReceivedCount++;
                            } else {
                                console.log('other value for item.isIncoming:', item.isIncoming);
                            }
        
                        if(item.recordType === COLLABORATION_TYPE_TASK){
                            taskCount++;
                        }        
                        if(item.recordType === COLLABORATION_TYPE_FINAL_DOCUMENT){
                            finalDocumentCount++;
                        }
                    });
                    this.wiredCollaborationCounts = {
                        aggregateCollaborations: mvcollaborationsCount,
                        aggregateEmails: emailOutCount,
                        aggregateTasks: taskCount,
                        aggregateEmailReceived: emailReceivedCount,
                        aggregateEmailsOut: emailOutCount,
                        aggregateFinalDocument: finalDocumentCount
                    };
                }
            })
            .catch(err => {
                console.error(JSON.stringify(this.serializeError(err)));
            });
    }
    

    initializeCollaborationTable() {
        try{
            console.log('In Method : Initializing Dynamic Collaboration Table');
            if (this.table) {
                this.table.clearData(); 
                this.table.destroy(); 
                this.table = null;
            }
            console.log('collaboration Records',JSON.stringify(this.collaborationRecords));
            window.setTimeout(()=>{
                this.component = this.template.querySelector('[data-id="dynamicCollaboration"]');
                //Initialize table
                let baseColumns = [
                    {
                        title: "", field: "isExpanded", align: "center", width: "25", resizable: false, headerSort: false, formatter: function (cell, formatterParams) {
                            //if (cell.getRow().getData().recordType === COLLABORATION_TYPE_EMAIL || cell.getRow().getData().recordType === COLLABORATION_TYPE_TASK) {
                                if (cell.getRow().getData().isExpanded) {
                                    return "<i class='fa fa-minus-circle' title='Collapse'></i>";
                                } else {
                                    return "<i class='fa fa-plus-circle' title='Expand'></i>";
                                }
                            //}
                        }, cellClick: async (e, cell) => {
                            e.stopPropagation();
                            e.preventDefault();
                        
                            const container = this.template.querySelector('.tabulator-container');
                            const rowElement = cell.getRow().getElement();
                        
                            const scrollTopBefore = container.scrollTop;
                        
                            const rowData = cell.getRow().getData();
                            const id = rowData.recordId;
                            const isExpanded = rowData.isExpanded;
                            cell.getRow().update({ isExpanded: !isExpanded });
                            
                            const subTableSelector = `.subTable${id}`;
                            const subTables = rowElement.querySelectorAll(subTableSelector);
                            
                            let childLoadPromises = [];
                        
                            subTables.forEach(async (subTable) => {
                                if (!isExpanded) {
                                    if (!subTable.hasChildNodes()) {
                                        let childComponent;
                        
                                        if (rowData.recordType === 'EMAIL') {
                                            childComponent = createElement('c-mv-email-message-display', {
                                                is: mvEmailMessageDisplay
                                            });
                                        } else if (rowData.recordType === 'TASK') {
                                            childComponent = createElement('c-lwc-task-record-view', {
                                                is: lwcTaskRecordView
                                            });
                                        } else if (rowData.recordType === 'FINAL_DOCUMENT') {
                                            childComponent = createElement('c-mv-final-document-display', {
                                                is: mvFinalDocumentDisplay
                                            });
                                        }
                        
                                        if (childComponent) {
                                            try {
                                                const componentLoadPromise = childComponent.updateRecordId(id);
                                                childLoadPromises.push(componentLoadPromise);
                                                subTable.appendChild(childComponent);
                                            } catch (error) {
                                                console.error('Error in childComponent.updateRecordId:', error);
                                            }
                                        }
                                    }
                                    subTable.style.visibility = 'visible';
                                    subTable.style.display = 'block';
                                } else {
                                    subTable.style.visibility = 'hidden';
                                    subTable.style.display = 'none';
                                }
                            });
                        
                            if (!isExpanded) {
                                container.style.height = "calc(100vh - 180px)";
                            } else {
                                container.style.height = "calc(100vh - 320px)";
                            }

                            this.table.updateLayout();
                            // Wait for components to load and restore the scroll position
                            /* Promise.all(childLoadPromises).then(() => {
                                setTimeout(() => {
                                    this.table.updateLayout();
                                }, 400); 
                            }); */
                        }
                                 
                    },
                    {
                        title: "", field: "recordType", align: "center", width: "25", resizable: false, headerSort: false, 
                        formatter: function (cell, formatterParams) {
                            const rowData = cell.getRow().getData();
                            const fileExtension = rowData.fileExtension;
                            
                            // Check if the recordType is FINAL_DOCUMENT
                            if (rowData.recordType === "FINAL_DOCUMENT") {
                                if (fileExtension==="pdf") {
                                    return "<i class='fa fa-file-pdf-o' title='PDF Document'></i>";
                                } else if (fileExtension==="doc" || fileExtension==="docx") {
                                    return "<i class='fa fa-file-word-o' title='Word Document'></i>";
                                } else if (fileExtension==="xls" || fileExtension==="xlsx") {
                                    return "<i class='fa fa-file-excel-o' title='Excel Document'></i>";
                                } else if (fileExtension==="ppt" || fileExtension==="pptx") {
                                    return "<i class='fa fa-file-powerpoint-o' title='PowerPoint Document'></i>";
                                } else if (fileExtension==="jpg" || fileExtension==="png" || fileExtension==="jpeg") {
                                    return "<i class='fa fa-file-photo-o' title='Image Document'></i>";
                                } else {
                                    return "<i class='fa fa-file' title='Document'></i>"; // Default icon
                                }
                            }
                    
                            // Other record types
                            if (rowData.recordType === "EMAIL") {
                                return "<i class='fa fa-envelope' style='color:#007bff;' title='Email'></i>";
                            } else if (rowData.recordType === "TASK") {
                                return "<i class='fa fa-tasks' style='color: #28a745;' title='Task'></i>";
                            }
                    
                            // Fallback
                            return "<i class='fa fa-file' title='Document'></i>";
                        },
                        cellClick: (e, cell) => this.handleNavigateClick(e, cell)
                    },
                    {
                        title: "", field: "isIncoming", align: "center", width: "25", resizable: false, headerSort: false, formatter: function (cell, formatterParams) {
                            // if (cell.getRow().getData().isIncoming) {
                            //     console.log('cell.getRow().getData().isIncoming',JSON.stringify(cell.getRow().getData().isIncoming));
                            //     return "<i class='fa fa-arrow-down' title='IN'></i>";
                            // } else {
                            //     return "<i class='fa fa-arrow-up' title='OUT'></i>";
                            // }
                            const isIncoming = (cell.getRow().getData().isIncoming || '').toUpperCase();
                            console.log('cell.getRow().getData().isIncoming', JSON.stringify(isIncoming));

                            if (isIncoming === '') {
                                return ''; 
                            } else if (isIncoming === 'IN') {
                                return "<i class='fa fa-arrow-down' title='" + isIncoming + "'></i>";
                            } else if (isIncoming === 'OUT') {
                                return "<i class='fa fa-arrow-up' title='" + isIncoming + "'></i>";
                            } else if (isIncoming === 'DEPARTMENT') {
                                return "<i class='fa fa-building' title='" + isIncoming + "'></i>";
                            }else if (isIncoming === 'INTERNAL') {
                                return "<i class='fa fa-users' title='" + isIncoming + "'></i>";
                            }else if (isIncoming === 'LEGACYIPM') {
                                return "<i class='fa fa-folder-open' title='" + isIncoming + "'></i>";
                            }else {
                                return "<i class='fa fa-building' title='" + isIncoming + "'></i>";
                            }
                        }
                    },
                    {
                        title: "", field: "hasAttachment", align: "center", width: "25", resizable: false, headerSort: false, formatter: function (cell, formatterParams) {
                            if (cell.getRow().getData().hasAttachment) {
                                return `<i class='fa fa-file-zip-o' title="Download Attachments Zip"></i>`;
                            }
                            return "<i></i>";
                        },
                        cellClick: (e, cell) => this.handleAttachmentClick(e, cell)
                    },
                    {
                        title: "Date",
                        field: "createdDate",
                        width: 180,
                        sorter: function(a, b, aRow, bRow, column, dir, sorterParams){
                            let aDate = new Date(a);
                            let bDate = new Date(b);
                            return aDate - bDate;
                        },
                        formatter: function (cell, formatterParams) {
                                return cell.getValue();
                        }
                    },
                    {
                        title: "Subject",
                        field: "subject",
                        headerFilter: true,
                        formatter: function (cell, formatterParams) {
                            const rowData = cell.getRow().getData();
                            const recordType = rowData.recordType;
                            let colorClass = "";

                            if (!this.disableColors) {
                                if (recordType === "EMAIL") {
                                    colorClass = "font-primary"; 
                                } else if (recordType === "TASK") {
                                    colorClass = "font-success";
                                } else if (recordType === "FINAL_DOCUMENT") {
                                    colorClass = "font-final-document";
                                }
                                else{
                                    colorClass = "textFormatting";
                                }
                            } else{
                                colorClass = "textFormatting";
                            }
                            

                            return `<div class="${colorClass}" style="font-weight: bold; white-space: normal;">
                                        ${rowData.subject.replace(/\n/g, '<br/>')}
                                    </div>`;
                        },
                    },
                    {
                        title: "Comment",
                        field: "comment",
                        headerFilter: "input",
                        formatter: "html",
                        formatter: function (cell) {
                            const commentValue = cell.getValue() || "";
                            return `<div style="white-space: pre-wrap;">${commentValue}</div>`;
                        }
                        /* formatter: function (cell, formatterParams) {
                            const rowData = cell.getRow().getData();
                            const emailComment = rowData.comment || "";
                            const paralegalComment = rowData.paralegalComment || "";
                            const attorneyComment = rowData.attorneyComment || "";
                    
                            let combinedComment = "";
                    
                            if (emailComment) {
                                combinedComment += `<div style="white-space: pre-wrap;">${emailComment}</div>`;
                            }
                            if (paralegalComment) {
                                combinedComment += `<div style="white-space: pre-wrap;"><strong>Paralegal Comment:</strong> ${paralegalComment}</div>`;
                            }
                            if (attorneyComment) {
                                combinedComment += `<div style="white-space: pre-wrap;"><strong>Attorney Comment:</strong> ${attorneyComment}</div>`;
                            }
                    
                            return combinedComment || "";
                        } */
                    },
                                                    
                    {
                        title: "From", field: "createdBy", headerFilter: true,formatter: "html", width: 200
                    },
                    {
                        title: "To", field: "assignedTo", headerFilter: true, width: 200
                    },
                    {
                        title: "", field: "recordType", align: "center", width: "25", resizable: false, headerSort: false, 
                        formatter: function (cell) {
                            const recordType = cell.getValue();
                            if (recordType === "EMAIL") {
                                return "<i class='fa fa-download' title='Download Email'></i>";
                            } else if (recordType === "FINAL_DOCUMENT") {
                                return "<i class='fa fa-download' title='Download Attachment'></i>";
                            } else if (recordType === "TASK") {
                                return "<i class='fa fa-download' title='Download Task'></i>";
                            }else{
                                return "";
                            }
                        
                        },
                        cellClick: (e, cell) => {
                            const rowData = cell.getRow().getData();
                            const recordId = rowData.recordId;
                            const attachmentId = rowData.linkedContentId;
                            if (rowData.recordType === "EMAIL") {
                                getHtmlBody({ emailMessageId: rowData.recordId })
                                    .then(res => {
                                        let htmlStr = this.generateHtmlBody(res);

                                        createEmlFromEmail({ emailMessageId: rowData.recordId, htmlValue: htmlStr})
                                            .then((base64Content) => {

                                                console.log('[DEBUG] Base64 EML Content returned from Apex');

                                                const dataUrl = `data:message/rfc822;base64,${base64Content}`;

                                                const downloadLink = document.createElement('a');
                                                downloadLink.href = dataUrl;
                                                downloadLink.download = `EmailMessage_${rowData.recordId}.eml`;
                                                document.body.appendChild(downloadLink);
                                                downloadLink.click();
                                                document.body.removeChild(downloadLink);
                                                const evt = new ShowToastEvent({
                                                    title: 'Success',
                                                    message: 'Email has successfully downloaded!!',
                                                    variant: 'success',
                                                });
                                                this.dispatchEvent(evt);
                                            })
                                            .catch((error) => {
                                                const evt = new ShowToastEvent({
                                                    title: 'Error',
                                                    message: 'This Email has some error!!',
                                                    variant: 'error',
                                                });
                                                this.dispatchEvent(evt);
                                                console.error('[ERROR] Error downloading email:', error);
                                            });
                                    })
                                    .catch((error) => {
                                        const evt = new ShowToastEvent({
                                            title: 'Error',
                                            message: 'This Email has some error!!',
                                            variant: 'error',
                                        });
                                        this.dispatchEvent(evt);
                                        console.error('[ERROR] Error downloading email:', error);
                                    });
                                
                            } else if (rowData.recordType === "FINAL_DOCUMENT" && attachmentId) {
                                const downloadUrl = `/sfc/servlet.shepherd/document/download/${attachmentId}`;
                                console.log('[DEBUG] Final Document Download URL:', downloadUrl);
                                window.open(downloadUrl, "_blank");
                            } else if (rowData.recordType === "TASK") {
                                const taskDownloadUrl = `/apex/TaskPDFPage?id=${recordId}`;
                                window.open(taskDownloadUrl, "_blank");
                            } 
                            else {
                                console.warn('[DEBUG] No downloadable content available.');
                            }
                        }
                    },
                    {
                        title: "", field: "recordType", align: "center", width: "25", resizable: false, headerSort: false, 
                        formatter: this.emailActionReplyFormatter,
                        cellClick: (e, cell) => this.handleActionClick(cell)
                    },
                    {
                        title: "", field: "recordType", align: "center", width: "25", resizable: false, headerSort: false, 
                        formatter: this.emailActionReplyAllFormatter,
                        cellClick: (e, cell) => this.handleActionClick(cell)
                    },
                    {
                        title: "", field: "recordType", align: "center", width: "25", resizable: false, headerSort: false, 
                        formatter: this.emailActionForwardFormatter,
                        cellClick: (e, cell) => this.handleActionClick(cell)
                    }

                ];

                this.table = new Tabulator(this.component, {
                    height: "100%",
                    layout: "fitColumns",
                    resizableColumns: false,
                    reactiveData: true,
                    data: this.collaborationRecords,
                    //pagination: "local",
                    history: true,
                    paginationCounter: "rows",
                    pagination: "remote",
                    virtualDom: true,
                    virtualDomBuffer: 10000,
                    paginationSize: this.paginationSize,
                    paginationSizeSelector: [25, 50, 100, 250, 500, 1000],
                    initialSort: [
                        { column: "createdDate", dir: "desc" }  // sort by createdDate in descending order
                    ],
                    columns: baseColumns,
                    rowFormatter: (row) => {
                        const id = row.getData().recordId;
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
                    },                
                });
                this.table.on("tableBuilt", () => {
                    console.log("Table built successfully");
                    this.isSpinner = false; 
                });
            },500);
        }
        catch(err){
                console.error(err);
                this.table.clearData();
                console.error(JSON.stringify(err));
            }
    }

    generateHtmlBody(htmlValue) {
        let el = document.createElement('div');
        el.innerHTML = htmlValue;

        const startStr = '/068';
        const endStr = '?';

        el.querySelectorAll('img').forEach((imgEl) => {
            let src = imgEl.src;
            let pos = src.indexOf(startStr) + startStr.length;
            src = src.substring(pos, src.indexOf(endStr, pos));
            imgEl.src = 'cid:068' + src;
        });

        //el.remove();
        return el.innerHTML;
    }

    emailActionReplyFormatter(cell) {
        const recordType = cell.getRow().getData().recordType;
        const recordId = cell.getRow().getData().recordId;
        const data = cell.getRow().getData();
        const fileExtension = data.fileExtension;
        if (recordType === COLLABORATION_TYPE_EMAIL) {
        return `
            <i class="fa fa-mail-reply email-action" data-id="${recordId}" title="Reply"></i>
        `;
        }else if (recordType === COLLABORATION_TYPE_TASK) {                
            const status = data.status;
                if (status === 'Not Started') {
                    return '<i class="fa fa-circle-thin" title="Not Started"></i>';
                } else if (status === 'In Progress') {
                    return '<i class="fa fa-spinner fa-spin" title="In Progress"></i>';
                } else if (status === 'Completed') {
                    return '<i class="fa fa-check" title="Completed"></i>';
                } else if (status === 'Waiting on someone else') {
                    return '<i class="fa fa-hourglass-half" title="Waiting on someone else"></i>';
                } else if (status === 'Deferred') {
                    return '<i class="fa fa-ban" title="Deferred"></i>';
                } else {
                    return '<i class="fa fa-question-circle-o"></i>';
                }
        }
        else if (recordType === COLLABORATION_TYPE_FINAL_DOCUMENT) {
            if(fileExtension === "msg" || fileExtension === "eml"){
                return "<i></i>";
            }else{
                return `
                <i class="fa fa-search finaldoc-preview-action" data-id="${recordId}" title="Preview"></i>
            `;
            }
            
        }
        else{
            "<i></i>";
        }
    }

    emailActionReplyAllFormatter(cell) {
        const data = cell.getRow().getData();
        if (data.recordType === COLLABORATION_TYPE_EMAIL) {
        return `
            <i class="fa fa-mail-reply-all email-action" data-id="${data.recordId}" title="Reply All"></i>
        `;
        }else if (data.recordType === COLLABORATION_TYPE_TASK) {
            return `
                <i class="fa fa-edit task-action" data-id="${data.recordId}" title="Edit"></i>
            `;
        }
        else if (data.recordType === COLLABORATION_TYPE_FINAL_DOCUMENT) {
            return `
                <i class="fa fa-edit finaldoc-action" data-id="${data.recordId}" title="Edit"></i>
            `;
        }
        else{
            return "<i></i>";
        }
    }

    emailActionForwardFormatter(cell) {
        if (cell.getRow().getData().recordType === COLLABORATION_TYPE_EMAIL) {
        return `
            <i class="fa fa-mail-forward email-action" data-id="${cell.getRow().getData().recordId}" title="Forward"></i>
        `;
        }
        else{
            "<i></i>";
        }
    }

    handleSubjectChange(event) {
        this.headerLabel = event.detail.subject;  
    }

    handleNavigateClick(event, cell) {
        const rowData = cell.getRow().getData();
        const recordId = rowData.recordId; 
        const recordType = rowData.recordType;
    
        console.log('Navigating to Record:', recordId, 'Type:', recordType);
    
        if (!recordId) {
            console.error('No Record ID found for navigation.');
            return;
        }
    
        let url;
        if (recordType === COLLABORATION_TYPE_EMAIL) {
            url = `/lightning/r/EmailMessage/${recordId}/view`;
        } else if (recordType === COLLABORATION_TYPE_TASK) {
            url = `/lightning/r/Task/${recordId}/view`;
        } else if (recordType === COLLABORATION_TYPE_FINAL_DOCUMENT) {
            url = `/lightning/r/Patent_Document__c/${recordId}/view`;
        } else {
            console.error('Unknown record type:', recordType);
            return;
        }
        window.open(url, '_blank');
    }
    handleAttachmentClick(event, cell) {
        const rowData = cell.getRow().getData();
        const recordId = rowData.recordId;
        const recordType = rowData.recordType;

        console.log('Clicked row:', rowData);

        if (!recordId) {
            console.error('No Record ID found for this row.');
            return;
        }
        let fileName;
        if (recordType === COLLABORATION_TYPE_EMAIL) {
            fileName = 'EmailAttachments';
        } else if (recordType === COLLABORATION_TYPE_TASK) {
            fileName = 'TaskAttachments';
        } else {
            console.error('Unknown record type:', recordType);
            return;
        }
        this.downloadAttachments(recordId, fileName);
    }

    downloadAttachments(recordId, fileName) {
        console.log('Fetching attachments for record ID:', recordId);
    
        getAttachement({ recordId })
            .then((result) => {
                console.log('Attachments fetched:', result);
    
                let attachmentIds = '';
                if (result && result.length > 0) {
                    attachmentIds = result.join('/') + '/';
                    attachmentIds = attachmentIds.replace(/.$/, '?');
                }
    
                if (attachmentIds) {
                    // Salesforce download URL with the file name
                    const downloadUrl = `/sfc/servlet.shepherd/version/download/${attachmentIds}&filename=${fileName}`;
                    console.log('Navigating to download URL:', downloadUrl);
    
                    // Ensure the download is handled by Salesforce, but still try to specify the filename
                    const config = {
                        type: 'standard__webPage',
                        attributes: {
                            url: downloadUrl,
                        },
                    };
    
                    this[NavigationMixin.Navigate](config);
                } else {
                    console.warn('No attachments found for record ID:', recordId);
                }
            })
            .catch((error) => {
                console.error('Error fetching attachments:', error);
            });
    }

    handleActionClick(cell) {
        const recordType = cell.getRow().getData().recordType;
        const recordId = cell.getRow().getData().recordId;
        const linkedContentId = cell.getRow().getData().linkedContentId;
        if (recordType === COLLABORATION_TYPE_EMAIL) {
            const clickedButton = cell.getElement().querySelector('.email-action');
            const action = clickedButton?.classList[1];
            if (action === 'fa-mail-reply-all') {
                this.replyAllEmail(recordId);
            } else if (action === 'fa-mail-reply') {
                this.replyEmail(recordId);
            } else if (action === 'fa-mail-forward') {
                this.forwardEmail(recordId);
            }
        } else if (recordType === COLLABORATION_TYPE_TASK) {
            const clickedButton = cell.getElement().querySelector('.task-action');
            const action = clickedButton?.classList[1];
            if (action === 'fa-edit') {
                this.taskId = recordId;
                console.log('this.taskId', this.taskId);
                this.showEditTaskModal = true;
            }
        }
        else if (recordType === COLLABORATION_TYPE_FINAL_DOCUMENT) {
            const clickedButton = cell.getElement().querySelector('.finaldoc-action');
            const clickedPreviewButton = cell.getElement().querySelector('.finaldoc-preview-action');
            const action = clickedButton?.classList[1];
            const actionPreview = clickedPreviewButton?.classList[1];
            if (action === 'fa-edit') {
                this.taskId = recordId;
                console.log('this.FinalDocId', this.taskId);
                this.showEditFinalDocModal = true;
            }else if(actionPreview === 'fa-search'){
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state: {
                        selectedRecordId: linkedContentId
                    }
                });
            }
        }
    }   

    replyAllEmail(recordId) {
            this.emailMessageId = recordId;
            this.emailAction = 'replyAll';
            this.headerLabel = 'Reply All';
            this.showNewEmailModal = true;
            this.emailComposerKey++;
    }

    replyEmail(recordId) {
        console.log('Called Reply email');
            this.emailMessageId = recordId;
            this.emailAction = 'reply';
            this.headerLabel = 'Reply';
            this.showNewEmailModal = true;
            this.emailComposerKey++;
    }

    forwardEmail(recordId) {
        this.emailMessageId = recordId;
        this.emailAction = 'forward';
        this.headerLabel = 'Forward';
        this.showNewEmailModal = true;
        this.emailComposerKey++;
    }

    initiateNewTask(event){
        this.showNewTaskModal = true;
    }

    handleTaskSaveComplete(event) {
    const taskId = event.detail.taskId;
    this.isEdited = true;
    console.log('[DEBUG] Task save complete with ID:', taskId);

    this.getCollaborationData2(true);
   // this.getTaskCount();
 ///   this.getTaskCountbyDirection(taskId);
    // this.getEmailCount();
   // this.getTotalCollobrationCount();
       

   /*    const mockEvent = {
        currentTarget: {
            dataset: {
                filtertype: "aggregateTasks" 
            },
            classList: {
                add: () => {}, 
                remove: () => {}
            }
        }
    };

    console.log('[DEBUG] Triggering handleFilters from handleTaskSaveComplete');
    this.handleFilters(mockEvent);*/
       
}

    getTaskCountbyDirection(taskId) {
        let incounter = 0;
        let outcounter = 0;
        getTaskDirection({ taskId: taskId })
            .then((result) => {
                const tasks = Object.values(result);
                console.log('tasks:', JSON.stringify(tasks));
                tasks.forEach(item => {
                    if (result.Direction__c === 'In') {
                        incounter++;
                    } else if (result.Direction__c === 'Out') {
                        outcounter++;
                    }
                    this.wiredCollaborationCounts.aggregateEmailReceived += incounter;
                    this.wiredCollaborationCounts.aggregateEmailsOut += outcounter;
                });
            })
            .catch((error) => {
                console.error('Error fetching task direction:', error);
            });
    }


    handleFinalDocSave(){
        console.log('this.tileFilter::',this.tileFilter);
        this.isEdited = true;
       this.getCollaborationData2(true);
         this.showEditFinalDocModal = false;
       // refreshApex(this.collaborationRecords);
        // const selectedTile = this.template.querySelector(`[data-filtertype="${this.tileFilter}"]`);
        // if (selectedTile) {
        //     this.handleFilters({ currentTarget: selectedTile });
        // }
        // const currentTile = this.tileFilter;
        // this.refreshData().then(() => {
        //     this.tileFilter = currentTile; 
        //     const selectedTile = this.template.querySelector(`[data-filtertype="${this.tileFilter}"]`);
        //     if (selectedTile) {
        //         this.handleFilters({ currentTarget: selectedTile });
        //     }
        //     this.render(); 
        // }).catch(error => {
        //     console.error('Error refreshing data:', error);
        // });
        
    }

    // refreshData() {
    //     return new Promise((resolve, reject) => {
    //         this.getCollaborationData2(true);
    //         resolve();
    //     });
    // }
    

   getTaskCount() {
    let incounter = 0;
    let outcounter = 0;
    console.log('this.wiredCollaborationCounts.aggregateEmailReceived in getTaskCount:', this.wiredCollaborationCounts.aggregateEmailReceived);
    console.log('this.wiredCollaborationCounts.aggregateEmailsOut in getTaskCount:', this.wiredCollaborationCounts.aggregateEmailsOut);
    taskCount({ recordId: this.recordId })
        .then((result) => {
            const tasks = Object.values(result);
            this.wiredCollaborationCounts.aggregateTasks = result; 
            console.log('tasks:', JSON.stringify(result));
            console.log('this.wiredCollaborationCounts.aggregateTasks:', JSON.stringify(this.wiredCollaborationCounts.aggregateTasks));
            tasks.forEach(item => {
                if (item.Direction__c === 'In') {
                    incounter++;
                } else {
                    outcounter++;
                }
            });
            // this.wiredCollaborationCounts.aggregateEmailReceived = incounter;
            // this.wiredCollaborationCounts.aggregateEmailsOut = outcounter;
            this.wiredCollaborationCounts.aggregateEmailReceived += incounter;
            this.wiredCollaborationCounts.aggregateEmailsOut += outcounter;
            console.log('this.wiredCollaborationCounts.aggregateEmailReceived in getTaskCount after:', this.wiredCollaborationCounts.aggregateEmailReceived);
            console.log('this.wiredCollaborationCounts.aggregateEmailsOut in getTaskCount after:', this.wiredCollaborationCounts.aggregateEmailsOut);
        })
        .catch((error) => {
            console.error('Error fetching task count:', error);
        });
    }

    getEmailCount() {
    let incounter = 0;
    let outcounter = 0;
        emailCount({ recordId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log('Raw Email Data:', result);

                    const emailMessages = Object.values(result);

                    this.wiredCollaborationCounts.aggregateEmails = emailMessages.length;
                    console.log('aggregateEmails', this.wiredCollaborationCounts.aggregateEmails);

                    emailMessages.forEach(item => {
                if (item.Incoming === true) {
                    incounter++;
                } else {
                    outcounter++;
                }
            });

            // Update the counts for incoming and outgoing emails
            this.wiredCollaborationCounts.aggregateEmailReceived = incounter;
            console.log('this.wiredCollaborationCounts.aggregateEmailReceived:', incounter)
            this.wiredCollaborationCounts.aggregateEmailsOut = outcounter;


                } else {
                    console.log('No email data returned.');
                }
            })
            .catch((error) => {
                console.error('Error fetching email count:', error);
            });
    }



    handleNewTaskClose() {
        this.showNewTaskModal = false;
    }

    async handleEditTaskClose(event) {
        const { status } = event.detail;
        console.log('Event received with action:', status);
        if (status === 'save') {
            this.showEditTaskModal = false;
            // this.hasFetchedCollaborationData = false;
            // this.table.clearData(); // Clear table data to avoid residue
            // this.table.destroy();  // Properly destroy the table instance
            // this.table = null;
            // try {
            //     await this.getCollaborationData(true);
            //     console.log('Data refreshed successfully');
            // } catch (error) {
            //     console.error('Error refreshing data:', error);
            // }
        } else {
            console.log('Closing edit task modal without saving.');
            this.showEditTaskModal = false;
        }
        this.taskId = null;
        console.log('Task modal flow completed');
       
    }
    
    handleCloseModal() {
        this.showEditFinalDocModal = false;
        
    }

    /* @track isSectionACollapsed = true;
    hasFetchedCollaborationData = false;
    handleSectionToggle(event) {
        const sectionName = event.detail.name;
        
        if (sectionName === 'A') {
            this.isSectionACollapsed = !this.isSectionACollapsed;  // Toggle collapse state
            
            // Fetch data only if the section is being expanded and data hasn't been fetched already
            if (!this.hasFetchedCollaborationData && !this.isSectionACollapsed) {
                this.getCollaborationData();
            }
        }
    } */

  

    @track emailComposerKey = 0;
    handleNewEmailClose() {
        this.showNewEmailModal = false;
        this.emailComposerKey++; 
    }

    handleEmailSent(){
       // this.getEmailCount();
        this.getCollaborationData2(true);
       // this.getTotalCollobrationCount();
        this.showNewEmailModal = false;
    }
    showNewFinalDocuments = false
    newOpenFinalDocuments() {
        this.showNewFinalDocuments = true;
        this.emailComposerKey++; 
    }
    handleFinalDocumentClose() {
        this.showNewFinalDocuments = false;
        this.emailComposerKey++; 
    }

    newOpenEmailComposer() {
        this.emailMessageId = null; 
        this.emailAction = 'new';
        this.headerLabel = 'New Email';
        this.showNewEmailModal = true;
        this.emailComposerKey++; 
    }

    handleFlowCloseModal() {
        this.showNewEmailModal = false;
    }

    serializeError(error) {
        try{
            return JSON.stringify({
                name: error.name,
                message: error.message,
                stack: error.stack
            });
        }
        catch(jsErrorInService){
            return JSON.stringify({
                name: jsErrorInService.name,
                message: jsErrorInService.message,
                stack: jsErrorInService.stack
            });
        }
    }

}