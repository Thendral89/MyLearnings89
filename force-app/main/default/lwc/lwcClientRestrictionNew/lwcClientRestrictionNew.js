import { LightningElement, wire, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import FA from "@salesforce/resourceUrl/FA";
import { RefreshEvent, registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClientRestrictions from '@salesforce/apex/mvLawfirmUtilities.getClientRestrictions';
import getObjectPermission from '@salesforce/apex/mvLawfirmUtilities.getObjectPermission';
import getUserTimezoneOffset from '@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset';
import getUserLocale from '@salesforce/apex/mvLawfirmUtilities.getUserLocale';
import canModifyRestriction from '@salesforce/apex/ClientController.canModifyRestriction';
import removeAccess from '@salesforce/apex/ClientController.addOrRemoveRestriction';
import grantAccess from '@salesforce/apex/ClientController.addOrRemoveRestriction';

import { refreshApex } from '@salesforce/apex';

const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100, 500];

const TABULATOR_BUTTON_ID_PREFIX = 'myButtonMatterEngagementModel';

const PERSON_RECORD_TYPE_INTERNAL = 'Internal';
const PERSON_RECORD_TYPE_EXTERNAL = 'External';

const RETURN_CODE_DELETED = 'DELETED';
const RETURN_CODE_CREATED = 'CREATED';
const RETURN_CODE_UPSERTED = 'UPSERTED';

export default class LwcClientRestrictionNew extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @track data = [];
    @track selectedData = [];
    @track columns = [];

    @track showModal = false;

    clientEngagementModelObjectPermissions;
    addOrEditMessage = "Add";
    records = [];
    showTable = false;

    wiredPersonsResult;

    instanceId = "cmp-" + Math.random().toString(36).substring(2, 9);

    refreshHandlerID;
    isLoadingFirstTime = true;

    //Added for Personnel filter
    @track clientIdCondition = '';
    @track assignedTo = '';

    hasCrudAccess = false;

    currentFeatureSettings = {

        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR
    };

    timezone;
    userlocale;

    @wire(getUserTimezoneOffset)
    wiredTimezone({ error, data }) {
        if (data) {
            this.timezone = data; // Example: "America/New_York"
        }
    }

    @wire(getUserLocale)
    wiredUserLocale({ error, data }) {
        if (data) {
            this.userlocale = data.replace('_', '-');
        }
    }

    showDeleteConfirmation = false;
    columns = [];
    accessRestrictionId;

    handleActionClick(e, cell) {
        try {
            let target = e.target;
            let rowData = cell.getRow().getData();

            if (target.classList.contains("edit-icon")) {
                this.addOrEditMessage = 'Edit';
                this.showAddEdit = true;
            } else if (target.classList.contains("delete-icon")) {
                this.accessRestrictionId = cell.getRow().getData().recordId;
                this.showDeleteConfirmation = true;
            }
        } catch (err) {
            console.error('JS Error ::  :: handleActionClick')
            console.error(this.serializeError(err));
        }
    }

    // check here
    handleDeleteConfirmation() {
        try {
            console.log('All this.accessRestrictionId ', this.accessRestrictionId);
            grantAccess({ accessRestrictionId: this.accessRestrictionId, clientId: this.recordId, grantAccess: true })
            .then(result => {
                if(result == RETURN_CODE_DELETED){
                    this.showAccessTerminateToast();
                }
                else if(result == RETURN_CODE_UPSERTED){
                    this.showAccessReleaseToast();
                }
            })
            .catch(err => {
                console.error('Server error :: handleDeleteConfirmation');
                this.handleAllErrorTypes( err );
            })
            .finally(() => {
                this.fetchClientRestrictions();
                this.refreshOtherElementsOnThePage();
            })

            this.showDeleteConfirmation = false;
        } catch (err) {
            console.error('JS Error ::  :: handleDeleteConfirmation')
            console.error(err)
        }
    }

    handleDeleteCancel() {
        try {
            this.showDeleteConfirmation = false;
        } catch (err) {
            console.error('JS Error ::  :: handleDeleteCancel')
            console.error(err)
        }
    }

    handleAllErrorTypes(err){
        try{
            console.error(err);
            console.error( JSON.stringify(err) );
            console.error( this.serializeError(err) );
        }catch(err){
            console.error('JS Error ::  :: handleAllErrorTypes')
            console.error(err)
        }
     }

    async connectedCallback() {

        this.clientIdCondition = `
            Id NOT IN (SELECT Person__c FROM Access_Restriction__c WHERE Client__c = '${this.recordId}')
             AND 
             Is_User_Active__c = true
             AND 
             SymphonyLF__User__r.ProfileName__c NOT IN ('Docketer','Client','Account and Finance Team','System Administrator')
             AND 
            Id NOT IN (SELECT SymphonyLF__Person__c FROM SymphonyLF__Client_Engagement_Model__c WHERE SymphonyLF__Client__c = '${this.recordId}' AND Is_Active__c = true)
             `;
        
        try {
            this.refreshHandlerID = registerRefreshHandler(this, this.refreshHandler);
            await Promise.all(
                [
                    this.fetchObjectPermissions(),
                    
                    this.fetchClientRestrictions(),

                    this.fetchCanModifyRestriction()
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

    tabulatorAddButtonClick(event) {
        try {
            if (event.target.id === (TABULATOR_BUTTON_ID_PREFIX + this.instanceId)) {
                this.handleAdd();
            }
        } catch (err) {
            console.error('JS Error ::  :: tabulatorAddButtonClick')
            console.error(err)
        }
    }

    fetchCanModifyRestriction(){
       try{
        const promise = canModifyRestriction({
            'clientId' : this.recordId
           })
           promise.then( response => {
               try{
                   this.hasCrudAccess = response
               }catch(err){
                    console.error('JS Error in Server callback :: lwcClientRestrictionNew :: fetchCanModifyRestriction');
               }
           })
           .catch( error => {
                console.error('Server Error :: lwcClientRestrictionNew :: fetchCanModifyRestriction :: apexMethod => canModifyRestriction');
               console.error(JSON.stringify(error));
           })

           return promise;
       }catch(err){
            console.error('JS Error :: lwcClientRestrictionNew :: fetchCanModifyRestriction')
           console.error(err)
       }
    }

    fetchObjectPermissions() {
        try {
            const promise = getObjectPermission({ 'objectApiName': 'Access_Restriction__c' });
            promise.then(response => {
                try {
                    this.clientEngagementModelObjectPermission = response;
                } catch (err) {
                    console.error('JS Error in Server callback ::  :: fetchObjectPermissions');
                }
            })
                .catch(error => {
                    console.error('Server Error ::  :: fetchObjectPermissions :: apexMethod => getObjectPermission');
                    console.error(JSON.stringify(error));
                });

            return promise;
        } catch (err) {
            console.error('JS Error ::  :: fetchObjectPermissions')
            console.error(err)
        }
    }

    prepareColumns() {
        try {
            let columns = [
                {
                    title: "Symphony ID", field: "symphonyId", headerFilter: false, type: "recordlink", formatterParams: {
                        "recordIdField": "recordId",
                        "classList": [],
                        "styleList": [
                            {
                                "property": "font-weight",
                                "value": "bold",
                            }
                        ]
                    }
                },
                {
                    title: "Type", headerFilter: true, field: "type", formatterParams: {
                        "recordIdField": "recordId",
                        "classList": [],
                        "styleList": [
                            {
                                "property": "font-weight",
                                "value": "bold",
                            }
                        ],
                        "classListFunction": this.contactRecordTypeFormatting
                    }
                },
                {
                    title: "Name", headerFilter: true, field: "contactName", type: 'picklist', type: "recordlink", formatterParams: {
                        "recordIdField": "contactRecordId",
                        "classList": [],
                        "styleList": [
                            {
                                "property": "font-weight",
                                "value": "bold",
                            }
                        ]
                    }
                },
                {
                    title: "Email", headerFilter: true, field: "email", formatterParams: {
                        "recordIdField": "recordId",
                        "classList": [],
                        "styleList": [
                            {
                                "property": "font-weight",
                                "value": "bold",
                            }
                        ]
                    }
                },
                {
                    title: "Phone", headerFilter: true, field: "phone", formatterParams: {
                        "recordIdField": "recordId",
                        "classList": [],
                        "styleList": [
                            {
                                "property": "font-weight",
                                "value": "bold",
                            }
                        ]
                    }
                },
                {
                    title: "Status", headerFilter: true, field: "status", formatterParams: {
                        "classList": [],
                        "styleList": [
                            {
                                "property": "font-weight",
                                "value": "bold",
                            }
                        ],
                        "classListFunction": this.statusFormatting
                    }
                }
            ];

            let action = {
                title: "actions", field: "actions", align: "center", width: "75", resizable: false, headerSort: false, formatter: (cell, formatterParams) => {
                    let cellData = cell.getRow().getData();
                    let formattedHtml = ` <div class="action-icons"> `

                    if (cellData.recordPermission.canDelete) {
                        formattedHtml += ` <i class='fa fa-regular fa-trash delete-icon' title='Delete'></i> `;
                    }

                    formattedHtml += ` </div> `;
                    return formattedHtml;
                }
                , cellClick: (e, cell) => this.handleActionClick(e, cell)
                , titleFormatter: () => {
                    if (
                        this.hasCrudAccess 
                        &&
                        this.clientEngagementModelObjectPermission.canCreate
                    ) {
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

            if (
                this.hasCrudAccess
                &&
                (
                    this.clientEngagementModelObjectPermission.canCreate
                    ||
                    this.clientEngagementModelObjectPermission.canDelete
                )
            ) {
                columns.push(action);
            }

            this.columns = columns;
        } catch (err) {
            console.error('JS Error ::  :: prepareColumns');
            console.error(this.serializeError(err));
        }
    }

    // check this
    handleSave() {

        removeAccess({
            personId: this.assignedTo, 
            clientId: this.recordId,
            grantAccess: false
        })
        .then(result => {
            try{
            this.showSuccessToast();

            this.fetchClientRestrictions();
            this.refreshOtherElementsOnThePage();
            }catch(err){
                console.error('handleSave :: removeAccess');
                this.handleAllErrorTypes();
            }
        })
        .catch(error => {
            console.error('Apex Call Error:', error);
        }).finally(() => {
            refreshApex(this.wiredPersonsResult);
        });

        this.showModal = false;
        this.showAddEdit = false;
    }

   

    updateEngagementTableData(data) {
        try {
            const tableElement = this.template.querySelector('c-lwc-mv-datatable[data-id="engagementTable"]');
            if (tableElement) {
                tableElement.updateTableData(data);
            }
    
        } catch (err) {
            console.error('JS Error ::  :: updateTableData')
            console.error(err)
        }
    }

    contactRecordTypeFormatting(cell) {
        try {

            return ["redtag"];
        } catch (err) {
            console.error('JS Error ::  :: contactRecordTypeFormatting')
            console.error(err)
        }
    }

    statusFormatting(cell) {
        try {
            const status = cell.getRow().getData().status;
            if(status === 'To Be Enforced' || status === 'To Be Granted'){
             return ["greentag"]
            }
            else if(status === 'Enforced'){
             return ["greytag"]
            }
            else{
             return [];
            }
        } catch (err) {
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
            this.fetchClientRestrictions();
        } catch (err) {
            console.error('JS Error ::   :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }

    disconnectedCallback() {
        try {
            unregisterRefreshHandler(this.refreshHandlerID);

            document.removeEventListener("click", this.handleTabulatorAddButtonClick);
        } catch (err) {
            console.error('JS Error ::   :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }


    
    fetchClientRestrictions() {
        try {
            const promise = getClientRestrictions({
                'recordId': this.recordId
            })
            promise.then(response => {
                try {
                    this.selectedData = response;
                    this.showTable = true;

                    if (this.isLoadingFirstTime == false) {
                        this.updateTableData(response);
                    }
                } catch (err) {
                    console.error('JS Error in Server callback ::  :: Fetch Access Restrictions');
                }
            })
                .catch(error => {
                    console.error('Server Error ::  :: Fetch Access Restrictions :: apexMethod => getClientRestrictions');
                    console.error(JSON.stringify(error));
                })
                .finally(() => {
                    this.isLoadingFirstTime = false;
                });

            return promise;
        } catch (err) {
            console.error('JS Error ::  :: Fetch Access Restrictions')
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

    showAddEdit = false;
    isLoading = false;

    handleAdd() {
        try {
            this.addOrEditMessage = 'Add';
            this.assignedTo = '';
            this.showAddEdit = true;
        } catch (err) {
            console.error('JS Error ::  :: handleAdd')
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

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Restriction will be Enforced in sometime',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showAccessReleaseToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Restriction will be Released in sometime',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showAccessTerminateToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Action terminated',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleCancel() {
        this.showAddEdit = false;
         this.showModal = false;
         this.assignedTo = '';
     }

    isRenderedCallBackInitialized = false;

    renderedCallback() {
        try {
            if (this.isRenderedCallBackInitialized) return;
            this.isRenderedCallBackInitialized = true;

            Promise.all([
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
            .then(() => {
            });
        } catch (err) {
            console.error('JS Error ::  :: renderedCallback')
            console.error(err)
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

    handleAssignedToChange(event) {
        try {
            if(event.detail.length){
                this.assignedTo = event.detail[0].Id;
            }
            else{
                this.assignedTo = '';
            }
        } catch (error) {
            console.error('JS Error ::  :: handleAssignedToChange')
            console.error(this.serializeError(error));
        }
        
    }
}