import { LightningElement, api, wire, track } from 'lwc';
import searchPatentFamilyRecords from '@salesforce/apex/applicationIntakeFormController.searchPatentFamilyRecords';
import getDraftPatentFamilyRecords from '@salesforce/apex/applicationIntakeFormController.getDraftPatentFamilyRecords';
import getFieldSetColumns from '@salesforce/apex/applicationIntakeFormController.getFieldSetColumns';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FA from "@salesforce/resourceUrl/FA";
import { loadStyle } from 'lightning/platformResourceLoader';

export default class ApplicationIntakeForm extends NavigationMixin(LightningElement) {
    @api clientId;
    @api conflictCheckId = '';

    @track inputValuePatentFamily = '';
    @track patentFamilyRecords = [];
    @track showDropdownPatentFamily = false;
    @track noResults = false;

    @track shortTitle = '';
    @track inventionTitle = '';

    @track DraftedpatentFamilyColumns = [];

    @track columnsLoaded = false;
    @track showIntakeForm = true;


    connectedCallback() {
        console.log('this.clientId::', this.clientId);
        if (this.clientId) {
            this.loadDraftPatentFamilyRecords();
        }
        this.prepareColumns();
    }

    loadDraftPatentFamilyRecords() {
        getDraftPatentFamilyRecords({ clientId: this.clientId })
            .then(result => {
                this.DraftedpatentFamilyData = result;
                console.log('this.DraftedpatentFamilyData:', JSON.stringify(this.DraftedpatentFamilyData));
            })
            .catch(error => {
                console.error('Error fetching draft records: ', error);
            });
    }

    prepareColumns() {
        getFieldSetColumns({ sObjectName: 'SymphonyLF__Patent_Family__c' })
            .then(result => {
                let dynamicCols = result.map(col => {
                    return {
                        title: col.label,
                        field: col.fieldName,
                        headerFilter: true,
                        formatterParams: {
                            recordIdField: "Id",
                            classList: [],
                            styleList: [
                                {
                                    property: "font-weight",
                                    value: "bold"
                                }
                            ]
                        }
                    };
                });
                dynamicCols.push({
                    title: "",
                    field: "navigate",
                    align: "center",
                    width: "75",
                    resizable: false,
                    headerSort: false,
                    formatter: () => {
                        return ` <div class="action-icons"> 
                                    <i class='fa fa-regular fa-location-arrow navigate-icon' title='Navigate To Intake Form'></i> 
                                </div>`;
                    },
                    cellClick: (e, cell) => this.handleNavigateToTab(e, cell)
                });
                this.DraftedpatentFamilyColumns = dynamicCols;
                console.log('DraftedpatentFamilyColumns:', JSON.stringify(this.DraftedpatentFamilyColumns));

                this.columnsLoaded = true;
            })
            .catch(error => {
                console.error('Error retrieving field set columns: ', error);
            });
    }

    handleNavigateToTab(event, cell) {
        const rowData = cell.getRow().getData();
        const draftedPatentFamilyId = rowData.Id;
        const clientId = rowData.SymphonyLF__Client__c || this.clientId;

        console.log('Navigating with clientId:', clientId, 'and draftedPatentFamilyId:', draftedPatentFamilyId);

        const url = '/lightning/n/Patent_Intake_Form_New' +
            '?c__clientId=' + encodeURIComponent(clientId) +
            '&c__draftedPatentFamilyId=' + encodeURIComponent(draftedPatentFamilyId);

        window.open(url, '_blank');
    }



    isRenderedCallBackInitialized = false;
    renderedCallback() {
        try {
            if (this.isRenderedCallBackInitialized) return;
            this.isRenderedCallBackInitialized = true;

            Promise.all([
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
                .then(() => {
                    /*  const defaultTile = this.template.querySelector('[data-filtertype="aggregateCollaborations"]');
                      if (defaultTile) {
                          defaultTile.classList.add('selected');
                      } */
                });
        } catch (err) {
            // alert('JS Error ::  :: renderedCallback')
            console.error(err)
        }
    }

    handleSearchExistingPatentFamily(event) {
        const searchterm = event.target.value;
        this.inputValuePatentFamily = searchterm
        if (searchterm) {
            searchPatentFamilyRecords({
                clientId: this.clientId,
                searchTerm: this.inputValuePatentFamily
            })
                .then(result => {
                    if (result && result.length > 0) {
                        this.patentFamilyRecords = result.map(rec => {
                            return {
                                recordId: rec.Id,
                                Name: rec.Name,
                                inventionTitle: rec.SymphonyLF__Invention_Title__c,
                            };
                        });
                        console.log('this.patentFamilyRecords::', JSON.stringify(this.patentFamilyRecords));
                        this.noResults = false;
                    } else {
                        this.patentFamilyRecords = [];
                        this.noResults = true;
                    }
                    this.showDropdownPatentFamily = true;
                })
                .catch(error => {
                    console.error('Error searching Patent Family: ', error);
                    this.patentFamilyRecords = [];
                    this.noResults = true;
                    this.showDropdownPatentFamily = true;
                });
        } else {
            this.patentFamilyRecords = [];
            this.noResults = false;
            this.showDropdownPatentFamily = false;
        }
    }

    handleSelectPatentFamily(event) {
        const index = event.currentTarget.dataset.index;
        const selectedRecord = this.patentFamilyRecords[index];

        const existingPatentFamilyRecordId = selectedRecord.recordId;

        const clientId = this.clientId;

        const url = '/lightning/n/Patent_Intake_Form_New'
            + '?c__clientId=' + encodeURIComponent(clientId)
            + '&c__existingPatentFamilyRecordId=' + encodeURIComponent(existingPatentFamilyRecordId);

        window.open(url, '_blank');

        this.inputValuePatentFamily = '';
        this.showDropdownPatentFamily = false;
    }


    handleInventionTitle(event) {
        const inputVal = event.target.value;
        this.inventionTitle = inputVal;

        if (inputVal.length > 80) {
            let truncated = inputVal.substring(0, 80);
            let lastSpace = truncated.lastIndexOf(' ');
            if (lastSpace > 0) {
                // Use the substring up to the last complete word.
                this.shortTitle = truncated.substring(0, lastSpace);
            } else {
                this.shortTitle = truncated;
            }
        } else {
            this.shortTitle = inputVal;
        }
    }



    handleCancel() {
        console.log('Cancel clicked');
        const eve = new CustomEvent('showengagementmodalclose', {
            detail: false
        })
        this.dispatchEvent(eve);
    }

    handleContinueIntakeForm() {
        console.log('Continue clicked, shortTitle=', this.shortTitle, ' inventionTitle=', this.inventionTitle);

        if (!this.validateInventorDetailsInputs()) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill Title to proceed.',
                variant: 'error',
            }));
            return;
        }

        // const url = '/lightning/n/Patent_Intake_Form_New'
        //     + '?c__shortTitle=' + encodeURIComponent(this.shortTitle)
        //     + '&c__clientId=' + encodeURIComponent(this.clientId)
        //     + '&c__inventionTitle=' + encodeURIComponent(this.inventionTitle);

        // window.open(url, '_blank');
        this.showIntakeForm = true;
    }

    validateInventorDetailsInputs() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;

        inputs.forEach(input => {
            if (!input.checkValidity()) {
                isValid = false;
                input.reportValidity();
            }
        });

        return isValid;
    }
}