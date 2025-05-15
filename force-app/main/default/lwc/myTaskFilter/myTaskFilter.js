import { api, LightningElement, track, wire } from 'lwc';
import {getTaskFieldsDataApex} from 'c/myTaskUtils'
import USER_ID from '@salesforce/user/Id';
//import CLIENT_ID_FIELD from '@salesforce/schema/User.Client_Id__c';
import { getRecord } from 'lightning/uiRecordApi';



const operatorMap = {
    equals: '=',
    doesNotEquals: '!=',
    greaterThan: '>',
    lessThan: '<',
    greaterThanOrEqual: '>=',
    lessThanOrEqual: '<=',
    contains: 'LIKE',
    isNull: 'IS NULL',
    startWith: 'LIKE', 
    endWith: 'LIKE', 
};

const fieldToOperatorsMap = {
    string: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
        { label: "Start With", value: "startWith" },
        { label: "End With", value: "endWith" },
        { label: "Contains", value: "contains" }
    ],
    integer: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
        { label: "Greater Than", value: "greaterThan" },
        { label: "Less Than", value: "lessThan" },
        { label: "Greater Than Or Equal", value: "greaterThanOrEqual" },
        { label: "Less Than Or Equal", value: "lessThanOrEqual" },
        { label: "Contains", value: "contains" },
        { label: "Is Null", value: "isNull" },
    ],
    currency: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
        { label: "Greater Than", value: "greaterThan" },
        { label: "Less Than", value: "lessThan" },
        { label: "Greater Than Or Equal", value: "greaterThanOrEqual" },
        { label: "Less Than Or Equal", value: "lessThanOrEqual" },
        { label: "Is Null", value: "isNull" },
    ],
    boolean: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
        { label: "Is Null", value: "isNull" },
    ],
    picklist: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
    ],
    combobox: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
        { label: "Contains", value: "contains" },
    ],
    reference: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" }
    ],
    date: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
        { label: "Greater Than", value: "greaterThan" },
        { label: "Less Than", value: "lessThan" },
        { label: "Greater Than Or Equal", value: "greaterThanOrEqual" },
        { label: "Less Than Or Equal", value: "lessThanOrEqual" }
    ],
    percent: [
        { label: "Equals", value: "equals" },
        { label: "Does Not Equals", value: "doesNotEquals" },
        { label: "Greater Than", value: "greaterThan" },
        { label: "Less Than", value: "lessThan" },
        { label: "Greater Than Or Equal", value: "greaterThanOrEqual" },
        { label: "Less Than Or Equal", value: "lessThanOrEqual" },
        { label: "Is Null", value: "isNull" },
    ],
};
const ruleValueOptions = {
    equals: [
        { label: 'True', value: 'True' },
        { label: 'False', value: 'False' }
    ],
    doesNotEquals: [
        { label: 'True', value: 'True' },
        { label: 'False', value: 'False' }
    ],
    isNull: [
        { label: 'True', value: 'True' },
        { label: 'False', value: 'False' }
    ],
}

export default class MyTaskFilter extends LightningElement {



    @track isShowFilterModal = false;
    @track isEmpty = false;
    @track oldRules = [this.createNewRule(1)];
    @track rules = [this.createNewRule(1)];
    @track objectApiNameValue;
    ruleFieldOptions = [];
    ruleOperatorOptions = [];
    operatorOptions = [
        { value: 'OR', label: 'OR' },
        { value: 'AND', label: 'AND' },
    ];
    
    collectionFieldNames='Name';
    collectionfieldsToQuery='Name';


    @api
    resetFilters() {
        this.rules = [this.createNewRule(1)];
        this.oldRules = [this.createNewRule(1)];
        this.isEmpty = false;
    }

    createNewRule(id) {
        return {
            id,
            selectedRuleField: null,
            selectedRuleOperator: 'equals',
            selectedRuleValue: null,
            isFieldDisabled: false,
            isOperatorDisabled: true,
            isValueDisabled: true,
            selectedFieldCategory: 'string',
            selectedOperatorCategory: 'equals',
            type: 'text',
            placeholder: 'Enter a value',
            selectedFieldText: true,
        };
    }

    handleOnClickFilterList() {
        this.isShowFilterModal = true;
        this.getTaskFieldsData();
    }

    /* @wire(getRecord, { recordId: USER_ID, fields: [CLIENT_ID_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.clientId = data.fields.Client_Id__c.value;
            console.log('clientId:',this.clientId);
            if(this.clientId){
                this.clientIdCondition = "Client_Id__c ='" + this.clientId + "'";
                console.log('this.clientIdCondition::',this.clientIdCondition);
            }
            else{
                this.clientIdCondition = '';
            }
        } else if (error) {
            console.error(error);
        }
    } */

    async getTaskFieldsData() {
            const resp = await getTaskFieldsDataApex();
            if (resp && resp.isSuccess) {
                this.ruleFieldOptions = resp.data;
                console.log('this.ruleFieldOptions:',this.ruleFieldOptions);
                console.log('this.ruleFieldOptions.referenceTo:',this.ruleFieldOptions.referenceTo);
            } else {
                console.log(resp.errorMessage);
            }
    }


    handleRuleFieldChange(event) {
        const ruleId = event.target.dataset.id;
        const selectedFieldOption = event.detail.value;
        let rules = this.rules.map((rule) => {
            if (rule.id == ruleId) {
                let selectedField = this.selectedFieldDataType(selectedFieldOption);
                let fieldLabel = this.selectedFieldDataPattern.label;
                let selectedOperatorOptions = fieldToOperatorsMap[selectedField.toLowerCase()] || [];
                if (selectedField.toLowerCase() == 'date') {
                    return {
                        ...rule,
                        selectedRuleField: selectedFieldOption,
                        selectedFieldLabel: fieldLabel,
                        selectedRuleOperator: "equals",
                        selectedRuleValue: "",
                        isOperatorDisabled: false,
                        isValueDisabled: false,
                        selectedFieldCategory: selectedField,
                        ruleOperatorOptions: selectedOperatorOptions,
                        selectedFieldDate: true,
                        selectedFieldText: false,
                        selectedFieldPicklist: false,
                        selectedFieldLookup: false,
                    };
                }
                else if (selectedField.toLowerCase() == 'reference') {
                    this.objectApiNameValue = this.selectedFieldDataPattern.referenceTo;
                    console.log('Selected Field Data Pattern:', this.selectedFieldDataPattern);
                    console.log('Object API Name:', this.objectApiNameValue);
                    return {
                        ...rule,
                        selectedRuleField: selectedFieldOption,
                        selectedFieldLabel: fieldLabel,
                        selectedRuleOperator: "equals",
                        selectedRuleValue: "",
                        isOperatorDisabled: false,
                        isValueDisabled: false,
                        selectedFieldCategory: selectedField,
                        ruleOperatorOptions: selectedOperatorOptions,
                        selectedFieldLookup: true,
                        selectedFieldText: false,
                        selectedFieldPicklist: false,
                        selectedFieldDate: false,
                    };

                }
                else if (selectedField.toLowerCase() == 'picklist' || selectedField.toLowerCase() == 'combobox') {
                    let picklistValues = this.getPicklistValuesByLabel(fieldLabel);
                    return {
                        ...rule,
                        selectedRuleField: selectedFieldOption,
                        selectedFieldLabel: fieldLabel,
                        selectedRuleOperator: "equals",
                        selectedRuleValue: "",
                        isOperatorDisabled: false,
                        isValueDisabled: false,
                        selectedFieldCategory: selectedField,
                        ruleOperatorOptions: selectedOperatorOptions,
                        selectedFieldPicklist: true,
                        selectedFieldPicklistOptions: picklistValues,
                        selectedFieldText: false,
                        selectedFieldLookup: false,
                        selectedFieldDate: false,
                    };
                }
                else if (selectedField.toLowerCase() == 'string' ) {
                    console.log('inside string');
                    return {
                        ...rule,
                        selectedRuleField: selectedFieldOption,
                        selectedFieldLabel: fieldLabel,
                        selectedRuleOperator: "equals",
                        selectedRuleValue: "",
                        isOperatorDisabled: false,
                        isValueDisabled: false,
                        selectedFieldCategory: selectedField,
                        ruleOperatorOptions: selectedOperatorOptions,
                        selectedFieldText: true,
                        selectedFieldLookup: false,
                        selectedFieldDate: false,
                        selectedFieldPicklist: false,
                    };
                }
                else {
                    console.log('inside else');
                    return {
                        ...rule,
                        selectedRuleField: selectedFieldOption,
                        selectedFieldLabel: fieldLabel,
                        selectedRuleOperator: "equals",
                        selectedRuleValue: "",
                        isOperatorDisabled: false,
                        isValueDisabled: false,
                        selectedFieldCategory: selectedField,
                        ruleOperatorOptions: selectedOperatorOptions,
                        selectedFieldText: true,
                    };
                }

            }else{
                return rule;
            }
        });

        this.rules = rules;
    }

    handleOperatorChange(event){
        const ruleId = event.target.dataset.id;
        const selectedOperatorOption = event.detail.value;
        console.log('operator :' + selectedOperatorOption);
        let rules = this.rules.map((rule) => {
            if (rule.id == ruleId) {
                let selectedField = this.selectedFieldDataType(rule.selectedRuleField);
                const type = selectedField.toLowerCase();
                let isPicklistType = this.selectedFieldDataPattern.isValuePicklistType;
                let picklistOptions = this.selectedFieldDataPattern.picklistTypeOptions;
                const isNullOrChange = selectedOperatorOption === "isNull";
                const isValueInputType = ['string', 'integer', 'currency', 'percent'].includes(type.toLowerCase()) && !isNullOrChange ? true : false;
                if (!isValueInputType && !isPicklistType || (isValueInputType && isNullOrChange)) {
                    return {
                        ...rule,
                        selectedRuleOperator: selectedOperatorOption,
                        selectedRuleValue: "",
                        isValuePicklistType: isPicklistType,
                        isValueDisabled: false,
                        ruleValueOptions: ruleValueOptions[selectedOperatorOption] || [],
                        isType: isValueInputType,
                    };
                }else if(!isValueInputType && isPicklistType) {
                    return {
                        ...rule,
                        selectedRuleOperator: selectedOperatorOption,
                        selectedRuleValue: "",
                        isValuePicklistType: isPicklistType,
                        isValueDisabled: false,
                        ruleValueOptions: picklistOptions || [],
                        isType: isValueInputType,
                    };
                }else{
                    console.log('inside else');
                    return {
                        ...rule,
                        selectedRuleOperator: selectedOperatorOption,
                        selectedRuleValue: "",
                        isValuePicklistType: isPicklistType,
                        isValueDisabled: false,
                        selectedOperatorCategory: type,
                        type: type === "string" ? "text" : ['integer', 'currency', 'percent'].includes(type.toLowerCase()) ? 'number' : type,
                        placeholder: type === "date" ? "DD-MMM-YYYY" : "Enter a value",
                        isType: isValueInputType,
                        formatter: ['currency', 'percent'].includes(type.toLowerCase()) ? type : '',
                    };
                }
            }else{
                return rule;
            }
        });
        this.rules = rules;
    }

    handleValueChange(event){
        const source = event.target.dataset.source;
        const ruleId = event.target.dataset.id;
        const selectedValueOption='';
        if(source === 'AssignedToPerson' && event.detail != null && event.detail.length == 1){
            this.selectedValueOption = event.detail[0].Id;
            console.log('let selectedValueOption in if:,'+this.selectedValueOption);
        }
        else{
         this.selectedValueOption = event.target.value;
        }

        let rules = this.rules.map((rule) => {
            if (rule.id == ruleId) {
                return {
                    ...rule,
                    selectedRuleValue: this.selectedValueOption,
                };
            } else {
                return rule;
            }
        });
        this.rules = rules;
        console.log('this.rules::', JSON.stringify(this.rules));
    }

    selectedFieldDataType(value){
        this.selectedFieldDataPattern = this.ruleFieldOptions.find((field) => field.value === value);
        return this.selectedFieldDataPattern ? this.selectedFieldDataPattern.dataType : "";
    }


    getPicklistValuesByLabel(targetLabel){
        // Find the object with the matching label
        this.ruleFieldOptions.forEach(entry => {
        });
        const item = this.ruleFieldOptions.find(entry => entry.label.trim().toLowerCase() === targetLabel.trim().toLowerCase());
        return item.picklistValues;
    }


    handleRemoveRule(event) {
        let ruleId = event.target.dataset.id;
        let defaultRules = JSON.parse(JSON.stringify((this.rules)));
        if (defaultRules.length > 1) {
            defaultRules.splice(ruleId - 1, 1);
            defaultRules.forEach(function (item, index) {
                item.id = index + 1;
            });
            const lastItem = defaultRules[defaultRules.length - 1];
            if (lastItem) {
                lastItem.displayLogicalOperator = false;
                lastItem.selectedOperatorField = '';
                defaultRules = [...defaultRules];
            }
            this.rules = defaultRules;
        }else{
            this.rules = [];
            this.handleAddRules();
        }
    }

    
    handleAddRules(event) {
        let rulesCheck = this.rules.map((rule) => {
            this.isEmpty = this.rules.some((rule) => 
                !rule.selectedRuleField || !rule.selectedRuleOperator //|| !rule.selectedRuleValue
            );
        });
        if (this.isEmpty) {
            return;
        }
        const lastRuleIndex = this.rules.length - 1;
        if (lastRuleIndex >= 0) {
            this.rules[lastRuleIndex].displayLogicalOperator = true;
            this.rules[lastRuleIndex].selectedOperatorField = 'AND';
        }
        const newRule = this.createNewRule(this.rules.length + 1);
        this.rules.push(newRule);
    }

    handleApplyRules(){

        let rulesCheck = this.rules.map((rule) => {
            this.isEmpty = this.rules.some((rule) => 
                !rule.selectedRuleField || !rule.selectedRuleOperator //|| !rule.selectedRuleValue
            );
        });

        if (this.isEmpty == false) {
            let queryFilterParts = [];
            let openParenthesis = false;
        
            this.rules.forEach((rule, index) => {
                const field = rule.selectedRuleField.split(';')[0]; 
                const operator = operatorMap[rule.selectedRuleOperator];
                let queryPart = `(${field}`;

                if(rule.selectedRuleOperator === 'isNull') {
                    queryPart += ` ${operator})`;
                }else if(rule.selectedRuleOperator === 'contains') {
                    queryPart += ` ${operator} '%${rule.selectedRuleValue}%')`;
                }else if (rule.selectedRuleOperator === 'startWith') {
                    queryPart += ` ${operator} '${rule.selectedRuleValue}%')`;
                } else if (rule.selectedRuleOperator === 'endWith') {
                    queryPart += ` ${operator} '%${rule.selectedRuleValue}')`;
                }else{
                    const value = rule.selectedFieldCategory === 'DATE'
                ? (rule.selectedRuleValue ? rule.selectedRuleValue : 'null') 
                : `'${rule.selectedRuleValue}'`;
                    
                    queryPart += ` ${operator} ${value})`;
                }

                if(rule.selectedOperatorField === 'OR'){
                    if (!openParenthesis) {
                        queryFilterParts.push('('); 
                        openParenthesis = true;
                    }
                    queryFilterParts.push(queryPart);
                }else{
                    if(openParenthesis){
                        queryFilterParts.push(queryPart + ')'); 
                        openParenthesis = false;
                    }else{
                        queryFilterParts.push(queryPart); 
                    }
                }
            
                if(index < this.rules.length - 1){
                    queryFilterParts.push(rule.selectedOperatorField);
                }
            });
          
            if(openParenthesis){
                queryFilterParts.push(')');
            }

            const queryFilter = queryFilterParts.join(' ');

            const applyFilter = new CustomEvent('applyfilter', { 
                detail: { 
                    queryFilter: queryFilter 
                } 
            });

            this.oldRules = JSON.parse(JSON.stringify(this.rules));
            console.log('queryFilter:',queryFilter);
            this.dispatchEvent(applyFilter);
            this.isShowFilterModal = false;
        }

    }

    handleLogicalOperatorChange(event){
        const ruleId = event.target.dataset.id;
        let selectedValue = event.detail.value;
        let rules = this.rules.map((rule) => {
            if(rule.id == ruleId){
                return{
                    ...rule,
                    selectedOperatorField: selectedValue,
                };
            }else{
                return rule;
            }
        });
        this.rules = rules;
    }

    handleFilterClose(){
        this.isShowFilterModal = false;
       // this.rules = this.oldRules.length > 0 ? JSON.parse(JSON.stringify(this.oldRules)) : this.createNewRule(1);
        this.rules = JSON.parse(JSON.stringify(this.oldRules));
    }

}