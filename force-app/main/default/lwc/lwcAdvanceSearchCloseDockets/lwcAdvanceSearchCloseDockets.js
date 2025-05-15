import { LightningElement, api } from 'lwc';
import Id from '@salesforce/user/Id';

const ARGUMENTS_DEFAULT = {
    'closeDockets' : false,
    'reasonToClose' : '',
    'closedBy' : Id
}

export default class LwcAdvanceSearchCloseDockets extends LightningElement {
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

    closeDockets = false;

    @api
    checkValidity(){
        try{
            let isValid = true;

            if(
                this.arguments.closeDockets
                &&
                (! this.arguments.reasonToClose)
            ){
                isValid = false;
            }

            return isValid;
        }catch(err){
            alert('JS Error :: lwcAdvanceSearchCloseDockets :: checkValidity')
            console.error(err)
        }
    }

    @api 
    reportValidity(){
        try{
            if(! this.arguments.closeDockets ){
                return;
            }
    
            if(! this.arguments.reasonToClose ){
                const textArea = this.template.querySelector('lightning-textarea');
                textArea.reportValidity();
                textArea.focus();
            }
        }catch(err){
            alert('JS Error :: lwcAdvanceSearchCloseDockets :: reportValidity')
            console.error(err)
        }
    }

    changeToggle(event){
        try{
            let checked = event.target.checked;

            let args = this.arguments;
            args.reasonToClose = '';
            
            if(checked){
                args.closeDockets = true;
                this.closeDockets = true;
            }
            else{
                args.closeDockets = false;
                this.closeDockets = false;
            }
            
            this.arguments = args;
        }catch(err){
            alert('JS Error :: lwcAdvanceSearchCloseDockets :: changeToggle')
            console.error(err)
        }
    }

    handleChangeReason(event){
        try{
            let args = this.arguments;
            args.reasonToClose = event.target.value;
            this.arguments = args;
        }catch(err){
            alert('JS Error :: lwcAdvanceSearchCloseDockets :: handleChangeReason')
            console.error(err)
        }
    }
}