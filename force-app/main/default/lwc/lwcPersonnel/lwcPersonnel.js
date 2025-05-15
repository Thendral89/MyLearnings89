import { LightningElement, wire, api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import FA from "@salesforce/resourceUrl/FA";
import { RefreshEvent, registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';
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
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMatterEngagementModels from '@salesforce/apex/mvLawfirmUtilities.getMatterEngagementModels';
import getObjectPermission from '@salesforce/apex/mvLawfirmUtilities.getObjectPermission';
import getClientEngagementModelsToAddForMem from '@salesforce/apex/mvLawfirmUtilities.getClientEngagementModelsToAddForMem';
import addCemsToMems from '@salesforce/apex/mvLawfirmUtilities.addCemsToMems';

import getUserTimezoneOffset from '@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset';
import getUserLocale from '@salesforce/apex/mvLawfirmUtilities.getUserLocale';
/* Check for User Permissions */
import hasAddPermission from '@salesforce/customPermission/CEM_Add';
import hasEditPermission from '@salesforce/customPermission/CEM_Edit';
import hasDeletePermission from '@salesforce/customPermission/CEM_Delete';
import hasViewPermission from '@salesforce/customPermission/CEM_View';

const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100, 500];

const TABULATOR_BUTTON_ID_PREFIX = 'myButtonMatterEngagementModel';

const PERSON_RECORD_TYPE_INTERNAL = 'Internal';
const PERSON_RECORD_TYPE_EXTERNAL = 'External';
export default class LwcPersonnel extends NavigationMixin(LightningElement)  {
    @api recordId;
    @api objectApiName;

    instanceId = "cmp-" + Math.random().toString(36).substring(2, 9);

    refreshHandlerID;
    isLoadingFirstTime = true;

    currentFeatureSettings = {
        
        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR
    };

    get hasAddAccess() {
        return hasAddPermission;
    }

    get hasViewAccess() {
        return hasViewPermission;
    }

    get
    matterEngagementModelLookup(){
       try{
           let lookup = {
            "SymphonyLF__Patent__c": "SymphonyLF__Patent__c"
            , "SymphonyLF__Agreement_Contract__c": "SymphonyLF__Agreements_Contracts__c"
            , "SymphonyLF__Copyright__c": "SymphonyLF__Copyright__c"
            , "SymphonyLF__Design_Family__c": "SymphonyLF__Design_Family__c"
            , "SymphonyLF__Design__c": "SymphonyLF__Design__c"
            , "SymphonyLF__Dispute_Opposition__c": "SymphonyLF__Dispute_Opposition__c"
            , "SymphonyLF__General_Matter__c": "SymphonyLF__General_Matter__c"
            , "SymphonyLF__Mark__c": "SymphonyLF__Mark__c"
            , "SymphonyLF__Patent_Family__c": "SymphonyLF__Patent_Family__c"
            , "SymphonyLF__Trademark__c": "SymphonyLF__Trademark__c"
           }

           return lookup[this.objectApiName];
       }catch(err){
           alert('JS Error ::  :: matterEngagementModelLookup')
           console.error(err)
       }
    }

    timezone;
    @wire(getUserTimezoneOffset)
    wiredTimezone({ error, data }) {
        if (data) {
            console.log('Time zone received BB', data);
            this.timezone = data; // Example: "America/New_York"
        }
    }

    userlocale;
    @wire(getUserLocale)
    wiredUserLocale({ error, data }) {
        if (data) {
            console.log('User Locale received BB', data);
            this.userlocale = data.replace('_','-');
        }
    }

    @wire(IsConsoleNavigation) isConsoleNavigation;
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
    
                // Open sub tab
                await openSubtab(this.enclosingTabId, {
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
                alert('JS Error : ccDashboard : findEnclosingTabAndOpenSubtab');
            }
            
        }

    showDeleteConfirmation = false;
    columns = [];

    handleActionClick(e, cell) {
        try {
            let target = e.target;
            let rowData = cell.getRow().getData();

            const recordId = rowData.recordId;
            this.clientEngagementModelId = recordId;

            if (target.classList.contains("edit-icon")) {
                this.addOrEditMessage = 'Edit';
                this.showEdit = true;
            } else if (target.classList.contains("delete-icon")) {
                this.showDeleteConfirmation = true;
            }

            /*
                
                */
        } catch (err) {
            alert('JS Error ::  :: handleActionClick')
            console.error(this.serializeError(err));
        }
    }

    handleDeleteConfirmation(){
       try{
        deleteRecord(this.clientEngagementModelId)
            .then(() => {
                this.showToast('Success', 'success', 'Record deleted successfully');
            })
            .catch(error => {
                this.showToast('Error', 'error', 'Error deleting record: ' + error.body.message);
            })
            .finally(() => {
                this.fetchMatterEngagementModels();
                this.refreshOtherElementsOnThePage();
            });

        let filterdRemainingData = this.records.filter(each => {
            if (each.recordId != this.clientEngagementModelId) {
                return true;
            }
            return false;
        });
        this.updateTableData(filterdRemainingData);
        this.clientEngagementModelId = null;
        this.showDeleteConfirmation = false;
       }catch(err){
           alert('JS Error ::  :: handleDeleteConfirmation')
           console.error(err)
       }
    }

    handleDeleteCancel(){
       try{
        this.showDeleteConfirmation = false;
       }catch(err){
           alert('JS Error ::  :: handleDeleteCancel')
           console.error(err)
       }
    }

    clientEngagementModelObjectPermissions;
    addOrEditMessage = "Add";
    records = [];
    showTable = false;

    async connectedCallback() {
        try {
            this.refreshHandlerID = registerRefreshHandler(this, this.refreshHandler);
        await Promise.all(
            [
                this.fetchObjectPermissions(),
                this.fetchMatterEngagementModels()
            ]
        );
        this.prepareColumns();

            document.addEventListener("click", this.handleTabulatorAddButtonClick);
        } catch (err) {
            alert('JS Error ::  :: connectedCallback');
            console.error(this.serializeError(err));
        }
    }

    handleTabulatorAddButtonClick = this.tabulatorAddButtonClick.bind(this);

    tabulatorAddButtonClick(event){
       try{
        if (event.target.id === (TABULATOR_BUTTON_ID_PREFIX + this.instanceId)) {
            this.handleAdd();
        }
       }catch(err){
           alert('JS Error ::  :: tabulatorAddButtonClick')
           console.error(err)
       }
    }

    columnsClientEngagementModelsToAdd = [
        {
            title: "",
            field: "isSelected",
            align: "center",
            width: "40",
            resizable: false,
            headerSort: false,
            formatter: (cell) => {
                let isSelected = cell.getValue();
                return `<input type="checkbox" class="engagement-checkbox" ${isSelected ? 'checked' : ''} />`;
            },
            cellClick: (e, cell) => this.handleCheckboxClick(e, cell)
        },
        {
            title: "Symphony ID", field: "symphonyId", headerFilter: false, type: "recordlink", formatterParams: {
                "recordIdField" : "recordId",
                "classList" : [],
                "styleList" : [
                    {
                        "property" : "font-weight",
                        "value" : "bold",
                    }
                ]
            }
        },
        {
            title: "Type", headerFilter: true, field: "type", formatterParams: {
                "recordIdField" : "recordId",
                "classList" : [],
                "styleList" : [
                    {
                        "property" : "font-weight",
                        "value" : "bold",
                    }
                ],
                "classListFunction" : this.contactRecordTypeFormatting
            }
        },
        {
            title: "Name", headerFilter: true, field: "contactName", type : 'picklist', type: "recordlink", formatterParams: {
                "recordIdField" : "contactRecordId",
                "classList" : [],
                "styleList" : [
                    {
                        "property" : "font-weight",
                        "value" : "bold",
                    }
                ]
            }
        },
        {
            title: "IP Matters", headerFilter: true, field: "ipMatters", formatterParams: {
                "recordIdField" : "recordId",
                "classList" : [],
                "styleList" : [
                    {
                        "property" : "font-weight",
                        "value" : "bold",
                    }
                ]
            }
        },            
        {
            title: "Jurisdiction", headerFilter: true, field: "jurisdictions", formatterParams: {
                "recordIdField" : "recordId",
                "classList" : [],
                "styleList" : [
                    {
                        "property" : "font-weight",
                        "value" : "bold",
                    }
                ]
            }
        },
        {
            title: "Email", width:"15%", headerFilter: true, field: "email", formatterParams: {
                "recordIdField" : "recordId",
                "classList" : [],
                "styleList" : [
                    {
                        "property" : "font-weight",
                        "value" : "bold",
                    }
                ]
            }
        },
        {
            title: "Phone", width:"9%",headerFilter: true, field: "phone", formatterParams: {
                "recordIdField" : "recordId",
                "classList" : [],
                "styleList" : [
                    {
                        "property" : "font-weight",
                        "value" : "bold",
                    }
                ]
            }
        },
        {
            title: "Default", width:"7%",field: "isDefault",
            formatter: (cell, formatterParams) => {
                var isDefaulted = cell.getRow().getData().isDefault;

                if (isDefaulted)
                        return "<span class='greentag' style='font-weight:bold;'>Default</span>";
                    else
                        return "<span style='font-weight:bold;text-decoration:line-through'></span>";


            }
        },
        {
            title: "Active", width:"5%",field: "isActive",
            formatter: (cell, formatterParams) => {
                var isActive = cell.getRow().getData().isActive;

                if (isActive)
                        return "<span class='greentag' style='font-weight:bold;'>Active</span>";
                    else
                    return "<span class='redtag' style='font-weight:bold;'>Inactive</span>";
            }
        }
    ];

    clientEngagementModelRecords = [];
    fetchClientEngagementModelsToAdd(){
       try{
           const promise = getClientEngagementModelsToAddForMem({
            "recordId" : this.recordId
           })
           promise.then( response => {
               try{
                   this.clientEngagementModelRecords = response;
               }catch(err){
                   alert('JS Error in Server callback :: lwcPersonnel :: fetchClientEngagementModelsToAdd');
               }
           })
           promise.catch( error => {
               alert('Server Error :: lwcPersonnel :: fetchClientEngagementModelsToAdd :: apexMethod => getClientEngagementModelsToAddForMem');
               console.error(JSON.stringify(error));
           });
           return promise;
       }catch(err){
           alert('JS Error :: lwcPersonnel :: fetchClientEngagementModelsToAdd')
           console.error(err)
       }
    }

    cemsToAddAsMem = {};
     async handleCheckboxClick(event, cell) {
            try{
            event.stopPropagation();
    
            const rowData = cell.getRow().getData();
            const isSelected = rowData.isSelected;
            if (!isSelected) {
                rowData.isSelected = true;
                this.cemsToAddAsMem[ rowData.recordId ] = rowData.recordId;
            } else {
                rowData.isSelected = false;
                delete this.cemsToAddAsMem[ rowData.recordId ];
            }
        }catch(err){
            alert('JS Error :: assetIntakeFormInventors :: handleCheckboxClick');
            this.handleAllErrorTypes(err);
        }
    
    }

    fetchObjectPermissions(){
        try{
         const promise = getObjectPermission({ 'objectApiName': 'SymphonyLF__Matter_Engagement_Model__c' });
         promise.then( response => {
                try{
                 this.clientEngagementModelObjectPermission = response;
                }catch(err){
                    alert('JS Error in Server callback ::  :: fetchObjectPermissions');
                }
            })
            .catch( error => {
                alert('Server Error ::  :: fetchObjectPermissions :: apexMethod => getObjectPermission');
                console.error(JSON.stringify(error));
            });
 
            return promise;
        }catch(err){
            alert('JS Error ::  :: fetchObjectPermissions')
            console.error(err)
        }
     }

    prepareColumns() {
        if(hasViewPermission) {
            try {
                let columns = [
                {
                    title: "Symphony ID", field: "symphonyId", headerFilter: false, type: "recordlink", formatterParams: {
                        "recordIdField" : "recordId",
                        "classList" : [],
                        "styleList" : [
                            {
                                "property" : "font-weight",
                                "value" : "bold",
                            }
                        ]
                    }
                },
                {
                    title: "Type", headerFilter: true, field: "type", formatterParams: {
                        "recordIdField" : "recordId",
                        "classList" : [],
                        "styleList" : [
                            {
                                "property" : "font-weight",
                                "value" : "bold",
                            }
                        ],
                        "classListFunction" : this.contactRecordTypeFormatting
                    }
                },
                {
                    title: "Name", headerFilter: true, field: "contactName", type : 'picklist', type: "recordlink", formatterParams: {
                        "recordIdField" : "contactRecordId",
                        "classList" : [],
                        "styleList" : [
                            {
                                "property" : "font-weight",
                                "value" : "bold",
                            }
                        ]
                    }
                },           
                {
                    title: "Email", headerFilter: true, field: "email", formatterParams: {
                        "recordIdField" : "recordId",
                        "classList" : [],
                        "styleList" : [
                            {
                                "property" : "font-weight",
                                "value" : "bold",
                            }
                        ]
                    }
                },
                {
                    title: "Phone", headerFilter: true, field: "phone", formatterParams: {
                        "recordIdField" : "recordId",
                        "classList" : [],
                        "styleList" : [
                            {
                                "property" : "font-weight",
                                "value" : "bold",
                            }
                        ]
                    }
                },
                {
                    title: "Default", width:"7%",field: "isDefault",
                    formatter: (cell, formatterParams) => {
                        var isDefaulted = cell.getRow().getData().isDefault;

                        if (isDefaulted)
                                return "<span class='greentag' style='font-weight:bold;'>Default</span>";
                            else
                                return "<span style='font-weight:bold;text-decoration:line-through'></span>";
        
        
                    }
                },
                {
                    title: "Active", width:"5%",field: "isActive",
                    formatter: (cell, formatterParams) => {
                        var isActive = cell.getRow().getData().isActive;

                        if (isActive)
                                return "<span class='greentag' style='font-weight:bold;'>Active</span>";
                            else
                            return "<span class='redtag' style='font-weight:bold;'>Inactive</span>";
                    }
                }
            ];

            const canEdit   = hasEditPermission;
            const canDelete = hasDeletePermission;
            const canAdd = hasAddPermission;
              
            let action = {
                title: "actions", field: "actions", align: "center", width: "75", resizable: false, headerSort: false, formatter: (cell, formatterParams) => {
                    let cellData = cell.getRow().getData();
                    let formattedHtml = ` <div class="action-icons"> `

                    /*if (cellData.recordPermission.canEdit) {
                        formattedHtml += ` <i class='fa fa-edit edit-icon' title='Edit'></i>  `;
                    }*/

                    /*if (cellData.recordPermission.canDelete) {
                        formattedHtml += ` <i class='fa fa-regular fa-trash delete-icon' title='Delete'></i> `;
                    }*/
                    if (canDelete) {
                        formattedHtml += ` <i class='fa fa-regular fa-trash delete-icon' title='Delete'></i> `;
                    }

                    formattedHtml += ` </div> `;
                    return formattedHtml;
                }
                , cellClick: (e, cell) => this.handleActionClick(e, cell)
                , titleFormatter: () => {
                    /*if (this.clientEngagementModelObjectPermission.canCreate) {
                        return ` 
                    <button id="${TABULATOR_BUTTON_ID_PREFIX + this.instanceId}" class="slds-button slds-button_brand">Add</button>
                    `;
                    }*/
                    if (canAdd) {
                        return ` 
                    <button id="${TABULATOR_BUTTON_ID_PREFIX + this.instanceId}" class="slds-button slds-button_brand">Add</button>
                    `;
                    }
                    else {
                        return ``;
                    }
                }
                , hozAlign: "center"
                , columnHeaderVertAlign: "middle"
            };

            if (this.clientEngagementModelObjectPermission.canCreate
                ||
                this.clientEngagementModelObjectPermission.canEdit
                ||
                this.clientEngagementModelObjectPermission.canDelete
            ) {
                columns.push(action);
            }
        

            this.columns = columns;
        } catch (err) {
            alert('JS Error ::  :: prepareColumns');
            console.error(this.serializeError(err));
        }
      }
    }

    contactRecordTypeFormatting(cell){
        try{
            const contactRecordType = cell.getRow().getData().contactRecordType;
            if(contactRecordType === PERSON_RECORD_TYPE_INTERNAL){
             return ["greentag"]
            }
            else if(contactRecordType === PERSON_RECORD_TYPE_EXTERNAL){
             return ["greytag"]
            }
            else{
             return [];
            }
        }catch(err){
            alert('JS Error ::  :: contactRecordTypeFormatting')
            console.error(err)
        }
     }

     refreshHandler() {
        try {
            if (this.currentElementInitiatedRefresh) {
                this.currentElementInitiatedRefresh = false;
                return;
            }
           // this.fetchMatterEngagementModels();
        } catch (err) {
            alert('JS Error ::   :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }

    disconnectedCallback() {
        try{
            unregisterRefreshHandler(this.refreshHandlerID);

            document.removeEventListener("click", this.handleTabulatorAddButtonClick);
        } catch (err) {
            alert('JS Error ::   :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }

    fetchMatterEngagementModels(){
       try{
        const promise = getMatterEngagementModels({
            'recordId': this.recordId
           })
           promise.then(response => {
               try{
                   this.records = response;
                   this.showTable = true;

                   console.log('this.records matter models ', JSON.stringify(this.records));
                   console.log('isLoadingFirstTime---->',this.isLoadingFirstTime);

                   //if (this.isLoadingFirstTime == false) {
                    this.updateTableData(response);
                //}
               }catch(err){
                   alert('JS Error in Server callback ::  :: fetchMatterEngagementModels');
               }
           })
           .catch( error => {
               alert('Server Error ::  :: fetchMatterEngagementModels :: apexMethod => getMatterEngagementModels');
               console.error(error);
               console.error(JSON.stringify(error));
               console.error( this.serializeError(error) );
           })
           .finally(() => {
            this.isLoadingFirstTime = false;
        });

        return promise;
       }catch(err){
           alert('JS Error ::  :: fetchMatterEngagementModels')
           console.error(err)
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
    showAdd = false;
    showEdit = false;
    isLoading = false;

    async handleAdd() {
        try {
            this.isLoading = true;
            this.addOrEditMessage = 'Add';
            this.clientEngagementModelId = null;
            await this.fetchClientEngagementModelsToAdd();
            this.isLoading = false;
            this.showAdd = true;
        } catch (err) {
            alert('JS Error ::  :: handleAdd')
            console.error(err)
        }
    }

    handleEditSuccess() {
        try {
            this.showEdit = false;
            this.isLoading = false;
            this.fetchMatterEngagementModels();
            this.refreshOtherElementsOnThePage();
            this.showToast('Success', 'success', 'Record updated');
        } catch (err) {
            alert('JS Error ::  :: handleEditSuccess')
            console.error(this.serializeError(err));
        }
    }

    handleAddEditError(event) {
        try {
            const errorDetails = event.detail;
            console.error('Error occurred while saving the record:', errorDetails);

            // Display a custom error message to the user (optional)
            const errorMessage = this.extractErrorMessage(errorDetails);

            this.showToast('Error', 'error', errorMessage); // 'Record not updated'
            this.isLoading = false;
        } catch (err) {
            alert('JS Error ::  :: handleAddEditError')
            console.error(this.serializeError(err));
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

    handleCancel() {
        try {
            this.showAdd = false;
            this.showEdit = false;
            this.cemsToAddAsMem = {};
        } catch (err) {
            alert('JS Error ::  :: handleCancel')
            console.error(this.serializeError(err));
        }
    }

    async handleAddSave(){
       try{
            this.isLoading = true;

            let cemsList = Object.keys(this.cemsToAddAsMem);
            console.log('cemsList ', cemsList.length);
            console.log('cemsList ', JSON.stringify(cemsList));
           
            if(
                cemsList.length
            ){
                await this.addCemsToTheMems();
            }
            this.showAdd = false;
       }catch(err){
           alert('JS Error ::  :: handleAddSave')
           console.error(err)
       }
    }

    addCemsToTheMems(){
       try{
           const promise = addCemsToMems({
            "recordId" : this.recordId,
            "cemIds" : Object.keys(this.cemsToAddAsMem)
           });
           promise.then( response => {
               try{
                   
               }catch(err){
                   alert('JS Error in Server callback ::  :: addCemsToTheMems');
               }
               
           });
           promise.catch( error => {
               alert('Server Error ::  :: addCemsToTheMems :: apexMethod => addCemsToMems');
               console.error(JSON.stringify(error));
           });
           promise.finally( () => {
                this.cemsToAddAsMem = {};
                this.isLoading = true;
                this.fetchMatterEngagementModels();
           });

           return promise;
       }catch(err){
           alert('JS Error ::  :: addCemsToTheMems')
           console.error(err)
       }
    }

    handleEditSave() {
        try {
            console.log('Handle Save called');
            this.isLoading = true;

            const inputFields = this.template.querySelectorAll('lightning-input-field');

            const fields = {};

            let isValid = true;

            inputFields.forEach(inputField => {
                if(! inputField.reportValidity()){
                    isValid = false;
                }

                fields[inputField.fieldName] = inputField.value;
            });

            if(! isValid){
                this.isLoading = false;
                return;
            }

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } catch (err) {
            alert('JS Error ::  :: handleSave')
            console.error(this.serializeError(err));
        }
    }

    get
        showAddEditVisible() {
        try {
            return this.showEdit ? 'slds-show' : 'slds-hide';
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
                //   loadScript(this, MAXVALTABLEJS),
                //   loadStyle(this, MAXVALTABLECSS),
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
                .then(() => {
                    /*  const defaultTile = this.template.querySelector('[data-filtertype="aggregateCollaborations"]');
                      if (defaultTile) {
                          defaultTile.classList.add('selected');
                      } */
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

    // updateTableData(data) {
    //     try {
    //         const tableElement = this.template.querySelector('.lwcMvDataTable');
    //         if (tableElement) {
    //             tableElement.updateTableData(data);
    //             console.log('MEMs updated---');
    //         }

    //     } catch (err) {
    //         alert('JS Error ::  :: updateTableData')
    //         console.error(err)
    //     }
    // }

    updateTableData(data) {
    try {
        setTimeout(() => {
            const tableElement = this.template.querySelector('.lwcMvDataTable');
            console.log('table element--->',tableElement);
            if (tableElement) {
                tableElement.updateTableData(data);
                console.log('MEMs updated---');
            } else {
                console.warn('Table element not found');
            }
        }, 0); // 0ms delay defers execution until after current call stack
    } catch (err) {
        alert('JS Error :: updateTableData');
        console.error(err);
    }
}

    currentElementInitiatedRefresh = false;
    refreshOtherElementsOnThePage() {
        try {
            this.currentElementInitiatedRefresh = true;
            this.dispatchEvent(new RefreshEvent());
        } catch (err) {
            alert('JS Error ::  :: refreshOtherElementsOnThePage')
            console.error(err)
        }
    }
}