import { LightningElement, wire, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import FA from "@salesforce/resourceUrl/FA";
import { 
    IsConsoleNavigation,
    EnclosingTabId,
    openSubtab,
    getTabInfo
} from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClientPortfolio from '@salesforce/apex/mvLawfirmUtilities.getClientPortfolio';

const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [25, 50, 100, 500];

export default class ClientPortfolio extends NavigationMixin(LightningElement)  {
    @api recordId;
    @track patentsCount=0;
    @track trademarksCount=0;
    @track copyrightsCount=0;
    @track disputesCount=0;
    @track designsCount=0;
    @track agreementAndContractCount=0;
    @track entitiesCount=0;
    @track generalMattersCount=0;
    @track patentFamiliesCount=0;
    @track designFamiliesCount=0;
    @track marksCount=0;
    @track totalCount=0;

    currentFeatureSettings = {        
        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues" : PAGINATOR_SIZE_SELECTOR
    };

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;

    async findEnclosingTabAndOpenSubtab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
            try{
                // Ensure that we're in a console app and that we have a tab open
                if (!this.isConsoleNavigation || !this.enclosingTabId) {
                    return;
                }

                let tabInfo = await getTabInfo(this.enclosingTabId);

                let finalTabId = tabInfo.parentTabId ? tabInfo.parentTabId : this.enclosingTabId;

                // Open sub tab
                await openSubtab(finalTabId, {
                    pageReference: {
                        'type': type,
                        attributes: {
                            'objectApiName': objectApiName,
                            'actionName': actionName,
                            "recordId": recordId
                        }
                    }
                });
            }
            catch(err){
                console.error('JS Error : ccDashboard : findEnclosingTabAndOpenSubtab');
            }
            
        }

    columns = [
        {title:"Title", width:"35%",  field:"assetTitle", headerFilter:true , formatter: (cell, formatterParams) => {
            var value = cell.getValue();
            let recordId = cell.getRow().getData().recordId;
            let output;
            if(this.isConsoleNavigation){
                output = document.createElement("a");
                output.href = "#";
                output.style.fontWeight = "bold";
                output.textContent = value;
                output.addEventListener("click", (event) => {
                    event.preventDefault();
                    this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
                });
            }

            return output;
            /*
                var value = cell.getValue();
                return "<span style='color:#c29304; font-weight:bold;'><a href='" +  'sfdcURL' + "/" + cell.getRow().getData().recordId + "'>" + value + "</a></span>";
                */
            }},
        {title:"Asset Type", width:"7%", headerFilter:true, field:"assetType", formatter: (cell, formatterParams) => {
            var value = cell.getValue();
            if (value=='Patent')
                return "<span class='greentag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Trademark')
                return "<span class='purpletag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Design')
                return "<span class='greentag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Design Family')
                return "<span class='greentag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Disputes')
                return "<span class='bluetag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Patent Family')
                return "<span class='greentag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Mark')
                return "<span class='purpletag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Copyright')
                return "<span class='purpletag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
            else 
                return "<span class='bluetag' style='display: inline-block;width: 100%;font-weight:bold;'>" + value + "</span>";
        }},
        {title:"Docket Number", width:"10%", headerFilter:true,field:"docketNumber", formatter: (cell, formatterParams) =>{

            var value = cell.getValue();
            let recordId = cell.getRow().getData().recordId;
            let output;
            if(this.isConsoleNavigation){
                output = document.createElement("a");
                output.href = "#";
                output.style.fontWeight = "bold";
                output.textContent = value;
                output.addEventListener("click", (event) => {
                    event.preventDefault();
                    this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
                });
            }

            return output;
        }},
        {title:"Type",  width:"13%",headerFilter:true, field:"assetCaseType", formatter: (cell, formatterParams) => {
            var value = cell.getValue();
            return "<span style='font-weight:bold;'>" + value + "</span>";
        }},
        {title:"Jurisdiction", width:"20%", headerFilter:true, field:"assetJurisdiction", formatter: (cell, formatterParams) => {
            var value = cell.getValue();
            return "<span style='font-weight:bold;'>" + value + "</span>";
        }},
        {title:"Status", width:"15%", headerFilter:true, field:"assetStatus", formatter: (cell, formatterParams) => {
            var value = cell.getValue();
            if (value=='Granted')
                return "<span class='greentag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Registered')
                return "<span class='greentag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Issued')
                return "<span class='greentag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Issued/Granted')
                return "<span class='greentag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Open')
                return "<span class='greentag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Inforce')
                return "<span class='greentag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Abandoned')
                return "<span class='redtag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Closed')
                return "<span class='redtag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Transferred Out')
                return "<span class='redtag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Withdrawn')
                return "<span class='redtag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Expired')
                return "<span class='redtag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Transferred')
                return "<span class='redtag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            else if (value=='Terminated')
                return "<span class='redtag' style='display: inline-block;width:100%;font-weight:bold;'>" + value + "</span>";
            return "<span class='ambertag' style='display: inline-block;width:100%;font-weight:bold;padding: 4px 8px;text-align: center;border-radius: 5px;'>" + value + "</span>";
        }},
    ];

    addOrEditMessage = "Add";
    records = [];
    showTable = false;

    patentIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Patent__c' })
    objectInfopatentIcon({ error, data }) {
        if (data) {
            this.patentIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    trademarkIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Trademark__c' })
    objectInfotrademarkIcon({ error, data }) {
        if (data) {
            this.trademarkIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    designIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Design__c' })
    objectInfodesignIcon({ error, data }) {
        if (data) {
            this.designIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    copyrightIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Copyright__c' })
    objectInfocopyrightIcon({ error, data }) {
        if (data) {
            this.copyrightIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    agreementIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Agreement_Contract__c' })
    objectInfoagreementIcon({ error, data }) {
        if (data) {
            this.agreementIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    disputesIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Dispute_Opposition__c' })
    objectInfodisputesIcon({ error, data }) {
        if (data) {
            this.disputesIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    generalMatterIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__General_Matter__c' })
    objectInfogeneralMatterIcon({ error, data }) {
        if (data) {
            this.generalMatterIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    patentFamilyIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Patent_Family__c' })
    objectInfopatentFamilyIcon({ error, data }) {
        if (data) {
            this.patentFamilyIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    designFamilyIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Design_Family__c' })
    objectInfodesignFamilyIcon({ error, data }) {
        if (data) {
            this.designFamilyIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    markFamilyIcon;
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Mark__c' })
    objectInfomarkFamilyIcon({ error, data }) {
        if (data) {
            this.markFamilyIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    orgIcon
    @wire(getObjectInfo, { objectApiName: 'SymphonyLF__Client__c' })
    objectInfomarkOrgIcon({ error, data }) {
        if (data) {
            this.orgIcon = data.themeInfo.iconUrl; // Object logo
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    async connectedCallback() {
        try{
            this.fetchClientPortfolio();
        }catch(err){
            console.error('JS Error ::  :: fetchClientPortfolio')
            console.error(err)
        }
    }

    handleAllErrorTypes(err){
        try{
            console.error( '%c ' + err , 'font-weight: bold;');
            console.error( '%c ' + JSON.stringify(err) , 'font-weight: bold;');
            console.error( '%c ' +this.serializeError(err) , 'font-weight: bold;' );
        }catch(err){
            console.error('JS Error ::  :: handleAllErrorTypes')
            console.error(err)
        }
     }

    fetchClientPortfolio(){
       try{
            this.showTable = false;
            
           getClientPortfolio({
            'recordId' : this.recordId
           })
           .then( response => {
               try{
                   this.showTable = false;
                   window.setTimeout(()=>{
                    this.records = response;

                    this.totalCount = this.records.length;
                    
                    var occurences = this.records.reduce(function (r, row) {
                        r[row.assetType] = ++r[row.assetType] || 1;
                        return r;
                    }, {});
                    
                    var result = Object.keys(occurences).map(function (key) {
                        return { key: key, value: occurences[key] };
                    });

                    result.forEach((element) => {
                        if (element.key=='Patent')
                            this.patentsCount = element.value;
                        else if (element.key=='Trademark')
                            this.trademarksCount = element.value;  
                        else if (element.key=='Design')
                            this.designsCount = element.value;
                        else if (element.key=='Disputes')
                            this.disputesCount = element.value;
                        else if (element.key=='Copyright')
                            this.copyrightsCount = element.value;
                        else if(element.key == 'Agreement')
                            this.agreementAndContractCount = element.value;
                        else if(element.key == 'General Matter')
                            this.generalMattersCount = element.value;
                        else if(element.key == 'Design Family')
                            this.designFamiliesCount = element.value;
                        else if(element.key == 'Mark')
                            this.marksCount = element.value;
                        else if(element.key == 'Patent Family')
                            this.patentFamiliesCount = element.value;
                    }
                );

                    this.showTable = true;
                   }, 100);
               }catch(err){
                    console.error('JS Error in Server callback ::  :: fetchClientPortfolio');
               }
           })
           .catch( error => {
                console.error('Server Error ::  :: fetchClientPortfolio :: apexMethod => getClientPortfolio');
               console.error(JSON.stringify(error));
           })
       }catch(err){
            console.error('JS Error ::  :: fetchClientPortfolio')
           console.error(err)
       }
    }

    handleFilters(event) { 
        console.log('inside event-->')
        try { 
            const newSelection = event.currentTarget.dataset.filtertype;
    
            let filteredData = this.records.filter((item) => {
                return ( item.assetType === newSelection || newSelection == 'All' )
            });
    
            try {
                const tableElement = this.template.querySelector('.lwcMvDataTable');
                if (tableElement) {
                    tableElement.updateTableData(filteredData);
                }
    
            } catch (err) {
                console.error('JS Error ::  :: updateTableData')
                console.error(err)
            }
        } catch (err) {
            console.error(err);
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

    isRenderedCallBackInitialized = false;

    renderedCallback(){
       try{
        if (this.isRenderedCallBackInitialized) return;
        this.isRenderedCallBackInitialized = true;
    
        Promise.all([
            loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
        ])
        .then(() => {

        });
       }catch(err){
            console.error('JS Error ::  :: renderedCallback')
           console.error(err)
       }
    }
}