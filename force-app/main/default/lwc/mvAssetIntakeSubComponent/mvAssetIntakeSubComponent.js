import { LightningElement,api, track  } from 'lwc';
import getExistingPatentFamilyDetails from '@salesforce/apex/PatentIntakeFormNewHelper.getExistingPatentFamilyDetails';

export default class MvAssetIntakeSubComponent extends LightningElement {
    @track selectedInventors = [];
    @track selectedApplicants=[];
    @api recordId;
    @track isTableLoaded = false;
    @track inventorColumns = [];

    connectedCallback() {


        this.fetchExistingPatentFamilyDetails();
        this.prepareColumns();

        this.isTableLoaded = true;
    }

    prepareColumns() {
        this.inventorColumns = [
            {
                title: "", 
                field: "select",
                align: "center",
                width: "40",
                resizable: false,
                headerSort: false,
                formatter: (cell) => {
                    const selectedRows = this.selectedEngagementDetails || [];
                    const rowData = cell.getRow().getData();
                    const isSelected = selectedRows.some(item => item.recordId === rowData.recordId);
                    return `<input type="checkbox" class="engagement-checkbox" ${isSelected ? 'checked' : ''} />`;
                },
                cellClick: (e, cell) => this.handleCheckboxClick(e, cell)
            },
            {
                title: "Name",
                headerFilter: false,
                field: "Name",
                formatterParams: {
                    recordIdField: "Id",
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
                title: "Address",
                headerFilter: false,
                field: "AddressText",
                formatterParams: {
                    recordIdField: "Id",
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
                headerFilter: false,
                field: "Email",
                formatterParams: {
                    recordIdField: "Id",
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

        this.applicantColumns = [
            {
                title: "", 
                field: "select",
                align: "center",
                width: "40",
                resizable: false,
                headerSort: false,
                formatter: (cell) => {
                    const selectedRows = this.selectedEngagementDetails || [];
                    const rowData = cell.getRow().getData();
                    const isSelected = selectedRows.some(item => item.recordId === rowData.recordId);
                    return `<input type="checkbox" class="engagement-checkbox" ${isSelected ? 'checked' : ''} />`;
                },
                cellClick: (e, cell) => this.handleCheckboxClick(e, cell)
            },
            {
                title: "Name",
                headerFilter: false,
                field: "Name",
                formatterParams: {
                    recordIdField: "Id",
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
                title: "Address",
                headerFilter: false,
                field: "AddressText",
                formatterParams: {
                    recordIdField: "Id",
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
    }
    fetchExistingPatentFamilyDetails() {

        if (this.recordId) {
            // this.patentFamilyId = recordId;
            getExistingPatentFamilyDetails({ recordId: this.recordId })
                .then(result => {
                    console.log('result::in ', JSON.stringify(result));
                    this.selectedInventors = result.inventors.map(inv => {
                        const addressObj = inv.SymphonyLF__Contact__r.SymphonyLF__Address__c || {};
                        const addressText = [
                            addressObj.street,
                            addressObj.city,
                            addressObj.postalCode,
                            addressObj.countryCode
                        ]
                            .filter(val => val)
                            .join(', ');
                        return {
                            Name: inv.SymphonyLF__Contact__r.Name,
                            Id: inv.SymphonyLF__Contact__c,
                            existingRecId: inv.Id,
                            Address: inv.SymphonyLF__Contact__r.SymphonyLF__Address__c || {},
                            AddressText: addressText,
                            Email: inv.SymphonyLF__Contact__r.SymphonyLF__Email__c,
                            isPrimary: inv.SymphonyLF__Primary_Inventor__c,
                            sequence: inv.Sequence__c
                        };
                    });

                    this.selectedApplicants = result.chainRecords.map(record => {
                        const addressObj = record.SymphonyLF__Address__c || {};
                        const addressText = [
                            addressObj.street,
                            addressObj.city,
                            addressObj.postalCode,
                            addressObj.countryCode
                        ]
                        .filter(val => val)
                        .join(', ');
                        return {
                            chainOfTitleId: record.Id,
                            Id: record.SymphonyLF__Client__c,
                            Name: record.SymphonyLF__Registered_Applicant__c,
                            Address: record.SymphonyLF__Address__c,
                            AddressText: addressText
                        };
                    });

                })
                .catch(error => {
                    console.error('Error fetching details:', error);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || error.message,
                        variant: 'error'
                    }));
                });
        }

    }

    // @api
    // getSelectionData() {
    //     console.log('this.selectedInventors in subcomp:', JSON.stringify(this.selectedInventors));
    //     return {
    //         selectedInventors: this.selectedInventors,
    //         selectedApplicants: this.selectedApplicants
    //     };
    // }

    // handleCheckboxClick(e, cell) {
    //     const rowData = cell.getRow().getData();
    //     rowData.isSelected = !rowData.isSelected;
    // }

    handleRowSelection(){
        console.log('row selected event received');
    }
}