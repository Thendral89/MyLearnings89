/**
 * Copyright © 2025 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
     * @author     : Siva Nekkalapudi (siva.n@maxval.com)
     * @modifier   : 18-APR-2025
     * @ticket     : PSOD-
*/
import { LightningElement, api, wire, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord,
    getRecord,
    getFieldValue
    } from "lightning/uiRecordApi";

import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

/* Import the Static Resources for Tabulator and FA Open source libraries*/
import MAXVALTABLECSS from "@salesforce/resourceUrl/MAXVALTABLECSS";
import MAXVALTABLEJS from "@salesforce/resourceUrl/MAXVALTABLEJS";
import FA from "@salesforce/resourceUrl/FA";

/* Import Toast Events*/
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* This scoped module imports the current user profile name and User Id */
import profileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';

/* Console Navigation */
import {
    closeTab,
    IsConsoleNavigation,
    getFocusedTabInfo
} from 'lightning/platformWorkspaceApi';

/* Check for User Permissions */
import hasAddPermission from '@salesforce/customPermission/Renewal_Configuration_Add';
import hasEditPermission from '@salesforce/customPermission/Renewal_Configuration_Edit';
import hasDeletePermission from '@salesforce/customPermission/Renewal_Configuration_Delete';
import hasViewPermission from '@salesforce/customPermission/Renewal_Configuration_View';

import CURRENCY_FIELD from "@salesforce/schema/SymphonyLF__Client__c.SymphonyLF__Default_Billing_Currency__r.Name";
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';
import {
    registerRefreshHandler,
    unregisterRefreshHandler
} from 'lightning/refresh';


export default class RenewalConfiguration extends LightningElement {
    
    // Make a Component Aware of Its Record Context
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_object_context
    @api recordId;

    /* Common Variables */
    isSpinner = false; 
    spinnerText = '';
    isRenderedCallBackInitialized = false;
    @track baseURL;
    
    /* Variable to control Add /Edit/Delete */
    showModalUI = false;
    renewalRecordId = '';
    actionText = '';
    submitDisabled= false;
    errorMessage = '';
    activeSections = [ 'Renewal Generation', 'Default Renewal Instruction', 'Renewal Cycle' ];
    showDefaultInstruction = false;
    refreshHandlerID;

    table;
    rowToDelete;           
    showDeleteModal = false;

    /* Variable to hold Renewal Configuration Data */
    renewalConfigurationData = [];
    _renewalConfigurationData = []; // Use only for Refresh

    @wire(IsConsoleNavigation) isConsoleNavigation;

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'SymphonyLF__Renewal_Annuities_Configurations__r', // custom Object(Child to Parent)
        fields: [ 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Asset_Type__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Instruction_Type__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Default_Instruction__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Instruction_Deadline__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Instruction_Window__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Is_Active__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Renewal_Start_Date__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Renewal_Stop_Date__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Start_Month__c'
                , 'SymphonyLF__Client_Renewal_Configuration__c.SymphonyLF__Default_Billing_Currency__c'
                ],
     })
    //  renewalConfigurationListInfo({error, data}) {                      
    //     if (data) {          
    //         this._renewalConfigurationData = data;  
    //         console.log ('Renewal Configuration Records : ' + JSON.stringify(data.records));
    //         this.renewalConfigurationData = JSON.parse(JSON.stringify(data.records));
    //     }else if (error) {
    //         console.error('Renewal Configuration Error : ', error);           
    //         this.renewalConfigurationData = undefined;
    //     }
    // }// End of renewalConfigurationListInfo
    wiredRenewalConfigs(result) {
        this._wiredRenewalConfigs = result;
        const { data, error } = result;
        if (data) {
            // keep clone for display
            this.renewalConfigurationData = JSON.parse(JSON.stringify(data.records));
            // if the table already exists, just replace its data
            if (this.table) {
                this.table.replaceData(this.renewalConfigurationData);
            }
        }else if (error) {
            console.error('Renewal Configuration Error : ', error);           
            this.renewalConfigurationData = undefined;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [CURRENCY_FIELD]})
    client;

    get clientBillingCurrency() {
        return getFieldValue(this.client.data, CURRENCY_FIELD);
    }

    get hasAddAccess() {
        return hasAddPermission;
    }

    get hasViewAccess() {
        return hasViewPermission;
    }

    refreshHandler() {
       return refreshApex(this._renewalConfigurationData);
    }

    connectedCallback() {
        // if the component runs in an org with Lightning Locker instead of Lightning Web Security (LWS), use
        // this.refreshContainerID = registerRefreshHandler(this.template.host, this.refreshHandler.bind(this));
        this.refreshHandlerID = registerRefreshHandler(
            this,
            this.refreshHandler
        );
  
    }

    refreshHandler() {
        console.log('In Refresh Handler');
        return this.refreshApex(this._renewalConfigurationData);
    }

    disconnectedCallback() {
        unregisterRefreshHandler(this.refreshHandlerID);
    }

    async renderedCallback() {
        if (this.isRenderedCallBackInitialized) {
            return;
        }
        await this.loadStylesAndScripts();
        // await this.initializeClientPersonnel();
        this.baseURL = window.location.origin;

    }

    async loadStylesAndScripts(){
        try{
            this.isSpinner = true;
            this.spinnerText = 'Please wait while the resources are being loaded...';
            await loadScript(this, MAXVALTABLEJS).then(() => {
                loadStyle(this, MAXVALTABLECSS).then(() => {
                    loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css').then(() => {
                        console.log('Scripts Loaded Successfully');
                        this.isRenderedCallBackInitialized = true;
                        this.initializeRenewalConfiguration();
                        this.isSpinner = false;
                        this.spinnerText = '';            
                    });
                });
            });
        }catch(err){
            this.isSpinner = false;
            this.spinnerText = '';
            console.error(JSON.stringify(err));
        }
    }

    initializeRenewalConfiguration() {
        if(hasViewPermission) {
            this.isSpinner = true;
            this.spinnerText = 'Please wait while we are fetching the Renewal Configuration data ... ';
            let component = this.template.querySelector('[data-id="renewalConfigurationTable"]');
            console.log('In Initialize Renewal Configuration Data');
            let sfdcURL = this.baseURL;
            let columns = [
                            {title:"Asset Type", field:"fields.SymphonyLF__Asset_Type__c.displayValue", headerFilter:true , formatter:function(cell, formatterParams){            
                                    var value = cell.getValue();
                                    if(value === 'Patent' )
                                        return "<span class='greentag'>" + value + "</span>";
                                    else if(value === 'Design' )
                                        return "<span class='greytag'>" + value + "</span>";
                                    else if(value === 'Trademark' )
                                        return "<span class='purpletag'>" + value + "</span>";
                                }
                            },
                            {title:"Renewal Cycle",  field:"fields.SymphonyLF__Instruction_Window__c.displayValue", headerFilter:true},
                            {title:"Instruction Deadline (in Months)",  field:"fields.SymphonyLF__Instruction_Deadline__c.value", headerFilter:true},
                            {title:"Default Instruction",  field:"fields.SymphonyLF__Default_Instruction__c.value", headerFilter:true},
                            {title:"Start Date",  field:"fields.SymphonyLF__Renewal_Start_Date__c.displayValue", headerFilter:true},
                            {title:"Stop Date",  field:"fields.SymphonyLF__Renewal_Stop_Date__c.displayValue", headerFilter:true},
                            {title:"Instruction Type",  field:"fields.SymphonyLF__Instruction_Type__c.displayValue", headerFilter:true},
                            {title:"Active",  field:"fields.SymphonyLF__Is_Active__c.value", formatter:function(cell, formatterParams){            
                                var value = cell.getValue();
                                if(value )
                                    return "<span class='greentag'>Active</span>";
                                else 
                                    return "<span class='redtag'>Inactive</span>";
                            }}
                        ];
            console.log('Delete Permission : ' + hasDeletePermission);

          /*  if (hasEditPermission) {
                columns.push({
                    title: '',
                    field: 'phone',
                    width: '2%',
                    headerSort: false,
                    formatter: () =>
                        "<i class='fa fa-regular fa-edit edit-icon' title='Edit'></i>",
                    cellClick: (e, cell) => {
                        this.handleEditClick(cell.getRow().getData());
                    }
                });
            }

            if (hasDeletePermission) {
                columns.push({
                    title: "",
                    field: "phone",
                    width: "2%",
                    headerSort: false,
                    formatter: function(cell) {
                        return "<i class='fa fa-regular fa-trash delete-icon' title='Delete'></i>";
                    },
                    
                    cellClick: (e, cell) => {
                        this.rowToDelete = cell.getRow().getData();
                        this.showDeleteModal = true;
                    }
                });
            }*/
            const canEdit   = hasEditPermission;
            const canDelete = hasDeletePermission;
              
            if (canEdit || canDelete) {
                columns.push({
                    title: '',
                    field: 'actions',
                    hozAlign: 'center',
                    headerSort: false,
                    width: canEdit && canDelete ? 80 : 40, // adjust width if only one icon
                    formatter: () => {
                      let html = '';
                      if (canEdit) {
                        html += `<i class="fa fa-regular fa-edit edit-icon" title="Edit" style="padding-right: 0.5rem;"></i>`;
                      }
                      if (canDelete) {
                        html += `<i class="fa fa-regular fa-trash delete-icon" title="Delete"></i>`;
                      }
                      return html;
                    },
                    cellClick: (e, cell) => {
                      e.stopPropagation();
                      const rowData = cell.getRow().getData();
                      if (canEdit && e.target.classList.contains('edit-icon')) {
                        this.handleEditClick(rowData);
                      } else if (canDelete && e.target.classList.contains('delete-icon')) {
                        this.rowToDelete     = rowData;
                        this.showDeleteModal = true;
                      }
                    }
                  });
            }
           
              

            console.log('Columns : ' + JSON.stringify(columns));

    
            try{
            this.table = new Tabulator(component, {
                height:"100%",
                layout:"fitColumns",
                resizableColumns:true,
                selectable:false,
                data:this.renewalConfigurationData,
                pagination:"local",
                paginationSize:25,
                responsiveLayout:"collapse",
                columns:columns,
            });
            } catch(err) {
                console.log(err);
            }
            console.log('Record ID : ' + this.recordId);
            this.isSpinner = false;
            this.spinnerText = '';
        }
    }
    
    handleAdd()
    {
        this.actionText = 'New Renewal Configuration';
        this.showModalUI = true;        
        this.renewalRecordId = undefined;
        this.errorMessage = '';
        this.submitDisabled = false;

        this.showDefaultInstruction= true; //as default Instruction Type is Automatic 

    }

    hideModal()
    {
        this.showModalUI = false;
    }

    validateFields()
    {
       this.template.querySelectorAll('.RenewalConfiguration').forEach(element => {
           element.reportValidity();
       });
    }

    async handleSuccess()
    {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Renewal Configuration saved successfully',
                variant: 'success'
            })
        );
        // this.refreshData();
       // this.dispatchEvent(new RefreshEvent());
        this.actionText = '';
        this.errorMessage = '';
        this.showModalUI = false;
        this.renewalRecordId= undefined;

        await refreshApex(this._wiredRenewalConfigs);
    }

    handleSubmit(event){
        event.preventDefault();       // Stop the form from Submission to perform custom validations
        const fields = event.detail.fields;       
        console.log(JSON.stringify(fields));  
        console.log ('Renewal Record ID : ' + this.renewalRecordId);      
        if(this.renewalRecordId == undefined || this.renewalRecordId.length == 0)
        {
            let activeConfiguration = this.renewalConfigurationData.find(x=>x.fields.SymphonyLF__Asset_Type__c.displayValue == fields.SymphonyLF__Asset_Type__c && x.fields.SymphonyLF__Is_Active__c.value == true)
            if(activeConfiguration != null)
            {
                this.errorMessage = 'An Active Renewal Configuration already exists with the same Asset Type. You cannot have multiple Active Renewal Configurations for the same Asset Type.';
            }
            else 
            {
                this.errorMessage = '';
                fields.SymphonyLF__Client__c = this.recordId;
                // fields.SymphonyLF__Is_Active__c = true;
                let defaultBillingCurrency = (this.client.data['fields']['SymphonyLF__Default_Billing_Currency__r']['value'] != null) ?
                this.client.data['fields']['SymphonyLF__Default_Billing_Currency__r']['value']['id'] : null;
                if(defaultBillingCurrency != null)
                    fields.SymphonyLF__Default_Billing_Currency__c = defaultBillingCurrency;   
                this.submitFields(null,fields);             
            }
        }
        else 
        {
            if(fields.SymphonyLF__Is_Active__c)
            {

                let configurationRecord = this.renewalConfigurationData.find(x=>x.fields.SymphonyLF__Asset_Type__c.displayValue == fields.SymphonyLF__Asset_Type__c && x.fields.SymphonyLF__Is_Active__c.value == true && x.id != this.renewalRecordId)
                if(configurationRecord != null)
                {
                    this.errorMessage = 'An Active Renewal Configuration already exists with the same Asset Type. You cannot have multiple Active Renewal Configurations for the same Asset Type.';
                }
                else 
                {
                    this.submitFields(this.renewalRecordId,fields);
                }
            }
            else 
            {
                this.submitFields(this.renewalRecordId,fields);
            }
        }    
    }

    handleError(event) {
        // stop the framework from popping the global error dialog
        event.preventDefault();
    }
      

    submitFields(Id, fields)
    {
        try
        {
            if(Id != null)
                fields.Id = Id; 
            this.template.querySelector('.RenewalConfiguration').submit(fields); 
            this.dispatchEvent(new RefreshEvent());
        }
        catch(error)
        {
            console.log(error);
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An unexpected error occured while saving the Renewal Configuration record. Please contact your Administrator for further assistance.',
                    variant: 'error'
                })
            );
        }        
    }

    instructionTypeSelect(event){
        let instructionType = event.detail.value;
        if(instructionType == 'Automatic')
            this.showDefaultInstruction = true;
        else
            this.showDefaultInstruction = false;
    }


    hideDeleteModal() {
        this.showDeleteModal = false;
        this.rowToDelete = undefined;
    }
    
    handleConfirmDelete() {
        deleteRecord(this.rowToDelete.id)
            .then(async () => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Deleted',
                    message: 'Record deleted successfully',
                    variant: 'success'
                })
                );
                this.hideDeleteModal();
                
                await refreshApex(this._wiredRenewalConfigs);
            })
            .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Delete failed',
                    message: error.body?.message || error.message,
                    variant: 'error'
                }));
            });
    }

    handleEditClick(rowData) {
        this.renewalRecordId   = rowData.id;      
        this.actionText        = 'Edit Renewal Configuration';
        this.showDefaultInstruction =
           rowData.fields.SymphonyLF__Instruction_Type__c.value === 'Automatic';
        this.errorMessage      = '';
        this.submitDisabled    = false;
        this.showModalUI       = true;
    }

    get isEdit() {
        return !!this.renewalRecordId;
    }

    get today() {
        const dt = new Date();
        const yyyy = dt.getFullYear();
        const mm   = String(dt.getMonth() + 1).padStart(2, '0');
        const dd   = String(dt.getDate()).padStart(2, '0');
        return `${yyyy}-${mm}-${dd}`;
    }      
      
}