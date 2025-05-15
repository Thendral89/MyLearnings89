import { LightningElement,track } from 'lwc';
import  { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class QuestionComponent extends LightningElement {
    @track question = '';
    @track richTextValue = '';

    handleQuestionChange(e){
        this.question = e.target.value;
    }
    get isAskDisable(){
        return !this.question.trim();
    }
    handleChange(e){
        this.richTextValue = e.target.value;
        const plainText = this.richTextValue
            ?.replace(/<[^>]*>/g, '') // Remove HTML tags
            ?.replace(/&nbsp;/g, ' ') // Replace &nbsp; with space
            ?.trim();
        console.log('rich text value ', plainText);
    }
    handleAsk(){
        this.question = '';
        this.richTextValue = '';
        this.showToast('Seccussful!','success','dismissable','Question asked successfully')

    }
    showToast(title,variant,mode,message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: mode,
            message: message
        });
        this.dispatchEvent(event);
    }
}