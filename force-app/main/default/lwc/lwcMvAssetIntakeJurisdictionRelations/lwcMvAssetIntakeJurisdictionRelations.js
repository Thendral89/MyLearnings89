import { LightningElement,api, track  } from 'lwc';
export default class LwcMvAssetIntakeJurisdictionRelations extends LightningElement {
    @api assetIntakeJurisdictionId;
    @api clientId;
    @api assetIntakeFormId;
    @api assetType;
    @api jurisdictionRelations = {};
    

    @track clientEngagementModelsColumns = [];
    @track applicantsColumns = [];
    @track inventorsColumns = [];
    @track classesColumns = [];

    @track clientEngagementModelsData = [];
    @track applicantsData = [];
    @track inventorsData = [];
    @track classesData = [];

    @track selectedClientEngagementModels = [];
    @track selectedApplicants=[];
    @track selectedInventors=[];

    @track isTableLoaded = false;
   // showInventors;

    async connectedCallback(){
       try{
            console.log('Asset type ---->', this.assetType);
            this.prepareColumns();
            console.log('assetIntakeJurisdictionId ', this.assetIntakeJurisdictionId);
            console.log('clientId ', this.clientId);
            console.log('assetIntakeFormId ', this.assetIntakeFormId);
            console.log('this.jurisdictionRelations', this.jurisdictionRelations);

           const data = JSON.parse( JSON.stringify(this.jurisdictionRelations) );

                   console.log('BB data jurisdictionRelations ',  JSON.stringify(data)  );

                    this.clientEngagementModelsData = data.clientEngagementModels ?? [];
                    this.applicantsData = data.applicants ?? [];
                    this.inventorsData = data.inventors ?? [];
                    this.classesData = data.classes ?? [];

                    console.log('%c this.clientEngagementModelsData ' + JSON.stringify(this.clientEngagementModelsData), 'color: brown; font-weight: bold;');
                    console.log('%c this.applicantsData ' + JSON.stringify(this.applicantsData), 'color: brown; font-weight: bold;');
                    console.log('%c this.inventorsData ' + JSON.stringify(this.inventorsData), 'color: brown; font-weight: bold;');
                    console.log('%c this.classesData ' + JSON.stringify(this.classesData), 'color: brown; font-weight: bold;');

            console.log('After data loaded for relations');
            this.isTableLoaded = true;
       }catch(err){
           alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: connectedCallback')
           console.error(err);
           console.error(JSON.stringify(err));
           console.error(this.serializeError(err));
       }
    }

    prepareColumns(){
       try{
           this.prepareClientEngagementModelColumns();
           this.prepareApplicantsColumns();
           this.prepareInventorsColumns();
           this.prepareClassesColumns();
       }catch(err){
           alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: prepareColumns')
           console.error(err)
       }
    }

    prepareClientEngagementModelColumns(){
       try{
        let columns = [
            {
                title: "",
                field: "isSelected",
                align: "center",
                width: "40",
                resizable: false,
                headerSort: false,
                formatter: (cell) => {
                    try{
                    let isSelected = cell.getValue();
                    return `<input type="checkbox" class="engagement-checkbox" ${isSelected ? 'checked' : ''} />`;
                    }catch(err){
                        alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: prepareClientEngagementModelColumns :: isSelected :: formatter')
                    }
                },
                cellClick: (e, cell) => this.handleCheckboxClickClientEngagementModel(e, cell)
            },
            {
                title: "Symphony ID",
                field: "symphonyId",
                headerFilter: false,
                type: "recordlink",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Type",
                headerFilter: true,
                field: "type",
                formatterParams: {
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Name",
                headerFilter: true,
                field: "contactName",
                type: "recordlink",
                formatterParams: {
                    recordIdField: "contactRecordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Email",
                headerFilter: true,
                field: "email",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            }
        ];

        this.clientEngagementModelsColumns = columns;
       }catch(err){
           alert('JS Error ::  :: prepareClientEngagementModelColumns')
           console.error(err)
       }
    }

    prepareApplicantsColumns(){
       try{
        let columns = [
            {
                title: "",
                field: "isSelected",
                align: "center",
                width: "40",
                resizable: false,
                headerSort: false,
                formatter: (cell) => {
                    let isSelected = cell.getValue();
                    return `<input type="checkbox" class="engagement-checkbox" ${isSelected ? 'checked' : ''} />`;
                },
                cellClick: (e, cell) => this.handleCheckboxClickApplicants(e, cell)
            },
            {
                title: "Applicant Draft ID",
                field: "recordName",
                headerFilter: false,
                type: "recordlink",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Applicant",
                field: "name",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Applicant Address",
                field: "address",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Client Classification",
                field: "clientClassification",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Currency",
                field: "currencyCode",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "US/CA Entity Size",
                field: "entitySize",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "New/Existing",
                field: "isExistingApplicant",
                formatterParams: {
                    "recordIdField": "recordId",
                    "classList": [],
                    "styleList": [
                        {
                            "property": "font-weight",
                            "value": "bold",
                        }
                    ],
                    "classListFunction": this.applicantRecordTypeFormatting
                }
            },
        ];

        this.applicantsColumns = columns;
       }catch(err){
           alert('JS Error ::  :: prepareApplicantsColumns')
           console.error(err)
       }
    }

    prepareInventorsColumns(){
       try{
        let columns = [
            {
                title: "",
                field: "isSelected",
                align: "center",
                width: "40",
                resizable: false,
                headerSort: false,
                formatter: (cell) => {
                    try{
                    let isSelected = cell.getValue();
                    return `<input type="checkbox" class="engagement-checkbox" ${isSelected ? 'checked' : ''} />`;
                    }catch(err){
                        alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: prepareClientEngagementModelColumns :: isSelected :: formatter')
                    }
                },
                cellClick: (e, cell) => this.handleCheckboxClickInventors(e, cell)
            },
            {
                title: "Draft ID",
                field: "recordName",
                headerFilter: false,
                type: "recordlink",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Innovator",
                field: "inventorName",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Innovator Address",
                field: "address",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Email Address",
                field: "emailAddress",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Nationality",
                field: "nationality",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Phone Number",
                field: "phoneNumber",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "New/Existing",
                field: "isExistingInventor",
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                    classListFunction: this.inventorRecordTypeFormatting,
                },
            }
        ];

        this.inventorsColumns = columns;
       }catch(err){
           alert('JS Error ::  :: prepareInventorsColumns')
           console.error(err)
       }
    }

    prepareClassesColumns(){
        try{
         let columns = [
             {
                 title: "",
                 field: "isSelected",
                 align: "center",
                 width: "4%",
                 resizable: false,
                 headerSort: false,
                 formatter: (cell) => {
                     try{
                     let isSelected = cell.getValue();
                     return `<input type="checkbox" class="engagement-checkbox" ${isSelected ? 'checked' : ''} />`;
                     }catch(err){
                         alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: prepareClientEngagementModelColumns :: isSelected :: formatter')
                     }
                 },
                 cellClick: (e, cell) => this.handleCheckboxClickClasses(e, cell)
             },
             {
                 title: "Draft ID",
                 field: "recordName",
                 width: "10%",
                 headerFilter: false,
                 type: "recordlink",
                 formatterParams: {
                     recordIdField: "recordId",
                     classList: [],
                     styleList: [
                         {
                             property: "font-weight",
                             value: "bold",
                         },
                     ],
                 },
             },
             {
                title: "Class",
                field: "className",
                width: "10%",
                type: "recordlink",
                headerFilter: false,
                formatterParams: {
                    recordIdField: "clientSpecificationId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Jurisdiction",
                field: "jurisdictionName",
                width: "15%",
                headerFilter: false,
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Languages",
                field: "languages",
                width: "10%",
                headerFilter: false,
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "Specification",
                field: "specification",
                width: "36%",
                headerFilter: false,
                formatterParams: {
                    recordIdField: "recordId",
                    classList: [],
                    styleList: [
                        {
                            property: "font-weight",
                            value: "bold",
                        },
                    ],
                },
            },
            {
                title: "New/Existing",
                field: "isExistingClass",
                headerFilter: false,
                formatterParams: {
                    "recordIdField": "recordId",
                    "classList": [],
                    "styleList": [
                        {
                            "property": "font-weight",
                            "value": "bold",
                        }
                    ],
                    "classListFunction": this.applicantRecordTypeFormatting
                }
            }
         ];
 
         this.classesColumns = columns;
        }catch(err){
            alert('JS Error ::  :: prepareInventorsColumns')
            console.error(err)
        }
     }
    

    async handleCheckboxClickApplicants(event, cell){
        try{
            event.stopPropagation();
     
            const rowData = cell.getRow().getData();
            const isSelected = rowData.isSelected;
            const assetIntakeJurisdictionRelationRecordId = rowData.assetIntakeJurisdictionRelationRecordId;
            const relatedToId = rowData.recordId;
            const checkbox = event.target;
 
            if (!isSelected) {
                cell.getRow().getData().isSelected = true;
                this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId,'Asset_Intake_Applicants__c', true);
            } else {
                  cell.getRow().getData().isSelected = false;
 
                 this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId,'Asset_Intake_Applicants__c', false);
            }
 
        }catch(err){
            alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: handleCheckboxClickApplicants')
            console.error(err)
            this.serializeError(err);
        }
     }

     async handleCheckboxClickInventors(event, cell){
        try{
            event.stopPropagation();
     
            const rowData = cell.getRow().getData();
            const isSelected = rowData.isSelected;
            const assetIntakeJurisdictionRelationRecordId = rowData.assetIntakeJurisdictionRelationRecordId;
            const relatedToId = rowData.recordId;
            const checkbox = event.target;
 
            if (!isSelected) {
                cell.getRow().getData().isSelected = true;
                this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId,'Asset_Intake_Inventor__c', true);
            } else {
                  cell.getRow().getData().isSelected = false;
 
                 this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId,'Asset_Intake_Inventor__c', false);
            }
 
        }catch(err){
            alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: handleCheckboxClickInventors')
            console.error(err)
            this.serializeError(err);
        }
     }

     async handleCheckboxClickClasses(event, cell){
        try{
            event.stopPropagation();
     
            const rowData = cell.getRow().getData();
            const isSelected = rowData.isSelected;
            const assetIntakeJurisdictionRelationRecordId = rowData.assetIntakeJurisdictionRelationRecordId;
            const relatedToId = rowData.recordId;
            const checkbox = event.target;
 
            if (!isSelected) {
                cell.getRow().getData().isSelected = true;
                this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId,'Asset_Intake_Class__c', true);
            } else {
                  cell.getRow().getData().isSelected = false;
 
                 this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId,'Asset_Intake_Class__c', false);
            }
 
        }catch(err){
            alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: handleCheckboxClickInventors')
            console.error(err)
            this.serializeError(err);
        }
     }
 
 

    async handleCheckboxClickClientEngagementModel(event, cell){
       try{
           event.stopPropagation();
    
           const rowData = cell.getRow().getData();
           const isSelected = rowData.isSelected;
           const assetIntakeJurisdictionRelationRecordId = rowData.assetIntakeJurisdictionRelationRecordId;
           const relatedToId = rowData.assetIntakePersonnelRecordId;
           const checkbox = event.target;

           if (!isSelected) {
               cell.getRow().getData().isSelected = true;
               this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId, 'Asset_Intake_Personnel__c', true);
           } else {
                 cell.getRow().getData().isSelected = false;

                this.communicateToParent(rowData, assetIntakeJurisdictionRelationRecordId, relatedToId, 'Asset_Intake_Personnel__c', false);
           }

       }catch(err){
           alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: handleCheckboxClickClientEngagementModel')
           console.error(err)
           this.serializeError(err);
       }
    }

    inventorRecordTypeFormatting(cell) {
        try {
            const isExisting = cell.getRow().getData().isExistingInventor;
            console.log("Is Existing " + isExisting);
            if (isExisting === "Existing") {
                return ["greentag"];
            } else {
                return ["greytag"];
            }
        } catch (err) {
            alert("JS Error ::  :: inventorRecordTypeFormatting");
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

    communicateToParent( rowData, assetIntakeJurisdictionRelationRecordId, relatedToId , instanceType, checked ){
       try{
        console.log('%c checked from communicateToParent ' + checked, 'color: blue; font-weight: bold;');
        console.log('%c instanceType from communicateToParent ' + instanceType, 'color: blue; font-weight: bold;');
        console.log('%c assetIntakeJurisdictionId from communicateToParent ' + this.assetIntakeJurisdictionId, 'color: blue; font-weight: bold;');
        console.log('%c assetIntakeJurisdictionRelationRecordId from communicateToParent ' + assetIntakeJurisdictionRelationRecordId, 'color: blue; font-weight: bold;');
        console.log('%c relatedToId from communicateToParent ' + relatedToId, 'color: blue; font-weight: bold;');

           const evt = new CustomEvent('checkboxclickjurisdictionrelation', {
               detail: {
                   "checked": checked,
                   "rowData": rowData,
                   "assetIntakeJurisdictionRelationRecordId": assetIntakeJurisdictionRelationRecordId,
                   "assetIntakeJurisdictionId" : this.assetIntakeJurisdictionId,
                   "instanceType": instanceType,
                   "relatedToId": relatedToId
               }
               , bubbles: true
               , composed: true
           });

           this.dispatchEvent(evt);
       }catch(err){
           alert('JS Error :: LwcMvAssetIntakeJurisdictionRelations :: communicateToParent')
           console.error(err)
       }
    }

    applicantRecordTypeFormatting(cell) {
        try {
            const isExisting = cell.getRow().getData().isExistingApplicant;
            console.log('Is Existing ' + isExisting);
            if (isExisting === 'Existing') {
                return ["greentag"];
            }
            else {
                return ["greytag"];
            }
        } catch (err) {
            alert('JS Error ::  :: applicantRecordTypeFormatting')
            console.error(err)
        }
    }

    get
    showInventors(){
       try{
        console.log(' NNNNNNNNNN this.assetType ', this.assetType);
           return (this.assetType == 'Patent');
       }catch(err){
           alert('JS Error ::  :: showInventors')
           console.error(err)
       }
    }

    get
    showClasses(){
       try{
        return (this.assetType == 'Trademark');
       }catch(err){
           alert('JS Error ::  :: showClasses')
           console.error(err)
       }
    }
}