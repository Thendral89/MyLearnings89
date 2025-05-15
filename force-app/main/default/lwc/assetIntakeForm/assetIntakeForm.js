import { LightningElement, track, api, wire } from 'lwc';
import NavigationMixin from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { CurrentPageReference } from 'lightning/navigation';

import {
    IsConsoleNavigation,
    getFocusedTabInfo,
    setTabLabel,
    setTabIcon,
    refreshTab

} from 'lightning/platformWorkspaceApi';

const TAB_LABEL = 'Asset Intake Form';

export default class AssetIntakeForm extends LightningElement {

    @track patentBreadcrumb = JSON.parse('[{"id":1,"labelName":"Basic Details","URL":"#" ,"className":"active" }' +
        ',{"id":2,"labelName":"Personnel"       ,"URL":"#" ,"className":""}' +
        ',{"id":3,"labelName":"Applicants"       ,"URL":"#" ,"className":""}' +
        ',{"id":4,"labelName":"Innovators"       ,"URL":"#" ,"className":""}' +
        ',{"id":5,"labelName":"Jurisdiction"       ,"URL":"#" ,"className":""}' +
        ']');

    @track trademarkBreadcrumb = JSON.parse('[{"id":1,"labelName":"Basic Details","URL":"#" ,"className":"active" }' +
            ',{"id":2,"labelName":"Personnel"       ,"URL":"#" ,"className":""}' +
            ',{"id":3,"labelName":"Applicants"       ,"URL":"#" ,"className":""}' +
            ',{"id":4,"labelName":"Classes and Goods"       ,"URL":"#" ,"className":""}' +
            ',{"id":5,"labelName":"Jurisdiction"       ,"URL":"#" ,"className":""}' +
            ']');

    @track oppositionBreadcrumb = JSON.parse('[{"id":1,"labelName":"Basic Details","URL":"#" ,"className":"active" }' +
            ',{"id":2,"labelName":"Personnel"       ,"URL":"#" ,"className":""}' +
            ',{"id":3,"labelName":"Applicants"       ,"URL":"#" ,"className":""}' +
            ',{"id":4,"labelName":"Other Parties"       ,"URL":"#" ,"className":""}' +
            ',{"id":5,"labelName":"Jurisdiction"       ,"URL":"#" ,"className":""}' +
            ']');

    clientId ='';
    conflictCheckId ='' ;
    clientReferenceNumber = '';
    clientGroupNumber = '';
    isPatent = false;
    isTrademark = false;
    isDispute = false;
    isRenderedCallbackInitialized = false;
    tabId='';
    matterTitle = '';

    assetType;
    isLoaded = false;


    @track breadcrumb;
    @track breadcrumbWidth = "width:20%";
    @track showPersonnelDetails = false;
    @track showBasicDetails = true;
    @track showApplicantDetails = false;
    @track showInventorDetails = false;
    @track showJurisdictionDetails = false;
    @track intakeData = [];
    @track currentStage = 1;
    @track assetIntakeId;
    @track isNewFamily = false;
    @track showClassesAndGoods = false;
    @track showOtherparties = false;

    @wire(IsConsoleNavigation) isConsoleNavigation;

    @wire(CurrentPageReference)
    currentPageReference;
    

    

    async setCurrentTabLabel() {
        console.log('Console Navigation : ' + this.isConsoleNavigation);
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        setTabLabel(tabId, TAB_LABEL);
        setTabIcon( tabId, 'utility:edit_gpt', {
            iconAlt: 'Account Insights'
        });
    }
    rerendercomponent = false;
    refreshComponentData() {
        this.rerendercomponent = false;
        setTimeout(() => {
            this.rerendercomponent = true; 
        }, 10);
    }

    async connectedCallback() {
        try{

            this.setCurrentTabLabel();
            await getFocusedTabInfo().then((tabInfo) => {
                this.tabId = tabInfo.tabId;
                console.log('this.tabId',this.tabId);
            })
            if(this.clientId != this.currentPageReference.state.c__clientId || this.conflictCheckId != this.currentPageReference.state.c__conflictCheckId){
                this.refreshComponentData();
            }
            
            console.log('Connected Call Back');
            console.log('currentpageref state-->',this.currentPageReference.state);
            this.clientId = this.currentPageReference.state.c__clientId;
            this.conflictCheckId = this.currentPageReference.state.c__conflictCheckId;
            this.clientReferenceNumber = this.currentPageReference.state.c__clientReferenceNumber;
            this.clientGroupNumber = this.currentPageReference.state.c__clientGroupNumber;
            this.isPatent = this.currentPageReference.state.c__isPatent;
            this.isTrademark = this.currentPageReference.state.c__isTrademark;
            this.isDispute = this.currentPageReference.state.c__isDispute;
            this.matterTitle = this.currentPageReference.state.c__matterTitle;

            console.log('this.clientId',  this.clientId);
            console.log('this.conflictCheckId',  this.conflictCheckId);
            console.log('this.clientReferenceNumber',  this.clientReferenceNumber);
            console.log('this.clientGroupNumber',  this.clientGroupNumber);
            console.log('this.matterTitle',  this.matterTitle);


            if(this.isPatent){
                this.assetType = 'Patent';
                this.breadcrumb = this.patentBreadcrumb;
            }else if(this.isTrademark){
                this.assetType = 'Trademark';
                this.breadcrumb = this.trademarkBreadcrumb;
            }else if(this.isDispute){
                this.assetType = 'Opposition';
                this.breadcrumb = this.oppositionBreadcrumb;
            }

            console.log('this.isPatent',  this.isPatent);
            console.log('this.isTrademark',  this.isTrademark);

            this.isLoaded = true;
            
        }catch(err){
            alert('JS Error :: connectedCallback');
        }
    }

    navigateToBasicDetails() {
        try{
        this.showBasicDetails = true;
        this.showApplicantDetails = false;
        this.showPersonnelDetails = false;
        this.showInventorDetails = false;
        this.showJurisdictionDetails = false;
        this.showOtherparties = false;
        

        this.patentBreadcrumb[0].className = "active";
        this.patentBreadcrumb[1].className = "";
        this.patentBreadcrumb[2].className = "";
        this.patentBreadcrumb[3].className = "";
        this.patentBreadcrumb[4].className = "";

        this.trademarkBreadcrumb[0].className = "active";
        this.trademarkBreadcrumb[1].className = "";
        this.trademarkBreadcrumb[2].className = "";
        this.trademarkBreadcrumb[3].className = "";
        this.trademarkBreadcrumb[4].className = "";

        this.oppositionBreadcrumb[0].className = "active";
        this.oppositionBreadcrumb[1].className = "";
        this.oppositionBreadcrumb[2].className = "";
        this.oppositionBreadcrumb[3].className = "";
        this.oppositionBreadcrumb[4].className = "";

        this.currentStage = 1;
    }catch(err){
        alert('JS Error :: assetIntakeForm :: navigateToBasicDetails');
        this.handleAllErrorTypes( err );
    }
    }
    

    // async renderedCallback() {
    //     if (!this.isRenderedCallbackInitialized)
    //         await this.setTabTitle();
    //     this.isRenderedCallbackInitialized = true;
    // }


    // assetIntakeCreated(event){ 
    //     try{
    //     console.log ('Asset Intake Created : ' + JSON.stringify(event));
    //     if(event.detail.assetIntakeId){
    //     this.assetIntakeId = event.detail.assetIntakeId;
    //     }
    //     this.isNewFamily = event.detail.isNewFamily;
    //     this.currentStage = this.currentStage + 1;

    //     this.navigatetopersonneldetails( event );
    //     }catch(err){
    //         alert('JS Error :: assetIntakeForm :: assetIntakeCreated');
    //         this.handleAllErrorTypes( err );
    //     }
    // }

    handleAllErrorTypes(err){
        try{
            console.error(err);
            console.error( JSON.stringify(err) );
            console.error( this.serializeError(err) );
        }catch(err){
            alert('JS Error ::  :: handleAllErrorTypes')
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

    navigatetobasicdetails(event){
        try{
        console.log ('Asset Intake Created : ' + JSON.stringify(event));
        if(event.detail.assetIntakeId){
        this.assetIntakeId = event.detail.assetIntakeId;
        }
        this.currentStage = this.currentStage + 1;
        this.navigateToBasicDetails();
        }catch(err){
            alert('JS Error :: assetIntakeForm :: navigatetobasicdetails')
            this.handleAllErrorTypes( err );
        }
    }

    navigatetoapplicantdetails(event){
        try{
        console.log ('Asset Intake  : ' + JSON.stringify(event));
        if(event.detail.assetIntakeId){
        this.assetIntakeId = event.detail.assetIntakeId;
        }
      //  this.currentStage = this.currentStage + 1;

        this.showBasicDetails = false;
        this.showApplicantDetails = true;
        this.showPersonnelDetails = false;
        this.showInventorDetails = false;
        this.showJurisdictionDetails = false;
        this.showClassesAndGoods = false;
        this.showOtherparties = false;

        this.patentBreadcrumb[0].className = "";
        this.patentBreadcrumb[1].className = "";
        this.patentBreadcrumb[2].className = "active";
        this.patentBreadcrumb[3].className = "";
        this.patentBreadcrumb[4].className = "";

        this.trademarkBreadcrumb[0].className = "";
        this.trademarkBreadcrumb[1].className = "";
        this.trademarkBreadcrumb[2].className = "active";
        this.trademarkBreadcrumb[3].className = "";
        this.trademarkBreadcrumb[4].className = "";

        this.oppositionBreadcrumb[0].className = "";
        this.oppositionBreadcrumb[1].className = "";
        this.oppositionBreadcrumb[2].className = "active";
        this.oppositionBreadcrumb[3].className = "";
        this.oppositionBreadcrumb[4].className = "";

       // this.navigateToApplicantDetails();
    }catch(err){
        alert('JS Error :: assetIntakeForm :: navigatetoapplicantdetails')
        this.handleAllErrorTypes( err );
    }
    }

    navigatetopersonneldetails(event) {
        try{
        console.log ('Asset Intake  : ' + JSON.stringify(event));
        if(event.detail.assetIntakeId){
        this.assetIntakeId = event.detail.assetIntakeId;
        }
        
     //   this.currentStage = this.currentStage + 1;

        this.showBasicDetails = false;
        this.showPersonnelDetails = true;
        this.showApplicantDetails = false;
        this.showInventorDetails = false;
        this.showJurisdictionDetails = false;
        this.showOtherparties = false;

        this.patentBreadcrumb[0].className = "";
        this.patentBreadcrumb[1].className = "active";
        this.patentBreadcrumb[2].className = "";
        this.patentBreadcrumb[3].className = "";
        this.patentBreadcrumb[4].className = "";

        this.trademarkBreadcrumb[0].className = "";
        this.trademarkBreadcrumb[1].className = "active";
        this.trademarkBreadcrumb[2].className = "";
        this.trademarkBreadcrumb[3].className = "";
        this.trademarkBreadcrumb[4].className = "";

        this.oppositionBreadcrumb[0].className = "";
        this.oppositionBreadcrumb[1].className = "active";
        this.oppositionBreadcrumb[2].className = "";
        this.oppositionBreadcrumb[3].className = "";
        this.oppositionBreadcrumb[4].className = "";
        
        console.log('this.oppositionBreadcrumb', JSON.stringify(this.oppositionBreadcrumb));

        this.currentStage = 2;
      //  this.navigateToPersonnelDetails();
    }catch(err){
        alert('JS Error :: assetIntakeForm :: navigatetopersonneldetails')
        this.handleAllErrorTypes( err );
    }
    }

    navigatetoinventordetails(event) {
        try{
        console.log ('Asset Intake  : ' + JSON.stringify(event));
        if(event.detail.assetIntakeId){
        this.assetIntakeId = event.detail.assetIntakeId;
        }
    //    this.currentStage = this.currentStage + 1;

        this.showBasicDetails = false;
        this.showApplicantDetails = false;
        this.showJurisdictionDetails = false;
        this.showInventorDetails = true;
        this.showPersonnelDetails = false;
        this.showClassesAndGoods = true;
        this.showOtherparties = true;

        this.patentBreadcrumb[0].className = "";
        this.patentBreadcrumb[1].className = "";
        this.patentBreadcrumb[2].className = "";
        this.patentBreadcrumb[3].className = "active";
        this.patentBreadcrumb[4].className = "";

        this.trademarkBreadcrumb[0].className = "";
        this.trademarkBreadcrumb[1].className = "";
        this.trademarkBreadcrumb[2].className = "";
        this.trademarkBreadcrumb[3].className = "active";
        this.trademarkBreadcrumb[4].className = "";

        this.oppositionBreadcrumb[0].className = "";
        this.oppositionBreadcrumb[1].className = "";
        this.oppositionBreadcrumb[2].className = "";
        this.oppositionBreadcrumb[3].className = "active";
        this.oppositionBreadcrumb[4].className = "";

        this.currentStage = 5;

      //  this.navigateToInventorDetails();
    }catch(err){
        alert('JS Error :: assetIntakeForm :: navigatetoinventordetails')
        this.handleAllErrorTypes( err );
    }
    }

    navigatetojurisdictiondetails(event) {
        try{
        console.log ('Asset Intake  : ' + JSON.stringify(event));
        if(event.detail.assetIntakeId){
        this.assetIntakeId = event.detail.assetIntakeId;
        }
       // this.currentStage = this.currentStage + 1;

       this.showBasicDetails = false;
        this.showApplicantDetails = false;
        this.showJurisdictionDetails = true;
        this.showPersonnelDetails = false;
        this.showInventorDetails = false;
        this.showClassesAndGoods = false;
        this.showOtherparties = false;

        this.patentBreadcrumb[0].className = "";
        this.patentBreadcrumb[1].className = "";
        this.patentBreadcrumb[2].className = "";
        this.patentBreadcrumb[3].className = "";
        this.patentBreadcrumb[4].className = "active";

        this.trademarkBreadcrumb[0].className = "";
        this.trademarkBreadcrumb[1].className = "";
        this.trademarkBreadcrumb[2].className = "";
        this.trademarkBreadcrumb[3].className = "";
        this.trademarkBreadcrumb[4].className = "active";
        
        this.oppositionBreadcrumb[0].className = "";
        this.oppositionBreadcrumb[1].className = "";
        this.oppositionBreadcrumb[2].className = "";
        this.oppositionBreadcrumb[3].className = "";
        this.oppositionBreadcrumb[4].className = "active";

        this.currentStage = 5;

     //   this.navigateToJurisdictionDetails();
    }catch(err){
        alert('JS Error :: assetIntakeForm :: navigatetojurisdictiondetails')
        this.handleAllErrorTypes( err );
    }
    }

    handleNext(event){
          
        if(event.detail.assetIntakeId){
        this.assetIntakeId = event.detail.assetIntakeId;
        }
        if(event.detail.isNewFamily){
            this.isNewFamily = event.detail.isNewFamily;
        }
        
        let index = this.breadcrumb.find(d=>d.className=='active').id ;
        let element = this.breadcrumb.find(e=>e.id==index+1);
        
        if(element != undefined){
            console.log('element.labelName : ',element.labelName);
            this.setActiveClass(element.id);
            this.setShowDetails(element.labelName);
        }
       
    }

    handleBack(event){
        if(event.detail.assetIntakeId){
            this.assetIntakeId = event.detail.assetIntakeId;
        }

        let index = this.breadcrumb.find(d=>d.className=='active').id ;
        let element = this.breadcrumb.find(e=>e.id==index-1);
        
        if(element != undefined){
            this.setActiveClass(element.id);
            this.setShowDetails(element.labelName);
        }
        
    }

    handleActionNavigation(event){
         if(event.detail.assetIntakeId){
            this.assetIntakeId = event.detail.assetIntakeId;
        }

        let element = this.breadcrumb.find(e=>e.labelName==event.detail.currentPage);
        
        if(element != undefined){
            this.setActiveClass(element.id);
            this.setShowDetails(element.labelName);
        }

    }

    @track selectedAddress;

    handleAddressSelected(event) {
        this.selectedAddress = event.detail;
        console.log('selectedAddress--->',this.selectedAddress);
    }

    setShowDetails(labelName) {
  // Reset all details to false
   this.showBasicDetails = false;
   this.showPersonnelDetails = false;
   this.showApplicantDetails = false;
   this.showInventorDetails = false;
   this.showJurisdictionDetails = false;
   this.showOtherparties = false;
   this.showClassesAndGoods = false;

  // Set the corresponding variable to true based on the labelName
  switch (labelName) {
    case "Basic Details":
      this.showBasicDetails = true;
      break;
    case "Personnel":
      this.showPersonnelDetails = true;
      break;
    case "Applicants":
      this.showApplicantDetails = true;
      break;
    case "Innovators":
      this.showInventorDetails = true;
      break;
    case "Jurisdiction":
      this.showJurisdictionDetails = true;
      break;
    case "Classes and Goods":
      this.showClassesAndGoods = true;
      break;
    // You can add other cases as needed, for example, if you have a "Other Parties" case
    case "Other Parties":
      this.showOtherparties = true;
      break;
    
    default:
      break;
  }
}

    setActiveClass(id) {
     this.breadcrumb.forEach(item => {
        console.log('item labelName : ',item.labelName);
        console.log('item id : ',item.id);
    if (item.id === id) {
      item.className = "active"; // Set the matching ID's className to active
    } else {
      item.className = ""; // Set all others' className to blank
    }
  });
    }


}