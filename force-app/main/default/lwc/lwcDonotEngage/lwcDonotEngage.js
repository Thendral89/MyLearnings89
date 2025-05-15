import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Toast from 'lightning/toast';
import { deleteRecord } from 'lightning/uiRecordApi';


import deleteClientRecord from '@salesforce/apex/ClientController.deleteClientRecord';

export default class LwcJKDonotEngage extends LightningElement {
@api showDonotEngagementmodal;
@api conflictCheckId;
@api selectedClientStatus;
@api selectedClientId;
@track showSpinner = false;

    connectedCallback() {
        this.showDonotEngagementmodal = true;
        console.log('this.conflictCheckId :::::::::::::: ',this.conflictCheckId);
    }

    cancelButton(){
        this.showDonotEngagementmodal=false;
        const eve = new CustomEvent('showdonotengagementmodal',{
                detail:this.showDonotEngagementmodal
            })
            this.dispatchEvent(eve);
    }

    async finishButton(){
        this.showSpinner = true;
        
        //alert('Docketing and Matter Engagement Modal has been Created...');
        // Delete conflict check record if the status is Yet to Engage 
        

        if(this.conflictCheckId === undefined){
            this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error While Deleting record',
                        message: 'Pass the Conflict check record Id to delete',
                        variant: 'error',
                    }),
                );
            this.showSpinner = false;
            return;
        }
        else{
                try {
                  //  await deleteRecord(this.conflictCheckId);
                    // console.log('this.selectedClientId ',this.selectedClientId);
                    // console.log('this.selectedClientStatus ',this.selectedClientStatus);
                    // if(this.selectedClientStatus === 'Yet to Engage') {
                    //     await deleteRecord(this.selectedClientId);
                    // }
                    deleteClientRecord({recordId : this.conflictCheckId })
                    .then(res =>{
                        this.showSpinner = false;
                        Toast.show({
                            label: 'Success',
                            message: 'Conflict Check Record deleted.',
                            mode: 'dismissible',
                            variant: 'success'
                        }, this);
                        this.showEngagementmodal=false;
                        const eve = new CustomEvent('showdonotengagementmodal',{
                                detail:this.showDonotEngagementmodal
                            })
                        this.dispatchEvent(eve);
                    })
                    .catch(err =>{
                        console.log('OUTPUT : ',err);
                    })
                    this.showSpinner = false;
                    
                    
                } catch (error) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting record',
                            message: reduceErrors(error).join(', '),
                            variant: 'error'
                        })
                    );
                }
                this.showSpinner = false;
        }
    }
}

//deleteRecord(this.conflictCheckId)
// .then(() => {
                        
// })
// .catch(error => {
//     this.showSpinner = false;
//     console.log(error);
//     this.dispatchEvent(
//         new ShowToastEvent({
//             title: 'Error While Deleting record',
//             message: error.body.message,
//             variant: 'error',
//         }),
//     );
// });