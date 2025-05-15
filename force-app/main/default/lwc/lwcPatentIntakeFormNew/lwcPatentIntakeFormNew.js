import { LightningElement, api, track, wire } from 'lwc';
import getRecordByQuery from '@salesforce/apex/SymphonyLF.DynamicSearchRecords.DynamicQueryRecords';
import Utils from 'SymphonyLF/utils';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from '@salesforce/apex/PatentIntakeFormHelperNew.saveRecord';
import fetchApplicantsAndInventorsData from '@salesforce/apex/PatentIntakeFormHelperNew.GetApplicantsAndInventors';
import getClientCEMdetails from '@salesforce/apex/PatentIntakeFormHelperNew.getClientCEMdetails';
import getPicklistValuesMethod from '@salesforce/apex/PatentIntakeFormHelperNew.getPicklistValuesMethod';
import getMemDetails from '@salesforce/apex/PatentIntakeFormHelperNew.getMemDetails';
import getMEMpatentFamilyDetails from '@salesforce/apex/PatentIntakeFormHelperNew.getMEMpatentFamilyDetails';
import createClients from '@salesforce/apex/PatentIntakeFormHelperNew.createClient'
import createPersons from '@salesforce/apex/PatentIntakeFormHelperNew.createPerson';
import checkRenewalsAnnuitiess from '@salesforce/apex/PatentIntakeFormHelperNew.checkRenewalsAnnuities';
import getAddressOptions from '@salesforce/apex/PatentIntakeFormHelperNew.getAddressOptions'
import getDependentAddress from '@salesforce/apex/PatentIntakeFormHelperNew.getPicklistValues';
import getKeywords from '@salesforce/apex/PatentIntakeFormHelperNew.getKeywords';
import jurisdictionBasedCaseType from '@salesforce/apex/SymphonyLF.CommonUtility.getJurisdictionCaseType';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PERSON_OBJECT from "@salesforce/schema/SymphonyLF__Person__c";
import { getRecord } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
const CC_FIELDS = [
    'Conflict_Check__c.Client_Reference_Number__c',
    'Conflict_Check__c.Matter_Name__c'
];
const DOCKET_ACTIVITIES = [{ type: 'Hard', nameLabel: 'Hard Docket Event Name', nameRequired: false, eventDateLabel: 'Hard Docket Event Date', eventDateRequreid: false, dueDateRequired: false, dueDateLabel: 'Hard Docket Due Date', eventName: '', eventDate: '', dueDate: '', assignToUser: '', assignToTeam: '', docketError: '' },
{ type: 'Soft', nameLabel: 'Soft Docket Event Name', nameRequired: false, eventDateRequreid: false, dueDateRequired: false, eventDateLabel: 'Soft Docket Event Date', dueDateLabel: 'Soft Docket Due Date', eventName: '', eventDate: '', dueDate: '', assignToUser: '', assignToTeam: '', docketError: '' }
];

export default class LwcPatentIntakeFormNew extends NavigationMixin(LightningElement) {
    @api clientId = '';
    @api conflictCheckId = '';

    @track jurisdictionOptions = [];
    @track isButtonDisabled = false;
    @track engagementDetailsPF = [];
    @track engagementDetailsPatent = [];
    @track isDisabled = false;
    @track docketActivities = [...DOCKET_ACTIVITIES];

    activeSections = ['existingPatentFamilies', 'basicDetails', 'ccDetails', 'existingPatentApplications', 'businessCategory', 'inventors', 'applicants', 'jurisdictions', 'files'];
    picklistOptions = [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }];
    activeJurisdictionSections = ['basicDetails', 'engagementDetails', 'priorities', 'Portfolio_Management', 'BusinessCategories', 'applicants', 'inventors', 'docketActivities', 'keywords'];
    applicantActiveSection = ['A', 'B'];

    warningMessage = 'Please Note: Any changes made to this section will be reflected to the Jurisdiction records created in this transaction Only. No changes will be done to the Family record!';
    isInventorError = false;
    @track sequenceError = '';
    isDocketError = false;
    clientFieldNames = 'Name';
    clientfieldsToQuery = 'Name';
    clientWhereCond = '';
    disableOptions = true;
    @track patentFamilyData = [];
    @track initialPatentFamilyData = [];
    patentFamilyTableHeight = '';
    @track applicants = [];
    @track inventors = [];
    mainRadioValue = '';
    showForm = false;
    showAll = false;
    showFamilyDetails = false;
    showPatentApplications = false;
    @track patentFamilyError = '';
    @track selectedBusinessInfos = [];
    @track jurisdictionList = [];
    patentFamilyId = '';
    jurisdictionError = '';
    inventorError = '';
    readonly = false;
    // inventionDate = null;
    @track inventionTitle = '';
    // earliestPriorityDate = null;
    @track shortTitle = '';
    @track patentData = [];
    patentTableHeight = '';
    @track inventorsTable = [];
    inventionTitleError = '';
    inventionTitleErrorClass = '';
    shortTitleError = '';
    shortTitleErrorClass = '';
    @track inventorAndApplicantFlag = false;
    showInventorPopup = false;
    personName = '';
    emailAddress = '';
    // personNameError = '';
    // personNameErrorClass = '';
    emailAddressError = '';
    Inventortype = '';
    contactType = '';
    inventorAddress = '';
    user = '';
    nationality = '';
    phone = '';
    assistant = '';
    linkToCard = '';
    linkToProfile = '';
    mobilePhone = '';
    extension = '';
    inventorTableHeight = '';
    @track selectedInventors = [];
    applicantTableHeight = '';
    @track selectedApplicants = [];
    // isApplicantDisabled = false;
    applicantAddress = '';
    applicantName = '';
    applicantCurrency = '';
    applicantClassification = 'Applicant';
    applicantEntitySize = '';
    showApplicantPopup = false;
    @track countryOptions = [];
    @track stateOptions = [];
    applicantError = '';
    showApplicantEdit = false;
    rowApplicantClient = '';
    rowApplicantRegisteredApplicant = '';
    rowApplicantAddress = '';
    editRowApplicant;
    jurisdictionPopupError = '';
    showJurisdictionCmp = false;
    @track jurisdictionCmpList = [];
    jurisdictionCmpError = '';
    jurisdictionTableHeight = '';
    // removedInventors = [];
    docketError = false;
    editId = '';
    showJurisdictionPopup = false;
    @track finalSelectedPriorities = [];
    @track preselectedIds = [];
    caseTypeValue = '';
    assetType = 'Patent';
    patOrProsecutionDN = '';
    IPRdocketReq = '';
    OppDocketReq = '';
    litigationDocketReq = '';
    clientOnAnnuityPolicy = '';
    responsibleForAnnuities = '';
    clientAccessToFileDocket = '';
    jurisdictionId = '';
    jurisdictionName = '';
    @track applicantsTable = [];
    @track businessCategoriesTable = [];
    renewalsAnnuities = true; // LFP-655 -> Boolean variable default value update by Aman
    @track selectedInventorsJurisdiction = [];
    @track selectedApplicantsJurisdiction = [];
    @track selectedBusiCategoryJurisdiction = [];
    @track inventorStateOptions = [];
    @track inventorCountryOptions = [];
    applicantActionHeight = '';
    busiCategoryActionHeight = '';
    inventorActionHeight = '';
    openExistingPriorityPopup = false;
    showPriorityTable = false;
    jurisdictionSearchValue = '';
    heReferenceSearchValue = '';
    filingNumberSearchValue = '';
    nullPriorityRecordMessage = '';
    existingPriorityCmpError = '';
    existingPriorityAddError = '';
    @track selectedPriorities = [];
    openNewPriorityPopup = false;
    priorityCaseType = '';
    priorityJurisdictionId = '';
    priorityJurisdictionName = '';
    inventionTitlePriority = '';
    shortTitlePriority = '';
    applicationNumber = '';
    applicationDate = null;
    priorityJurisdictionError = '';
    priorityJurisdictionErrorClass = '';
    priorityShortTitleError = '';
    priorityShortTitleErrorClass = '';
    priorityInventionTitleError = '';
    priorityInventionTitleErrorClass = '';
    priorityApplicationNumberError = '';
    priorityApplicationNumberErrorClass = '';
    priorityApplicationDateError = '';
    priorityApplicationDateErrorClass = '';
    // priorityPortFolioError = '';
    // priorityPortFolioErrorClass = '';
    pantentFamilypriorityNewErrorClass = '';
    patentFamilypriorityError = '';
    prioritypatentFamilyId = '';
    priorityAssetType = 'Patent';
    finalPriorityHeight = '';
    @track jurisdictionPriorityOptions = [];
    showRecordCreationSpinner = false;
    spinnerMessage = '';
    styleTagAppended = false;
    showConfirmationDialog = false;
    confirmationTitle = '';
    confirmationMessage = '';
    @track existingPriorityRecords = [];
    showSelectedPriorities = false;
    existingPriorityHeight = '';
    // agentCondition = '';
    addressDependentPicklist = {};
    // inventorClient = '';
    // inventorOfficeOrAgent = '';

    @track keywords=[];
    @track selectedkeywords=[];
    @track keywordFlag= false;
    @track keywordTableHeight= '';
    @track keywordTable = [];
    keywordActionHeight = '';
    @track selectedkeywordJurisdiction=[];
    @track showKeywordPopup = false;

    keywordColumns =[{ label: 'Keyword Name', fieldName: 'label', wrapText: true },
        { label: 'Full Name', fieldName: 'fullName', wrapText: true },
    ];


    keywordColumnsWithAction =[{ label: 'Keyword Name', fieldName: 'label', wrapText: true },
        { label: 'Full Name', fieldName: 'fullName', wrapText: true },
        { label: 'Action', type:'button-icon',cellAttributes: { class: 'iconTdClass', alignment: 'right' }, typeAttributes: { class: { fieldName: 'deleteButton' }, iconClass: 'deleteIcon', iconName: 'utility:close', title: 'Delete', name: 'delete', variant: 'container', disabled: {fieldName:'disableAction'}}, initialWidth: 86}];
    
    priorityColumnsWithAction = [
        { label: 'Jurisdiction', fieldName: 'SymphonyLF__Country__r.Name', wrapText: true },
        { label: 'Docket Number', fieldName: 'SymphonyLF__Docket_Number__c', wrapText: true },
        { label: 'Case Type', fieldName: 'SymphonyLF__Case_Type__c', wrapText: true },
        { label: 'Application Number', fieldName: 'SymphonyLF__Filing_Number__c', wrapText: true },
        { label: 'Filing Date', fieldName: 'SymphonyLF__Application_Date__c', type: 'date', typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' }, wrapText: true },
        {
            label: 'Action', type: 'button-icon', cellAttributes: { class: 'iconTdClass', alignment: 'center' },
            typeAttributes: {
                class: { fieldName: 'rowRemoveBtnCls' }, iconClass: 'removeIcon', iconName: 'utility:close',
                title: 'close', name: 'close', variant: 'container', disabled: { fieldName: 'disableAction' }
            }, initialWidth: 80
        }];

    inventorColumnsWithAction = [
        { label: 'Name', fieldName: 'value', wrapText: true },
        { label: 'Email', fieldName: 'email', wrapText: true },
        { label: 'Address', fieldName: 'address', wrapText: true },
        { label: 'Primary', fieldName: 'primary', type: 'boolean', wrapText: true },
        { label: 'Sequence', fieldName: 'sequence', wrapText: true },
        { label: 'Action', type: 'button-icon', cellAttributes: { class: 'iconTdClass', alignment: 'center' }, typeAttributes: { class: { fieldName: 'rowRemoveBtnCls' }, iconClass: 'removeIcon', iconName: 'utility:close', title: 'close', name: 'close', variant: 'container', disabled: { fieldName: 'disableAction' } }, initialWidth: 80 }];

    applicantsColumnsWithAction = [{ label: 'Name', fieldName: 'value', wrapText: true },
    { label: 'Address', fieldName: 'address', wrapText: true },
    { label: 'Action', type: 'button-icon', cellAttributes: { class: 'iconTdClass', alignment: 'center' }, typeAttributes: { class: { fieldName: 'rowRemoveBtnCls' }, iconClass: 'removeIcon', iconName: 'utility:close', title: 'close', name: 'close', variant: 'container', disabled: { fieldName: 'disableAction' } }, initialWidth: 80 }];

    businessCategoriesColumnsWithAction = [{ label: 'Category', fieldName: 'SymphonyLF__Category_Formula__c', wrapText: true },
    { label: 'Value', fieldName: 'SymphonyLF__Category_Value__c', wrapText: true },
    { label: 'Action', type: 'button-icon', cellAttributes: { class: 'iconTdClass', alignment: 'center' }, typeAttributes: { class: { fieldName: 'rowRemoveBtnCls' }, iconClass: 'removeIcon', iconName: 'utility:close', title: 'close', name: 'close', variant: 'container', disabled: { fieldName: 'disableAction' } }, initialWidth: 80 }];


    patentFamilyColumns = [{ label: 'Short Title', fieldName: 'Name', wrapText: true },
    { label: 'Docket Number', fieldName: 'SymphonyLF__Docket_Number__c', wrapText: true }];

    patentColumns = [{
        label: 'Docket Number', fieldName: 'URLforDetailPage', wrapText: true,
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'heReferenceNumber'
            },
            tooltip: 'Go to detail page',
            target: '_blank'
        }
    },
    { label: 'Jurisdiction', fieldName: 'jurisdictionName', wrapText: true },
    { label: 'Case Type', fieldName: 'caseType', wrapText: true },
    { label: 'Status', fieldName: 'status', wrapText: true }
        // { label: 'Agent', fieldName: 'foreignAssociateName', wrapText: true }
    ];

    inventorColumns = [
        { label: 'Name', fieldName: 'value', wrapText: true },
        { label: 'Email', fieldName: 'email', wrapText: true },
        { label: 'Address', fieldName: 'address', wrapText: true },
        {
            label: 'Primary', fieldName: 'primary', wrapText: true, type: 'checkbox', standardCellLayout: true,
            typeAttributes: {
                value: { fieldName: 'primary' },
                rowKey: { fieldName: 'key' },
                checked: { fieldName: 'primary' },
                fieldName: 'primary',
                keyField: 'key'
            },
            cellAttributes: {
                class: 'slds-cell-edit'
            }
        },
        {
            label: 'Sequence', fieldName: 'sequence', wrapText: true, type: 'number', cellAttributes: {
                standardCellLayout: true
            },
            editable: true
        }
    ];

    newPFShortTitle = '';
    newPFInventionTitle = '';
    clientRefNoDefault = '';
    clientRefNo = '';
    @wire(getRecord, { recordId: '$conflictCheckId', fields: CC_FIELDS })
    wiredConflictCheck({ error, data }) {
        console.log('data from cc', JSON.stringify(data));

        if (data) {
            if (data.fields.Matter_Name__c.value != null) {
                // Assign Matter_Name__c to shortTitle and longTitle
                const matterName = data.fields.Matter_Name__c.value;
                // Crop shortTitle to 80 characters
                this.newPFShortTitle = matterName.length > 80 ? matterName.substring(0, 80) : matterName;
                // Crop longTitle to 255 characters
                this.newPFInventionTitle = matterName.length > 255 ? matterName.substring(0, 255) : matterName;
            }
            if(data.fields.Client_Reference_Number__c.value != null){
                this.clientRefNoDefault = data.fields.Client_Reference_Number__c.value;
            }
            

        } else if (error) {

            console.error('Error fetching Conflict_Check__c record:', error);
            
        }
    }

    @track draftValues = [];
    async handleCellChange(event) {
        try {
            // Assuming SEQUENCE_FIELD and other necessary imports are already defined

            // Clear previous errors
            this.sequenceError = '';

            // Get updated fields from the event
            const updatedFields = event.detail.draftValues[0];
            console.log(JSON.stringify(updatedFields) + ' event.detail.draftValues[0]');
            const sequenceAsInteger = parseInt(updatedFields.sequence, 10); // Base 10
            console.log(sequenceAsInteger);

            // Initialize an array to collect errors
            const errors = [];

            // Iterate over each inventor to perform validations
            this.selectedInventors.forEach(item => {
                // Check for duplicate sequence
                if (item.sequence === sequenceAsInteger && item.key !== updatedFields.key) {
                    errors.push('This sequence already exists for another inventor.');
                }

                // Check if the inventor is primary and has the correct sequence
                if (item.key === updatedFields.key && item.primary && sequenceAsInteger !== 1) {
                    errors.push('Primary inventor must have a sequence of 1.');
                }
            });

            // Additional validations outside the loop
            if (sequenceAsInteger <= 0) {
                errors.push('Please enter Sequence No greater than 0.');
            }

            if (sequenceAsInteger > this.selectedInventors.length) {
                errors.push('Please enter Sequence No less than or equal to Total size of selected Inventors.');
            }

            // Combine all errors into a single message
            if (errors.length > 0) {
                this.sequenceError = errors.join(' ');
            }


            this.selectedInventors.forEach(item => {
                if (item.key === updatedFields.key) {
                    item.sequence = sequenceAsInteger; // Update the sequence
                }
            });

            if (this.sequenceError == '') {
                this.sequenceError = this.validateInventorSequence();
            }

            // Force a re-render to clear draft values
            setTimeout(() => {
                this.draftValues = []; // Ensure the draft values are cleared
            }, 10);
            // to refresh the data after editing
            this.selectedInventors = this.selectedInventors.map(({ selected, ...rest }) => rest);
            this.inventors = this.inventors.map(({ selected, ...rest }) => rest);
            this.template.querySelector(".inventor").setValues(this.inventors, this.selectedInventors);
            this.inventors = [...this.inventors];
            this.selectedInventors = [...this.selectedInventors];
            console.log(' inventors ' + JSON.stringify(this.inventors));

            if (this.jurisdictionList.length > 0) {
                // Create a map for quick key lookup of sequences
                const sequenceMap = this.selectedInventors.reduce((acc, curr) => {
                    acc[curr.key] = curr.sequence; // Map the key to the sequence number
                    return acc;
                }, {});
                console.log('sequenceMap ' + JSON.stringify(sequenceMap));
                console.log('sequenceMap ' + sequenceMap);
                
                // Update jurisdictionList with sequence information
                this.jurisdictionList = this.jurisdictionList.map(jurisdiction => {
                    const updatedSelectedInventors = jurisdiction.selectedInventors.map(inventor => {
                        console.log('sequenceMap ' + sequenceMap[inventor.key]);
                        return {
                            ...inventor,
                            sequence: sequenceMap[inventor.key] !== undefined ? sequenceMap[inventor.key] : null // Update sequence
                        };
                    });

                    return {
                        ...jurisdiction,
                        selectedInventors: updatedSelectedInventors
                    };
                });
                console.log(JSON.stringify(this.jurisdictionList) + 'tjis list');
                
            }
        } catch (err) {
            console.log('OUTPUT : err message', err.message);
        }

    }




    applicantsColumns = [{ label: 'Name', fieldName: 'value', wrapText: true },
    { label: 'Registered Applicant', fieldName: 'registeredApplicant', wrapText: true },
    { label: 'Address', fieldName: 'address', wrapText: true },
    { label: 'Action', type: 'button-icon', cellAttributes: { class: 'iconTdClass', alignment: 'right' }, typeAttributes: { class: { fieldName: 'rowEditBtnCls' }, iconClass: 'editIcon', iconName: 'utility:edit', title: 'Edit', name: 'edit', variant: 'container', disabled: { fieldName: 'disableAction' } }, initialWidth: 40 },
    ];

    jurisdictionColumns = [
        { label: 'Jurisdiction', fieldName: 'jurisdictionName', wrapText: true },
        { label: 'Case Type', fieldName: 'caseTypeValue', wrapText: true },
        { label: 'Originating Attorney', fieldName: 'responsiblePartnerName', wrapText: true },
        { label: 'Responsible (Billing) Attorney', fieldName: 'responsibleAttorneyName', wrapText: true },
        { label: 'Agent', fieldName: 'foreignAssociateName', wrapText: true },
        { label: 'Act', type: 'button-icon', cellAttributes: { class: 'iconTdClass', alignment: 'right' }, typeAttributes: { class: { fieldName: 'rowEditBtnCls' }, iconClass: 'editIcon', iconName: 'utility:edit', title: 'Edit', name: 'edit', variant: 'container', disabled: { fieldName: 'disableAction' } }, initialWidth: 40 },
        { label: 'ions', type: 'button-icon', cellAttributes: { class: 'iconTdClass', alignment: 'left' }, typeAttributes: { class: { fieldName: 'rowDeleteBtnCls' }, iconClass: 'deleteIcon', iconName: 'utility:delete', title: 'Delete', name: 'delete', variant: 'container', disabled: { fieldName: 'disableAction' } }, initialWidth: 40 },
    ];


    portfolioOptions = [{ label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' }];

    prosecutionManagedOptions = [{ label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' }];

    renewalsAnnuitiesOptions = [{ label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' }];

    priorityAssetTypeOptions = [{ label: 'Patent', value: 'Patent' },
    { label: 'Utility Model', value: 'Utility Model' }];

    priorityColumns = [
        { label: 'Jurisdiction', fieldName: 'SymphonyLF__Country__r.Name', wrapText: true },
        { label: 'Docket Number', fieldName: 'SymphonyLF__Docket_Number__c', wrapText: true },
        { label: 'Case Type', fieldName: 'SymphonyLF__Case_Type__c', wrapText: true },
        { label: 'Application Number', fieldName: 'SymphonyLF__Filing_Number__c', wrapText: true },
        { label: 'Filing Date', fieldName: 'SymphonyLF__Application_Date__c', type: 'date', typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' }, wrapText: true }];

    get options() {
        return [
            { label: 'An Existing Patent Family', value: 'An Existing Patent Family' },
            { label: 'New Patent Family', value: 'New Patent Family' },
        ];
    }

    @track assetTypeOptions = [];

    //store record type id of recordtye name ="External"

    personRecordTypeId;
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
            // perform your logic related to error 
        }
    };


    connectedCallback() {
        console.log('Child is loaded');
        this.keywordFlag = false;
        getKeywords()
        .then(keywordResults =>{
            if(keywordResults != null){
                this.keywords = [...keywordResults.map(keyword => ({
                    label: keyword.Name,  
                    value: keyword.Name,  
                    key: keyword.Id,
                    fullName : keyword.SymphonyLF__Full_Name__c
                }))];
                console.log('this keywords ' + JSON.stringify(this.keywords));
                this.keywordFlag = true;
            }
        })

        getPicklistValuesMethod({ objectName: 'SymphonyLF__Patent__c', fieldName: 'SymphonyLF__IP_Matter__c' })
            .then(res => {
                if (res != null) {

                    for (const key in res) {
                        this.assetTypeOptions.push({ label: res[key], value: key });
                    }
                }
            })


        getDependentAddress().then(result => {

            if (result != null && result) {

                this.addressDependentPicklist = result.fieldDependencyMap;
            }
        });

        getAddressOptions({ option: 'country' }).then(result => {
            if (result && result != '') {

                this.countryOptions = result;
                this.inventorCountryOptions = this.countryOptions;
            }
        })

        getAddressOptions({ option: 'state' }).then(result => {
            if (result && result != '') {

                this.stateOptions = result;
            }
        })

        this.clientWhereCond = "(SymphonyLF__Active__c = true and SymphonyLF__Client__c!=null)";

        if (this.clientId != null) {
            this.disableOptions = false;
        }
    }
    renderedCallback() {
        if (!this.styleTagAppended) {
            let styleSource = document.createElement('style');
            styleSource.innerText = '.slds-form-element__label.slds-form-element__legend{font-weight: normal;}.slds-form-element__control .slds-radio{display: inline-block !important;padding-right: 15px;}';
            styleSource.innerText += '.slds-th__action{background-color: #f3f3f3 !important;} .slds-icon_container_circle{background-color: limegreen !important;} .iconTdClass{ padding:0 0.15rem !important;}';
            styleSource.innerText += '.iconTdClass .slds-icon{ width: var(--lwc-squareIconXxSmallContent,.875rem);height: var(--lwc-squareIconXxSmallContent,.875rem);line-height: var(--lwc-lineHeightReset,1);}';
            styleSource.innerText += 'th[aria-label="Act"] .slds-th__action{ padding: 0; justify-content: end; } th[aria-label="ions"] .slds-th__action{ padding: 0; }';
            styleSource.innerText += 'th[aria-label="Act"] .slds-resizable__divider{ display: none;}';
            styleSource.innerText += '.slds-hyphenate { width: 100%;}';
            this.template.querySelector('.source').appendChild(styleSource);
            this.styleTagAppended = true;
        }

    }
    // Added by Abhijeet Sontakke [20-02-2024] : JIRA: HEISD-393
    get showComponent() {
        return this.messageId !== undefined && this.messageId !== null && this.messageId !== '';
    }
    get formElements() {
        let className = "slds-p-around_xxx-small ";
        if (this.showComponent) {
            className += "slds-col slds-size_2-of-3";
        } else {
            className += "slds-col slds-size_1-of-1";
        }
        return className;
    }
    get inputVariables() {
        return [
            {
                name: 'iEmailMessageId',
                type: 'String',
                value: this.messageId
            }
        ];
    }

    // End HEISD-393
    handleSelectedClientRecord(event) {
        if (event.detail != null && event.detail.length > 0) {
            this.clientId = event.detail[0].Id;
            this.disableOptions = false;
            console.log('fetch result--1');
            this.fetchApplicantsAndDesignerHelper();

        }
        else {
            this.disableOptions = true;
            this.mainRadioValue = '';
            this.showForm = false;
            this.showAll = false;
            this.resetForm();
            this.patentFamilyData = [];
            this.initialPatentFamilyData = [];
            this.patentFamilyTableHeight = '';
        }

        console.log(this.clientId, ' client id ');

        this.handleEngagementDetails();
    }

    async fetchApplicantsAndDesignerHelper() {
        await fetchApplicantsAndInventorsData({ clientId: this.clientId })
            .then(result => {
                if (result) {
                    console.log('fetch result-' + JSON.stringify(result));
                    if (result.patentFamily != null && result.patentFamily.length > 0) {
                        this.patentFamilyData = result.patentFamily;
                        this.initialPatentFamilyData = [...this.patentFamilyData];
                        this.patentFamilyTableHeight = this.patentFamilyData.length > 7 ? 'height:300px' : '';
                    }
                    if (result.applicants != null && result.applicants.length > 0) {
                        this.applicants = [];
                        for (let row of result.applicants) {
                            const applicant = {};
                            applicant.label = row.Name;
                            applicant.value = row.Name;
                            applicant.registeredApplicant = row.Name;


                            applicant.key = row.Id;
                            let address = '';
                            let addressedit = {};
                            if (row.SymphonyLF__Address__c != undefined) {
                                if (row.SymphonyLF__Address__c.street != undefined) {
                                    address += row.SymphonyLF__Address__c.street + ', ';
                                    addressedit.street = row.SymphonyLF__Address__c.street;

                                }
                                if (row.SymphonyLF__Address__c.city != undefined) {
                                    address += row.SymphonyLF__Address__c.city + ', ';
                                    addressedit.city = row.SymphonyLF__Address__c.city;

                                }
                                if (row.SymphonyLF__Address__c.state != undefined) {
                                    address += row.SymphonyLF__Address__c.state + ', ';

                                    addressedit.state = row.SymphonyLF__Address__c.state;

                                }
                                if (row.SymphonyLF__Address__c.stateCode != undefined) {
                                    addressedit.state = row.SymphonyLF__Address__c.stateCode;

                                }
                                if (row.SymphonyLF__Address__c.postalCode != undefined) {
                                    address += row.SymphonyLF__Address__c.postalCode + ', ';
                                    addressedit.postalCode = row.SymphonyLF__Address__c.postalCode;

                                }
                                if (row.SymphonyLF__Address__c.country != undefined) {
                                    address += row.SymphonyLF__Address__c.country;
                                    let arraysss = this.countryOptions.filter(ro => ro.label == row.SymphonyLF__Address__c.country)
                                    addressedit.country = arraysss[0] == undefined ? "" : arraysss[0].code;

                                }
                            }
                            applicant.address = address;
                            applicant.addressedit = addressedit;
                            this.applicants.push(applicant);
                        }
                        this.applicants = [...this.applicants];
                        this.inventorAndApplicantFlag = true;
                    }
                    if (result.inventors != null && result.inventors.length > 0) {
                        this.inventors = [];
                        for (let row of result.inventors) {
                            const inventor = {};
                            if (row.SymphonyLF__Email__c) {
                                inventor.label = row.Name + ' - ' + row.SymphonyLF__Email__c;
                                inventor.email = row.SymphonyLF__Email__c;
                            }
                            else
                                inventor.label = row.Name;
                            inventor.value = row.Name;
                            inventor.key = row.Id;
                            let address = '';

                            if (row.SymphonyLF__Address__c != undefined) {
                                if (row.SymphonyLF__Address__c.street != undefined) {
                                    address += row.SymphonyLF__Address__c.street + ', ';
                                }
                                if (row.SymphonyLF__Address__c.city != undefined) {
                                    address += row.SymphonyLF__Address__c.city + ', ';
                                }
                                if (row.SymphonyLF__Address__c.State != undefined) {
                                    address += row.SymphonyLF__Address__c.State + ', ';
                                }
                                if (row.SymphonyLF__Address__c.postalCode != undefined) {
                                    address += row.SymphonyLF__Address__c.postalCode + ', ';
                                }
                                if (row.SymphonyLF__Address__c.country != undefined) {
                                    address += row.SymphonyLF__Address__c.country;
                                }
                            }
                            inventor.address = address;
                            inventor.primary = false;
                            this.inventors.push(inventor);
                        }
                        this.inventors = [...this.inventors];
                        this.inventorAndApplicantFlag = true;
                    }
                }
                console.log('after result');
            });
    }

    handleEngagementDetails() {
        getClientCEMdetails({ clientId: this.clientId, moduleName: 'Patent', allJurisdiction: true, jurisdictionId: '' })
            .then(res => {
                if (res != null) {

                    if (this.engagementDetailsPF.length == 0) {
                        this.engagementDetailsPF = res;
                    }

                } else {
                    this.engagementDetailsPF = [];
                }
            })
    }

    handleSourceChange(event) {
        this.mainRadioValue = event.target.value;
        this.resetForm();
        if (this.mainRadioValue == 'An Existing Patent Family') {
            this.showFamilyDetails = true;
            this.showForm = true;
            this.showAll = false;
            this.showPatentApplications = true;
            this.activeSections = [];
            this.activeSections = ['existingPatentFamilies'];
        }
        else if (this.mainRadioValue == 'New Patent Family') {
            this.shortTitle = this.newPFShortTitle;
            this.inventionTitle = this.newPFInventionTitle;
            this.showFamilyDetails = false;
            this.showForm = false;
            console.log('activeSections-' + this.activeSections);
            this.activeSections = [];
            this.activeSections = ['existingPatentFamilies', 'basicDetails', 'ccDetails', 'existingPatentApplications', 'businessCategory', 'inventors', 'applicants', 'jurisdictions', 'keywords'];
            this.activeSections = [...this.activeSections, 'engagementDetails'];
            this.showAll = true;
            this.showPatentApplications = false;


            this.handleEngagementDetails();
        }
    }

    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        console.log('searchKey-' + searchKey);
        this.patentFamilyData = [...this.initialPatentFamilyData];
        if (searchKey) {
            if (this.patentFamilyData.length > 0) {
                let recs = [];
                for (let rec of this.patentFamilyData) {
                    let valuesArray = Object.values(rec);
                    for (let val of valuesArray) {
                        let strVal = String(val);
                        if (strVal) {
                            if (strVal.toLowerCase().includes(searchKey)) {
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                this.patentFamilyData = [...recs];
                console.log('recs-' + JSON.stringify(this.patentFamilyData));
            }
            else {
                this.patentFamilyData = [...this.initialPatentFamilyData];
            }
        }
        else {
            this.patentFamilyData = [];
            this.patentFamilyData = [...this.initialPatentFamilyData];
        }
    }

    getSelectedPatentFamily(event) {
        try {
            this.inventorAndApplicantFlag = false;
            this.keywordFlag = false;
            let patentId = '';
            let selectedPatentFamily = [];
            selectedPatentFamily = event.detail.selectedRows;
            this.selectedBusinessInfos = [];
            this.jurisdictionList = [];
            this.selectedApplicants = [];
            this.selectedInventors = [];
            this.fetchApplicantsAndDesignerHelper();
            this.inventors = [...this.inventors];
            console.log('removed', this.selectedApplicants);
            console.log('selectedPatentFamily-' + JSON.stringify(selectedPatentFamily));
            if (selectedPatentFamily != null && selectedPatentFamily.length > 0) {
                this.patentFamilyId = selectedPatentFamily[0].Id;
                this.activeSections = [];
                this.activeSections = ['basicDetails', 'ccDetails', 'jurisdictions'];
                this.showAll = true;
                this.patentFamilyError = (this.mainRadioValue == 'An Existing Patent Family' && this.patentFamilyId == '') ? 'Please select any one patent family.' : '';
                this.jurisdictionError = '';
                this.inventorError = '';
                this.showPatentApplications = true;
                let familyRecord = this.patentFamilyData.filter(x => x.Id == selectedPatentFamily[0].Id);
                console.log('familyRecord-' + JSON.stringify(familyRecord));
                if (familyRecord.length > 0) {
                    this.readonly = true;
                    // this.inventionDate = familyRecord[0].SymphonyLF__Invention_Date__c;
                    this.inventionTitle = familyRecord[0].SymphonyLF__Invention_Title__c;
                    // this.inventionDescription = familyRecord[0].SymphonyLF__Invention_Description__c;
                    // this.earliestPriorityDate = familyRecord[0].SymphonyLF__Earliest_Priority_Date__c;
                    this.shortTitle = familyRecord[0].Name;
                    this.patentData = [];
                    this.patentTableHeight = '';
                    this.template.querySelectorAll('.inventor').forEach((record) => {
                        console.log('records', record);
                        record.reset();
                    });
                    this.template.querySelectorAll('.applicant').forEach((record) => {
                        console.log('records', record);
                        record.reset();
                    });//removed Client_Reference__c,Portfolio_Management__c field in below query
                    let patentQuery = 'Select Name,SymphonyLF__Country__c,SymphonyLF__Docket_Number__c,SymphonyLF__Application_Date__c,SymphonyLF__Filing_Number__c,SymphonyLF__Case_Type__c,SymphonyLF__IP_Matter__c,SymphonyLF__Patent_Status__c,SymphonyLF__Title__c,SymphonyLF__Country__r.Name from SymphonyLF__Patent__c where  SymphonyLF__Client__c= \'' + this.clientId + '\' AND SymphonyLF__Patent_Family__c=\'' + this.patentFamilyId + '\'';//SymphonyLF__Asset_Type__c
                    console.log('patentewuery - ' + patentQuery);
                    getRecordByQuery({ query: patentQuery }).then(result => {
                        if (result && result.length > 0) {
                            let patentIds = [];
                            result.forEach(item => {
                                patentIds.push(item.Id);
                            })
                            getMemDetails({ patentIdList: patentIds }).then(result => {
                                if (result.length > 0) {
                                    console.log(result);
                                    this.patentData = JSON.parse(result);
                                    for (let i of this.patentData) {
                                        i['URLforDetailPage'] = '/' + i['patentId'];
                                    }
                                    console.log(this.patentData);
                                }
                            })
                            console.log('patentIDS', JSON.stringify(patentIds))
                        }
                    })
                    let inventorQuery = "Select Id,SymphonyLF__Contact__c,Sequence__c,SymphonyLF__Primary_Inventor__c,SymphonyLF__Contact__r.Name,SymphonyLF__Contact__r.SymphonyLF__Email__c,SymphonyLF__Contact__r.SymphonyLF__Address__c FROM SymphonyLF__Inventor_Designer_Author__c where SymphonyLF__Patent_Family__c='" + this.patentFamilyId + "' AND SymphonyLF__Type__c='Inventor'";
                    console.log('query-' + inventorQuery);
                    getRecordByQuery({ query: inventorQuery }).then(result => {
                        if (result && result.length > 0) {
                            //  let selectedInventorsTemp = [];
                            for (let row of result) {
                                const inventor = {};
                                inventor.label = row.SymphonyLF__Contact__r.Name;
                                inventor.value = row.SymphonyLF__Contact__r.Name;
                                inventor.key = row.SymphonyLF__Contact__c;
                                inventor.existing = true;
                                inventor.sequence = row.Sequence__c;
                                inventor.email = row.SymphonyLF__Contact__r.SymphonyLF__Email__c;
                                let address = '';
                                if (row.SymphonyLF__Contact__r.SymphonyLF__Address__c != undefined) {
                                    if (row.SymphonyLF__Contact__r.SymphonyLF__Address__c.street != undefined) {
                                        address += row.SymphonyLF__Contact__r.SymphonyLF__Address__c.street + ', ';
                                    }
                                    if (row.SymphonyLF__Contact__r.SymphonyLF__Address__c.city != undefined) {
                                        address += row.SymphonyLF__Contact__r.SymphonyLF__Address__c.city + ', ';
                                    }
                                    if (row.SymphonyLF__Contact__r.SymphonyLF__Address__c.State != undefined) {
                                        address += row.SymphonyLF__Contact__r.SymphonyLF__Address__c.State + ', ';
                                    }
                                    if (row.SymphonyLF__Contact__r.SymphonyLF__Address__c.postalCode != undefined) {
                                        address += row.SymphonyLF__Contact__r.SymphonyLF__Address__c.postalCode + ', ';
                                    }
                                    if (row.SymphonyLF__Contact__r.SymphonyLF__Address__c.country != undefined) {
                                        address += row.SymphonyLF__Contact__r.SymphonyLF__Address__c.country;
                                    }
                                }
                                inventor.primary = row.SymphonyLF__Primary_Inventor__c;
                                inventor.existingRecId = row.Id;
                                inventor.address = address;
                                this.selectedInventors.push(inventor);
                            }
                            this.selectedInventors = this.selectedInventors.map(({ selected, ...rest }) => rest);
                            this.inventors = this.inventors.map(({ selected, ...rest }) => rest);
                            this.template.querySelector(".inventor").setValues(this.inventors, this.selectedInventors);
                            this.selectedInventors = [...this.selectedInventors];
                            this.inventorsTable = [...this.selectedInventors];
                            this.inventors = [...this.inventors];

                            console.log('selectedInventors-patent-' + JSON.stringify(this.selectedInventors));
                        }
                    });
                    let applicantsQuery = "Select Id,SymphonyLF__Client__c,SymphonyLF__Client__r.Name, SymphonyLF__Role__c, SymphonyLF__Registered_Applicant__c, SymphonyLF__Address__City__s, SymphonyLF__Address__CountryCode__s, SymphonyLF__Address__StateCode__s, SymphonyLF__Address__Street__s, SymphonyLF__Address__PostalCode__s FROM SymphonyLF__Chain_of_Title__c where SymphonyLF__Patent_Family__c='" + this.patentFamilyId + "' AND SymphonyLF__Role__c='Applicant'";
                    console.log('query-' + applicantsQuery);
                    getRecordByQuery({ query: applicantsQuery }).then(result => {
                        if (result && result.length > 0) {
                            this.selectedApplicants = [];
                            for (let row of result) {
                                const applicant = {};
                                applicant.existingApplicantId = row.Id;
                                applicant.label = row.SymphonyLF__Client__r.Name;
                                applicant.value = row.SymphonyLF__Client__r.Name;
                                applicant.key = row.SymphonyLF__Client__c;
                                applicant.registeredApplicant = row.SymphonyLF__Registered_Applicant__c;
                                applicant.addressedit = {};
                                // applicant.email = row.SymphonyLF__Contact__r.SymphonyLF__Email__c;
                                let address = '';
                                // if (row.SymphonyLF__Contact__r.SymphonyLF__Address__c != undefined) {
                                if (row.SymphonyLF__Address__Street__s != undefined) {
                                    address += row.SymphonyLF__Address__Street__s + ', ';
                                    applicant.addressedit.street = row.SymphonyLF__Address__Street__s;
                                }
                                if (row.SymphonyLF__Address__City__s != undefined) {
                                    address += row.SymphonyLF__Address__City__s + ', ';
                                    applicant.addressedit.city = row.SymphonyLF__Address__City__s;
                                }
                                if (row.SymphonyLF__Address__StateCode__s != undefined) {
                                    address += row.SymphonyLF__Address__StateCode__s + ', ';
                                    applicant.addressedit.state = row.SymphonyLF__Address__StateCode__s;
                                }
                                if (row.SymphonyLF__Address__PostalCode__s != undefined) {
                                    address += row.SymphonyLF__Address__PostalCode__s + ', ';
                                    applicant.addressedit.postalCode = row.SymphonyLF__Address__PostalCode__s;
                                }
                                if (row.SymphonyLF__Address__CountryCode__s != undefined) {
                                    address += row.SymphonyLF__Address__CountryCode__s;
                                    applicant.addressedit.country = row.SymphonyLF__Address__CountryCode__s;
                                }

                                // }
                                applicant.address = address;





                                this.selectedApplicants.push(applicant);
                            }
                            this.selectedApplicants = [...this.selectedApplicants];
                            this.applicantsTable = [...this.selectedApplicants];
                            this.template.querySelector(".applicant").setValues(this.applicants, this.selectedApplicants);
                            console.log('selectedApplicants-patent-' + JSON.stringify(this.selectedApplicants));
                        }
                    });

                    let businessQuery = "Select Id,SymphonyLF__Client_Business_Category_New__r.SymphonyLF__Category_Value__c, SymphonyLF__Client_Business_Category_New__c, Name, SymphonyLF__Client_Business_Category_New__r.SymphonyLF__Category_Formula__c FROM SymphonyLF__Matter_Business_Category__c where Patent_Family__c='" + this.patentFamilyId + "'";
                    console.log('query-' + businessQuery);

                    getRecordByQuery({ query: businessQuery }).then(result => {
                        if (result && result.length > 0) {
                            this.selectedBusinessInfos = [];
                            for (let row of result) {
                                const business = {};
                                business.Id = row.SymphonyLF__Client_Business_Category_New__c;
                                business.SymphonyLF__Category_Value__c = row.SymphonyLF__Client_Business_Category_New__r.SymphonyLF__Category_Value__c;
                                business.Name = row.Name;
                                business.SymphonyLF__Category_Formula__c = row.SymphonyLF__Client_Business_Category_New__r.SymphonyLF__Category_Formula__c;
                                business.existingBCId = row.Id;
                                business.existing = true;
                                this.selectedBusinessInfos.push(business);
                            }
                            this.selectedBusinessInfos = [... this.selectedBusinessInfos];
                            this.businessCategoriesTable = [... this.selectedBusinessInfos];

                        }
                    });

                    let keywordQuery = "Select Id, SymphonyLF__Keyword__c, SymphonyLF__Keyword__r.Name, SymphonyLF__Keyword__r.SymphonyLF__Full_Name__c from SymphonyLF__Keyword_Association__c where SymphonyLF__Keyword__c != null AND SymphonyLF__Patent_Family__c='" + this.patentFamilyId + "'";
                    console.log('query-' + keywordQuery);

                    getRecordByQuery({ query: keywordQuery }).then(result => {
                        if (result && result.length > 0) {
                            this.selectedkeywords = [];
                            for (let row of result) {
                                const keyword = {};
                                keyword.label= row.SymphonyLF__Keyword__r.Name;
                                keyword.value = row.SymphonyLF__Keyword__r.Name;  
                                keyword.key = row.SymphonyLF__Keyword__c;
                                keyword.fullName = row.SymphonyLF__Keyword__r.SymphonyLF__Full_Name__c;
                                keyword.existing = true;
                                keyword.existingKeywordId = row.Id;
                                this.selectedkeywords.push(keyword);
                            }
                            this.selectedkeywords = [... this.selectedkeywords];
                            this.template.querySelector(".keyword").setValues(this.keywords, this.selectedkeywords);

                        }
                    });
                }
                this.inventorAndApplicantFlag = true;
                this.keywordFlag = true;
            }
            else {
                this.showPatentApplications = false;
                this.showAll = false;
                this.patentFamilyError = (this.mainRadioValue == 'An Existing Patent Family' && this.patentFamilyId == '') ? 'Please select any one patent family.' : '';
            }
        } catch (err) {
            console.log('mesg' + err.message);

        }
    }


    async handleValueChange(event) {
        try {

            event.stopPropagation();

            console.log('json ' + JSON.stringify(event.detail));
            let data = event.detail;
            let tempList = this.selectedInventors;
           
            const previousPrimaryUpdated = tempList.find(item => item.primary);
            let swapValue = '';
            tempList = [...tempList.map(item => {

                if (item.key === data.key) {
                    let obj = { ...item };
                    obj.primary = data.primary;
                    if (data.primary == true && item.sequence == null) {
                        //swapValue = previousPrimaryUpdated != undefined ? 'Empty' : 'NotEmpty';
                        obj.sequence = 1;
                        if (item.existing && item.existingRecId != undefined) {
                            //   this.createUpdatePromise(obj);
                        }

                    } else if (data.primary == true && item.sequence != null && item.sequence != 1) {
                        swapValue = previousPrimaryUpdated != undefined ? item.sequence : '';

                        obj.sequence = 1;

                        if (item.existing && item.existingRecId != undefined) {
                            // this.createUpdatePromise(obj);
                        }
                    }

                    //return { ...item, primary: data.primary };
                    return obj;
                }
                let outerObj = { ...item };
                outerObj.primary = false;
                
                return outerObj;
                // return { ...item, primary: false };
            })];
            tempList = [...tempList.map(item => {



                if (previousPrimaryUpdated != undefined && previousPrimaryUpdated.key == item.key) {
                    let outerObj = { ...item };
                    outerObj.primary = false;
                    outerObj.sequence = swapValue != '' ? parseInt(swapValue) : null;
                    return outerObj;
                }
                return item;
                // return { ...item, primary: false };
            })];
            
            this.selectedInventors = [...tempList];
            this.sequenceError = this.validateInventorSequence();
            console.log('this selection ' + JSON.stringify(this.selectedInventors));
            // to refresh the data after editing
            this.selectedInventors = this.selectedInventors.map(({ selected, ...rest }) => rest);
            this.inventors = this.inventors.map(({ selected, ...rest }) => rest);
            this.template.querySelector(".inventor").setValues(this.inventors, this.selectedInventors);
            this.inventors = [...this.inventors];
            this.selectedInventors = [...this.selectedInventors];
            if (this.jurisdictionList.length > 0) {
                // Create a map for quick key lookup
                const primaryMap = this.selectedInventors.reduce((acc, curr) => {
                    if (curr.primary) {
                        acc[curr.key] = true;
                    }
                    return acc;
                }, {});

                const sequenceMap = this.selectedInventors.reduce((acc, curr) => {
                    acc[curr.key] = curr.sequence; // Map the key to the sequence number
                    return acc;
                }, {});
                console.log('sequenceMap ' + JSON.stringify(sequenceMap));
                
                this.jurisdictionList = [...this.jurisdictionList.map(jurisdiction => {
                    // Update selectedInventors based on the primaryMap
                    const updatedSelectedInventors = jurisdiction.selectedInventors.map(inventor => {
                        console.log(' sequenceMap[inventor.key]  ' + sequenceMap[inventor.key] );
                        console.log(' sequenceMap[inventor.key]  ' + inventor.key );
                        
                        return {
                            ...inventor,
                            primary: primaryMap[inventor.key] !== undefined ? primaryMap[inventor.key] : false ,// Use value if exists, otherwise false
                            sequence: sequenceMap[inventor.key] !== undefined ? sequenceMap[inventor.key] : null // Update sequence
                        };
                    });

                    return {
                        ...jurisdiction,
                        selectedInventors: updatedSelectedInventors
                    };
                })];
            }
            console.log('this.jurisdictionList ' + JSON.stringify(this.jurisdictionList));
        } catch (err) {
            console.log('Error' + err.message);

        }


    }
    handleShortTitle(event) {
        this.shortTitle = event.target.value;
        this.shortTitleError = this.shortTitle.trim() == '' ? 'Complete this field.' : '';
        this.shortTitleErrorClass = this.shortTitle.trim() ? '' : 'slds-has-error';
    }

    handleInventionTitle(event) {
        this.inventionTitle = event.target.value;
        this.inventionTitleError = this.inventionTitle.trim() == '' ? 'Complete this field.' : '';
        this.inventionTitleErrorClass = this.inventionTitle.trim() ? '' : 'slds-has-error';
    }

    async handleInventors(event) {
        console.log('selectedIventors-1-' + JSON.stringify(this.selectedInventors));
        console.log('selectedIventors-1-' + JSON.stringify(event.detail));
        try {
            let tempList = event.detail;
            let selectedTempList = this.selectedInventors;
            if (tempList.length > selectedTempList.length) {
                // insert in Selected Inventor List for Jurisdiction List
                let temp2List = [];
                // find latest inserted value by comparing new inventorList and already selected inventor List 
                tempList.forEach(ele => {
                    if (!selectedTempList.find(e => e.key == ele.key)) {
                        temp2List.push(ele);
                    }
                })
                console.log('temp2list nsert' + JSON.stringify(temp2List));

                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        let obj = { ...ele };
                        console.log('before ' + JSON.stringify(obj.selectedInventors));
                        obj.selectedInventors = [...obj.selectedInventors, ...temp2List];
                        console.log('After ' + JSON.stringify(obj.selectedInventors));
                        return obj;
                    })]
                }

            } else if (tempList.length < selectedTempList.length) {
                // delete in Inventor List for Jurisdiction List, if already not deleted
                let temp2List = [];
                // find latest deleted value by comparing new inventorList and already selected inventor List 
                selectedTempList.forEach(ele => {
                    if (!tempList.find(e => e.key == ele.key)) {
                        temp2List.push(ele);
                    }
                })
                console.log('temp@List ' + JSON.stringify(temp2List));
                // Create a Set of existingRecIds from existingRecords
                const existingRecIds = new Set(temp2List.map(record => record.existingRecId).filter(id => id));

                // Check if Existing Inventor is getting deleted in temp2List
                const isDeleteExistingInventor = temp2List.some(record => record.existingRecId && existingRecIds.has(record.existingRecId));
                this.selectedInventors = this.selectedInventors.map(({ selected, ...rest }) => rest);
                this.inventors = this.inventors.map(({ selected, ...rest }) => rest);
                this.template.querySelector(".inventor").setValues(this.inventors, this.selectedInventors);
                this.inventors = [...this.inventors];
                this.selectedInventors = [...this.selectedInventors];
                if (isDeleteExistingInventor) {
                    // Show confirmation dialog
                    const result = await LightningConfirm.open({
                        message: this.warningMessage,
                        variant: 'headerless',  // Optional, you can choose 'headerless', 'warning', 'destructive'
                        label: 'Confirm Removal',  // Optional, set the button label text
                    });
    
                    // If the user clicked "Yes"
                    if (result) {
                        console.log('Record deleted!');
                        // Perform the deletion logic here (e.g., remove from jurisdictionList)
                    } else {
                        console.log('Deletion canceled');
                       
                        return;  // Exit early if the user cancels
                    }
                    
                } 
                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        let obj = { ...ele };
                        obj.selectedInventors = obj.selectedInventors.map(ele => {
                            if (!temp2List.find(e => e.key == ele.key)) {
                                return ele
                            } else {
                                return null
                            }
                        }).filter(ele => ele !== null);
                        return obj;
                    })]
                }

            } else {
                // update selectedInventors for Jurisdicition List
                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        return { ...ele, selectedInventors: tempList };
                    })]
                }
            }
        } catch (err) {
            console.log('err111111' + err.message);

        }
        console.log(JSON.stringify(this.jurisdictionList));


        this.selectedInventors = event.detail;
        this.selectedInventors = [...this.selectedInventors];
        this.inventors = [...this.inventors];
        this.selectedInventors = this.selectedInventors.map(({ selected, ...rest }) => rest);
        this.inventors = this.inventors.map(({ selected, ...rest }) => rest);
        this.template.querySelector(".inventor").setValues(this.inventors, this.selectedInventors);
        this.inventorTableHeight = this.selectedInventors.length > 7 ? 'height:300px' : '';
        this.inventorsTable = [...this.selectedInventors];
        this.inventorError = this.selectedInventors != null && this.selectedInventors.length > 0 ? '' : 'At least one inventor is required.';
        console.log('selectedIventors-' + JSON.stringify(this.selectedInventors));
    }

    async handleSelectedBusinessInfos(event) {
        try {
            let tempList = event.detail;
            let selectedTempList = this.selectedBusinessInfos;
            if (tempList.length > selectedTempList.length) {
                // insert
                let temp2List = [];
                tempList.forEach(ele => {
                    if (!selectedTempList.find(e => e.Id == ele.Id)) {
                        temp2List.push(ele);
                    }
                })
                console.log('temp2list nsert' + JSON.stringify(temp2List));

                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        let obj = { ...ele };
                        console.log('before ' + JSON.stringify(obj.selectedBusinessInfos));
                        obj.selectedBusinessInfos = [...obj.selectedBusinessInfos, ...temp2List];
                        console.log('After ' + JSON.stringify(obj.selectedBusinessInfos));
                        return obj;
                    })]
                }

            } else if (tempList.length < selectedTempList.length) {
                // delete
                let temp2List = [];
                selectedTempList.forEach(ele => {
                    if (!tempList.find(e => e.Id == ele.Id)) {
                        temp2List.push(ele);
                    }
                })
                console.log('temp@List ' + JSON.stringify(temp2List));
                // Create a Set of existingRecIds from existingRecords
                const existingRecIds = new Set(temp2List.map(record => record.existingBCId).filter(id => id));

                // Check if Existing Inventor is getting deleted in temp2List
                const isDeleteExistingBC = temp2List.some(record => record.existingBCId && existingRecIds.has(record.existingBCId));
                this.selectedBusinessInfos = [...this.selectedBusinessInfos];
                if (isDeleteExistingBC) {
                    console.log('before' + JSON.stringify(this.selectedBusinessInfos));

                    // Show confirmation dialog
                    const result = await LightningConfirm.open({
                        message: this.warningMessage,
                        variant: 'headerless',  // Optional, you can choose 'headerless', 'warning', 'destructive'
                        label: 'Confirm Removal',  // Optional, set the button label text
                    });
    
                    // If the user clicked "Yes"
                    if (result) {
                        console.log('Record deleted!');
                        // Perform the deletion logic here (e.g., remove from jurisdictionList)
                    } else {
                        console.log('Deletion canceled');
                       
                        return;  // Exit early if the user cancels
                    }
                } 
                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        let obj = { ...ele };
                        obj.selectedBusinessInfos = obj.selectedBusinessInfos.map(ele => {
                            if (!temp2List.find(e => e.Id == ele.Id)) {
                                return ele
                            } else {
                                return null
                            }
                        }).filter(ele => ele !== null);
                        return obj;
                    })]
                }

            } else {
                // update selectedInventors for Jurisdicition List
                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        return { ...ele, selectedBusinessInfos: tempList };
                    })]
                }
            }
        } catch (err) {
            console.log('err111111' + err.message);

        }
        this.selectedBusinessInfos = event.detail;
        this.selectedBusinessInfos = [...this.selectedBusinessInfos];
        this.businessCategoriesTable = [...this.selectedBusinessInfos];
        this.busiCategoryActionHeight = this.selectedBusinessInfos.length > 7 ? 'height:300px' : '';
        console.log('business-' + JSON.stringify(this.selectedBusinessInfos));
        // this.showBusinessInformationError = this.selectedBusinessInfos.length == 0 ? 'At least one Business Category is required' : '';
    }

    handleNewInventor() {
        this.showInventorPopup = true;
        this.personName = '';
        this.emailAddress = '';
        // this.personNameError = '';
        // this.personNameErrorClass = '';
        this.emailAddressError = '';
        this.Inventortype = 'Client';
        this.contactType = 'Inventor';
        this.inventorAddress = '';
        this.user = '';
        this.nationality = '';
        this.phone = '';
        this.assistant = '';
        this.linkToCard = '';
        this.linkToProfile = '';
        this.mobilePhone = '';
        this.extension = '';
        this.isButtonDisabled = false;
        this.inventorError = '';
    }

    async handleApplicants(event) {
        try {
            let tempList = event.detail;
            let selectedTempList = this.selectedApplicants;
            if (tempList.length > selectedTempList.length) {
                // insert
                let temp2List = [];
                tempList.forEach(ele => {
                    if (!selectedTempList.find(e => e.key == ele.key)) {
                        temp2List.push(ele);
                    }
                })
                console.log('temp2list nsert' + JSON.stringify(temp2List));

                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        let obj = { ...ele };
                        console.log('before ' + JSON.stringify(obj.selectedApplicants));
                        obj.selectedApplicants = [...obj.selectedApplicants, ...temp2List];
                        console.log('After ' + JSON.stringify(obj.selectedApplicants));
                        return obj;
                    })]
                }

            } else if (tempList.length < selectedTempList.length) {
                // delete
                let temp2List = [];
                selectedTempList.forEach(ele => {
                    if (!tempList.find(e => e.key == ele.key)) {
                        temp2List.push(ele);
                    }
                })
                console.log('temp@List ' + JSON.stringify(temp2List));
                const existingRecIds = new Set(temp2List.map(record => record.existingApplicantId).filter(id => id));

                // Check if Existing Inventor is getting deleted in temp2List
                const isDeleteExistingApplicant = temp2List.some(record => record.existingApplicantId && existingRecIds.has(record.existingApplicantId));
                this.selectedApplicants = this.selectedApplicants.map(({ selected, ...rest }) => rest);
                this.applicants = this.applicants.map(({ selected, ...rest }) => rest);
                this.template.querySelector(".applicant").setValues(this.applicants, this.selectedApplicants);
                this.applicants = [...this.applicants];
                if (isDeleteExistingApplicant) {
                    
                    // Show confirmation dialog
                    const result = await LightningConfirm.open({
                        message: this.warningMessage,
                        variant: 'headerless',  // Optional, you can choose 'headerless', 'warning', 'destructive'
                        label: 'Confirm Removal',  // Optional, set the button label text
                    });
    
                    // If the user clicked "Yes"
                    if (result) {
                        console.log('Record deleted!');
                        // Perform the deletion logic here (e.g., remove from jurisdictionList)
                    } else {
                        console.log('Deletion canceled');
                       
                        return;  // Exit early if the user cancels
                    }
                }
                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        let obj = { ...ele };
                        obj.selectedApplicants = obj.selectedApplicants.map(ele => {
                            if (!temp2List.find(e => e.key == ele.key)) {
                                return ele
                            } else {
                                return null
                            }
                        }).filter(ele => ele !== null);
                        return obj;
                    })]
                }

            } else {
                // update selectedInventors for Jurisdicition List
                if (this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                        return { ...ele, selectedApplicants: tempList };
                    })]
                }
            }
        } catch (err) {
            console.log('err111111' + err.message);

        }

        this.selectedApplicants = event.detail;
        this.selectedApplicants = [...this.selectedApplicants];
        this.applicantsTable = [...this.selectedApplicants];
        this.selectedApplicants = this.selectedApplicants.map(({ selected, ...rest }) => rest);
        this.applicants = this.applicants.map(({ selected, ...rest }) => rest);
        this.template.querySelector(".applicant").setValues(this.applicants, this.selectedApplicants);
        this.applicantTableHeight = this.selectedApplicants.length > 7 ? 'height:300px' : '';
        console.log('selectedApplicants-' + JSON.stringify(this.selectedApplicants));
        console.log('selectedApplicants-' + JSON.stringify(this.jurisdictionList));
    }

    handleNewApplicant() {
        // this.isApplicantDisabled = false;
        this.applicantAddress = {};
        this.applicantName = '';
        this.applicantCurrency = '';
        this.applicantClassification = 'Applicant';
        this.applicantEntitySize = '';
        this.showApplicantPopup = true;
        this.stateOptions = [];
        this.applicantError = '';
        this.isButtonDisabled = false;
    }

    //ApplicantEdit
    handleRowApplicant(event) {

        let selectedRowApplicant = event.detail.row;
        this.showApplicantEdit = true;
        this.isButtonDisabled = false;
        this.rowApplicantClient = selectedRowApplicant.key;
        this.rowApplicantRegisteredApplicant = selectedRowApplicant.registeredApplicant;
        let currentApplicant = event.detail.row;
        if (currentApplicant.addressEdit != null || currentApplicant.addressedit && this.addressDependentPicklist[currentApplicant.addressedit.country]) {
            // let currentCountry=this.addressDependentPicklist.filter(row=>row.addressEdit.country)[0];
            console.log('current country', currentApplicant.addressedit.country);
            this.setStateOptions(currentApplicant.addressedit.country);
        } else {
            this.stateOptions = [];
        }

        this.rowApplicantAddress = selectedRowApplicant.addressedit;
        this.rowApplicantAddress.province = selectedRowApplicant.addressedit != undefined ? selectedRowApplicant.addressedit.stateCode : '';


        this.editRowApplicant = selectedRowApplicant.key;


        console.log(event)
        console.log('Handle Row Applicant Called');
        console.log(JSON.stringify(event.detail));

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

    handleAddJurisdiction() {
        this.showJurisdictionCmp = true;
        this.jurisdictionCmpList = [];
        this.jurisdictionCmpError = '';
    }

    handleRowJurisdiction(event) {
        this.isDocketError = false;
        this.jurisdictionPopupError = '';
        let selectedRow = event.detail.row;
        console.log('selected row-' + JSON.stringify(selectedRow));
        switch (event.detail.action.name) {
            case 'edit':
                // this.removedInventors = [];
                this.editId = selectedRow.uniqueId;
                this.showJurisdictionPopup = true;
                this.finalSelectedPriorities = [];
                this.preselectedIds = [];
                this.jurisdictionOptions = [];
                this.caseTypeValue = selectedRow.caseTypeValue;
                this.assetType = selectedRow.assetType == '' ? 'Patent' : selectedRow.assetType;
                this.engagementDetailsPatent = selectedRow.engagementDetailsPatent;
                this.jurisdictionId = selectedRow.jurisdictionId;
                this.jurisdictionName = selectedRow.jurisdictionName;
                // this.foreignAssociateId = selectedRow.foreignAssociateId;
                // this.foreignAssociateName = selectedRow.foreignAssociateName;
                this.inventorsTable = selectedRow.selectedInventors;
                this.keywordTable = selectedRow.selectedkeywords;
                this.applicantsTable = selectedRow.selectedApplicants;
                this.businessCategoriesTable = selectedRow.selectedBusinessInfos;
                this.patOrProsecutionDN = '';
                this.IPRdocketReq = '';
                this.OppDocketReq = '';
                this.litigationDocketReq = '';
                this.clientAccessToFileDocket = '';
                this.responsibleForAnnuities = '';
                this.clientOnAnnuityPolicy = '';
                this.clientRefNo = selectedRow.clientRefNo;
                this.docketActivities = selectedRow.docketActivities;
                // LFP-655 -> Start Bug fix by Aman
                if ('renewalsAnnuities' in selectedRow) {
                    this.renewalsAnnuities = selectedRow.renewalsAnnuities;
                } else {
                    this.renewalsAnnuities = true;
                }
                // LFP-655 -> End
                jurisdictionBasedCaseType({ IPMatter: this.assetType, jurisdictionIds: this.jurisdictionId })
                    .then(result => {
                        console.log('resultjurisdiction ', result);
                        console.log('length', result.length);
                        let caseTypeOptions = result[0].AllowedCaseTypes[0].split(';');
                        caseTypeOptions = JSON.parse(JSON.stringify(caseTypeOptions));
                        for (let val of caseTypeOptions) {
                            this.jurisdictionOptions.push({
                                'label': val,
                                'value': val
                            })
                        }
                        this.jurisdictionOptions = JSON.parse(JSON.stringify(this.jurisdictionOptions));
                        console.log('this.jurisdictionOptions ', this.jurisdictionOptions);
                    })
                    .catch(error => {
                        console.error('Error in caseTypes');
                        console.log('ERROR', JSON.stringify(error));
                    });
                checkRenewalsAnnuitiess({ clientID: this.clientId })
                    .then(result => {
                        console.log('result checkRenewalsAnnuitiess-->', result);
                        if (result == true) {
                            this.isDisabled = true;
                        }
                        if (result == false) {
                            this.isDisabled = false;
                        }
                    })
                //TODO:
                // this.billingParty = this.clientId;
                // this.selectedInventors = (selectedRow.selectedInventors != null && selectedRow.selectedInventors.length > 0) ? selectedRow.selectedInventors : this.selectedInventors;
                console.log('this.selectedInventor', this.selectedInventors);
                console.log('this.this.engagementDetailsPatent', this.engagementDetailsPatent);
                // this.selectedApplicants = (selectedRow.selectedApplicants != null && selectedRow.selectedApplicants.length > 0) ? selectedRow.selectedApplicants : this.selectedApplicants;
                console.log('this.selectedApplicants', this.selectedApplicants);
                this.finalSelectedPriorities = (selectedRow.selectedPriorities != null && selectedRow.selectedPriorities.length > 0) ? selectedRow.selectedPriorities : this.finalSelectedPriorities;
                this.selectedInventorsJurisdiction = selectedRow.selectedInventors;
                this.selectedkeywordJurisdiction = selectedRow.selectedkeywords;
                this.selectedApplicantsJurisdiction = selectedRow.selectedApplicants;
                this.selectedBusiCategoryJurisdiction = selectedRow.selectedBusinessInfos;
                break;
            case 'delete':
                this.jurisdictionList = this.jurisdictionList.filter(row => row.uniqueId != selectedRow.uniqueId);
                console.log('deleted', this.jurisdictionList);
                break;
            default:
                console.log('default');
        }
    }

    cancelButton() {
        this.showConfirmationDialog = true;
        this.confirmationTitle = 'Cancel';
        this.confirmationMessage = 'Are you sure you want to cancel?';
    }

    validateInventorList() {

        const keyCount = {};
        let primaryCount = 0;

        for (const item of this.selectedInventors) {
            // Count occurrences of each key
            keyCount[item.key] = (keyCount[item.key] || 0) + 1;

            // Count primary true items
            if (item.primary) {
                primaryCount++;
                // Early exit if multiple primaries are found
                if (primaryCount > 1) {
                    return true; // Multiple primaries found
                }
            }

            // Early exit if duplicate keys are found
            if (keyCount[item.key] > 1) {
                return true; // Duplicate key found
            }
        }

        // If no issues found
        return false;

    }

    validateInventorSequence() {
        const errors = [];
        const sequenceSet = new Set(); // To track unique sequences
        const totalSelected = this.selectedInventors.length;

        // Iterate over each inventor to perform validations
        this.selectedInventors.forEach(item => {
            if (item.hasOwnProperty('sequence') && item.sequence != null) {
                const sequenceAsInteger = parseInt(item.sequence, 10); // Ensure sequence is an integer

                // Check if sequence is less than 1
                if (sequenceAsInteger < 0) {
                    errors.push(`Sequence No for '${item.label}' must be greater than 0.`);
                }

                // Check if sequence exceeds total selected inventors
                if (sequenceAsInteger > totalSelected) {
                    errors.push(`Sequence No for '${item.label}' must be less than or equal to the total size of selected Inventors i.e [${totalSelected}].`);
                }

                // Check for duplicate sequences
                if (sequenceSet.has(sequenceAsInteger)) {
                    errors.push(`Duplicate sequence found: ${sequenceAsInteger} for inventor '${item.label}'.`);
                } else {
                    sequenceSet.add(sequenceAsInteger);
                }

                // Check if primary inventor has sequence of 1
                if ((item.primary && sequenceAsInteger !== 1)) {
                    errors.push(`Primary inventor '${item.label}' must have a sequence of 1.`);
                }

                if ((item.primary == false && sequenceAsInteger == 1)) {
                    errors.push(`Sequence 1 is reserved for Primary inventor. Please either mark '${item.label}' as primary or give any other sequence no.`);
                }
            }

        });

        // Return errors as a single string or an empty string if there are no errors
        return errors.length > 0 ? errors.join('\n') : '';
    }

    validateOnSubmit() {
        let validationPass = true;
        this.isInventorError = this.validateInventorList();
        if (this.sequenceError == '') {
            this.sequenceError = this.validateInventorSequence();
        }
        console.log('inventorValidation ' + this.isInventorError);

        this.patentFamilyError = (this.mainRadioValue == 'An Existing Patent Family' && this.patentFamilyId == '') ? 'Please select any one patent family.' : '';
        let nullInJurisdictionList = false;
        this.engagementDetailsPF = [... this.engagementDetailsPF.map((item, i) => {
            if (item.label == 'Originating Attorney' && item.personId == '') {
                return { ...item, errorClass: 'slds-has-error', errorMessage: 'Complete this Field.' };
            } else {
                return item;
            }
        }
        )];
        console.log(JSON.stringify(this.engagementDetailsPF));
        console.log(this.patentFamilyError);
        console.log(JSON.stringify(this.jurisdictionList));


        for (let item of this.jurisdictionList) {
            if (
                (item.caseTypeValue == '' || item.caseTypeValue == undefined)
                || (item.assetType == '' || item.assetType == undefined)
                || (item.responsiblePartnerName == '' || item.responsiblePartnerName == undefined)   //Removed by Jagadeeswar
            ) {
                nullInJurisdictionList = true;
                this.jurisdictionPopupError = 'Fill up the required fields for all the selected jurisdictions.';
                break;
            }
        }
        let originatingAttorneyPF = this.engagementDetailsPF.find(ele => ele.label === 'Originating Attorney')?.personId || '';

        if (this.clientId == '' || (this.mainRadioValue == 'An Existing Patent Family' && this.patentFamilyId == '') || (this.mainRadioValue == 'New Patent Family' && (this.shortTitle.trim() == '' || this.inventionTitle.trim() == '' || originatingAttorneyPF == '')) || this.selectedInventors.length == 0 ||
            this.jurisdictionList.length == 0 || nullInJurisdictionList || this.isInventorError || this.sequenceError != '') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Information',
                message: 'Fill all the mandatory fields in the form',
                variant: 'error'
            }));
            validationPass = false;

        }
        if (validationPass) {
            this.confirmationTitle = 'Patent Application Intake Form Submission';
            this.confirmationMessage = 'Are you sure you want to submit?';
            this.showConfirmationDialog = true;
        }
        else {
            this.setErrorMessage();
        }
    }

    closePopup() {
        this.showInventorPopup = false;
        this.showApplicantEdit = false;
        this.showApplicantPopup = false;
        this.showJurisdictionPopup = false;
        this.showPriorityTable = false;
        this.jurisdictionSearchValue = '';
        //this.clientReferenceSearchValue='';
        this.heReferenceSearchValue = '';
        this.filingNumberSearchValue = '';
        this.showJurisdictionCmp = false;
        this.caseTypeValue = '';
        this.assetType = 'Patent';
    }

    handlePersonName(event) {
        this.personName = event.target.value;
        // this.personNameError = this.personName == '' ? 'Complete this field.' : '';
        // this.personNameErrorClass = this.personName == '' ? 'slds-has-error' : '';
    }

    handleUser(event) {
        this.user = event.target.value;
        console.log('user', this.user);
    }

    handleNationality(event) {
        this.nationality = event.target.value;
        console.log('nationality', this.nationality);

    }

    emailAddressError = '';
    handleEmailAddress(event) {
        this.emailAddress = event.target.value;
        console.log('this.emailAddress', this.emailAddress);
    }

    handlePhone(event) {
        this.phone = event.target.value;
        console.log('Phone', this.phone);
    }

    handleInventorAddress(event) {
        console.log('inside address', event.detail);

        let inventorAdd = {};
        inventorAdd.street = event.detail.street;
        console.log('street');
        inventorAdd.postalCode = event.detail.postalCode;
        inventorAdd.city = event.detail.city;
        inventorAdd.country = event.detail.country;
        inventorAdd.state = event.detail.province;
        this.inventorAddress = inventorAdd;
        console.log('inventorAddress', this.inventorAddress);

        if (Object.keys(this.addressDependentPicklist).includes(event.detail.country)) {
            let code = event.detail.country;
            console.log('states', this.addressDependentPicklist[code]);
            this.setStateOptions(code);
            this.inventorStateOptions = this.stateOptions;
        }
        else {
            this.stateOptions = [];
        }

    }

    handleInventortype(event) {
        this.Inventortype = event.target.value;
        console.log('Inventortype', this.Inventortype);
    }

    handleContactType(event) {
        this.contactType = event.target.value;
        console.log('tcontactType', this.contactType);
    }

    createInventor() {

        console.log('Before if');
        if (this.emailAddress) {
            const emailRegex = /^[a-zA-Z][^\s@]*@[^\s@]+\.[^\s@].[^\s@]+$/;
            if (!emailRegex.test(this.emailAddress)) {
                this.emailAddressError = 'Please enter a valid email address.';
            }
            else {
                this.emailAddressError = '';
            }
        }
        if (this.personName != '' && this.emailAddressError == '') {
            this.isButtonDisabled = true;
            let inventorList = [];
            let newInventor = {};
            newInventor.clientId = this.clientId;
            newInventor.email = this.emailAddress;
            newInventor.contactType = 'Inventor';
            newInventor.recordTypeId = this.personRecordTypeId;
            newInventor.Type = 'Client';
            newInventor.user = this.user ? this.user : null;
            newInventor.personName = this.personName;
            newInventor.nationality = this.nationality ? this.nationality : null;
            newInventor.phone = this.phone ? this.phone : null;
            newInventor.inventorAddress = this.inventorAddress ? this.inventorAddress : null;
            newInventor.assistant = this.assistant ? this.assistant : null;
            newInventor.extension = this.extension ? this.extension : null;
            newInventor.mobilePhone = this.mobilePhone ? this.mobilePhone : null;
            newInventor.linkVcard = this.linkToCard ? this.linkToCard : null;
            newInventor.linkToProfile = this.linkToProfile ? this.linkToProfile : null;
            inventorList.push(newInventor);
            console.log('inventorList', JSON.stringify(inventorList));
            createPersons({ person: JSON.stringify(inventorList) }).then(result => {
                console.log('result person', JSON.stringify(result));
                if (result.PatentFamilyID != '' && result.Status == true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Inventor Created successfully',
                            variant: 'success'
                        })
                    );
                    let inventor = {};
                    if (this.emailAddress != '') {
                        inventor.label = this.personName + ' - ' + this.emailAddress;
                    } else {
                        inventor.label = this.personName;
                    }
                    inventor.value = this.personName;
                    inventor.personName = this.personName;
                    inventor.key = result.PatentFamilyID;
                    inventor.email = this.emailAddress;
                    inventor.address = (this.inventorAddress != null || this.inventorAddress != {}) ? this.addressToString(this.inventorAddress) : null;
                    inventor.user = this.user;
                    inventor.nationality = this.nationality;
                    inventor.phone = this.phone;
                    inventor.asistant = this.assistant;
                    inventor.linkToCard = this.linkToCard;
                    inventor.linkToProfile = this.linkToProfile;
                    inventor.mobilePhone = this.mobilePhone;
                    inventor.extension = this.extension;
                    inventor.client = this.clientId;
                    //inventor.isVisible=true;
                    //this.template.querySelector('.inventor').reset();
                    this.inventors.push(inventor);
                    this.selectedInventors.push(inventor);
                    this.selectedInventors = [...this.selectedInventors];
                    this.inventorsTable = [...this.selectedInventors];
                    this.inventors = [...this.inventors, ...this.selectedInventors];
                    // const ids = this.inventors.map(({ email }) => email);
                    // this.inventors = this.inventors.filter(({ email }, index) =>
                    //     !ids.includes(email, index + 1));
                    const uniqueIds = this.inventors.map(({ email, personName }) => `${email}-${personName}`);
                    this.inventors = this.inventors.filter(({ email, personName }, index) =>
                        uniqueIds.indexOf(`${email}-${personName}`) === index
                    );
                    this.showInventorPopup = false;
                    this.selectedInventors = this.selectedInventors.map(({ selected, ...rest }) => rest);
                    this.inventors = this.inventors.map(({ selected, ...rest }) => rest);
                    this.template.querySelector(".inventor").setValues(this.inventors, this.selectedInventors);
                    this.selectedInventors = [...this.selectedInventors];
                    this.inventors = [...this.inventors];
                    if (this.jurisdictionList.length > 0) {
                        this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                            let obj = { ...ele };
                            obj.selectedInventors.push(inventor);
                            return obj;
                        })]
                    }
                }
                this.isButtonDisabled = false;
                if (result.Status == false) {
                    this.isButtonDisabled = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            // message: 'Email ID already exists. Create with a different Email ID',
                            message: 'Error in creating Inventor',
                            variant: 'error'
                        })
                    );
                }
            })
                .catch(error => {
                    // Handle error
                    //  console.error('Error creating record: ' + error.body.message);
                    console.log(JSON.stringify(error));

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error in creating Inventor',
                            variant: 'error'
                        })
                    );
                });
        } else if (this.personName == '') {
            this.template.querySelector('.PersonNameInventor').reportValidity();
            // this.template.querySelector('.EmailInventor').reportValidity();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Fill Required Fields!',
                    variant: 'error'
                })
            );
        }
        this.inventors = [...this.inventors];
        this.selectedInventors = [...this.selectedInventors];
        this.inventorsTable = [...this.selectedInventors];
        this.inventorTableHeight = this.selectedInventors.length > 7 ? 'height:300px' : '';
        console.log('last line of functions');
    }

    handleApplicantNameChange(event) {

        this.applicantName = event.target.value;
        this.template.querySelector('.clientName').reportValidity();

    }

    handleApplicantCurrencyChange(event) {
        this.applicantCurrency = event.target.value;
    }

    handleApplicantEntityChange(event) {
        this.applicantEntitySize = event.target.value;
    }

    handleApplicantClassificationChange(event) {
        this.applicantClassification = event.target.value;
        this.applicantError = this.applicantClassification.includes('Applicant') ? '' : 'Applicant Should Be Mandatory';
        console.log('applicantClassification', this.applicantClassification);
    }

    handleApplicantAddressChange(event) {
        let address = {};
        address.street = event.detail.street;
        address.postalCode = event.detail.postalCode;
        address.city = event.detail.city;
        address.country = event.detail.country;
        address.state = event.detail.province;
        this.applicantAddress = address;

        if (Object.keys(this.addressDependentPicklist).includes(event.detail.country)) {
            let code = event.detail.country;
            console.log('states', this.addressDependentPicklist[code]);
            this.setStateOptions(code);

        }
        else {
            this.stateOptions = [];
        }


    }

    createApplicant(event) {
        console.log('save button clicked');

        console.log(JSON.stringify(event.target));
        console.log(event.detail.fields);
        let clients = [];
        let client = {};
        client.name = this.applicantName;
        client.classification = this.applicantClassification;
        client.entitySize = this.applicantEntitySize;
        client.defaultCurrency = this.applicantCurrency;
        client.address = this.applicantAddress;
        clients.push(client);

        console.log(JSON.stringify(clients));

        if (this.applicantError == '' && this.applicantName != '' && this.applicantClassification != '' && this.applicantEntitySize != '' && this.applicantCurrency != '') {
            this.applicantError = '';
            this.isButtonDisabled = true;
            createClients({ client: JSON.stringify(clients), existingClientId: this.clientId }).then(result => {
                if (result && result != '') {
                    if (result.Status) {
                        let newApplicant = {};
                        newApplicant.key = result.PatentFamilyID;
                        newApplicant.label = this.applicantName;
                        newApplicant.value = this.applicantName;
                        newApplicant.registeredApplicant = this.applicantName;
                        newApplicant.address = (this.applicantAddress != null || this.applicantAddress != {}) ? this.addressToString(this.applicantAddress) : null;
                        newApplicant.addressedit = this.applicantAddress;
                        newApplicant.isVisible = true;
                        // newApplicant.selected=true;
                        this.template.querySelector('.applicant').reset();
                        console.log('SELECTED APPLICANT AFTER RESET ', JSON.stringify(this.selectedApplicants));
                        this.selectedApplicants.push(newApplicant);
                        this.selectedApplicants = [...this.selectedApplicants];
                        this.showApplicantPopup = false;

                        this.applicants.push(newApplicant);
                        let selectedonesKey = []
                        this.selectedApplicants.forEach(row => {
                            if (row.key != undefined) {
                                selectedonesKey.push(row.key);
                            }
                        });
                        console.log('SelectedKEys', selectedonesKey);
                        this.applicants.forEach(row => {
                            if (!selectedonesKey.includes(row.key)) {
                                row.selected = false;
                                console.log(row);
                            }


                        });

                        this.template.querySelector(".applicant").setValues(this.applicants, this.selectedApplicants);
                        if (this.jurisdictionList.length > 0) {
                            this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                                let obj = { ...ele };
                                obj.selectedApplicants.push(newApplicant);
                                return obj;
                            })]
                        }
                    }
                }

                console.log(JSON.stringify(result));
            }).catch(error => {
                // Handle error
                console.error('Error creating record: ' + error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error in creating Applicant',
                        variant: 'error'
                    })
                );
            });
        } else {
            this.template.querySelector('.clientName').reportValidity();
            this.template.querySelector('.classfication').reportValidity();
            this.template.querySelector('.entitySize').reportValidity();
            this.template.querySelector('.billingCurrency').reportValidity();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Fill Required Fields!',
                    variant: 'error'
                })
            );
        }


        console.log(JSON.stringify(this.applicantName));
        console.log(JSON.stringify(this.applicantError));
        console.log(JSON.stringify(this.applicantClassification));
        console.log(JSON.stringify(this.applicantAddress));
        console.log(JSON.stringify(this.applicantEntitySize));
        console.log(JSON.stringify(this.applicantCurrency));
    }

    handleRowApplicantChange(event) {

        console.log(JSON.stringify(event.target.value));
        this.rowApplicantRegisteredApplicant = event.target.value;

    }

    addressInputChange(event) {
        let addressEdited = event.detail;
        console.log(JSON.stringify(addressEdited));

        this.rowApplicantAddress.street = addressEdited.street != undefined ? addressEdited.street : '';
        this.rowApplicantAddress.city = addressEdited.city != undefined ? addressEdited.city : '';
        this.rowApplicantAddress.country = addressEdited.country != undefined ? addressEdited.country : '';
        this.rowApplicantAddress.state = addressEdited.province != undefined ? addressEdited.province : '';
        this.rowApplicantAddress.postalCode = addressEdited.postalCode != undefined ? addressEdited.postalCode : '';
        if (Object.keys(this.addressDependentPicklist).includes(event.detail.country)) {
            let code = event.detail.country;
            this.setStateOptions(code);

        }
        else {
            this.stateOptions = [];
        }

    }

    handleApplicantEdit() {
        this.selectedApplicants.forEach(row => {
            console.log(JSON.stringify(row));
            console.log(JSON.stringify(this.rowApplicantRegisteredApplicant));
            if (this.rowApplicantRegisteredApplicant != '') {
                if (row.key == this.editRowApplicant) {

                    row.registeredApplicant = this.rowApplicantRegisteredApplicant;
                    row.address = this.addressToString(this.rowApplicantAddress);
                    console.log('ROW' + JSON.stringify(row));
                }
                this.showApplicantEdit = false;
            }
            console.log(JSON.stringify(this.rowApplicantRegisteredApplicant));
        });
        this.selectedApplicants = [...this.selectedApplicants];

    }

    closeJurisdictionCmpPopup() {
        this.jurisdictionCmpList = [];
        this.showJurisdictionCmp = false;
    }

    handleSelectedJurisdictionGroup(event) {
        this.jurisdictionCmpList = event.detail.selectedJurisdictions;
        console.log('jurisdictionList-' + JSON.stringify(this.jurisdictionList));
        this.jurisdictionCmpError = this.jurisdictionCmpList != null && this.jurisdictionCmpList.length > 0 ? '' : 'At least one jurisdiction is required.';

        this.jurisdictionTableHeight = this.jurisdictionList.length > 7 ? 'height:300px' : '';
    }

    async addJurisdictions() {
        try {
            // this.showSpinner = true;
            this.showJurisdictionCmp = false;
            this.showRecordCreationSpinner = true;
            this.spinnerMessage = 'Jurisdiction Application configuring in progress...';
            let count = 1;
            console.log(' *** ' + JSON.stringify([...DOCKET_ACTIVITIES].map(ele => { let obj = { ...ele, docketError: '' }; return obj })));

            let json = JSON.stringify(this.jurisdictionCmpList);
            console.log('jurisdictionCmpList-' + json);
            this.jurisdictionCmpError = this.jurisdictionCmpList != null && this.jurisdictionCmpList.length > 0 ? '' : 'At least one jurisdiction is required.';
            if (this.jurisdictionCmpList != null && this.jurisdictionCmpList.length > 0) {

                for (const row of this.jurisdictionCmpList) {
                    let randomNumber = parseInt(Math.random() * 100000000).toString();
                    row.uniqueId = 'AD' + row.jurisdictionId + (new Date().getDate()) + (new Date().getMonth()) + (new Date().getFullYear()) + (new Date().getTime()) + randomNumber,
                    row.selectedInventors = this.selectedInventors;
                    row.selectedkeywords = this.selectedkeywords;
                    row.selectedApplicants = this.selectedApplicants;
                    row.selectedBusinessInfos = this.selectedBusinessInfos;
                    row.docketActivities = [...DOCKET_ACTIVITIES].map(ele => { let obj = { ...ele, docketError: '' }; return obj });
                    row.caseTypeValue = '';
                    row.assetType = '';
                    row.clientRefNo = this.clientRefNoDefault;



                    if (this.mainRadioValue == 'New Patent Family') {

                        this.engagementDetailsPatent = this.engagementDetailsPF;
                        // get from engagementPF list outer, if not there, query cem for that juridiction Responsible (billing) Attorney - Responsible Attorney,Originating Attorney - Responsible Partner

                    } else {
                        // existing pF family - get MEM records, if not there then query cem records for that juridiciton
                        const res = await getMEMpatentFamilyDetails({ patentFamilyId: this.patentFamilyId })
                        if (res != null) {
                            this.engagementDetailsPatent = res;
                            this.engagementDetailsPF = res.map(ele => { return { ...ele, isAlreadyCreated: true } }); // to store existing patent family MEM
                            console.log(JSON.stringify(this.engagementDetailsPatent) + ' -----------3333333 res');
                        }

                        // For Existing PF, also need to update the engagement Details if all jurisdiction is coming up
                        //  this.handleEngagementDetails();
                        if (this.engagementDetailsPF.length != 0 && this.engagementDetailsPF.some(ele => ele.personId == '')) {
                            const res2 = await getClientCEMdetails({ clientId: this.clientId, moduleName: 'Patent', allJurisdiction: true, jurisdictionId: '' });
                            if (res2 != null) {

                                this.engagementDetailsPF = [...this.engagementDetailsPF.map(item => {
                                    if (item.personId == '') {

                                        const foundElement = res2.find(ele => (ele.label).toLowerCase() === (item.label).toLowerCase());
                                        if (foundElement != undefined && foundElement != null) {
                                            return { ...foundElement, isAlreadyCreated: false };
                                        } else {
                                            return { ...item, isAlreadyCreated: false };
                                        }
                                    } else {
                                        return item;
                                    }
                                })];
                                console.log(JSON.stringify(this.engagementDetailsPF) + ' ----------11--2222 res');
                            }
                        }
                        if (this.engagementDetailsPatent.length != 0 && this.engagementDetailsPatent.some(ele => ele.personId == '')) {
                            const allJurisdictionCEMResults = await getClientCEMdetails({ clientId: this.clientId, moduleName: 'Patent', allJurisdiction: true, jurisdictionId: '' });
                            if (allJurisdictionCEMResults != null) {

                                this.engagementDetailsPatent = [...this.engagementDetailsPatent.map(item => {
                                    if (item.personId == '') {

                                        const foundElement = allJurisdictionCEMResults.find(ele => (ele.label).toLowerCase() === (item.label).toLowerCase());
                                        return foundElement !== undefined && foundElement !== null ? foundElement : item;
                                    } else {
                                        return item;
                                    }
                                })];
                                console.log(JSON.stringify(this.engagementDetailsPatent) + ' ----------11-engagementDetailsPatent-2222 res');
                            }
                        }
                    }
                    if (this.engagementDetailsPatent.length != 0 && this.engagementDetailsPatent.some(ele => ele.personId == '')) {
                        console.log('yes');

                        const res1 = await getClientCEMdetails({ clientId: this.clientId, moduleName: 'Patent', allJurisdiction: false, jurisdictionId: row.jurisdictionId });
                        if (res1 != null) {

                            this.engagementDetailsPatent = [...this.engagementDetailsPatent.map(item => {
                                if (item.personId == '') {

                                    const foundElement = res1.find(ele => (ele.label).toLowerCase() === (item.label).toLowerCase());
                                    return foundElement !== undefined && foundElement !== null ? foundElement : item;
                                } else {
                                    return item;
                                }
                            })];
                            console.log(JSON.stringify(this.engagementDetailsPatent) + ' -----------2222 res');
                        }
                    }
                    row.engagementDetailsPatent = this.engagementDetailsPatent;
                    row.responsiblePartnerName = this.engagementDetailsPatent.find(ele => ele.label === 'Originating Attorney')?.personName || '';
                    row.responsibleAttorneyName = this.engagementDetailsPatent.find(ele => ele.label === 'Responsible (Billing) Attorney')?.personName || '';
                    row.foreignAssociateName = this.engagementDetailsPatent.find(ele => ele.label === 'Foreign Associate')?.personName || '';
                    console.log(JSON.stringify(this.engagementDetailsPatent) + ' -----------111 res');
                    console.log(JSON.stringify(row.engagementDetailsPatent) + ' -----------111 cccccccccccres');

                }
                this.jurisdictionCmpList = [...this.jurisdictionCmpList];
                if (this.jurisdictionList != null && this.jurisdictionList.length > 0) {
                    this.jurisdictionList = [...this.jurisdictionList, ...this.jurisdictionCmpList];
                }
                else {
                    this.jurisdictionList = [...this.jurisdictionCmpList];
                }
                this.jurisdictionList = [...this.jurisdictionList];
                console.log('addJurisdictions-2-' + JSON.stringify(this.jurisdictionList));
                this.jurisdictionError = this.jurisdictionList != null && this.jurisdictionList.length > 0 ? '' : 'At least one jurisdiction is required.';

                this.showJurisdictionCmp = false;
            }
        } catch (err) {

            console.log('OUTPUT : err ', err.message);
        } finally {
            this.showRecordCreationSpinner = false;
        }



    }

    handleCaseType(event) {
        this.caseTypeValue = event.target.value;
        //this.casetypeError=(this.caseTypeValue == ''|| this.caseTypeValue ==undefined) ? 'Complete the field.':'';
        //this.template.querySelector('.caseType').reportValidity();
    }

    handleAssetType(event) {
        this.assetType = event.target.value;
        // this.assetTypeError = this.assetType == '' ? 'Complete the field.' : '';
        this.template.querySelector('.assetType').reportValidity();
    }

    handleChange(event) {
        const field = event.currentTarget.dataset.field;
        const value = event.target.value;
        if (field == 'Pat_or_prosecution_docketing_needed__c') {
            this.patOrProsecutionDN = value;
        } else if (field == 'IPR_docketing_required__c') {
            this.IPRdocketReq = value;
        } else if (field == 'opposition_docketing_required__c') {
            this.OppDocketReq = value;
        } else if (field == 'Litigation_docketing_required__c') {
            this.litigationDocketReq = value;
        } else if (field == 'Will_client_access_their_files_on_docket__c') {
            this.clientAccessToFileDocket = value;
        } else if (field == 'Is_MCC_responsible_for_annuities__c') {
            this.responsibleForAnnuities = value;
        } else if (field == 'Did_you_advise_Client_on_Annuity_Policy__c') {
            this.clientOnAnnuityPolicy = value;
        } else if (field == 'clientRefNo') {
            this.clientRefNo = value;
        }
        
    }

    handleEngagementChangePF(event) {
        const type = event.currentTarget.dataset.type;
        const name = event.detail.length > 0 ? event.detail[0].Name : '';
        const index = event.currentTarget.dataset.index;
        const value = event.detail.length > 0 ? event.detail[0].Id : '';
        // console.log(' 11111111 ' + JSON.stringify(this.engagementDetailsPF));
        this.engagementDetailsPF = [... this.engagementDetailsPF.map((item, i) => {
            if (i == index && item.type == type) {
                return { ...item, personId: value, personName: name, errorClass: '', errorMessage: '' };
            } else {
                return item;
            }
        }
        )];

    }

    handleEngagementChangePatent(event) {
        const type = event.currentTarget.dataset.type;
        const name = event.detail.length > 0 ? event.detail[0].Name : '';
        const index = event.currentTarget.dataset.index;
        const value = event.detail.length > 0 ? event.detail[0].Id : '';
        console.log(' 11111111 ' + JSON.stringify(this.engagementDetailsPatent));
        this.engagementDetailsPatent = [... this.engagementDetailsPatent.map((item, i) => {
            if (i == index && item.type == type) {
                return { ...item, personId: value, personName: name, errorClass: '', errorMessage: '' };
            } else {
                return item;
            }
        }
        )];

    }

    handleRenewalsAnnuities(event) {
        this.renewalsAnnuities = event.target.checked;
        //console.log('renewalsAnnuities' + event.target.checked);
    }

    handleDocketActivityChange(event) {
        const field = event.currentTarget.dataset.field;
        const index = event.currentTarget.dataset.index;
        const value = event.detail.length > 0 ? event.detail[0].Id : event.target.value;
        console.log(' 11111111 ' + JSON.stringify(this.engagementDetailsPF));
        this.docketActivities = [... this.docketActivities.map((item, i) => {
            if (i == index) {
                let temp = { ...item };
                temp[field] = (value != null ? value : '');
                if (field == 'eventName' && temp['eventDate'] == '' && value != '') {
                    let todayDate = new Date();
                    temp['eventDate'] = todayDate.getFullYear() + '-' + (todayDate.getMonth() + 1) + '-' + todayDate.getDate();
                }
                return { ...temp };

            } else {
                return item;
            }
        }
        )];
        console.log('DOCKET ACTIVITES ' + JSON.stringify(this.docketActivities));

    }

    removeInventor(event) {

        let selectedRow = event.detail.row;
        let selectedJurisdiction = this.jurisdictionList.findIndex(row => row.uniqueId == this.editId);
        let selectedInventorTable = this.jurisdictionList[selectedJurisdiction].selectedInventors;
        selectedInventorTable = selectedInventorTable.filter(row => row.key != selectedRow.key);
        console.log('removed inventor', JSON.stringify(selectedInventorTable.filter(row => row.key != selectedRow.key)));
        if (selectedInventorTable == null) {
            selectedInventorTable = [];
        }
        this.jurisdictionList[selectedJurisdiction].selectedInventors = [...selectedInventorTable];
        this.inventorsTable = [...selectedInventorTable];
        this.selectedInventorsJurisdiction = [...selectedInventorTable];
        this.inventorActionHeight = this.inventorsTable.length > 7 ? 'height:300px' : '';
    }

    handleExistingPriority() {
        this.openExistingPriorityPopup = true;
        this.showPriorityTable = false;
        this.jurisdictionSearchValue = '';
        //this.clientReferenceSearchValue='';
        this.heReferenceSearchValue = '';
        this.filingNumberSearchValue = '';
        this.nullPriorityRecordMessage = '';
        this.existingPriorityCmpError = '';
        this.existingPriorityAddError = '';
        this.selectedPriorities = [];
    }

    handleNewPriority() {
        this.openNewPriorityPopup = true;
        this.selectedPriorities = [];
        this.preselectedIds = [];
        this.priorityCaseType = '';
        this.priorityJurisdictionId = '';
        this.priorityJurisdictionName = '';
        this.inventionTitlePriority = '';
        this.shortTitlePriority = '';
        // this.clientReferencePriority='';
        this.applicationNumber = '';
        this.applicationDate = null;
        //this.portfolioManagement='';
        // this.priorityCasetypeError = '';
        // this.priorityCasetypeErrorClass = '';
        this.priorityJurisdictionError = '';
        this.priorityJurisdictionErrorClass = '';
        this.priorityShortTitleError = '';
        this.priorityShortTitleErrorClass = '';
        this.priorityInventionTitleError = '';
        this.priorityInventionTitleErrorClass = '';
        this.priorityApplicationNumberError = '';
        this.priorityApplicationNumberErrorClass = '';
        this.priorityApplicationDateError = '';
        this.priorityApplicationDateErrorClass = '';
        // this.priorityPortFolioError = '';
        // this.priorityPortFolioErrorClass = '';
        this.nullPriorityRecordMessage = '';
        this.pantentFamilypriorityNewErrorClass = '';
        this.patentFamilypriorityError = '';
        this.prioritypatentFamilyId = '';
        this.priorityAssetType = 'Patent';
    }


    removePriority(event) {
        let selectedRow = event.detail.row;
        this.finalSelectedPriorities = this.finalSelectedPriorities.filter(row => row.uniqueId != selectedRow.uniqueId);
        this.preselectedIds = [];
        this.finalPriorityHeight = this.finalSelectedPriorities.length > 7 ? 'height:300px' : '';
    }

    addJurisdictionDetails() {
        try {

            this.isDocketError = false;
            let orginatingAttorney = this.engagementDetailsPatent.find(ele => (ele.label === 'Originating Attorney')?.personId || '');
            this.docketActivities.some(ele => {
                if (ele.eventName != '' && ele.eventDate != '' && ele.dueDate != '' && (ele.assignToUser != '' || ele.assignToTeam != '')) {
                    this.isDocketError = false;
                    return true; // stop iteration
                } else {
                    this.isDocketError = true;
                    return false;
                }

            })
            if (!this.isDocketError) {
                this.docketActivities = [... this.docketActivities.map(ele => {

                    if ((ele.eventName != '' || ele.eventDate != '' || ele.dueDate != '' || ele.assignToUser != '' || ele.assignToTeam != '') &&
                        (ele.eventName == '' || ele.eventDate == '' || ele.dueDate == '' || (ele.assignToUser == '' && ele.assignToTeam == ''))) {
                        ele.docketError = 'Please Either Fill all Details for ' + ele.type + ' Docket Event including Assign to Either User or Team otherwise Empty all details.';
                    } else {
                        ele.docketError = '';
                    }

                    return ele;
                })]
            }
            this.docketError = this.docketActivities.some(ele => {
                if (ele.docketError != '') {
                    return true;
                } else {
                    return false;
                }

            });
            console.log('this docketError ' + this.docketError);

            if (this.docketError || this.caseTypeValue == '' || orginatingAttorney == '' || this.assetType == '' || this.isDocketError) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Information',
                    message: 'Fill all the mandatory fields in the form',
                    variant: 'error'
                }));

            }
            console.log('inside update');
            this.engagementDetailsPatent = [... this.engagementDetailsPatent.map((item, i) => {
                if (item.label == 'Originating Attorney' && item.personId == '') {
                    return { ...item, errorClass: 'slds-has-error', errorMessage: 'Complete this Field.' };
                } else {
                    return item;
                }
            }
            )];

            this.template.querySelector('.caseType').reportValidity();
            this.template.querySelector('.assetType').reportValidity();
            if ((this.caseTypeValue != '' && this.assetType != '' && orginatingAttorney != '' && !this.docketError && !this.isDocketError)
                && this.jurisdictionList != null && this.jurisdictionList.length > 0) {
                console.log('inside edit mode');
                this.jurisdictionList.forEach((row => {
                    console.log('rows', row);
                    if (row.uniqueId == this.editId) {
                        row.caseTypeValue = this.caseTypeValue;
                        row.assetType = this.assetType;
                        row.selectedInventors = this.selectedInventorsJurisdiction;
                        row.selectedkeywords = this.selectedkeywordJurisdiction;
                        row.selectedApplicants = this.selectedApplicantsJurisdiction;
                        row.selectedBusinessInfos = this.selectedBusiCategoryJurisdiction;
                        row.selectedPriorities = this.finalSelectedPriorities;
                        // row.prosecutionManaged = this.prosecutionManaged;
                        row.renewalsAnnuities = this.renewalsAnnuities;
                        row.engagementDetailsPatent = this.engagementDetailsPatent;
                        row.responsiblePartnerName = this.engagementDetailsPatent.find(ele => ele.label === 'Originating Attorney')?.personName || '';
                        row.responsibleAttorneyName = this.engagementDetailsPatent.find(ele => ele.label === 'Responsible (Billing) Attorney')?.personName || '';
                        row.foreignAssociateName = this.engagementDetailsPatent.find(ele => ele.label === 'Foreign Associate')?.personName || '';
                        row.patOrProsecutionDN = this.patOrProsecutionDN;
                        row.IPRdocketReq = this.IPRdocketReq;
                        row.OppDocketReq = this.OppDocketReq;
                        row.clientRefNo = this.clientRefNo;
                        row.litigationDocketReq = this.litigationDocketReq;
                        row.clientOnAnnuityPolicy = this.clientOnAnnuityPolicy;
                        row.responsibleForAnnuities = this.responsibleForAnnuities;
                        row.clientAccessToFileDocket = this.clientAccessToFileDocket;
                        row.docketActivities = this.docketActivities;
                        console.log('inside add - priori-' + JSON.stringify(this.finalSelectedPriorities));
                        console.log('inside row.docketActivities' + JSON.stringify(this.docketActivities));

                    }
                }));
                this.jurisdictionList = [...this.jurisdictionList];
                this.showJurisdictionPopup = false;
                console.log('jurisdictionList-after edit' + JSON.stringify(this.jurisdictionList));

            }
        } catch (err) {
            console.log('err ' + err.message);

        }
    }

    closePriorityPopup() {
        this.openNewPriorityPopup = false;
        this.showPriorityTable = false;
        this.openExistingPriorityPopup = false;
    }

    enterkeyevent(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    handlePantentFamily(event) {
        console.log('inside event');
        if (event.detail.length > 0) {
            console.log('inside if case');
            this.prioritypatentFamilyId = event.detail[0].Id;
            // this.patentFamilyName = event.detail[0].Name;
            console.log("this.prioritypatentFamilyId", this.prioritypatentFamilyId);
        }
        else {
            this.prioritypatentFamilyId = '';
            // this.patentFamilyName = '';
        }

        this.patentFamilypriorityError = (this.prioritypatentFamilyId == '' || this.prioritypatentFamilyId == undefined) ? 'Complete this field.' : '';
        this.pantentFamilypriorityNewErrorClass = (this.prioritypatentFamilyId == '' || this.prioritypatentFamilyId == undefined) ? 'slds-has-error' : '';

    }

    handlePriorityAssetType(event) {
        this.priorityAssetType = event.detail.value;
        // this.priorityAssetTypeError = this.priorityAssetType == '' ? 'Complete this field.' : '';
        this.template.querySelector('.priorityAssetType').reportValidity();
    }

    handleSelectedJurisdiction(event) {
        this.jurisdictionPriorityOptions = [];
        if (event.detail.length > 0) {
            this.priorityJurisdictionId = event.detail[0].Id;
            this.priorityJurisdictionName = event.detail[0].Name;
            jurisdictionBasedCaseType({ IPMatter: this.priorityAssetType, jurisdictionIds: this.priorityJurisdictionId })
                .then(result => {
                    console.log('resultPriority ', result);
                    let prioritycaseTypeOptions = result[0].AllowedCaseTypes[0].split(';');
                    prioritycaseTypeOptions = JSON.parse(JSON.stringify(prioritycaseTypeOptions));
                    for (let val of prioritycaseTypeOptions) {
                        this.jurisdictionPriorityOptions.push({
                            'label': val,
                            'value': val
                        })
                    }
                    this.jurisdictionPriorityOptions = JSON.parse(JSON.stringify(this.jurisdictionPriorityOptions));
                    console.log('this.jurisdictionPriorityOptions ', this.jurisdictionPriorityOptions);
                })
                .catch(error => {
                    console.error('Error in prioritycaseTypes');
                    console.log('ERROR', JSON.stringify(error));
                });
        }
        else {
            this.priorityJurisdictionId = '';
            this.priorityJurisdictionName = '';
        }
        this.priorityJurisdictionError = (this.priorityJurisdictionId == '' || this.priorityJurisdictionId == undefined) ? 'Complete this field.' : '';
        this.priorityJurisdictionErrorClass = (this.priorityJurisdictionId == '' || this.priorityJurisdictionId == undefined) ? 'slds-has-error' : '';
    }

    handlePriorityCaseType(event) {
        this.priorityCaseType = event.target.value;
        // this.priorityCasetypeError = (this.priorityCaseType == '' || this.priorityCaseType == undefined) ? 'Complete the field.' : '';
        this.template.querySelector('.priorityCaseTypeClass').reportValidity();
    }

    handlePriorityInventionTitle(event) {
        this.inventionTitlePriority = event.target.value;
        this.priorityInventionTitleError = this.inventionTitlePriority.trim() == '' ? 'Complete this field.' : '';
        this.priorityInventionTitleErrorClass = this.inventionTitlePriority.trim() == '' ? 'slds-has-error' : '';
    }

    handlePriorityShortTitle(event) {
        this.shortTitlePriority = event.target.value;
        this.priorityShortTitleError = this.shortTitlePriority.trim() == '' ? 'Complete this field.' : '';
        this.priorityShortTitleErrorClass = this.shortTitlePriority.trim() == '' ? 'slds-has-error' : '';
    }

    handleApplicationNumber(event) {
        this.applicationNumber = event.target.value;
        this.priorityApplicationNumberError = this.applicationNumber.trim() == '' ? 'Complete this field.' : '';
        this.priorityApplicationNumberErrorClass = this.applicationNumber.trim() == '' ? 'slds-has-error' : '';
    }

    handleApplicationDate(event) {
        this.applicationDate = event.target.value;
        this.priorityApplicationDateError = this.applicationDate == null ? 'Complete this field.' : '';
        this.priorityApplicationDateErrorClass = this.applicationDate == null ? 'slds-has-error' : '';
    }

    addNewPriority() {
        try {
            let validation = false;
            if (!validation) {
                this.priorityJurisdictionError = (this.priorityJurisdictionId == '' || this.priorityJurisdictionId == undefined) ? 'Complete this field.' : '';
                this.priorityJurisdictionErrorClass = (this.priorityJurisdictionId == '' || this.priorityJurisdictionId == undefined) ? 'slds-has-error' : '';
                this.patentFamilypriorityError = (this.prioritypatentFamilyId == '' || this.prioritypatentFamilyId == undefined) ? 'Complete this field.' : '';
                this.pantentFamilypriorityNewErrorClass = (this.prioritypatentFamilyId == '' || this.prioritypatentFamilyId == undefined) ? 'slds-has-error' : '';
                this.priorityShortTitleError = this.shortTitlePriority.trim() == '' ? 'Complete this field.' : '';
                this.priorityShortTitleErrorClass = this.shortTitlePriority.trim() == '' ? 'slds-has-error' : '';
                // this.priorityCasetypeError = (this.priorityCaseType == '' || this.priorityCaseType == undefined) ? 'Complete the field.' : '';
                this.template.querySelector('.priorityCaseTypeClass').reportValidity();
                this.template.querySelector('.priorityAssetType').reportValidity();
                this.priorityInventionTitleError = this.inventionTitlePriority.trim() == '' ? 'Complete this field.' : '';
                this.priorityInventionTitleErrorClass = this.inventionTitlePriority.trim() == '' ? 'slds-has-error' : '';
                this.priorityApplicationNumberError = this.applicationNumber.trim() == '' ? 'Complete this field.' : '';
                this.priorityApplicationNumberErrorClass = this.applicationNumber.trim() == '' ? 'slds-has-error' : '';
                this.priorityApplicationDateError = this.applicationDate == null ? 'Complete this field.' : '';
                this.priorityApplicationDateErrorClass = this.applicationDate == null ? 'slds-has-error' : '';
                //this.priorityPortFolioError = this.portfolioManagement == ''? 'Complete this field.' : '';
                // this.priorityPortFolioErrorClass = this.portfolioManagement =='' ? 'slds-has-error' : '';
                // this.priorityAssetTypeError = this.priorityAssetType == '' ? 'Complete this field.' : '';
                if (this.priorityJurisdictionError == '' && this.priorityShortTitleError == '' &&
                    this.priorityInventionTitleError == '' && this.priorityApplicationNumberError == ''
                    && this.priorityApplicationDateError == '' && this.patentFamilypriorityError == '') {
                    validation = true;
                }
            }
            if (validation) {
                console.log('inside validation');
                let randomNumber = parseInt(Math.random() * 100000000).toString();
                const priority = {
                    'SymphonyLF__Country__r.Name': this.priorityJurisdictionName,
                    SymphonyLF__Country__c: this.priorityJurisdictionId,
                    SymphonyLF__Docket_Number__c: '',
                    SymphonyLF__Application_Date__c: this.applicationDate,
                    SymphonyLF__Filing_Number__c: this.applicationNumber,
                    //Client_Reference__c: this.clientReferencePriority,
                    SymphonyLF__Case_Type__c: this.priorityCaseType,
                    Id: '',
                    Name: this.shortTitlePriority,
                    SymphonyLF__Title__c: this.inventionTitlePriority,
                    // Portfolio_Management__c:this.portfolioManagement,
                    SymphonyLF__Patent_Family__c: this.prioritypatentFamilyId,
                    SymphonyLF__IP_Matter__c: this.priorityAssetType,
                    uniqueId: 'PR' + this.priorityJurisdictionId + (new Date().getDate()) + (new Date().getMonth()) + (new Date().getFullYear()) + (new Date().getTime()) + randomNumber
                };
                this.selectedPriorities = [...this.selectedPriorities, priority];
                console.log('selectedPrioritiesNew-' + JSON.stringify(this.selectedPriorities));
                this.finalSelectedPriorities.forEach(item => {
                    if (!this.preselectedIds.some(x => x == item.Id)) {
                        this.preselectedIds.push(item.Id);
                    }
                });
                this.preselectedIds = [...this.preselectedIds];
                if (this.finalSelectedPriorities.length > 0) {
                    this.finalSelectedPriorities = [...this.finalSelectedPriorities, ...this.selectedPriorities];
                }
                else {
                    this.finalSelectedPriorities = [...this.selectedPriorities];
                }
                this.finalPriorityHeight = this.finalSelectedPriorities.length > 7 ? 'height:300px' : '';
                this.openNewPriorityPopup = false;
                this.showPriorityTable = true;
                console.log('finalSelectedPrioritiesNew-' + JSON.stringify(this.finalSelectedPriorities));
            }
        } catch (error) {
            console.log('errr' + error.message);

        }


    }

    handleJurisdictionSearch(event) {
        if (event.detail.length > 0) {
            this.jurisdictionSearchValue = event.detail[0].Id;
            console.log('jursidiction', this.jurisdictionSearchValue);
        }
        else {
            this.jurisdictionSearchValue = '';
        }
    }

    handleFilingNumberSearch(event) {
        this.filingNumberSearchValue = event.target.value;
    }

    handleHEReferenceSearch(event) {
        this.heReferenceSearchValue = event.target.value;
    }

    handlePrioritySearch() {
        console.log('At least one field is required.');//removed in below line at last -->this.clientReferenceSearchValue!=null
        this.existingPriorityCmpError = this.jurisdictionSearchValue != null && this.heReferenceSearchValue != null && this.filingNumberSearchValue != null ? 'At least one field is required for search.' : '';
        this.existingPriorityRecords = [];
        let additionalCondition = '';
        if (this.jurisdictionSearchValue.length > 0) {
            if (additionalCondition != '') {
                additionalCondition += " AND SymphonyLF__Country__c='" + this.jurisdictionSearchValue + "'";
            }
            else {
                additionalCondition += " SymphonyLF__Country__c='" + this.jurisdictionSearchValue + "'";
            }
            this.existingPriorityCmpError = this.jurisdictionSearchValue.length > 0 ? '' : 'At least one field is required for search.';
            this.showPriorityTable = false
            console.log('this.showPriorityTable', this.showPriorityTable);
        }
        if (this.heReferenceSearchValue.length > 0) {
            let searchStr = "'%" + this.heReferenceSearchValue + "%'";
            if (additionalCondition != '') {
                additionalCondition += " AND SymphonyLF__Docket_Number__c LIKE  " + searchStr;
            }
            else {
                additionalCondition += " SymphonyLF__Docket_Number__c  LIKE  " + searchStr;
            }
            this.existingPriorityCmpError = this.heReferenceSearchValue.length > 0 ? '' : 'At least one field is required for search.';

        }
        if (this.filingNumberSearchValue.length > 0) {
            if (additionalCondition != '') {
                additionalCondition += " AND SymphonyLF__Filing_Number__c LIKE '%" + this.filingNumberSearchValue + "%'";
            }
            else {
                additionalCondition += " SymphonyLF__Filing_Number__c LIKE '%" + this.filingNumberSearchValue + "%'";
            }
            this.existingPriorityCmpError = this.filingNumberSearchValue.length > 0 ? '' : 'At least one field is required for search.';

        }
        //if(this.clientReferenceSearchValue.length > 0)
        // {
        //     if(additionalCondition != '')
        // {
        //    additionalCondition += " AND Client_Reference__c='"+this.clientReferenceSearchValue+"'";
        // }
        //  else {
        //   additionalCondition += " Client_Reference__c='"+this.clientReferenceSearchValue+"'";
        //   }
        //  this.existingPriorityCmpError=this.clientReferenceSearchValue.length > 0 ?'':'At least one field is required for search.';

        // }
        if (this.preselectedIds.length > 0) {
            let quotedList = this.preselectedIds.map(item => "'" + item + "'");
            if (additionalCondition != '') {
                additionalCondition += ' AND Id NOT IN (' + quotedList + ')';
            }
            else {
                additionalCondition += ' Id NOT IN (' + quotedList + ')';
            }
        }
        this.showPriorityTable = false;
        console.log('this.preselectedIds-' + JSON.stringify(this.preselectedIds));//removed Client_Reference__c,Portfolio_Management__c field in below query
        let patentQuery = 'Select Name,SymphonyLF__Country__c,SymphonyLF__Docket_Number__c,SymphonyLF__Application_Date__c,SymphonyLF__Filing_Number__c,SymphonyLF__Case_Type__c,SymphonyLF__IP_Matter__c,SymphonyLF__Patent_Status__c,SymphonyLF__Title__c,SymphonyLF__Country__r.Name from SymphonyLF__Patent__c where ' + additionalCondition + ' LIMIT 500';//SymphonyLF__Asset_Type__c
        console.log('patentQuery-' + patentQuery);
        getRecordByQuery({ query: patentQuery }).then(result => {
            if (result && result.length > 0) {
                console.log('result', result);
                this.showPriorityTable = false;
                this.existingPriorityRecords = this.flattenList(result);
                this.existingPriorityRecords = [...this.existingPriorityRecords];
                this.showPriorityTable = true;
                this.nullPriorityRecordMessage = this.existingPriorityRecords != null && this.existingPriorityRecords.length > 0 ? '' : 'No records to display.';
                this.existingPriorityHeight = this.existingPriorityRecords.length > 7 ? 'height:300px' : '';
            }
            else {
                this.nullPriorityRecordMessage = '';
                this.showPriorityTable = false;
                this.nullPriorityRecordMessage = 'No records to display.';
                console.log('No recordsIN');
            }
        });
    }

    getSelectedExistingPriorities(event) {
        this.selectedPriorities = event.detail.selectedRows;
        if (this.selectedPriorities != null && this.selectedPriorities.length > 0) {
            this.showSelectedPriorities = true;
            this.existingPriorityAddError = '';
        }
        else {
            this.showSelectedPriorities = false;
        }
    }

    addExistingPriority() {
        this.existingPriorityAddError = this.selectedPriorities.length > 0 ? '' : 'Select At least One Existing Priority';
        if (this.selectedPriorities.length > 0) {
            if (this.finalSelectedPriorities.length > 0) {
                this.finalSelectedPriorities = [...this.finalSelectedPriorities, ...this.selectedPriorities];
            }
            else {
                this.finalSelectedPriorities = [...this.selectedPriorities];
            }
            this.finalSelectedPriorities = [...this.finalSelectedPriorities];
            this.openExistingPriorityPopup = false;
            this.finalSelectedPriorities.forEach(item => {
                let randomNumber = parseInt(Math.random() * 100000000).toString();
                item.uniqueId = 'PR' + this.priorityJurisdictionId + (new Date().getDate()) + (new Date().getMonth()) + (new Date().getFullYear()) + (new Date().getTime()) + randomNumber;
                if (!this.preselectedIds.some(x => x == item.Id)) {
                    this.preselectedIds.push(item.Id);
                    console.log('this.preselectedIds', this.preselectedIds);
                }
            });
            this.finalSelectedPriorities = [...this.finalSelectedPriorities];
            this.finalPriorityHeight = this.finalSelectedPriorities.length > 7 ? 'height:300px' : '';
        }
    }







    addressToString(address) {
        console.log(JSON.stringify(address));
        let street = (address.street == '' || address.street == undefined) ? '' : address.street + ',';
        let city = (address.city == '' || address.street == '' || address.city == undefined || address.street == undefined) ? '' : address.city + ', ';
        let state = (address.state == '' || address.city == '' || address.state == undefined || address.city == undefined) ? '' : address.state;
        let country = (address.country == '' || address.country == undefined) ? '' : address.country;
        var stateLabel = '';
        if (state != null && state != '' && state && this.addressDependentPicklist[country] != undefined) {
            stateLabel = this.addressDependentPicklist[country].filter(row => row.code == state)[0].label + ', ';

        }
        let countryLabel = '';
        if (country && country != '' && country != null) {
            countryLabel = this.countryOptions.filter(row => row.code == country)[0].label;

        }
        let str = street + city + stateLabel + countryLabel;



        return str;

    }


    resetForm() {
        this.docketError = false;
        this.jurisdictionPopupError = '';
        this.patentFamilyError = '';
        // this.personNameError = '';
        // this.personNameErrorClass = '';
        this.priorityShortTitleError = '';
        this.priorityShortTitleErrorClass = '';
        this.priorityInventionTitleError = '';
        this.priorityInventionTitleErrorClass = '';
        this.priorityApplicationNumberError = '';
        this.priorityApplicationNumberErrorClass = '';
        this.priorityApplicationDateError = '';
        this.priorityApplicationDateErrorClass = '';
        // this.priorityPortFolioError = '';
        // this.priorityPortFolioErrorClass = '';
        this.priorityJurisdictionError = '';
        this.priorityJurisdictionErrorClass = '';
        // this.priorityCasetypeError = '';
        // this.priorityCasetypeErrorClass = '';
        this.jurisdictionCmpError = '';
        this.inventorError = '';
        this.jurisdictionError = '';
        this.shortTitleError = '';
        this.shortTitleErrorClass = '';
        this.responsiblePartnerNew = '';
        this.managingOfficeNew = '';
        this.jurisdictionCmpList = [];
        this.showJurisdictionCmp = false;
        this.existingPriorityHeight = '';
        this.finalPriorityHeight = '';
        this.inventorActionHeight = '';
        this.applicantActionHeight = '';
        this.busiCategoryActionHeight = '';
        this.jurisdictionTableHeight = '';
        this.applicantTableHeight = '';
        this.heReferenceSearchValue = '';
        this.jurisdictionSearchValue = '';
        this.filingNumberSearchValue = '';
        //this.clientReferenceSearchValue='';
        this.shortTitle = '';
        //this.clientReference='';
        this.inventionTitle = '';
        this.inventionTitleError = '';
        this.inventionTitleErrorClass = '';
        // this.inventionDate = null;
        // this.inventionDescription = '';
        // this.earliestPriorityDate = null;
        this.patentData = [];
        // this.showBusinessInformationError = '';
        this.selectedBusinessInfos = [];
        this.patentFamilyId = '';
        this.selectedInventors = [];
        // this.inventorsData = [];
        this.inventorTableHeight = '';
        // this.documentId = '';
        // this.fileDetails = [];
        this.showConfirmationDialog = false;
        this.confirmationTitle = '';
        this.confirmationMessage = '';
        this.readonly = false;
        this.jurisdictionList = [];
        this.jurisdictionId = '';
        this.jurisdictionName = '';
        this.editId = '';
        this.existingPriorityRecords = [];
        this.showSelectedPriorities = false;
        this.applicationDate = null;
        this.applicationNumber = '';
        // this.portfolioManagement = '';
        this.selectedApplicants = [];
        this.personName = '';
        this.emailAddress = '';
        this.preselectedIds = [];
        this.priorityCaseType = '';
        this.priorityJurisdictionId = '';
        this.priorityJurisdictionName = '';
        this.showPriorityTable = false;
        this.inventionTitlePriority = '';
        this.shortTitlePriority = '';
        this.patentTableHeight = '';
        this.caseTypeValue = '';
        this.inventorsTable = '';
        this.nullPriorityRecordMessage = '';
        this.pantentFamilypriorityNewErrorClass = '';
        this.patentFamilypriorityError = '';
        // this.patentFamilyName = '';
        this.prioritypatentFamilyId = '';
        this.existingPriorityCmpError = '';
        this.emailAddressError = '';
        this.existingPriorityAddError = '';
        this.priorityAssetType = 'Patent';
        this.assetType = 'Patent';
        this.renewalsAnnuities = true;
        // this.prosecutionManaged = '';
        this.patOrProsecutionDN = '';
        this.IPRdocketReq = '';
        this.OppDocketReq = '';
        this.litigationDocketReq = '';
        this.clientAccessToFileDocket = '';
        this.responsibleForAnnuities = '';
        this.clientOnAnnuityPolicy = '';
        this.docketActivities = [...DOCKET_ACTIVITIES];
        this.template.querySelectorAll('symphonylf-multi-select-pick-list-with-search').forEach((record) => {
            record.reset();
        });
    }


    _flatten = (nodeValue, flattenedRow, nodeName) => {
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.' + key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }
    flattenList(records) {
        let recordList = [];
        for (let row of records) {
            const flattenedRow = {};
            // get keys of a single row — Name, Phone, LeadSource and etc
            let rowKeys = Object.keys(row);
            //iterate 
            rowKeys.forEach((rowKey) => {
                //get the value of each key of a single row. John, 999-999-999, Web and etc
                const singleNodeValue = row[rowKey];
                //check if the value is a node(object) or a string
                if (singleNodeValue.constructor === Object) {
                    //if it's an object flatten it
                    this._flatten(singleNodeValue, flattenedRow, rowKey)
                } else {
                    //if it’s a normal string push it to the flattenedRow array
                    flattenedRow[rowKey] = singleNodeValue;
                }
            });
            recordList.push(flattenedRow);
        }
        console.log('recordList-' + recordList);
        return recordList;
    }

    handleConfirmationClick(event) {
        if (event.target.name == 'confirmModal') {
            if (event.detail.status === 'confirm') {
                if (this.confirmationTitle == 'Cancel') {
                    const eve = new CustomEvent('showengagementmodalclose', {
                        detail: false
                    })
                    this.dispatchEvent(eve);

                }
                else {
                    this.showConfirmationDialog = false;
                    this.showRecordCreationSpinner = true;
                    this.spinnerMessage = 'Patent creation in progress...';
                    this.handleSubmitForm();
                }
            }
            else if (event.detail.status === 'cancel') {
                this.showConfirmationDialog = false;
            }
        }
    }


    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            // Flow has finished
            console.log('Flow finished successfully.');
        }
    }



    // handleInventionDescription(event) {
    //     this.inventionDescription = event.target.value;
    // }
    // handleEarliestPriorityDate(event) {
    //     this.earliestPriorityDate = event.target.value;
    // }






    // handleFileUpload(event)                                         //Mark Image Upload
    // {
    //     const fileUploadDetails = event.detail;                            //get file upload details
    //     fileUploadDetails.forEach((item) => {
    //         let file = {
    //             id: item.documentId,
    //             contentVersionId: item.contentVersionId,
    //             contentDocumentId: item.documentId
    //         }
    //         this.fileDetails = [...this.fileDetails, file];
    //     });
    //     this.fileDetails = [...this.fileDetails];
    //     console.log('handleFileUpload-' + JSON.stringify(this.fileDetails));
    //     //store in document id
    // }
    // handleDeleteFile(event) {
    //     this.documentId = '';
    //     try {
    //         const id = event.detail;
    //         console.log('id-' + JSON.stringify(id));
    //         this.fileDetails = this.fileDetails.filter(x => x.Id != id);
    //         this.fileDetails = [...this.fileDetails];
    //         console.log('delete image-' + JSON.stringify(this.fileDetails));
    //     }
    //     catch (exception) {
    //         console.log('exception-' + JSON.stringify(exception));
    //     }

    // }

    setErrorMessage() {
        this.shortTitleError = this.mainRadioValue == 'New Patent Family' && this.shortTitle.trim() == '' ? 'Complete this field.' : '';
        this.shortTitleErrorClass = this.mainRadioValue == 'New Patent Family' && this.shortTitle.trim() == '' ? 'slds-has-error' : '';
        this.inventionTitleError = this.mainRadioValue == 'New Patent Family' && this.inventionTitle.trim() == '' ? 'Complete this field.' : '';
        this.inventionTitleErrorClass = this.mainRadioValue == 'New Patent Family' && this.inventionTitle.trim() ? '' : 'slds-has-error';
        this.jurisdictionError = this.jurisdictionList.length == 0 ? 'At least one jurisdiction is required.' : '';
        this.inventorError = this.selectedInventors.length == 0 ? 'At least one inventor is required.' : '';

    }

    //handlePortfolioManagement(event)
    //{
    //    this.portfolioManagement = event.detail.value;
    //    this.priorityPortFolioError = this.portfolioManagement == ''? 'Complete this field.' : '';
    //    this.priorityPortFolioErrorClass = this.portfolioManagement=='' ? 'slds-has-error' : '';
    // }


    handleSubmitForm() {
        let businessRecords = [];
        this.selectedBusinessInfos.forEach((item) => {
            let businessRecord = {
                id: item.Id,
                categoryValue: item.SymphonyLF__Category_Value__c,
                name: item.Name,
                categoryFormula: item.SymphonyLF__Category_Formula__c,
                tag: item.Tag__c,
                existingBCId: item.existingBCId,
                existing: 'existing' in item ? item.existing : false,
            };
            businessRecords.push(businessRecord);
        });

        let temp = [...this.jurisdictionList];
        console.log('temp-' + JSON.stringify(temp));
        temp.forEach((item1) => {
            let priorityRecords = [];
            item1.selectedPriorities.forEach(item => {
                let priorityRecord = {
                    Id: item.Id,
                    jurisdiction: item.SymphonyLF__Country__c,
                    heReferenceNumber: item.SymphonyLF__Docket_Number__c,
                    filingDate: item.SymphonyLF__Application_Date__c,
                    filingNumber: item.SymphonyLF__Filing_Number__c,
                    //clientReference:item.Client_Reference__c,
                    caseType: item.SymphonyLF__Case_Type__c,
                    //ipMatter:item.SymphonyLF__Asset_Type__c,
                    shortTitle: item.Name,
                    title: item.SymphonyLF__Title__c,
                    // portfolioManagement:item.Portfolio_Management__c,
                    patentFamily: item.SymphonyLF__Patent_Family__c,
                    priorityAssetType: item.SymphonyLF__IP_Matter__c
                };
                priorityRecords.push(priorityRecord);
            });
            item1.selectedPriorities = [];
            item1.selectedPriorities = [...priorityRecords];
        });
        let familyDetails = {
            patentFamilyId: this.patentFamilyId,
            title: this.inventionTitle,
            // inventionDate: this.inventionDate,
            shortTitle: this.shortTitle,
            // clientReference:this.clientReference,
            // inventionDate: this.inventionDate,
            // earliestPriorityDate: this.earliestPriorityDate,
            // inventionDescription: this.inventionDescription,
            engagementDetails: this.engagementDetailsPF
        };
        let patentData = {
            ClientId: this.clientId,
            conflictCheckId: this.conflictCheckId,
            Source: this.mainRadioValue,
            PatentFamily: familyDetails,
            BusinessCategory: businessRecords,
            Inventors: this.selectedInventors,
            keywords: this.selectedkeywords,
            Applicants: this.selectedApplicants,
            ApplicationDetails: temp,
            // FileDetails: this.fileDetails
        }
        console.log('patentData-' + JSON.stringify(patentData));
        let patentDataJson = JSON.stringify(patentData);
        saveRecord({ jsonString: patentDataJson, userId: null })
            .then((result) => {
                console.log('result-' + JSON.stringify(result));
                if (result.Status && result.PatentFamilyID != null) {
                    this.showRecordCreationSpinner = false;
                    this.patentFamilyId = result.PatentFamilyID;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records Created successfully',
                            variant: 'success'
                        })
                    );
                    const eve = new CustomEvent('showengagementmodalclose', {
                        detail: false
                    })
                    this.dispatchEvent(eve);
                    Utils.navigateToRecordViewPage(this, NavigationMixin, this.patentFamilyId);
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                }
                else {
                    console.log('juris after error-' + JSON.stringify(this.jurisdictionList));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result.message,
                            // message: 'Error in creating Records',
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    this.showRecordCreationSpinner = false;
                    console.log('Error-' + JSON.stringify(result.Errors));
                    console.log('Error-' + JSON.stringify(result.message));
                }
                this.jurisdictionList = [...this.jurisdictionList];

            });
    }

    removeApplicants(event) {
        let selectedRow = event.detail.row;
        let selectedJurisdiction = this.jurisdictionList.findIndex(row => row.uniqueId == this.editId);
        let selectedapplicantsTable = this.jurisdictionList[selectedJurisdiction].selectedApplicants;
        selectedapplicantsTable = selectedapplicantsTable.filter(row => row.key != selectedRow.key);
        this.applicantsTable = [...selectedapplicantsTable];
        this.jurisdictionList[selectedJurisdiction].selectedApplicants = [...selectedapplicantsTable];
        this.selectedApplicantsJurisdiction = [...selectedapplicantsTable];
        this.applicantsTable = selectedapplicantsTable.filter(row => row.key != selectedRow.key);
        this.applicantActionHeight = this.applicantsTable.length > 7 ? 'height:300px' : '';
    }

    removeBusinessCategory(event) {
        let selectedRow = event.detail.row;
        let selectedJurisdiction = this.jurisdictionList.findIndex(row => row.uniqueId == this.editId);
        let selectedBusiCategoryTable = this.jurisdictionList[selectedJurisdiction].selectedBusinessInfos;
        selectedBusiCategoryTable = selectedBusiCategoryTable.filter(row => row.Id != selectedRow.Id);
        this.businessCategoriesTable = [...selectedBusiCategoryTable];
        this.jurisdictionList[selectedJurisdiction].selectedBusinessInfos = [...selectedBusiCategoryTable];
        this.selectedBusiCategoryJurisdiction = [...selectedBusiCategoryTable];
        this.businessCategoriesTable = selectedBusiCategoryTable.filter(row => row.Id != selectedRow.Id);
        this.busiCategoryActionHeight = this.businessCategoriesTable.length > 7 ? 'height:300px' : '';
    }

   



    async handleKeywords(event){
        
        let latestKeywords = event.detail;
        let previousSelectedKeywords = this.selectedkeywords;

        if (latestKeywords.length > previousSelectedKeywords.length) {
            // insert new keyword
            let newkeywords = [];
            latestKeywords.forEach(ele => {
                if (!previousSelectedKeywords.find(e => e.key == ele.key)) {
                    newkeywords.push(ele);
                }
            })
            console.log('newkeywords nsert' + JSON.stringify(newkeywords));

            if (this.jurisdictionList.length > 0) {
                this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                    let obj = { ...ele };
                    console.log('before ' + JSON.stringify(obj.selectedkeywords));
                    obj.selectedkeywords = [...obj.selectedkeywords, ...newkeywords];
                    console.log('After ' + JSON.stringify(obj.selectedkeywords));
                    return obj;
                })]
            }

        } else if (latestKeywords.length < previousSelectedKeywords.length) {
            // delete the keyword
            let deletedKeywords = [];
            previousSelectedKeywords.forEach(ele => {
                if (!latestKeywords.find(e => e.key == ele.key)) {
                    deletedKeywords.push(ele);
                }
            })
            console.log('temp@List ' + JSON.stringify(deletedKeywords));
            const existingRecIds = new Set(deletedKeywords.map(record => record.existingKeywordId).filter(id => id));

            // Check if Existing keyword is getting deleted in deletedKeywords
            const isDeleteExistingKeyword = deletedKeywords.some(record => record.existingKeywordId && existingRecIds.has(record.existingKeywordId));
            this.selectedkeywords = this.selectedkeywords.map(({ selected, ...rest }) => rest);
            this.keywords = this.keywords.map(({ selected, ...rest }) => rest);
            this.template.querySelector(".keyword").setValues(this.keywords, this.selectedkeywords);
            this.keywords = [...this.keywords];
            if (isDeleteExistingKeyword) {
                
                // Show confirmation dialog
                const result = await LightningConfirm.open({
                    message: this.warningMessage,
                    variant: 'headerless', 
                    label: 'Confirm Removal',  
                });

               
                if (result) {
                    console.log('Record deleted!');
                } else {
                    console.log('Deletion canceled');
                    return; 
                }
            }
            if (this.jurisdictionList.length > 0) {
                this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                    let obj = { ...ele };
                    obj.selectedkeywords = obj.selectedkeywords.map(ele => {
                        if (!deletedKeywords.find(e => e.key == ele.key)) {
                            return ele
                        } else {
                            return null
                        }
                    }).filter(ele => ele !== null);
                    return obj;
                })]
            }

        } else {
            // update selectedkeywords for Jurisdicition List
            if (this.jurisdictionList.length > 0) {
                this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                    return { ...ele, selectedkeywords: latestKeywords };
                })]
            }
        }
        

        this.selectedkeywords = latestKeywords;
        this.selectedkeywords = [...this.selectedkeywords];
        this.selectedkeywords = this.selectedkeywords.map(({ selected, ...rest }) => rest);
        this.keywords = this.keywords.map(({ selected, ...rest }) => rest);
        this.template.querySelector(".keyword").setValues(this.keywords, this.selectedkeywords);
        this.keywordTableHeight = this.selectedkeywords.length > 7 ? 'height:300px' : '';
        console.log('selectedkeywords-' + JSON.stringify(this.selectedkeywords));
        console.log('selectedkeywords-' + JSON.stringify(this.jurisdictionList));
    }

    removeKeyword(event) {

        let selectedRow = event.detail.row;
        let selectedJurisdiction = this.jurisdictionList.findIndex(row => row.uniqueId == this.editId);
        let selectedKeywordTable = this.jurisdictionList[selectedJurisdiction].selectedkeywords;
        selectedKeywordTable = selectedKeywordTable.filter(row => row.key != selectedRow.key);
        console.log('removed keyword', JSON.stringify(selectedKeywordTable.filter(row => row.key != selectedRow.key)));
        if (selectedKeywordTable == null) {
            selectedKeywordTable = [];
        }
        this.jurisdictionList[selectedJurisdiction].selectedkeywords = [...selectedKeywordTable];
        this.keywordTable = [...selectedKeywordTable];
        this.selectedkeywordJurisdiction = [...selectedKeywordTable];
        this.keywordActionHeight = this.keywordTable.length > 7 ? 'height:300px' : '';
    }

    handleNewKeyword(event){
        this.showKeywordPopup = true;
    }

    closeKeywordModal(){
        this.showKeywordPopup = false;
    }

    handleKeywordError(event) {
        // Handle error if the form submission fails
        console.log('Error during submission:', event.detail);
        console.log('Error during submission:', event.detail.message);
       
    }

    handleKeywordSuccess(event) {
        // Handle success after saving the record
        const fields = event.detail.fields;
        console.log('Record saved successfully:',JSON.stringify(event.detail));
        console.log('Record saved successfully:',  fields);
        let keyword = {};
        keyword.Name = fields.Name.value;
        keyword.fullName = fields.SymphonyLF__Full_Name__c.value;
        keyword.label= fields.Name.value;
        keyword.value = fields.Name.value;  
        keyword.key = event.detail.id;
        this.selectedkeywords.push(keyword);
        this.keywords.push(keyword);
        this.selectedkeywords = [...this.selectedkeywords];
        this.keywordTable = [...this.selectedkeywords];
        this.showKeywordPopup = false;
        this.selectedkeywords = this.selectedkeywords.map(({ selected, ...rest }) => rest);
        this.keywords = this.keywords.map(({ selected, ...rest }) => rest);
        this.template.querySelector(".keyword").setValues(this.keywords, this.selectedkeywords);
        
        if (this.jurisdictionList.length > 0) {
            this.jurisdictionList = [... this.jurisdictionList.map(ele => {
                let obj = { ...ele };
                obj.selectedkeywords.push(keyword);
                return obj;
            })]
        }

        
    }




}