import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class LwcGenerateSDoc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    handleGenerateSdoc(){
       try{
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `/apex/SDOC__SDCreate1?id=${this.recordId}&Object=${this.objectApiName}&lightningnav=true`
                }
            });
       }catch(err){
           console.error('JS Error ::  :: handleGenerateSdoc')
           console.error(err)
       }
    }
}