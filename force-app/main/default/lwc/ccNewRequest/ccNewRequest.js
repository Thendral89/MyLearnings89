import { LightningElement, api, track, wire } from 'lwc';
import getRecordClient from  '@salesforce/apex/CCNewRequestController.getRecordClient';
//Importing Custom Labels
import conflictCheckFormAnnouncementheader from '@salesforce/label/c.Conflict_Check_Form_Announcement_Header';
import conflictCheckFormAnnounceSubText from '@salesforce/label/c.Conflict_Check_Form_Announcement';
//Conflict Check Fileds
import CONFLICT_CHECK_OBJECT from '@salesforce/schema/Conflict_Check__c';
import CLIENT_FIELD from '@salesforce/schema/Conflict_Check__c.Client_Name__c';
import NEW_CLIENT_FIELD from '@salesforce/schema/Conflict_Check__c.New_Client__c';

//import CLIENT_NAME_FIELD from '@salesforce/schema/Conflict_Check__c.Client_s_Name__c';
import MATTER_NAME_FIELD from '@salesforce/schema/Conflict_Check__c.Matter_Name__c';
import REFERENCE_NUMBER_FIELD from '@salesforce/schema/Conflict_Check__c.Client_Reference_Number__c';
import TRANSFIRM_ANOTHER_FIRM_FIELD from '@salesforce/schema/Conflict_Check__c.Matter_transferred_in_from_another_firm__c';
import ADVERSE_PARTIES_FIELD from '@salesforce/schema/Conflict_Check__c.Adverse_Parties__c';
import RELATED_PARTIES_FIELD from '@salesforce/schema/Conflict_Check__c.Related_Parties_other_than_client__c';
import CLIENT_RELATIONSHIP_FIELD from '@salesforce/schema/Conflict_Check__c.Client_Relationship_with_related_parties__c';
import CONTRIBUTORS_FIELD from '@salesforce/schema/Conflict_Check__c.Contributor__c';
import KEYWORDS_FIELD from '@salesforce/schema/Conflict_Check__c.Keywords__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Conflict_Check__c.Brief_Description_of_Subject_Matter__c';
import CCFIELD_FIELD from '@salesforce/schema/Conflict_Check__c.CC_Status__c';
import AREA_OF_LAW_FIELD from '@salesforce/schema/Conflict_Check__c.Area_of_Law_AOL__c';
import {
    IsConsoleNavigation,
    EnclosingTabId,
    openSubtab
} from 'lightning/platformWorkspaceApi';

import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent
} from "lightning/flowSupport";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import Toast from 'lightning/toast';
import { RefreshEvent } from 'lightning/refresh';


export default class CcNewRequest extends NavigationMixin(LightningElement) {

    @api showModal = false;
    @api flowModal = false;

    RECORD_CREATE_SUCCESS_MESSAGE = 'New Conflict Check record initiated successfully.';
    VALIDATION_ERROR_MESSAGE = 'Please fill required fields and anyone of Contributors (OR) Related Parties fields are mandatory.'

    @track announcementHeader = conflictCheckFormAnnouncementheader; //'Conflict Check Form Important Information!';
    @track announcements = conflictCheckFormAnnounceSubText; //'Please press the Enter button on your keyboard to add Contributors, Related Parties, Adverse Parties, and Keywords.\n'+


    data = [];
    @track isRenderedCallBackInitialized = false;

    @track showSpinner = false;
    isShowEngagementModal;
    isShowDoNotEngagementModal;
    rowOffset = 0;
    currentStepIsShowDatatables = false;
    currentStepIsDataConfirmation = false;
    currentStepIsCreateNewRequest = true;
    isShowNewClientModal = false;
    currentStep = 'createNewRequest';
    toggleCheck = false;
    isExpandAll = true;
    @track isShowModal = false;
    @track existingClientName;
    wiredClientData;
    @track clientData;
    @track inventorData;
    @track usersData;
    @track keywordsData;
    @track activeSections = ['BasicDetails'];
    @track isClientCreated = false;
    baseURL;
    @track clientId;
    @track hasError = false;
    @track allAdverseParties = '';
    @track allRelatedParties = '';
    @track allContributors = '';
    @track allKeywords = '';
    showKeywordError = false;
    showLawError = false;
    showClientError = false;
    selectedClientGroupNumber;
    
    @track ccRecordId = '';

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;

    connectedCallback() {
        if (this.currentStep === 'createNewRequest') {
            this.currentStepIsCreateNewRequest = true;
        }
        this.showModal = true;
    }
    renderedCallback() {
        console.log('renderedCallback ');
        if (this.adversePartiesPills != null && this.showModal) {
            var event = this.template.querySelector('[data-id="adverseParties"]');
            event.addEventListener("keydown", (event) => {
                if (event.key === "Enter") {
                    console.log('event.key ', event.key);
                    this.addAdverseParties();
                }
            });
        }

        if (this.relatedPartiesPills != null && this.showModal) {
            var event = this.template.querySelector('[data-id="relatedParties"]');
            event.addEventListener("keydown", (event) => {
                if (event.key === "Enter") {
                    this.addRelatedParties();
                }
            });
        }

        if (this.contribtorsPills != null && this.showModal) {
            var event = this.template.querySelector('[data-id="contribtors"]');
            event.addEventListener("keydown", (event) => {
                if (event.key === "Enter") {
                    this.addContributors();
                }
            });
        }
        if (this.keywordsPills != null && this.showModal) {
            var event = this.template.querySelector('[data-id="keywords"]');
            event.addEventListener("keydown", (event) => {
                if (event.key === "Enter") {
                    this.addKeywords();
                }
            });
        }
    }
    @track adversePartiesPills = [];
    addAdverseParties() {
        console.log('addAdverseParties ');
        if (this.v_AdverseParties != null && this.v_AdverseParties != '') {
            if (this.v_AdverseParties.length >= 3) {
                var Duplicate = this.adversePartiesPills.find(s => (s.label).toUpperCase() == this.v_AdverseParties.toUpperCase());
                console.log('Duplicate ', JSON.stringify(Duplicate));
                console.log('v_AdverseParties ', JSON.stringify(this.v_AdverseParties));
                if (typeof (Duplicate) === "undefined") {
                    this.adversePartiesPills.push({ label: this.v_AdverseParties });
                    this.v_AdverseParties = '';
                    console.log('v_AdverseParties.adversePartiesPills ', JSON.stringify(this.adversePartiesPills));
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Invalid',
                            message: 'Entered Adverse Parties has already added.',
                            mode: 'dismissible',
                            variant: 'warning',
                        }),
                    );
                    return;
                }

            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Errors',
                        message: 'Adverse Parties name should have more or equal to 3 Characters',
                        mode: 'dismissible',
                        variant: 'error',
                    }),
                );
            }
        }
        console.log('this.adversePartiesPills ', JSON.stringify(this.adversePartiesPills));
    }
    handleAdeversePartiesRemove(event) {
        const index = event.detail.index;
        this.adversePartiesPills.splice(index, 1);
    }

    @track contribtorsPills = [];
    addContributors() {
        if (this.contributors != null && this.contributors != '') {
            if (this.contributors.length >= 3) {
                var Duplicate = this.contribtorsPills.find(s => (s.label).toUpperCase() == this.contributors.toUpperCase());
                if (typeof (Duplicate) === "undefined") {
                    this.contribtorsPills.push({ label: this.contributors });
                    this.contributors = '';
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Invalid',
                            message: 'Entered Contributor has already added.',
                            mode: 'dismissible',
                            variant: 'warning',
                        }),
                    );
                    return;
                }

            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Errors',
                        message: 'Contributor name should have more or equal to 3 Characters',
                        mode: 'dismissible',
                        variant: 'error',
                    }),
                );
            }

        }
    }
    handleContributorsRemove(event) {
        const index = event.detail.index;
        this.contribtorsPills.splice(index, 1);
    }

    @track relatedPartiesPills = [];
    allRelatedPartiesCheck = []
    addRelatedParties() {
        if (this.v_RalatedParties != null && this.v_RalatedParties != '') {
            if (this.v_RalatedParties.length >= 3) {
                var Duplicate = this.relatedPartiesPills.find(s => (s.label).toUpperCase() == this.v_RalatedParties.toUpperCase());
                if (typeof (Duplicate) === "undefined") {
                    this.relatedPartiesPills.push({ label: this.v_RalatedParties });
                    this.v_RalatedParties = '';
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Invalid',
                            message: 'Entered Related Parties has already added.',
                            mode: 'dismissible',
                            variant: 'warning',
                        }),
                    );
                    return;
                }

            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Errors',
                        message: 'Related Parties name should have more or equal to 3 Characters',
                        mode: 'dismissible',
                        variant: 'error',
                    }),
                );
            }

        }
    }
    handleRelatedPartiesRemove(event) {
        const index = event.detail.index;
        this.relatedPartiesPills.splice(index, 1);
    }


    @track keywordsPills = [];
    addKeywords() {
        if (this.keywords != null && this.keywords != '') {
            if (this.keywords.length >= 3) {
                var Duplicate = this.keywordsPills.find(s => (s.label).toUpperCase() == this.keywords.toUpperCase());
                if (typeof (Duplicate) === "undefined") {
                    this.keywordsPills.push({ label: this.keywords });
                    this.keywords = '';
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Invalid',
                            message: 'Entered Keyword has already added.',
                            mode: 'dismissible',
                            variant: 'warning',
                        }),
                    );
                    return;
                }

            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Errors',
                        message: 'Keyword should have more or equal to 3 Characters',
                        mode: 'dismissible',
                        variant: 'error',
                    }),
                );
            }
        }
    }
    handleKeywordRemove(event) {
        const index = event.detail.index;
        this.keywordsPills.splice(index, 1);
    }



    hideConflictCheckModal(event) {
        this.showModal = false;
    }
    hideModalBox(event) {
        this.isShowNewClientModal = false;
        this.showModal = true;
        this.currentStepIsCreateNewRequest = true;

    }


    handleCancelClick() {
        const eve = new CustomEvent('closepopup', {
            detail: false
        })
        this.dispatchEvent(eve);
        this.handleFlowAction();


    }
    handleFlowAction() {
        if (this.flowModal) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    openClientPopup() {
        this.isShowNewClientModal = true;
        this.currentStepIsCreateNewRequest = false;
        this.showModal = false;
    }

    @track value;
    @track allValues = [];
    @track optionsMaster = [
        { label: 'Applicant', value: 'Applicant' },
        { label: 'Assignee', value: 'Assignee' },
        { label: 'Assignor', value: 'Assignor' },
        { label: 'Client', value: 'Client' },
        { label: 'Licensee', value: 'Licensee' },
        { label: 'Licensor', value: 'Licensor' },
    ];

    // Form Fields values 

    @track matterName = '';
    onMatterNameChange(event) {
        this.matterName = event.target.value;
    }

    @track referenceNumber = ''
    onReferenceNumberChange(event) {
        this.referenceNumber = event.target.value;
    }

    @track v_MatterTransferFromFirmSelected = '';
    onMatterTransferFromFirmSelected(event) {
        this.v_MatterTransferFromFirmSelected = event.detail;
    }

    @track v_AdverseParties = '';
    onAdversePartiesChange(event) {
        this.v_AdverseParties = event.target.value;
    }

    @track v_RalatedParties
    onRelatedPartiesChange(event) {
        this.v_RalatedParties = event.target.value;
    }

    handleChange(event) {
        this.value = event.target.value;
        if (!this.allValues.includes(this.value))
            this.allValues.push(this.value);
        this.modifyOptions();
    }

    handleRemove(event) {
        this.value = '';
        const valueRemoved = event.target.name;
        this.allValues.splice(this.allValues.indexOf(valueRemoved), 1);
        this.modifyOptions();
    }

    modifyOptions() {
        this.options = this.optionsMaster.filter(elem => {
            if (!this.allValues.includes(elem.value))
                return elem;
        })
    }

    @track contributors = '';
    onContributorsChange(event) {
        this.contributors = event.target.value;
    }

    @track isValidKeyword = false;
    @track keywords = '';
    onKeywordsChange(event) {
        this.keywords = event.target.value;
        if (this.allKeywords != null) {
            this.isValidKeyword = true;
        }
        else {
            this.isValidKeyword = false;
        }
    }

    @track v_BreifDescription = '';
    onDescriptionChange(event) {
        this.v_BreifDescription = event.target.value;
    }

    @track areaOfLaw = '';
    onAreaOfLawSelected(event) {
        this.areaOfLaw = event.detail;
        console.log('this.areaOfLaw : ',this.areaOfLaw);
    }

    onClickInitiateConflictCheck(event) {
        this.showSpinner = true;
        //this.conflictCheckValidations();
        if ( this.conflictCheckValidations() ) {
            this.onCreateConflictCheck();
        }

    }

    conflictCheckValidations() {
        this.hasError        = false;
        this.showClientError = false;
        this.showLawError    = false;
        this.showKeywordError= false;
        this.allAdverseParties = '';
        this.allRelatedParties = '';
        this.allContributors   = '';
        this.allKeywords       = '';

        this.adversePartiesPills.forEach(o => {
        this.allAdverseParties = this.allAdverseParties
            ? this.allAdverseParties + ',' + o.label
            : o.label;
        });
        this.relatedPartiesPills.forEach(o => {
        this.allRelatedParties = this.allRelatedParties
            ? this.allRelatedParties + ',' + o.label
            : o.label;
        });
        this.contribtorsPills.forEach(o => {
        this.allContributors = this.allContributors
            ? this.allContributors + ',' + o.label
            : o.label;
        });
        this.keywordsPills.forEach(o => {
        this.allKeywords = this.allKeywords
            ? this.allKeywords + ',' + o.label
            : o.label;
        });

        // related/adverse/contributor check
        if (((this.allRelatedParties === undefined || this.allRelatedParties === '' || this.allRelatedParties == null)
            &&
            (this.allAdverseParties === undefined || this.allAdverseParties === '' || this.allAdverseParties == null)
            &&
            (this.allContributors === undefined || this.allContributors === '' || this.allContributors == null))

        ) {
        this.triggerRelatedPartiesError(); 
        }

        // client
        if (this.existingClientName === undefined || this.existingClientName === '' || this.existingClientName == null) {
            this.showClientError = true;
            this.hasError        = true;
        }

        // keywords
        if (this.allKeywords === undefined || this.allKeywords === '' || this.allKeywords == null) {
            this.showKeywordError = true;
            this.hasError         = true;
        }

        // area of law
        if (this.areaOfLaw === undefined || this.areaOfLaw === '' || this.areaOfLaw === null || this.areaOfLaw === '--None--') {
            this.showLawError = true;
            this.hasError     = true;
        }

        // if any error, hide spinner
        if (this.hasError) {
            this.showSpinner = false;
        }
        return !this.hasError;
    }


    /*conflictCheckValidations() {
        //Defaulting to Blank, so that it can be reset everytime, when method is called.
        this.allAdverseParties = '';
        this.allRelatedParties = '';
        this.allContributors = '';
        this.allKeywords = '';
        this.showKeywordError = false;
        this.showLawError = false;
        this.showClientError = false;
        this.hasError = false;

        this.showSpinner = true;
        this.adversePartiesPills.forEach(option => {
            this.allAdverseParties = this.allAdverseParties === '' ? this.allAdverseParties = option.label : this.allAdverseParties + ',' + option.label;
        });

        this.relatedPartiesPills.forEach(option => {
            this.allRelatedParties = this.allRelatedParties === '' ? option.label : this.allRelatedParties + ',' + option.label;
        });
        this.contribtorsPills.forEach(option => {
            this.allContributors = this.allContributors === '' ? option.label : this.allContributors + ',' + option.label;

        });
        this.keywordsPills.forEach(option => {
            this.allKeywords = this.allKeywords === '' ? option.label : this.allKeywords + ',' + option.label;
        });

        if (((this.allRelatedParties === undefined || this.allRelatedParties === '' || this.allRelatedParties == null)
            &&
            (this.allAdverseParties === undefined || this.allAdverseParties === '' || this.allAdverseParties == null)
            &&
            (this.allContributors === undefined || this.allContributors === '' || this.allContributors == null))

        ) {
            this.triggerRelatedPartiesError();
        }

        if (this.existingClientName === undefined || this.existingClientName === '' || this.existingClientName == null) {
            this.showClientError = true;
            this.showSpinner = false;
        }
        if (this.allKeywords === undefined || this.allKeywords === '' || this.allKeywords == null) {
            this.showKeywordError = true;
            this.showSpinner = false;
        }
        if (this.areaOfLaw === undefined || this.areaOfLaw === '' || this.areaOfLaw === null || this.areaOfLaw === '--None--') {
            this.showLawError = true;
            this.showSpinner = false;
        }
        console.log('this.hasError', this.hasError);
        console.log('this.showClientError', this.showClientError);
        console.log('this.showKeywordError', this.showKeywordError);
        console.log('this.showLawError', this.showLawError);
        if (!this.hasError && !this.showClientError && !this.showKeywordError && !this.showLawError) {
            this.hasError = false;
            this.onCreateConflictCheck();
        }
    }*/

    triggerRelatedPartiesError() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Validation Errors',
                message: this.VALIDATION_ERROR_MESSAGE,
                variant: 'error',
            }),
        );
        this.hasError = true;
        this.showSpinner = false;
    }


    @track ConflictCheckRecordId;
    async onCreateConflictCheck(event) {
        var multiSelect = this.allValues.join(';');
        const fields = {};
        fields[CLIENT_FIELD.fieldApiName] = this.existingClientName;
        fields[MATTER_NAME_FIELD.fieldApiName] = this.matterName.length > 80 ? this.matterName.slice(0, 80) : this.matterName;
        fields[REFERENCE_NUMBER_FIELD.fieldApiName] = this.referenceNumber;
        fields[TRANSFIRM_ANOTHER_FIRM_FIELD.fieldApiName] = this.v_MatterTransferFromFirmSelected;
        fields[ADVERSE_PARTIES_FIELD.fieldApiName] = this.allAdverseParties; //this.v_AdverseParties;
        fields[RELATED_PARTIES_FIELD.fieldApiName] = this.allRelatedParties; //this.v_RalatedParties;
        fields[CLIENT_RELATIONSHIP_FIELD.fieldApiName] = multiSelect;
        fields[CONTRIBUTORS_FIELD.fieldApiName] = this.allContributors; //this.contributors;
        fields[KEYWORDS_FIELD.fieldApiName] = this.allKeywords; //this.keywords;
        fields[DESCRIPTION_FIELD.fieldApiName] = this.v_BreifDescription;
        fields[AREA_OF_LAW_FIELD.fieldApiName] = this.areaOfLaw;

        // Default fields to populate
        //fields[CLIENT_NAME_FIELD.fieldApiName] = this.clientName;
        fields[CCFIELD_FIELD.fieldApiName] = 'Conflict Check Pending'; //'Submitted';
        fields[NEW_CLIENT_FIELD.fieldApiName] = this.isClientCreated;

        console.log('this.fields', fields);
        const recordInput = { apiName: CONFLICT_CHECK_OBJECT.objectApiName, fields };
        const ccRecord = await createRecord(recordInput);
        if (ccRecord.id != null) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.RECORD_CREATE_SUCCESS_MESSAGE,
                    variant: 'success',
                }),
            );
            this.showSpinner = false;
            this.handleFlowAction();
            const eve = new CustomEvent('closepopup', {
                detail: false
            })
            this.dispatchEvent(eve);

            this.dispatchEvent(new RefreshEvent());
            // if (this.flowModal) {
            //     this[NavigationMixin.GenerateUrl]({
            //         type: "standard__recordPage",
            //         attributes: {
            //             recordId: ccRecord.id,
            //             objectApiName: 'Conflict_Check__c',
            //             actionName: 'view'
            //         }
            //     }).then(url => {
            //         window.open(url, "_blank");
            //     });
            // }
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There is something wrong while creating the Conflict check record. Please contact to your Salesforce Adminitrator.',
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
        }

    }

    navigateToRecord() {
        Toast.show({
            label: 'Success',
            message: 'Conflict check record initiated successfully',
            mode: 'dismissible',
            variant: 'success'
        }, this);
    }


    closePopup(event) {
        this.isShowNewClientModal = event.close;
        this.showModal = true;
        this.currentStepIsCreateNewRequest = true;
    }
    onclientCreation(event) {
        console.log('created Client =====> ', event.detail);
        this.existingClientName = event.detail;
        this.isClientCreated = true;
        this.isShowNewClientModal = false;
        this.showModal = true;
        this.currentStepIsCreateNewRequest = true;

    }

    expandAll() {
        this.activeSections = ['BasicDetails', 'ConflictCheck', 'MatterEngagement', 'Docketing'];
        this.isExpandAll = false;
    }
    collapseAll() {
        this.activeSections = [];
        this.isExpandAll = true;
    }
    @track clientName;
    lookupClientRecord(event) {
        if (event.detail.selectedRecord != undefined) {
            this.existingClientName = event.detail.selectedRecord.Id;
            this.clientName = event.detail.selectedRecord.Name;
        }
        else {
            this.existingClientName = '';
            this.clientName = '';
        }


    }
    handleClickSaveAsDraft() {
        alert('Conflict check record will create with status DRAFT');
    }
    handleClickDoNotEngage() {
        //alert('Conflict check record will be deleted along with the client record that you have created for this Conflict check.');
        this.isShowDoNotEngagementModal = true;
    }
    handleClickEngage() {
        //alert('Open a popup where we have to fill Matter Engagement model and Docketing');
        this.isShowEngagementModal = true;
    }



    closeDonotEngagementModal(event) {
        this.isShowDoNotEngagementModal = event.detail;
    }
    hideDonotEngagementModal() {
        this.isShowDoNotEngagementModal = false;
    }



    // Skip and Engage Functionality
    isDisignIntakeForm;
    isTrademarkIntakeForm;
    isAgreementIntakeForm;
    isPatentIntakeForm;
    isCopyrightIntakeForm;
    isDisputeIntakeForm;
    isGMIntakeForm;
    hideEngagementModal() {
        this.isShowEngagementModal = false;
    }
    closeEngagementModal(event) {
        this.isShowEngagementModal = false;
        this.connectedCallback();
    }
    @track modalName;
    skipAndEngage = false;
    handleClickOnSkipAndEngage(event) {
        console.log('In Handle Skip and Engage');
       // this.skipAndEngage = true;
        this.showSpinner   = true;

        // if ((this.areaOfLaw == null || this.areaOfLaw == undefined || this.areaOfLaw == '' || this.areaOfLaw == '--None--')
        //     || (this.existingClientName == null || this.existingClientName == undefined || this.existingClientName == '')
        // ) {
        //     Toast.show({
        //         label: 'Error',
        //         message: 'Area of Law & Client Name should be mandatory',
        //         mode: 'dismissible',
        //         variant: 'error'
        //     }, this);
        //     return;

        // }
        // else {
        //     console.log ('In Skip and Engage - Else Block');
        //     if (this.existingClientName) {
            if ( this.validateClientAndLaw() ) {
                this.skipAndEngage = true;
                getRecordClient({ recordId: this.existingClientName })
                    .then((record) => {
                        if(record != null){
                            let status = record.Client_Status__c; // Access the field value
                            this.clientId = record.Id;
                            console.log('client id --->',this.clientId);
                            this.selectedClientGroupNumber = record.SymphonyLF__Client_Group_Number__c;
                            if(status != 'Active'){
                                Toast.show({
                                    label: 'Error',
                                    message: 'Client should be Active For Skip and Engage.',
                                    mode: 'dismissible',
                                    variant: 'error'
                                }, this);
                                this.showSpinner   = false;
                                return;
                            }else{
                                console.log ('Before Helper Method');
                                this.helperMethod();
                                
                            }
                           // this.openApplicationIntakeForm(this.clientId);
                        }
                        
                    })
                    .catch((error) => {
                        console.error('Error retrieving record:', error);
                    });
                
            }
            
       // }
    }

    validateClientAndLaw() {
        this.hasError        = false;
        this.showClientError = false;
        this.showLawError    = false;
    
        if (!this.existingClientName) {
            this.showClientError = true;
            this.hasError        = true;
        }
    
        if (!this.areaOfLaw || this.areaOfLaw === '--None--') {
            this.showLawError = true;
            this.hasError     = true;
        }
    
        if (this.hasError) {
            this.showSpinner = false;
        }
        return !this.hasError;
    }
    

    conflictCheckHelper(){
        this.allAdverseParties = '';
        this.allRelatedParties = '';
        this.allContributors = '';
        this.allKeywords = '';
        this.adversePartiesPills.forEach(option => {
            this.allAdverseParties = this.allAdverseParties === '' ? this.allAdverseParties = option.label : this.allAdverseParties + ',' + option.label;
        });

        this.relatedPartiesPills.forEach(option => {
            this.allRelatedParties = this.allRelatedParties === '' ? option.label : this.allRelatedParties + ',' + option.label;
        });
        this.contribtorsPills.forEach(option => {
            this.allContributors = this.allContributors === '' ? option.label : this.allContributors + ',' + option.label;

        });
        this.keywordsPills.forEach(option => {
            this.allKeywords = this.allKeywords === '' ? option.label : this.allKeywords + ',' + option.label;
        });
    }

   async helperMethod(){
        this.conflictCheckHelper();
        this.showSpinner = true;
        var multiSelect = this.allValues.join(';');
        const fields = {};
        fields[CLIENT_FIELD.fieldApiName] = this.existingClientName;
        fields[AREA_OF_LAW_FIELD.fieldApiName] = this.areaOfLaw;
        fields[MATTER_NAME_FIELD.fieldApiName] = this.matterName;
        fields[REFERENCE_NUMBER_FIELD.fieldApiName] = this.referenceNumber;
        fields[TRANSFIRM_ANOTHER_FIRM_FIELD.fieldApiName] = this.v_MatterTransferFromFirmSelected;
        fields[ADVERSE_PARTIES_FIELD.fieldApiName] = this.allAdverseParties; //this.v_AdverseParties;
        fields[RELATED_PARTIES_FIELD.fieldApiName] = this.allRelatedParties; //this.v_RalatedParties;
        fields[CLIENT_RELATIONSHIP_FIELD.fieldApiName] = multiSelect;
        fields[CONTRIBUTORS_FIELD.fieldApiName] = this.allContributors; //this.contributors;
        fields[KEYWORDS_FIELD.fieldApiName] = this.allKeywords; //this.keywords;
        fields[DESCRIPTION_FIELD.fieldApiName] = this.v_BreifDescription;
        // Default fields to populate
        //fields[CLIENT_NAME_FIELD.fieldApiName] = this.clientName;
        fields[CCFIELD_FIELD.fieldApiName] = 'Conflict Check Skipped'; //'Submitted';
        fields[NEW_CLIENT_FIELD.fieldApiName] = this.isClientCreated;

        console.log('this.fields', fields);
        const recordInput = { apiName: CONFLICT_CHECK_OBJECT.objectApiName, fields };
        const ccRecord = await createRecord(recordInput);
        if (ccRecord.id != null) {
            this.ccRecordId = ccRecord.id;
            if(!this.skipAndEngage){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.RECORD_CREATE_SUCCESS_MESSAGE,
                        variant: 'success',
                    }),
                );
            }
            
            this.showSpinner = false;

            this.dispatchEvent(new RefreshEvent());
            this.showModal = false;
            this.isShowEngagementModal = true;
            this.isDisignIntakeForm = this.areaOfLaw == 'Design' ? true : false;
            this.isPatentIntakeForm = this.areaOfLaw == 'Patent' || this.areaOfLaw == 'Post Grant Proceeding'  ? true : false;
            this.isTrademarkIntakeForm = this.areaOfLaw == 'Trademark' ? true : false;
            this.isAgreementIntakeForm = this.areaOfLaw == 'Agreement' ? true : false;
            this.isCopyrightIntakeForm = this.areaOfLaw == 'Copyright' ? true : false;
            this.isDisputeIntakeForm = (this.areaOfLaw == 'Opposition' || this.areaOfLaw ==  "Due Diligence" || this.areaOfLaw ==  "Litigation" || this.areaOfLaw ==  "Opinion" || this.areaOfLaw ==  "Cancellation Action")  ? true : false;
            this.isGMIntakeForm = (this.areaOfLaw == 'Counseling' || this.areaOfLaw == 'Discipline' || this.areaOfLaw == 'Board of Governors' || this.areaOfLaw == 'Bankruptcy') ? true : false;
            if(this.areaOfLaw == 'Trademark'){
                this.modalName = 'Trademark';
                this.openApplicationIntakeForm(this.clientId);
            }else if(this.areaOfLaw == "Patent" || this.areaOfLaw == 'Post Grant Proceeding' ){
                this.modalName = "Patent";
                 this.openApplicationIntakeForm(this.clientId);
            }else if(this.areaOfLaw ==  "Design"){
                this.modalName =  "Design";
            }else if(this.areaOfLaw ==  "Copyright"){
                this.modalName =  "Copyright";
            }else if(this.areaOfLaw ==  "Agreement"){
                this.modalName =  "Agreement";
            }else if(this.areaOfLaw ==  "Opposition" || this.areaOfLaw ==  "Due Diligence" || this.areaOfLaw ==  "Litigation" || this.areaOfLaw ==  "Opinion" || this.areaOfLaw ==  "Cancellation Action" ){
                this.modalName =  "Dispute/Opposition";
            }else if(this.areaOfLaw == 'Counseling' || this.areaOfLaw == 'Discipline' || this.areaOfLaw == 'Board of Governors' || this.areaOfLaw == 'Bankruptcy'){
                this.modalName = "General Matter";
                this.openApplicationIntakeForm(this.clientId);
            }
            
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There is something wrong while creating the Conflict check record. Please contact to your Salesforce Adminitrator.',
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
        }
    }

     openApplicationIntakeForm(clientId){
        try {

            console.log('if conditions :'+this.isConsoleNavigation+' '+this.enclosingTabId);
            console.log('intake form '+this.isPatentIntakeForm);
            // if (!this.isConsoleNavigation || !this.enclosingTabId) {
            //     return;
            // }
             if (this.isConsoleNavigation) {

            if (this.isPatentIntakeForm) {
                // let compDefinition = {
                //     componentDef: "c:assetIntakeForm",
                //     attributes:{
                //         "clientId": this.clientId,
                //        // "conflictCheckId":  this.conflictCheckSelectedRecordId,
                //        // "clientReferenceNumber": this.selectedClientReferenceNumber,
                //         "clientGroupNumber": this.selectedClientGroupNumber,
                //         "isPatent":true
                //     }
                // };
            
                // // Base64 encode the compDefinition JS object
                // let encodedDef = btoa(JSON.stringify(compDefinition));
                // let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'Patent Intake Form' };
                // openSubtab(this.enclosingTabId, params);
                 this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Asset_Intake_Form'
                        },
                        state: {
                            c__clientId: this.clientId,
                            c__conflictCheckId:  this.conflictCheckSelectedRecordId,
                            c__clientReferenceNumber: this.selectedClientReferenceNumber,
                            c__clientGroupNumber: this.selectedClientGroupNumber,
                            c__matterTitle : this.matterName,
                            c__isPatent:true,
                        },
                        focus: true,
                        label: 'Asset Intake Form'
                    });
            } 
            else if (this.isTrademarkIntakeForm){
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'Asset_Intake_Form'
                    },
                    state: {
                        c__clientId: this.clientId,
                        c__conflictCheckId:  this.conflictCheckSelectedRecordId,
                        c__clientReferenceNumber: this.selectedClientReferenceNumber,
                        c__clientGroupNumber: this.selectedClientGroupNumber,
                        c__matterTitle : this.matterName,
                        c__isTrademark:true,
                    },
                    focus: true,
                    label: 'Asset Intake Form'
                });
                // let compDefinition = {
                //     componentDef: "c:assetIntakeForm",
                //     attributes:{
                //         "clientId": this.selectedClientId,
                //         "conflictCheckId":  this.conflictCheckSelectedRecordId,
                //         "clientReferenceNumber": this.selectedClientReferenceNumber,
                //         "isTrademark":true
                //     }
                // };
            
                // // Base64 encode the compDefinition JS object
                // let encodedDef = btoa(JSON.stringify(compDefinition));
                // let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'Trademark Intake Form' };
                // openSubtab(this.enclosingTabId, params);           

            }
            else if (this.isGMIntakeForm){
                    // let compDefinition = {
                    //     componentDef: "c:assetIntakeGeneralMatter",
                    //     attributes:{
                    //         "clientId": this.selectedClientId,
                    //         "conflictCheckId":  this.conflictCheckSelectedRecordId,
                    //         "clientReferenceNumber": this.selectedClientReferenceNumber,
                    //         // "isGeneralMatter":true
                    //     }
                    // };
                
                    // // Base64 encode the compDefinition JS object
                    // let encodedDef = btoa(JSON.stringify(compDefinition));
                    // let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'General Matter Intake Form' };
                    // openSubtab(this.tabId, params);    
                    
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Asset_Intake_General_Matters'
                        },
                        state: {
                            c__clientId: this.clientId,
                            c__conflictCheckId:  this.conflictCheckSelectedRecordId,
                            c__clientReferenceNumber: this.selectedClientReferenceNumber,
                            c__matterTitle : this.matterName
                        },
                        focus: true,
                        label: 'Asset Intake Form'
                    });

                }
            // else if (this.isDisputeIntakeForm){
            //     let compDefinition = {
            //         componentDef: "c:assetIntakeForm",
            //         attributes:{
            //             "clientId": this.selectedClientId,
            //             "conflictCheckId":  this.conflictCheckSelectedRecordId,
            //             "clientReferenceNumber": this.selectedClientReferenceNumber,
            //             "isDispute":true
            //         }
            //     };
            
            //     // Base64 encode the compDefinition JS object
            //     let encodedDef = btoa(JSON.stringify(compDefinition));
            //     let params = {url:"/one/one.app#" + encodedDef,icon:'utility:edit_form', label:'Dispute Intake Form' };
            //     openSubtab(this.enclosingTabId, params);                
            // }
             }
        }
        catch (err) {
            alert('JS Error : ccNewRequest : openApplicationIntakeForm');
        } 
    
     }
}