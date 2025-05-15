import { LightningElement, api, track } from 'lwc';
import getResults from '@salesforce/apex/lwcMultiLookupController.getResults';

export default class LwcMultiLookup extends LightningElement {
    @api objectName = 'SymphonyLF__Person__c';
    @api fieldName = 'Name';
    @api isKeywordHierarchy = false;
    @api flagError = false;
    @api currentRecordId = '';
    @api label = '';
    @track searchRecords = [];
    @api selectedRecords = [];
    @api required = false;;
    @api iconName = 'action:user'
    @api LoadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @api variant;
    @api slectedToIds = [];


    connectedCallback() {
        try {
            
            console.log('5454',JSON.stringify(this.selectedRecords));
            
            var currentText = '';
            
       
            getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, selectedRecId: this.selectedRecords, isKeywordHierarchy: false, currentRecordId: '' })
                .then(result => {
                    console.log('787',JSON.stringify(result));
                    let selectedRecords = [];
                    for (let i = 0; i < result.length; i++) {
                        let singlePerson = {};
                        singlePerson.recId = result[i].recId;
                        singlePerson.recName = result[i].recName;

                        selectedRecords.push(singlePerson);
                    }
                    this.selectedRecords = selectedRecords;
                })
                .catch(error => {
                    console.log('-------error-------------' + error);
                    console.log(error);
                });

        }
        catch (err) {
            alert('aaaa');
            console.error('aaaa', err);
            console.error('aaaa', JSON.stringify(err));
        }
        //this method is only for person default



    }

    searchField(event) {

        var currentText = event.target.value;
        var selectRecId = [];
        for (let i = 0; i < this.selectedRecords.length; i++) {
            selectRecId.push(this.selectedRecords[i].recId);
        }
        this.LoadingText = true;
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, selectedRecId: selectRecId, isKeywordHierarchy: this.isKeywordHierarchy, currentRecordId: this.currentRecordId })
            .then(result => {
                this.searchRecords = result;
                this.LoadingText = false;

                this.txtclassname = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
                if (currentText.length > 0 && result.length == 0) {
                    this.messageFlag = true;
                }
                else {
                    this.messageFlag = false;
                }

                if (this.selectRecordId != null && this.selectRecordId.length > 0) {
                    this.iconFlag = false;
                    this.clearIconFlag = true;
                }
                else {
                    this.iconFlag = true;
                    this.clearIconFlag = false;
                }
            })
            .catch(error => {
                console.log('-------error-------------' + error);
                console.log(error);
            });

    }


    setSelectedRecord(event) {
        var recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        
        let newsObject = { 'recId': recId, 'recName': selectName };
        //let newsObject = { 'recId': recId};
        this.selectedRecords.push(newsObject);
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        //let selRecords = this.selectedRecords;
        console.log('107'+this.selectedRecords);
        
        let selRecords = [];
        

        for(let i =0; i < this.selectedRecords.length; i++)
        {
            selRecords.push(this.selectedRecords[i].recId);
        }

       
        //this.slectedToIds = selectRecId;
         
        
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        const selectedEvent = new CustomEvent('selected', { detail: { selRecords }, });
        
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    removeRecord(event) {
        let selectRecId = [];
        let selIds = [];
        for (let i = 0; i < this.selectedRecords.length; i++) {
            if (event.detail.name !== this.selectedRecords[i].recId)
            {
                selectRecId.push(this.selectedRecords[i]);
                selIds.push(this.selectedRecords[i].recId)
            }
        }
        this.selectedRecords = [...selectRecId];
        let selRecords = [...selIds];
        const selectedEvent = new CustomEvent('selected', { detail: { selRecords }, });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}