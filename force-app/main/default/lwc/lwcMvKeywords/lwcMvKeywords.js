import { LightningElement, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import addKeywords from '@salesforce/apex/KeywordsController.addKeywords';
// import addKeywordsAssets from '@salesforce/apex/KeywordsController.addKeywordsAssets';
import removeKeywordAssociations from '@salesforce/apex/KeywordsController.removeKeywordAssociations';
import getKeywords from '@salesforce/apex/KeywordsController.getKeywords';
import KEYWORD_OBJECT from '@salesforce/schema/SymphonyLF__Keyword__c';
import KEYWORD_NAME_FIELD from '@salesforce/schema/SymphonyLF__Keyword__c.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcMvKeywords extends LightningElement {
    @api recordId;
    @api objectApiName;
    RECORD_CREATE_SUCCESS_MESSAGE = 'New keyword created successfully.';

    disableAutoDropdown = true;
    @api showKeywords = false;
    keywords;

    selectedCaseId = '';
    clientIdCondition = '';

    addIcon = true;
    @api noResultMsg = 'No result found.Press Enter to add new keyword';

    @api assetType;
 //   @api listOfRecordIds;

    @track renderSelector = true;


    connectedCallback(){
       try{
            this.fetchKeywords();
       }catch(err){
           console.error('JS Error ::  :: connectedCallback')
           console.error(err)
       }
    }

    fetchKeywords(){
       try{
           getKeywords({
            "recordId": this.recordId,
            "objectApiName": this.objectApiName
           })
           .then( response => {
               try{
                    this.keywords = response;

                    if(this.keywords && Array.isArray(this.keywords)){
                        this.showKeywords = true;
                        this.selectedCaseId = this.keywords.map(e=>e.keywordId).join(',');
                    }

               }catch(err){
                   console.error('JS Error in Server callback ::  :: fetchKeywords');
               }
           })
           .catch( error => {
               console.error('Server Error ::  :: fetchKeywords :: apexMethod => getKeywords');
               console.error(JSON.stringify(error));
           })
       }catch(err){
           console.error('JS Error ::  :: fetchKeywords')
           console.error(err)
       }
    }

    @track isValidKeyword = false;
    @track newKeywords = '';

     onKeywordsChange(event) {
        console.log('this.keywords--->',this.keywords);
        let newKeyword = event.detail;
        this.createKeyword(newKeyword);
    }

    async createKeyword(newKeyword){
        const fields = {};
        fields[KEYWORD_NAME_FIELD.fieldApiName] = newKeyword;
        const recordInput = { apiName: KEYWORD_OBJECT.objectApiName, fields };
        const keywordRecord = await createRecord(recordInput);
        if (keywordRecord.id != null) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.RECORD_CREATE_SUCCESS_MESSAGE,
                    variant: 'success'
                })
            );
            //this.selectedCaseId = keywordRecord.id.join(',');

            const eventDetail = [{
                Id: keywordRecord.id, 
                Name: keywordRecord.name 
            }];
            let keywordList = [];
            keywordList.push(keywordRecord.id);
            this.addTheKeyword(keywordList);

            this.disableAutoDropdown = true;
           
            this.renderSelector = false;
            // async so the DOM can tear down first
            Promise.resolve().then(() => {
            this.renderSelector = true;
            });
            
            //this.handleAddKeyword({ detail: eventDetail });

        }
         
    }

    

    handleAddKeyword(event){
       try{
        console.log('B 1111')
            console.log('handleSelectExistingSearchCase', JSON.stringify(event.detail));
            let keywordIdsToAdd = [];

            let existingKeywords = [];
            let existingKeywordsSet = {};
            if(this.keywords){
                this.keywords.forEach(e=>{
                    existingKeywords.push(e.keywordId);
                    existingKeywordsSet[e.keywordId] = e;
                });
            }
console.log('B existingKeywords', JSON.stringify(existingKeywords));
console.log('B existingKeywordsSet', JSON.stringify(existingKeywordsSet));
            
            for(let i=0; i<event.detail.length; i++){
                if( ! existingKeywordsSet[event.detail[i].Id]){
                    keywordIdsToAdd.push(event.detail[i].Id);
                    existingKeywords.push(event.detail[i].Id);
                    existingKeywordsSet[event.detail[i].Id] = event.detail[i].Id;
                }
            }

            console.log('B keywordIdsToAdd', JSON.stringify(keywordIdsToAdd));

           //this.addTheKeyword(keywordIdsToAdd);
            if (keywordIdsToAdd.length > 0) {
                this.addTheKeyword(keywordIdsToAdd);
            } else {
                console.log('No new keywords to add.');
            }
           this.selectedCaseId = existingKeywords.join(',');
           this.disableAutoDropdown = true;

           this.renderSelector = false;
            // async so the DOM can tear down first
            Promise.resolve().then(() => {
            this.renderSelector = true;
            });

           
                
       }catch(err){
           console.error('JS Error ::  :: handleSelectExistingSearchCase')
           console.error(err)
       }finally {
            setTimeout(() => {
            const combo = /** @type {HTMLElement} **/(
                event.currentTarget  
            );
            combo.blur();

            this.disableAutoDropdown = false;
            }, 0);
        }
    }


    addTheKeyword(keywordIds){
        if( (!keywordIds) || keywordIds.length == 0) {
             return;

        }
       
       try{
        //console.log('listOfRecordIds:', JSON.stringify(this.listOfRecordIds));
        console.log('recordId : '+this.recordId+'      objectApiName : '+this.objectApiName+'   '+'keywordIds : '+keywordIds+'   '+'keywordIds.length : '+keywordIds.length);
        // if (this.assetType === 'Copyright') {
        //     if (!this.listOfRecordIds.length) {
        //         console.warn('No recordIds provided for Copyright');
        //         return;
        //     }
        //     addKeywordsAssets({
        //         keywordIds: keywordIds,
        //         recordIds : this.listOfRecordIds,
        //         objectApiName: this.objectApiName
        //     })
        //     .then(response => {
        //         this.keywords = response;
        //         console.log('Keywords (assets):', this.keywords);
        //     })
        //     .catch(error => {
        //         console.error('Error in addKeywordsAssets:', JSON.stringify(error));
        //     });
        // } else{
            addKeywords({
                "keywordIds": keywordIds,
                "recordId": this.recordId,
                "objectApiName": this.objectApiName
               })
               .then( response => {
                   try{
                       this.keywords = response;
                       console.log('test new array keyword : ',this.keywords);
                   }catch(err){
                       console.error('JS Error in Server callback ::  :: addTheKeyword');
                   }
               })
               .catch( error => {
                   console.error('Server Error ::  :: addTheKeyword :: apexMethod => addKeywords');
                   console.error(JSON.stringify(error));
               })
       // }
           
       }catch(err){
           console.error('JS Error ::  :: addTheKeyword')
           console.error(err)
       }
    }
    
    handleRemoveTheKeyword(event){
       try{
           let keywordAssociationId = event.target.name;
           console.log('keywordAssociationId', keywordAssociationId);
           this.removeTheKeyword([keywordAssociationId]);
       }catch(err){
           console.error('JS Error ::  :: handleRemoveTheKeyword')
           console.error(err)
       }
    }

    removeTheKeyword(keywordAssociationIds){
        if( (!keywordAssociationIds) || keywordAssociationIds.length == 0) return;
       try{
           removeKeywordAssociations({
            "keywordAssociationIds": keywordAssociationIds,
            "recordId": this.recordId,
            "objectApiName": this.objectApiName
           })
           .then( response => {
               try{
                   this.keywords = response;

                    this.selectedCaseId = response.map(e=>e.keywordId).join(',');

                    this.disableAutoDropdown = true;
               }catch(err){
                   console.error('JS Error in Server callback :: lwcMvHighlightsPanel :: removeTheKeyword');
               }
           })
           .catch( error => {
               console.error('Server Error :: lwcMvHighlightsPanel :: removeTheKeyword :: apexMethod => removeKeywordAssociations');
               console.error(JSON.stringify(error));
           })
       }catch(err){
           console.error('JS Error :: lwcMvHighlightsPanel :: removeTheKeyword')
           console.error(err)
       }
    }

    serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
           // ...error
        });
    }
}