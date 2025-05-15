import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { Redux } from 'c/lwcRedux';
import { publish, subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

import FORM_FACTOR from '@salesforce/client/formFactor';
import maxvalDebug from "@salesforce/customPermission/maxvalDebug";
import searchPatentFamilyRecords from '@salesforce/apex/assetIntakeFormController.searchPatentFamilyRecords';
import getDraftPatentFamilyRecords from '@salesforce/apex/assetIntakeFormController.getDraftPatentFamilyRecords';
import getFieldSetColumns from '@salesforce/apex/assetIntakeFormController.getFieldSetColumns';

export default class AssetIntakeFormContainer extends NavigationMixin(Redux(LightningElement)) {

    @track clientId = 'a0TWr000007QKlRMAW'; // TODO: Change this to API name
    @track isPatent = true;                 // TODO: Change this to API name

    /* Variables for Patent */
    @track inputValuePatentFamily = '';
    @track patentFamilyRecords = [];
    @track showDropdownPatentFamily = false;
    @track noResults = false;

    @api mobilePhone;
    @track showPersistentNotification;

    @wire(MessageContext)
    messageContext;
    urlParameters;
    debugText;
    count = 0;
    desktop;
    tabletOrPhone;

    isMobileApp = false;
    renderPersister = false;
    flowStateCalloutFlag = false;

    @api
    get recordId() {
        return this.clientId;
    }

    get debugContent() {
        let displayedInfo = '';
        // TODO: Code to fetch the Conflict Check Details and display them

        return displayedInfo;
    }

    set recordId(value) {
        this.debugText += 'objId in setter ' + value + '\n';
        this.clientId = value;
        if (FORM_FACTOR !== 'Large' && this.props.client && this.clientId !== this.props.client.id) {
            window.location.reload();
        }
    }

    @api get assetIntakeParameters() {
        return this.urlParameters;
    }

    set assetIntakeParameters(value) {
        this.urlParameters = value;
        if (this.props && Object.keys(this.props).length > 0) {
            this.loaded = false;
            if (this.count == 0) {
                this.debugText += 'loading Asset Intake Form from setter...\n';
                this.loadAssetIntakeFlow();
            } else {
                window.location.reload();
            }
        }
    }

    get displayDebugContent() {
        return maxvalDebug ? true : false;
    }

    mapStateToProps(state) {
        return {
            pages: state.pages,
            selectedClient: state.selectedClient,
            progressSteps: state.progressSteps,
            stepGrps: state.stepGroups,
            client: state.client,
        };
    }
    mapDispatchToProps() {
        return { changePage, addJourneySteps, addStepGroups, updateJourneyType, refreshJourneyPage, changePage2, disablePage, addSearchResults, updateClientId, resetReducers, updateValidateResponse, setAssetIntakeParameters, updateJourneyTypePage, addApplicantAddress };
    }

    async connectedCallback() {
        console.log('inside connectedcallback');
        await super.connectedCallback();
        this.debugText += 'objId: ' + this.recordId + '\n';
        if (FORM_FACTOR === 'Large') {
            this.desktop = true;
            this.tabletOrPhone = false;
        } else {
            this.desktop = false;
            this.tabletOrPhone = true;
        }
        this.debugText += 'Loading Intake Form connected callback\n';
        console.log("Persistent Notification: ", this.showPersistentNotification)
        this.loadAssetIntakeFlow();
    }

    async loadAssetIntakeFlow() {
        //If recordId !=props.client.Id (client.Id should not be null)
        //If it is null, Send a new reset action;
        this.count++;
        if (!this.props.client || !this.props.client.id || this.recordId !== this.props.client.id) {
            this.debugText += 'Resetting reducers...\n';
            this.props.resetReducers();
            this.props.client.id = this.recordId;

        }

        if (this.flowName && this.flowName === 'PATENT_INTAKE_FORM') {
            this.props.updateJourneyTypePage('Patent Intake Form');
        }

        this.debugText += 'Set Journey Type...\n';
        this.setJourneyType(this.flowName);
        this.debugText += 'Add Journey Steps...\n';
        this.props.addJourneySteps(this.journeyResults);
        this.debugText += 'Refresh Journey Page...\n';
        this.props.refreshJourneyPage(this.journeyResults);
        this.debugText += 'Get Progress Bar Path...\n';
        this.stepGroups = this.getProgressBarPath(this.journeyResults);
        this.debugText += 'Add Step Groups...\n';
        this.props.addStepGroups(this.stepGroups);
        this.debugText += 'Step Groups Added...\n';
    }

    getProgressBarPath(result) {
        let stepGrp;
        let progressPath = [];
        let rootKey;
        for (var prop in result) {
            if (prop == this.props.client.journeyType) {
                rootKey = prop;
                for (var key in result[rootKey]) {
                    for (var key1 in result[rootKey][key]) {
                        if (key1 == "StepGroup") {
                            stepGrp = result[rootKey][key][key1];
                            if (progressPath.findIndex(a => a === stepGrp) === -1) {
                                progressPath.push(stepGrp);
                            }
                        }
                    }
                }
                break;
            }
        }

        return progressPath;
    }

    setJourneyType(action) {
        switch (action) {
            case 'PATENT_INTAKE_FORM':
                this.props.updateJourneyType('Patent Intake Form');
                break;
            case 'TRADEMAR_INTAKE_FORM':
                this.props.updateJourneyType('Trademark Intake Form');
                break;
            default:
                this.props.updateJourneyType('Generic Intake Form');
        }
    }

    get activePage() {
        let currentPage;
        let pages = this.props.pages;
        for (var key in pages.data) {
            if (key === this.props.client.journeyType) {
                for (var key1 in pages.data[key]) {
                    for (var key2 in pages.data[key][key1]) {
                        if (key2 === 'active' && pages.data[key][key1][key2] == true) {
                            currentPage = key1;
                            break;
                        }
                    }
                }
            }
        }

        return currentPage;
    }



}