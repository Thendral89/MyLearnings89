import { LightningElement, api } from 'lwc';

export default class LwcMvReportsOut extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api relatedIds;

    showModal = false;
    emailAction = 'new';

    value = '';

    get options() {
        return [
            { label: 'Internal', value: 'Internal' },
            { label: 'External', value: 'External' },
        ];
    }

    handleNewEmailClose(){
       try{
        console.log('BB handleNewEmailClose');
        this.communicateToParent('close');
       }catch(err){
           alert('JS Error :: lwcMvReportsOut :: handleNewEmailClose')
           console.error(err)
       }
    }

    handleSubjectChange(){
       try{
           
       }catch(err){
           alert('JS Error :: lwcMvReportsOut :: handleSubjectChange')
           console.error(err)
       }
    }

    handleEmailSent(){
       try{
            console.log('BB handleEmailSent');
           this.communicateToParent('sent');
       }catch(err){
           alert('JS Error :: lwcMvReportsOut :: handleEmailSent')
           console.error(err)
       }
    }

    handleCancelAndClose(){
       try{
        console.log('BB handleCancelAndClose');
        this.communicateToParent('close');
       }catch(err){
           alert('JS Error ::  :: handleCancelAndClose')
           console.error(err)
       }
    }

    communicateToParent(actiontype){
       try{
           let event = new CustomEvent('reportsout', {
               detail: {
                   actionType: actiontype
               }
           });

           this.dispatchEvent(event);
       }catch(err){
           alert('JS Error ::  :: communicateToParent')
           console.error(err)
       }
    }
}