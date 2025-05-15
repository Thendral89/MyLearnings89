import { LightningElement, api } from 'lwc';

export default class LwcDocketViewSubContent extends LightningElement {
    @api recordId;
    @api numberOfFiles = 0;

    get
    showFiles(){
       try{
           return ( this.numberOfFiles ? true : false );
       }catch(err){
           alert('JS Error ::  :: showFiles')
           console.error(err)
       }
    }
}