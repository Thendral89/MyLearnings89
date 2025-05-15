import { LightningElement,track } from 'lwc';
import  { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PollComponent extends LightningElement {
    @track question = '';
    options = [
        {id:'1',label: 'Option 1',value:''},
        {id:'2',label: 'Option 2',value:''}
    ]

    get isAskDisabled(){
        return !(this.question.trim() && this.options.every(option => option.value && option.value.trim()) );
    }
    handleQuestionChange(e){
        this.question = e.target.value;
    }
    handleOptionChange(e) {
        const optionId = e.target.dataset.id; 
        const enteredValue = e.target.value; 
    
        this.options = this.options.map(option => 
            option.id === optionId 
                ? { ...option, value: enteredValue } 
                : option 
        );
        console.log(JSON.stringify(this.options));  
        
    }
    
    handleAddOption(){
        this.options = [...this.options,{
            id: (this.options.length + 1).toString(), 
            label: 'Option '+(this.options.length + 1),
            value:''
        }];
    }
    handleRemoveOption(e) {
        const optionId = e.target.dataset.id;
       
        this.options = this.options
            .filter(option => option.id !== optionId)
            .map((option, index) => ({
                id: (index + 1).toString(), 
                label: 'Option ' + (index + 1),
                value: option.value
            }));
    }
    handleAsk(){
        this.question = '';
        this.options = this.options
                .map((option) => ({
                        ...option,
                        value: ''
                }));
        console.log(JSON.stringify(this.options));
        
        this.showToast('Seccussful!','success','dismissable','Poll created successfully');
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