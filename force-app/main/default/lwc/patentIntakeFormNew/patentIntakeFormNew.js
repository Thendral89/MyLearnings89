import { LightningElement, track, wire, api } from 'lwc';
import FA from "@salesforce/resourceUrl/FA";
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import CLIENT_OBJECT from '@salesforce/schema/SymphonyLF__Client__c';
import savePatentFamilyAndEngagements from '@salesforce/apex/PatentIntakeFormNewHelper.savePatentFamilyAndEngagements';
import dynamicQueryRecords from '@salesforce/apex/PatentIntakeFormNewHelper.DynamicQueryRecords';
import updateIntakeFormDraftedAt from '@salesforce/apex/PatentIntakeFormNewHelper.updateIntakeFormDraftedAt';
import createPatentRecordForJurisdiction from '@salesforce/apex/PatentIntakeFormNewHelper.createPatentRecordForJurisdiction';
import { getRecord } from 'lightning/uiRecordApi';
import searchApplicants from '@salesforce/apex/PatentIntakeFormNewHelper.searchApplicants';
import createPatentInventors from '@salesforce/apex/PatentIntakeFormNewHelper.createPatentInventors';
import searchInventors from '@salesforce/apex/PatentIntakeFormNewHelper.searchInventors';
import createNewClients from '@salesforce/apex/PatentIntakeFormNewHelper.createNewClients';
import createChainOfTitleRecords from '@salesforce/apex/PatentIntakeFormNewHelper.createChainOfTitleRecords';
import getExistingPatentFamilyDetails from '@salesforce/apex/PatentIntakeFormNewHelper.getExistingPatentFamilyDetails';
import createNewPersons from '@salesforce/apex/PatentIntakeFormNewHelper.createNewPersons';
import PERSON_OBJECT from "@salesforce/schema/SymphonyLF__Person__c";
import getPicklistValuesPersonClient from '@salesforce/apex/PatentIntakeFormNewHelper.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CLIENT_ID_GROUPNUMBER from '@salesforce/schema/SymphonyLF__Client__c.SymphonyLF__Client_Group_Number__c';
const CLIENT_FIELDS = [CLIENT_ID_GROUPNUMBER];

import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    openSubtab,
} from 'lightning/platformWorkspaceApi';


import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import getClientEngagementModels from '@salesforce/apex/mvLawfirmUtilities.getClientEngagementModels';


export default class PatentIntakeFormNew extends LightningElement {

    @track patentBreadcrumb = JSON.parse('[{"id":1,"labelName":"Basic Details","URL":"#" ,"className":"active" }' +
        ',{"id":2,"labelName":"Applicants"       ,"URL":"#" ,"className":""}' +
        ',{"id":3,"labelName":"Inventors"       ,"URL":"#" ,"className":""}' +
        ',{"id":4,"labelName":"Jurisdiction"       ,"URL":"#" ,"className":""}' +
        // ',{"id":4,"labelName":"Category and Keywords"       ,"URL":"#" ,"className":""}' +
        ']');


    @track breadcrumb = this.patentBreadcrumb;
    @track breadcrumbWidth = "width:25%";
    @track showBasicDetails = true;
    @track showInventorDetails= false;
    @track showApplicantDetails = false;
    @track showJurisdictionDetails = false; 
    @track showBusinessCategoryAndInventorDetails = false;

    @track markType = '';
    @track markRecordTypeId = '';
    @track markTypeView = '';

    @api clientId='a0TWr000006j3CnMAI';
    @api draftedPatentFamilyId='a18Wr000002oQFtIAM';
    @api shortTitle;
    @api inventionTitle;
    @api existingPatentFamilyRecordId;
    @track loading = true;
    @track engagementDetailsPF = [];
    showPatentApplications = false;
    activeSections = ['businessCategory', 'jurisdictionSection'];
    clientFieldNames = 'Name';
    clientfieldsToQuery = 'Name';
    clientWhereCond = '';
    readonly = false;
    
    @track engagementDetails = [];
    @track engagementColumns = [];
    @track selectedEngagementDetails=[];
    @track deletedEngagementDetails=[];
    @track patentFamilyId = null; 
    @track assetTypeOptions = [];
    @track showDropdownApplicants= false;
    @track noResults = false;
    @track noResultsApplicant = false;
    @track selectedApplicants=[];
    @track selectedInventors=[];
    @track alreadyAddedApplicantsToExclude = [];
    @track inputValueApplicant = '';
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy = 'Name';
    @track applicantData=[];
    @track inventorOptions = [];
    @track excludedInventorIds = [];
    
    @track showDropdownInventors = false;
    @track activeTab = 'selectedApplicants';
    @track inventorInputValue='';
    @track inventortype = 'Client';
    @track contactType = 'Inventor';
	classification = 'Applicant';
    @track stateOptions = [];
    @track isButtonDisabled = false;

    applicantName = '';
    defaultCurrency = '';
    @track entitySize = '';
    @track currency = '';
    @track address = {
        street: '',
        city: '',
        state: '',
        country: '',
        postalCode: ''
    };
    @track applicantOptions = [];
    @track inventorStateOptions = [];
    @track inventorCountryOptions = [];
    @track countryOptions = [];
    @track newApplicants = []; 
    @track applicantColumns = [];
    @track inventorColumns=[];
    

    @track personName = '';
    @track user = '';
    @track nationality = '';
    @track emailAddress = '';
    @track phone = '';
    @track inventorAddress = { 
        street: '',
        city: '',
        state: '',
        country: '',
        postalCode: ''
    }; 
    @track inventorData = [];
    @track newInventors=[];
    @track nationalityOptions = [];
    @track personRecordTypeId;
    
    @track isExistingPatentFamily = false;
    @track existingMEMColumns =[];
    @track existingMEMDetails=[];

    @track intakeFormDraftedAt = 'Basic Details';
    @track classificationOptions=[
        {"label":"Applicant","value":"Applicant"},
        {"label":"Assignee","value":"Assignee"},
        {"label":"Licensee","value":"Licensee"},
        {"label":"Assignor","value":"Assignor"},
        {"label":"Licensor","value":"Licensor"}
    ];
    @track entitySizeOptions=[];
    @track selectedValues = ['Applicant'];
    @track selectedLabels = 'Applicant';
    @track isTableLoaded= false;


    @track deletedChainOfTitles=[];
    @track deletedInventorDesigner=[];

    @track jurisdictionColumns = [];
    @track jurisdictionGroup = [];
   // @track jurisdictionRecords;
    @track jurisdictionRecords = [
        {
            id: "1",             
            CaseType: "Primary",    
            Country: "US",       
            ClientRefNumber: ""     
        }
    ];
    @track jurisdictions = [];
    @track caseTypesPatent=[];

    @track defaultUSJurisdictionId;
    @track defaultCaseTypeValue='Primary';


    navigateToBusinessCategoryAndInventors() { 
        this.showBasicDetails = false;
        this.showApplicantDetails = false;
        this.showBusinessCategoryAndInventorDetails = true;
        this.showJurisdictionDetails = false;
        this.showInventorDetails=false;
        this.patentBreadcrumb[0].className="";
        this.patentBreadcrumb[1].className="active";
        this.patentBreadcrumb[2].className="";
        this.patentBreadcrumb[3].className="";
        this.patentBreadcrumb[4].className="";
    }

    navigateToApplicantDetails() { 
        this.showBasicDetails = false;
        this.showApplicantDetails = true;
        this.showInventorDetails=false;
        this.showBusinessCategoryAndInventorDetails = false;
        this.showJurisdictionDetails = false;
        this.patentBreadcrumb[0].className="";
        this.patentBreadcrumb[1].className="active";
        this.patentBreadcrumb[2].className="";
        this.patentBreadcrumb[3].className="";
        //this.patentBreadcrumb[4].className="";
    }
    navigateToInventorDetails() { 
        this.showBasicDetails = false;
        this.showApplicantDetails = false;
        this.showInventorDetails=true;
        this.showBusinessCategoryAndInventorDetails = false;
        this.showJurisdictionDetails = false;
        this.patentBreadcrumb[0].className="";
        this.patentBreadcrumb[1].className="";
        this.patentBreadcrumb[2].className="active";
        this.patentBreadcrumb[3].className="";
        //this.patentBreadcrumb[4].className="";
    }

    navigateToBasicDetails() {
        this.showBasicDetails = true;
        this.showApplicantDetails = false;
        this.showBusinessCategoryAndInventorDetails = false;
        this.showJurisdictionDetails = false;
        this.showInventorDetails=false;
        this.patentBreadcrumb[0].className="active";
        this.patentBreadcrumb[1].className="";
        this.patentBreadcrumb[2].className="";
        this.patentBreadcrumb[3].className="";
       // this.patentBreadcrumb[4].className="";
    }

    navigateToJurisdictionDetails() {
        this.showBasicDetails = false;
        this.showApplicantDetails = false;
        this.showBusinessCategoryAndInventorDetails = false;
        this.showJurisdictionDetails = true;
        this.showInventorDetails=false;
        this.patentBreadcrumb[0].className="";
        this.patentBreadcrumb[1].className="";
        this.patentBreadcrumb[2].className="";
        this.patentBreadcrumb[3].className="active";
       // this.patentBreadcrumb[4].className="";
    }

    // @wire(CurrentPageReference)
    // pageRef({ state }) {
    //     if (state) {
    //         this.clientId = state.c__clientId;
    //         this.shortTitle = state.c__shortTitle;
    //         this.inventionTitle = state.c__inventionTitle;
    //         this.existingPatentFamilyRecordId = state.c__existingPatentFamilyRecordId;
    //         this.draftedPatentFamilyId= state.c__draftedPatentFamilyId;
    //     }
    //    // this.checkLoadingStatus();
    // }
    
    @wire(getObjectInfo, { objectApiName: PERSON_OBJECT })
    Function({ error, data }) {
        if (data) {
            let objArray = data.recordTypeInfos;
            for (let i in objArray) {
                if (objArray[i].name === 'External')
                    this.personRecordTypeId = objArray[i].recordTypeId
                console.log('OUTPUT : this.personRecordTypeId', this.personRecordTypeId);
            }
        } else if (error) {
            console.log(JSON.stringify(error))
        }
      //  this.checkLoadingStatus();
    };


    @wire(getRecord, { recordId: '$clientId', fields: CLIENT_FIELDS })
    wiredClient({ error, data }) {
        console.log('data of clientId:', JSON.stringify(data));
        if (data) {
            this.clientGroupNumber = data.fields.SymphonyLF__Client_Group_Number__c.value;
            console.log('this.clientGroupNumber:', this.clientGroupNumber);
        } else if (error) {
            console.log('error fetching client group number:', error);
            //this.showToast('Error', 'Failed to fetch Client Group Number', 'error');
        }
       // this.checkLoadingStatus();
    }
    

    @wire(getPicklistValuesPersonClient)
    wiredPicklistValues({ error, data }) {
        if (data) {
            console.log('data for picklist entity size:', JSON.stringify(data));
            if (data.clientFields) {
                data.clientFields.forEach(field => {
                    switch (field.value) {
                        // case 'SymphonyLF__Client_Classification__c':
                        //     this.classificationOptions = field.picklistValues || [];
                        //     console.log('Classification Options:', JSON.stringify(this.classificationOptions));
                        //     break;
                        case 'SymphonyLF__Entity_Size__c':
                            this.entitySizeOptions = field.picklistValues || [];
                            console.log('Entity Size Options:', JSON.stringify(this.entitySizeOptions));
                            break;
                    }
                });
            }
            if (data.personFields) {
                data.personFields.forEach(field => {
                    if (field.value === 'SymphonyLF__Nationality__c') {
                        this.nationalityOptions = field.picklistValues || [];
                        console.log('this.nationalityOptions::', JSON.stringify(this.nationalityOptions));
                    }
                });
            }
            if (data.patentFields) {
                data.patentFields.forEach(field => {
                    switch (field.value) {
                        case 'SymphonyLF__Case_Type__c':
                            this.caseTypesPatent = field.picklistValues || [];
                            console.log('Case Types Patent:', JSON.stringify(this.caseTypesPatent));
                            break;
                    }
                });
            }
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
      //  this.checkLoadingStatus();
    }

    @wire(getObjectInfo, { objectApiName: CLIENT_OBJECT })
    objectInfo;

    map_CountryPicklistValues = new Map();
    @wire(getPicklistValuesByRecordType, {
            objectApiName: CLIENT_OBJECT,
            recordTypeId: '$objectInfo.data.defaultRecordTypeId',
           // recordTypeId: '012000000000000AAA',
        })
    wiredPicklistValuesForCountry({ error, data }) {
            if (data) {
                 const countryPicklistValues1 = data.picklistFieldValues.SymphonyLF__Address__CountryCode__s.values;
               
                countryPicklistValues1.map(picklistValue => {
                        this.map_CountryPicklistValues.set(picklistValue.label, picklistValue.value);
                        console.log(' this.map_CountryPicklistValues::', JSON.stringify( this.map_CountryPicklistValues));
                });
            } else if (error) {
                console.error('Error fetching picklist values:', error);
            }
         //   this.checkLoadingStatus();
    }

    
    isRenderedCallBackInitialized = false;
    renderedCallback() {
        try {
            if (this.isRenderedCallBackInitialized) return;
            this.isRenderedCallBackInitialized = true;

            Promise.all([
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
                .then(() => {
                });
        } catch (err) {
           // alert('JS Error ::  :: renderedCallback')
            console.error(err)
        }
    }

    

    connectedCallback(){

        console.log('inventionTitle::', this.inventionTitle);
        console.log('clientId::', this.clientId);
        console.log('shortTitle::', this.shortTitle);
        
        if(this.clientId){
            this.fetchClientEngagementModels();
            this.fetchJurisdictionDetails();
        }
        if (this.existingPatentFamilyRecordId || this.draftedPatentFamilyId) {
            this.fetchExistingPatentFamilyDetails();
            this.isExistingPatentFamily = this.existingPatentFamilyRecordId ? true : false;
        }
        this.prepareColumns();        
        
        //this.checkLoadingStatus();

        this.isTableLoaded= true;
        this.loading= false;        
    }

    fetchClientEngagementModels() {
        getClientEngagementModels({ recordId: this.clientId })
            .then((response) => {
                try {
                    console.log('response CEM:', JSON.stringify(response));
                    this.engagementDetails = response;
                    console.log('this.engagementDetails:', JSON.stringify(this.engagementDetails));
                    this.updateEngagementTableData(this.engagementDetails);
                } catch (err) {
                    console.error('Error processing response:', err);
                   // this.showErrorToast('Error processing server response.');
                }
            })
            .catch((error) => {
                console.error('Server Error:', error);
                //this.showErrorToast('Error fetching engagement models from the server.');
            });
    }

    fetchJurisdictionDetails() {
        // getJurisdictionDetail({ clientId: this.clientId })
        //     .then(result => {
        //         this.jurisdictionGroup = result.jurisdictionGroup;
        //         this.jurisdictions = result.jurisdictions;
        //         console.log('Jurisdiction Groups:', JSON.stringify(this.jurisdictionGroup));
        //         console.log('Countries:', JSON.stringify(this.jurisdictions));
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         console.error('Error fetching jurisdiction details:', error);
        //     });
        const queryString = "SELECT SymphonyLF__Country_Code__c, Name, Id " +
            "FROM SymphonyLF__Country__c " +
            "WHERE SymphonyLF__Active__c = true " +
            "AND SymphonyLF__Country_Code__c ='US' " +
            "AND Name= 'United States of America'";
            
        dynamicQueryRecords({ query: queryString })
            .then(result => {
                if(result && result.length > 0) {
                    this.defaultUSJurisdictionId = result[0].Id;
                    console.log('Default US Jurisdiction Id:', this.defaultUSJurisdictionId);
                }
            })
            .catch(error => {
                console.error('Error retrieving US jurisdiction record:', error);
            });
    }

    fetchExistingPatentFamilyDetails(){
        let recordId;
        if(this.existingPatentFamilyRecordId){
            recordId = this.existingPatentFamilyRecordId;
        } else if(this.draftedPatentFamilyId){
            recordId = this.draftedPatentFamilyId;
        }
        if(recordId){
            this.patentFamilyId = recordId;
        getExistingPatentFamilyDetails({ recordId: recordId })
            .then(result => {
                console.log('Combined result:', JSON.stringify(result));
                this.inventionTitle = result.patentFamily.SymphonyLF__Invention_Title__c;
                this.intakeFormDraftedAt = result.patentFamily.Intake_Form_DraftedAt__c;
                this.existingMEMDetails = result.engagements.map(record => ({
                    recordId: record.Id,
                    type: record.SymphonyLF__Type__c,
                    contactRecordId: record.SymphonyLF__Supervisor_Client_Contact__c,
                    contactRecordName:record.SymphonyLF__Supervisor_Client_Contact__r.Name
                }));

                this.applicantData = result.chainRecords.map(record => {
                    const addressObj = record.SymphonyLF__Address__c || {};
                    const addressText = [
                        addressObj.street,
                        addressObj.city,
                        addressObj.postalCode,
                        addressObj.countryCode
                    ]
                    .filter(val => val)
                    .join(', ');
                    return {
                        chainOfTitleId: record.Id,
                        Id: record.SymphonyLF__Client__c,
                        Name: record.SymphonyLF__Registered_Applicant__c,
                        Address: record.SymphonyLF__Address__c,
                        AddressText: addressText
                    };
                });
                this.selectedApplicants = this.applicantData;
        
                this.inventorData = result.inventors.map(inv => {
                    const addressObj = inv.SymphonyLF__Contact__r.SymphonyLF__Address__c || {};
                    const addressText = [
                        addressObj.street,
                        addressObj.city,
                        addressObj.postalCode,
                        addressObj.countryCode
                    ]
                    .filter(val => val)
                    .join(', ');
                    return {
                        Name: inv.SymphonyLF__Contact__r.Name,
                        Id: inv.SymphonyLF__Contact__c,
                        existingRecId: inv.Id,
                        Address:inv.SymphonyLF__Contact__r.SymphonyLF__Address__c || {},
                        AddressText: addressText,
                        Email: inv.SymphonyLF__Contact__r.SymphonyLF__Email__c,
                        isPrimary: inv.SymphonyLF__Primary_Inventor__c,
                        sequence: inv.Sequence__c
                    };
                });
                this.selectedInventors = this.inventorData;

                this.updateApplicantTableData(this.applicantData);
                this.updateInventorTableData(this.inventorData);
                this.updateExistingMEMTableTableData(this.existingMEMDetails);

                console.log('this.existingMEMDetails::', JSON.stringify(this.existingMEMDetails));
                if (this.engagementDetails && this.engagementDetails.length > 0) {
                    this.engagementDetails = this.engagementDetails.map(localEng => {
                        const matchingServerEng = this.existingMEMDetails.find(serverEng =>
                            serverEng.contactRecordId === localEng.contactRecordId &&
                            serverEng.type === localEng.type
                        );
                        if (matchingServerEng) {
                            return { ...localEng, memId: matchingServerEng.recordId };
                        }
                        return localEng;
                    });
                    this.selectedEngagementDetails = this.engagementDetails.filter(eng => eng.memId);
                    console.log('this.selectedEngagementDetails picked from MEM:', JSON.stringify(this.selectedEngagementDetails));
                }

                if(this.draftedPatentFamilyId && this.intakeFormDraftedAt){
                    switch(this.intakeFormDraftedAt) {
                        case 'Basic Details':
                            this.navigateToBasicDetails();
                            break;
                        case 'Applicants':
                            this.navigateToApplicantDetails();
                            break;
                        case 'Inventors':
                            this.navigateToInventorDetails();
                            break;
                        case 'Jurisdiction':
                            this.navigateToJurisdictionDetails();
                            break;
                        default:
                            this.navigateToBasicDetails();
                    }
                }
            })
            .catch(error => {
                console.error('Error fetching details:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || error.message,
                    variant: 'error'
                }));
            });
        }
    
    }


    prepareColumns() {
        try {
            
            this.engagementColumns = [
                {
                    title: "", 
                    field: "select",
                    align: "center",
                    width: "40",
                    resizable: false,
                    headerSort: false,
                    formatter: (cell) => {
                        const selectedRows = this.selectedEngagementDetails || [];
                        const rowData = cell.getRow().getData();
                        const isSelected = selectedRows.some(item => item.recordId === rowData.recordId);
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
                    field: "type",
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
                    headerFilter: true,
                    field: "contactName",
                    type: "recordlink", 
                    formatterParams: {
                        recordIdField: "contactRecordName",
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
                }
            ];

            this.applicantColumns = [
                {
                    title: "Name",
                    headerFilter: false,
                    field: "Name",
                    formatterParams: {
                        recordIdField: "Id",
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
                    title: "Address",
                    headerFilter: false,
                    field: "AddressText",
                    formatterParams: {
                        recordIdField: "Id",
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
                    title: "Action",
                    field: "action",
                    align: "center",
                    width: "75",
                    resizable: false,
                    headerSort: false,
                    formatter: () => {
                        return `
                            <div class="action-icons slds-grid slds-grid_align-center slds-grid_vertical-align-center" style="font-size: 18px;"> 
                                <i class='fa fa-regular fa-trash delete-icon' title='Delete' style="cursor: pointer; color: #333;"></i> 
                            </div> 
                        `;
                    },
                    cellClick: (e, cell) => this.handleDeleteApplicant(e, cell),
                }
                
            ];

            this.inventorColumns = [
                {
                    title: "Name",
                    headerFilter: false,
                    field: "Name",
                    formatterParams: {
                        recordIdField: "Id",
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
                    title: "Address",
                    headerFilter: false,
                    field: "AddressText",
                    formatterParams: {
                        recordIdField: "Id",
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
                    headerFilter: false,
                    field: "Email",
                    formatterParams: {
                        recordIdField: "Id",
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
                    title: "Primary",
                    field: "isPrimary",
                    resizable: false,
                    style: "width:3%!important;",
                    formatter: (cell) => {
                        const data = cell.getRow().getData();
                        return data.isPrimary
                            ? `<span style="font-weight:bold;"><i class='fa fa-toggle-on'></i></span>`
                            : `<span style="font-weight:bold;"><i class='fa fa-toggle-off'></i></span>`;
                    },
                    cellClick: (e, cell) => {
                        const clickedData = cell.getRow().getData();
                        if (clickedData.isPrimary) {
                            this.inventorData = this.inventorData.map(row => {
                                if (row.Id === clickedData.Id) {
                                    return { ...row, isPrimary: false };
                                }
                                return row;
                            });
                        } else {
                            this.inventorData = this.inventorData.map(row => {
                                return row.Id === clickedData.Id
                                    ? { ...row, isPrimary: true }
                                    : { ...row, isPrimary: false };
                            });
                        }
                        this.updateInventorTableData(this.inventorData);
                    }
                },     
                {
                    title: "Action",
                    field: "action",
                    align: "center",
                    width: "75",
                    resizable: false,
                    headerSort: false,
                    formatter: () => {
                        return `
                            <div class="action-icons slds-grid slds-grid_align-center slds-grid_vertical-align-center" style="font-size: 18px;"> 
                                <i class='fa fa-regular fa-trash delete-icon' title='Delete' style="cursor: pointer; color: #333;"></i> 
                            </div> 
                        `;
                    },
                    cellClick: (e, cell) => this.handleDeleteInventor(e, cell),
                }
            ];

            this.existingMEMColumns = [ 
                {
                    title: "Type",
                    field: "type",
                    headerFilter: true,
                    formatterParams: {
                        recordIdField: "recordId",
                        classList: [],
                        styleList: [{ property: "font-weight", value: "bold" }]
                    }
                },
                {
                    title: "Client Contact",
                    headerFilter: true,
                    field: "contactRecordId",
                    type: "recordlink", 
                    formatterParams: {
                        recordIdField: "recordId",
                        classList: [],
                        styleList: [{ property: "font-weight", value: "bold" }]
                    }
                }
            ];

            this.jurisdictionColumns = [
                {
                    title: 'Case Type',
                    field: 'CaseType',
                    type: 'picklist',
                    editor: 'select',
                    headerFilter: 'select',
                    editorParams: {
                        values: this.caseTypesPatent
                    },
                    formatter: (cell) => {
                        const cellValue = cell.getValue();
                        const option = this.caseTypesPatent.find(opt => opt.value === cellValue);
                        return option ? option.label : cellValue;
                    }
                },
                {
                    title: 'Country',
                    field: 'Country',
                    type: 'picklist',
                    editor: 'select',
                    headerFilter: 'select',
                    editorParams: {
                        values: this.countryOptions
                    },
                    formatter: (cell) => {
                        const cellValue = cell.getValue();
                        const option = this.countryOptions.find(opt => opt.value === cellValue);
                        return option ? option.label : cellValue;
                    }
                }
                // {
                //     title: 'Client Reference Number',
                //     field: 'ClientRefNumber',
                //     editor: 'input',
                //     headerFilter: 'input'
                // }
            ];
            

        } catch (err) {
            console.error('Error preparing columns:', err);
            //this.showErrorToast('Error preparing column configuration.');
        }
    }    
    

    checkLoadingStatus(){
        if (
            this.map_CountryPicklistValues && this.map_CountryPicklistValues.size > 0 &&
            this.entitySizeOptions && this.entitySizeOptions.length > 0 &&
            this.clientGroupNumber &&
            this.personRecordTypeId
        ) {
            this.loading = false;
            this.isTableLoaded = true;
            console.log('All required properties are loaded.');
        } else {
            console.log('Loading... waiting for all required properties to be populated.');
        }
    }

    handleCheckboxClick(event, cell) {
        // Stop propagation to avoid triggering other cell events
        event.stopPropagation();
    
        const rowData = cell.getRow().getData();
    
        if (!this.selectedEngagementDetails) {
            this.selectedEngagementDetails = [];
        }
        if (!this.deletedEngagementDetails) {
            this.deletedEngagementDetails = [];
        }
    
        const checkbox = event.target;
    
        console.log('checkbox:', JSON.stringify(checkbox));
        if (checkbox.checked) {
            if (!this.selectedEngagementDetails.find(item => item.recordId === rowData.recordId)) {
                this.selectedEngagementDetails.push(rowData);
            }
        } else {
            console.log('checkbox unchecked');
            this.selectedEngagementDetails = this.selectedEngagementDetails.filter(item => item.recordId !== rowData.recordId);
            // If the row has been previously saved (has a memId), add it to deletedEngagementDetails.
            if (rowData.memId && this.patentFamilyId) {
                if (!this.deletedEngagementDetails.includes(rowData.memId)) {
                    this.deletedEngagementDetails = [...this.deletedEngagementDetails, rowData.memId];
                    console.log('this.deletedEngagementDetails::', JSON.stringify(this.deletedEngagementDetails));
                }
            }
        }
        
        console.log('Selected Engagement Details:', JSON.stringify(this.selectedEngagementDetails));
    }
    

    toggleDropdown() {
        const dropdownMenu = this.template.querySelector('.dropdown-menu');
        if (dropdownMenu) {
            dropdownMenu.classList.toggle('slds-hide');
        }
    }


    handleDeleteApplicant(event, cell) {
        const recordId = cell.getRow().getData().Id;
        console.log('recordId to delete:', recordId);

        const applicantToDelete = this.applicantData.find(app => app.Id === recordId);
        if (applicantToDelete && applicantToDelete.chainOfTitleId) {
            this.deletedChainOfTitles = [...this.deletedChainOfTitles, applicantToDelete.chainOfTitleId];
          
            console.log('this.deletedChainOfTitles::', JSON.stringify(this.deletedChainOfTitles));
        }

        this.selectedApplicants = this.selectedApplicants.filter(app => app.Id !== recordId);
        this.newApplicants = this.newApplicants.filter(app => app.Id !== recordId);
        this.alreadyAddedApplicantsToExclude = this.alreadyAddedApplicantsToExclude.filter(id => id !== recordId);
        this.applicantData = JSON.parse(JSON.stringify(this.selectedApplicants));
    
        console.log('Updated applicantData:', JSON.stringify(this.applicantData));
        console.log('Updated selectedApplicants:', JSON.stringify(this.selectedApplicants));
        console.log('Updated newApplicants:', JSON.stringify(this.newApplicants));

        this.updateApplicantTableData(this.applicantData);
    }

    handleDeleteInventor(event, cell) {
        const recordId = cell.getRow().getData().Id;
        console.log('Deleting Inventor with Id:', recordId);

        const inventorsToDelete = this.inventorData.find(inv => inv.Id === recordId);
        if (inventorsToDelete && inventorsToDelete.existingRecId) {
            this.deletedInventorDesigner = [...this.deletedInventorDesigner, inventorsToDelete.existingRecId];
          
            console.log('this.deletedInventorDesigner::', JSON.stringify(this.deletedInventorDesigner));
        }

        this.selectedInventors = this.selectedInventors.filter(inv => inv.Id !== recordId);
        this.newInventors = this.newInventors.filter(inv => inv.Id !== recordId);
        this.excludedInventorIds = this.excludedInventorIds.filter(id => id !== recordId);
        this.inventorData = JSON.parse(JSON.stringify(this.selectedInventors));
  
        console.log('Updated inventorData:', JSON.stringify(this.inventorData));
        console.log('Updated selectedInventors:', JSON.stringify(this.selectedInventors));
        console.log('Updated newInventors:', JSON.stringify(this.newInventors));

        this.updateInventorTableData(this.inventorData);
    }

    validateBasicDetailsInputs() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;
    
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                isValid = false;
                input.reportValidity();
            }
        });
    
        return isValid;
    }

    handleInventionTitle(event) {
        const inputVal = event.target.value;
        this.inventionTitle = inputVal;

        if (inputVal.length > 80) {
            let truncated = inputVal.substring(0, 80);
            let lastSpace = truncated.lastIndexOf(' ');
            if (lastSpace > 0) {
                // Use the substring up to the last complete word.
                this.shortTitle = truncated.substring(0, lastSpace);
            } else {
                this.shortTitle = truncated;
            }
        } else {
            this.shortTitle = inputVal;
        }
    }

    async createOrUpdatePatent() {

        if(!this.isExistingPatentFamily){
            if (!this.validateBasicDetailsInputs()) {
                this.showToast('Error', 'Invention Title is mandatory.', 'error');
                return;
            }
        
            console.log('this.patentFamilyId before savePF:', this.patentFamilyId);
            const patentFamilyData = {
                clientId: this.clientId,
                shortTitle: this.shortTitle,
                inventionTitle: this.inventionTitle,
                patentFamilyId: this.patentFamilyId,
                engagementDetails: this.selectedEngagementDetails.map(engagement => ({
                    type: engagement.type,
                    personId: engagement.contactRecordId,
                    memId: engagement.memId ?engagement.memId : ''
                })),
                deletedEngagementDetails: this.deletedEngagementDetails
            };
            console.log('patentFamilyData to create:', JSON.stringify(patentFamilyData));
        
            try {
                const result = await savePatentFamilyAndEngagements({ jsonString: JSON.stringify(patentFamilyData) });
        
                console.log('result of Patent Family created:::', JSON.stringify(result));
                if (result.Status) {
                    this.patentFamilyId = result.PatentFamilyID;
                    this.selectedEngagementDetails=[];

                    result.engagementDetails.forEach(returnedEng => {
                        const index = this.engagementDetails.findIndex(localEng =>
                            localEng.contactRecordId === returnedEng.contactRecordId &&
                            localEng.type === returnedEng.type
                        );
                        if (index !== -1) {
                            this.engagementDetails[index].memId = returnedEng.memId;
                            if (!this.selectedEngagementDetails.find(item => item.recordId === this.engagementDetails[index].recordId)) {
                                this.selectedEngagementDetails.push(this.engagementDetails[index]);
                            }
                        }
                    });
                } else {
                    this.showToast('Error', 'Error saving Patent Family.', 'error');
                }
            } catch (error) {
                let errMsg = 'Unexpected error occurred.';
                if (error.body && error.body.message) {
                    errMsg = error.body.message;
                } else if (error.message) {
                    errMsg = error.message;
                }
                this.showToast('Error', 'Unexpected error occurred: ' + errMsg, 'error');
            }
        }
        

        this.intakeFormDraftedAt ='Basic Details';
        this.navigateToApplicantDetails();
    }
    

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    async handleSearchApplicant(event) {
        const searchText = event.target.value;
        this.inputValueApplicant = searchText;
        if (searchText) {
            this.applicantOptions = [];
            searchApplicants({ searchTerm: searchText, clientGroupNumber: this.clientGroupNumber, excludedApplicantIds: this.alreadyAddedApplicantsToExclude })
                .then(result => {
                    console.log('result applicants:', JSON.stringify(result));
                    this.applicantOptions = result.map(app => ({
                        label: app.Name,
                        recordId: app.Id,
                        Address:app.SymphonyLF__Address__c ? app.SymphonyLF__Address__c : '',
                        src: 'standard:user',
                        selected: false,
                    }));
                    console.log('this.applicantOptions::', JSON.stringify(this.applicantOptions));
                    this.showDropdownApplicants = this.applicantOptions.length > 0;
                    this.noResultsApplicant = this.applicantOptions.length === 0;
                })
                .catch(error => {
                    console.error('Error fetching applicantOptions', error);
                    this.applicantOptions = [];
                    this.showDropdownApplicants = false;
                });
        }
        else {
            this.applicantOptions = [];
            this.noResultsApplicant = false;
            this.showDropdownApplicants = false;
        }
    
    }
    


    handleSelectApplicant(event) {
        const appId = event.currentTarget.dataset.recordId;
        const selectedApplicant = this.applicantOptions.find(app => app.recordId === appId);
        
        console.log('selectedApplicant:', JSON.stringify(selectedApplicant));
        
        this.applicantOptions = this.applicantOptions.map(app => ({
            ...app,
            selected: app.recordId === appId || app.selected
        }));

        if (selectedApplicant && !this.alreadyAddedApplicantsToExclude.includes(appId)) {
            const addressObj = selectedApplicant.Address || {};
        
            const addressText = [
                addressObj.street,
                addressObj.city,
                addressObj.postalCode,
                addressObj.countryCode
            ]
            .filter(val => val)
            .join(', ');

            this.selectedApplicants = [
                ...this.selectedApplicants,
                {
                    Id: selectedApplicant.recordId,
                    Name: selectedApplicant.label,
                    Address: selectedApplicant.Address,
                    AddressText: addressText 
                }
            ];
           this.applicantData = JSON.parse(JSON.stringify(this.selectedApplicants));
            this.alreadyAddedApplicantsToExclude.push(appId);

            console.log('this.applicantData ==>', JSON.stringify(this.applicantData));
            
            this.updateApplicantTableData(this.applicantData);
            
        }

        this.showDropdownApplicants= false;
        this.inputValueApplicant='';

    }

    updateEngagementTableData(data) {
        try {
            const tableElement = this.template.querySelector('c-lwc-mv-datatable[data-id="engagementTable"]');
            if (tableElement) {
                tableElement.updateTableData(data);
            }

        } catch (err) {
            alert('JS Error ::  :: updateTableData')
            console.error(err)
        }
    }

    updateExistingMEMTableTableData(data) {
        try {
            const tableElement = this.template.querySelector('c-lwc-mv-datatable[data-id="existingMEMTable"]');
            if (tableElement) {
                tableElement.updateTableData(data);
            }

        } catch (err) {
            alert('JS Error ::  :: updateTableData')
            console.error(err)
        }
    }

    updateApplicantTableData(data) {
        try {
            const tableElement = this.template.querySelector('c-lwc-mv-datatable[data-id="applicantTable"]');
            if (tableElement) {
                tableElement.updateTableData(data);
            }

        } catch (err) {
            alert('JS Error ::  :: updateTableData')
            console.error(err)
        }
    }

    updateInventorTableData(data) {
        try {
            const tableElement = this.template.querySelector('c-lwc-mv-datatable[data-id="inventorTable"]');
            if (tableElement) {
                tableElement.updateTableData(data);
            }

        } catch (err) {
            alert('JS Error ::  :: updateTableData')
            console.error(err)
        }
    }



    handleInventorDelete(event){
        const id = event.target.dataset.id;
        console.log('Row ID:', id);
        if (id) {
            this.inventorData = this.inventorData.filter(inventor => inventor.Id !== id);
            this.excludedInventorIds = this.excludedInventorIds.filter(id => id !== id);
        }
        else {
        console.error('Row ID is undefined. Ensure data-id is set correctly on the buttons.');
        }

    }

    get computedClassificationOptions() {
        return this.classificationOptions.map(opt => {
            return {
                ...opt,
                isChecked: this.selectedValues.includes(opt.value)
            };
        });
    }

    handleInputChangeApplicant(event) {
        const fieldName = event.target.name || event.target.dataset.field;
    
        let fieldValue;
    
        if (fieldName === 'currency') {
            console.log('Record picker event detail:', event.detail);
            fieldValue = event.detail.recordId;
            console.log('fieldValue currency:', fieldValue);
        }
        else if (event.target.tagName === 'LIGHTNING-INPUT-ADDRESS') {
            this.address = {
                street: event.target.street,
                city: event.target.city,
                state:  event.target.province,
                country: this.map_CountryPicklistValues.get(event.target.country),//event.target.country,
                postalCode: event.target.postalCode
            };
            console.log('this.address ::: ', JSON.stringify(this.address));
            
        }else if (fieldName === 'classification') {
            if (event.target.checked) {
                if (!this.selectedValues.includes(event.target.value)) {
                    this.selectedValues.push(event.target.value);
                }
            } else {
                this.selectedValues = this.selectedValues.filter(val => val !== event.target.value);
            }
            this.updateSelectedLabels();
            return;
        }
        else {
            fieldValue = event.target.value;
        }
    
        console.log('Field Name:', fieldName, 'Value:', fieldValue);
    
        if (fieldName === 'applicantName') {
            this.applicantName = fieldValue;
        } else if (fieldName === 'currency') {
            this.currency = fieldValue;
            console.log('this.currency==>', this.currency);
        } else if (fieldName === 'entitySize') {
            this.entitySize = fieldValue;
        }
    
        console.log('Updated Data:', JSON.stringify({
            applicantName: this.applicantName,
            currency: this.currency,
            entitySize: this.entitySize,
            address: this.address,
            selectedValues: this.selectedValues,
        }));
    }
    
    updateSelectedLabels() {
        if (this.selectedValues.length > 0) {
            const selectedOptions = this.classificationOptions.filter(option =>
                this.selectedValues.includes(option.value)
            );
            this.selectedLabels = selectedOptions.map(opt => opt.label).join(';');
        } else {
            this.selectedLabels = 'Select Classification';
        }
    }
    

    setStateOptions(code) {
        this.stateOptions = [];
        this.addressDependentPicklist[code].forEach(row => {
            console.log(row);
            let states = {};
            states.code = row.code;
            states.label = row.label;
            states.value = row.code;
            this.stateOptions.push(states);
        });
        this.stateOptions = [...this.stateOptions];
        console.log('state', JSON.stringify(this.stateOptions));
    }

    validateApplicantFields() {
        let isValid = true;
        
        const applicantInput = this.template.querySelector('lightning-input[name="applicantName"]');
        if (applicantInput) {
            if (!applicantInput.checkValidity()) {
                applicantInput.reportValidity();
                isValid = false;
            }
        }

        const currencyInput = this.template.querySelector('lightning-record-picker[name="currency"]');
        if (!this.currency) {
            isValid = false;
            if (currencyInput && currencyInput.setCustomValidity) {
                currencyInput.setCustomValidity('Complete this field.');
                currencyInput.reportValidity();
            } else if (currencyInput) {
                currencyInput.classList.add('slds-has-error');
            }
        } else if (currencyInput && currencyInput.setCustomValidity) {
            currencyInput.setCustomValidity('');
            currencyInput.reportValidity();
        }
        

        const entitySizeInput = this.template.querySelector('lightning-combobox[name="entitySize"]');
        if (!this.entitySize) {
            isValid = false;
            if (entitySizeInput && entitySizeInput.setCustomValidity) {
                entitySizeInput.setCustomValidity('Complete this field.');
                entitySizeInput.reportValidity();
            } else if (entitySizeInput) {
                entitySizeInput.classList.add('slds-has-error');
            }
        } else if (entitySizeInput && entitySizeInput.setCustomValidity) {
            entitySizeInput.setCustomValidity('');
            entitySizeInput.reportValidity();
        }
        
        const classificationContainer = this.template.querySelector('.custom-dropdown[data-field="classification"]');
        if (!this.selectedValues || this.selectedValues.length === 0) {
            isValid = false;
            if (classificationContainer) {
                classificationContainer.classList.add('slds-has-error');
            }
        } else if (classificationContainer) {
            classificationContainer.classList.remove('slds-has-error');
        }
        
        return isValid;
    }
    
    addApplicant() {
        if (!this.validateApplicantFields()) {
            this.showToast('Error', 'Please fill in the mandatory details', 'error');
            return;
        }
        const tempId = 'temp-' + Date.now();
        const newApp = {
            Id: tempId,
            Name: this.applicantName,
            Currency: this.currency,
            EntitySize: this.entitySize,
            Classification: this.selectedValues.join(';'),
            AddressText: `${this.address.street || ''} ${this.address.city || ''} ${this.address.state || ''} ${this.address.country || ''} ${this.address.postalCode || ''}`.trim(),
            Address: this.address,
            isNew: true
        };
    
        console.log('newApp:', JSON.stringify(newApp));
        this.selectedApplicants = [...this.selectedApplicants, newApp];
        this.newApplicants = [...this.newApplicants, newApp];
        this.applicantData = JSON.parse(JSON.stringify(this.selectedApplicants));
        console.log('this.applicantData new app::', JSON.stringify(this.applicantData));
    
        this.updateApplicantTableData(this.applicantData);
        this.clearApplicantForm();
    }

    handleSaveApplicant() {
        const newClients = this.newApplicants.map(applicant => ({
            tempId: applicant.Id,
            name: applicant.Name,
            classification: applicant.Classification,
            entitySize: applicant.EntitySize,
            defaultCurrency: applicant.Currency,
            address: applicant.Address
        }));
        
        console.log('newClients to create:', JSON.stringify(newClients));
        
        createNewClients({ newClientsJson: JSON.stringify(newClients) })
            .then(clientResponse => {
                console.log('Saved applicants:', JSON.stringify(clientResponse));
                clientResponse.forEach(savedRecord => {
                    let index = this.applicantData.findIndex(app => app.Id === savedRecord.tempId);
                    if (index !== -1) {
                        this.applicantData[index].Id = savedRecord.id;
                        this.applicantData[index].Name = savedRecord.name;
                        this.applicantData[index].Address= savedRecord.address;

                        const addr = savedRecord.address;
                        this.applicantData[index].AddressText = 
                            `${addr.street ? addr.street + ', ' : ''}` +
                            `${addr.city ? addr.city + ', ' : ''}` +
                            `${addr.state ? addr.state + ', ' : ''}` +
                            `${addr.country ? addr.country + ', ' : ''}` +
                            `${addr.postalCode || ''}`.replace(/, $/, '');
                    }
                });
                this.newApplicants = [];


                const chainRecords = this.applicantData
                                    .filter(applicant => !applicant.chainOfTitleId) 
                                    .map(applicant => ({
                                        clientId: applicant.Id,
                                        Name: applicant.Name,
                                        addressedit: (applicant.Address && typeof applicant.Address === 'object') ? applicant.Address : null
                                        
                                    }));
                
                                    console.log('chainRecords to create:', JSON.stringify(chainRecords));
            
            return createChainOfTitleRecords({
                    chainRecordsJson: JSON.stringify(chainRecords),
                    deletedChainOfTitlesIds: this.deletedChainOfTitles,
                    patentFamilyID: this.patentFamilyId
                });
            })
            .then(chainResponse => {
                console.log('Chain of Title records created:', JSON.stringify(chainResponse));
                chainResponse.forEach(chainRec => {
                    let index = this.applicantData.findIndex(app => app.Id === chainRec.clientId);
                    if (index !== -1) {
                        this.applicantData[index].chainOfTitleId = chainRec.chainId;

                    }
                });
                
                this.selectedApplicants = this.applicantData;
                console.log('this.applicantData after chain records created::', JSON.stringify(this.applicantData));
                
                this.updateApplicantTableData(this.applicantData);

                this.intakeFormDraftedAt ='Applicants';
                this.navigateToInventorDetails();
            })
            .catch((error) => {
                console.error('Error saving applicants:', JSON.stringify(error));
            });

        
    }

    clearApplicantForm() {
        this.applicantName = '';
        this.currency = null;
        this.entitySize = '';
        this.selectedValues = ['Applicant'];
        this.address = {
            street: '',
            city: '',
            state: '',
            country: '',
            postalCode: ''
        };
        const currencyPicker = this.template.querySelector('lightning-record-picker[name="currency"]');
        if (currencyPicker) {
            currencyPicker.value = null; 
        }
    
    }

    handleInventorSearch(event) {
        const searchTerm = event.target.value;
        this.inventorInputValue=searchTerm;
        if (searchTerm) {
            this.inventorOptions=[];
            searchInventors({ searchTerm: searchTerm, clientId: this.clientId, excludedInventorIds: this.excludedInventorIds })
                .then(result => {
                    console.log('result inventors:', JSON.stringify(result));
                    this.inventorOptions = result.map(inv => ({
                        label: inv.Name,
                        recordId: inv.Id,
                        Email:inv.SymphonyLF__Email__c ? inv.SymphonyLF__Email__c : '',
                        Address:inv.SymphonyLF__Address__c ? inv.SymphonyLF__Address__c : '',
                        src: 'standard:user',
                        selected: false,
                    }));
                    console.log('this.inventorOptions::', JSON.stringify(this.inventorOptions));
                    this.showDropdownInventors = this.inventorOptions.length > 0;
                    this.noResults = this.inventorOptions.length === 0;
                })
                .catch(error => {
                    console.error('Error fetching inventors', error);
                    this.inventorOptions = [];
                    this.showDropdownInventors = false;
                });
        } else {
            this.showDropdownInventors = false;
            this.inventorOptions=[];
            this.noResults= false;
        }
    }

    handleSelectInventor(event) {
        console.log('event.currentTarget.dataset:', event.currentTarget.dataset);
        const invId = event.currentTarget.dataset.recordId;
        const selectedInventor = this.inventorOptions.find(inv => inv.recordId === invId);

        this.inventorOptions = this.inventorOptions.map(inv => ({
            ...inv,
            selected: inv.recordId === invId || inv.selected
        }));

        if (selectedInventor && !this.excludedInventorIds.includes(invId)) {
            const addressObj = selectedInventor.Address || {};
            const addressText = [
                addressObj.street,
                addressObj.city,
                addressObj.postalCode,
                addressObj.country
            ]
            .filter(val => val)
            .join(', ');
            this.selectedInventors = [
                ...this.selectedInventors,
                {
                    Id: selectedInventor.recordId,
                    Name: selectedInventor.label,
                    AddressText: addressText ,
                    Email: selectedInventor.Email,
                    isPrimary: selectedInventor.isPrimary
                }
            ];
                
                
                this.inventorData = JSON.parse(JSON.stringify(this.selectedInventors));
                this.excludedInventorIds.push(invId);
                console.log('this.inventorData ==>', JSON.stringify(this.inventorData));
                this.updateInventorTableData(this.inventorData);
            
        }

        this.showDropdownInventors = false;
        this.inventorInputValue='';
        
    }

    
    handleFieldChangeInventor(event) {
        const fieldName = event.target.name || event.target.dataset.field;
        let fieldValue;

        if (event.target.tagName === 'LIGHTNING-INPUT-ADDRESS') {
            //this.inventorAddress = { ...event.detail };
            this.inventorAddress = {
                street: event.target.street,
                city: event.target.city,
                state:  event.target.province,
                country: this.map_CountryPicklistValues.get(event.target.country),//event.target.country,
                postalCode: event.target.postalCode
            };
            console.log('Address updated:', JSON.stringify(this.inventorAddress));
            return;
        }

        if (fieldName === 'user') {
            fieldValue = event.detail.recordId;
        } else {
            fieldValue = event.target.value;
        }

        switch (fieldName) {
            case 'personName':
                this.personName = fieldValue;
                break;
            case 'emailAddress':
                this.emailAddress = fieldValue;
                this.validateEmailAddress(fieldValue);
                break;
            case 'nationality':
                this.nationality = fieldValue;
                break;
            case 'phone':
                this.phone = fieldValue;
                break;
            case 'user':
                this.user = fieldValue;
                break;
            default:
                console.warn(`Unhandled field: ${fieldName}`);
        }
        console.log(`Updated field: ${fieldName} = ${fieldValue}`);
    }

    
    validateEmailAddress(email) {
        const emailRegex = /^[a-zA-Z][^\s@]*@[^\s@]+\.[^\s@]+$/;
        const emailInput = this.template.querySelector("lightning-input[name='emailAddress']");
        if (email && !emailRegex.test(email)) {
            this.emailAddressError = 'Please enter a valid email address.';
            if (emailInput) {
                emailInput.setCustomValidity(this.emailAddressError);
                emailInput.reportValidity();
            }
        } else {
            this.emailAddressError = '';
            if (emailInput) {
                emailInput.setCustomValidity('');
                emailInput.reportValidity();
            }
        }
    }


    addInventor() {
        if (!this.personName || this.personName.trim() === '') {
            this.showToast('Error', 'Person Name is required.', 'error');
            return;
        }
        if (this.emailAddress && this.emailAddressError) {
            this.showToast('Error', 'Please enter a valid email address.', 'error');
            return;
        }

        const tempId = 'temp-' + Date.now();
        const newInventor = {
            Id: tempId,
            Name: this.personName,
            user: this.user,
            nationality: this.nationality,
            Email: this.emailAddress,
            Phone: this.phone,
            Address: this.inventorAddress,
            AddressText: this.formatAddress(this.inventorAddress),
            isNew: true
        };
        this.newInventors = [...this.newInventors, newInventor];
        this.inventorData = [...this.inventorData, newInventor];
        this.selectedInventors = [...this.selectedInventors, newInventor];

        console.log('this.newInventors::', JSON.stringify(this.newInventors));
        console.log('this.inventorData=>', JSON.stringify(this.inventorData));
        console.log('this.selectedInventors==>', JSON.stringify(this.selectedInventors));

        
        
        this.resetInventorFields();
        this.updateInventorTableData(this.inventorData);
    }


    formatAddress(address) {
        if (!address || typeof address !== 'object') {
            return '';
        }
        const { street, city, state, country, postalCode } = address;
        return `${street ? street + ', ' : ''}${city ? city + ', ' : ''}${state ? state + ', ' : ''}${country ? country + ', ' : ''}${postalCode || ''}`.replace(/, $/, '');
    }
    

    resetInventorFields() {
        this.personName = '';
        this.user = null;
        this.nationality = '';
        this.emailAddress = '';
        this.phone = '';
        this.inventorAddress = {
            street: '',
            city: '',
            state: '',
            country: '',
            postalCode: ''
        };
    }
    
    saveOrupdateInventorDetails(){
        if (this.inventorData.length === 0) {
            this.showToast('Info', 'Please Select atleast one Inventor', 'info');
            return;
        }

        const newPersons = this.newInventors.map(inventor =>({
                tempId : inventor.Id,
                clientId: this.clientId, 
                contactType: this.contactType,
                recordTypeId: this.personRecordTypeId,
                Type: this.inventortype, 
                personName: inventor.Name,
                user: inventor.user || null,
                nationality: inventor.nationality || null,
                emailAddress: inventor.Email,
                phone: inventor.Phone || null,
                inventorAddress: inventor.Address && Object.keys(inventor.Address).length > 0 ? inventor.Address : null
            }));

            console.log('Creating Person with details:', JSON.stringify(newPersons));
             
            createNewPersons({newPersonsJson: JSON.stringify(newPersons)})
                .then(Personresults => {
                    console.log('saved persons: ', JSON.stringify(Personresults));
                    Personresults.forEach(inventor => {
                        let dataIndex = this.inventorData.findIndex(inv => inv.Id === inventor.tempId);
                        if (dataIndex !== -1) {
                            this.inventorData[dataIndex].Id = inventor.id;
                            this.inventorData[dataIndex].Name = inventor.personName;
                            this.inventorData[dataIndex].Email = inventor.emailAddress;
                            this.inventorData[dataIndex].Address= inventor.address;

                            const addr = inventor.address;
                            this.inventorData[dataIndex].AddressText= `${addr.street ? addr.street + ', ' : ''}` +
                            `${addr.city ? addr.city + ', ' : ''}` +
                            `${addr.state ? addr.state + ', ' : ''}` +
                            `${addr.country ? addr.country + ', ' : ''}` +
                            `${addr.postalCode || ''}`.replace(/, $/, '');
                    }
                });
                console.log('this.inventorData=> after created:', JSON.stringify(this.inventorData))
                this.newInventors = [];

                const inventorWrappers = this.inventorData.map(inv => {
                    return {
                        contactId: inv.Id,        
                        existingRecId: inv.existingRecId || null, 
                        primary: inv.isPrimary,     
                        sequence: inv.sequence   
                    };
                });

                console.log('inventorWrappers::', JSON.stringify(inventorWrappers));
                return createPatentInventors({
                    patentFamilyId: this.patentFamilyId,
                    deletedInventorDesignerIds: this.deletedInventorDesigner,
                    inventorsJson: JSON.stringify(inventorWrappers)
                });
            })
            .then(inventorDesignerAuthorRecs => {
                console.log('Created/Updated Inventor Designer Author records:', JSON.stringify(inventorDesignerAuthorRecs));
                
                inventorDesignerAuthorRecs.forEach(ida => {
                    let localIndex = this.inventorData.findIndex(i => i.Id === ida.SymphonyLF__Contact__c);
                    if (localIndex !== -1) {
                        this.inventorData[localIndex].existingRecId = ida.Id;
                    }
                });

                console.log('this.inventorData:', JSON.stringify(this.inventorData));
                this.selectedInventors = this.inventorData;
                this.updateInventorTableData(this.inventorData);


                //create default Patent record of Us
                const params = {
                    clientId: this.clientId,
                    patentFamilyId: this.patentFamilyId,
                    patentFamilyShortTitle: this.shortTitle,
                    patentFamilyTitle: this.inventionTitle,
                    defaultCaseTypeValue: this.defaultCaseTypeValue,
                    defaultUSJurisdictionId: this.defaultUSJurisdictionId,
                    selectedEngagementDetails: this.selectedEngagementDetails,
                    applicantData: this.applicantData,
                    inventorData: this.inventorData
                };
                console.log('params for creating Patent:', JSON.stringify(params));

                createPatentRecordForJurisdiction(params)
                .then(result => {
                    console.log('Patent and related records created:', JSON.stringify(result));
                })
                .catch(error => {
                    console.error('Error creating Patent and related records:', JSON.stringify(error));
                    
                });

                this.intakeFormDraftedAt ='Inventors';
                this.navigateToJurisdictionDetails();
            })
            .catch(error => {
                console.error('Error saving inventor details:', JSON.stringify(error));
                let errorMsg = 'Unknown error';
                if (error.body && error.body.message) {
                    errorMsg = error.body.message;
                } else if (error.message) {
                    errorMsg = error.message;
                }
               // this.showToast('Error', 'Error saving inventor details: ' + errorMsg, 'error');
            });
        
    }

    handleSaveJurisdiction(){
        // const jurisdictionComp = this.template.querySelector('c-mv-intake-jurisdiction');
        // if (jurisdictionComp && typeof jurisdictionComp.getFormData === 'function') {
        //     const formData = jurisdictionComp.getFormData();
        //     console.log('Form Data to save: ', formData);
        // }
    }
    
    SubmitForm(){
       //submit form
        
    }

    handleCancel(){
        console.log('this.intakeFormDraftedAt:', this.intakeFormDraftedAt);
        if (this.patentFamilyId && this.intakeFormDraftedAt) {
            updateIntakeFormDraftedAt({ 
                patentFamilyId: this.patentFamilyId, 
                intakeFormDraftedAt: this.intakeFormDraftedAt 
            })
            .then(() => {
                console.log('Patent Family updated with intakeFormDraftedAt');
                window.close();
            })
            .catch(error => {
                console.error('Error updating Patent Family:', error);
                window.close();
            });
        } else {
            window.close();
        }
    }

    

    

    
}