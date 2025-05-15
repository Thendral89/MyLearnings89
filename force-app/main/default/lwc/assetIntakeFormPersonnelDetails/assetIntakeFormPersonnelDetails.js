import { LightningElement, api, track, wire } from 'lwc';
import getUserLocale from "@salesforce/apex/mvLawfirmUtilities.getUserLocale";
import getUserTimezoneOffset from "@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FA from "@salesforce/resourceUrl/FA";
import ASSET_INTAKE_PERSONNEL_OBJECT from "@salesforce/schema/Asset_Intake_Personnel__c";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getClientEngagementModels from '@salesforce/apex/assetIntakeUtilities.getClientEngagementModels';
import cascadeDeltasToJurisdictions from '@salesforce/apex/assetIntakeUtilities.cascadeDeltasToJurisdictions';

import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord
} from "lightning/uiRecordApi";
import {
    closeTab,
    IsConsoleNavigation,
    getFocusedTabInfo
} from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';

const PAGINATOR_DEFAULT_SIZE = 10;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100];
const PERSON_RECORD_TYPE_INTERNAL = 'Internal';
const PERSON_RECORD_TYPE_EXTERNAL = 'External';

export default class AssetIntakeFormPersonnelDetails extends NavigationMixin(LightningElement) {
    @api clientId;
    @api assetIntakeId;
    @api isNewFamily;
    @track personnelData = [];
    @track availablePersonnel = [];
    @track isRenderedCallBackInitialized = false;
    @track selectedEngagementDetails = [];
    @track assetIntakePersonnelData;
    @track assetIntakePersonnelId;
    @track draftRecordsExists = false;
    contactRecordId;
     @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        console.log('basic details tabId-->'+tabId);
        await closeTab(tabId);
    }

    userlocale;
    timezone;
    @wire(getUserTimezoneOffset)
    wiredTimezone({ error, data }) {
        if (data) {
            console.log("Time zone received BB", data);
            this.timezone = data; // Example: "America/New_York"
        }
    }

    currentFeatureSettings = {
        defaultPaginationSize: PAGINATOR_DEFAULT_SIZE,
        paginationSizeValues: PAGINATOR_SIZE_SELECTOR,
    };

    @wire(getUserLocale)
    wiredUserLocale({ error, data }) {
        if (data) {
            console.log("User Locale received BB", data);
            this.userlocale = data.replace("_", "-");
        }
    }

    @wire(getRecordCreateDefaults, { objectApiName: ASSET_INTAKE_PERSONNEL_OBJECT })
    assetIntakePersonnelDefaults;

    get recordInputForCreate() {
        if (!this.assetIntakePersonnelDefaults.data) {
            return undefined;
        }

        const assetIntakeObjectInfo =
            this.assetIntakePersonnelDefaults.data.objectInfos[
            ASSET_INTAKE_PERSONNEL_OBJECT.objectApiName
            ];
        const recordDefaults = this.assetIntakePersonnelDefaults.data.record;
        const recordInput = generateRecordInputForCreate(
            recordDefaults,
            assetIntakeObjectInfo
        );
        console.log("Record Input : " + JSON.stringify(recordInput));
        return recordInput;
    }

    get errors() {
        console.log("Error in Asset Intake Defaults");
        return this.assetIntakePersonnelDefaults.error;
    }

    connectedCallback() {
        if (this.clientId) {
            this.fetchClientEngagementModels();
        }
    }

    contactRecordTypeFormatting(cell){
        try{
            const contactRecordType = cell.getRow().getData().contactRecordType;
            console.log('Contact Record Type ' + cell.getRow().getData().contactRecordType);
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

     isFirstTime = true;
    fetchClientEngagementModels() {
        console.log ('Is New Family :' + this.isNewFamily);
        getClientEngagementModels({ recordId: this.clientId, assetIntakeFormId: this.assetIntakeId, createDefaultEngagementModels:this.isNewFamily  })
            .then((response) => {
                try {
                    console.log('response CEM:', JSON.stringify(response));
                    this.availablePersonnel = response;

                    this.contactRecordIds = [];
                        response.forEach(item => {
                        if (item.contactRecordId) {
                        this.contactRecordIds.push(item.contactRecordId);
                        }
                    });
                    console.log('All Contact Record IDs:', this.contactRecordIds);

                    this.prepareColumns();
                    this.draftRecordsExists = true;

                    if(! this.isFirstTime){
                        this.updateTableData( this.availablePersonnel );
                    }else{
                        this.isFirstTime = false;
                    }
                } catch (err) {
                    console.error('Error processing response:', err);
                }
            })
            .catch((error) => {
                console.error('Server Error:', error);
                console.error( JSON.stringify(error) );
                this.showToast('Error fetching engagement models from the server.');
            });
    }

    updateTableData(data) {
        try {
            const tableElement = this.template.querySelector('.lwcMvDataTable');
            if (tableElement) {
                tableElement.updateTableData(data);
            }

        } catch (err) {
            alert('JS Error ::  :: updateTableData')
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
                    console.log('Successfully loaded styles');
                });
        } catch (err) {
            console.error('Error in Rendered Call Back :  ' + err)
        }
    }

    async handleCheckboxClick(event, cell) {
        try{
        // Stop propagation to avoid triggering other cell events
        event.stopPropagation();

        const rowData = cell.getRow().getData();
        const isSelected = rowData.isSelected;
        const recordId = rowData.recordId;
        const personnelId = rowData.contactRecordId;
        const type = rowData.type;
        console.log('Row Data : ' + JSON.stringify(rowData));

        const checkbox = event.target;

        console.log('checkbox:', JSON.stringify(checkbox));
        console.log('checkbox.checked:', checkbox.checked );
        console.log('isSelected ', isSelected);
        if (!isSelected) {

            const assetIntakePersonnelObjectInfo =
                this.assetIntakePersonnelDefaults.data.objectInfos[
                ASSET_INTAKE_PERSONNEL_OBJECT.objectApiName
                ];
            const recordDefaults = this.assetIntakePersonnelDefaults.data.record;
            this.assetIntakePersonnelData = generateRecordInputForCreate(
                recordDefaults,
                assetIntakePersonnelObjectInfo
            );

            console.log('Asset Intake Personnel Data : ' + JSON.stringify(this.assetIntakePersonnelData));
            console.log('Asset Intake ID : ' + this.assetIntakeId);
            console.log('Personnel ID : ' + personnelId);
            this.assetIntakePersonnelData.fields["Asset_Intake_Form__c"] = this.assetIntakeId;
            this.assetIntakePersonnelData.fields["Personnel__c"] = personnelId;
            this.assetIntakePersonnelData.fields["Client_Engagement_Model__c"] = recordId;
            this.assetIntakePersonnelData.fields["Type__c"] = type;


            console.log(
                "Asset Intake Personnel Data : " + JSON.stringify(this.assetIntakePersonnelData)
            );
            const fields = this.assetIntakePersonnelData.fields;
            const recordInput = {
                apiName: ASSET_INTAKE_PERSONNEL_OBJECT.objectApiName,
                fields
            };
                // Invoke createRecord
                
                const assetIntakePersonnelRecord = await createRecord(recordInput);
                console.log('Asset Intake Personnel Record : ' + JSON.stringify(assetIntakePersonnelRecord));
                const assetIntakePersonnelId = assetIntakePersonnelRecord.id;
                rowData.assetIntakePersonnelRecordId = assetIntakePersonnelId;
                let deltaIdsCreated = this.deltaIdsCreated;
                deltaIdsCreated[assetIntakePersonnelId] = assetIntakePersonnelId;
                this.deltaIdsCreated = deltaIdsCreated;
                console.log(
                    "Success fully created record with Personnel ID: " + this.assetIntakePersonnelId
                );
                rowData.isSelected = true;
        } else {
            console.log('checkbox unchecked');
            const assetIntakePersonnelId = rowData.assetIntakePersonnelRecordId;
            console.log('Asset Intake Personnel ID to Delete : ' + assetIntakePersonnelId);
            await deleteRecord(assetIntakePersonnelId);
            let deltaIdsCreated = this.deltaIdsCreated;
            delete deltaIdsCreated[assetIntakePersonnelId];
            rowData.assetIntakePersonnelRecordId = null;
            this.deltaIdsCreated = deltaIdsCreated;
            console.log("Successfully deleted record with Asset Intake Personnel ID: " + assetIntakePersonnelId);
            rowData.isSelected = false;
        }

        this.fetchClientEngagementModels();
    }catch(err){
        alert('JS Error :: assetIntakeFormPersonnelDetails :: handleCheckboxClick');
        this.handleAllErrorTypes(err);
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

     serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
           // ...error
        });
    }

    prepareColumns() {
        try {
            let columns = [
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
                    title: "Symphony ID",
                    field: "symphonyId",
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
                },
                {
                    title: "Type",
                    headerFilter: true,
                    field:"type", formatterParams: {
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
                    title: "Name",
                    headerFilter: true,
                    field: "contactName",
                    type: "recordlink",
                    formatterParams: {
                        recordIdField: "contactRecordId",
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
                    title: "Email",
                    headerFilter: true,
                    field: "email",
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
                },
                {
                    title: "Is Defaulted?",
                    headerFilter: false,
                    field: "isDefault",
                    formatter: (cell, formatterParams) => {
                        var isDefaulted = cell.getRow().getData().isDefault;

                        if (isDefaulted)
                                return "<span class='greentag' style='font-weight:bold;'>Default</span>";
                            else
                                return "<span style='font-weight:bold;text-decoration:line-through'></span>";
        
        
                    }
                }
            ];

            this.draftColumns = columns;

        } catch (err) {
            console.error(this.serializeError(err));
        }
    }

    handleBack() {
        console.log('Handle Back');
          this.dispatchEvent(new CustomEvent('back', {
            detail: {
                assetIntakeId: this.assetIntakeId
            }, bubbles: true, composed: true
        }));
    }

   handleReset() {
        this.closeTab();
        this.navigateToCCdashboard();
    }

     navigateToCCdashboard() {
        this[NavigationMixin.Navigate]({
        type: 'standard__navItemPage',
        attributes: {
            apiName: 'Conflict_Check_Dashboard'
        }
    });
    }

    isSaving = false;
    async handleSaveDraft() {
        this.isSaving = true;
        await this.cascadeDeltasToJurisdictions();

        let selectedRecords = this.availablePersonnel.filter(record => record.isSelected != false);
        console.log('Selected Personnel Count : ' + selectedRecords.length);

        if (selectedRecords.length <= 0) {
            this.showToast('Error', 'error', 'You must select atleast 1 Personnel to proceed further.');
            this.isSaving = false;
        }
        else {

            const fields = {};
            fields['Id'] = this.assetIntakeId;
            fields['Current_Page__c'] = 'Applicants';
            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    console.log('Successfully updated the page to Applicants');
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    console.log('Failed to update the page to Applicants');
                });
             this.dispatchEvent(new CustomEvent('next', {
                detail: {
                    assetIntakeId: this.assetIntakeId
                }, bubbles: true, composed: true
            }));
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

    deltaIdsCreated = {};
    cascadeDeltasToJurisdictions(){
       try{
           const promise = cascadeDeltasToJurisdictions({
            "assetIntakeId" : this.assetIntakeId,
            "deltaIdsCreated" : Object.keys( this.deltaIdsCreated ),
            "section" : "Asset_Intake_Personnel__c" 
           });

           promise.then( response => {
               try{
                   
               }catch(err){
                   alert('JS Error in Server callback ::  :: cascadeDeltasToJurisdictions');
               }
           });

           promise.catch( error => {
               alert('Server Error ::  :: cascadeDeltasToJurisdictions :: apexMethod => cascadeDeltasToJurisdictions');
               console.error(JSON.stringify(error));
           });

           return promise;
       }catch(err){
           alert('JS Error ::  :: cascadeDeltasToJurisdictions')
           console.error(err)
           console.error(this.serializeError(err));
       }
    }

}