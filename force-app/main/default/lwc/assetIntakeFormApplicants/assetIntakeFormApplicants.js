import { LightningElement, track, api, wire } from "lwc";
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    getRecord,
    createRecord,
    updateRecord,
    deleteRecord,
    getPicklistValuesByRecordType,
} from "lightning/uiRecordApi";
import getDraftApplicantRecords from "@salesforce/apex/assetIntakeUtilities.getApplicants";
import cascadeDeltasToJurisdictions from '@salesforce/apex/assetIntakeUtilities.cascadeDeltasToJurisdictions';
import ASSET_INTAKE_APPLICANT_OBJECT from "@salesforce/schema/Asset_Intake_Applicants__c";
import getUserLocale from "@salesforce/apex/mvLawfirmUtilities.getUserLocale";
import getUserTimezoneOffset from "@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import LightningModal from 'lightning/modal';
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
import getClientAddress from '@salesforce/apex/assetIntakeUtilities.getClientAddress';

const PAGINATOR_DEFAULT_SIZE = 10;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100];

export default class AssetIntakeFormApplicants extends NavigationMixin(LightningElement) {

    @api clientId;
    @api isNewFamily = false;
    @api assetIntakeId;
    @api clientGroupNumber;
    @api assetType;
    @track assetIntakeApplicantId = '';
    assetIntakeApplicantObject = ASSET_INTAKE_APPLICANT_OBJECT;
    @track assetIntakeApplicantDrafts = [];
    assetIntakeApplicantData;
    addApplicantModal = false;
    applicantName;
    existingApplicantValue;
    draftColumns = [];
    userlocale;
    timezone;
    @track draftRecordsExists = false;
    @track isRenderedCallBackInitialized = false;
    @track defaultCurrencyId = 'a0XWr000000jMUDMA2';
    @track applicantCity = '';
    @track applicantStreet = '';
    @track applicantCountry = '';
    @track applicantPostalCode = '';
    @track applicantState;
    @track applicantcountryCode = '';

    countryOptions = [];
    stateOptions = [];
    defaultRecordTypeId;
    selectedCountry;

    onApplicantAddressChange(event) {
        this.applicantStreet = event.target.street;
        this.applicantCity = event.target.city;
        this.applicantCountry = event.target.country;
        this.applicantState = event.target.province;
        this.applicantPostalCode = event.target.postalCode;
        console.log('this. :: ', this.applicantCountry);
    }

    applicantAddress = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: '',
        countryCode: ''
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

     @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        console.log('basic details tabId-->'+tabId);
        await closeTab(tabId);
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

    // map_CountryPicklistValues = new Map();
    // @wire(getPicklistValuesByRecordType, {
    //     objectApiName: ASSET_INTAKE_APPLICANT_OBJECT,
    //     recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    // })
    // wiredPicklistValues({ error, data }) {
    //     if (data) {
    //          const countryPicklistValues1 = data.picklistFieldValues.Address__CountryCode__s.values;

    //         countryPicklistValues1.map(picklistValue => {
    //                 this.map_CountryPicklistValues.set(picklistValue.label, picklistValue.value);
    //         });
    //     } else if (error) {
    //         console.error('Error fetching picklist values:', error);
    //     }
    // }

    @wire(getRecordCreateDefaults, { objectApiName: ASSET_INTAKE_APPLICANT_OBJECT })
    assetIntakeDefaults;

    get recordInputForCreate() {
        if (!this.assetIntakeDefaults.data) {
            return undefined;
        }

        const assetIntakeObjectInfo =
            this.assetIntakeDefaults.data.objectInfos[
            ASSET_INTAKE_APPLICANT_OBJECT.objectApiName
            ];
        const recordDefaults = this.assetIntakeDefaults.data.record;
        const recordInput = generateRecordInputForCreate(
            recordDefaults,
            assetIntakeObjectInfo
        );
        console.log("Record Input : " + JSON.stringify(recordInput));
        return recordInput;
    }

    // @wire(getRecord, { recordId: '$assetIntakeApplicantId', fields: FIELDS })
    // wiredRecord({ error, data }) {
    //     if (data) {
    //         this.clientGroupNumber = data.Client_Group_Number__c;
    //         console.log('client group number-->',this.clientGroupNumber);
    //     } else if (error) {
    //         console.error('Error fetching record:', error);
    //     }
    // }

    addressInputChange(event){

        const address = this.template.querySelector('lightning-input-address');

        this.applicantAddress.street = event.detail.street;
        this.applicantAddress.city = event.detail.city;
        this.applicantAddress.postal = event.detail.postalCode;
        this.applicantAddress.state = event.detail.province;
        this.applicantAddress.country = event.detail.country;
        this.selectedCountry = event.detail.country;
        //this.getCountryCode(this.applicantAddress.country);

        console.log( 'Applicant Address : ' + JSON.stringify(this.applicantAddress));
        console.log(this.applicantAddress);
    }

    // getCountryCode(countryName) {
    //     getCountryCodeByName({ countryName })
    //         .then((result) => {
    //             if (result) {
    //                 this.applicantAddress.countryCode = result.Country_Code__c;
    //                 console.log('Country Code:', this.applicantAddress.countryCode);
    //             }
    //         })
    //         .catch((error) => {
    //             console.error('Error retrieving country code:', error);
    //         });
    // }

    connectedCallback() {
        console.log('client Grp num : ',this.clientGroupNumber);
        this.loadDraftRecords();

    }

    loadDraftRecords() {
        this.draftRecordsExists = false;
        getDraftApplicantRecords({ assetIntakeFormId: this.assetIntakeId, clientId: this.clientId, createDefaultApplicants: this.isNewFamily  }).then((result) => {
            console.log("Result : " + JSON.stringify(result));
            this.isNewFamily = false;
            this.assetIntakeApplicantDrafts = result;
            console.log(
                "Asset Intake Draft Records : " + JSON.stringify(this.assetIntakeApplicantDrafts)
            );
            this.prepareColumns();
            this.draftRecordsExists = true;

        })
        .catch(err=>{
            alert('Error in loading draft records. Please contact system Adminstrator. ' );
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
                    title: "Applicant Draft ID",
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
                    title: "Applicant",
                    field: "name",
                    type: "recordlink",
                    headerFilter: true,
                    formatterParams: {
                        recordIdField: "applicantId",
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
                    title: "Applicant Address",
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
                    title: "Client Classification",
                    field: "clientClassification",
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
                    title: "Currency",
                    field: "currencyCode",
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
                    title: "US/CA Entity Size",
                    field: "entitySize",
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
                    field: "isExistingApplicant",
                    headerFilter: true,
                    formatterParams: {
                        "recordIdField": "recordId",
                        "classList": [],
                        "styleList": [
                            {
                                "property": "font-weight",
                                "value": "bold",
                            }
                        ],
                        "classListFunction": this.applicantRecordTypeFormatting
                    }
                },
            ];

            this.draftColumns = columns;
        } catch (err) {
            console.error(this.serializeError(err));
        }
    }

    async handleCheckboxClick(event, cell) {
        try{
        // Stop propagation to avoid triggering other cell events
        event.stopPropagation();

        const rowData = cell.getRow().getData();
        const isSelected = rowData.isSelected;
        const checkbox = event.target;

        //checkbox.disabled = true;

        if (!isSelected) {
            const recordInput = {
                apiName: ASSET_INTAKE_APPLICANT_OBJECT.objectApiName,
                fields: {
                    "Asset_Intake_Form__c": this.assetIntakeId
                    ,"Applicant__c": rowData.applicantId
                }
            };

                // Invoke createRecord
                const assetIntakeApplicantRecord = await createRecord(recordInput);
                const recordId = assetIntakeApplicantRecord.id;
                console.log("Successfully created record with Asset Intake Applicant ID: " + recordId);
                rowData.recordId = recordId;
                let deltaIdsCreated = this.deltaIdsCreated;
                deltaIdsCreated[recordId] = recordId;
                this.deltaIdsCreated = deltaIdsCreated;

            rowData.isSelected = true;
        } else {
            const recordId = rowData.recordId;
            await deleteRecord(recordId);
            let deltaIdsCreated = this.deltaIdsCreated;
            delete deltaIdsCreated[recordId];
            this.deltaIdsCreated = deltaIdsCreated;
            console.log("Successfully deleted record with Asset Intake Applicant ID: " + recordId);
            rowData.recordId = null;
            rowData.isSelected = false;
        }
        this.loadDraftRecords();
        //checkbox.disabled = false;
    }catch(err){
        alert('JS Error :: assetIntakeFormApplicants :: handleCheckboxClick');
        this.handleAllErrorTypes(err);
    }

    }

    applicantRecordTypeFormatting(cell) {
        try {
            const isExisting = cell.getRow().getData().isExistingApplicant;
            console.log('Is Existing ' + isExisting);
            if (isExisting === 'Existing') {
                return ["greentag"];
            }
            else {
                return ["greytag"];
            }
        } catch (err) {
            alert('JS Error ::  :: applicantRecordTypeFormatting')
            console.error(err)
        }
    }

    get errors() {
        console.log("Error in Asset Intake Defaults");
        return this.assetIntakeDefaults.error;
    }

    handleAddApplicant() {
        this.addApplicantModal = true;
    }

    hideModalBox() {
        this.addApplicantModal = false;
    }

    addNewApplicant() {
        try{
            console.log("Clicked on Save Applicant");
            const inputFields = this.template.querySelectorAll('[data-id="addApplicantRecordFormField"]');
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

            const addressFields = this.template.querySelectorAll('[data-id="addressField"]');
            
            addressFields.forEach(addressField => {
                if(! addressField.checkValidity()){
                    addressField.reportValidity();
                    console.log('cm here')
                    isValid = false;
                }
            });

            if(! isValid){
                this.isLoading = false;
                return;
            }

            // inputFields.forEach(inputField => {
            //     fields[inputField.fieldName] = inputField.value;
            // });

            //fields['Applicant_Address__c'] = this.applicantAddress;
            fields['Applicant_Address__Street__s'] = this.applicantAddress.street;
            //fields['Applicant__Address__City__s'] = this.applicantAddress.city; 
            fields['Applicant_Address__City__s'] = this.applicantAddress.city; 
            //fields['Applicant__Address__State__s'] = this.applicantAddress.state;   
            fields['Applicant_Address__StateCode__s'] = this.applicantAddress.state;
           // fields['Applicant__Address__PostalCode__s'] = this.applicantAddress.postal; 
            fields['Applicant_Address__PostalCode__s'] = this.applicantAddress.postal; 
            fields['Applicant_Address__CountryCode__s'] = this.applicantAddress.country;  
            //fields['Applicant_Address__CountryCode__s'] = this.applicantAddress.countryCode; 

            console.log('Applicant Data : ' + JSON.stringify(fields));

            this.template.querySelector('[data-id="addApplicantRecordForm"]').submit(fields);
            this.hideModalBox();
            this.draftRecordsExists = false;
        
        }catch(err){
             alert('JS Error ::  :: addNewApplicant')
            console.error(err)
        }
    }

    handleAddApplicantSuccess(event) {
        let recordId = event.detail.id;

        let deltaIdsCreated = this.deltaIdsCreated;
        deltaIdsCreated[recordId] = recordId;
        this.deltaIdsCreated = deltaIdsCreated;

        console.log('Successfully Created ');

        this.loadDraftRecords();
    }

    handleAddApplicantError(event) {
        try{
            // alert('Handle Error');
             const errorDetails = event.detail;
             console.error('Error occurred while saving the record:', errorDetails);
 
             // Display a custom error message to the user (optional)
             const errorMessage = this.extractErrorMessage(errorDetails);
 
             this.showToast('Error', 'error', errorMessage); // 'Record not updated'
             this.isLoading = false;
         }catch(err){
             alert('JS Error ::  :: handleError')
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

    handleBack(event) { 
        console.log('Handle Back');

        const fields = {};
            fields['Id'] = this.assetIntakeId;
            fields['Current_Page__c'] = 'Personnel';

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    console.log('Successfully updated the page to Personnel');
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    console.log('Failed to update the page to Personnel');
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

    getValueByLabel(label) {
    // Find the object in the array where the label matches
    const country = this.countryOptions.find(option => option.label === label);

    // Return the value if found, otherwise return undefined
    return country ? country.value : undefined;
    }

    isSaving = false;
    
    async handleSaveDraft(){ 
        var addressPayload;
        this.isSaving = true;
        await this.cascadeDeltasToJurisdictions();
        console.log('assetIntakeApplicantDrafts in handle save draft--->',this.assetIntakeApplicantDrafts);
        let selectedRecords = this.assetIntakeApplicantDrafts.filter(record => record.isSelected != false);
        console.log('Selected Applicant Count : ' + selectedRecords.length);


        if (selectedRecords.length < 1) { 
            this.showToast('Error', 'error', 'You must add atleast 1 Applicant to proceed further.');
            this.isSaving = false;
        }

        else {
            
            if (selectedRecords.length === 1) {
                const selected = selectedRecords[0];

                addressPayload = {
                    street: selected.street,
                    city: selected.city,
                    state: selected.stateCode,
                    postal: selected.postal,
                    country: selected.countryCode
                };
        }else{
            try {
            const response = await getClientAddress({
                assetIntakeFormId: this.assetIntakeId,
                clientId: this.clientId
            });
            console.log('getClientAddress response',response);

            if (response) {
                addressPayload = {
                   // source: 'client',
                    street: response.street,
                    city: response.city,
                    state: response.stateCode,
                    postal: response.postal,
                    country: response.countryCode
                };
            }
        } catch (error) {
            console.error('Error fetching client address:', error);
        }
        }
        if (addressPayload) {
        const addressEvent = new CustomEvent('addressselected', {
            detail: addressPayload,
            bubbles: true,
            composed: true
        });

        this.dispatchEvent(addressEvent);
        this.isSaving = false;
    }
    let currentPage = this.assetType ==='Patent'?'Innovators':'Classes and Goods';
            const fields = {};
            fields['Id'] = this.assetIntakeId;
            fields['Current_Page__c'] = currentPage;
            const recordInput = { fields };

           await updateRecord(recordInput)
                .then(() => {
                    console.log('Successfully updated the page to Inventors');
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    console.log('Failed to update the page to Inventors');
                });
            console.log('Handle Next');
            this.isSaving = false;
            
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
                "section" : "Asset_Intake_Applicants__c" 
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