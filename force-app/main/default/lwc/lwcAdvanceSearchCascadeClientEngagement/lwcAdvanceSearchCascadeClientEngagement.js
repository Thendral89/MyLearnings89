import { LightningElement, api } from 'lwc';

const ARGUMENTS_DEFAULT = {
    'cascadeToMemAndDockets' : false
}

export default class LwcAdvanceSearchCascadeClientEngagement extends LightningElement {
    @api
    records;
    @api
    object;
    @api
    operationType;
    @api
    arguments = ARGUMENTS_DEFAULT;
    @api
    extensionClass;
    _isValid = false;

    changeToggle(event){
        try{
            let checked = event.target.checked;

            let args = this.arguments;
            args.cascadeToMemAndDockets = checked;
            
            this.arguments = args;
        }catch(err){
            alert('JS Error :: LwcAdvanceSearchCascadeClientEngagement :: changeToggle')
            console.error(err)
        }
    }
}