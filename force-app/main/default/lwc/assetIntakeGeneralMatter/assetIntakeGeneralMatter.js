import { LightningElement, track, api, wire } from "lwc";
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord,
    getRecord,
    getRecords,
    getFieldValue 
} from "lightning/uiRecordApi";

import { CurrentPageReference } from 'lightning/navigation';

import {
    closeTab,
    IsConsoleNavigation,
    EnclosingTabId,
    getFocusedTabInfo,
    setTabLabel,
    openTab,
    openSubtab,
    getTabInfo
} from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';

/* Import Objects and Fields */
import GENERAL_MATTER_OBJECT from "@salesforce/schema/SymphonyLF__General_Matter__c";
import CLIENT_OBJECT from "@salesforce/schema/SymphonyLF__Client__c";
import CONFLICT_CHECK_OBJECT from "@salesforce/schema/Conflict_Check__c";

import CLIENT_JURISDICTION_FIELD from "@salesforce/schema/SymphonyLF__Client__c.Jurisdiction__c";
import CREDIT_STATUS from "@salesforce/schema/SymphonyLF__Client__c.Credit_Status__c";

import CC_CLIENT_REFERENCE_NUMBER from "@salesforce/schema/Conflict_Check__c.Client_Reference_Number__c";
import MATTER_NAME from "@salesforce/schema/Conflict_Check__c.Matter_Name__c";

/* Import the Static Resources for Tabulator and FA Open source libraries*/
import MAXVALTABLECSS from "@salesforce/resourceUrl/MAXVALTABLECSS";
import MAXVALTABLEJS from "@salesforce/resourceUrl/MAXVALTABLEJS";
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";

/* Import Toast Events*/
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Import Apex Classes*/
import getClientEngagementModels from '@salesforce/apex/assetIntakeUtilities.getClientEngagementModelsNoIntakeId';
import submissionGeneralMatter from '@salesforce/apex/assetIntakeUtilities.submissionGeneralMatter';
import createDocketActivity from '@salesforce/apex/assetIntakeUtilities.createDocketActivity';


/* This scoped module imports the current user profile name and User Id */
import profileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';

const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100, 500];
const TABULATOR_BUTTON_ID_PREFIX = 'myButton';

const PERSON_RECORD_TYPE_INTERNAL = 'Internal';
const PERSON_RECORD_TYPE_EXTERNAL = 'External';

const TAB_LABEL = 'General Matter Intake Form';

export default class AssetIntakeGeneralMatter extends NavigationMixin(LightningElement) {
    
    /* API Variables for holding Client ID and Conflict Check ID */
    clientId = '';
    conflictCheckId = '';

    /* Variables for holding General Matter Information */ 
    generalMatterId = '';
    generalMatterObject = GENERAL_MATTER_OBJECT;
    generalMatterTitle = '';
    generalMatterReferenceNumber = '';
    generalMatterType = 'Pre-Filing Advice';
    generalMatterJurisdiction = '';
    generalMatterDescription = '';
    generalMatterCreditStatus = '';
    clientRecord = [];
    conflictCheckRecord = [];

    personnelRecordIdSelected = {};

    /* Store Client Engagement Data */ 
    clientEngagementData = [];

    /* UI Controlling Variables */ 
    isRenderedCallBackInitialized = false;

    currentFeatureSettingsMattersCreated = {
        "pagination": false
    };

    @wire(getRecord, {
        recordId: '$clientId',
        fields: [CLIENT_JURISDICTION_FIELD, CREDIT_STATUS],
    }) 
    wiredClient({ data, error }) {
        if (data) {
            console.log ('Client Data : ' + JSON.stringify(data))
            this.clientRecord = data;
            this.generalMatterJurisdiction = data.fields.Jurisdiction__c.value;
            this.generalMatterCreditStatus = data.fields.Credit_Status__c.value;
            this.error = undefined;
        } else if (error) {
            console.log ('Error : ' + JSON.stringify(error))
            this.error = error;
            this.clientRecord = undefined;
        }
    };

    @wire(getRecord, {
        recordId: '$conflictCheckId',
        fields: [CC_CLIENT_REFERENCE_NUMBER, MATTER_NAME],
    })  wiredConflictCheck({ data, error }) {
        if (data) {
            console.log ('Conflict Check Data : ' + JSON.stringify(data))
            this.conflictCheckRecord = data;
            this.generalMatterTitle = data.fields.Matter_Name__c.value;
            this.generalMatterReferenceNumber = data.fields.Client_Reference_Number__c.value;
            this.error = undefined;
        } else if (error) {
            console.log ('Error : ' + JSON.stringify(error))
            this.error = error;
            this.conflictCheckRecord = undefined;
        }
    };

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;
    @wire(CurrentPageReference) currentPageReference;
    
    async setCurrentTabLabel() {
        console.log('Console Navigation : ' + this.isConsoleNavigation);
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        setTabLabel(tabId, TAB_LABEL);
    }

    async connectedCallback() { 
        this.clientId = this.currentPageReference.state.c__clientId;
        this.conflictCheckId = this.currentPageReference.state.c__conflictCheckId;

        console.log ('In Connected Call Back');
        console.log ('Client ID : ' + this.clientId);
        console.log ('Conflict Check ID : ' + this.conflictCheckId);
        this.initializeDefaultValues();
        this.setCurrentTabLabel();

        console.log('Record ID : ' + this.clientId);
        
    }

    async loadStylesAndScripts(){
        try{
            console.log('BB Reached load styles and scripts');
            await loadScript(this, MAXVALTABLEJS).then(() => {
                loadStyle(this, MAXVALTABLECSS).then(() => {
                    loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css').then( async () => {
                        console.log('BB Scripts Loaded Successfully');
                        this.isRenderedCallBackInitialized = true;
                        console.log('Reached load styles and scripts completed');
                        const response = await getClientEngagementModels ({ clientId: this.clientId});
        
                            this.clientEngagementData = JSON.parse(JSON.stringify(response));  
                            console.log(JSON.stringify(response));  
                            
                            this.clientEngagementData.forEach(e => {
                                this.personnelRecordIdSelected[  e.recordId + '-' + e.type ] = e.recordId + '-' + e.type;
                            });


                        this.initializeClientPersonnel();         
                    });
                });
            });
        }catch(err){
            console.error('BB JS Error : loadStylesAndScripts');
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

    initializeDefaultValues() { 
        // this.generalMatterTitle = this.matterName;
        // this.generalMatterReferenceNumber = this.clientReferenceNumber;
        // this.generalMatterJurisdiction = this.clientJurisdiction;
        console.log ('General Matter Title            : ' + this.generalMatterTitle);
        console.log ('General Matter Reference Number : ' + this.generalMatterReferenceNumber);
        console.log ('General Matter Jurisdiction     : ' + this.generalMatterJurisdiction);
    }

    async renderedCallback() { 
        console.log ('In Rendered Call Back');
        if (this.isRenderedCallBackInitialized) {
            return;
        }
        this.isRenderedCallBackInitialized = true;
        await this.loadStylesAndScripts();
        this.initializeDefaultValues();
    }

    paginationFalse = false;
    personnelTable;
    initializeClientPersonnel() {
        try{
            console.log('JS BB initializeClientPersonnel');
        
        this.component = this.template.querySelector('[data-id="clientEngagementTable"]');
        console.log('In Initialize Client Personnel');
        let sfdcURL = this.baseURL;
        this.personnelTable = new Tabulator(this.component, {
            height:"100%",
            layout:"fitColumns",
            resizableColumns:true,
            selectable:false,
            data:this.clientEngagementData,
            pagination:"local",
            paginationSize:25,
            responsiveLayout:"collapse",
            columns:[
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
                    formatter: (cell, formatterParams) => {
                        var value = cell.getValue();
                        let recordId = cell.getRow().getData().recordId;
        
                        let output = this.spanFormatter(cell, formatterParams);
        
                        let hyperlink = document.createElement("a");
                        let href = this.sfdcURL + "/" + recordId;
                        hyperlink.href = href
                        hyperlink.textContent = ( value ? value : '' );
                        hyperlink.addEventListener("click", (event) => {
                            event.preventDefault();
        
                            if(recordId){
                                if (this.isConsoleNavigation) {
                                    this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
                                }
                                else {
                                    window.open(href);
                                 }
                            }
                        });
        
                        output.appendChild(hyperlink);
                        return output;
                    },
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
                    formatter: (cell, formatterParams) => {
                        try {
                            var value = cell.getValue();
        
                            let output = this.spanFormatter(cell, formatterParams);
        
                            if (!value) {
                                value = '';
                            }
                            output.textContent = value;
        
                            return output;
                        } catch (err) {
                         //   alert('JS Error ::  :: formatByType :: else');
                            console.error(this.serializeError(err));
                        }
                    },
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
                    formatter: (cell, formatterParams) => {
                        var value = cell.getValue();
                        let recordId = cell.getRow().getData().contactRecordId;
        
                        let output = this.spanFormatter(cell, formatterParams);
        
                        let hyperlink = document.createElement("a");
                        let href = this.sfdcURL + "/" + recordId;
                        hyperlink.href = href
                        hyperlink.textContent = ( value ? value : '' );
                        hyperlink.addEventListener("click", (event) => {
                            event.preventDefault();
        
                            if(recordId){
                                if (this.isConsoleNavigation) {
                                    this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
                                }
                                else {
                                    window.open(href);
                                 }
                            }
                        });
        
                        output.appendChild(hyperlink);
                        return output;
                    },
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
                    formatter: (cell, formatterParams) => {
                        try {
                            var value = cell.getValue();
        
                            let output = this.spanFormatter(cell, formatterParams);
        
                            if (!value) {
                                value = '';
                            }
                            output.textContent = value;
        
                            return output;
                        } catch (err) {
                         //   alert('JS Error ::  :: formatByType :: else');
                            console.error(this.serializeError(err));
                        }
                    },
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
            ]
        });

        console.log('Record ID : ' + this.recordId);

        }
        catch(err){
            alert('JS Error :: initializeClientPersonnel');
            console.error(err);
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

     async handleCheckboxClick(event, cell) {
        try{
        // Stop propagation to avoid triggering other cell events
        event.stopPropagation();

        const rowData = cell.getRow().getData();
        const isSelected = rowData.isSelected;
        const recordId = rowData.recordId;
        const personnelId = rowData.contactRecordId;
        const type = rowData.type;
        const key = recordId + '-' + type;
        console.log('Row Data : ' + JSON.stringify(rowData));

        const checkbox = event.target;

        console.log('checkbox:', JSON.stringify(checkbox));
        console.log('checkbox.checked:', checkbox.checked );
        console.log('isSelected ', isSelected);
        if (!isSelected) {
            this.personnelRecordIdSelected[key] = key;
                rowData.isSelected = true;
        } else {
            delete this.personnelRecordIdSelected[key];
            rowData.isSelected = false;
        }

        let sortedData = this.personnelTable.getData().sort((a, b) => {
            return (b.isSelected === true) - (a.isSelected === true);
        });

        window.setTimeout(() => {
            this.personnelTable.setData(sortedData);
        }, 200);
        
    }catch(err){
        alert('JS Error :: assetIntakeFormPersonnelDetails :: handleCheckboxClick');
        this.handleAllErrorTypes(err);
    }

    }

    sfdcURL = window.location.origin;
    showGeneratedMatters = false;
    generatedMatterRecords = [];
    generatedMatterColumns = [
        // {
        //     title: "Docket No.",
        //     field: "docketNumber",
        //     headerFilter: false,
        //     type: "recordlink",
        //     formatter: (cell, formatterParams) => {
        //         var value = cell.getValue();
        //         let recordId = cell.getRow().getData().recordId;

        //         let output = this.spanFormatter(cell, formatterParams);

        //         let hyperlink = document.createElement("a");
        //         let href = this.sfdcURL + "/" + recordId;
        //         hyperlink.href = href
        //         hyperlink.textContent = ( value ? value : '' );
        //         hyperlink.addEventListener("click", (event) => {
        //             event.preventDefault();

        //             if(recordId){
        //                 // if (this.isConsoleNavigation) {
        //                 //     this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
        //                 // }
        //                 // else {
        //                     window.open(href);
        //                 // }
        //             }
        //         });

        //         output.appendChild(hyperlink);
        //         return output;
        //     },
        //     formatterParams: {
        //         recordIdField: "recordId",
        //         classList: [],
        //         styleList: [
        //             {
        //                 property: "font-weight",
        //                 value: "bold",
        //             },
        //         ],
        //     },
        // },
        {
            title: "Title",
            field: "title",
            formatter: (cell, formatterParams) => {
                try {
                    var value = cell.getValue();
                    let recordId = cell.getRow().getData().recordId;

                    let output = this.spanFormatter(cell, formatterParams);

                    let hyperlink = document.createElement("a");
                    let href = this.sfdcURL + "/" + recordId;
                    hyperlink.href = href
                    hyperlink.textContent = ( value ? value : '' );
                    hyperlink.addEventListener("click", (event) => {
                        event.preventDefault();

                        if(recordId){
                            // if (this.isConsoleNavigation) {
                            //     this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
                            // }
                            // else {
                                window.open(href);
                            // }
                        }
                    });

                    output.appendChild(hyperlink);
                    return output;
                } catch (err) {
                 //   alert('JS Error ::  :: formatByType :: else');
                    console.error(this.serializeError(err));
                }
            },
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
            field: "caseType",
            formatter: (cell, formatterParams) => {
                try {
                    var value = cell.getValue();

                    let output = this.spanFormatter(cell, formatterParams);

                    if (!value) {
                        value = '';
                    }
                    output.textContent = value;

                    return output;
                } catch (err) {
                 //   alert('JS Error ::  :: formatByType :: else');
                    console.error(this.serializeError(err));
                }
            },
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
            title: "Jurisdiction",
            field: "jurisdiction",
            formatter: (cell, formatterParams) => {
                try {
                    var value = cell.getValue();

                    let output = this.spanFormatter(cell, formatterParams);

                    if (!value) {
                        value = '';
                    }
                    output.textContent = value;

                    return output;
                } catch (err) {
                 //   alert('JS Error ::  :: formatByType :: else');
                    console.error(this.serializeError(err));
                }
            },
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

    spanFormatter(cell, formatterParams) {
        try {
            let output = document.createElement("span");

            if (formatterParams.classList) {
                formatterParams.classList.forEach(each => {
                    output.classList.add(each);
                });
            }

            if (formatterParams.classListFunction) {
                formatterParams.classListFunction(cell)?.forEach(each => {
                    output.classList.add(each);
                });
            }

            if (formatterParams.styleList) {
                formatterParams.styleList.forEach(each => {
                    output.style[each.property] = each.value;
                });
            }

            return output;
        } catch (err) {
         //   alert('JS Error ::  :: spanFormatter')
            console.error(err)
        }
    }

    generatedMatterRecordId;
    loading = false;
        handleSubmit(){        
            if (!this.generalMatterTitle || !this.generalMatterType) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Required fields must be filled',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                return;
            }
        
            try{

            this.loading = true;
            submissionGeneralMatter({
                "clientId": this.clientId
                , "conflictCheckId": this.conflictCheckId
                , "generalMatterTitle": this.generalMatterTitle
                , "generalMatterReferenceNumber": this.generalMatterReferenceNumber
                , "generalMatterType": this.generalMatterType
                , "generalMatterJurisdiction": this.generalMatterJurisdiction
                , "generalMatterDescription": this.generalMatterDescription
                , "generalMatterCreditStatus": this.generalMatterCreditStatus
                , "personnelRecordIdSelected": Object.keys(this.personnelRecordIdSelected)
            })
            .then(( response )=>{
               // location.reload();
               this.generatedMatterRecords = response;
               this.generatedMatterRecordId = response[0].recordId;
               this.showGeneratedMatters = true;

               window.setTimeout(()=>{
                let component = this.template.querySelector('[data-id="generatedMattersTable"]');
                console.log('In Initialize Client Personnel');
              //  let sfdcURL = this.baseURL;
                var table = new Tabulator(component, {
                    height:"100%",
                    layout:"fitColumns",
                    resizableColumns:true,
                    selectable:false,
                    data:this.generatedMatterRecords,
                    pagination:false,
                    paginationSize:25,
                    responsiveLayout:"collapse",
                    columns:this.generatedMatterColumns
                });
               },200);
            })
            .catch((err)=>{
                alert('Server Error :: LwcMvIntakeFormJurisdiction :: handleSubmit :: apexMethod => submission');
                this.handleAllErrorTypes(err);
            })
            .finally(()=>{
                this.loading = false;
            })
           }catch(err){
               alert('JS Error ::  :: handleSubmit')
               console.error(err)
           }
        }

        handleReset() {
            this.closeTab();
            this.navigateToCCdashboard();
        }

        async handleClose(){
            this.showGeneratedMatters = false;
            this.closeTab();
            this.navigateToCCdashboard();
         }

         async closeTab() {
            if (!this.isConsoleNavigation) {
                return;
            }
        
            const tabInfo = await getFocusedTabInfo();
            console.log('tab info--->',tabInfo);
            const tabId = tabInfo ? tabInfo.tabId : null;
            console.log('Jurisdiction tabId-->' + tabId); 
                if (tabId) {
                    closeTab(tabId); 
                }
                // WorkspaceApi.openSubtab({
                //     parentTabId: tabInfo.parentTabId
                // }).then(() => {
                //     console.log('Successfully navigated to the subtab!');
                // })
        }

        navigateToCCdashboard() {
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'Conflict_Check_Dashboard'
                },
                state: {
                    refresh: true  // Set this to true to refresh the page when navigating to the same page
                }
            });
        }
    
        handleGeneralMatterTitle(event) {
            this.generalMatterTitle = event.target.value;
        }

        handleClientReferenceNumber(event) {
            this.generalMatterReferenceNumber = event.target.value;
        }

        handleGeneralMatterType(event) {
            this.generalMatterType = event.target.value;
        }

        handleJurisdictionValue(event) {
            this.generalMatterJurisdiction = event.target.value;
        }

        handleCreditStatus(event) {
            this.generalMatterCreditStatus = event.target.value;
        }

        handleDescription(event) {
            this.generalMatterDescription = event.target.value;
        }

        showDocket = true;
        handleSubmitDocket(event){
            if(this.loading){
                event.preventDefault();
                return;
            }
            this.loading = true;
        }

        get options() {
            return [
                { label: 'Hard', value: 'Hard Docket' },
                { label: 'Soft', value: 'Soft Docket' }
            ];
        }

        handleSubmitDocketActivity(){
            try{

            
            if(this.loading){
                return;
            }
            this.loading = true;

            const allValid = [...this.template.querySelectorAll('.docketActivityClass')]
                .reduce((validSoFar, input) => {
                    input.reportValidity(); // shows message
                    return validSoFar && input.checkValidity();
                }, true);

            if (allValid) {
                console.log('Form is valid!');
                // Proceed with Apex call or form processing
            } else {
                console.log('Form has errors.');
                this.loading = false;
                return;
            }

            let data = {};

            this.template.querySelectorAll('.docketActivityClass').forEach(element => {
                data[element.name] = element.value;
            });

            console.log('JSON.stringify(data) ', JSON.stringify(data));
            createDocketActivity({
                "data" : JSON.stringify(data)
            })
            .then(()=>{
                this.handleSuccessDocket();
            })
            .catch((err)=>{
                console.log('Error : ' + JSON.stringify(err));
                this.handleErrorDocket();
            });

        }catch(err){
             console.error('JS Error handleSubmitDocketActivity');   
             console.error(err);
        }
        }

        handleSuccessDocket(event){
            this.showDocket = false;
            this.loading = false;
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: 'Docket has been created.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        }

        handleErrorDocket(event){
            this.loading = false;

            const evt = new ShowToastEvent({
                title: 'Error!',
                message: 'Error in creating docket activity.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
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
                this.openAsNewTab(type, objectApiName, recordId, actionName);
                /*
                alert('JS Error : lwcMvDatatable : findEnclosingTabAndOpenSubtab');
                try{
                    console.error(this.serializeError(err));
                }catch(e){}
    
                try{
                    console.error(err);
                    console.error(JSON.stringify(err));
                }catch(e){}
                
    */
            }
    
        }
    
        async openAsNewTab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
            try {
                // Open sub tab
                await openTab({
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
              //  alert('JS Error : lwcMvDatatable : openAsNewTab');
                try {
                    console.error(this.serializeError(err));
                } catch (e) { }
    
                try {
                    console.error(err);
                    console.error(JSON.stringify(err));
                } catch (e) { }
    
            }
    
        }
}