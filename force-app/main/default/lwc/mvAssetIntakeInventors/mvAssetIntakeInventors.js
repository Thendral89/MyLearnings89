import { LightningElement, api, track } from 'lwc';
import getExistingPatentFamilyDetails from '@salesforce/apex/PatentIntakeFormNewHelper.getExistingPatentFamilyDetails';

export default class MvAssetIntakeInventors extends LightningElement {
    @track selectedInventors = [];
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
            },
            {
                title: "Primary",
                field: "isPrimary",
                resizable: false,
                style: "width:3%!important;",
                formatter: (cell) => {
                    const data = cell.getRow().getData();
                    return data.isPrimary
                        ? `<span style="font-weight:bold;"><i class='fa fa-toggle-on'></i></span>`
                        : `<span style="font-weight:bold;"><i class='fa fa-toggle-off'></i></span>`;
                },
                cellClick: (e, cell) => {
                    const clickedData = cell.getRow().getData();
                    if (clickedData.isPrimary) {
                        this.inventorData = this.inventorData.map(row => {
                            if (row.Id === clickedData.Id) {
                                return { ...row, isPrimary: false };
                            }
                            return row;
                        });
                    } else {
                        this.inventorData = this.inventorData.map(row => {
                            return row.Id === clickedData.Id
                                ? { ...row, isPrimary: true }
                                : { ...row, isPrimary: false };
                        });
                    }
                    this.updateInventorTableData(this.inventorData);
                }
            },
            {
                title: "Action",
                field: "action",
                align: "center",
                width: "75",
                resizable: false,
                headerSort: false,
                formatter: () => {
                    return `
                        <div class="action-icons slds-grid slds-grid_align-center slds-grid_vertical-align-center" style="font-size: 18px;"> 
                            <i class='fa fa-regular fa-trash delete-icon' title='Delete' style="cursor: pointer; color: #333;"></i> 
                        </div> 
                    `;
                },
                cellClick: (e, cell) => this.handleDeleteInventor(e, cell),
            }
        ];
    }
    fetchExistingPatentFamilyDetails() {

        if (this.recordId) {
            // this.patentFamilyId = recordId;
            getExistingPatentFamilyDetails({ recordId: this.recordId })
                .then(result => {

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
}