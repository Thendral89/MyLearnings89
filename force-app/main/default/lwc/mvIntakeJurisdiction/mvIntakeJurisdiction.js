import { LightningElement, wire, track, api } from 'lwc';
import * as CONSTANTS from 'c/mvConstants';
import { NavigationMixin } from 'lightning/navigation';
import { createElement } from 'lwc';
import mvDocketFields from 'c/mvObjectFields';
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import assetIntakeSubComponent from 'c/mvAssetIntakeSubComponent';


import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    openSubtab,
} from 'lightning/platformWorkspaceApi';

const PAGINATOR_DEFAULT_SIZE = 100;
const PAGINATOR_SIZE_SELECTOR = [25, 50, 100, 500];

export default class MvIntakeJurisdiction extends NavigationMixin(LightningElement) {

    // API Related Parameters 
    @api clientId;
    @api patentFamilyId;
    @api assetType;

    // @api
    // getFormData() {
    //     const rowData = this.records[0];
    //     let subData = { selectedInventors: [], selectedApplicants: [] };
    //     // If the row was expanded and the subcomponent exists, ask it for its selections
    //     if (rowData.subComponent && typeof rowData.subComponent.getSelectionData === 'function') {
    //         subData = rowData.subComponent.getSelectionData();
    //     }
    //     return {
    //         jurisdiction: rowData.assetJurisdiction,
    //         caseType: rowData.assetCaseType,
    //         referenceNumber: rowData.referenceNumber,
    //         selectedInventors: subData.selectedInventors,
    //         selectedApplicants: subData.selectedApplicants
    //     };
    // }

    @track records = [{ "assetJurisdiction": "US", "assetCaseType": "", "referenceNumber": "", isExpanded: false }];//subComponent: null
    @track isRenderedCallBackInitialized = false;

    currentFeatureSettings = {
        "defaultPaginationSize": PAGINATOR_DEFAULT_SIZE,
        "paginationSizeValues": PAGINATOR_SIZE_SELECTOR
    };

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;

    columns = [
        {
            title: "", field: "isExpanded", align: "center", frozen: true, width: "25", resizable: false, headerSort: false,
            formatter: function (cell, formatterParams) {
                const rowData = cell.getRow().getData();
                console.log('Row Data : ' + JSON.stringify(rowData));

                return rowData.isExpanded
                    ? "<i class='fa fa-minus-circle' title='Collapse'></i>"
                    : "<i class='fa fa-plus-circle' title='Expand'></i>";
            },
            cellClick: (e, cell) => {
                const rowData = cell.getRow().getData();
                const isNowExpanded = !rowData.isExpanded;
                cell.getRow().update({ isExpanded: isNowExpanded });

                const rowElement = cell.getRow().getElement();
                let container = rowElement.querySelector('.lwcMvDataTable');
                if (!container) {
                    container = document.createElement('div');
                    container.classList.add('lwcMvDataTable');
                    rowElement.appendChild(container);
                }

                container.innerHTML = '';
                console.log('Before Adding the Component');
                if (isNowExpanded) {
                    const childComponent = createElement('c-mv-asset-intake-sub-component', {
                        is: assetIntakeSubComponent
                    });
                    childComponent.recordId = this.patentFamilyId;

                    container.appendChild(childComponent);
                    // childComponent.recordId = this.patentFamilyId;
                    // rowData.subComponent = childComponent;
                    // container.appendChild(childComponent);
                    console.log('After Adding the Component');

                }
            }

        },
        {
            title: "Jurisdiction", width: "20%", headerFilter: true, field: "assetJurisdiction", formatter: (cell, formatterParams) => {

                var isClosed = cell.getRow().getData().isClosed;
                var value = cell.getValue();

                var cellEl = cell.getElement(); //get cell DOM element

                try {

                    const divComponent = document.createElement('div');

                    const childComponent = createElement('c-mv-object-fields', {
                        is: mvDocketFields
                    });
                    console.log(childComponent);
                    // Assign properties correctly
                    childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                    childComponent.objectName = 'SymphonyLF__Patent__c';
                    childComponent.fieldName = 'SymphonyLF__Country__c';
                    childComponent.updateableFieldName = 'SymphonyLF__Country__c';
                   // childComponent.value = 'United States of America'; 

                    // childComponent.addEventListener('valuechanged', (e) => {
                    //         rowData.assetJurisdiction = e.detail.value;
                    // });
                    divComponent.appendChild(childComponent);
                    return divComponent;

                } catch (err) {
                    // alert('JS Error :');
                    console.log('Err :  ' + err);
                    console.error(JSON.stringify(err));
                }
            }
        },
        {
            title: "Case Type", width: "20%", headerFilter: true, field: "assetCaseType", formatter: (cell, formatterParams) => {

                var isClosed = cell.getRow().getData().isClosed;
                var value = cell.getValue();
                var cellEl = cell.getElement(); //get cell DOM element

                try {
                    const divComponent = document.createElement('div');

                    const childComponent = createElement('c-mv-object-fields', {
                        is: mvDocketFields
                    });
                    console.log(childComponent);
                    // Assign properties correctly
                    childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                    childComponent.objectName = 'SymphonyLF__Patent__c';
                    childComponent.fieldName = 'SymphonyLF__Case_Type__c';
                    childComponent.updateableFieldName = 'SymphonyLF__Case_Type__c';
                    childComponent.value = 'Primary'; 
                    // childComponent.addEventListener('valuechanged', (e) => {
                    //     rowData.assetCaseType = e.detail.value;
                    // });
                    divComponent.appendChild(childComponent);
                    return divComponent;

                } catch (err) {
                    // alert('JS Error :');
                    console.log('Err :  ' + err);
                    console.error(JSON.stringify(err));
                }
            }
        },
        {
            title: "Reference Number", width: "20%", headerFilter: true, field: "referenceNumber", formatter: (cell, formatterParams) => {

                var isClosed = cell.getRow().getData().isClosed;
                var value = cell.getValue();
                var cellEl = cell.getElement(); //get cell DOM element

                try {
                    const divComponent = document.createElement('div');

                    const childComponent = createElement('c-mv-object-fields', {
                        is: mvDocketFields
                    });
                    console.log(childComponent);
                    // Assign properties correctly
                    childComponent.recordId = null; // Record ID should be null as the Patent is not yet created
                    childComponent.objectName = 'SymphonyLF__Patent__c';
                    childComponent.fieldName = 'SymphonyLF__Client_Reference__c';
                    childComponent.updateableFieldName = 'SymphonyLF__Client_Reference__c';
                    // childComponent.addEventListener('valuechanged', (e) => {
                    //     rowData.referenceNumber = e.detail.value;
                    // });
                    divComponent.appendChild(childComponent);
                    return divComponent;

                } catch (err) {
                    // alert('JS Error :');
                    console.log('Err :  ' + err);
                    console.error(JSON.stringify(err));
                }
            }
        },
        {
            title: "Clone", field: "", resizable: false, style: "width:3%!important;", formatter: "buttonCross", formatter: function (cell, formatterParams) {
                return "<span style='font-weight:bold;'><i class='fa fa-clone'></i></span>";
            }
        },
    ];

    renderedCallback() {
        try {
            if (this.isRenderedCallBackInitialized) return;
            this.isRenderedCallBackInitialized = true;

            Promise.all([
                loadStyle(this, FA + '/font-awesome-4.7.0/css/font-awesome.css')
            ])
                .then(() => {
                    console.log('Loaded FA Styles');
                });
        } catch (err) {
            alert('JS Error ::  :: renderedCallback')
            console.error(err)
        }
    }

    handleValueChanged(event){
        console.log('in handleValueChanged');
        console.log('received event:', JSON.stringify(event.detail));
    }
}