import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class BsTypeAttributeClickableDeleteIcon extends NavigationMixin(LightningElement) {
    @api contentDocumentId;
    @api sourceType;

    handleClick(event){
        try{
            const selectedEvent = new CustomEvent('deleteicon', { 
                composed: true,
                bubbles: true,
                detail: {"contentDocumentId" : this.contentDocumentId, "sourceType" : this.sourceType} 
            });
            this.dispatchEvent(selectedEvent);
        }catch(err){
            alert("JS Error :: BsTypeAttributeClickableDeleteIcon :: handleClick");
            console.error(err);
        }
    }

    navigateToFiles() {
        this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
              pageName: 'filePreview'
          },
          state : {
              selectedRecordId: this.contentDocumentId
          }
        })
      }
}