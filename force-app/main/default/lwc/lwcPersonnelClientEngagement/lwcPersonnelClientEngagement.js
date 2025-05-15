import { LightningElement, wire, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import FA from "@salesforce/resourceUrl/FA";
import { RefreshEvent, registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClientEngagementModels from '@salesforce/apex/mvLawfirmUtilities.getClientEngagementModels';
import getObjectPermission from '@salesforce/apex/mvLawfirmUtilities.getObjectPermission';
import getUserTimezoneOffset from '@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset';
import getUserLocale from '@salesforce/apex/mvLawfirmUtilities.getUserLocale';

const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100, 500];

const TABULATOR_BUTTON_ID_PREFIX = 'myButton';

const PERSON_RECORD_TYPE_INTERNAL = 'Internal';
const PERSON_RECORD_TYPE_EXTERNAL = 'External';

export default class LwcPersonnelClientEngagement extends NavigationMixin(LightningElement) {
    @api recordId;

    clientIdCondition = '';
    instanceId = "cmp-" + Math.random().toString(36).substring(2, 9);

    refreshHandlerID;
    isLoadingFirstTime = true;

    clientEngagementModelObjectPermissions;
    addOrEditMessage = "Add";
    records = [];
    showTable = false;
    showDeleteConfirmation = false;
    columns = [];

    timezone;
    userlocale;

    clientEngagementModelId;
    showAddEdit = false;
    isLoading = false;

    currentFeatureSettings = {

        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR
    };

    @wire(getUserTimezoneOffset)
    wiredTimezone({ error, data }) {
        if (data) {
            this.timezone = data; // Example: "America/New_York"
        }
    }

    @wire(getUserLocale)
    wiredUserLocale({ error, data }) {
        if (data) {
            this.userlocale = data.replace('_','-');
        }
    }

    handleActionClick(e, cell) {
        try {
            let target = e.target;
            let rowData = cell.getRow().getData();

            const recordId = rowData.recordId;
            this.clientEngagementModelId = recordId;
            this.assignedTo = rowData.contactRecordId;

            if (target.classList.contains("edit-icon")) {
                this.addOrEditMessage = 'Edit';
                this.showAddEdit = true;
            } else if (target.classList.contains("delete-icon")) {
                this.showDeleteConfirmation = true;
            }
        } catch (err) {
            console.error('JS Error ::  :: handleActionClick')
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
                this.fetchClientEngagementModels();
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
           console.error('JS Error ::  :: handleDeleteConfirmation')
           console.error(err)
       }
    }

    handleDeleteCancel(){
       try{
        this.showDeleteConfirmation = false;
       }catch(err){
           console.error('JS Error ::  :: handleDeleteCancel')
           console.error(err)
       }
    }

    async connectedCallback() {
        try {
            this.clientIdCondition = `
            Id NOT IN (SELECT Person__c FROM Access_Restriction__c WHERE Client__c = '${this.recordId}')
            AND
            SymphonyLF__Type__c IN ('Client', 'Attorney', 'Legal Assistant', 'Paralegal', 'Office/Agent', 'Assistant', 'Other Party', 'Docketer', 'Billing', 'Docketing', 'Finance')
            `;

            this.refreshHandlerID = registerRefreshHandler(this, this.refreshHandler);

            await Promise.all(
                [
                    this.fetchObjectPermissions(),
                    this.fetchClientEngagementModels()
                ]
            );
            
            this.prepareColumns();

            document.addEventListener("click", this.handleTabulatorAddButtonClick);
        } catch (err) {
            console.error('JS Error ::  :: connectedCallback');
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
           console.error('JS Error ::  :: tabulatorAddButtonClick')
           console.error(err)
       }
    }

    fetchObjectPermissions(){
       try{
        const promise = getObjectPermission({ 'objectApiName': 'SymphonyLF__Client_Engagement_Model__c' });
        promise.then( response => {
               try{
                this.clientEngagementModelObjectPermission = response;
               }catch(err){
                   console.error('JS Error in Server callback ::  :: fetchObjectPermissions');
               }
           })
           .catch( error => {
               console.error('Server Error ::  :: fetchObjectPermissions :: apexMethod => getObjectPermission');
               console.error(JSON.stringify(error));
           });

           return promise;
       }catch(err){
           console.error('JS Error ::  :: fetchObjectPermissions')
           console.error(err)
       }
    }

    prepareColumns() {
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

            let action = {
                title: "actions", field: "actions", align: "center", width: "80", resizable: false, headerSort: false, formatter: (cell, formatterParams) => {
                    let cellData = cell.getRow().getData();
                    let formattedHtml = ` <div class="action-icons"> `

                    // if (cellData.recordPermission.canEdit) {
                    //     formattedHtml += ` <i class='fa fa-edit edit-icon' title='Edit'></i>  `;
                    // }

                    if (cellData.recordPermission.canDelete) {
                        formattedHtml += ` <i class='fa fa-regular fa-trash delete-icon' title='Delete'></i> `;
                    }

                    formattedHtml += ` </div> `;
                    return formattedHtml;
                }
                , cellClick: (e, cell) => this.handleActionClick(e, cell)
                , titleFormatter: () => {
                    if (this.clientEngagementModelObjectPermission.canCreate) {
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
            console.error('JS Error ::  :: prepareColumns');
            console.error(this.serializeError(err));
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
           console.error('JS Error ::  :: contactRecordTypeFormatting')
           console.error(err)
       }
    }

    refreshHandler() {
        try {
            if (this.currentElementInitiatedRefresh) {
                this.currentElementInitiatedRefresh = false;
                return;
            }
            this.fetchClientEngagementModels();
        } catch (err) {
            console.error('JS Error ::   :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }

    disconnectedCallback() {
        try{
            unregisterRefreshHandler(this.refreshHandlerID);

            document.removeEventListener("click", this.handleTabulatorAddButtonClick);
        } catch (err) {
            console.error('JS Error ::   :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }

    fetchClientEngagementModels() {
        try {
            const promise = getClientEngagementModels({
                'recordId': this.recordId
            });
            promise.then(response => {
                    try {
                        this.records = response;
                        this.showTable = true;

                        if (this.isLoadingFirstTime == false) {
                            this.updateTableData(response);
                        }
                    } catch (err) {
                        console.error('JS Error in Server callback ::  :: fetchClientEngagementModels');
                    }
                })
                .catch(error => {
                    console.error('Server Error ::  :: fetchClientEngagementModels :: apexMethod => getClientEngagementModels');
                    console.error(JSON.stringify(error));
                })
                .finally(() => {
                    this.isLoadingFirstTime = false;
                });

                return promise;
        } catch (err) {
            console.error('JS Error ::  :: fetchClientEngagementModels')
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

    handleAdd() {
        try {
            this.addOrEditMessage = 'Add';
            this.clientEngagementModelId = null;
            this.assignedTo = '';
            this.showAddEdit = true;
        } catch (err) {
            console.error('JS Error ::  :: handleAdd')
            console.error(err)
        }
    }

    handleAddEditSuccess() {
        try {
            this.showAddEdit = false;
            this.isLoading = false;
            this.assignedTo = '';
            this.fetchClientEngagementModels();
            this.refreshOtherElementsOnThePage();
            this.showToast('Success', 'success', 'Record updated');
        } catch (err) {
            console.error('JS Error ::  :: handleAddEditSuccess')
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
            console.error('JS Error ::  :: handleAddEditError')
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
            this.showAddEdit = false;
            this.assignedTo = '';
        } catch (err) {
            console.error('JS Error ::  :: handleCancel')
            console.error(this.serializeError(err));
        }
    }

    handleSave() {
        try {

            if (!this.assignedTo) {
                this.showToast('Error', 'error', 'Person is Mandatory');
                return;
            }
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

            if (this.assignedTo) {
                fields.SymphonyLF__Person__c = this.assignedTo;
            }
            

            if(! isValid){
                this.isLoading = false;
                return;
            }

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } catch (err) {
            console.error('JS Error ::  :: handleSave')
            console.error(this.serializeError(err));
        }
    }

    get
    showAddEditVisible() {
        try {
            return this.showAddEdit ? 'slds-show' : 'slds-hide';
        } catch (err) {
            console.error('JS Error ::  :: showAddEditVisible')
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
            console.error('JS Error ::  :: renderedCallback')
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
            console.error('JS Error ::  :: extractErrorMessage');
            console.error(err);
        }
    }

    updateTableData(data) {
        try {
            const tableElement = this.template.querySelector('.lwcMvDataTable');
            if (tableElement) {
                tableElement.updateTableData(data);
            }

        } catch (err) {
            console.error('JS Error ::  :: updateTableData')
            console.error(err)
        }
    }

    currentElementInitiatedRefresh = false;
    refreshOtherElementsOnThePage() {
        try {
            this.currentElementInitiatedRefresh = true;
            this.dispatchEvent(new RefreshEvent());
        } catch (err) {
            console.error('JS Error ::  :: refreshOtherElementsOnThePage')
            console.error(err)
        }
    }

    //Added for Personnel filter
    @track assignedTo = '';
    handleAssignedToChange(event) {
        try {
            if(event.detail.length){
                this.assignedTo = event.detail[0].Id;
            }else{
                this.assignedTo = '';
            }
            
        } catch (error) {
            console.error('JS Error assignedTo::  :: handleAssignedToChange')
            console.error(this.serializeError(error));
        }
        
    }
}