import { LightningElement, wire, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import FA from "@salesforce/resourceUrl/FA";
import { RefreshEvent, registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchRecords from '@salesforce/apex/serviceRepositoryUtils.fetchRecords';
import getObjectPermission from '@salesforce/apex/mvLawfirmUtilities.getObjectPermission';
import getUserTimezoneOffset from '@salesforce/apex/mvLawfirmUtilities.getUserTimezoneOffset';
import getUserLocale from '@salesforce/apex/mvLawfirmUtilities.getUserLocale';
import getCurrentUserProfile from '@salesforce/apex/mvLawfirmUtilities.getCurrentUserProfile';
import deleteRecordById from '@salesforce/apex/mvRecordDeletionController.deleteRecordById'
import downloadDocuments from '@salesforce/apex/cmpAPiManagDocumentCtrl.DownloadDocuments';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account'; 
import COUNTRY_CODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import STATE_CODE_FIELD from '@salesforce/schema/Account.BillingStateCode';

const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100, 500];

const TABULATOR_BUTTON_ID_PREFIX = 'myButton';

export default class LwcMvRelatedList extends NavigationMixin(LightningElement) {
    @api serviceRepositoryName;
    @api serviceRepositoryWhereClauseReplacer = '';
    @api label = '';
    @api recordId;
    @api objectApiName;
    @api hideAdd;
    @api hideEdit;
    @api hideDelete;

    @api addButtonOverriddenByImanage = false;

    showImanageAdd = false;

    childObjectApiName;
    childObjectLabel;
    lookupField;
    actionFields;
    currentMode;
    userProfile;
    isDckMagmtUser = false;
    serviceRespositoryResponse;

    instanceId = "cmp-" + Math.random().toString(36).substring(2, 9);

    refreshHandlerID;
    isLoadingFirstTime = true;

    currentFeatureSettings = {

        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR
    };

    @track parentFields = ['Id'];

    parentRecord;
    @wire(getRecord, { recordId: '$recordId', fields: '$parentFields'  })
    parentRecordWired({ error, data }) {
        if (data) {
            this.parentRecord = data;
        } else if (error) {
            console.error('Error loading parentRecord', error);
            console.error(JSON.stringify(error));
            console.error('parentFields ' + JSON.stringify(this.parentFields));
        }
    }

    @wire(getCurrentUserProfile)
    wiredUserProfile({ error, data }) {
        if (data) {
            this.userProfile = data; 
            console.log('user profile--->',JSON.stringify(this.userProfile));
            if(this.userProfile == 'MCCIP Docketing Management'){
                this.isDckMagmtUser = true;
            }
        } else if (error) {
            this.userProfile = undefined;
            console.error('Error fetching user profile: ', error);
        }
    }

    recordTypeDeveloperName;
    @track recordTypeOptions = [];
    selectedRecordTypeId;
    countryOptions = [];
    stateOptions = [];
    defaultRecordTypeId;
    selectedCountry;

    get getProvinceOptions() {
        if(this.selectedCountry){
         return this.stateOptions[this.selectedCountry] || [];
        }else{
         return [];
        }
       
    }
    get getCountryOptions() {
        return this.countryOptions;
    }

    @wire(getObjectInfo, { objectApiName: '$childObjectApiName' })
    objectInfo({ data }) {
        if (data) {
            console.log('data data recordTypes', JSON.stringify(data.recordTypeInfos));
            this.recordTypeOptions = Object.values(data.recordTypeInfos)
                .filter(rt => rt.available)
                .map(rt => ({
                    label: rt.name,
                    value: rt.recordTypeId
                }));
        }
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: COUNTRY_CODE_FIELD })
    countryPicklistValues({ data, error }) {
        if (data) {
            this.countryOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: STATE_CODE_FIELD })
    statePicklistValues({ data, error }) {
       if (!data) {
            return;
        }
        const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));

        this.stateOptions = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state.validFor[0]];
            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
    }

    timezone;
    @wire(getUserTimezoneOffset)
    wiredTimezone({ error, data }) {
        if (data) {
            console.log('Time zone received BB', data);
            this.timezone = data; // Example: "America/New_York"
        }
    }

    userlocale;
    @wire(getUserLocale)
    wiredUserLocale({ error, data }) {
        if (data) {
            console.log('User Locale received BB', data);
            this.userlocale = data.replace('_','-');
        }
    }

    objectLabel = '';

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.objectLabel = data.label;
        } else if (error) {
            console.error('Error retrieving object info:', error);
        }
    }

    showDeleteConfirmation = false;
    columns = [];

    get
    isNewRecord(){
       try{
           if( this.clientEngagementModelId ){
                return false;
           }
           else{
            return true;
           }
       }catch(err){
           console.error('JS Error ::  :: isNewRecord')
           console.error(err)
       }
    }

    handleActionClick(e, cell) {
        try {
            let target = e.target;
            let rowData = cell.getRow().getData();
            console.log('rowdata',JSON.stringify(rowData));
            const recordId = rowData.Id;
            this.clientEngagementModelId = recordId;
            
            this.actionFieldAddressToDetail = {};

            if (target.classList.contains('downloadIcon')) {
                this.handleDownload(rowData);
            }
            else if (target.classList.contains("edit-icon")) {
                this.addOrEditMessage = `Edit ${this.childObjectLabel}`;
                this.addOrEditSuccessMessage = 'Record updated';
                this.currentMode = 'edit';
                this.mapValueToActionField();
                this.setRecordTypeId();
                this.showAddEdit = true;
            } else if (target.classList.contains("delete-icon")) {
                this.showDeleteConfirmation = true;
                this.currentMode = 'delete';
            }

            /*
                
                */
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleActionClick')
            console.error(this.serializeError(err));
        }
    }

    handleDownload(rowData) {
        downloadDocuments({ PatentId: rowData.Id }) 
            .then(result => {
                console.log(
                    'downloadDocuments returned: ' + JSON.stringify(result));
                if (result) {
                    const downloadUrl = `/sfc/servlet.shepherd/version/download/${result}`;
                    console.log('Navigating to download URL:', downloadUrl);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: downloadUrl,
                        },
                    });
                } else {
                    this.showToast('Warning', 'warning', 'No file was returned.');
                }
            })
            .catch(error => {
                this.showToast('Error', 'error', 'Error downloading file: ' + error.body.message);
                console.error(error);
            });
    }

    /*handleDeleteConfirmation(){
       try{
        deleteRecord(this.clientEngagementModelId)
            .then(() => {
                this.showToast('Success', 'success', 'Record deleted successfully');
            })
            .catch(error => {
                this.showToast('Error', 'error', 'Error deleting record: ' + error.body.message);
            })
            .finally(() => {
                this.fetchClientEngagementModels();
                this.refreshOtherElementsOnThePage();
            });

        let filterdRemainingData = this.records.filter(each => {
            if (each.recordId != this.clientEngagementModelId) {
                return true;
            }
            return false;
        });
        this.updateTableData(filterdRemainingData);
        this.clientEngagementModelId = null;
        this.showDeleteConfirmation = false;
       }catch(err){
           console.error('JS Error :: LwcMvRelatedList :: handleDeleteConfirmation')
           console.error(err)
       }
    }*/

    handleDeleteConfirmation() {
    try {
        console.log('object api name===>',this.objectApiName);
        console.log('record id===>',this.clientEngagementModelId);

        const deleteAction = this.isDckMagmtUser
            ? deleteRecordById({ objectApiName: this.objectApiName, recordId: this.clientEngagementModelId })
            : deleteRecord(this.clientEngagementModelId);

        deleteAction
            .then(result => {
                let data = result;
                console.log('result delete--->',data);
                this.showToast('Success', 'success', 'Record deleted successfully');
            })
            .catch(error => {
                const errorMessage = error?.body?.message || error.message || 'Unknown error';
                this.showToast('Error', 'error', 'Error deleting record: ' + errorMessage);
            })
            .finally(() => {
                this.fetchClientEngagementModels();
                this.refreshOtherElementsOnThePage();
            });

        // Continue with UI updates regardless of deletion method
        const filteredRemainingData = this.records.filter(each => {
            return each.recordId !== this.clientEngagementModelId;
        });
        this.updateTableData(filteredRemainingData);
        this.clientEngagementModelId = null;
        this.showDeleteConfirmation = false;
    } catch (err) {
        console.error('JS Error :: handleDeleteConfirmation');
        console.error(err);
    }
}

    handleDeleteCancel(){
       try{
        this.showDeleteConfirmation = false;
       }catch(err){
           console.error('JS Error :: LwcMvRelatedList :: handleDeleteCancel')
           console.error(err)
       }
    }

    clientEngagementModelObjectPermissions;
    addOrEditMessage = `Add ${this.childObjectLabel}`;
    addOrEditSuccessMessage = '';
    records = [];
    recordsMap = {};
    showTable = false;

    async connectedCallback() {
        try {
            this.refreshHandlerID = registerRefreshHandler(this, this.refreshHandler);

            this.serviceRespositoryResponse = await fetchRecords({
                "serviceName" : this.serviceRepositoryName, 
                "recordId" : this.recordId, 
                "serviceRepositoryWhereClauseReplacer": this.serviceRepositoryWhereClauseReplacer
            });
            this.records = this.serviceRespositoryResponse.serviceOutput;
            this.convertToMap(this.records);

            console.log('this.records FROM connected callback', JSON.stringify(this.records));
            this.clientEngagementModelObjectPermission = this.serviceRespositoryResponse.objectPermission;
            this.childObjectApiName = this.serviceRespositoryResponse.childObjectApiName;
            this.childObjectLabel = this.serviceRespositoryResponse.childObjectLabel;
            this.lookupField = this.serviceRespositoryResponse.lookupField;
            this.groupBy = this.serviceRespositoryResponse.groupBy;
            this.recordTypeDeveloperName = this.serviceRespositoryResponse.recordType;
            this.prepareActionFields(this.serviceRespositoryResponse.actionFields);
            this.prepareColumns();

            this.showTable = true;
            this.isLoadingFirstTime = false;

            document.addEventListener("click", this.handleTabulatorAddButtonClick);
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: connectedCallback');
            console.error(err);
            console.error(JSON.stringify(err));
            console.error(this.serializeError(err));
        }
    }

    prepareActionFields(data){
        try{
        let actionFields = (data ? JSON.parse(data) : []);
        let parentFields = [...this.parentFields];

        let output = [];
        actionFields?.forEach(e => {
            let newVal = {
                "fieldApiName":"",
                "required":false,
                "defaultValue": null
            };
            if(e.type === 'address'){
                e.isAddress = true;

                let addressFieldApiName = e.fieldApiName;
                let street = addressFieldApiName.replace('__c', '__Street__s');
                let city = addressFieldApiName.replace('__c', '__City__s');
                let countryCode = addressFieldApiName.replace('__c', '__CountryCode__s');
                let postalCode = addressFieldApiName.replace('__c', '__PostalCode__s');
                let stateCode = addressFieldApiName.replace('__c', '__StateCode__s');
                let country = addressFieldApiName.replace('__c', '__Country__s');
                //let postalCode = addressFieldApiName.replace('__c', '__Postal__s');
               // let stateCode = addressFieldApiName.replace('__c', '__State__s');
                let latitude = addressFieldApiName.replace('__c', '__Latitude__s');
                let longitude = addressFieldApiName.replace('__c', '__Longitude__s');
                let geocodeAccuracy = addressFieldApiName.replace('__c', '__GeocodeAccuracy__s');

                e.addressObject = {
                    "street" : street,
                    "city" : city,
                    //"countryCode" : countryCode,
                    "country" : country,
                    "postalCode" : postalCode,
                    "stateCode" : stateCode,
                    "latitude" : latitude,
                    "longitude" : longitude,
                    "geocodeAccuracy" : geocodeAccuracy
                }
                console.log('Address object',e.addressObject);
            }

            Object.assign(newVal, e);

            if(e.defaultFromParentField){
                if(e.type == 'address'){
                    parentFields.push( this.objectApiName + '.' + e.defaultFromParentField.replace('__c', '__Street__s'));
                    parentFields.push( this.objectApiName + '.' + e.defaultFromParentField.replace('__c', '__City__s'));
                    parentFields.push( this.objectApiName + '.' + e.defaultFromParentField.replace('__c', '__PostalCode__s'));
                    parentFields.push( this.objectApiName + '.' + e.defaultFromParentField.replace('__c', '__StateCode__s'));
                    parentFields.push( this.objectApiName + '.' + e.defaultFromParentField.replace('__c', '__CountryCode__s'));
                }
                else{
                    parentFields.push( this.objectApiName + '.' + e.defaultFromParentField)
                }
                
            }

            output.push(newVal);
        })
        this.actionFields = output;
        this.parentFields = parentFields;

        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: prepareActionFields');
            console.error(this.serializeError(err));
        }
    }

    actionFieldAddressToDetail = {};

    addressInputChange(event){
       try{
        const fieldApiName = event.target.dataset.fieldapiname;
        console.log('fieldApiName ', fieldApiName);
        const address = {};

        address.street = event.detail.street;
        address.city = event.detail.city;
       // address.postal = event.detail.postal;
        address.postalCode = event.detail.postalCode;
        
        address.state = event.detail.province;
        address.country = event.detail.country;
        this.selectedCountry = event.detail.country;

        const actionFieldAddressToDetail = this.actionFieldAddressToDetail;
        actionFieldAddressToDetail[ fieldApiName ] = address;

        this.actionFieldAddressToDetail = actionFieldAddressToDetail;
       }catch(err){
           console.error('JS Error :: LwcMvRelatedList :: addressInputChange')
           console.error(err)
       }
    }

    handleTabulatorAddButtonClick = this.tabulatorAddButtonClick.bind(this);

    tabulatorAddButtonClick(event){
       try{
        if (event.target.id === (TABULATOR_BUTTON_ID_PREFIX + this.instanceId)) {
            this.handleAdd();
        }
       }catch(err){
           console.error('JS Error :: LwcMvRelatedList :: tabulatorAddButtonClick')
           console.error(err)
       }
    }

    fetchObjectPermissions(){
       try{
        const promise = getObjectPermission({ 'objectApiName': 'SymphonyLF__Client_Engagement_Model__c' });
        promise.then( response => {
               try{
                this.clientEngagementModelObjectPermission = response;
               }catch(err){
                   console.error('JS Error in Server callback :: LwcMvRelatedList :: fetchObjectPermissions');
               }
           })
           .catch( error => {
               console.error('Server Error :: LwcMvRelatedList :: fetchObjectPermissions :: apexMethod => getObjectPermission');
               console.error(JSON.stringify(error));
           });

           return promise;
       }catch(err){
           console.error('JS Error :: LwcMvRelatedList :: fetchObjectPermissions')
           console.error(err)
       }
    }

    prepareColumns() {
        try {
            let columns = JSON.parse( this.serviceRespositoryResponse.serviceLabels );
            console.log('1st columns mv related list --->',columns);
            columns = this.columnsFormatting(columns);
            console.log('1st columns mv related list --->',columns);
            let action = {
                title: "actions", field: "actions", hozAlign: "center", width: "75", resizable: false, headerSort: false,frozenRight: true, formatter: (cell, formatterParams) => {
                    let cellData = cell.getRow().getData();
                    let cellId = cell.getRow().getData()['Id'];
                    let formattedHtml = ` <div class="action-icons"> `

                    if(this.addButtonOverriddenByImanage){
                    //if (rowData.documentRecords && rowData.documentRecords.length > 0) {
                        formattedHtml += "<i style='width:32px;height:32px;' class='fa fa-cloud-download downloadIcon' title='Download Document'></i>";
                    //}
                    }

                    if (this.serviceRespositoryResponse.recordPermission[cellId].canEdit) {
                        if(!this.hideEdit){
                            formattedHtml += ` <i class='fa fa-edit edit-icon' title='Edit'></i>  `;
                        }
                    }

                    if (this.serviceRespositoryResponse.recordPermission[cellId].canDelete) {
                        if(!this.hideDelete){
                            formattedHtml += ` <i class='fa fa-regular fa-trash delete-icon' title='Delete'></i> `;
                        }
                    }
                    else if (this.isDckMagmtUser) {
                            formattedHtml += ` <i class='fa fa-regular fa-trash delete-icon' title='Delete'></i> `;
                    }
                    

                    formattedHtml += ` </div> `;
                    return formattedHtml;
                }
                , cellClick: (e, cell) => this.handleActionClick(e, cell)
                , titleFormatter: () => {
                    if(this.hideAdd){return ''};
                    if (this.clientEngagementModelObjectPermission.canCreate) {
                        return ` 
                    <button id="${TABULATOR_BUTTON_ID_PREFIX + this.instanceId}" class="slds-button slds-button_brand">Add</button>
                    `;
                    }
                    else {
                        return ``;
                    }
                }
                , hozAlign: "center"
                , columnHeaderVertAlign: "middle"
            };

            if(! (this.hideAdd && this.hideEdit && this.hideDelete) ){
                if (this.clientEngagementModelObjectPermission.canCreate
                    ||
                    this.clientEngagementModelObjectPermission.canEdit
                    ||
                    this.clientEngagementModelObjectPermission.canDelete
                ) {
                    columns.push(action);
                }
            }
            
            this.columns = columns;

            if(this.groupBy){
                this.currentFeatureSettings = {
                    ...this.currentFeatureSettings,
                    groupByFieldName: this.groupBy
                };
            }
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: prepareColumns');
            console.error(this.serializeError(err));
        }
    }

    get
    actionFieldsOnAddEditing(){
       try{
           let output = [...this.actionFields];
           let data = this.parentRecord;
           let dataFields = (data) ? data.fields : {};

           output.forEach(e=>{
            const addressDefaultValue = {};
            addressDefaultValue.street = '';
            addressDefaultValue.city = '';
            addressDefaultValue.postal = '';
            addressDefaultValue.state = '';
            addressDefaultValue.country = '';
            e["addressDefaultValue"] = addressDefaultValue;

            if(e.defaultFromParentField){
                e.defaultValue = dataFields[e.defaultFromParentField]?.value;

                if(e.type === 'address'){
                    console.log('e.defaultValue ', e.defaultValue);
                    console.log('e.defaultValue ', JSON.stringify(e.defaultValue));

                    const addressObject =  e["addressDefaultValue"];
                    addressObject.street = dataFields[e.defaultFromParentField.replace('__c', '__Street__s')]?.value ?? '';
                    addressObject.city = dataFields[e.defaultFromParentField.replace('__c', '__City__s')]?.value ?? '';
                    //  addressObject.postal = dataFieldspostal;
                    addressObject.postal = dataFields[e.defaultFromParentField.replace('__c', '__PostalCode__s')]?.value ?? '';
                    addressObject.state = dataFields[e.defaultFromParentField.replace('__c', '__StateCode__s')]?.value ?? '';
                    addressObject.country = dataFields[e.defaultFromParentField.replace('__c', '__CountryCode__s')]?.value ?? '';
                    this.selectedCountry = dataFields[e.defaultFromParentField.replace('__c', '__CountryCode__s')]?.value ?? null;

                    e["addressDefaultValue"] = addressObject;
                }
            }

            if(e.availableMode && Array.isArray(e.availableMode)){
                if(this.isNewRecord){
                    if(e.availableMode.includes('create')){
                        e.availableModeBoolean = true;
                    }
                    else{
                        e.availableModeBoolean = false;
                    }
                }
                else{
                    if(e.availableMode.includes('edit')){
                        e.availableModeBoolean = true;
                    }
                    else{
                        e.availableModeBoolean = false;
                    }
                }
            }
            else{
                e.availableModeBoolean = true;
            }

            if(e.sldsHideMode && Array.isArray(e.sldsHideMode)){
                if(this.isNewRecord){
                    if(e.sldsHideMode.includes('create')){
                        e.sldsHideModeClass = 'slds-hide';
                    }
                    else{
                        e.sldsHideModeClass = 'slds-show';
                    }
                }
                else{
                    if(e.sldsHideMode.includes('edit')){
                        e.sldsHideModeClass = 'slds-hide';
                    }
                    else{
                        e.sldsHideModeClass = 'slds-show';
                    }
                }
            }
            else{
                e.sldsHideModeClass = 'slds-show';
            }
           });

           return output;
       }catch(err){
           console.error('JS Error ::  :: columnsOnAddEditing')
            console.error(this.serializeError(err));
           console.error(err)
       }
    }

    columnsFormatting(columns){
       try{
           if(this.serviceRepositoryName == 'relatedListClientInventors'){
                columns.forEach(column => {
                    if(column.field == 'SymphonyLF__Contact_Type__c'){
                        if(!column.formatterParams){
                            column["formatterParams"] = {};
                        }
                        column.formatterParams["classListFunction"] = (cell) => {
                            const contactType = cell.getRow().getData().SymphonyLF__Contact_Type__c;
                            if(contactType === 'Inventor'){
                                return ["redtag"]
                            }
                            else if(contactType === 'Designer'){
                                return ["greentag"]
                            }
                            else if(contactType === 'Author'){
                                return ["greytag"]
                            }
                            else{
                            return [];
                            }
                        }
                    }
                });
           }
           return columns
       }catch(err){
           console.error('JS Error ::  :: columnsFormatting')
           console.error(err)
       }
    }

    refreshHandler() {
        try {
            if (this.currentElementInitiatedRefresh) {
                this.currentElementInitiatedRefresh = false;
                return;
            }
            this.fetchClientEngagementModels();
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }

    disconnectedCallback() {
        try{
            unregisterRefreshHandler(this.refreshHandlerID);

            document.removeEventListener("click", this.handleTabulatorAddButtonClick);
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: refreshHandler');
            console.error(this.serializeError(err));
        }
    }

    fetchClientEngagementModels() {
        try {
            const promise = fetchRecords({
                "serviceName" : this.serviceRepositoryName, 
                "recordId" : this.recordId, 
                "serviceRepositoryWhereClauseReplacer": this.serviceRepositoryWhereClauseReplacer
            });
            console.log('fetchClientEngagementModels');
            promise.then(response => {
                    try {
                        this.serviceRespositoryResponse = response;
                      //  this.records = response;
                        this.showTable = true;
                        console.log('fetchClientEngagementModels resolved');
                        if (this.isLoadingFirstTime == false) {
                            console.log('fetchClientEngagementModels update table data 1');
                            this.updateTableData(response.serviceOutput);
                            this.convertToMap(response.serviceOutput);
                            console.log('response.serviceOutput ', response.serviceOutput);
                            console.log('response.serviceOutput.length ', response.serviceOutput.length);
                            console.log('fetchClientEngagementModels update table data 2');
                        }
                    } catch (err) {
                        console.error('JS Error in Server callback :: LwcMvRelatedList :: fetchClientEngagementModels');
                    }
                })
                .catch(error => {
                    console.error('Server Error :: LwcMvRelatedList :: fetchClientEngagementModels :: apexMethod => getClientEngagementModels');
                    console.error(JSON.stringify(error));
                })
                .finally(() => {
                    this.isLoadingFirstTime = false;
                });

                return promise;
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: fetchClientEngagementModels')
            console.error(err)
        }
    }

    convertToMap(input){
       try{
           if(input && Array.isArray(input) && input.length){
                const recordsMap = {};

                input.forEach(e => {
                    recordsMap[ e.Id ] = e;
                });

                this.recordsMap = recordsMap;
           }
       }catch(err){
           console.error('JS Error ::  :: convertToMap')
           console.error(err)
       }
    }

    mapValueToActionField(){
       try{
           this.actionFields.forEach(e => {
                if(e.type === 'address'){
                    delete e.addressObject;
                    const record = this.recordsMap[this.clientEngagementModelId];

                    const addressObject = {};
                    if(record){
                        const fieldValue = record[e.fieldApiName];

                        addressObject.street = fieldValue.street;
                        addressObject.city = fieldValue.city;
                      //  addressObject.postal = fieldValue.postal;
                        addressObject.postal = fieldValue.postalCode;
                        addressObject.state = fieldValue.stateCode;
                        addressObject.country = fieldValue.countryCode;
                        this.selectedCountry = fieldValue.countryCode;
                    }
                    else{
                        addressObject.street = '';
                        addressObject.city = '';
                        addressObject.postal = '';
                        addressObject.state = '';
                        addressObject.country = '';
                    }

                    e.addressObject = addressObject;
                }

                if (e.type === 'override' && e.overrideAttribute && e.overrideMode && this.currentMode) {
                    const attr = e.overrideAttribute;
                    e[attr] = e.overrideMode == this.currentMode ? e.overrideValue : !e.overrideValue;
                }

           });
       }catch(err){
           console.error('JS Error ::  :: mapValueToActionField');
           console.error(err);
           console.error(this.serializeError(err));
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

    clientEngagementModelId;
    showAddEdit = false;
    isLoading = false;

    handleAdd() {
        try {
            if(this.addButtonOverriddenByImanage){
                this.handleImanageInit();
            }else{
            this.actionFieldAddressToDetail = {};
            this.addOrEditMessage = `Add ${this.childObjectLabel}`;
            this.addOrEditSuccessMessage = 'Record created';
            this.clientEngagementModelId = null;
            this.currentMode = 'add';
            this.mapValueToActionField();
            this.setRecordTypeId();
            this.showAddEdit = true;
            }
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleAdd')
            console.error(err)
        }
    }

    setRecordTypeId(){
       try{
        if(!this.recordTypeDeveloperName){
            this.selectedRecordTypeId = null;
            return;
        }

        const defaultType = this.recordTypeOptions.filter(recordType =>{
            return recordType.label === this.recordTypeDeveloperName;
        });

        if(defaultType.length > 0){
            this.selectedRecordTypeId = defaultType[0].value;
        }
       }catch(err){
        console.error('JS Error ::  :: setRecordTypeId')
           console.error(err)
       }
    }

    handleAddEditSuccess() {
        try {
            this.showAddEdit = false;
            this.isLoading = false;
            this.fetchClientEngagementModels();
            this.selectedCountry = null;
          //  this.refreshOtherElementsOnThePage();
            this.showToast('Success', 'success', this.addOrEditSuccessMessage);
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleAddEditSuccess')
            console.error(this.serializeError(err));
        }
    }

    handleAddEditError(event) {
        try {
            this.isLoading = false;
            console.error('error in handle add Edit error ', event);
            console.error('error in handle add Edit error ', JSON.stringify(event));
            console.error('error in handle add Edit error ', event.detail);
            console.error('error in handle add Edit error ', JSON.stringify(event.detail));
            console.error('error in handle add Edit error ', event.body);
            console.error('error in handle add Edit error ', JSON.stringify(event.body));
           /* const errorDetails = event.detail;
            console.error('Error occurred while saving the record:', errorDetails);

            // Display a custom error message to the user (optional)
            const errorMessage = this.extractErrorMessage(errorDetails); */

            let errors = this.reduceErrors(event?.detail?.body?.output?.errors); // you can pass your recordedit form error here
            let errorMessage = errors.join('; ');

            this.showToast('Error', 'error', errorMessage); // 'Record not updated'
            
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleAddEditError')
            console.error(this.serializeError(err));
        }
    }

    reduceErrors(errors) {

        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // Page level errors
                    else if (
                        error?.body?.pageErrors &&
                        error.body.pageErrors.length > 0
                    ) {
                        return error.body.pageErrors.map((e) => e.message);
                    }
                    // Field level errors
                    else if (
                        error?.body?.fieldErrors &&
                        Object.keys(error.body.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML page level errors
                    else if (
                        error?.body?.output?.errors &&
                        error.body.output.errors.length > 0
                    ) {
                        return error.body.output.errors.map((e) => e.message);
                    }
                    // UI API DML field level errors
                    else if (
                        error?.body?.output?.fieldErrors &&
                        Object.keys(error.body.output.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.output.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

    handleCancel() {
        try {
            this.showAddEdit = false;
            this.selectedCountry = null;
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleCancel')
            console.error(this.serializeError(err));
        }
    }

    getValueByLabel(label) {
    // Find the object in the array where the label matches
    const country = this.countryOptions.find(option => option.label === label);

    // Return the value if found, otherwise return undefined
    return country ? country.value : undefined;
    }

    handleSave() {
        try {
            this.isLoading = true;

            const inputFields = this.template.querySelectorAll('lightning-input-field');

            const fields = {};

            let isValid = true;

            inputFields.forEach(inputField => {
                if(! inputField.reportValidity()){
                    console.log('cm here')
                    isValid = false;
                }
                fields[inputField.fieldName] = inputField.value;
            });

            console.log('isValid ', isValid);

            const addressFields = this.template.querySelectorAll('.addressField');
            
            addressFields.forEach(addressField => {
                if(! addressField.checkValidity()){
                    addressField.reportValidity();
                    console.log('cm here')
                    isValid = false;
                }
            });

            if(! isValid){
                this.isLoading = false;
                return;
            }

            this.actionFields.forEach(e => {
                if(e.type === 'address'){
                    const fieldApiName = e.fieldApiName;
                    const addressComplexValue  = this.actionFieldAddressToDetail[fieldApiName];

                    if(addressComplexValue){
                        console.log('cm addressComplexValue ', JSON.stringify(addressComplexValue));
                        fields[fieldApiName] = addressComplexValue;

                        
                        fields[fieldApiName.replace('__c', '__Street__s')] = addressComplexValue.street;
                        fields[fieldApiName.replace('__c', '__City__s')] = addressComplexValue.city; 
                        //fields[fieldApiName.replace('__c', '__State__s')] = addressComplexValue.state;   
                        fields[fieldApiName.replace('__c', '__StateCode__s')] = addressComplexValue.state;   
                         //fields[fieldApiName.replace('__c', 'StateCode__s')] = 'CA'; 
                        fields[fieldApiName.replace('__c', '__PostalCode__s')] = addressComplexValue.postalCode; 
                        
                       fields[fieldApiName.replace('__c', '__CountryCode__s')] = addressComplexValue.country;  

                        // Address (Country/Territory): bad value for restricted picklist field: Antigua and Barbuda

                        
                    }
                    
                }
            });

            if(this.selectedRecordTypeId){
                fields['RecordTypeId'] = this.selectedRecordTypeId;
            }

            console.log('fields ', JSON.stringify(fields));
        

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleSave')
            console.error(this.serializeError(err));
        }
    }

    flowApiName;
    flowInputVariables;
    handleImanageInit(){
       try{
           this.flowApiName = 'cmpAPiManageDocuments';
           this.flowInputVariables = [
               {
                   "name": "recordId",
                   "type": "String",
                   "value": this.recordId
               }
           ];
           this.showImanageAdd = true;
       }catch(err){
           console.error('JS Error ::  :: handleImanageInit')
           console.error(err)
       }
    }

    handleSaveImanage(event) {
        try {
            if (event.detail.status === 'FINISHED') {
                this.isLoading = true;

                this.showImanageAdd = false;

                this.fetchClientEngagementModels();
            }
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleSaveImanage')
            console.error(this.serializeError(err));
        }
    }

    handleCancelImanage() {
        try {
            this.showImanageAdd = false;

            this.fetchClientEngagementModels();
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: handleCancelImanage')
            console.error(this.serializeError(err));
        }
    }

    get
        showAddEditVisible() {
        try {
            return this.showAddEdit ? 'slds-show' : 'slds-hide';
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: showAddEditVisible')
            console.error(err)
        }
    }


    isRenderedCallBackInitialized = false;

    renderedCallback() {
        try {
            if (this.isRenderedCallBackInitialized) return;
            this.isRenderedCallBackInitialized = true;

            Promise.all([
                //   loadScript(this, MAXVALTABLEJS),
                //   loadStyle(this, MAXVALTABLECSS),
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
                .then(() => {
                    /*  const defaultTile = this.template.querySelector('[data-filtertype="aggregateCollaborations"]');
                      if (defaultTile) {
                          defaultTile.classList.add('selected');
                      } */
                });
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: renderedCallback')
            console.error(err)
        }
    }

    // Helper method to extract error messages
    extractErrorMessage(errorDetails) {
        try {
            if (errorDetails && errorDetails.body) {
                if (errorDetails.body.output && errorDetails.body.output.errors.length > 0) {
                    return errorDetails.body.output.errors[0].message; // Record-level error
                } else if (errorDetails.body.message) {
                    return errorDetails.body.message; // Top-level error
                }
            }
            return errorDetails.detail;
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: extractErrorMessage');
            console.error(err);
        }
    }

    updateTableData(data) {
        try {
            console.log('data ', data);
            console.log('JSON.stringify(data) ', JSON.stringify(data));
            const tableElement = this.template.querySelector('.lwcMvDataTable');
            console.log('querying table element');
            if (tableElement) {
                console.log('Found table element 1');
                tableElement.updateTableData(data);
                console.log('Found table element 2');
            }

        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: updateTableData')
            console.error(err);
            console.error(this.serializeError(err));
        }
    }

    currentElementInitiatedRefresh = false;
    refreshOtherElementsOnThePage() {
        try {
            this.currentElementInitiatedRefresh = true;
            this.dispatchEvent(new RefreshEvent());
        } catch (err) {
            console.error('JS Error :: LwcMvRelatedList :: refreshOtherElementsOnThePage')
            console.error(err)
        }
    }
}