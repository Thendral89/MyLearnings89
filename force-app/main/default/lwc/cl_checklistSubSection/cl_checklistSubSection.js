import { api, LightningElement, track } from 'lwc';
import { updateRecord } from "lightning/uiRecordApi";

export default class Cl_checklistSubSection extends LightningElement {
    @api 
    get subSectionData() {
        return this._subSectionData;
    }
    set subSectionData(value) {
        if(value) {
            this._subSectionData = value;
        } else {
            this._subSectionData = {};
        }

        this.processChecklistInstanceItems();
    }
    @api isSecretary;
    @api isAttorney;
    @api isDoubleChecker;
    @api isSecretaryEditable;
    @api isAttorneyEditable;
    @api isDoubleCheckerEditable;

    @track _subSectionData = {}

    get isSecretaryDisabled() {
        return !this.isSecretaryEditable
    }

    get isAttorneyDisabled() {
        return !this.isAttorneyEditable
    }
    get isDoubleCheckerDisabled() {
        return !this.isDoubleCheckerEditable
    }

    get isDisabled() {
        if(this.isSecretary) {
            return this.isSecretaryDisabled
        } else if(this.isAttorney) {
            return this.isAttorneyDisabled
        } else if(this.isDoubleChecker) {
            return this.isDoubleCheckerDisabled
        }
        return true;
    }

    connectedCallback(event) {
        // console.log('isSecretary----',this.isSecretary);
        // console.log('isAttorney----',this.isAttorney);
        // console.log('isDoubleChecker----',this.isDoubleChecker);
        // console.log('isDisabled----',this.isDisabled);
        
    }

    handleChange(event) {
        const checked = event.target.checked;
        const index = event.currentTarget.dataset.index;
        const field = event.currentTarget.dataset.field;

        this._subSectionData.itemList[index][field] = checked;

        this.processChecklistInstanceItems();

        const itemdata = this._subSectionData.itemList[index];

        console.log('itemdata---'+JSON.stringify(itemdata));
        
        const fields = {};
        fields['Id'] = itemdata.id;
        fields['Attorney_Completed__c'] = itemdata.attorneyCompleted;
        fields['Double_Checker_Completed__c'] = itemdata.doubleCheckerCompleted;
        fields['Secretary_Completed__c'] = itemdata.secretoryCompleted;

        const recordInput = { fields };

        this.saveRecordData(recordInput);

    }

    processChecklistInstanceItems() {
        try {
            const subSectionData = JSON.parse(JSON.stringify(this._subSectionData));
            const itemList = (subSectionData.itemList || []).map(ele => {
                return {...ele, isSelected: (ele.secretoryCompleted || ele.attorneyCompleted || ele.doubleCheckerCompleted)}
            });

            subSectionData['itemList'] = itemList;
            this._subSectionData = subSectionData;

            // console.log('this._subSectionData----'+JSON.stringify(this._subSectionData));
            
        } catch (error) {
            console.log(error.message);
            
        }
    }


    saveRecordData(recordInput) {

        console.log('recordInput----'+JSON.stringify(recordInput));
        try {
            updateRecord(recordInput).then(() => {
                console.log('record Saved');
            }).catch((error) => {
                console.log('error----'+error.body.message);
            });
        } catch (error) {
            console.log('error-----'+error.message);
            
        }
    }
    
}