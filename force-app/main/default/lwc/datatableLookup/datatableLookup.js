import { LightningElement, api, wire } from 'lwc';
import { loadStyle } from "lightning/platformResourceLoader";
import CustomDataTableResource from "@salesforce/resourceUrl/CustomDatatable";
import { getRecord } from "lightning/uiRecordApi";
import getRecordDetails from '@salesforce/apex/DatatableLookupHelper.getRecordDetails';
import getCurrencyDetails from '@salesforce/apex/DatatableLookupHelper.getCurrencyDetails';

export default class DatatableLookup extends LightningElement {
    @api label;
    val;
    @api placeholder;
    @api fieldName;
    @api object;
    @api context;
    @api variant;
    @api name;
    @api fields;
    @api target;
    @api preValue;
    @api disabled = false;
    showLookup = false;
    @api lookupValueChanged=false;
    nameLookup='';

  
    handleChange(event) {
        event.preventDefault();
        this.val = event.detail.value[0];
        this.lookupValueChanged=true;
        this.getLookupName();
        this.showLookup = (this.val != null || this.val !=undefined) ? false : true;  
    }



    @api 
    get value()
    { 
       return this.val;
    }
    set value(val)
    { 
       this.val=val;
       this.lookupValueChanged=false;
       this.getLookupName();
    }
    
    connectedCallback()
    { 
       this.val=this.value;
       this.getLookupName();
    }

    getLookupName()
    { 
        if(this.val)
        {
        if(this.fieldName=='Currency__c')
        { 
            getCurrencyDetails({recordId:this.val})
            .then(result=> 
                { 
                    this.nameLookup=result.Name;
                    if(this.lookupValueChanged)
                       this.dispatchCustomEvent('valuechange', this.context, this.val, this.label, this.nameLookup);
                    else
                       this.dispatchCustomEvent('loaddata', this.context, this.val, this.label, this.nameLookup);
                })
                .catch(error=> { 
                    console.log(JSON.stringify(error));
                })
        }
        else
        {
            getRecordDetails({recordId:this.val})
            .then(result=> 
                { 
                    this.nameLookup=result.Name;
                    if(this.lookupValueChanged)
                    this.dispatchCustomEvent('valuechange', this.context, this.val, this.label, this.nameLookup);
                })
                .catch(error=> { 
                    console.log(JSON.stringify(error));
                })
        }   
        }
        else
        { 
            this.nameLookup='';
            if(this.lookupValueChanged)
               this.dispatchCustomEvent('valuechange', this.context, this.val, this.label, this.nameLookup);
            else
            { 
                this.dispatchCustomEvent('lookupedit', this.context, this.val, this.label, this.nameLookup); 
            }
        }
    }


    renderedCallback() {
        Promise.all([
            loadStyle(this, CustomDataTableResource),
        ]).then(() => { });
        if (!this.guid) {
            this.guid = this.template.querySelector('.lookupBlock').getAttribute('id');
         
            this.dispatchEvent(
                new CustomEvent('itemregister', {
                    bubbles: true,
                    composed: true,
                    detail: {
                        callbacks: {
                            reset: this.reset
                        },
                        template: this.template,
                        guid: this.guid,
                        name: 'c-datatable-lookup'
                    }
                })
            );
        }
    }

    
    reset = (context) => {
        if (this.context !== context) {
            this.showLookup = false;
        }
    }


    handleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        this.showLookup = true;
        this.getLookupName();
    }


    dispatchCustomEvent(eventName, context, value, label, name) {
        this.dispatchEvent(new CustomEvent(eventName, {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: context, value: value, label: label, name: name }
            }
        }));
    }


    getFieldName() {
        let fieldName = this.fields[0];
        fieldName = fieldName.substring(fieldName.lastIndexOf('.') + 1, fieldName.length);
        return fieldName;
    }
}