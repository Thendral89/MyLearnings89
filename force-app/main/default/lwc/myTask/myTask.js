import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getTaskDataApex, getViewsDataApex, getAdditionalFieldsLabelApex} from 'c/myTaskUtils'
import USER_ID from '@salesforce/user/Id';
import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    openSubtab,
    getTabInfo
} from 'lightning/platformWorkspaceApi'


export default class MyTask extends LightningElement {
    @api headerLabel = 'My Task';
    @api headerLabelDeligated='Delegated';
    @api hideRelated;
    @api hideLabel;
    @api hideStatus;
    @api hidePriority;
    @api sortBy;
    @api sortType;
    @api taskPerPage;
    @api additionalFieldOne;
    @api additionalFieldTwo;
    @api defaultView;
    @api panelOne;
    @api panelTwo;
    @api panelThree;
    @api panelFour;

    @track taskList = [];
    @track taskListToDisplay = [];
    @track selectedTasks = [];
    @track defaultFilterOptions = [];
    @track additionalFieldLabels;
    @track filterVal;

    @track headerLabelActive = 'active'; 
    @track headerLabelDelegatedActive = '';
    @track clickedHeaderLabel = 'Owner';
    @track createOrAssignedLabel;
    @track createOrAssignedField;
    
    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;

    selectedView;
    currentPage;
    showSpinner = false;
    massActionChecked = false;
    showNewModal = false;
    selectedTaskId;

    get taskCount() {
        console.log('this.taskList.length in get taskcount::',this.taskList.length);
        return this.taskList ? this.taskList.length : 0;
    }

    get massActionsVisible() {
        return this.selectedTasks && this.selectedTasks.length > 0
    }

    get selectedViewLabel() {
        if(!this.selectedView) return 'Custom';

        const findResult = this.defaultFilterOptions.find(ele => {
            return ele.value === this.selectedView;
        })
        
        return findResult ? findResult.label : 'Custom';
    }

    get totalPage() {
        return Math.ceil(this.taskCount/this.taskPerPage);
    }

    get firstPageDisabled () {
        return this.currentPage === 1 || this.currentPage === 0
    }

    get previousDisabled () {
        return this.currentPage === 1 || this.currentPage === 0
    }

    get nextDisabled () {
        return this.currentPage === this.totalPage || this.totalPage === 0
    }

    get lastPageDisabled () {
        return this.currentPage === this.totalPage || this.totalPage === 0
    }

    get additionalFieldOneLabel() {
        return (this.additionalFieldOne && this.additionalFieldOne !== 'none' && this.additionalFieldLabels) ? this.additionalFieldLabels[this.additionalFieldOne] : false
    }

    get additionalFieldTwoLabel() {
        return (this.additionalFieldTwo && this.additionalFieldTwo !== 'none' && this.additionalFieldLabels) ? this.additionalFieldLabels[this.additionalFieldTwo] : false
    }

    connectedCallback() {
        this.initializeComponent();
        Promise.all([
            this.getViewsData(),
            this.getAdditionalFieldsLabel(),
            this.getTaskData()
        ]).then(res => {
            console.log('in success');
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            console.log('in error',error);
        })
        
    }

    initializeComponent() {
        this.showSpinner = true;
        this.selectedView = this.defaultView;
        if (this.clickedHeaderLabel === 'Owner') {
            this.filterVal = `OwnerId = '${USER_ID}'`;
            this.createOrAssignedField ='CreatedBy.Name';
            this.createOrAssignedLabel = 'Created By';
        } else if (this.clickedHeaderLabel === 'CreatedBy') {
            this.filterVal = `CreatedById = '${USER_ID}'`;
            this.createOrAssignedField ='Owner.Name';
            this.createOrAssignedLabel = 'Assigned To';
        }
    //    this.filterVal = '';
        this.currentPage = 1;

        if(this.template.querySelector('c-my-task-filter')) {
            this.template.querySelector('c-my-task-filter').resetFilters();
        }

        const self = this;
        setTimeout(() => {
            try {
                (self.template.querySelectorAll('c-my-task-highlighted-panel') || []).forEach(ele => {
                    ele.refresh();
                });
            
            } catch (error) {
                console.log('error---',error.message);
            }   
        }, 100);
    }

    handleDefaultFilterSelect(event) {
        this.selectedView = event.detail.value;
        this.getTaskData();

    }

    handleApplyFilter(event) {
       // this.filterVal = event.detail.queryFilter;
       if (this.filterVal) {
        this.filterVal = `${this.filterVal} AND ${event.detail.queryFilter}`;
        }else {
            this.filterVal = event.detail.queryFilter;
        }

        this.handleRefresh();
    }

    handleRefresh(event) {
        console.log(122);
        
        this.showSpinner = true;
        Promise.all([
            this.getTaskData()
        ]).then(res => {
            console.log('in success');
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            console.log('in error',error);
        })

        const self = this;

        setTimeout(() => {
            try {
                (self.template.querySelectorAll('c-my-task-highlighted-panel') || []).forEach(ele => {
                    ele.refresh();
                });
            
            } catch (error) {
                console.log('error---',error.message);
            }   
        }, 100);

    }

    handleClick(event) {
        const action = event.currentTarget.dataset.action;

        switch (action) {
            case 'refresh':
                this.connectedCallback();
                break;
            case 'new-task':
            this.showNewModal = true;
                break;
        
            default:
                break;
        }
    }

    handleTaskSelected(event) {
        this.selectedTasks = event.detail.selectedTasks;
    }

    handleMassActionChange(event) {
        event.stopPropagation();
        const checked = event.target.checked;
        this.massActionChecked = checked;
        const myTaskTable = this.template.querySelector('c-my-task-table');
        if(myTaskTable) {
            myTaskTable.selectAll(checked);
        }
    }

    handlePanelSelect(event) {
        const panel = event.currentTarget.dataset.panel;

        this.selectedView = panel;
        this.handleRefresh();

        // if(this.template.querySelector('c-my-task-filter')) {
        //     this.template.querySelector('c-my-task-filter').resetFilters();
        // }
    }

    handleNavigation(event) {
        const action = event.currentTarget.dataset.action;

        switch (action) {
            case 'first':
                this.currentPage = 1;
                break;
            case 'previous':
                this.currentPage -= 1;
                break;
            case 'next':
                this.currentPage += 1;
                break;
            case 'last':
                this.currentPage = this.totalPage;
                break;
            default:
                break;
        }
        this.selectedTasks = [];
        this.massActionChecked = false;
        this.evaluateTaskListToDisplay();
    }

    handleNewTaskClose() {
        this.showNewModal = false;
        this.selectedTaskId = '';
        this.handleRefresh();
    }

    getTaskData() {

        console.log('USER_ID::',USER_ID);
        console.log('clickedHeaderLabel in gettaskdata:',this.clickedHeaderLabel);
        return new Promise(async (resolve, reject) => {
            const params = {
                additionalFieldList: [this.additionalFieldOne, this.additionalFieldTwo, this.createOrAssignedField],
                filterVal: this.filterVal,
                selectedView: this.selectedView,
                sortBy: this.sortBy,
                sortDirection: this.sortType
            };

            console.log('params:',JSON.stringify(params));
            
            const resp = await getTaskDataApex(params);
            if(resp && resp.isSuccess) {
                const data = resp.data;
                this.taskList = data;
                this.currentPage = this.taskList.length > 0 ? 1 : 0;
                this.selectedTasks = [];
                this.massActionChecked = false;
                this.evaluateTaskListToDisplay();
                resolve();
                console.log('this.taskList.length in getTaskDataApex',this.taskList.length);
            } else {
                this.showToast('Error!!', resp.errorMessage, 'error');
                reject(resp.errorMessage);
            }
        }); 
    }

    getAdditionalFieldsLabel() {
        return new Promise(async (resolve, reject) => {
            const resp = await getAdditionalFieldsLabelApex({additionalFieldOne: this.additionalFieldOne, additionalFieldTwo: this.additionalFieldTwo});
        
            if(resp && resp.isSuccess) {
                const data = resp.data;
                this.additionalFieldLabels = data;
                resolve();
            } else {
                this.showToast('Error!!', resp.errorMessage, 'error');
                reject(resp.errorMessage);
            }
        });
    }

    getViewsData() {
        return new Promise(async (resolve, reject) => {
            const resp = await getViewsDataApex();
        
            if(resp && resp.isSuccess) {
                const data = resp.data;
                this.defaultFilterOptions = data;
                resolve();
            } else {
                this.showToast('Error!!', resp.errorMessage, 'error');
                reject(resp.errorMessage);
            }
        });
        
    }

    evaluateTaskListToDisplay() {
        if(this.taskCount > 0) {
            this.taskListToDisplay = this.taskList.slice((this.currentPage - 1) * Number(this.taskPerPage), this.currentPage === this.totalPage ? this.taskCount : this.currentPage * Number(this.taskPerPage))
            return;
        }

        this.taskListToDisplay = [];
        
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({title, message, variant});
        this.dispatchEvent(event);
    }

    handleEditEvent(event) {
        let taskId = event.detail.taskId;
        this.selectedTaskId = taskId;
        this.showNewModal = true;
    }

    handleHeaderLabelClick() {
        this.headerLabelActive = 'active';
        this.headerLabelDelegatedActive = '';
        this.clickedHeaderLabel = 'Owner';
        this.filterVal = `OwnerId = '${USER_ID}'`;
        this.createOrAssignedField ='CreatedBy.Name';
        this.createOrAssignedLabel = 'Created By';
        this.handleRefresh();
    }

    handleHeaderLabelDelegatedClick() {
        this.headerLabelActive = '';
        this.headerLabelDelegatedActive = 'active';
        this.clickedHeaderLabel = 'CreatedBy';
        this.filterVal = `CreatedById = '${USER_ID}'`;
        this.createOrAssignedField ='Owner.Name';
        this.createOrAssignedLabel = 'Assigned To';
        this.handleRefresh();
    }

    get myTasktabClass() {
        return this.headerLabelActive ? 'tab active header_label' : 'tab header_label';
    }

    get delegatedTabClass() {
        return this.headerLabelDelegatedActive ? 'tab active header_label' : 'tab header_label';
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