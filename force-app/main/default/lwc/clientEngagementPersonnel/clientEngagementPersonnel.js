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
    getFocusedTabInfo,
    openSubtab,
    EnclosingTabId,
    getTabInfo,
    openTab
} from 'lightning/platformWorkspaceApi';

/* Check for User Permissions */
import hasAddPermission from '@salesforce/customPermission/CEM_Add';
import hasEditPermission from '@salesforce/customPermission/CEM_Edit';
import hasDeletePermission from '@salesforce/customPermission/CEM_Delete';
import hasViewPermission from '@salesforce/customPermission/CEM_View';

import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';

import ClientEngagementPersonnelEditModalHeaderText from '@salesforce/label/c.ClientEngagementPersonnelEditModalHeader';
import ClientEngagementPersonnelEditModalAnnouncementText from '@salesforce/label/c.ClientEngagementPersonnelEditModalAnnouncement';
import ClientEngagementPersonneldeleteModalHeaderText from '@salesforce/label/c.ClientEngagementPersonneldeleteModalHeader';
import ClientEngagementPersonneldeleteModalAnnouncementText from '@salesforce/label/c.ClientEngagementPersonneldeleteModalAnnouncement';

import {
    registerRefreshHandler,
    unregisterRefreshHandler
} from 'lightning/refresh';


export default class ClientEngagementPersonnel extends LightningElement {
    
    // Make a Component Aware of Its Record Context
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_object_context
    @api recordId;

    /* Common Variables */
    isSpinner = false; 
    spinnerText = '';
    isRenderedCallBackInitialized = false;
    @track baseURL;
    
    /* Variable to control Add /Edit/Delete */
    clientPersonnelId = '';
    showModalUI = false;
    actionText = '';    
    submitDisabled= false;
    errorMessage = '';
    refreshHandlerID;
    table;
    @track rowToDelete;           
    showDeleteModal = false;
    deleteTable;

    /* Variable to hold Client Personnel Data */
    clientPersonnelData = [];
    _clientPersonnelData; // Use only for Refresh

    wiredClientPersonnelData;

    clientIdCondition = '';

    @track assignedTo = '';

    @track isSubmitted = false;

    memsWireResult;
    rowToDeleteId;

    showEditModal = false;
    editTable;

    @track cemClientId;

    @track editModalHeader = ClientEngagementPersonnelEditModalHeaderText;
    @track editModalAnnouncement = ClientEngagementPersonnelEditModalAnnouncementText;

    @track deleteModalHeader= ClientEngagementPersonneldeleteModalHeaderText; 
    @track deleteModalAnnouncement=ClientEngagementPersonneldeleteModalAnnouncementText;

    
    @wire(IsConsoleNavigation) isConsoleNavigation; 

    @wire(EnclosingTabId) enclosingTabId;
 

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'SymphonyLF__Client_Engagement_Models__r', // custom Object(Child to Parent)
        fields: [ 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Applicable_to_all_jurisdiction__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Client__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__IP_Matters__c'
                , 'SymphonyLF__Client_Engagement_Model__c.Is_Active__c'
                , 'SymphonyLF__Client_Engagement_Model__c.Is_Default__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Jurisdiction__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Jurisdiction__r.Name'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Office_Agent__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Person__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Person__r.Name'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Person__r.RecordType.Name'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Person__r.SymphonyLF__Email__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Person__r.SymphonyLF__Phone_Number__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Practice_Area__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Type__c'
                , 'SymphonyLF__Client_Engagement_Model__c.SymphonyLF__Team__c'
                , 'SymphonyLF__Client_Engagement_Model__c.Sequence__c'
                ],
     })
    wiredclientPersonnelListInfo(result) {
        this.wiredClientPersonnelData = result;
        const { data, error } = result;
        if (data) {
            // keep clone for display
            this.clientPersonnelData = JSON.parse(JSON.stringify(data.records));
            console.log('clientPersonnelData: ' , JSON.stringify(this.clientPersonnelData));
            // if the table already exists, just replace its data
            if (this.table) {
                this.table.replaceData(this.clientPersonnelData);
            }
        }else if (error) {
            console.error('clientPersonnelList Error : ', error);           
            this.clientPersonnelData = undefined;
        }
    }

    @wire(getRelatedListRecords, {
      parentRecordId: '$rowToDeleteId',
      relatedListId:  'Matter_Engagement_Model__r',
      fields: [
        'SymphonyLF__Matter_Engagement_Model__c.Id',
        'SymphonyLF__Matter_Engagement_Model__c.Is_Active__c'
      ]
    })
    wiredMemList(result) {
      this.wiredMemResult = result;
      const { data, error } = result;
      if (data) {
        this.memsList = data.records.map(r => ({
          id:    r.fields.Id.value,
          active: r.fields.Is_Active__c.value
        }));
        console.log('this.memsList:', JSON.stringify(this.memsList));
      } else if (error) {
        console.error('Failed to load MEMs:', error);
        this.memsList = [];
      }
  }
  


    get hasAddAccess() {
        return hasAddPermission;
    }

    get hasViewAccess() {
        return hasViewPermission;
    }

    refreshHandler() {
       return refreshApex(this._clientPersonnelData);
    }

    connectedCallback() {
        // if the component runs in an org with Lightning Locker instead of Lightning Web Security (LWS), use
        // this.refreshContainerID = registerRefreshHandler(this.template.host, this.refreshHandler.bind(this));
        this.refreshHandlerID = registerRefreshHandler(
            this,
            this.refreshHandler
        );

        this.clientIdCondition = `
            Id NOT IN (SELECT Person__c FROM Access_Restriction__c WHERE Client__c = '${this.recordId}')
            AND
            RecordType.Name IN ('Internal','External')
            `;
  
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
                        this.initializeClientPersonnel();
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

    handleEditClick(rowData) {

        this.editRowId = rowData.id; 
        this.rowToDelete = rowData;  
        this.showEditModal = true;  
        requestAnimationFrame(() => this.initializeEditDetailTable());
    }
      
    initializeEditDetailTable() {
        
        if (this.editTable) {
          this.editTable.destroy();
        }
      
        const container = this.template.querySelector('[data-id="editDetailTable"]');
        if (!container || !this.rowToDelete) return;
      
        const f = this.rowToDelete.fields;
        const personRecType = f.SymphonyLF__Person__r.value
          .fields.RecordType.displayValue;
        
        const allJur = f.SymphonyLF__Applicable_to_all_jurisdiction__c.value;
        const jurValue = allJur ? 'All' : f.SymphonyLF__Jurisdiction__r.displayValue;
      
        
        const detailData = [
          { label: 'Type',        value: f.SymphonyLF__Type__c.displayValue,                       editable: false, recordType: personRecType },
          { label: 'Name',        value: f.SymphonyLF__Person__r.displayValue,                    editable: false },
          { label: 'IP Matters',  value: f.SymphonyLF__IP_Matters__c.displayValue,               editable: false },
          { label: 'Jurisdiction', value: jurValue,                                             editable: false },
          { label: 'Email',       value: f.SymphonyLF__Person__r.value.fields.SymphonyLF__Email__c.value,     editable: false },
          { label: 'Phone',       value: f.SymphonyLF__Person__r.value.fields.SymphonyLF__Phone_Number__c.value, editable: false },
          { label: 'Active',      value: f.Is_Active__c.value,                                  editable: true  },
          { label: 'Default',     value: f.Is_Default__c.value,                                 editable: true  }
        ];
      
        
        this.editTable = new Tabulator(container, {
          data: detailData,
          layout: 'fitColumns',
          headerVisible: false,
          columns: [
            
            {
              field: 'label',
              width: 150,
              headerSort: false,
              formatter: cell => {
                cell.getElement().style.backgroundColor = '#f3f2f2';
                return cell.getValue();
              }
            },
            {
              field: 'value',
              headerSort: false,
              formatter: (cell) => {
                const { label, value, editable, recordType } = cell.getRow().getData();
            
                if (label === 'Type') {
                  return recordType === 'Internal'
                    ? `<span class="greentag">${value}</span>`
                    : `<span class="greytag">${value}</span>`;
                }
                if (!editable) {
                  return value;
                }
            
                const cb = document.createElement('input');
                cb.type    = 'checkbox';
                cb.checked = !!value;
                cb.style.transform = 'scale(1.2)';
                cb.style.cursor    = 'pointer';
            
                cb.addEventListener('change', (e) => {
                  const row = cell.getRow();
                  row.update({ value: e.target.checked });
                });
            
                return cb;
              }
            }     
              
              
          ]
        });
    }
      
      
    async handleSaveEdit() {
        
        // const rows = this.editTable.getData();
        // console.log('rows:', JSON.stringify(rows));
        // const upd = {};
        // rows.forEach(r => {
        //   if (r.label === 'Active')  upd.Is_Active__c  = r.value;
        //   if (r.label === 'Default') upd.Is_Default__c = r.value;
        // });
      
        const rows = this.editTable.getData();

        const activeRow  = rows.find(r => r.label === 'Active');
        const defaultRow = rows.find(r => r.label === 'Default');
      
        const isActive  = !!activeRow.value;
        let   isDefault = !!defaultRow.value;
      
        // if Active is false, Default must also be false
        if (!isActive) {
          isDefault = false;
        }
      
        const upd = {
          Id:                this.editRowId,
          Is_Active__c:      isActive,
          Is_Default__c:     isDefault
        };
            
      
        try {
          await updateRecord({ fields: upd });
          this.dispatchEvent(new ShowToastEvent({
            title:   'Success',
            message: 'Personnel updated.',
            variant: 'success'
          }));
          this.showEditModal = false;
          await refreshApex(this.wiredClientPersonnelData);
        } catch (error) {
          this.dispatchEvent(new ShowToastEvent({
            title:   'Update Failed',
            message: error.body?.message || error.message,
            variant: 'error'
          }));
        }
    }

    handleCancelEdit() {
      this.showEditModal = false;
      if (this.editTable) { this.editTable.destroy(); this.editTable = null; }
    }
      
    
    handleAdd()
    {
        this.actionText = 'Add Personnel';
        this.showModalUI = true;        
        this.clientPersonnelId = undefined;
        this.errorMessage = '';
        this.assignedTo = '';
        this.submitDisabled = false;
        this.isSubmitted=false;

    }

    hideModal()
    {
        this.showModalUI = false;
        this.assignedTo = '';
        this.isSubmitted=false;
    }


    initializeClientPersonnel() {
        if(hasViewPermission) {
            this.isSpinner = true;
            this.spinnerText = 'Please wait while we are fetching the Client Personnel data ... ';
            let component = this.template.querySelector('[data-id="clientPersonnelTable"]');
            console.log('In Initialize Client Personnel Data');
            let sfdcURL = this.baseURL;
            let columns = [
                            {title:"Type", field:"fields.SymphonyLF__Type__c.displayValue", headerFilter:true , formatter:function(cell, formatterParams){            
                                    var value = cell.getValue();
                                    const rowData = cell.getRow().getData();
                                    console.log ('Row Data : ' + JSON.stringify(rowData));
                                    if(rowData.fields.SymphonyLF__Person__r.value.fields.RecordType.displayValue === 'Internal' )
                                        return "<span class='greentag'>" + value + "</span>";
                                    
                                    return "<span class='greytag'>" + value + "</span>";
                                } 
                            },   
                            {
                              title: 'Name',
                              field: 'fields.SymphonyLF__Person__r.displayValue',
                              headerFilter: true,
                              formatter: cell => {
                                const row       = cell.getRow().getData();
                                const personId  = row.fields.SymphonyLF__Person__c.value;
                                const label     = cell.getValue() || '';
                                const linkEl    = document.createElement('a');
                        
                                linkEl.textContent      = label;
                                linkEl.style.fontWeight = 'bold';
                                linkEl.href             = 'javascript:void(0);';
                                linkEl.addEventListener('click', e => {
                                  e.preventDefault();
                                  this.findEnclosingTabAndOpenSubtab(
                                    'standard__recordPage',
                                    'SymphonyLF__Person__c',
                                    personId,
                                    'view'
                                  );
                                });
                        
                                console.log('linkEl:', linkEl);
                                return linkEl;
                              }
                            },
                                           
                            {title:"IP Matters",  field:"fields.SymphonyLF__IP_Matters__c.displayValue", headerFilter:true},
                            //{title:"Jurisdiction",  field:"fields.SymphonyLF__Jurisdiction__r.displayValue", headerFilter:true},
                            {  
                              title: "Jurisdiction",  
                              field: "fields.SymphonyLF__Jurisdiction__r.displayValue",
                              headerFilter: true,
                              formatter: cell => {
                                const row = cell.getRow().getData();
                                const allFlag = row.fields.SymphonyLF__Applicable_to_all_jurisdiction__c.value;
                                if (allFlag) {
                                  return 'All';
                                }
                                return cell.getValue() || '';
                              }
                            },
                            {title:"Email",  field:"fields.SymphonyLF__Person__r.value.fields.SymphonyLF__Email__c.value", headerFilter:true},
                            {title:"Phone",  field:"fields.SymphonyLF__Person__r.value.fields.SymphonyLF__Phone_Number__c.value", headerFilter:true},
                            {title:"Active",  field:"fields.Is_Active__c.value", formatter:function(cell, formatterParams){            
                                var value = cell.getValue();
                                if(value )
                                    return "<span class='greentag'>Active</span>";
                                else 
                                    return "<span class='redtag'>Inactive</span>";
                            }},
                            {
                              title: 'Default',
                              field: 'fields.Is_Default__c.value',
                              headerFilter: true,
                              formatter: cell => {
                                return cell.getValue()
                                  ? `<span class="greentag">Default</span>`
                                  : '';
                              }
                            },
                        ];
            console.log('Delete Permission : ' + hasDeletePermission);

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
                        this.handleDeleteClick(rowData);
                      }
                    }
                  });
            }

            console.log('Columns : ' + JSON.stringify(columns));

    
            try{
              this.clientPersonnelData.sort((a, b) => {
                    // Active DESC
                    const aAct = a.fields.Is_Active__c.value ? 1 : 0;
                    const bAct = b.fields.Is_Active__c.value ? 1 : 0;
                    if (aAct !== bAct) return bAct - aAct;
                
                    // Default DESC
                    const aDef = a.fields.Is_Default__c.value ? 1 : 0;
                    const bDef = b.fields.Is_Default__c.value ? 1 : 0;
                    if (aDef !== bDef) return bDef - aDef;
                
                    // Sequence ASC
                    const seqA = a.fields.Sequence__c.value || 0;
                    const seqB = b.fields.Sequence__c.value || 0;
                    if (seqA !== seqB) return seqA - seqB;
                
                    // Name A→Z
                    const nameA = a.fields.SymphonyLF__Person__r.displayValue.toLowerCase();
                    const nameB = b.fields.SymphonyLF__Person__r.displayValue.toLowerCase();
                    if (nameA < nameB) return -1;
                    if (nameA > nameB) return  1;
                    return 0;
                });

                // const sorts = [
                //   { column: "fields.Is_Active__c.value",                 dir: "desc" },
                //   { column: "fields.Is_Default__c.value",                dir: "desc" },
                //   { column: "fields.Sequence__c.value",                  dir: "asc"  },
                //   { column: "fields.SymphonyLF__Person__r.displayValue", dir: "asc"  },
                // ];

            this.table = new Tabulator(component, {
                height:"100%",
                layout:"fitColumns",
                resizableColumns:true,
                selectable:false,
                data:this.clientPersonnelData,
                // multiSort: true,              
                // initialSort: sorts,
                pagination:"local",
                paginationSize:25,
                responsiveLayout:"collapse",
                columns:columns,
              //   initialSort: [
              //     { column: "fields.Is_Active__c.value", dir: "desc" },
              //     { column: "fields.Is_Default__c.value", dir: "desc" },
              //     { column: "fields.Sequence__c.value", dir: "asc" },
              //     { column: "fields.SymphonyLF__Person__r.displayValue", dir: "asc" }
              // ]
            });
            this.table.setSort(sorts);
            } catch(err) {
                console.log(err);
            }
            console.log('Record ID : ' + this.recordId);
            this.isSpinner = false;
            this.spinnerText = '';
        }
    }

    get isEdit() {
        return !!this.clientPersonnelId;
    }

    hideDeleteModal() {
        this.showDeleteModal = false;
        this.rowToDelete = undefined;
        if (this.deleteTable) {
            this.deleteTable.destroy();
            this.deleteTable = null;
        }
    }
  
    
    

    handleDeleteClick(rowData) {
        this.rowToDelete = rowData;
        this.showDeleteModal = true;
        this.rowToDeleteId = rowData.id;
        console.log('rowToDelete::', JSON.stringify(this.rowToDelete));
        this.cemClientId = this.rowToDelete.fields.SymphonyLF__Client__c.value;
        console.log('this.rowToDeleteId:', this.rowToDeleteId);
        
        requestAnimationFrame(() => this.initializeDeleteDetailTable());
    }

    initializeDeleteDetailTable() {
        
        if (this.deleteTable) {
          this.deleteTable.destroy();
        }
      
        const container = this.template.querySelector('[data-id="deleteDetailTable"]');
        if (!container || !this.rowToDelete) return;
      
        
        const f = this.rowToDelete.fields;
        const personRecType = f.SymphonyLF__Person__r.value
          .fields.RecordType.displayValue;
        
        const allJur = f.SymphonyLF__Applicable_to_all_jurisdiction__c.value;
        const jurValue = allJur ? 'All' : f.SymphonyLF__Jurisdiction__r.displayValue;
      
        // build detail rows,
        const detailData = [
          {
            label: 'Type',
            value: f.SymphonyLF__Type__c.displayValue,
            recordType: personRecType
          },
          {
            label: 'Name',
            value: f.SymphonyLF__Person__r.displayValue,
            personId: f.SymphonyLF__Person__c.value
          },
          { label: 'IP Matters',   value: f.SymphonyLF__IP_Matters__c.displayValue },
          //{ label: 'Jurisdiction', value: f.SymphonyLF__Jurisdiction__r.displayValue },
          { label: 'Jurisdiction', value: jurValue },
          {
            label: 'Email',
            value: f.SymphonyLF__Person__r.value
              .fields.SymphonyLF__Email__c.value
          },
          {
            label: 'Phone',
            value: f.SymphonyLF__Person__r.value
              .fields.SymphonyLF__Phone_Number__c.value
          },
          { label: 'Active',  value: f.Is_Active__c.value ? 'Active' : 'Inactive' },
          { label: 'Default', value: f.Is_Default__c.value ? 'Yes' : 'No' }
        ];
      
        this.deleteTable = new Tabulator(container, {
          data: detailData,
          layout: 'fitColumns',
          headerVisible: false,
      
          columns: [
            {
              field: 'label',
              headerSort: false,
              width: 150,
              formatter: cell => {
                cell.getElement().style.backgroundColor = '#f3f2f2';
                return cell.getValue();
              }
            },
            {
              field: 'value',
              headerSort: false,
              formatter: cell => {
                const row = cell.getRow().getData();
                const val = cell.getValue();
      
                //type: green if Internal, grey otherwise
                if (row.label === 'Type') {
                  return row.recordType === 'Internal'
                    ? `<span class="greentag">${val}</span>`
                    : `<span class="greytag">${val}</span>`;
                }
      
                // Active: reuse greentag/redtag
                if (row.label === 'Active') {
                  return val === 'Active'
                    ? `<span class="greentag">Active</span>`
                    : `<span class="redtag">Inactive</span>`;
                }
                if (row.label === 'Default') {
                  return val === 'Yes'
                    ? `<span class="greentag">Default</span>`
                    : '';
                }
      
                return val;
              }
            }
          ]
        });
        

    }
      

    async handleConfirmDelete() {

        if (this.memsList.some(m => m.active)) {
            this.dispatchEvent(new ShowToastEvent({
              title:   'Validation Error',
              message: 'This Personnel is associated with Matters that are still active. Please deactivate them first.',
              variant: 'error'
            }));
            return;
        }
    
        // no active MEMs → proceed with delete
        try {
          await deleteRecord(this.rowToDeleteId);
          this.dispatchEvent(
            new ShowToastEvent({
              title:   'Deleted',
              message: 'Personnel deleted.',
              variant: 'success'
            })
          );
          this.hideDeleteModal();
          await refreshApex(this.wiredClientPersonnelData);
        } catch (err) {
          this.dispatchEvent(
            new ShowToastEvent({
              title:   'Delete failed',
              message: err.body?.message || err.message,
              variant: 'error'
            })
          );
        }
    }

    async handleSuccess()
    {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Personnel saved successfully',
                variant: 'success'
            })
        );
        this.actionText = '';
        this.errorMessage = '';
        this.showModalUI = false;
        this.clientPersonnelId= undefined;
        this.assignedTo = '';

        await refreshApex(this.wiredClientPersonnelData);
    }

    handleError(event) {
        // stop the framework from popping the global error dialog
        event.preventDefault();
        console.error('handleError:',JSON.stringify(event.detail));

        
        let detailMessage = event.detail.detail;

        if (!detailMessage && event.detail.output?.errors?.length) {
            detailMessage = event.detail.output.errors
                .map(err => err.message)
                .join(', ');
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Validation Error',
                message: detailMessage,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    
    handleAssignedToChange(event) {
        try {
            console.log('event.detail::', JSON.stringify(event.detail));
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


    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        console.log('fields=>', JSON.stringify(fields));

        console.log('this.assignedTo:', this.assignedTo);
    
        
        this.errorMessage = '';
        this.isSubmitted  = true;
    
      
        const duplicateErrors = this.getDuplicateError(fields);
        if (duplicateErrors.length) {
          duplicateErrors.forEach(msg => {
            this.dispatchEvent(
              new ShowToastEvent({
                title:   'Validation Error',
                message: msg,
                variant: 'error'
              })
            );
          });
         
          return;
        }
    
        
        if (this.assignedTo) {
          fields.SymphonyLF__Person__c = this.assignedTo;
        }
        this.submitFields(null, fields);
    }
  
    
    // getDuplicateError(fields) {
    //   // Common inputs
    //   const newPerson  = this.assignedTo;
    //   const newType    = fields.SymphonyLF__Type__c;
    //   const newJur     = fields.SymphonyLF__Jurisdiction__c;
    //   const newAllJur  = fields.SymphonyLF__Applicable_to_all_jurisdiction__c;
    //   const newMatters = (fields.SymphonyLF__IP_Matters__c || '')
    //     .split(';').map(m => m.trim()).filter(m => m);
    //   const newIPAll   = newMatters.includes('All');
    
    //   // Helper to compare two arrays as sets
    //   const sameSet = (a, b) =>
    //     a.length === b.length && a.every(x => b.includes(x));
    
    //   const errors = [];
    
    //   for (const rec of this.clientPersonnelData) {
    //     // Only consider same person & type, and skip the record we're editing
    //     if (rec.fields.SymphonyLF__Person__c.value !== newPerson) continue;
    //     if (rec.fields.SymphonyLF__Type__c.value   !== newType)   continue;
    //     if (this.clientPersonnelId && rec.id === this.clientPersonnelId) continue;
    
    //     // Extract existing-record values
    //     const recJur     = rec.fields.SymphonyLF__Jurisdiction__c.value;
    //     const recAllJur  = rec.fields.SymphonyLF__Applicable_to_all_jurisdiction__c.value;
    //     const recMatters = (rec.fields.SymphonyLF__IP_Matters__c.value || '')
    //       .split(';').map(m => m.trim()).filter(m => m);
    //     const recIPAll   = recMatters.includes('All');
    
    //     //Exact‐duplicate of a specific record
        
    //     if (
    //       !newIPAll && !recIPAll &&
    //       !newAllJur && !recAllJur &&
    //       newJur === recJur &&
    //       sameSet(newMatters, recMatters)
    //     ) {
    //       errors.push(
    //         'An active Engagement already exists for this person, Type, IP Matter and jurisdiction.'
    //       );
    //       continue;
    //     }
    
    //     // IP-Matters “All” vs specific (same jurisdiction only)
        
    //     //  New is “All” matters, existing is specific
    //     if (newIPAll && !recIPAll) {
    //       if (!newAllJur && newJur === recJur) {
    //         errors.push(
    //           'Cannot create an “All” IP Matters record because a specific IP Matters record already exists for this person, Type & jurisdiction.'
    //         );
    //       }
    //       continue;
    //     }
    //     //  Existing is “All” matters, new is specific
    //     if (!newIPAll && recIPAll) {
    //       if (!newAllJur && newJur === recJur) {
    //         errors.push(
    //           'Cannot create a specific IP Matters record because an “All” IP Matters record already exists for this person, Type & jurisdiction.'
    //         );
    //       }
    //       continue;
    //     }
    
    //     //Jurisdiction “All” vs specific (for overlapping IP Matters)
    //     //
    //     //  New is “All” jurisdictions, existing is specific
    //     if (newAllJur && !recAllJur) {
    //       if (recMatters.some(m => newMatters.includes(m))) {
    //         errors.push(
    //           'Cannot create an “All jurisdictions” record because a specific jurisdiction record already exists for this person, Type & IP Matter.'
    //         );
    //       }
    //       continue;
    //     }
    //     //  Existing is “All” jurisdictions, new is specific
    //     if (!newAllJur && recAllJur) {
    //       if (recMatters.some(m => newMatters.includes(m))) {
    //         errors.push(
    //           'Cannot create a jurisdiction-specific record because an “All jurisdictions” record already exists for this person, Type & IP Matter.'
    //         );
    //       }
    //       continue;
    //     }
    
    //     // Both are “All” jurisdictions (duplicate All-jurisdictions)
    //     //
    //     if (newAllJur && recAllJur) {
    //       if (recMatters.some(m => newMatters.includes(m))) {
    //         errors.push(
    //           'An “All jurisdictions” record already exists for this person, Type & IP Matter.'
    //         );
    //       }
    //       continue;
    //     }
        
    //   }
    
    //   return errors;
    // }    
    

    getDuplicateError(fields) {
      
      const newPerson  = this.assignedTo;
      const newType    = fields.SymphonyLF__Type__c;
      const newJur     = fields.SymphonyLF__Jurisdiction__c;
      const newAllJur  = fields.SymphonyLF__Applicable_to_all_jurisdiction__c;
      const newMatters = (fields.SymphonyLF__IP_Matters__c || '')
        .split(';').map(m => m.trim()).filter(m => m);
      const newIPAll   = newMatters.includes('All');
    
      const errors = [];
    
      for (const rec of this.clientPersonnelData) {
        // Only same person & type; skip the record we're editing
        if (rec.fields.SymphonyLF__Person__c.value !== newPerson) continue;
        if (rec.fields.SymphonyLF__Type__c.value   !== newType)   continue;
        if (this.clientPersonnelId && rec.id === this.clientPersonnelId) continue;
    
        // Extract existing-record values
        const recJur     = rec.fields.SymphonyLF__Jurisdiction__c.value;
        const recAllJur  = rec.fields.SymphonyLF__Applicable_to_all_jurisdiction__c.value;
        const recMatters = (rec.fields.SymphonyLF__IP_Matters__c.value || '')
          .split(';').map(m => m.trim()).filter(m => m);
        const recIPAll   = recMatters.includes('All');
    
        // If both are specific jurisdictions AND they differ → allow
        if (!recAllJur && !newAllJur && recJur !== newJur) {
          continue;
        }
        // If both are specific IP-Matters AND they have no overlap → allow
        if (!recIPAll && !newIPAll && recMatters.every(m => !newMatters.includes(m))) {
          continue;
        }
    
        // At this point, we have a conflict. Pick the right message:
        if (recIPAll && newIPAll) {
          errors.push(
            'Cannot create an “All” IP Matters record because one already exists for this person, Type & jurisdiction combination.'
          );
        } else if (recIPAll && !newIPAll) {
          errors.push(
            'Cannot create a specific IP Matters record because an “All” IP Matters record already exists for this person, Type & jurisdiction combination.'
          );
        } else if (!recIPAll && newIPAll) {
          errors.push(
            'Cannot create an “All” IP Matters record because a specific IP Matters record already exists for this person, Type & jurisdiction combination.'
          );
        } else if (recAllJur && newAllJur) {
          errors.push(
            'An “All jurisdictions” record already exists for this person, Type & IP Matter combination.'
          );
        } else if (recAllJur && !newAllJur) {
          errors.push(
            'Cannot create a jurisdiction-specific record because an “All jurisdictions” record already exists for this person, Type & IP Matter combination.'
          );
        } else if (!recAllJur && newAllJur) {
          errors.push(
            'Cannot create an “All jurisdictions” record because a jurisdiction-specific record already exists for this person, Type & IP Matter combination.'
          );
        } else {
          errors.push(
            'An active Engagement already exists for this person, Type, IP Matter and jurisdiction.'
          );
        }
    
        continue;
      }
    
      return errors;
    }
    
    
    

    validateFields()
    {
        this.isSubmitted = true;
       this.template.querySelectorAll('.ClientEngagementModel').forEach(element => {
           element.reportValidity();
       });
    }

    submitFields(Id, fields)
    {
        try
        {
            if(Id != null)
                fields.Id = Id; 
            this.template.querySelector('.ClientEngagementModel').submit(fields); 

            console.log('submitted');
        }
        catch(error)
        {
            console.log(error);
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An unexpected error occured while saving the Client Engagement Personnel record. Please contact your Administrator for further assistance.',
                    variant: 'error'
                })
            );
        }        
    }

    get showPersonError() {
        return this.isSubmitted && !this.assignedTo;
    }
    
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
          console.log('Error:', err);
      }

  }

}