import { LightningElement, track, api, wire } from "lwc";
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord,
    getPicklistValuesByRecordType,
} from "lightning/uiRecordApi";
import getDraftInventorRecords from "@salesforce/apex/assetIntakeUtilities.getInventors";
import cascadeDeltasToJurisdictions from '@salesforce/apex/assetIntakeUtilities.cascadeDeltasToJurisdictions';
import ASSET_INTAKE_INVENTOR_OBJECT from "@salesforce/schema/Asset_Intake_Inventor__c";
import ASSET_INTAKE_JURISDICTION_RELATIONS_OBJECT from "@salesforce/schema/Asset_Intake_Jurisdiction_Relations__c";
import ASSET_INTAKE_JURISDICTION_OBJECT from "@salesforce/schema/Asset_Intake_Jurisdiction__c";
import getUserLocale from "@salesforce/apex/mvLawfirmUtilities.getUserLocale";
import getUserTimezoneOffset from "@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import LightningModal from "lightning/modal";
import {
    closeTab,
    IsConsoleNavigation,
    getFocusedTabInfo
} from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';
import getCountryCodeByName from '@salesforce/apex/assetIntakeUtilities.getCountryCodeByName';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account'; 
import COUNTRY_CODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import STATE_CODE_FIELD from '@salesforce/schema/Account.BillingStateCode';

const PAGINATOR_DEFAULT_SIZE = 10;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100];

export default class AssetIntakeFormInventors extends NavigationMixin(LightningElement) {
    @api clientId;
    @api assetIntakeId;
    @track assetIntakeInventorId = "";
    assetIntakeInventorObject = ASSET_INTAKE_INVENTOR_OBJECT;
    assetIntakeJurisdictionObject = ASSET_INTAKE_JURISDICTION_OBJECT;
    assetIntakeJurisdictionRelationsObject =
        ASSET_INTAKE_JURISDICTION_RELATIONS_OBJECT;
    @track assetIntakeInventorDrafts = [];
    assetIntakeInventorData;
    addInventorModal = false;
    inventorName;
    existingInventorValue;
    draftColumns = [];
    userlocale;
    timezone;
    @track draftRecordsExists = false;
    @track isRenderedCallBackInitialized = false;
    @track primaryInventor = false;
    @track inventorCity = "";
    @track inventorStreet = "";
    @track inventorCountry = "";
    @track inventorPostalCode = "";
    @track inventorState;
    @track inventorCountryCode = "";
    customInnovatorLabel = "Innovator Name";
    @api populateClientAddress = false;

    // inventorAddress = {
    //     Address__Street__s: "",
    //     Address__City__s: "",
    //     Address__State__s: "",
    //     Address__PostalCode__s: "",
    //     Address__CountryCode__s: "",
    // };
    inventorAddress = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: '',
        countryCode: ''
    }

    countryOptions = [];
    stateOptions = [];
    defaultRecordTypeId;
    selectedCountry;

    @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        console.log('basic details tabId-->'+tabId);
        await closeTab(tabId);
    }

    get getProvinceOptions() {
        if(this.selectedCountry){
         return this.stateOptions[this.selectedCountry] || [];
        }else{
         return [];
        }
       
    }
    get getCountryOptions() {
        return this.countryOptions;
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: COUNTRY_CODE_FIELD })
    countryPicklistValues({ data, error }) {
        if (data) {
            this.countryOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: STATE_CODE_FIELD })
    statePicklistValues({ data, error }) {
       if (!data) {
            return;
        }
        const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));

        this.stateOptions = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state.validFor[0]];
            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
    }



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

    @wire(getRecordCreateDefaults, {
        objectApiName: ASSET_INTAKE_INVENTOR_OBJECT,
    })
    assetIntakeDefaults;

    @wire(getRecordCreateDefaults, {
        objectApiName: ASSET_INTAKE_JURISDICTION_OBJECT,
    })
    assetIntakeJurisdictionDefaults;

    @wire(getRecordCreateDefaults, {
        objectApiName: ASSET_INTAKE_JURISDICTION_RELATIONS_OBJECT,
    })
    assetIntakeJurisdictionRelationDefaults;

    @api addressData;

    // get street() {
    //     return this.addressData?.street || '';
    // }

    // get city() {
    //     return this.addressData?.city || '';
    // }

    // get state() {
    //     return this.addressData?.stateCode || '';
    // }

    // get postal() {
    //     return this.addressData?.postal || '';
    // }

    // get country() {
    //     return this.addressData?.street || '';
    // }


    handleCheckboxChange(event){
         this.primaryInventor = event.target.checked;
    }

    addressInputChange(event) {
        const address = this.template.querySelector("lightning-input-address");

        this.inventorAddress.street = event.detail.street;
        this.inventorAddress.city = event.detail.city;
        this.inventorAddress.postal = event.detail.postalCode;
        this.inventorAddress.state = event.detail.province;
        this.inventorAddress.country = event.detail.country;
        this.selectedCountry = event.detail.country;
       // this.getCountryCode(this.inventorAddress.country);

        console.log("Inventor Address : " + JSON.stringify(this.inventorAddress));
        console.log(this.inventorAddress);
    }

    // getCountryCode(countryName) {
    //     getCountryCodeByName({ countryName })
    //         .then((result) => {
    //             if (result) {
    //                 this.inventorAddress.countryCode = result.Country_Code__c;
    //                 console.log('Country Code:', this.applicantAddress.countryCode);
    //             }
    //         })
    //         .catch((error) => {
    //             console.error('Error retrieving country code:', error);
    //         });
    // }

    connectedCallback() {
        this.loadDraftRecords();
    }

    loadDraftRecords() {
        this.draftRecordsExists = false;
        getDraftInventorRecords({ assetIntakeFormId: this.assetIntakeId, "clientId": this.clientId }).then(
            (result) => {
                console.log("Result : " + JSON.stringify(result));
                this.assetIntakeInventorDrafts = result;
                console.log(
                    "Asset Intake Draft Records : " +
                    JSON.stringify(this.assetIntakeInventorDrafts)
                );
                this.prepareColumns();
                this.draftRecordsExists = true;
            }
        ).catch(err=>{
            alert('Server error :: getDraftInventorRecords');
            console.error(JSON.stringify(err));
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
                    title: "Draft ID",
                    field: "recordName",
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
                    title: "Innovator",
                    field: "inventorName",
                    type: "recordlink",
                    headerFilter: true,
                    formatterParams: {
                        recordIdField: "inventorId",
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
                    title: "Innovator Address",
                    field: "address",
                    headerFilter: true,
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
                    title: "Email Address",
                    field: "emailAddress",
                    headerFilter: true,
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
                    title: "Primary Innovator",
                    field: "primaryInventor",
                    align: "center",
                    width: "150",
                    resizable: false,
                    headerSort: false,
                    formatter: (cell) => {
                    const value = cell.getValue();
                    const rowData = cell.getData();
                    const isSelected = rowData.isSelected;

                    const toggleIcon = value ? 'fa-toggle-on' : 'fa-toggle-off';
                    const toggleColor = isSelected ? (value ? 'green' : 'gray') : 'lightgray';
                    const cursorStyle = isSelected ? 'pointer' : 'not-allowed';

                    return `
                        <div class="action-icons">
                            <i class="fa ${toggleIcon}" 
                                title="${isSelected ? 'Toggle Primary Innovator' : 'Select row to enable toggle'}"
                            style="cursor: ${cursorStyle}; font-size: 24px; color: ${toggleColor};"></i>
                        </div>`;
                    },
                        cellClick: (e, cell) => this.handlePrimaryInventorToggle(e, cell),
                        hozAlign: "center",
                        columnHeaderVertAlign: "middle",
                },
                {
                    title: "Sequence",
                    field: "sequence",
                    headerFilter: true,
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
                    title: "Phone Number",
                    field: "phoneNumber",
                    headerFilter: true,
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
                    title: "New/Existing",
                    field: "isExistingInventor",
                    headerFilter: true,
                    formatterParams: {
                        recordIdField: "recordId",
                        classList: [],
                        styleList: [
                            {
                                property: "font-weight",
                                value: "bold",
                            },
                        ],
                        classListFunction: this.inventorRecordTypeFormatting,
                    },
                },
            ];

            this.draftColumns = columns;
        } catch (err) {
            console.error(this.serializeError(err));
        }
    }

    async handlePrimaryInventorToggle(e, cell) {
        const rowData = cell.getData();
        const table = cell.getTable();

        if (!rowData.isSelected) return;

        const currentValue = cell.getValue();
        const newValue = !currentValue;

        if (newValue) {
            this.primaryInventor = rowData;

            // Unset all other rows
            table.getRows().forEach(row => {
                const data = row.getData();
                    if (data.recordId !== rowData.recordId && data.primaryInventor) {
                        data.primaryInventor = false;
                        row.update({ primaryInventor: false, sequence: null });
                    }
                });

            // Update selected row
            rowData.primaryInventor = true;
            cell.getRow().update({ primaryInventor: true, sequence: 1 });

        } else {
            this.primaryInventor = null;
            rowData.primaryInventor = false;
            cell.getRow().update({ primaryInventor: false, sequence: null });
        }

        // 🔁 Update Salesforce
        const fields = {
            Id: rowData.recordId,
            Primary_Inventor__c: rowData.primaryInventor
        };

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                console.log('Record updated successfully');
            })
            .catch((error) => {
                console.error('Failed to update the record', error);
            });
    }


    async handleCheckboxClick(event, cell) {
        try{
        // Stop propagation to avoid triggering other cell events
        event.stopPropagation();

        const rowData = cell.getRow().getData();
        const isSelected = rowData.isSelected;
        const checkbox = event.target;

        if (!isSelected) {
            const recordInput = {
                apiName: ASSET_INTAKE_INVENTOR_OBJECT.objectApiName,
                fields: {
                    "Asset_Intake_Form__c": this.assetIntakeId
                    ,"Person__c": rowData.inventorId
                }
            };

                // Invoke createRecord
                const assetIntakeInventorRecord = await createRecord(recordInput);
                const recordId = assetIntakeInventorRecord.id;
                let deltaIdsCreated = this.deltaIdsCreated;
                deltaIdsCreated[recordId] = recordId;
                this.deltaIdsCreated = deltaIdsCreated;
                console.log("Successfully created record with Asset Intake Inventor ID: " + recordId);
                rowData.recordId = recordId;

            rowData.isSelected = true;
        } else {
            const recordId = rowData.recordId;
            await deleteRecord(recordId);
            let deltaIdsCreated = this.deltaIdsCreated;
            delete deltaIdsCreated[recordId];
            this.deltaIdsCreated = deltaIdsCreated;
            console.log("Successfully deleted record with Asset Intake Inventor ID: " + recordId);
            rowData.recordId = null;
            rowData.isSelected = false;

        }
        this.loadDraftRecords();

    }catch(err){
        alert('JS Error :: assetIntakeFormInventors :: handleCheckboxClick');
        this.handleAllErrorTypes(err);
    }

    }

    inventorRecordTypeFormatting(cell) {
        try {
            const isExisting = cell.getRow().getData().isExistingInventor;
            console.log("Is Existing " + isExisting);
            if (isExisting === "Existing") {
                return ["greentag"];
            } else {
                return ["greytag"];
            }
        } catch (err) {
            alert("JS Error ::  :: inventorRecordTypeFormatting");
            console.error(err);
        }
    }

    async handleActionClick(event, cell) {
        console.log('inside handle action click event---->');
        // Stop propagation to avoid triggering other cell events
        event.stopPropagation();
        try {
            let target = event.target;
            let rowData = cell.getRow().getData();

            const draftInventorRecordId = rowData.recordId;
            await deleteRecord(draftInventorRecordId);
            console.log(
                "Successfully deleted record with Draft Inventor Record ID: " +
                draftInventorRecordId
            );
            this.draftRecordsExists = false;
            this.loadDraftRecords();
        } catch (err) {
            console.error(this.serializeError(err));
        }
    }

    get errors() {
        console.log("Error in Asset Intake Defaults");
        return this.assetIntakeDefaults.error;
    }

   handleAddInventor() {
    // If address data is available, populate the address fields
        this.primaryInventor = false;
        console.log('addressdata--->',this.addressData);
        if (this.addressData) {
            this.inventorAddress = {
                street: this.addressData.street,
                city: this.addressData.city,
                postal: this.addressData.postal,
                state: this.addressData.state,
                country: this.addressData.country
            };
            this.selectedCountry = this.addressData.country;
        }

        // Open the modal
        this.addInventorModal = true;
    }

    hideModalBox() {
        this.addInventorModal = false;
    }

    addNewInventor() {
        console.log("Clicked on Save Inventor");

        const inputFields = this.template.querySelectorAll('[data-id="addInventorRecordFormField"]');
            let isValid = true;
            const fields = {};

            inputFields.forEach(inputField => {
                if(! inputField.reportValidity()){
                    console.log('cm here')
                    isValid = false;
                }
                fields[inputField.fieldName] = inputField.value;
            });

            console.log('isValid ', isValid);

            if(! isValid){
                this.isLoading = false;
                return;
            }

        // const inputFields = this.template.querySelectorAll(
        //     '[data-id="addInventorRecordFormField"]'
        // );

        // const fields = {};

        // inputFields.forEach((inputField) => {
        //     fields[inputField.fieldName] = inputField.value;
        // });

       // fields["Address__c"] = this.inventorAddress;
        fields["Primary_Inventor__c"] = this.primaryInventor;
        fields["Address__Street__s"] = this.inventorAddress.street;
        fields["Address__City__s"] = this.inventorAddress.city;
        fields["Address__StateCode__s"] = this.inventorAddress.state;
        fields["Address__PostalCode__s"] =this.inventorAddress.postal;
       // fields["Address__CountryCode__s"] = this.inventorAddress.Address__CountryCode__s;
        fields["Address__CountryCode__s"] = this.inventorAddress.country;

        console.log("Inventor Data : " + JSON.stringify(fields));

        this.template
            .querySelector('[data-id="addInventorRecordForm"]')
            .submit(fields);
        this.hideModalBox();
        this.draftRecordsExists = false;
        this.primaryInventor = false;
    }

    handleAddInventorSuccess(event) {
        let recordId = event.detail.id;

        let deltaIdsCreated = this.deltaIdsCreated;
        deltaIdsCreated[recordId] = recordId;
        this.deltaIdsCreated = deltaIdsCreated;
        console.log("Successfully Created ");

        this.loadDraftRecords();
    }

    handleAddInventorError(event) {
        try {
            // alert('Handle Error');
            const errorDetails = event.detail;
            console.error("Error occurred while saving the record:", errorDetails);

            // Display a custom error message to the user (optional)
            const errorMessage = this.extractErrorMessage(errorDetails);

            this.showToast("Error", "error", errorMessage); // 'Record not updated'
            this.isLoading = false;
        } catch (err) {
            alert("JS Error ::  :: handleError");
            console.error(err);
        }
    }

    // Helper method to extract error messages
    extractErrorMessage(errorDetails) {
        try {
            if (errorDetails && errorDetails.body) {
                if (
                    errorDetails.body.output &&
                    errorDetails.body.output.errors.length > 0
                ) {
                    return errorDetails.body.output.errors[0].message; // Record-level error
                } else if (errorDetails.body.message) {
                    return errorDetails.body.message; // Top-level error
                }
            }
            return errorDetails.detail;
        } catch (err) {
            alert("JS Error ::  :: extractErrorMessage");
            console.error(err);
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
            stack: error.stack, //,
            // ...error
        });
    }

    handleBack() {
        console.log("Handle Back");
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

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

    isSaving = false;
    async handleSaveDraft() {
        this.isSaving = true;
        await this.cascadeDeltasToJurisdictions();

        let selectedRecords = this.assetIntakeInventorDrafts.filter(record => record.isSelected != false);
        console.log('Selected Innovator Count : ' + selectedRecords.length);


        if (selectedRecords.length < 1) { 
            this.showToast('Error', 'error', 'You must add atleast 1 Innovator to proceed further.');
            this.isSaving = false;
        }
        
        else{ const fields = {};
                    fields['Id'] = this.assetIntakeId;
                    fields['Current_Page__c'] = 'Jurisdiction';
        
                    const recordInput = { fields };
        
                    updateRecord(recordInput)
                        .then(() => {
                            console.log('Successfully updated the page to Jurisdiction');
                        })
                        .catch((error) => {
                            console.log(JSON.stringify(error));
                            console.log('Failed to update the page to Jurisdiction');
                        });

        console.log("Handle Next");
         this.dispatchEvent(new CustomEvent('next', {
                detail: {
                    assetIntakeId: this.assetIntakeId
                }, bubbles: true, composed: true
            }));  
        }
    }

    deltaIdsCreated = {};
        cascadeDeltasToJurisdictions(){
           try{
               const promise = cascadeDeltasToJurisdictions({
                "assetIntakeId" : this.assetIntakeId,
                "deltaIdsCreated" : Object.keys( this.deltaIdsCreated ),
                "section" : "Asset_Intake_Inventor__c" 
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