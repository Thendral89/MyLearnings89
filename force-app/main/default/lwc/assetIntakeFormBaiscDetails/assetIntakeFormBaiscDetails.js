import { LightningElement, track, api, wire } from "lwc";
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord,
    getRecord,
    getFieldValue 
} from "lightning/uiRecordApi";
import getDraftClientRecordsForTrademark from "@salesforce/apex/assetIntakeUtilities.getDraftAssetRecords";
import getDraftClientRecordsForPatent from "@salesforce/apex/assetIntakeUtilities.getDraftRecords";
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
import DEPARTMENT_FIELD from '@salesforce/schema/SymphonyLF__Patent_Family__c.Department__c'; 
import {
    closeTab,
    IsConsoleNavigation,
    getFocusedTabInfo
} from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';

const PAGINATOR_DEFAULT_SIZE = 10;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100];

const TAB_LABEL = 'Asset Intake Form';

export default class AssetIntakeFormBaiscDetails extends NavigationMixin(LightningElement) {
    @api clientId;
    @api conflictCheckId;
    @api isPatent;
    @api isTrademark;
    @api tabId;
    @api matterTitle;

    @track draftPatentCount = 0;
    @track draftRecordsExists = false;
    @track draftInventorCount = 0;
    @track draftApplicantCount = 0;
    assetIntakeObject = ASSET_INTAKE_OBJECT;
    @track assetIntakeDrafts = [];
    @track draftColumns = [];
    @track assetIntakeData;
    @track isNewFamily = false;
    @track isRenderedCallBackInitialized=false;
    @track imageUploaded = false;
    @track imageUrl; // Stores uploaded image URL
    @track versionId = '';
    @track existingMarkImage = false; //To check existing Mark images

    assetIntakeId = '';
    existingMark = "";
    newMarkName = "";
    userlocale;
    timezone;
    @api patentFamily ;
    existingDepartment;
    newPatentFamilyName = "";
    newDepartment="";
    showDepartment = false;

     @wire(IsConsoleNavigation) isConsoleNavigation;

     
    // async closeTab() {
    //     if (!this.isConsoleNavigation) {
    //         return;
    //     }
    //     console.log('basic details tabId-->'+this.tabId);
    //     await closeTab(this.tabId);
    // }

    @wire(getRecord, {
        recordId: '$patentFamily', 
        fields: [DEPARTMENT_FIELD] 
    })
    wiredPatentFamily({ error, data }) {
        if (data) {
            this.existingDepartment = getFieldValue(data, DEPARTMENT_FIELD);
        } else if (error) {
            console.error("Error retrieving Department value", error);
        }
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
        console.log('isPatent--->' + this.isPatent);
        console.log('isTrademark--->' + this.isTrademark);
        console.log('this.matterTitle : in basic detail comp  ',this.matterTitle);
        this.newPatentFamilyName = this.matterTitle;
        this.newMarkName = this.matterTitle;
        if(this.isTrademark){
            this.fetchPicklistValues();
        }
        
        try{
            if(this.isTrademark){
                this.loadDraftRecordsForTradeMark();
            }else if(this.isPatent){
                this.loadDraftRecordsForPatent();
            }
           // this.loadDraftRecords();
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

     loadDraftRecordsForTradeMark() {
        try{
        getDraftClientRecordsForTrademark({ clientId: this.clientId, assetType: 'Trademark'}).then((result) => {
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

    loadDraftRecordsForPatent() {
        try{
        getDraftClientRecordsForPatent({ clientId: this.clientId, assetType: 'New Patent Family' }).then((result) => {
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

            // let cloneAction = {
            //     title: "Clone",
            //     field: "actions",
            //     align: "center",
            //     width: "75",
            //     resizable: false,
            //     headerSort: false,
            //     formatter: (cell, formatterParams) => {
            //         let cellData = cell.getRow().getData();
            //         let formattedHtml = ` <div class="action-icons"> `;
            //         formattedHtml += ` <i class='fa fa-clone' title='Clone'></i>  `;
            //         formattedHtml += ` </div> `;
            //         return formattedHtml;
            //     },
            //     cellClick: (e, cell) => this.handleActionClone(e, cell),
            //     hozAlign: "center",
            //     columnHeaderVertAlign: "middle",
            // };

            // columns.push(cloneAction);

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

            const assetIntakeDraftLeft = this.assetIntakeDrafts.filter(record => record.recordId != rowData.recordId);
            await deleteRecord(draftIntakeId);
            this.assetIntakeDrafts = assetIntakeDraftLeft;
            this.template.querySelector('.lwcMvDataTable').updateTableData(this.assetIntakeDrafts);

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
           
            let currentPage = rowData.currentPage;
            
             
            console.log ('Selected Draft Intake ID : ' + draftIntakeId) ;
            console.log('Current Page : ' + currentPage);

             this.dispatchEvent(new CustomEvent('actionnavigation', {
                    detail: { 
                        currentPage: currentPage ,
                        assetIntakeId: draftIntakeId
                    }, bubbles: true, composed: true
                }));
        } catch (err) {
            alert('JS Error :: assetIntakeFormBasicDetails :: handleActionClick');
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
        if(this.isPatent){
            this.handleSaveDraftForPatent();
        }else if(this.isTrademark){
            this.handleSaveDraftForTrademark();
        }
     }
        //PATENT
      handleSaveDraftForPatent(){
       try{
            console.log("Client ID :  " + this.clientId);
            console.log("Patent Family : " + this.patentFamily);
            console.log("New Patent Family Name : " + this.newPatentFamilyName);

            if (  this.newPatentFamilyName ===undefined || this.newPatentFamilyName === '' ) {
                this.showToast('Error', 'error', 'New Family is a required field. Please enter the New Family.', 'dismissable', 'assets/warning_24.png', '');
                return;
            }

           createNewIntakeRecord({'request' : JSON.stringify(
               {
                   "clientId" : this.clientId,
                   "newFamilyName": this.newPatentFamilyName,
                   "existingFamilyId": this.patentFamily,
                   "assetType": this.patentFamily ? 'Existing Patent Family' : 'New Patent Family',
                   "department": this.newDepartment,
                   "conflictCheckId": this.conflictCheckId
               }
           )})
           .then( response => {
               try{
                this.dispatchEvent(new CustomEvent('next', {
                    detail: { 
                        assetIntakeId: response,
                        isNewFamily : false
                    }, bubbles: true, composed: true
                }));

               }catch(err){
                //    alert('JS Error in Server callback ::  :: handleSaveDraft');
                   console.error(JSON.stringify(err));
               }
           })
           .catch( error => {
            //    alert('Server Error ::  :: handleSaveDraft :: apexMethod => createNewIntakeRecord');
               console.error(JSON.stringify(error));
           })
        }catch(err){
            // alert('JS Error :: assetIntakeFormPatentDetails :: handleSaveDraft');
            this.handleAllErrorTypes( err );
        }
    }

    //TRADEMARK
    handleSaveDraftForTrademark(){
       try{
            console.log("Client ID :  " + this.clientId);
            console.log("Patent Family : " + this.existingMark);
            console.log("New Patent Family Name : " + this.newMarkName);
            console.log('this.selectedMarkTypes : ',this.selectedMarkTypes);

            if (this.newMarkName === '' || this.newMarkName === undefined || this.newMarkName === null ) {
                this.showToast('Error', 'error', 'Please enter New Mark Name.', 'dismissable', 'assets/warning_24.png', '');
                return;
            }

            if(this.selectedMarkTypes === undefined || this.selectedMarkTypes === '' || this.selectedMarkTypes === '--None--' || this.selectedMarkTypes === null || this.selectedMarkTypes == [] || this.selectedMarkTypes.length <= 0){
                this.showToast('Error', 'error', 'Please select a Mark Type.', 'dismissable', 'assets/warning_24.png', '');
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
                // this.dispatchEvent(new CustomEvent('assetintakecreated', {
                //     detail: { 
                //         assetIntakeId: response, 
                //         isNewFamily : false
                //     }, bubbles: true, composed: true
                // }));
                this.dispatchEvent(new CustomEvent('next', {
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

    //PATENT
    handleNewPatentFamilyValue(event) {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
    try{
        this.newPatentFamilyName = event.target.value;
        this.patentFamily = "";
        this.isNewFamily = false;
    }catch(err){
        alert('JS Error :: assetIntakeFormBasicDetails :: handleNewPatentFamilyValue');
        this.handleAllErrorTypes( err );
    }
    }
    preventRefresh(event) {
        if(event.key === "Enter" || event.keyCode === 13){
            event.preventDefault();
            event.stopPropagation();    
        }
    }

    //TRADEMARK
     handleNewTrademarkFamilyValue(event) {
        try{
        this.newMarkName = event.target.value;
        this.existingMark = "";
        this.isNewFamily = false;
        //this.selectedMarkTypes = [];
    }catch(err){
        alert('JS Error :: assetIntakeFormBasicDetails :: handleNewTrademarkFamilyValue');
        this.handleAllErrorTypes( err );
    }
    }
    //PATENT
    handleDepartmentChange(event) {
        try{
        console.log('Event Values : ' + JSON.stringify(event.target));
        this.newDepartment = event.target.value;
        this.patentFamily = "";
        this.isNewFamily = true;
        console.log ('Department Values : ' + this.newDepartment);

    }catch(err){
        alert('JS Error :: assetIntakeFormPatentDetails :: handleDepartmentChange');
        this.handleAllErrorTypes( err );
    }
    }
    //PATENT
    handleExistingPatentFamilyValue(event) {
        try{
        this.patentFamily = event.target.value;
        if(this.patentFamily != null && this.patentFamily != undefined){
            this.showDepartment = true;
        }
        this.newDepartment="";
        this.isNewFamily = true;
        this.newPatentFamilyName = "";

    }catch(err){
        alert('JS Error :: assetIntakeFormBasicDetails :: handleExistingPatentFamilyValue');
        this.handleAllErrorTypes( err );
    }
    }
    //TRADEMARK
        handleExistingTrademarkFamilyValue(event) {
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
            alert('JS Error CATCH:: assetIntakeFormBasicDetails :: handleExistingTrademarkFamilyValue');
            this.handleAllErrorTypes( err );
        }
    }

    async handleReset() {
        //this.closeTab();

        console.log('Tab ID : ' + this.tabId);
        if (this.tabId) {
                        closeTab({ tabId: this.tabId })
                            .then(() => {
                                console.log('Tab closed successfully');
                            })
                            .catch(error => {
                                console.error('Error closing the tab: ', error);
                            });
                    }
        this.navigateToCCdashboard();
    // console.log('handleReset called');
    // getTabInfo()
    //     .then(tabInfo => {
    //         console.log('Tab Info:', tabInfo);
    //         const tabId = tabInfo.id;  // Tab ID
    //         if (tabId) {
    //             closeTab({ tabId: tabId })
    //                 .then(() => {
    //                     console.log('Tab closed successfully');
    //                 })
    //                 .catch(error => {
    //                     console.error('Error closing the tab: ', error);
    //                 });
    //         } else {
    //             console.error('No tab ID available');
    //         }
    //     })
    //     .catch(error => {
    //         console.error('Error getting tab info: ', error);
    //     });
    //     this[NavigationMixin.Navigate]({
    //     type: 'standard__navItemPage',
    //     attributes: {
    //         // This is the name of the Lightning page you want to navigate to
    //         apiName: 'Conflict_Check'
    //     }
    // });
}

     navigateToCCdashboard() {
        this[NavigationMixin.Navigate]({
        type: 'standard__navItemPage',
        attributes: {
            // This is the name of the Lightning page you want to navigate to
            apiName: 'Conflict_Check_Dashboard'
        }
    });
    }

    // closeTab() {
    //     window.close(); 
    // }



    //TRADEMARK
        get hideImageUpload() {
        return !this.imageUploaded && !this.existingMarkImage;
    }

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