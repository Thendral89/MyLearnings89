/* Copyright © 2022 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Developed by: Aman Deep (aman.d@maxval.com)
 */
import { LightningElement, api, track } from 'lwc';
import getSearchRecords from '@salesforce/apex/DynamicSearchRecords.DynamicSearchRecords';

export default class DynamicSearchAndSelect extends LightningElement {
    @api minSearchTxtLen = 3;
    @api flowErrorMsg = 'Please Select a value'
    @api objectName;
    @api placeholder = '';
    @api autocomplete = 'off';
    @api searchFieldNames = '';
    searchFieldNameList;
    @api queryFieldNames = '';
    queryFieldNameList;
    @api selectionCriteria = '';
    @api whereClause = '';
    @api Label;
    @api iconName;
    @api recordsExcluded = '';
    @api dropdownOptionFields = '';
    dropdownFieldNames = [];
    @api selectedRecordRepresentation = '';
    @api limit = 10;
    @api orderBy = 'Id';
    @api textLengthRestrictionMsg = ''; //'Enter 2 or more characters to search';
    @api noResultMsg = 'No result found.';
    @api error = '';
    @api noSelectionError = '';
    @track hasRecId = false;
    @track searchRecords = [];
    fetchedRecords = [];
    @track selectedRecords = [];
    dispatchRecords = [];
    @track recordId = '';
    isDropdownHovered = false;
    @api disabled = false;
    @api hasEncryptedFieldSearch;
    @api returnUniqueValueFor;
    @api groupBy; //deprecated
    @api havingCond; //deprecated
    enteredText = '';
    @api addIcon = false;
    @api
    get finalSelId() {
        return this.recordId;
    }
    set finalSelId(value) {
        if (value != null && value!='') {
            if (value.length > 0) {
                if (this.recordId === '' || this.recordId !== value) {
                    value = value.replaceAll(' ', '').replaceAll(',', ' ').trim().replaceAll(' ', ',');
                    let valueList = value.split(',');
                    let tempWhereClause = this.whereClause != null && this.whereClause != '' ? '('+this.whereClause+') AND' : '';
                    let autoPopulationWhereClause = tempWhereClause+" ID IN ('" + value.replaceAll(",", "','") + "')";
                    getSearchRecords({ ObjectName: this.objectName, SearchFieldNameList: this.searchFieldNameList, FieldsToFetch: this.queryFieldNames, str: '', selectedRecId: [], additionalCond: autoPopulationWhereClause, numOfRecs: valueList.length })
                    .then(result => {
                        this.reset();
                        this.fetchedRecords = result;
                        result.forEach(row => {
                            let e = { currentTarget: { dataset: { id: row.Id } } };
                            if(!this.addIcon){
                                this.setSelectedRecord(e);
                            }
                        });
                    })
                    .catch(error => {
                        console.log('-------error-------------' + error);
                        console.log(error);
                    });
                }
            } else {
                this.reset();
            }
        }
    }
    @api
    get finalSelIdList() {
        return this.recordId.split(',');
    }

    @api required = false;
    labelVariant = 'label-hidden';//"standard";
    // iconClass = 'slds-icon_container slds-icon-standard-account slds-combobox__input-entity-icon slds-m-top_small';
    // btnClass = 'sicon_container slds-button slds-button_icon slds-input__icon slds-input__icon_right slds-input_height slds-p-top_x-small slds-button_icon-border';
    iconClass = 'slds-icon_container slds-icon-standard-account slds-combobox__input-entity-icon';
    btnClass = 'sicon_container slds-button slds-button_icon slds-input__icon slds-input__icon_right';

    @api LoadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;

    connectedCallback() {
        this.setParentFields();
    }
    @api setParentFields()
    { 
        this.searchFieldNameList = this.searchFieldNames.replaceAll(' ', '').split(',');
        let queryFNset = new Set(this.queryFieldNames.replaceAll(' ', '').split(','));
        if (queryFNset.has('ID') || queryFNset.has('Id') || queryFNset.has('iD') || queryFNset.has('id')) {
            queryFNset.delete('ID'); queryFNset.delete('Id'); queryFNset.delete('iD'); queryFNset.delete('id');
        }
        this.queryFieldNameList = [...queryFNset];
        this.queryFieldNameList.unshift('Id');
        this.queryFieldNames = this.queryFieldNameList.join();
        let dropdownFieldIndexArray = this.dropdownOptionFields.replaceAll(' ', '').split(',');
        this.dropdownFieldNames=[];
        dropdownFieldIndexArray.forEach(item => {
            this.dropdownFieldNames.push(this.queryFieldNameList[item]);
        });

        this.selectedRecordRepresentation = this.selectedRecordRepresentation.trim();
        this.selectionCriteria = this.selectionCriteria.trim().toLowerCase();
        console.log('this.whereClause114',this.whereClause);
        if(this.whereClause)
            this.whereClause = this.whereClause.trim();
        if (this.selectionCriteria != 's' && this.selectionCriteria != 'm') {
            this.selectionCriteria = 's';
        }
        console.log('this.whereClause120',this.whereClause);
        // Important Note: If value of required is coming as string, this will set it to appropriate boolean value for required
        if (this.required == true || this.required == 'true') {
            this.required = true;
        } else {
            this.required = false;
        }
    }

    _flatten = (nodeValue, flattenedRow, nodeName) => {
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.' + key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

    handleKeyDown(event) {
        if (this.addIcon && event.key === 'Enter' &&  this.messageFlag) {
            console.log('Enter key pressed:', this.enteredText);
            const selectedEvent = new CustomEvent('add', { detail: this.enteredText });
            this.dispatchEvent(selectedEvent);
            this.messageFlag = false;
        }
    }

    handleClick(){
        console.log('inside handle click',this.enteredText);
         const selectedEvent = new CustomEvent('onAdd', { detail: this.enteredText });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
     }
     
    searchField(event) {
        this.disableAutoDropdown = false;
        var currentText = event.target.value;
        this.enteredText = event.target.value;
        this.noSelectionError = '';
        const selectedEvent = new CustomEvent('change', { detail: this.enteredText });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        if (this.disabled) {
            // this.isDropdownHovered = false;
            this.LoadingText = false;
            this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        }
        else {
            this.isDropdownHovered = false;
            var selectRecId = [];
            if (this.recordsExcluded.length > 0) {
                selectRecId = this.recordsExcluded.replaceAll(' ', '').split(',');
            }
            for (let i = 0; i < this.selectedRecords.length; i++) {
                selectRecId.push(this.selectedRecords[i].recId);
            }

            if (currentText.length >= this.minSearchTxtLen && ((this.hasEncryptedFieldSearch && currentText.length > 1) || !this.hasEncryptedFieldSearch)) {
                this.LoadingText = true;
                this.messageFlag = false;
                getSearchRecords({ ObjectName: this.objectName, SearchFieldNameList: this.searchFieldNameList, FieldsToFetch: this.queryFieldNames, str: currentText, selectedRecId: selectRecId, additionalCond: this.whereClause, orderBy: this.orderBy, numOfRecs: this.limit, hasEncryptedFieldSearch: this.hasEncryptedFieldSearch, returnUniqueValueFor: this.returnUniqueValueFor })
                .then(result => {
                    let noOfDropdownFields = this.dropdownFieldNames.length;
                    console.log('result object>>',JSON.stringify(result));
                    this.fetchedRecords = []; //result;
                    for (let row of result) {
                        // this const stroes a single flattened row. 
                        const flattenedRow = {}
                        // get keys of a single row — Name, Phone, LeadSource and etc
                        let rowKeys = Object.keys(row);
                        //iterate 
                        rowKeys.forEach((rowKey) => {
                            //get the value of each key of a single row. John, 999-999-999, Web and etc
                            const singleNodeValue = row[rowKey];
                            //check if the value is a node(object) or a string
                            if (singleNodeValue.constructor === Object) {
                                //if it's an object flatten it
                                this._flatten(singleNodeValue, flattenedRow, rowKey);
                            } else {
                                //if it’s a normal string push it to the flattenedRow array
                                flattenedRow[rowKey] = singleNodeValue;
                            }
                        });
                        this.fetchedRecords.push(flattenedRow);
                    }
                    let result1 = [];
                    for (let row of this.fetchedRecords) {
                        let newRow = {};
                        newRow.Id = row.Id;
                        newRow.optHeading = row[this.dropdownFieldNames[0]] ? row[this.dropdownFieldNames[0]] : '';
                        newRow.optMetaText = '';
                        for (let i = 1; i < noOfDropdownFields; i++) {
                            if (row[this.dropdownFieldNames[i]]) {
                                if (newRow.optMetaText == '') {
                                    newRow.optMetaText = row[this.dropdownFieldNames[i]];
                                } else {
                                    newRow.optMetaText += ' | ' + row[this.dropdownFieldNames[i]];
                                }
                            }
                        }
                        result1.push(newRow);
                    }
                    this.searchRecords = result1;
                    this.LoadingText = false;

                    this.txtclassname = result1.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
                    if (result1.length == 0) {
                        this.messageFlag = true;
                    }
                    else {
                        this.messageFlag = false;
                    }
                })
                .catch(error => {
                    console.log('-------error-------------' + error);
                    console.log(error);
                });
            } else {
                this.searchRecords = null;
                this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            }
        }
    }

    @api hidePills = false;
    _disableAutoDropdown = false;

    
    @api get disableAutoDropdown(){
       try{
           return this._disableAutoDropdown;
       }catch(err){
           alert('JS Error ::  :: disableAutoDropdown :: get');
           console.error(err)
       }
    }
    set disableAutoDropdown(val){
        try{
           this._disableAutoDropdown = val;
       }catch(err){
           alert('JS Error ::  :: disableAutoDropdown :: set');
       }
    }

    get
    showPills(){
       try{
           return !this.hidePills;
       }catch(err){
           alert('JS Error ::  :: showPills')
           console.error(err)
       }
    }

    @api
    resetSearchErrorAndText() {
        this.noSelectionError = '';
        this.enteredText = '';
    }
    setSelectedRecord(event) {
        try{
        let recId = event.currentTarget.dataset.id;
        let tempObject;
        let selRec_Representation = this.selectedRecordRepresentation;
        this.fetchedRecords.forEach(rec => {
            if (rec.Id == recId) {
                tempObject = rec;
            }
        });
        this.dispatchRecords.push(tempObject);

        for (var i = this.queryFieldNameList.length - 1; i >= 0; i--) {
            let key = 'field' + i;
            selRec_Representation = selRec_Representation.replace(i, key);
        }
        for (var i = this.queryFieldNameList.length - 1; i >= 0; i--) {
            let key = 'field' + i;
            let value = tempObject[this.queryFieldNameList[i]] ? tempObject[this.queryFieldNameList[i]] : '';
            selRec_Representation = selRec_Representation.replace(key, value);
        }

        let selRecLabel = selRec_Representation;
        let newsObject = { 'recId': recId, 'recLabel': selRecLabel };
        if (this.selectionCriteria == 's') {
            this.selectedRecords = [];
        }
        this.selectedRecords.push(newsObject);

        if (this.selectionCriteria == 's') {
            this.recordId = recId;
            this.hasRecId = true;
            this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            this.enteredText = '';
        } else {
            if (this.recordId == '') {
                this.recordId = recId;
            } else {
                this.recordId += ',' + recId;
            }
            if(this.disableAutoDropdown == false)
            this.template.querySelector('.searchBox').focus();
        }
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        console.log('dispatch records-->',JSON.stringify(this.dispatchRecords));
        const selectedEvent = new CustomEvent('selected', { detail: this.dispatchRecords });
        // Dispatches the event.
       // debugger;
        this.dispatchEvent(selectedEvent);
        }
        catch(err){
            alert('JS Error :: dynamicSearchAndSelect :: setSelectedRecord');
        }
    }
    enterkeyevent(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }
    removeRecord(event) {
        console.log('event.target.type'); console.log(event.target.type);
        console.log('dynamic remove record ' + this.Label);
        try {
            let selectRecId = [];
            let tempRecordId = '';
            let tempDispatchRecords = [];
            for (let i = 0; i < this.selectedRecords.length; i++) {
                if (event.currentTarget.name !== this.selectedRecords[i].recId) {
                    selectRecId.push(this.selectedRecords[i]);
                    tempDispatchRecords.push(this.dispatchRecords[i]);
                    if (tempRecordId == '') {
                        tempRecordId = this.selectedRecords[i].recId;
                    } else {
                        tempRecordId += ',' + this.selectedRecords[i].recId;
                    }
                }
            }
            this.selectedRecords = [...selectRecId];
            this.dispatchRecords = tempDispatchRecords;
            if (this.selectionCriteria == 'm') {
                this.recordId = tempRecordId;

                if(this.disableAutoDropdown == false)
                this.template.querySelector('.searchBox').focus();
            }
            if (!this.selectedRecords.length) {
                this.recordId = '';
                this.hasRecId = false;
            }
            const selectedEvent = new CustomEvent('selected', { detail: this.dispatchRecords });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
        catch (Exception) {
            console.log('remove rec exception--' + Exception);
        }
    }
    // this method runs when search input box loses focus
    handleBlur(event) {
        if (!this.isDropdownHovered) {
            this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            this.messageFlag = false; this.LoadingText = false;
            if (this.template.querySelector('.searchBox').value != '' && !this.selectedRecords.length)
                this.noSelectionError = 'Select an option from the lookup or remove the search term';
        }
    }
    handleDropdownHoverOut() {
        this.isDropdownHovered = false;
    }
    handleDropdownHoverIn() {
        this.isDropdownHovered = true;
    }
    @api reset() {
        this.searchRecords = [];
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.dispatchRecords = [];
        this.selectedRecords = [];
        this.recordId = '';
        this.hasRecId = false;
        this.noSelectionError = '';
        this.enteredText = '';
    }
    @api
    validate() {
        if (this.required) {
            if (this.recordId) {
                return { isValid: true };
            }
            else {
                // If the component is invalid, return the isValid parameter 
                // as false and return an error message. 
                return {
                    isValid: false,
                    errorMessage: this.flowErrorMsg
                };
            }
        }
    }
}