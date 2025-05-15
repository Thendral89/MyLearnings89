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

import ASSET_INTAKE_OBJECT from "@salesforce/schema/Asset_Intake_Form__c";
import getUserLocale from "@salesforce/apex/mvLawfirmUtilities.getUserLocale";
import getUserTimezoneOffset from "@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


const PAGINATOR_DEFAULT_SIZE = 10;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100];

export default class AssetIntakeFormDisputeDetails extends LightningElement {
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
    title = "";
    disputeSubType = "";
    disputeType="";
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
        try{
        this.loadDraftRecords();
    }catch(err){
        alert('JS Error :: assetIntakeFormPatentDetails :: connectedCallback');
        this.handleAllErrorTypes( err );
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
            }catch(err){
                alert('JS Error :: assetIntakeFormPatentDetails :: renderedCallback');
                this.handleAllErrorTypes( err );
            }
    }

    loadDraftRecords() {
        try{
        getDraftClientRecords({ clientId: this.clientId, assetType: 'Opposition'}).then((result) => {
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
                    title: "Title",
                    field: "title",
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
                    title: "Dispute Subtype",
                    field: "disputeSubType",
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
                    title: "Dispute Type",
                    field: "disputeType",
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
    handletitle(event) {
        this.title = event.target.value;
    }
    handleDisputesubType(event) {
        this.disputeSubType = event.target.value;
    }
    handleDisputeType(event) {
        this.disputeType = event.target.value;
    }


    handleSaveDraft(){
       try{
            
            console.log('this.title',this.title);
           createNewIntakeRecord({'request' : JSON.stringify(
               {
                   "clientId" : this.clientId,
                   "newFamilyName": this.title,
                   "disputeSubType": this.disputeSubType,
                   "disputeType": this.disputeType,
                   "assetType" : 'Opposition'
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

}