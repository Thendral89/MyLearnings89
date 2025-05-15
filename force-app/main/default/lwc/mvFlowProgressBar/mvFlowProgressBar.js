import { LightningElement, api, wire, track } from 'lwc';
import { Redux } from 'c/lwcRedux';
// import { changePage, changePage2 } from 'c/mvActions';
import { publish, subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import mvPathChannel from '@salesforce/messageChannel/mvPath__c';
import FORM_FACTOR from '@salesforce/client/formFactor';
import * as mvUtils from 'c/mvUtils';
import mvFlowProgressBarStyle from '@salesforce/resourceUrl/mvFlowProgressBar';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class MvFlowProgressBar extends Redux(LightningElement) {

    selectedStep = '';
    steps = [];
    tempSteps = [];
    subscription;
    currentPage;
    showProgressBar = true;
    nextStepGroup;
    nextStep;
    isInit = true;
    stGroup;
    isMobileApp = false;

    @api init;
    @api flowName;
    @track isIntakeFlow = true;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        console.log('Connected Call Back');
        super.connectedCallback();
        this.subscribeToMessageChannel();
        if (FORM_FACTOR == 'Medium' || FORM_FACTOR == 'Small') {
            this.isMobileApp = true;
        }
        //console.log('progressSteps redux state -->' + JSON.stringify(this.props.progressSteps));
        this.steps = this.props.stepGroups;
        //console.log('progressSteps Props>' + JSON.stringify(this.props));
        this.currentPage = mvUtils.getCurrentPage(this.props);
        //console.log('in progressbar curr page....' + this.currentPage);
        this.stGroup = mvUtils.getStepNavigation(this.props, this.currentPage, false);
        //console.log('in progressbar tempSteps....' + JSON.stringify(this.stGroup));
        this.getStepName(this.stGroup);
        if (this.flowName === 'PATENT_INTAKE_FLOW') {
            this.isIntakeFlow = true;
            this.showProgressBar = true;
        }
        else {
            this.showProgressBar = true;
        }
        Promise.all([
            loadStyle(this, mvFlowProgressBarStyle)
        ]).then(() => {
            window.console.log('Files loaded.');
        }).catch(error => {
            window.console.error("Error" + JSON.stringify(error));
        });
    }

    mapStateToProps(state) {
        return {
            pages: state.pages,
            customer: state.customer,
            progressSteps: state.progressSteps,
            stepGroups: state.stepGroups,
            selectedClient: state.selectedClient
        };
    }

    mapDispatchToProps() {
        return { changePage, changePage2 };
    }



    renderedCallback() {
        console.log('init in progressbar..' + this.init);
        let items = this.template.querySelectorAll(`[data-id]`);
        items.forEach(element => {
            console.log('selectedStep--->', element.textContent);
            const selected = element.textContent.trim();
            if (selected === this.selectedStep) {
                element.classList.add('selected');
            }
            else {
                element.classList.remove('selected');
            }
        });
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                mvPathChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        window.scrollTo(0, 0);
        console.log('inside handle message progressbar' + JSON.stringify(message));
        //console.log('handleMessage bar is..' + JSON.stringify(this.props.pages));
        this.currentPage = mvUtils.getCurrentPage(this.props);
        console.log('handleMessage progressbar curr page....' + this.currentPage);
        this.stGroup = mvUtils.getStepNavigation(this.props, this.currentPage, false);
        console.log('handleMessage progressbar tempSteps....' + JSON.stringify(this.stGroup));
        this.getStepName(this.stGroup);
        this.showProgressBar = true;
    }

    getStepName(stepArray) {
        for (var i = 0; i < stepArray.length; i++) {
            if (stepArray[i].key == 'StepGroup') {
                console.log('StepArray....' + stepArray[i].value);
                this.nextStepGroup = stepArray[i].value;
                this.selectedStep = this.nextStepGroup;
                break;
            }
        }
    }


    handleStep(event) {
        var currstep = this.selectedStep;
        let curStepindex = this.steps.indexOf(currstep);
        var newstep = event.target.value;
        let newStepindex = this.steps.indexOf(newstep);
        // console.log('Curr Step ',this.selectedStep);
        // console.log('New Step ',event.target.value);
        // console.log('Curr Index ',curStepindex);
        // console.log('New Index ',newStepindex);

        // if (newStepindex > curStepindex) {
        //     this.selectedStep = currstep;
        // } else {
        if (newStepindex <= curStepindex) {
            this.currentPage = mvUtils.getCurrentPage(this.props);
            mvUtils.getPageByStepGroup(this.props, this.currentPage, newstep);
        } else {
            this.selectedStep = currstep;
        }
        //this.selectedStep = newstep;
        //this.currentPage = mvUtils.getCurrentPage(this.props); 
        //mvUtils.getPageByStepGroup(this.props,this.currentPage,newstep);
        //}
        //this.props.changePage2(newPage, currPage, this.props.customer.journeyType);
    }

}