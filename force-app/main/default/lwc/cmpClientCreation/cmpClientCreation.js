import { LightningElement,track,api,wire } from 'lwc';
//Importing Custom Labels
import clientIntakeAnnouncementheader from '@salesforce/label/c.Client_Intake_Announcement_Header';
import clientIntakeAnnounceSubText from '@salesforce/label/c.Client_Intake_Announcement';
import Toast from 'lightning/toast';
import { getObjectInfo, getPicklistValuesByRecordType,getPicklistValues } from "lightning/uiObjectInfoApi";
// Client Object Fields for Step:1
import CLIENT_OBJECT from '@salesforce/schema/SymphonyLF__Client__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account'; 
import COUNTRY_CODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import STATE_CODE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// Importing Apex Class method
import saveClient from '@salesforce/apex/ClientController.saveClient';


export default class CmpClientCreation extends LightningElement {

   @track steps = JSON.parse('[{"id":1,"labelName":"Basic Information","URL":"#" ,"className":"active" }' + 
    ',{"id":2,"labelName":"Billing Information"       ,"URL":"#" ,"className":""}' +
    ',{"id":3,"labelName":"Contract Information"       ,"URL":"#" ,"className":""}' + 
    ']');
    

    @track announcements = clientIntakeAnnounceSubText;
    @track announcementHeader = clientIntakeAnnouncementheader;

    @api showmodal;
    showOriginatingAttorneyMandatory = false;
    showRateCodeMandatory = false;
    @api createdClientName;
    //@api recordId;
    
    countryPicklistValues = [];
    countryPicklistValuesMap = new Map();
    statePicklistValues = [];
    @track countryOptions = [];
    @track stateOptions = [];
    defaultRecordTypeId;
    selectedCountry;

    get getCountryOptions() {
        return this.countryOptions;
    }

    get getProvinceOptions() {
        return this.stateOptions[this.selectedCountry] || [];
    }

    // Fetch default Record Type ID
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    // Fetch country picklist values
    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: COUNTRY_CODE_FIELD })
    countryPicklistValues({ data, error }) {
        if (data) {
            this.countryOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            console.error('Error retrieving country picklist values', error);
        }
    }

    // Fetch state picklist values and map to countries
    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: STATE_CODE_FIELD })
    statePicklistValues({ data, error }) {
        if (data) {
            const controllerValues = data.controllerValues;
            const values = data.values;

            const stateMap = {};

            values.forEach(state => {
                const controllerKey = state.validFor[0];
                const countryIsoCode = Object.keys(controllerValues).find(key => controllerValues[key] === controllerKey);
                if (!stateMap[countryIsoCode]) {
                    stateMap[countryIsoCode] = [];
                }
                stateMap[countryIsoCode].push({ label: state.label, value: state.value });
            });

            this.stateOptions = stateMap;
        } else if (error) {
            console.error('Error retrieving state picklist values', error);
        }
    }



    // @wire(getObjectInfo, { objectApiName: CLIENT_OBJECT })
    // objectInfo;

    // map_CountryPicklistValues = new Map();
    // @wire(getPicklistValuesByRecordType, {
    //     objectApiName: CLIENT_OBJECT,
    //     recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    // })
    // wiredPicklistValues({ error, data }) {
    //     if (data) {
    //          const countryPicklistValues1 = data.picklistFieldValues.SymphonyLF__Address__CountryCode__s.values;
           
    //         countryPicklistValues1.map(picklistValue => {
    //                 this.map_CountryPicklistValues.set(picklistValue.label, picklistValue.value);
    //         });
    //     } else if (error) {
    //         console.error('Error fetching picklist values:', error);
    //     }
    // }

    @track currentStep = 'basicDetailsSection';
    @track currentStepIsBasicDetails;
    @track mapOfFieldValues = [];
    @track step1 = true;
    
    step1Open=true;
    step2Open = false;
    step3Open = false

    @track clientRecord = {};
    hasError;
    
    
    hideModalBox(){
        this.showmodal = false;
        const eve = new CustomEvent('onclosepopup',{
            detail:this.showmodal
        })
        this.dispatchEvent(eve);
    }
    
    
    @track phone1;
    @track fax1;
    @track clientsName='';
    onclientNameChange(event){
        this.clientsName = event.target.value;
        this.clientRecord.Name = this.clientsName;        
    }

    @track oopen=false;
    @track v_HowDidClientHearAboutUs;
    onHowDidClientHearAboutUsSelected(event){
        if(event.detail === 'Other'){this.oopen=true;}
        else{ this.oopen=false;
            this.clientOtherSource = '';
            this.clientRecord.Other_Source__c  = '';
        }
        this.v_HowDidClientHearAboutUs = event.detail;
        this.clientRecord.How_did_the_client_hear_about_us__c = this.v_HowDidClientHearAboutUs;
        
    }

    @track clientOtherSource='';
    onOtherSourceChange(event){
        this.clientOtherSource = event.target.value;
        this.clientRecord.Other_Source__c  = this.clientOtherSource;
    }

    @track emailRegex = "[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$";
    @track clientEmail='';
    onEmailChange(event){
        this.clientEmail = event.target.value;
        this.clientRecord.Email__c = this.clientEmail;
    }

    @track clientPhone='';
    onPhoneChange(event){
        this.clientPhone = event.target.value;
        this.clientRecord.SymphonyLF__Telephone__c = this.clientPhone;  
    }

    @track clientFax;
    onFaxChange(event){
        this.clientFax = event.target.value;
        this.clientRecord.SymphonyLF__Fax__c = this.clientFax;
    }
    @track clientCity='';
    @track clientStreet='';
    @track clientCountry='';
    @track clientPostal='';
    @track clientState;
    @track clientcountryCode;

    onClientAddressChange(event){
        this.clientStreet = event.target.street;
        this.clientCity = event.target.city;
        this.clientCountry = event.target.country;
        this.selectedCountry = event.target.country;
        this.clientState = event.target.province;
        this.clientPostal = event.target.postalCode;
        console.log('this.clientCountry :: ',this.clientCountry);
    }

    
    v_billingInfoSame = false;
    onIsBillingAddressSame(event){
        this.v_billingInfoSame = event.target.checked == true ? true : false;
        const address = this.template.querySelector('lightning-input-address');
        const isValid = address.checkValidity();
        if(this.v_billingInfoSame === true){
            this.billingPhone = this.clientPhone;
            this.billingFax = this.clientFax;
            this.billingEmail = this.clientEmail;
            this.billingCity = this.clientCity;
            this.billingCountry = this.clientCountry;
            this.billingPostal = this.clientPostal;
            this.billingState = this.clientState;
            this.billingStreet = this.clientStreet;
        }
        // To solve https://maxval.atlassian.net/browse/MCC-369
        else{
            this.billingPhone = '';
            this.billingFax ='';
            this.billingEmail = '';
            this.billingCity = '';
            this.billingCountry ='';
            this.billingPostal ='';
            this.billingState = '';
            this.billingStreet ='';
        }
        
    }

    step1Next(){
        this.basicDetailsValidation();
        
    }

    @track hasError = false;
    basicDetailsValidation(){
        if(
            (this.clientsName=='') 
            || (this.clientEmail == '') 
            || (this.clientPhone == '') 
            || (this.clientCity =='') 
            || (this.clientState =='' ) 
            || (this.clientStreet =='' ) 
            || (this.clientCountry =='' ) 
            || (this.clientPostal =='')          
        ){
            this.showErrorToast();
            this.validAddress = false;
            this.hasError = true;
            return;
        }
        else{
            if((this.clientOtherSource == '' && this.v_HowDidClientHearAboutUs == 'Other')){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'error',
                        message: 'Please select Other Source?',
                        variant: 'error',
                    }),
                );
            }
            else{
                this.steps = JSON.parse('[{"id":1,"labelName":"Basic Information","URL":"#" ,"className":"" }' + 
                                ',{"id":2,"labelName":"Billing Information"       ,"URL":"#" ,"className":"active"}' +
                                ',{"id":3,"labelName":"Contract Information"       ,"URL":"#" ,"className":""}' + 
                                ']');
                                this.step2Open = true;
                                this.step1Open = false;
            }
        }
    }


    step2Previous(){
        this.steps = JSON.parse('[{"id":1,"labelName":"Basic Information","URL":"#" ,"className":"active" }' + 
                                ',{"id":2,"labelName":"Billing Information"       ,"URL":"#" ,"className":""}' +
                                ',{"id":3,"labelName":"Contract Information"       ,"URL":"#" ,"className":""}' + 
                                ']');
        this.step2Open = false;
        this.step1Open = true;
    }
    step2Next(){
        this.billingDetailsValidation();
    }
    step3Previous(){
        this.steps = JSON.parse('[{"id":1,"labelName":"Basic Information","URL":"#" ,"className":"" }' + 
                                ',{"id":2,"labelName":"Billing Information"       ,"URL":"#" ,"className":"active"}' +
                                ',{"id":3,"labelName":"Contract Information"       ,"URL":"#" ,"className":""}' + 
                                ']');

        this.step2Open = true;
        this.step3Open = false;
        
    }

    //Step -2
    @track attentionName;
    onAttentionChange(event){
        this.attentionName = event.target.value;
        this.clientRecord.Attention__c = this.attentionName;
    }
    @track billingPhone='';
    onbillingPhoneChange(event){
        this.billingPhone = event.target.value;
    }
    @track billingEmail='';
    onbillingEmailChange(event){
        this.billingEmail = event.target.value;
    }
    @track billingFax;
    onbillingFaxChange(event){
        this.billingFax = event.target.value;
    }
    @track billingAddress='';
    @track billingCity='';
    @track billingStreet='';
    @track billingCountry='';
    @track billingPostal='';
    @track billingState='';

    onBillingAddressChange(event){
        this.billingStreet = event.target.street;
        this.billingCity = event.target.city;
        this.billingCountry = event.target.country;
        this.selectedCountry = event.detail.country;
        this.billingState = event.target.province;
        this.billingPostal = event.target.postalCode;
    }

    
    billingDetailsValidation(event){
        if(
            (this.billingPhone=='') ||(this.billingEmail=='') ||( this.billingStreet=='' || this.billingStreet==undefined) 
            ||( this.billingCity=='' || this.billingCity==undefined)  ||(this.billingState=='' || this.billingState==undefined) ||( this.billingCountry=='' || this.billingCountry==undefined) 
            ||( this.billingPostal=='' || this.billingPostal==undefined) 
            
        ){
            this.hasError = true;
            this.showErrorToast();
        }
        else{
            this.steps = JSON.parse('[{"id":1,"labelName":"Basic Information","URL":"#" ,"className":"" }' + 
                                ',{"id":2,"labelName":"Billing Information"       ,"URL":"#" ,"className":""}' +
                                ',{"id":3,"labelName":"Contract Information"       ,"URL":"#" ,"className":"active"}' + 
                                ']');
            this.hasError = false;
            //Navigate to Next Step 3
            this.step2Open = false;
            this.step3Open = true;
        }

    }

    //Step-3
    @track discount='';
    onChangeDiscount(event){
        if((event.target.value >=0 && event.target.value<=100) || (this.discount='')){
            this.discount = event.target.value;
            this.clientRecord.Discount_how_much__c = this.discount;
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: 'Discount Should be in Between 0 to 100.',
                    variant: 'error',
                }),
            );
        }
         
    }
     @track rateCode = '';
    onChangeRateCode(event){
        this.rateCode = event.target.value;
        this.showRateCodeMandatory = false;
        this.clientRecord.Rate_Code__c = this.rateCode;
    }
    
    @track ManagingAttorney;
    lookupManagingAttorney(event){
        // if(event.detail.selectedRecord != undefined){
        //     this.ManagingAttorney = event.detail.selectedRecord.Id;
        if(event.detail != null && event.detail.length > 0){
            this.ManagingAttorney =  event.detail[0].Id;
            this.clientRecord.Managing_Supervising_Attorney__c = this.ManagingAttorney;
        }
        else{
            this.ManagingAttorney = '';
            this.clientRecord.Managing_Supervising_Attorney__c='';
        }

        
    }
    @track OriginatingAttorney;
    lookupOriginatingAttorney(event){
        this.showOriginatingAttorneyMandatory = false;
        // if(event.detail.selectedRecord != undefined){
        if(event.detail != null && event.detail.length > 0){
            // this.OriginatingAttorney = event.detail.selectedRecord.Id;
            this.OriginatingAttorney = event.detail[0].Id;
            this.clientRecord.Originating_Attorney__c = this.OriginatingAttorney;
        }
        else{
            this.OriginatingAttorney = '';
            this.clientRecord.Originating_Attorney__c='';
        }
    }
    @track WorkingAttorney;
    lookupWorkingAttorney(event){
        // if(event.detail.selectedRecord != undefined){
        //     this.WorkingAttorney = event.detail.selectedRecord.Id;
        if(event.detail != null && event.detail.length > 0){
            this.WorkingAttorney = event.detail[0].Id;
            this.clientRecord.Working_Assigned_Attorney__c = this.WorkingAttorney;
        }
        else{
            this.WorkingAttorney = '';
            this.clientRecord.Working_Assigned_Attorney__c='';
        }
    }
    @track ResponsibleAttorney;
    lookupReponsibleAttorney(event){
        // if(event.detail.selectedRecord != undefined){
        //     this.ResponsibleAttorney = event.detail.selectedRecord.Id;
        if(event.detail != null && event.detail.length > 0){
            this.ResponsibleAttorney = event.detail[0].Id;
            this.clientRecord.Responsible_Billing_Attorney__c = this.ResponsibleAttorney;
        }
        else{
            this.ResponsibleAttorney = '';
            this.clientRecord.Responsible_Billing_Attorney__c='';
        }
    }

    @track b_SpecialBilling;
    
    @track b_PaperCopyOfDibusement;
    onPaperCopyOfDibusement(event){
        this.b_PaperCopyOfDibusement = event.target.checked;
        this.clientRecord.Paper_copy_of_disbursements_with_bills__c = this.b_PaperCopyOfDibusement; 
    }
    @track b_IsThisProBono;
    onIsThisProBono(event){
        this.b_IsThisProBono = event.target.checked;
        this.clientRecord.Is_this_pro_bono__c = this.b_IsThisProBono; 
    }
    @track b_TaskBasedBilling;
    onTaskBasedBilling(event){
        this.b_TaskBasedBilling = event.target.checked;
        this.clientRecord.Task_based_billing__c = this.b_TaskBasedBilling; 
    }
    @track b_EngagementLetterRecieve;
    onEngagementLetterRecieve(event){
        this.b_EngagementLetterRecieve = event.target.checked;
        this.clientRecord.Engagement_letter_received__c = this.b_EngagementLetterRecieve; 
    }
    @track b_PaperBillsOrEmail;
    onPaperBillsOrEmail(event){
        this.b_PaperBillsOrEmail = event.target.checked;
        this.clientRecord.Paper_Bills_or_Email__c = this.b_PaperBillsOrEmail; 
    }
    @track b_RetainerRecieved;
    onRetainerRecieved(event){
        this.b_RetainerRecieved = event.target.checked;
        this.clientRecord.Retainer_received__c = this.b_RetainerRecieved; 
    }
    @track b_LEDESFilesRequired;
    onLEDESFilesRequired(event){
        this.b_LEDESFilesRequired = event.target.checked;
        this.clientRecord.LEDES_files_required__c = this.b_LEDESFilesRequired; 
    }
    @track v_specialBilling;
    onSpecialBillingChange(event){
        this.v_specialBilling = event.target.value;
        this.clientRecord.Any_other_special_billing_instructions__c = this.v_specialBilling; 
    }
    

    titleNotificationText='';
    messageText='';
    variant='';

    CreatedClientRecord;
    CreatedClientRecordError;

    @track showSpinner = false;
    createClient(){
        // Client Address
        this.clientRecord.SymphonyLF__Address__City__s = this.clientCity;
        this.clientRecord.SymphonyLF__Address__Street__s = this.clientStreet;
        //this.clientRecord.SymphonyLF__Address__CountryCode__s = this.map_CountryPicklistValues.get(this.clientCountry);
        this.clientRecord.SymphonyLF__Address__CountryCode__s = this.clientCountry;
        this.clientRecord.SymphonyLF__Address__StateCode__s = this.clientState;
        this.clientRecord.SymphonyLF__Address__PostalCode__s = this.clientPostal;

        // Billing Address
        this.clientRecord.Billing_Email__c = this.billingEmail;
        this.clientRecord.Billing_Phone__c = this.billingPhone;
        this.clientRecord.Billing_Fax__c = this.billingFax;
        this.clientRecord.Billing_Address__City__s = this.billingCity;
        this.clientRecord.Billing_Address__Street__s = this.billingStreet;
       // this.clientRecord.Billing_Address__CountryCode__s = this.map_CountryPicklistValues.get(this.billingCountry);
        this.clientRecord.Billing_Address__CountryCode__s = this.billingCountry;
        this.clientRecord.Billing_Address__StateCode__s = this.billingState;
        this.clientRecord.Billing_Address__PostalCode__s = this.billingPostal;

        // Defaults
        this.clientRecord.SymphonyLF__Entity_Size__c = 'Not Available';
        this.clientRecord.SymphonyLF__Active__c = false;
        this.clientRecord.Client_Status__c = 'Yet to Engage';
        this.clientRecord.SymphonyLF__Client_Classification__c = 'Client';
        this.clientRecord.Initiated_from_Conflict_Check__c = true;
        this.clientRecord.SymphonyLF__Master_Company__c = true; //MCC-1036
        
        this.clientModuleValidation();
        
        
    }
    clientModuleValidation(){
        this.hasError = false;
        this.showOriginatingAttorneyMandatory = this.OriginatingAttorney == undefined;
        this.showRateCodeMandatory = this.rateCode == '';
        if(this.rateCode == '' || this.OriginatingAttorney == undefined){
            this.hasError = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill Rate Code and Originating Attorney.',
                    variant: 'error',
                }),
            );
        }
        else{
            this.saveClient();
            console.log('record is going to create. . .');
        }
    }

    saveClient(){
        this.showSpinner = true;
        saveClient({objClient: this.clientRecord})
        .then(result => {
            // Clear the user enter values
            this.showmodal = false;
            this.createdClientName = this.clientsName;
            this.CreatedClientRecord = result;
            console.log(this.CreatedClientRecord.Id);
            
            const eve = new CustomEvent('clientcreation',{
                detail:this.CreatedClientRecord.Id
            })
            this.dispatchEvent(eve);
            this.showSpinner = false;
            this.titleNotificationText = 'Success';
            this.messageText = 'New Client record created successfully.';
            this.variant = 'success';
            this.showToastNotification();
            
        })
        .catch(error => {
            this.CreatedClientRecordError = error;
            console.log('Error during Client record Creation.', JSON.stringify(error));
        });
    }

    showToastNotification() {
        const evt = new ShowToastEvent({
        title: this.titleNotificationText,
        message: this.messageText,
        variant: this.variant,
        });
        this.dispatchEvent(evt);
    }
    showErrorToast(){
        Toast.show({
            label: 'Validation Errors',
            message: 'Please fill required fields.',
            mode: 'dismissible',
            variant: 'error'
        }, this);
    }


    handleSubmit( event )
    {
        console.log('all Fields');
        let fields = event.detail.fields;
        event.preventDefault();
        console.log('all Fields',fields);
        this.template.querySelector( 'lightning-record-edit-form' ).submit( fields );
    }
    handleError(event){
        console.log('error occured while creating a client record');
    }
    handleSuccess( event ) {
        console.log( 'Updated Record Id is ', event.detail.id );
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Successful Record Update',
                message: 'Record Updated Surccessfully!!!',
                variant: 'success'
            })
        );
    }

}