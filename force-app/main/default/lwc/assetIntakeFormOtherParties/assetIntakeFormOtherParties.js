import { LightningElement, track, api, wire } from "lwc";
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord,
    getPicklistValuesByRecordType,
} from "lightning/uiRecordApi";
import getDraftApplicantRecords from "@salesforce/apex/assetIntakeUtilities.getGoodsSpecifications";
import cascadeDeltasToJurisdictions from '@salesforce/apex/assetIntakeUtilities.cascadeDeltasToJurisdictions';
import ASSET_INTAKE_APPLICANT_OBJECT from "@salesforce/schema/Asset_Intake_Party__c";
import getUserLocale from "@salesforce/apex/mvLawfirmUtilities.getUserLocale";
import getUserTimezoneOffset from "@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import LightningModal from 'lightning/modal';


const PAGINATOR_DEFAULT_SIZE = 10;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100];


export default class AssetIntakeFormOtherParties extends LightningElement {

    @api clientId;
    @api isNewFamily = false;
    @api assetIntakeId;
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

    @track applicantCity = '';
    @track applicantStreet = '';
    @track applicantCountry = '';
    @track applicantPostalCode = '';
    @track applicantState;
    // @track applicantcountryCode;

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

    connectedCallback() {
        this.loadDraftRecords();

    }

    loadDraftRecords() {
        getDraftApplicantRecords({ assetIntakeFormId: this.assetIntakeId, clientId: this.clientId, createDefaultApplicants: this.isNewFamily }).then((result) => {
            console.log("VLM Result : " + JSON.stringify(result));
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
                    title: "Class Draft ID",
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
                    title: "Class",
                    field: "className",
                    type: "recordlink",
                    headerFilter: true,
                    formatterParams: {
                        recordIdField: "clientSpecificationId",
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
                    field: "jurisdictionName",
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
                    title: "Languages",
                    field: "languages",
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
                    title: "Specificaition",
                    field: "specification",
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
                    field: "isExistingClass",
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

        if (!isSelected) {
            const recordInput = {
                apiName: ASSET_INTAKE_APPLICANT_OBJECT.objectApiName,
                fields: {
                    "Asset_Intake_Form__c": this.assetIntakeId
                    ,"Client_Asset_Specification__c": rowData.clientSpecificationId
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
    }catch(err){
        alert('JS Error :: assetIntakeFormApplicants :: handleCheckboxClick');
        this.handleAllErrorTypes(err);
    }

    }

    applicantRecordTypeFormatting(cell) {
        try {
            const isExisting = cell.getRow().getData().isExistingClass;
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
        console.log("Clicked on Save Applicant");
        const inputFields = this.template.querySelectorAll('[data-id="addApplicantRecordFormField"]');

        const fields = {};

        inputFields.forEach(inputField => {
            fields[inputField.fieldName] = inputField.value;
        });
        console.log('Applicant Data : ' + JSON.stringify(fields));

        this.template.querySelector('[data-id="addApplicantRecordForm"]').submit(fields);
        this.hideModalBox();
        this.draftRecordsExists = false;
        
        

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
            fields['Current_Page__c'] = 'Applicants';

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    console.log('Successfully updated the page to Personnel');
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    console.log('Failed to update the page to Personnel');
                });

        this.dispatchEvent(new CustomEvent('navigatetoapplicantdetails', {
            detail: {
                assetIntakeId: this.assetIntakeId
            }, bubbles: true, composed: true
        }));        
    }

    isSaving = false;
    async handleSaveDraft(){ 
        this.isSaving = true;
        await this.cascadeDeltasToJurisdictions();

        if (this.assetIntakeApplicantDrafts.length < 1) { 
            this.showToast('Error', 'error', 'You must add atleast 1 Classes or Goods to proceed further.');
        }

        else {

            const fields = {};
            fields['Id'] = this.assetIntakeId;
            fields['Current_Page__c'] = 'Jurisdiction';

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    console.log('Successfully updated the page to Inventors');
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    console.log('Failed to update the page to Inventors');
                });
            console.log('Handle Next');
            this.dispatchEvent(new CustomEvent('navigatetojurisdictiondetails', {
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
                "section" : "Asset_Intake_Party__c" 
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