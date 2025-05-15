import { LightningElement, api, wire, track } from 'lwc';
import getEmailMessage from '@salesforce/apex/mvCollaborationService.getEmailMessageObject';
import {NavigationMixin} from 'lightning/navigation'

export default class MvEmailMessageDisplay extends LightningElement {
    @api recordId;
    @track emailMessage;
    @track isRichText = false;
    @track isLoading = true; // Add loading state
    attachmentAvailable = false;
    emailMessageId;
    hasAttachment = false;

    connectedCallback() {
        this.fetchEmailMessage();
    }
    

    @api updateRecordId(value){
       try{
          this.recordId = value; 
          this.fetchEmailMessage();
       }catch(err){
           alert('JS Error ::  :: setRecordId')
           console.error(err)
       }
    }

    renderedCallback() {
        // If we have HTML and are using lwc:dom="manual", inject it
        if (this.emailMessage && this.emailMessage.HtmlBody) {
            const container = this.template.querySelector('.responsive-email-body');
            if (container) {
                container.innerHTML = this.emailMessage.HtmlBody;
            }
        }
    }

    incoming = false;
    fetchEmailMessage() {
        if (!this.recordId) return;

        getEmailMessage({ trackerId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log(
                        'result',JSON.stringify(result));
                    this.emailMessage = result;
                    this.isRichText = /<\/?[a-z][\s\S]*>/i.test(result.HtmlBody);
                    this.emailMessageId = result.Id;
                    this.hasAttachment = result.HasAttachment;
                    this.incoming = result.Incoming;
                }
            })
            .catch((error) => {
                console.error('Error fetching email message or attachments:', error);
            })
            .finally(() => {
                this.isLoading = false; // Stop loading after fetching data
            });
    }

    allAttachments =[]
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }

    downloadHandler(event) {
        const attachmentId = event.target.dataset.id;
        const attachmentUrl = this.allAttachments.find(att => att.value === attachmentId)?.url;

        if (attachmentUrl) {
            // Open the attachment URL in a new tab to download
            window.open(attachmentUrl, '_blank');
        } else {
            console.error('Attachment URL not found');
        }
    }
}