import { LightningElement, wire, track, api } from 'lwc';
import * as CONSTANTS from 'c/mvConstants';
import { NavigationMixin } from 'lightning/navigation';
import { createElement } from 'lwc';
import mvDocketFields from 'c/mvObjectFields';
import FA from "@salesforce/resourceUrl/FA";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getAssetIntakeJurisdictions from '@salesforce/apex/assetIntakeUtilities.getAssetIntakeJurisdictions';
import submission from '@salesforce/apex/assetIntakeUtilities.submission';

import lwcMvAssetIntakeJurisdictionRelations from 'c/lwcMvAssetIntakeJurisdictionRelations';

import ASSET_INTAKE_JURISDICTION_RELATION_OBJECT from "@salesforce/schema/Asset_Intake_Jurisdiction_Relations__c";
import ASSET_INTAKE_JURISDICTION_OBJECT from "@salesforce/schema/Asset_Intake_Jurisdiction__c";
//import { WorkspaceApi } from 'lightning/workspaceApi';

import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    deleteRecord,
    updateRecord,
    getPicklistValuesByRecordType,
} from "lightning/uiRecordApi";

import {
    IsConsoleNavigation,
    openTab,
    getFocusedTabInfo,
    openSubtab,
    closeTab
} from 'lightning/platformWorkspaceApi';
const PAGINATOR_DEFAULT_SIZE = 100;
const PAGINATOR_SIZE_SELECTOR = [25, 50, 100, 500];
const PAGINATION = false;

export default class LwcMvIntakeFormJurisdiction extends NavigationMixin(LightningElement) {

    // API Related Parameters 
    @api clientId;
    @api assetIntakeId;
    @api assetType;
    @api clientReferenceNumber;

    @api patentFamilyId;

    @track columns = [];
    @track records = [];//subComponent: null
    @track isRenderedCallBackInitialized = false;
    @track isDataLoaded = false;
    eventName;
    docketType;
    dueDate;
    showKeywords = true;
    newPatentFamilyId;
    fieldValues = {
        Event_Name__c: '',
        Due_Date__c: '',
    };
    objectParentApiName;
    patentRecordId;

    currentFeatureSettings = {
        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR,
        "pagination": PAGINATION
    };

    @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
    
        const tabInfo = await getFocusedTabInfo();
        console.log('tab info--->',tabInfo);
        const tabId = tabInfo ? tabInfo.tabId : null;
        console.log('Jurisdiction tabId-->' + tabId); 
            if (tabId) {
                closeTab(tabId); 
            }
            // WorkspaceApi.openSubtab({
            //     parentTabId: tabInfo.parentTabId
            // }).then(() => {
            //     console.log('Successfully navigated to the subtab!');
            // })
    }

    async connectedCallback(){
       try{
            this.prepareColumns();
            await this.fetchAssetIntakeFormJurisdictions();

            if(this.records.length === 0){
                let defaultData = { "jurisdictionName": "US", "caseType": "Primary", "clientReferenceNumber": this.clientReferenceNumber, isExpanded: false };
                let records = [...this.records];
                records.push(defaultData);
                this.records = records;
            }
            
           this.isDataLoaded = true;
       }catch(err){
           alert('JS Error ::  :: connectedCallback')
           console.error(err)
       }
       if(this.assetType === 'Trademark'){
            this.objectParentApiName = 'SymphonyLF__Mark__c';
        }else{
            this.objectParentApiName = 'SymphonyLF__Patent_Family__c';
        }
       
    }

    async updateJurisdictionRecord(recordId, fieldApiName, value){
       try{
           const fields = {};
           fields['Id'] = recordId;
           fields[fieldApiName] = value;
           
           await updateRecord({"fields": fields});

           console.log('Record updated successfully with ' + recordId + ' ,' + fieldApiName + ' ,' + value);
       }catch(err){
           alert('JS Error ::  :: updateJurisdictionRecord')
           console.error(err)
           this.handleAllErrorTypes( err );
       }
    }

    prepareColumns(){
       try{
        console.log('&&&&&& &&&&&&& assetType ' + this.assetType);
        var objectApiName  = '';
        if(this.assetType === 'Trademark'){
            objectApiName = 'SymphonyLF__Trademark__c';
        }else{
            objectApiName = 'SymphonyLF__Patent__c';
        }

        let columns = [
            {
                title: "", field: "isExpanded", align: "center", frozen: true, width: "25", resizable: false, headerSort: false,
                formatter: function (cell, formatterParams) {
                    try{
                    const rowData = cell.getRow().getData();
                    console.log('Row Data : ' + JSON.stringify(rowData));
    
                    return rowData.isExpanded
                        ? "<i class='fa fa-minus-circle' title='Collapse'></i>"
                        : "<i class='fa fa-plus-circle' title='Expand'></i>";
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: formatter')
                        console.error(err)
                    }
                },
                cellClick: (e, cell) => {
                    try{
                    const rowData = cell.getRow().getData();
                    const isNowExpanded = !rowData.isExpanded;
                    cell.getRow().update({ isExpanded: isNowExpanded });
    
                    const rowElement = cell.getRow().getElement();
                    let container = rowElement.querySelector('.lwcMvDataTable');
                    if (!container) {
                        container = document.createElement('div');
                        container.classList.add('lwcMvDataTable');
                     //   container.style.height = "calc(100vh - 320px)";
                        rowElement.appendChild(container);
                    }
    
                    container.innerHTML = '';
                    console.log('Before Adding the Component');
                    if (isNowExpanded) {
                        const childComponent = createElement('c-lwc-mv-asset-intake-jurisdiction-relations', {
                            is: lwcMvAssetIntakeJurisdictionRelations
                        });
                        childComponent.assetIntakeJurisdictionId = rowData.assetIntakeJurisdictionId;
                        childComponent.clientId = this.clientId;
                        childComponent.assetIntakeFormId = this.assetIntakeId;
                        childComponent.assetType = this.assetType;

                        const jurisdictionRelations = (this.records.filter(record => record.assetIntakeJurisdictionId === rowData.assetIntakeJurisdictionId))[0];
                        console.log('%c rowData.assetIntakeJurisdictionId to subcomponent ' + rowData.assetIntakeJurisdictionId, 'color: grey; font-weight: bold;');
                        console.log('%c jurisdictionRelations to subcomponent ' + JSON.stringify(jurisdictionRelations), 'color: grey; font-weight: bold;');
                        childComponent.jurisdictionRelations = jurisdictionRelations;
    
                        container.appendChild(childComponent);
                        console.log('After Adding the Component');
    
                    }

                    /*
                    if (!isExpanded) {
                        container.style.height = "calc(100vh - 180px)";
                    } else {
                        
                    }
                    */
                }catch(err){
                    alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: cellClick')
                    console.error(err)
                }
                }
    
            },
            {
                title: "Jurisdiction", width: "15%", headerFilter: true, field: "jurisdictionName", formatter: (cell, formatterParams) => {
    
                    var isClosed = cell.getRow().getData().isClosed;
                    var value = cell.getValue();
                    var rowData = cell.getRow().getData();
    
                    var cellEl = cell.getElement(); //get cell DOM element
    
                    try {
                        cellEl.style.overflow = "visible";
                        cellEl.style.zIndex = "1000"; // raise z-index to avoid overlap
                        cellEl.style.position = "relative"; // required for z-index to apply
    
                        const divComponent = document.createElement('div');
                        divComponent.style.overflow = "visible"; // also apply to wrapper
                        divComponent.style.position = "relative";
                        divComponent.style.zIndex = "1000";

    
                        //const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log(childComponent);
                        // Assign properties correctly
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = 'SymphonyLF__Patent__c';
                        childComponent.fieldName = 'SymphonyLF__Country__c';
                        childComponent.updateableFieldName = 'SymphonyLF__Country__c';
                        childComponent.value = cell.getRow().getData().jurisdictionId; 
    
                        childComponent.addEventListener('valuechanged', (e) => {
                                rowData.jurisdictionId = e.detail.value;
                                this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'Jurisdiction__c', e.detail.value);
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: jurisdiction :: formatter')
                        console.error(err)
                    }
                }
            },
            {
                title: "Case Type", width: "15%", headerFilter: true, field: "caseType", formatter: (cell, formatterParams) => {
    
                    var isClosed = cell.getRow().getData().isClosed;
                    var value = cell.getValue();
                    var cellEl = cell.getElement(); //get cell DOM element
                    var rowData = cell.getRow().getData();
                    if(value != null && value != undefined){
                        this.validCaseType = true;
                    }
    
                    try {
                        cellEl.style.overflow = "visible";
                        cellEl.style.zIndex = "1000"; // raise z-index to avoid overlap
                        cellEl.style.position = "relative"; // required for z-index to apply

                        const divComponent = document.createElement('div');
                        divComponent.style.overflow = "visible"; // also apply to wrapper
                        divComponent.style.position = "relative";
                        divComponent.style.zIndex = "1000";
                        //const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log('child component mvDocketField being created, caseType ? ', childComponent);
                        // Assign properties correctly
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = objectApiName;
                        childComponent.fieldName = 'SymphonyLF__Case_Type__c';
                        childComponent.updateableFieldName = 'SymphonyLF__Case_Type__c';
                        childComponent.value = value; 
                        childComponent.addEventListener('valuechanged', (e) => {
                            rowData.caseType = e.detail.value;
                            if(rowData.caseType === null && rowData.caseType === undefined && rowData.caseType === ''){
                                this.showToast('Error','error','Please select a Case Type to proceed further.')
                            }else{
                                this.validCaseType = true;
                                this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'CaseType__c', e.detail.value);
                            }
                            
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: caseType :: formatter')
                        console.error(err)
                    }
                }
            },
            {
                title: "Client Reference Number", width: "10%", headerFilter: true, field: "clientReferenceNumber", formatter: (cell, formatterParams) => {
    
                    var isClosed = cell.getRow().getData().isClosed;
                    var value = cell.getValue();
                    var cellEl = cell.getElement(); //get cell DOM element
                    var rowData = cell.getRow().getData();
    
                    try {
                        const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log(childComponent);
                        // Assign properties correctly
                        var clientref = value || this.clientReferenceNumber;
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = objectApiName;//'SymphonyLF__Patent__c';
                        childComponent.fieldName = 'SymphonyLF__Client_Reference__c';
                        childComponent.updateableFieldName = 'SymphonyLF__Client_Reference__c';
                        childComponent.value = clientref; 

                        childComponent.addEventListener('valuechanged', (e) => {
                            rowData.clientReferenceNumber = e.detail.value;
                            this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'ClientReferenceNumber__c', e.detail.value);
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: referenceNumber :: formatter')
                        console.error(err)
                        this.handleAllErrorTypes(err);
                    }
                }
            },
            {
                title: "Event Name", width: "15%", headerFilter: true, field: "eventName", validator: "required", formatter: (cell, formatterParams) => {
    
                    var isClosed = cell.getRow().getData().isClosed;
                    var value = cell.getValue();
                    if(value != null && value != undefined){
                        this.validEventName = true;
                    }
                    
                    var cellEl = cell.getElement(); //get cell DOM element

                    var rowData = cell.getRow().getData();
    
                    try {
    
                        const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log(childComponent);
                        // Assign properties correctly
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = 'Asset_Intake_Jurisdiction__c';
                        childComponent.fieldName = 'Event_Name__c';
                        childComponent.updateableFieldName = 'Event_Name__c';
                        childComponent.value = value; 
                        
    
                        childComponent.addEventListener('valuechanged', (e) => {
                            rowData.eventName = e.detail.value;
                            console.log('rowData.eventName : '+rowData.eventName);
                            if(rowData.eventName != null && rowData.eventName != undefined ){
                                this.validEventName = true;
                            }
                            if(rowData.eventName === ''){
                                this.validEventName = false;
                            }
                            this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'Event_Name__c', e.detail.value);
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: event :: formatter')
                        console.error(err)
                        this.handleAllErrorTypes(err);
                    }
                }
            },
            {
                title: "Hard/Soft", width: "7%", headerFilter: true, field: "docketType", formatter: (cell, formatterParams) => {
    
                    var isClosed = cell.getRow().getData().isClosed;
                    var value = cell.getValue();
    
                    var cellEl = cell.getElement(); //get cell DOM element
                    var rowData = cell.getRow().getData();
    
                    try {
                        cellEl.style.overflow = "visible";
                        cellEl.style.zIndex = "1000"; // raise z-index to avoid overlap
                        cellEl.style.position = "relative"; // required for z-index to apply

                        const divComponent = document.createElement('div');
                        divComponent.style.overflow = "visible"; // also apply to wrapper
                        divComponent.style.position = "relative";
                        divComponent.style.zIndex = "1000";

    
                        //const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log(childComponent);
                        // Assign properties correctly
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = 'Asset_Intake_Jurisdiction__c';
                        childComponent.fieldName = 'Docket_Type__c';
                        childComponent.updateableFieldName = 'Docket_Type__c';
                        childComponent.value = value; 
    
                        childComponent.addEventListener('valuechanged', (e) => {
                            rowData.docketType = e.detail.value;
                            this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'Docket_Type__c', e.detail.value);
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: hardSoft :: formatter')
                        console.error(err)
                        this.handleAllErrorTypes(err);
                    }
                }
            },
            {
                title: "Assigned To", width: "10%", headerFilter: true, field: "assignedToName", formatter: (cell, formatterParams) => {
    
                    var value = cell.getRow().getData().assignedToId;
    
                    var cellEl = cell.getElement(); //get cell DOM element
                    var rowData = cell.getRow().getData();
    
                    try {
    
                        const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log(childComponent);
                        // Assign properties correctly
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = 'Asset_Intake_Jurisdiction__c';
                        childComponent.fieldName = 'Assigned_To__c';
                        childComponent.updateableFieldName = 'Assigned_To__c';
                        childComponent.value = value; 
    
                        childComponent.addEventListener('valuechanged', (e) => {
                            rowData.assignedToId = e.detail.value;
                            this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'Assigned_To__c', e.detail.value);
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: assignedTo :: formatter')
                        console.error(err)
                        this.handleAllErrorTypes(err);
                    }
                }
            },
            {
                title: "Event Date", width: "10%", headerFilter: true, field: "eventDate", formatter: (cell, formatterParams) => {
    
                    var value = cell.getValue();
    
                    var cellEl = cell.getElement(); //get cell DOM element

                    var rowData = cell.getRow().getData();
    
                    try {
    
                        const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log(childComponent);
                        // Assign properties correctly
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = 'Asset_Intake_Jurisdiction__c';
                        childComponent.fieldName = 'Event_Date__c';
                        childComponent.updateableFieldName = 'Event_Date__c';
                        childComponent.value = value; 
    
                        childComponent.addEventListener('valuechanged', (e) => {
                            rowData.dueDate = e.detail.value;
                            this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'Event_Date__c', e.detail.value);
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: eventData :: formatter')
                        console.error(err)
                        this.handleAllErrorTypes(err);
                    }
                }
            },
            {
                title: "Due Date", width: "10%", headerFilter: true, field: "dueDate",validator: "required", formatter: (cell, formatterParams) => {
    
                    var value = cell.getValue();
                    if(value != null && value != undefined){
                        this.validDueDate = true;
                    }
    
                    var cellEl = cell.getElement(); //get cell DOM element

                    var rowData = cell.getRow().getData();
    
                    try {
    
                        const divComponent = document.createElement('div');
    
                        const childComponent = createElement('c-mv-object-fields', {
                            is: mvDocketFields
                        });
                        console.log(childComponent);
                        // Assign properties correctly
                        childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                        childComponent.objectName = 'Asset_Intake_Jurisdiction__c';
                        childComponent.fieldName = 'Due_Date__c';
                        childComponent.updateableFieldName = 'Due_Date__c';
                        if(new Date(rowData.dueDate) >= new Date(rowData.eventDate)){
                            childComponent.value = value;
                        }else{
                            childComponent.value = null;
                        }
    
                        childComponent.addEventListener('valuechanged', (e) => {
                            rowData.dueDate = e.detail.value;
                            if(rowData.dueDate != null && rowData.dueDate != undefined){
                                this.validDueDate = true;
                            }
                            if(new Date(rowData.dueDate) < new Date(rowData.eventDate)){
                                this.showToast('Error', 'error', 'Due Date must be in the future');
                                this.validDueDate = false;
                                childComponent.value = null;
                            }else{
                                this.updateJurisdictionRecord(rowData.assetIntakeJurisdictionId, 'Due_Date__c', e.detail.value);
                            }
                        });
                        divComponent.appendChild(childComponent);
                        return divComponent;
    
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: dueData :: formatter')
                        console.error(err)
                        this.handleAllErrorTypes(err);
                    }
                }
            },
            {
                title: "", field: "", resizable: false, style: "width:3%!important;", formatter: "buttonCross", formatter: function (cell, formatterParams) {
                    try{
                    return "<span style='font-weight:bold;'><i class='fa fa-clone'></i></span>";
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: clone :: formatter')
                        console.error(err)
                    }
                }
                ,cellClick: (e, cell) => this.handleActionClickClone(e, cell),
            },
            {
                title: "", field: "", resizable: false, style: "width:3%!important;", formatter: "buttonCross", formatter: function (cell, formatterParams) {
                    try{
                    return "<span style='font-weight:bold;'><i class='fa fa-trash'></i></span>";
                    }catch(err){
                        alert('JS Error :: lwcMvIntakeFormJurisdiction :: prepareColumns :: delete :: formatter')
                        console.error(err)
                    }
                }
                ,cellClick: (e, cell) => this.handleActionClickDelete(e, cell),
            }
        ];

        this.columns = columns;
       }catch(err){
           alert('JS Error ::  :: prepareColumns')
           console.error(err)
       }
    }

    handleAllErrorTypes(err){
       try{
           console.error(err);
           console.error( JSON.stringify(err) );
           console.error( this.serializeError(err) );
       }catch(err){
           alert('JS Error ::  :: handleAllErrorTypes')
           console.error(err)
       }
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

    handleActionClickDelete(event, cell){
       try{
        event.stopPropagation();

        if(this.records.length <= 1){
            this.showToast('Error', 'error', 'There should be atleast one Jurisdiction record');
            return;
        }
        let rowData = cell.getRow().getData();

        const jurisdictionLeft = (this.records.filter(record => record.assetIntakeJurisdictionId != rowData.assetIntakeJurisdictionId));

        deleteRecord(rowData.assetIntakeJurisdictionId);

        this.records = jurisdictionLeft;

        this.template.querySelector('.lwcMvDataTable').updateTableData(this.records);

       }catch(err){
           alert('JS Error ::  :: handleActionClickDelete')
           console.error(err)
       }
    }

    async handleActionClickClone(event, cell) {
        event.stopPropagation();
        const promises = [];
        const clonedOldIdToRelatedList = [];

      
        const rowData = cell.getRow().getData();
      
        const idx = this.records.findIndex(r => r.assetIntakeJurisdictionId === rowData.assetIntakeJurisdictionId);
        if (idx !== -1) {
          this.records = [
            ...this.records.slice(0, idx),
            { ...this.records[idx], ...rowData },
            ...this.records.slice(idx + 1),
          ];
        }
        //const clonedData = JSON.parse(JSON.stringify(jurisdictionRelations));

      
        const fields = {
          Asset_Intake_Form__c:     rowData.assetIntakeId,
          CaseType__c:              rowData.caseType,
          ClientReferenceNumber__c: rowData.clientReferenceNumber,
          Jurisdiction__c:          rowData.jurisdictionId,
          Docket_Type__c:           rowData.docketType,
          Event_Name__c:            rowData.eventName,
          Event_Date__c:            rowData.eventDate,
          Due_Date__c:              rowData.dueDate,
          Assigned_To__c:           rowData.assignedToId,
        };
        if(rowData.caseType === null || rowData.caseType === undefined || rowData.caseType === '--None--'|| rowData.clientReferenceNumber === undefined || rowData.clientReferenceNumber === null || rowData.clientReferenceNumber === ''||
             rowData.jurisdictionId === null || rowData.jurisdictionId === undefined || rowData.jurisdictionId === '' || rowData.eventName === null || rowData.eventName === '' || rowData.eventName === undefined ||
             rowData.dueDate === null || rowData.dueDate === undefined || rowData.dueDate === ''
        ){
            this.validCaseType = false;
            this.validDueDate = false;
            this.validEventName = false;
        }
        try {
          const { id: newId } = await createRecord({
            apiName: ASSET_INTAKE_JURISDICTION_OBJECT.objectApiName,
            fields
          });

          const cloned = {
            ...rowData,
            assetIntakeJurisdictionId: newId,
            isExpanded: false
          };

          cloned.clientEngagementModels.forEach( recordInput => {
            const jurisdictionRelationRecordfields = {};
            jurisdictionRelationRecordfields['Asset_Intake_Jurisdiction__c'] = newId;
            jurisdictionRelationRecordfields['InstanceType__c'] = 'Asset_Intake_Personnel__c';
            jurisdictionRelationRecordfields['Asset_Intake_Personnel__c'] = recordInput.assetIntakePersonnelRecordId;

            const recordInputJurisdictionRelation = {
                "apiName": ASSET_INTAKE_JURISDICTION_RELATION_OBJECT.objectApiName,
                "fields": jurisdictionRelationRecordfields,
            };

            if(recordInput.assetIntakeJurisdictionRelationRecordId ){ // && recordInput.isChecked
                const jurisdictionRelationRecord = createRecord(recordInputJurisdictionRelation);
                promises.push(jurisdictionRelationRecord);
                clonedOldIdToRelatedList.push({"oldRelationId": recordInput.assetIntakeJurisdictionRelationRecordId, "oldRelation" : recordInput});
            }
        });
        cloned.applicants.forEach( recordInput => {
            const jurisdictionRelationRecordfields = {};
            jurisdictionRelationRecordfields['Asset_Intake_Jurisdiction__c'] = newId;
            jurisdictionRelationRecordfields['InstanceType__c'] = 'Asset_Intake_Applicants__c';
            jurisdictionRelationRecordfields['Asset_Intake_Applicant__c'] = recordInput.recordId;

            const recordInputJurisdictionRelation = {
                "apiName": ASSET_INTAKE_JURISDICTION_RELATION_OBJECT.objectApiName,
                "fields": jurisdictionRelationRecordfields,
            };

            if(recordInput.assetIntakeJurisdictionRelationRecordId ){ // && recordInput.isChecked
                const jurisdictionRelationRecord =  createRecord(recordInputJurisdictionRelation);
                promises.push(jurisdictionRelationRecord);
                clonedOldIdToRelatedList.push({"oldRelationId": recordInput.assetIntakeJurisdictionRelationRecordId, "oldRelation" : recordInput});
            }
        });

        cloned.inventors.forEach(recordInput => {
            const jurisdictionRelationRecordfields = {};
            jurisdictionRelationRecordfields['Asset_Intake_Jurisdiction__c'] = newId;
            jurisdictionRelationRecordfields['InstanceType__c'] = 'Asset_Intake_Inventor__c';
            jurisdictionRelationRecordfields['Asset_Intake_Inventor__c'] = recordInput.recordId;

            const recordInputJurisdictionRelation = {
                "apiName": ASSET_INTAKE_JURISDICTION_RELATION_OBJECT.objectApiName,
                "fields": jurisdictionRelationRecordfields,
            };

            if(recordInput.assetIntakeJurisdictionRelationRecordId ){ // && recordInput.isChecked
                const jurisdictionRelationRecord = createRecord(recordInputJurisdictionRelation);
                promises.push(jurisdictionRelationRecord);
                clonedOldIdToRelatedList.push({"oldRelationId": recordInput.assetIntakeJurisdictionRelationRecordId , "oldRelation" : recordInput});
            }
        });
        Promise.all(promises)
            .then( results => {
                console.log('Success Cloned jurisdiction relations');
                console.log('clonedOldIdToRelatedList', JSON.stringify(clonedOldIdToRelatedList));

                cloned.assetIntakeJurisdictionId = newId;

                results.forEach( (each, index) => {
                    
                    let clonedOldIdToRelated = clonedOldIdToRelatedList[index];
                    const clonedRelated = clonedOldIdToRelated.oldRelation;

                    console.log('key', clonedOldIdToRelated.oldRelationId);
                    console.log('clonedOldIdToRelatedList', clonedRelated);

                    const clonedId = each.id;
                    console.log('clonedId', clonedId);

                    clonedRelated.assetIntakeJurisdictionRelationRecordId = clonedId;
                });
            });
          cloned.isExpanded = false;
          this.records = [...this.records, cloned];
          console.log('this.records : cloned  :::: ',JSON.stringify(this.records));
          this.template.querySelector('.lwcMvDataTable').updateTableData(this.records);
        }
        catch (err) {
          this.showToast('Error','error','Clone failed: '+ (err.body?.message||err.message));
          console.error(err);
        }
      }
      
    /* async handleActionClickClone(event, cell){
       try{
            event.stopPropagation();
            let rowData = cell.getRow().getData();

            let cloneDataArray = [];

            
            const jurisdictionRelationsList = (this.records.filter(record => record.assetIntakeJurisdictionId === rowData.assetIntakeJurisdictionId));
            const jurisdictionRelations = jurisdictionRelationsList[0];
            console.log('jurisdictionRelations ---- ',JSON.stringify(jurisdictionRelations));
            const clonedData = JSON.parse(JSON.stringify(jurisdictionRelations));
            

            const jurisdictionRecordfields = {};
            console.log('clonedData.assetIntakeId', clonedData.assetIntakeId);
            jurisdictionRecordfields['Asset_Intake_Form__c'] = clonedData.assetIntakeId;
            jurisdictionRecordfields['CaseType__c'] = clonedData.caseType;
            jurisdictionRecordfields['ClientReferenceNumber__c'] = clonedData.clientReferenceNumber;
            jurisdictionRecordfields['Jurisdiction__c'] = clonedData.jurisdictionId;
            jurisdictionRecordfields['Docket_Type__c'] = clonedData.docketType;
            jurisdictionRecordfields['Event_Name__c'] = clonedData.eventName;
            jurisdictionRecordfields['Event_Date__c'] = clonedData.eventDate;
            jurisdictionRecordfields['Due_Date__c'] = clonedData.dueDate;
            jurisdictionRecordfields['Assigned_To__c'] = clonedData.assignedToId;

            const recordInputJurisdiction = {
                "apiName": ASSET_INTAKE_JURISDICTION_OBJECT.objectApiName,
                "fields": jurisdictionRecordfields,
            };

            console.log('recordInputJurisdiction', JSON.stringify(recordInputJurisdiction));

            const jurisdictionRecord = createRecord(recordInputJurisdiction);
            const jurisdictionRecordId = (await jurisdictionRecord).id;

            console.log("Successfully cloned created record Jurisdiction Record ID: " + jurisdictionRecordId);

            const promises = [];
            const clonedOldIdToRelatedList = [];

            clonedData.clientEngagementModels.forEach( recordInput => {
                const jurisdictionRelationRecordfields = {};
                jurisdictionRelationRecordfields['Asset_Intake_Jurisdiction__c'] = jurisdictionRecordId;
                jurisdictionRelationRecordfields['InstanceType__c'] = 'Asset_Intake_Personnel__c';
                jurisdictionRelationRecordfields['Asset_Intake_Personnel__c'] = recordInput.assetIntakePersonnelRecordId;

                const recordInputJurisdictionRelation = {
                    "apiName": ASSET_INTAKE_JURISDICTION_RELATION_OBJECT.objectApiName,
                    "fields": jurisdictionRelationRecordfields,
                };

                if(recordInput.assetIntakeJurisdictionRelationRecordId ){ // && recordInput.isChecked
                    const jurisdictionRelationRecord = createRecord(recordInputJurisdictionRelation);
                    promises.push(jurisdictionRelationRecord);
                    clonedOldIdToRelatedList.push({"oldRelationId": recordInput.assetIntakeJurisdictionRelationRecordId, "oldRelation" : recordInput});
                }
            });

            clonedData.applicants.forEach( recordInput => {
                const jurisdictionRelationRecordfields = {};
                jurisdictionRelationRecordfields['Asset_Intake_Jurisdiction__c'] = jurisdictionRecordId;
                jurisdictionRelationRecordfields['InstanceType__c'] = 'Asset_Intake_Applicants__c';
                jurisdictionRelationRecordfields['Asset_Intake_Applicant__c'] = recordInput.recordId;

                const recordInputJurisdictionRelation = {
                    "apiName": ASSET_INTAKE_JURISDICTION_RELATION_OBJECT.objectApiName,
                    "fields": jurisdictionRelationRecordfields,
                };

                if(recordInput.assetIntakeJurisdictionRelationRecordId ){ // && recordInput.isChecked
                    const jurisdictionRelationRecord =  createRecord(recordInputJurisdictionRelation);
                    promises.push(jurisdictionRelationRecord);
                    clonedOldIdToRelatedList.push({"oldRelationId": recordInput.assetIntakeJurisdictionRelationRecordId, "oldRelation" : recordInput});
                }
            });

            clonedData.inventors.forEach(recordInput => {
                const jurisdictionRelationRecordfields = {};
                jurisdictionRelationRecordfields['Asset_Intake_Jurisdiction__c'] = jurisdictionRecordId;
                jurisdictionRelationRecordfields['InstanceType__c'] = 'Asset_Intake_Inventor__c';
                jurisdictionRelationRecordfields['Asset_Intake_Inventor__c'] = recordInput.recordId;

                const recordInputJurisdictionRelation = {
                    "apiName": ASSET_INTAKE_JURISDICTION_RELATION_OBJECT.objectApiName,
                    "fields": jurisdictionRelationRecordfields,
                };

                if(recordInput.assetIntakeJurisdictionRelationRecordId ){ // && recordInput.isChecked
                    const jurisdictionRelationRecord = createRecord(recordInputJurisdictionRelation);
                    promises.push(jurisdictionRelationRecord);
                    clonedOldIdToRelatedList.push({"oldRelationId": recordInput.assetIntakeJurisdictionRelationRecordId , "oldRelation" : recordInput});
                }
            });

            Promise.all(promises)
            .then( results => {
                console.log('Success Cloned jurisdiction relations');
                console.log('clonedOldIdToRelatedList', JSON.stringify(clonedOldIdToRelatedList));

                clonedData.assetIntakeJurisdictionId = jurisdictionRecordId;

                results.forEach( (each, index) => {
                    
                    let clonedOldIdToRelated = clonedOldIdToRelatedList[index];
                    const clonedRelated = clonedOldIdToRelated.oldRelation;

                    console.log('key', clonedOldIdToRelated.oldRelationId);
                    console.log('clonedOldIdToRelatedList', clonedRelated);

                    const clonedId = each.id;
                    console.log('clonedId', clonedId);

                    clonedRelated.assetIntakeJurisdictionRelationRecordId = clonedId;
                });
                    


                // this.records.push(clonedData);
                clonedData.isExpanded = false;
                this.records.forEach(record => {
                if (record.assetIntakeJurisdictionId === rowData.assetIntakeJurisdictionId) {
                    record.isExpanded = false;
                }
                });
                cloneDataArray = JSON.parse(JSON.stringify(clonedData));
                this.records = JSON.parse(JSON.stringify([...this.records, cloneDataArray]));
                
                this.template.querySelector('.lwcMvDataTable').updateTableData(this.records);
            })
            .catch(error => {
                alert('Failed Cloned jurisdiction relations');
                console.log('Failed Cloned jurisdiction relations');
                this.handleAllErrorTypes(error);
            })
            .finally(() => {
                
            });
       }catch(err){
           alert('JS Error ::  :: handleActionClickClone')
           console.error(err)
           console.error(JSON.stringify(err));
           console.error(this.serializeError(err));
       }
    } */

    async handlecheckboxclickjurisdictionrelation(event){
       try{
            event.stopPropagation();
            const detail = event.detail;

            let assetIntakeJurisdictionId = detail.assetIntakeJurisdictionId;
            let assetIntakeJurisdictionRelationRecordId = detail.assetIntakeJurisdictionRelationRecordId;
            let checked = detail.checked;
            let instanceType = detail.instanceType;
            let relatedToId = detail.relatedToId

            console.log('%c checked from event ' + checked, 'color: red; font-weight: bold;');
            console.log('%c instanceType from event ' + instanceType, 'color: red; font-weight: bold;');
            console.log('%c assetIntakeJurisdictionId from event ' + assetIntakeJurisdictionId, 'color: red; font-weight: bold;');
            console.log('%c assetIntakeJurisdictionRelationRecordId from event ' + assetIntakeJurisdictionRelationRecordId, 'color: red; font-weight: bold;');
            console.log('%c relatedToId from event ' + relatedToId, 'color: red; font-weight: bold;');
            
            console.log('xxxx records ', JSON.stringify( this.records ));

            const jurisdictionRelationsList = (this.records.filter(record => record.assetIntakeJurisdictionId === assetIntakeJurisdictionId));
            console.log('jurisdictionRelationsList ', jurisdictionRelationsList.length);
            const jurisdictionRelations = jurisdictionRelationsList[0];

            let toSearch;
            let fieldToMatch;

            console.log('xxxx jurisdictionRelations ', JSON.stringify(jurisdictionRelations) );

            if(instanceType === 'Asset_Intake_Inventor__c'){
                toSearch = jurisdictionRelations.inventors;
                fieldToMatch = "recordId";
            }
            else if(instanceType === 'Asset_Intake_Applicants__c'){
                toSearch = jurisdictionRelations.applicants;
                fieldToMatch = "recordId";
            }
            else if(instanceType === 'Asset_Intake_Class__c'){
                toSearch = jurisdictionRelations.classes;
                fieldToMatch = "recordId";
            }
            else if(instanceType === 'Asset_Intake_Personnel__c'){
                toSearch = jurisdictionRelations.clientEngagementModels;
                fieldToMatch = "assetIntakePersonnelRecordId";
            }

            console.log('xxxx fieldToMatch ', fieldToMatch);
            console.log('xxxx fieldToMatch ', JSON.stringify(toSearch) );

            let jurisdictionRelation = toSearch.find(item => item[fieldToMatch] === relatedToId);

            console.log('XXXX jurisdictionRelation ', JSON.stringify(jurisdictionRelation) );

            const fields = {};
            fields['Asset_Intake_Jurisdiction__c'] = assetIntakeJurisdictionId;

            if(toSearch && Array.isArray(toSearch)){
                
                fields['InstanceType__c'] = instanceType;
                if(instanceType === 'Asset_Intake_Inventor__c'){
                    fields['Asset_Intake_Inventor__c'] = jurisdictionRelation.recordId;
                }
                else if(instanceType === 'Asset_Intake_Applicants__c'){
                    fields['Asset_Intake_Applicant__c'] = jurisdictionRelation.recordId;
                }
                else if(instanceType === 'Asset_Intake_Personnel__c'){
                    fields['Asset_Intake_Personnel__c'] = jurisdictionRelation.assetIntakePersonnelRecordId;
                }
                
                if(jurisdictionRelation){
                    if(checked){          
                        const recordInput = {
                            apiName: ASSET_INTAKE_JURISDICTION_RELATION_OBJECT.objectApiName,
                            fields,
                        };

                        const jurisdictionRelationRecord = createRecord(recordInput);
                        const jurisdictionRelationRecordId = (await jurisdictionRelationRecord).id;

                        console.log("Successfully created record Jurisdiction Relation Record ID: " + jurisdictionRelationRecordId);
                        jurisdictionRelation.assetIntakeJurisdictionRelationRecordId = jurisdictionRelationRecordId;
                        jurisdictionRelation.isSelected = true;
                    }else{
                        console.log('jurisdictionRelation.assetIntakeJurisdictionRelationRecordId', jurisdictionRelation.assetIntakeJurisdictionRelationRecordId);
                        deleteRecord(jurisdictionRelation.assetIntakeJurisdictionRelationRecordId);
                        console.log("Successfully deleted record Jurisdiction Relation Record ID: " + jurisdictionRelation.assetIntakeJurisdictionRelationRecordId);
                        jurisdictionRelation.assetIntakeJurisdictionRelationRecordId = null;
                        jurisdictionRelation.isSelected = false;
                    }
                }
            }
       }catch(err){
           alert('JS Error ::  :: handlecheckboxclickjurisdictionrelation')
           this.handleAllErrorTypes(err);
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

    fetchAssetIntakeFormJurisdictions(){
       try{
        console.log('BBBB  assetIntakeId ', this.assetIntakeId);
           const promise = getAssetIntakeJurisdictions({
            "clientId": this.clientId,
            "assetIntakeId": this.assetIntakeId
           });

           promise.then( response => {
               try{
                console.log('Records in jurisduction ', JSON.stringify(response) );
                response.forEach(eachJurisdiction => {
                    eachJurisdiction.clientEngagementModels?.forEach(e => {
                        if(e.assetIntakeJurisdictionRelationRecordId){
                            e["isSelected"] = true;
                        }
                        else{
                            e["isSelected"] = false;
                        }
                   });

                   eachJurisdiction.applicants?.forEach(e => {
                            if(e.assetIntakeJurisdictionRelationRecordId){
                                e["isSelected"] = true;
                                console.log('Applicants isSelected ' + true, 'color: yellow; font-weight: bold;');
                            }
                            else{
                                e["isSelected"] = false;
                                console.log('Applicants isSelected ' + false, 'color: yellow; font-weight: bold;');
                            }
                    });

                    eachJurisdiction.inventors?.forEach(e => {
                        if(e.assetIntakeJurisdictionRelationRecordId){
                            e["isSelected"] = true;
                        }
                        else{
                            e["isSelected"] = false;
                        }
                    });

                    eachJurisdiction.classes?.forEach(e => {
                        if(e.assetIntakeJurisdictionRelationRecordId){
                            e["isSelected"] = true;
                        }
                        else{
                            e["isSelected"] = false;
                        }
                    });
                });
                    console.log('%c first response modified jurisdiction ' + JSON.stringify(response), 'color: black; font-weight: bold;');
                   this.records = response;
               }catch(err){
                   alert('JS Error in Server callback :: LwcMvIntakeFormJurisdiction :: fetchAssetIntakeFormJurisdictions');
               }
           });
           
           promise.catch( error => {
               alert('Server Error :: LwcMvIntakeFormJurisdiction :: fetchAssetIntakeFormJurisdictions :: apexMethod => getAssetIntakeJurisdictions');
               console.error(JSON.stringify(error));
           });

           return promise;
       }catch(err){
           alert('JS Error :: LwcMvIntakeFormJurisdiction :: fetchAssetIntakeFormJurisdictions')
           console.error(err)
       }
    }

    renderedCallback() {
        try {
            if (this.isRenderedCallBackInitialized) return;
            this.isRenderedCallBackInitialized = true;

            Promise.all([
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
                .then(() => {
                    console.log('Loaded FA Styles');
                });
        
        } catch (err) {
            alert('JS Error :: LwcMvIntakeFormJurisdiction :: renderedCallback')
            console.error(err)
        }
    }

    handleValueChanged(event){
        console.log('in handleValueChanged');
        console.log('received event:', JSON.stringify(event.detail));
        const fieldName = event.detail.field;
        const fieldValue = event.detail.value;

        if (this.fieldValues.hasOwnProperty(fieldName)) {
            this.fieldValues[fieldName] = fieldValue;
        }
        // console.log('fieldvalues-->'+this.fieldValues);
        // if(!this.fieldValues.isEmpty()){
        //     this.validDueDate = true;
        //     this.validEventName = true;
        // }
    }

    loading = false;
    familyLabel;
    assetLabel;
    validEventName = false;
    validDueDate = false;
    validCaseType = false;
    
    handleSubmit(){
       try{
        //     let isValid = true;
        //     let errorMessage = '';

        // Object.keys(this.fieldValues).forEach(field => {
        //     if (!this.fieldValues[field]) {
        //         isValid = false;
        //         errorMessage += `${field} is required. `;
        //     }
        // });

        // if (!isValid) {
        //     this.showToast('Error', 'error', errorMessage);
        // } 
        // else{
       
            if(!this.validEventName || !this.validDueDate || !this.validCaseType ){
                let errorMessage = 'Please fill all the missing fields';
                this.showToast('Error','error',errorMessage);

            }else{
        this.loading = true;
            submission({"intakeId": this.assetIntakeId,"clientId": this.clientId})
        .then(( response )=>{
                console.log('response :'+JSON.stringify(response));

                this.patentFamilyRecords = response.filter(record => record.familyStatus); 
                console.log('this.patentFamilyRecords : ',JSON.stringify(this.patentFamilyRecords));
                this.newPatentFamilyId = this.patentFamilyRecords[0].recordId;
                this.familyLabel = this.patentFamilyRecords[0].label;
                this.patentIdRecords = response.filter(record => record.caseType); 
                console.log('this.patentIdRecords : ',JSON.stringify(this.patentIdRecords));
                this.assetLabel = this.patentIdRecords[0].label;
                this.patentRecordId = 

           // location.reload();
           this.generatedMatterRecords = response;
           console.log('generated matters -->'+JSON.stringify(this.generatedMatterRecords));
           this.showGeneratedMatters = true;
        })
        .catch((err)=>{
                alert('Server Error :: LwcMvIntakeFormJurisdiction :: handleSubmit :: apexMethod => submission'+err+' '+JSON.stringify(err));
            this.handleAllErrorTypes(err);
        })
        .finally(()=>{
            this.loading = false;
        })
        }
       }catch(err){
           alert('JS Error ::  :: handleSubmit')
           console.error(err)
       }
    }

    handleBack(){
       try{

        const fields = {};
        fields['Id'] = this.assetIntakeId;
        fields['Current_Page__c'] = this.assetType ==='Patent'?'Innovators':'Classes and Goods';

        console.log('1');
        const recordInput = { fields };
        console.log('2');


        updateRecord(recordInput)
            .then(() => {
                console.log('Successfully updated the page to Inventors');
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
                console.log('Failed to update the page to Inventors');
            });

            console.log('3');
         this.dispatchEvent(new CustomEvent('back', {
                detail: {
                    assetIntakeId: this.assetIntakeId
                }, bubbles: true, composed: true
            })); 
       }catch(err){
           alert('JS Error ::  :: handleBack')
           console.error(err)
       }
    }

      handleReset() {
        this.closeTab();
        this.navigateToCCdashboard();
    }

    async handleClose(){
       this.showGeneratedMatters = false;
       this.closeTab();
       this.navigateToCCdashboard();
    }

   

    // handleSubmit(){
    //     this.showGeneratedMatters = true;
    // }
    // navigateToCCdashboard() {
    //     this[NavigationMixin.Navigate]({
    //     type: 'standard__navItemPage',
    //     attributes: {
    //         apiName: 'Conflict_Check_Dashboard'
    //     }
    // });
    //window.location.href = '/lightning/n/Conflict_Check_Dashboard';
   // }
   navigateToCCdashboard() {
    this[NavigationMixin.Navigate]({
        type: 'standard__navItemPage',
        attributes: {
            apiName: 'Conflict_Check_Dashboard'
        },
        state: {
            refresh: true  // Set this to true to refresh the page when navigating to the same page
        }
    });
}

    showGeneratedMatters = false;

    generatedMatterRecords = [];

    generatedMatterColumns = [
        // {
        //     title: "Docket No.",
        //     field: "docketNumber",
        //     headerFilter: false,
        //     type: "recordlink",
        //     formatterParams: {
        //         recordIdField: "recordId",
        //         classList: [],
        //         styleList: [
        //             {
        //                 property: "font-weight",
        //                 value: "bold",
        //             },
        //         ],
        //     },
        // },
        {
            title: "Title",
            field: "title",
            headerFilter: false,
            type: "recordlink",
            formatterParams: {
                recordIdField: "recordId",
                classList: [],
                styleList: [
                    {
                        property: "font-weight",
                        value: "bold",
                    },
                ],
            },
            // formatterParams: {
            //     classList: [],
            //     styleList: [
            //         {
            //             property: "font-weight",
            //             value: "bold",
            //         },
            //     ],
            // },
        },
        {
            title: "Case Type",
            field: "caseType",
            formatterParams: {
                classList: [],
                styleList: [
                    {
                        property: "font-weight",
                        value: "bold",
                    },
                ],
            },
        },
        {
            title: "Jurisdiction",
            field: "jurisdiction",
            formatterParams: {
                classList: [],
                styleList: [
                    {
                        property: "font-weight",
                        value: "bold",
                    },
                ],
            },
        }
    ];

    // handleClose(){
    //     try{
    //         this.showGeneratedMatters = false;
    //     }catch(err){
    //         alert('JS Error :: lwcMvIntakeFormJurisdiction :: handleClose')
    //         console.error(err)
    //     }
    //  }
}