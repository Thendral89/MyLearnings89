import { LightningElement, track, api, wire } from "lwc";
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord
} from "lightning/uiRecordApi";
import getDraftClientRecords from "@salesforce/apex/assetIntakeUtilities.getDraftAssetRecords";
import createNewIntakeRecord from "@salesforce/apex/assetIntakeUtilities.createNewIntakeRecord";
//Content Document fetch
import imageFromMark from "@salesforce/apex/createTrademarkRecords.fetchContentFromMark";
import fetchMarkType from "@salesforce/apex/createTrademarkRecords.fetchTypeFromMark";
import ASSET_INTAKE_OBJECT from "@salesforce/schema/Asset_Intake_Form__c";
import getUserLocale from "@salesforce/apex/mvLawfirmUtilities.getUserLocale";
import getUserTimezoneOffset from "@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getPicklistValues from '@salesforce/apex/createTrademarkRecords.getPicklistValues';


const PAGINATOR_DEFAULT_SIZE = 10;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100];

export default class AssetIntakeFormTrademarkDetails extends LightningElement {
    @api clientId;
    @api conflictCheckId;

    @track draftPatentCount = 0;
    @track draftRecordsExists = false;
    @track draftInventorCount = 0;
    @track draftApplicantCount = 0;
    assetIntakeObject = ASSET_INTAKE_OBJECT;
    @track assetIntakeDrafts = [];
    @track draftColumns = [];
    assetIntakeId = '';
    @track assetIntakeData;
    @track isNewFamily = false;
    existingMark = "";
    newMarkName = "";
    userlocale;
    timezone;
    @track isRenderedCallBackInitialized=false;
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

    @wire(getRecordCreateDefaults, { objectApiName: ASSET_INTAKE_OBJECT })
    assetIntakeDefaults;

    get recordInputForCreate() {
        try{
        if (!this.assetIntakeDefaults.data) {
            return undefined;
        }

        const assetIntakeObjectInfo =
            this.assetIntakeDefaults.data.objectInfos[
            ASSET_INTAKE_OBJECT.objectApiName
            ];
        const recordDefaults = this.assetIntakeDefaults.data.record;
        const recordInput = generateRecordInputForCreate(
            recordDefaults,
            assetIntakeObjectInfo
        );
        console.log("Record Input : " + JSON.stringify(recordInput));
        return recordInput;
        }catch(err){
            alert('JS Error :: assetIntakeFormPatentDetails :: recordInputForCreate');
            this.handleAllErrorTypes( err );
        }
    }

    get errors() {
        try{
        console.log("Error in Asset Intake Defaults");
        return this.assetIntakeDefaults.error;
        }catch(err){
            alert('JS Error :: assetIntakeFormPatentDetails :: errors');
            this.handleAllErrorTypes( err );
        }
    }

    connectedCallback() {
        this.fetchPicklistValues();
        try{
            this.loadDraftRecords();
        }catch(err){
            alert('JS Error :: assetIntakeFormPatentDetails :: connectedCallback');
            this.handleAllErrorTypes( err );
        }
    }

    fetchPicklistValues() {
        getPicklistValues({ objectApiName: 'SymphonyLF__Mark__c', fieldApiName: 'SymphonyLF__Mark_Type__c' })
            .then((result) => {
                this.markTypeOptions = result.map((item) => ({
                    label: item.label,
                    value: item.value
                }));
            })
            .catch((error) => {
                console.error('Error fetching picklist values:', error);
            });
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
            }catch(err){
                alert('JS Error :: assetIntakeFormPatentDetails :: renderedCallback');
                this.handleAllErrorTypes( err );
            }
    }

    loadDraftRecords() {
        try{
        getDraftClientRecords({ clientId: this.clientId, assetType: 'Trademark'}).then((result) => {
            console.log("Result : " + JSON.stringify(result));
            if (result.length > 0) this.draftRecordsExists = true;
            this.prepareColumns();
            this.assetIntakeDrafts = result;
            console.log(
                "Asset Intake Draft Records : " + JSON.stringify(this.assetIntakeDrafts)
            );
            this.draftPatentCount = result.length;
        });
        }catch(err){
            alert('JS Error :: assetIntakeFormPatentDetails :: loadDraftRecords');
            this.handleAllErrorTypes( err );
        }
    }

    prepareColumns() {
        try {
            let columns = [
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
                    title: "Name",
                    field: "familyTitle",
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
                    title: "Docket No.",
                    field: "familyDocketNumber",
                    type: "recordlink",
                    formatterParams: {
                        recordIdField: "familyId",
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
                    title: "Status",
                    field: "status",
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
                    title: "Type",
                    field: "assetType",
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

            let action = {
                title: "Action",
                field: "actions",
                align: "center",
                width: "75",
                resizable: false,
                headerSort: false,
                formatter: (cell, formatterParams) => {
                    let cellData = cell.getRow().getData();
                    let formattedHtml = ` <div class="action-icons"> `;
                    formattedHtml += ` <i class='fa fa-location-arrow' title='Navigate'></i>  `;
                    formattedHtml += ` </div> `;
                    return formattedHtml;
                },
                cellClick: (e, cell) => this.handleActionClick(e, cell),
                hozAlign: "center",
                columnHeaderVertAlign: "middle",
            };

            columns.push(action);

            let deleteaction = {
                title: "Delete",
                field: "actions",
                align: "center",
                width: "75",
                resizable: false,
                headerSort: false,
                formatter: (cell, formatterParams) => {
                    let cellData = cell.getRow().getData();
                    let formattedHtml = ` <div class="action-icons"> `;
                    formattedHtml += ` <i class='fa fa-trash' title='Navigate'></i>  `;
                    formattedHtml += ` </div> `;
                    return formattedHtml;
                },
                cellClick: (e, cell) => this.handleActionDelete(e, cell),
                hozAlign: "center",
                columnHeaderVertAlign: "middle",
            };

            columns.push(deleteaction);

            let cloneAction = {
                title: "Clone",
                field: "actions",
                align: "center",
                width: "75",
                resizable: false,
                headerSort: false,
                formatter: (cell, formatterParams) => {
                    let cellData = cell.getRow().getData();
                    let formattedHtml = ` <div class="action-icons"> `;
                    formattedHtml += ` <i class='fa fa-clone' title='Clone'></i>  `;
                    formattedHtml += ` </div> `;
                    return formattedHtml;
                },
                cellClick: (e, cell) => this.handleActionClone(e, cell),
                hozAlign: "center",
                columnHeaderVertAlign: "middle",
            };

            columns.push(cloneAction);

            this.draftColumns = columns;
        }catch(err){
            alert('JS Error :: assetIntakeFormPatentDetails :: prepareColumns');
            this.handleAllErrorTypes( err );
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

    async handleActionClone(event, cell){ 
        event.stopPropagation();        
        try {

            let rowData = cell.getRow().getData();
            const draftIntakeId = rowData.recordId;
            // call apex to clone
            this.showToast('Success', 'success', 'The Intake is successfully cloned.', 'dismissable');

            this.dispatchEvent(new CustomEvent('assetintakecreated', {
                detail: { 
                    assetIntakeId: response, 
                    isNewFamily : false
                }, bubbles: true, composed: true
            }));
        } catch(err) {
            alert('JS Error :: assetIntakeFormPatentDetails :: handleActionClone');
            this.handleAllErrorTypes( err );
        }

    }

    async handleActionDelete(event, cell){ 
        event.stopPropagation();        
        try {

            let rowData = cell.getRow().getData();
            const draftIntakeId = rowData.recordId;
            console.log('Draft Intake to be deleted : ' + draftIntakeId);


            const assetIntakeDraftLeft = (this.assetIntakeDrafts.filter(record => record.Id != rowData.Id));
            deleteRecord(draftIntakeId);
            this.assetIntakeDrafts = assetIntakeDraftLeft;
            this.template.querySelector('.lwcMvDataTable').updateTableData(assetIntakeDraftLeft);

            this.showToast('Success', 'success', 'The Draft Intake is successfully deleted.', 'dismissable');

            
        } catch(err) {
            alert('JS Error :: assetIntakeFormPatentDetails :: handleActionDelete');
            this.handleAllErrorTypes( err );
        }

    }
    handleActionClick(e, cell) {
        try {
            let target = e.target;
            let rowData = cell.getRow().getData();

            const draftIntakeId = rowData.recordId;
            const currentPage = rowData.currentPage;
            console.log ('Selected Draft Intake ID : ' + draftIntakeId) ;
            console.log('Current Page : ' + currentPage);
            if (currentPage === 'Personnel') {
                this.dispatchEvent(new CustomEvent('navigatetopersonneldetails', {
                    detail: { 
                        assetIntakeId: draftIntakeId
                    }, bubbles: true, composed: true
                }));
            } else if (currentPage === 'Applicants') {
                this.dispatchEvent(new CustomEvent('navigatetoapplicantdetails', {
                    detail: { 
                        assetIntakeId: draftIntakeId
                    }, bubbles: true, composed: true
                }));
            }
            else if (currentPage === 'Inventors') {
                this.dispatchEvent(new CustomEvent('navigatetoinventordetails', {
                    detail: { 
                        assetIntakeId: draftIntakeId
                    }, bubbles: true, composed: true
                }));
            } else if (currentPage === 'Jurisdiction') {
                console.log('Dispatching Event');
                this.dispatchEvent(new CustomEvent('navigatetojurisdictiondetails', {
                    detail: { 
                        assetIntakeId: draftIntakeId
                    }, bubbles: true, composed: true
                }));
            }



        } catch (err) {
            alert('JS Error :: assetIntakeFormPatentDetails :: handleActionClick');
            this.handleAllErrorTypes( err );
        }
    }

    serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
        });
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

    handleSaveDraft(){
       try{
            console.log("Client ID :  " + this.clientId);
            console.log("Patent Family : " + this.existingMark);
            console.log("New Patent Family Name : " + this.newMarkName);

            if (this.existingMark === '' && this.newMarkName === '') {
                this.showToast('Error', 'error', 'Please either enter New Mark or Select Existing Mark.', 'dismissable', 'assets/warning_24.png', '');
                return;
            }

           createNewIntakeRecord({'request' : JSON.stringify(
               {
                   "clientId" : this.clientId,
                   "newFamilyName": this.newMarkName,
                   "existingFamilyId": this.existingMark,
                   "assetType": 'Trademark',
                   "department": this.selectedMarkTypes,
                   "conflictCheckId": this.conflictCheckId,
                   "contentId":this.versionId
               }
           )})
           .then( response => {
               try{
                this.dispatchEvent(new CustomEvent('assetintakecreated', {
                    detail: { 
                        assetIntakeId: response, 
                        isNewFamily : false
                    }, bubbles: true, composed: true
                }));
               }catch(err){
                   alert('JS Error in Server callback ::  :: handleSaveDraft');
               }
           })
           .catch( error => {
               alert('Server Error ::  :: handleSaveDraft :: apexMethod => createNewIntakeRecord');
               console.error(JSON.stringify(error));
           })
        }catch(err){
            alert('JS Error :: assetIntakeFormPatentDetails :: handleSaveDraft');
            this.handleAllErrorTypes( err );
        }
    }


    handleAddIntakeSuccess() { }

    handleIntakeError() { }

    handleNewFamilyValue(event) {
        try{
        this.newMarkName = event.target.value;
        this.existingMark = "";
        this.isNewFamily = false;
        //this.selectedMarkTypes = [];
    }catch(err){
        alert('JS Error :: assetIntakeFormPatentDetails :: handleNewFamilyValue');
        this.handleAllErrorTypes( err );
    }
    }

    handleExistingFamilyValue(event) {
        try{
        this.existingMark = event.target.value;
        console.log('existingMark:', this.existingMark);
            if (this.existingMark) {
                imageFromMark({ markId: this.existingMark }).
                    then((contentId) => {
                        console.log('Fetched Content Id:', contentId);
                        
                        if (!contentId) {
                            console.log('No Content Id found');
                            return;
                        }
                        this.versionId = contentId;
                        const baseUrl = window.location.origin;
                        this.imageUrl = `${baseUrl}/sfc/servlet.shepherd/version/download/${contentId}`;
                        this.imageUploaded = false;
                        this.existingMarkImage = true;

                        console.log('Image URL:', this.imageUrl);
                    })
                    .catch((error) => {
                        console.log('Error fetching content:', error);
                    });
                fetchMarkType({ markId: this.existingMark })
                    .then((result) => {
                        if (result) {
                            console.log('Fetched Mark Type:', result);
                            this.selectedMarkTypes = result;
                            console.log('Fetched Mark Type:selectedMarkTypes', this.selectedMarkTypes);
                        }
                    })
                    .catch((error) => {
                        console.error('Error fetching mark type:', error);
                    });

            }else {
                this.versionId = '';
                //this.imageUrl = `${baseUrl}/sfc/servlet.shepherd/version/download/${contentId}`;
                this.imageUploaded = false;
                this.existingMarkImage = false;
                this.selectedMarkTypes = [];
                
            }

        //this.newDepartment="";
        this.isNewFamily = true;
        this.newMarkName = "";

        }catch(err){
            alert('JS Error CATCH:: handleExistingFamilyValue :: handleExistingFamilyValue');
            this.handleAllErrorTypes( err );
        }
    }

    handleBack(){

    }

    handleReset() {
        
    }

    get hideImageUpload() {
        return !this.imageUploaded && !this.existingMarkImage;
    }

    @track imageUploaded = false;
    @track imageUrl; // Stores uploaded image URL
    @track versionId = '';
    @track existingMarkImage = false; //To check existing Mark images
    //File Upload
    handleFileUpload(event) {
        const uploadedFiles = event.detail.files;

        if (!uploadedFiles || uploadedFiles.length === 0) {
            console.error('No files uploaded.');
            return;
        }

        const uploadedFile = uploadedFiles[0]; // Only allow one image upload
        const baseUrl = window.location.origin; 
        this.versionId = uploadedFile.contentVersionId;
        console.log(this.imageUrl);
        this.imageUrl = `${baseUrl}/sfc/servlet.shepherd/version/download/${uploadedFile.contentVersionId}`;
        this.imageUploaded = true; // Hide file upload button
        this.existingMarkImage = false;
        console.log(this.imageUrl);

        this.showToast('Success', 'success', 'Image Uploaded Successfully!');

    }

    handleRemoveImage() {
        this.imageUploaded = false; // Hide the image
    }

    @track markTypeOptions = [];
    @track selectedMarkTypes = [];
    
    handleMarkTypeChange(event) {
        try{
        console.log('Event Values : ' + JSON.stringify(event.target));
        //this.newDepartment = event.target.value;
        this.selectedMarkTypes = event.detail.value;
        this.patentFamily = "";
        this.isNewFamily = true;
        console.log ('MarkTYpe Values : ' + this.selectedMarkTypes);

        }catch(err){
            alert('JS Error :: MarkTYpe :: MarkTYpe');
            this.handleAllErrorTypes( err );
        }
    }
}