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

import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

import { CurrentPageReference } from 'lightning/navigation';

import {
    closeTab,
    IsConsoleNavigation,
    EnclosingTabId,
    getFocusedTabInfo,
    setTabLabel,
    setTabIcon,
    openTab,
    openSubtab,
    getTabInfo
} from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';

/* Import Objects and Fields */
import GENERAL_MATTER_OBJECT from "@salesforce/schema/SymphonyLF__General_Matter__c";
import CLIENT_OBJECT from "@salesforce/schema/SymphonyLF__Client__c";
import CONFLICT_CHECK_OBJECT from "@salesforce/schema/Conflict_Check__c";
import ASSET_INTAKE_OBJECT from "@salesforce/schema/Asset_Intake_Form__c";

import CLIENT_JURISDICTION_FIELD from "@salesforce/schema/SymphonyLF__Client__c.Jurisdiction__c";
import CREDIT_STATUS from "@salesforce/schema/SymphonyLF__Client__c.Credit_Status__c";
import CLIENT_STATUS from "@salesforce/schema/SymphonyLF__Client__c.Client_Status__c";

import CC_CLIENT_REFERENCE_NUMBER from "@salesforce/schema/Conflict_Check__c.Client_Reference_Number__c";
import MATTER_NAME from "@salesforce/schema/Conflict_Check__c.Matter_Name__c";

/* Import the Static Resources for Tabulator and FA Open source libraries*/
import MAXVALTABLECSS from "@salesforce/resourceUrl/MAXVALTABLECSS";
import MAXVALTABLEJS from "@salesforce/resourceUrl/MAXVALTABLEJS";
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";

/* Import Toast Events*/
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* This scoped module imports the current user profile name and User Id */
import profileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';

const TAB_LABEL = 'Matter Intake Form';

export default class MatterIntakeForm extends NavigationMixin(LightningElement) {
    // Make a Component Aware of Its Record Context
    clientId = '';
    conflictCheckId = '';
    matterType = '';

    /* Common Variables */
    isSpinner = false; 
    spinnerText = '';
    isRenderedCallBackInitialized = false;
    baseURL;
    tabId='';
    isPatent = false;
    isTrademark = false;
    clientRecord = [];
    conflictCheckRecord = [];
    clientJurisdiction = '';
    clientCreditStatus = '';
    clientStatus = '';
    matterTitle = '';
    matterReferenceNumber = '';
    assetIntakeObject = ASSET_INTAKE_OBJECT;
    assetIntakeId = '';

    /* Variables for Matters */
    // newPatentFamilyName = '';
    existingFamily = '';
    isNew = false;
    departmentValue = '';
    _wiredDraftRecords = []; // Use Only for Refresh
    draftIntakeRecords = [];
    draft


    @track patentBreadcrumb = JSON.parse('[{"id":1,"labelName":"Basic Details","URL":"#" ,"className":"active" }' +
        ',{"id":2,"labelName":"Personnel"          ,"URL":"#" ,"className":""}' +
        ',{"id":3,"labelName":"Applicants"         ,"URL":"#" ,"className":""}' +
        ',{"id":4,"labelName":"Innovators"         ,"URL":"#" ,"className":""}' +
        ',{"id":5,"labelName":"Jurisdiction"       ,"URL":"#" ,"className":""}' +
        ']');

    @track trademarkBreadcrumb = JSON.parse('[{"id":1,"labelName":"Basic Details","URL":"#" ,"className":"active" }' +
            ',{"id":2,"labelName":"Personnel"          ,"URL":"#" ,"className":""}' +
            ',{"id":3,"labelName":"Applicants"         ,"URL":"#" ,"className":""}' +
            ',{"id":4,"labelName":"Classes & Goods"    ,"URL":"#" ,"className":""}' +
            ',{"id":5,"labelName":"Jurisdiction"       ,"URL":"#" ,"className":""}' +
            ']');

    @track breadcrumb;
    @track breadcrumbWidth = "width:20%";
        
    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;
    @wire(CurrentPageReference) currentPageReference;

    @wire(getRecord, {
        recordId: '$clientId',
        fields: [CLIENT_JURISDICTION_FIELD, CREDIT_STATUS, CLIENT_STATUS],
    }) 
    wiredClient({ data, error }) {
        if (data) {
            console.log ('Client Data : ' + JSON.stringify(data))
            this.clientRecord = data;
            this.clientJurisdiction = data.fields.Jurisdiction__c.value;
            this.clientCreditStatus = data.fields.Credit_Status__c.value;
            this.clientStatus = data.fields.Client_Status__c.value;    
            this.error = undefined;
            console.log('Client Status ' + this.clientStatus);
            if(this.clientStatus != 'Active' || this.clientStatus === null) {
                const evt = new ShowToastEvent({
                    title   : 'Error!',
                    message : 'You cannot create a matter with an inactive client. Please activate the client by creating a General Matter and try again.',
                    variant : 'error',
                    mode    : 'dismissable'
                });
                this.dispatchEvent(evt);
                return;
            }

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
            this.matterTitle = data.fields.Matter_Name__c.value;
            this.matterReferenceNumber = data.fields.Client_Reference_Number__c.value;
            this.error = undefined;
        } else if (error) {
            console.log ('Error : ' + JSON.stringify(error))
            this.error = error;
            this.conflictCheckRecord = undefined;
        }
    };

    async setCurrentTabLabel() {
        console.log('Console Navigation : ' + this.isConsoleNavigation);
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        setTabLabel(tabId, TAB_LABEL);
        setTabIcon( tabId, 'utility:einstein', {
            iconAlt: 'Account Insights'
        });
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Asset_Intake_Form__r', // custom Object(Child to Parent)
        fields: [ 'Asset_Intake_Form__c.Name'
                , 'Asset_Intake_Form__c.Client__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Default_Instruction__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Instruction_Deadline__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Instruction_Window__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Is_Active__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Renewal_Start_Date__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Renewal_Stop_Date__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Start_Month__c'
                , 'Asset_Intake_Form__c.SymphonyLF__Default_Billing_Currency__c'
                ],
     })
    wiredDraftRecords(result) {
        this._wiredDraftRecords = result;
        const { data, error } = result;
        if (data) {
            // keep clone for display
            this.draftIntakeRecords = JSON.parse(JSON.stringify(data.records));
            // if the table already exists, just replace its data
            if (this.table) {
                this.table.replaceData(this.draftIntakeRecords);
            }
        }else if (error) {
            console.error('Renewal Configuration Error : ', error);           
            this.draftIntakeRecords = undefined;
        }
    }

    connectedCallback() { 
        this.setCurrentTabLabel();
        this.clientId = this.currentPageReference.state.c__clientId;
        this.conflictCheckId = this.currentPageReference.state.c__conflictCheckId;
        this.matterType = this.currentPageReference.state.c__matterType;
        console.log ('Client ID : ' + this.clientId);
        console.log ('Conflict Check ID : ' + this.conflictCheckId);
        if(this.clientId === undefined || this.matterType === undefined || this.conflictCheckId === undefined) {
            const evt = new ShowToastEvent({
                title   : 'Error!',
                message : 'Client ID, Conflict Check Id and Matter Type are mandatory parameters for creating a matter.',
                variant : 'error',
                mode    : 'dismissable'
            });
            this.dispatchEvent(evt);
        } else { 
            if(this.matterType === 'Patent') { 
              this.isPatent = true;  
              this.isTrademark = false;
            }
        }
    }

    async loadStylesAndScripts(){
        try{
            await loadScript(this, MAXVALTABLEJS).then(() => {
                loadStyle(this, MAXVALTABLECSS).then(() => {
                    loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css').then( async () => {
                        this.isRenderedCallBackInitialized = true;
                        console.log('Scripts Loaded Successfully');
                        // this.initializeClientPersonnel();         
                    });
                });
            });
        }catch(err){
            console.error('Unable to load Scripts/Styles');
        }
    }

    async renderedCallback() {
        console.log ('In Rendered Call Back');
        if (this.isRenderedCallBackInitialized) {
            return;
        }
        this.isRenderedCallBackInitialized = true;
        await this.loadStylesAndScripts();
        console.log ('Client Status : ' + this.clientStatus);

    }

    handleMatterTitle(event) {
        try{
            this.matterTitle = event.target.value;
            this.existingFamily = "";
            this.isNew = true;
        }catch(err){
            console.log('Error Occured in handling Matter Title : ' + err );
        }
    }

    handleDepartmentChange(event) {
        try{
        console.log('Event Values : ' + JSON.stringify(event.target));
        this.newDepartment = event.target.value;

        }catch(err){
            console.log('Error Occured in handling Department Change : ' + err );
        }
    }
}