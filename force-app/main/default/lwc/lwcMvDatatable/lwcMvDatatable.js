import { LightningElement, api, track, wire } from "lwc";
// importing Static Resources
import tableJS from '@salesforce/resourceUrl/MAXVALTABLEJS';
import tableCSS from '@salesforce/resourceUrl/MAXVALTABLECSS';
import MOMENT from '@salesforce/resourceUrl/MOMENT';
import jQuery from '@salesforce/resourceUrl/jQuery';
import dateRangePicker from '@salesforce/resourceUrl/dateRangePicker';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import {
    IsConsoleNavigation,
    openTab,
    EnclosingTabId,
    openSubtab,
    getTabInfo
} from 'lightning/platformWorkspaceApi';


const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100, 500];
const PAGINATION = 'remote';

const DATEFORMAT = {
    month: '2-digit',
    day: '2-digit',
    year: 'numeric',
    timeZone: 'UTC',
    locale: 'en-US'
}


export default class LwcMvDatatable extends LightningElement {
    @api serviceRepositoryName;
    mainObjectLabel;
    mainObjectName;
    sortFieldMap;
    fieldsWidth;
    @api customSettings;

    @api doNotAutoHeight = false;
    @api layout = 'fitColumns';
    @api timezone = 'America/Los_Angeles';
    @api userlocale = 'en-US';
    @api movableColumns = false;
    @api movableRows = false;
    @api rowHeight = 50;
    @api height;
    @api resizableRows = false;
    @api groupBy = undefined;
    @api groupStartOpen = false;

    isShowSpinner = false;
    sortDirection = "asc";
    sortedBy = "recordLink";
    counter = 0;

    clientHeight = null;

    expandedRow = {};
    showExpandedPopup = false;

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) enclosingTabId;
    //  get datatableHeight() {
    //     return `height: ${this.height || '600px'};`;  // Default to 600px if no height is provided
    // }


    async findEnclosingTabAndOpenSubtab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
        try {
            // Ensure that we're in a console app and that we have a tab open
            if (!this.isConsoleNavigation || !this.enclosingTabId) {
                return;
            }

            // Open a record as a subtab of the current tab
            let tabInfo = await getTabInfo(this.enclosingTabId);
            console.log('BBBB tabInfo', JSON.stringify(tabInfo));

            let finalTabId = tabInfo.parentTabId ? tabInfo.parentTabId : this.enclosingTabId;

            // Open sub tab
            await openSubtab(finalTabId, {
                pageReference: {
                    'type': type,
                    attributes: {
                        'objectApiName': objectApiName,
                        'actionName': actionName,
                        "recordId": recordId,
                        "focus": true
                    }
                }
            });
        }
        catch (err) {
            this.openAsNewTab(type, objectApiName, recordId, actionName);
            /*
            alert('JS Error : lwcMvDatatable : findEnclosingTabAndOpenSubtab');
            try{
                console.error(this.serializeError(err));
            }catch(e){}

            try{
                console.error(err);
                console.error(JSON.stringify(err));
            }catch(e){}
            
*/
        }

    }

    async openAsNewTab(type = 'standard__objectPage', objectApiName = null, recordId, actionName = 'list') {
        try {
            // Open sub tab
            await openTab({
                pageReference: {
                    'type': type,
                    attributes: {
                        'objectApiName': objectApiName,
                        'actionName': actionName,
                        "recordId": recordId,
                        "focus": true
                    }
                }
            });
        }
        catch (err) {
          //  alert('JS Error : lwcMvDatatable : openAsNewTab');
            try {
                console.error(this.serializeError(err));
            } catch (e) { }

            try {
                console.error(err);
                console.error(JSON.stringify(err));
            } catch (e) { }

        }

    }


    /*
    predefinedColumns = [{
            title: "Name",
            field: "recordLink",
            headerHozAlign:"center",
            vertAlign:"middle",
            headerWordWrap:true,
            formatter: "link",
            formatterParams:{
                labelField:"Name",
                target:"_blank",
            },
            sorter: function (a, b, aRow, bRow, column, dir) {
                return ((aRow?.getData()?.Name?.toLocaleLowerCase() > bRow?.getData()?.Name?.toLocaleLowerCase()) -
                    (bRow?.getData()?.Name?.toLocaleLowerCase() > aRow?.getData()?.Name?.toLocaleLowerCase()));
            },
            headerFilter: 'input',
            headerFilterParams: {clearable:true},
            headerFilterFunc: function (headerValue, rowValue, rowData) {
                return rowData?.Name?.toLowerCase()?.includes(headerValue?.toLocaleLowerCase());
            }
    }];
    */

    @api
    showSpinner() {
        this.isShowSpinner = true;
    }

    @api
    hideSpinner() {
        this.isShowSpinner = false;
    }

    get
    sldshowTable(){
       try{
           return this.isShowSpinner ? 'slds-hide' : 'slds-show';
       }catch(err){
           console.error('JS Error ::  :: sldshowTable')
           console.error(err)
       }
    }

    get initialSort() {
        const initialSort = [];
        if (Object.keys(this.sortFieldMap).length) {
            Object.keys(this.sortFieldMap)?.forEach(sortField => {
                const fieldName = sortField
                    .replace(this.mainObjectName + '.Name', 'recordLink')
                    .replace(this.mainObjectName + '.', '')
                    .replaceAll('.', '+')

                const refColumnFieldName = this.columns.find(column => column?.formatterParams?.labelField === fieldName);
                initialSort.push({
                    column: refColumnFieldName ? refColumnFieldName.field : fieldName,
                    dir: this.sortFieldMap[sortField]
                })
            });
        } else {
            initialSort.push({ column: this.sortedBy, dir: this.sortDirection })
        }
        return initialSort;
    }

    get textAreaColumns() {
        const fieldNames = [];
        this.columns?.forEach(column => {
            if (column.type === 'TEXTAREA' || column.type === 'IMAGE') {
                fieldNames.push(column.field);
            }
        });
        return fieldNames
    }

    get title() {
        return this.mainObjectLabel || "Results";
    }

    get userLocaleSetting() {
        return this.customSettings?.userLocale ?? 'en-US';
    }

    get paginationSize() {
        return this.customSettings?.defaultPaginationSize ?? PAGINATOR_DEFAULT_SIZE;
    }

    get pagination(){
        return this.customSettings?.pagination ?? PAGINATION;
    }

    get paginationSelectorValues() {
        return this.customSettings?.paginationSizeValues?.length ? this.customSettings?.paginationSizeValues : PAGINATOR_SIZE_SELECTOR;
    }

    _columns = []

    @api
    get columns() {
        try {

            const resultColumns = []; JSON.parse(JSON.stringify(this._columns));

            this._columns.forEach(column => {
                const oldFiled = column.field;
                /* const prefix = column.field.substring(0, column.field.indexOf('.'));
                    if (prefix && Object.keys(this.relatedObjectNames).includes(prefix) && column.field.replace(prefix + '.', '') === 'Name') {
                        column.type = 'recordLink';
                    }
                    column.field = oldFiled.replaceAll('.', '+'); */

                let newColumn = {};

                Object.assign(
                    newColumn
                    , this.formatByType(column.type?.toLowerCase(), column)
                );

                Object.assign(
                    newColumn
                    , column
                );


                /*
                Object.assign(column,
                    {
                        headerHozAlign:"center",
                        vertAlign:"middle",
                        headerWordWrap:true
                    },
                    this.formatByType(column.type?.toLowerCase(), column)
                );
                */


                resultColumns.push(newColumn);
            });

            return resultColumns;

        }
        catch (err) {
         //   alert('JS Error ::  :: get columns');
            console.error(this.serializeError(err));
        }
    }
    set columns(value) {
        this._columns = value;
    }

    async connectedCallback() {
        try {
            

            await this.loadTableLib();
        } catch (err) {
          //  alert('Error : lwcMvDatatable : connectedCallback');
        }
    }

    setLocale() {
        DATEFORMAT.locale = this.userLocaleSetting;
        DATEFORMAT.format = this.getDateFormat();
    }

    async loadTableLib() {
        await Promise.all(
            [
                loadScript(this, jQuery + '/jquery-3.4.1.min.js'),
                loadScript(this, dateRangePicker + '/daterangepicker.min.js'),
                loadStyle(this, dateRangePicker + '/daterangepicker.css'),
                loadScript(this, tableJS),
                loadStyle(this, tableCSS),
                loadScript(this, MOMENT),
            ]
        ).then(() => {
            this.setLocale();
            this.addListeners();
            this.getContentHeight();
            //this.observeVisibilityAndInit();
            this.initTable();
        });
    }

    observeVisibilityAndInit() {
        const el = this.template.querySelector('.result-table');
        if (!el) return;

        this.resizeObserver = new ResizeObserver(entries => {
            for (let entry of entries) {
                if (entry.contentRect.width > 0 && !this.isTabulatorReady) {
                    this.initTable( this.latestTimeoutCount );
                } else if (this.table) {
                    this.isShowSpinner = true;
                    const latestTimeoutCount = this.latestTimeoutCount + 1;
                    this.latestTimeoutCount = latestTimeoutCount;
                    clearTimeout(this.timeoutId);
                    this.timeoutId = window.setTimeout(()=>{
                        this.isShowSpinner = true;
                        console.log(`%c Redraw fired ${this.serviceRepositoryName} `, 'color: red; font-weight: bold;')
                      //  this.table.redraw(true);
                      this.initTable(latestTimeoutCount);
                    }, 500);
                }
            }
        });

        this.resizeObserver.observe(el);
    }

    timeoutId;
    latestTimeoutCount = 0;

    getContentHeight() {
        const elContent = this.template.querySelector('[data-id="content"]');
        if (elContent) {
            this.clientHeight = elContent.clientHeight;
        }
    }

    addListeners() {
        this.template.addEventListener("keydown", event => {
            if (event?.code === 'Escape') {
                this.handlePopupClose();
            }
        });
        window.addEventListener("resize", event => {
            this.getContentHeight();
            const tabulator = this.template.querySelector('.tabulator');
            if (tabulator) {
                if(! this.doNotAutoHeight){
                    tabulator.style.height = this.clientHeight + 'px';
                }
            }

        });
    }

    setColumnsWidthForPredefined() {
        this.predefinedColumns.forEach(predefinedColumn =>
            Object.assign(predefinedColumn,
                { "width": this.fieldsWidth[this.mainObjectName.concat('.', predefinedColumn.title)] }
            )
        );
    }

    sfdcURL = window.location.origin;

    formatByType(type, fullColumn) {
        try {
            if (type === 'boolean') {
                return {
                    hozAlign: "center",
                    formatter: 'tickCross',
                    headerFilter: "tickCross",
                    headerFilterParams: { "tristate": true, clearable: true, filterType: type, initial: null },
                    headerFilterEmptyCheck: function (value) { return value === 'all' },
                    headerFilterFunc: function (headerValue, rowValue, rowData, filterParams) {
                        if (headerValue === null) return rowValue === false;
                        if (headerValue === true) return rowValue === true;
                        return true;
                    },
                };
            }
            if (type === 'picklist') {
                return {
                    formatter: 'plaintext',
                    headerFilter: "list",
                    headerFilterParams: { valuesLookup: true, clearable: true }
                };
            }
            if (type === 'date' || type === 'datetime') {
                return {
                    formatter: (cell) => {
                        let value = cell.getValue();
                        if (!value) return '';

                        let date = new Date(value);
                        console.log('value BB', value);
                        //  console.log('timezone BB ', this.timezone);
                        const obj = {
                            timeZone: this.timezone
                        };

                        if (type = 'date') {
                            Object.assign(obj,
                                {
                                    year: 'numeric',
                                    month: 'short',
                                    day: 'numeric',
                                }
                            )
                        } else {
                            Object.assign(obj,
                                {
                                    year: 'numeric',
                                    month: 'short',
                                    day: 'numeric',
                                    hour: '2-digit',
                                    minute: '2-digit'
                                }
                            )
                        }
                        return new Intl.DateTimeFormat(this.userlocale, obj).format(date);
                    },
                    headerFilter: this.createInputElement,
                    headerFilterParams: { clearable: true },
                    headerFilterFuncParams: { fieldName: fullColumn.field },
                    headerFilterFunc: this.dateFilterFunction,
                    sorter: function (a, b, aRow, bRow, column, dir) {
                        const fieldName = column.getField(); // + 'Origin';
                        let reverse = dir === "asc" ? 1 : -1;
                        if (!a) return reverse;
                        if (!b) return -reverse;
                        const aRowData = aRow.getData();
                        const bRowData = bRow.getData();
                        return ((aRowData[fieldName] > bRowData[fieldName]) - (bRowData[fieldName] > aRowData[fieldName]));
                    }
                }
            }

            if (type === 'recordlink' || type === 'reference') {
                return {
                    formatter: (cell, formatterParams) => {
                        let recordIdField = formatterParams.recordIdField;

                        var value = cell.getValue();
                        let recordId = this.getNestedValue(cell.getRow().getData(), recordIdField);

                        let output = this.spanFormatter(cell, formatterParams);

                        let hyperlink = document.createElement("a");
                        let href = this.sfdcURL + "/" + recordId;
                        hyperlink.href = href
                        hyperlink.textContent = ( value ? value : '' );
                        hyperlink.addEventListener("click", (event) => {
                            event.preventDefault();

                            if(recordId){
                                if (this.isConsoleNavigation) {
                                    this.findEnclosingTabAndOpenSubtab('standard__recordPage', '', recordId, 'view');
                                }
                                else {
                                    window.open(href);
                                }
                            }
                        });

                        output.appendChild(hyperlink);
                        return output;
                    }
                };
            }

            if (type === 'address') {
                return {
                    formatter: (cell, formatterParams) => {
                        var value = cell.getValue();

                        let addressArray = [];
                        if (value) {
                            if (value.street) {
                                addressArray.push(value.street);
                            }
                            if (value.city) {
                                addressArray.push(value.city);
                            }
                            if (value.stateCode) {
                                addressArray.push(value.stateCode);
                            }
                            if (value.postalCode) {
                                addressArray.push(value.postalCode);
                            }
                            if (value.country) {
                                addressArray.push(value.country);
                            }
                        }

                        value = addressArray.join(', ');

                        let output = this.spanFormatter(cell, formatterParams);
                        output.textContent = value;
                        // output.setAttribute("title", value);

                        return value;
                    }
                }
            }

            return {
                formatter: (cell, formatterParams) => {
                    try {
                        var value = cell.getValue();

                        let output = this.spanFormatter(cell, formatterParams);

                        if (!value) {
                            value = '';
                        }
                        output.textContent = value;

                        return output;
                    } catch (err) {
                     //   alert('JS Error ::  :: formatByType :: else');
                        console.error(this.serializeError(err));
                    }
                }
            };

        }
        catch (err) {
         //   alert('JS Error ::  :: formatByType');
            console.error(this.serializeError(err));
        }
    }

    spanFormatter(cell, formatterParams) {
        try {
            let output = document.createElement("span");

            if (formatterParams.classList) {
                formatterParams.classList.forEach(each => {
                    output.classList.add(each);
                });
            }

            if (formatterParams.classListFunction) {
                formatterParams.classListFunction(cell)?.forEach(each => {
                    output.classList.add(each);
                });
            }

            if (formatterParams.styleList) {
                formatterParams.styleList.forEach(each => {
                    output.style[each.property] = each.value;
                });
            }

            return output;
        } catch (err) {
         //   alert('JS Error ::  :: spanFormatter')
            console.error(err)
        }
    }

    getNestedValue(rowData, fieldPath) {
        return fieldPath.split(".").reduce((obj, key) => (obj && obj[key] !== undefined ? obj[key] : null), rowData);
    }

    @api records = [];

    handleExpandTextareaField(cell) {
        this.expandedRow = Object.assign({}, {
            label: this.columns.find(column => column.field === cell.getField())?.title,
            value: cell.getValue().replaceAll(/\bwidth="(\d+)"/g, '').replaceAll(/\bheight="(\d+)"/g, '')
        })
        this.showExpandedPopup = true;
    }

    handlePopupClose() {
        this.expandedRow = {};
        this.showExpandedPopup = false;
    }

    handleRowSelection(data) {
        try {
            const selectedRows = [];
            data.forEach(row => {
                console.log('BB row', JSON.stringify(row));

                selectedRows.push(row);
            });
            this.dispatchEvent(new CustomEvent('rowselection', {
                detail: {
                    rows: selectedRows
                }, bubbles: true, composed: true
            }));
        } catch (err) {
        //    alert('JS Error :: lwcMvDataTable :: handleRowSelection');
            console.error(this.serializeError(err));
        }
    }

    handleResize(columns) {
        const fieldApiNames = [];
        const fieldWidths = [];
        columns.forEach(column => {
            const fieldName = column.getField();
            if (fieldName) {
                const currentColumn = this.columns.find(column => column?.field === fieldName);
                fieldApiNames.push(this.sanitizeColumnName(currentColumn.formatterParams?.labelField ?? fieldName));
                fieldWidths.push(column.getWidth());
            }
        });
        this.dispatchEvent(new CustomEvent('widthresize', {
            detail: {
                fieldWidths: fieldWidths,
                fieldApiNames: fieldApiNames
            }, bubbles: true, composed: true
        }));
    }

    handleSortData(sorters, rows) {
        const fieldApiNames = [];
        const directions = [];
        const sortedRows = [];
        rows.forEach(row => {
            const currentRow = row.getData();
            const newRow = {};
            Object.keys(currentRow).forEach(key => {
                const newKey = this.sanitizeColumnName(key);
                newRow[newKey] = currentRow[key];
            })
            sortedRows.push(newRow);
        });
        sorters.forEach(sorter => {
            const currentColumn = this.columns.find(column => column.field === sorter.field);
            const fieldName = (currentColumn?.type?.toLocaleLowerCase() === 'reference') ?
                currentColumn?.formatterParams?.labelField : sorter.field;

            fieldApiNames.push(this.sanitizeColumnName(fieldName));
            directions.push(sorter.dir);
        });
        this.dispatchEvent(new CustomEvent('fieldsort', {
            detail: {
                directions: directions,
                fieldApiNames: fieldApiNames,
                rows: sortedRows
            }, bubbles: true, composed: true
        }));
    }

    handleFilterData(rows) {
        const filteredRows = [];
        rows.forEach(row => {
            const currentRow = row.getData();
            const newRow = {};
            Object.keys(currentRow).forEach(key => {
                const newKey = this.sanitizeColumnName(key);
                newRow[newKey] = currentRow[key];
            })
            filteredRows.push(newRow);
        });
        this.dispatchEvent(new CustomEvent('fieldfilter', { detail: { rows: filteredRows }, bubbles: true, composed: true }));
    }

    sanitizeColumnName(columnName) {
        return columnName.replaceAll('+', '.');
    }

    table;

    @api
    updateTableData(data) {
        this.records = data;
        //  this.initTable();

        this.table.setData(data).then(() => {
            // resolve();
        });
    }

    @api
    addTableData(data, topOrBottom) {
        let dataTemp = [...this.records, ...data];
        this.records = dataTemp;

        this.table.addData(data, topOrBottom);
    }

    /*
    @api
    updateTableHeight(){
       try{
        const container = this.template.querySelector('.result-table');
        container.style.height = '900px';
        //  window.setTimeout(()=>{
        //   this.table.redraw();
        // }, 3000); 
       }catch(err){
           alert('JS Error ::  :: updateTableHeight')
           console.error(err)
       }
    }
    */

    //----- tabulator table -----
    async initTable(latestTimeoutCount) {
        console.log('Initialized table');
        console.log('columns: ' + JSON.stringify(this.columns));
        console.log('records: ' + JSON.stringify(this.records));

        window.setTimeout(() => {
            if (this.table) {
                this.table.destroy();
            }
        }, 50);

        window.setTimeout(() => {
            try {
                //define custom formatter function
                var tagFormatter = function (cell, formatterParams, onRendered) {
                    var vaules = cell.getValue();
                    var tags = "";

                    if (values) {
                        values.forEach(function (value) {
                            tags += "<span class='tag'>" + value + "</span>";
                        });
                    }
                    return tags;
                }

                let self = this;
                const reocordsCloned = JSON.parse(JSON.stringify(this.records));
                const customHeight = this.height ? this.height : ( this.clientHeight ?? '400px' );
                const tableEl = this.template.querySelector('.result-table');
                this.table = new Tabulator(tableEl, {
                    height: customHeight,
                    layout: this.layout,
                    reactiveData: true,
                    virtualDom: true,
                    virtualDomBuffer: 10000,
                    rowHeight: this.rowHeight,
                    resizableColumns: false,
                    resizableRows: this.resizableRows,
                  //  resizableRowGuide: true,
                    movableRows: this.movableRows,
                    movableColumns: this.movableColumns,
                    //pagination: "remote",
                    pagination: this.pagination,
                 //   responsiveLayout: 'collapse',
                    data: reocordsCloned,
                    columns: this.columns,
                    rowFormatter: this.applyRowStyles,
                    paginationSize: this.paginationSize,
                    paginationSizeSelector: this.paginationSelectorValues,
                    groupBy: this.customSettings?.groupByFieldName || undefined,
                    groupStartOpen: this.customSettings?.groupByFieldName ? false : undefined
                });

                this.isTabulatorReady = true;

                this.table.on("rowSelectionChanged", function (data) {
                    self.handleRowSelection(data);
                });

                this.table.on("tableBuilt", () => {
                    console.log("Table built successfully");

                    if(latestTimeoutCount == this.latestTimeoutCount){
                        this.hideSpinner();
                    }
                });

            }
            catch (err) {
                this.isSpinner = false;
                console.error('error initializeDynamicTable:' + JSON.stringify(err));
                console.error(this.serializeError(err));
            }

        }, 200);
    }

    serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
            // ...error
        });
    }

    /* applyRowStyles(row){
        const rowEl = row.getElement();

        if (rowEl.classList.contains('tabulator-row-even')) {
            rowEl.style.backgroundColor = "#f2f2f2"; 
            rowEl.addEventListener('mouseenter', function () {
                if (rowEl.classList.contains('tabulator-row-even')) {
                    rowEl.style.backgroundColor = "#bbb"; 
                } 
            });

            rowEl.addEventListener('mouseleave', function () {
                if (rowEl.classList.contains('tabulator-row-even')) {
                    rowEl.style.backgroundColor = "#f2f2f2"; 
                } 
            });
        } 
    } */
    applyRowStyles(row) {
        const rowEl = row.getElement();
        rowEl.style.backgroundColor = "#f2f2f2";
        // rowEl.style.position = "relative";
        // rowEl.style.overflow = "visible";
        rowEl.addEventListener('mouseenter', function () {
            rowEl.style.backgroundColor = "#bbb";
        });
        rowEl.addEventListener('mouseleave', function () {
            rowEl.style.backgroundColor = "#f2f2f2";
        });

     /*  this.fixRowSizeFunc(row);*/

     /*
     console.log('**** Start *****');
   //  var ogCalcHeight = row.scrollHeight;
        // console.log(ogCalcHeight);
        row.height = () => {
            console.log('1111');
          var item = row;
          var maxHeight = 0,
            minHeight = item.element[0].clientHeight;
          item.cells.forEach(function(cell) {
            if (cell.column.visible === true) {
              var height = cell.getHeight();
              if (height > maxHeight) {
                maxHeight = height;
              }
            }
          });
          item.height = Math.max(maxHeight, minHeight);
          item.outerHeight = this.element[0].offsetHeight;
        };

         row.normalizeHeight();*/
    }

    createInputElement(cell, onRendered, success, cancel, editorParams) {
        const container = document.createElement("span");
        const picker = document.createElement("input");
        picker.setAttribute("type", "text");
        picker.setAttribute("placeholder", "");
        picker.style.padding = "4px";
        picker.style.width = "100%";
        picker.style.boxSizing = "border-box";
        picker.style.textAlign = "center";

        $(function () {
            $(picker).daterangepicker({
                locale: {
                    "format": DATEFORMAT.format
                },
                autoUpdateInput: false,
                opens: 'left',
                showDropdowns: true,
                linkedCalendars: false
            }, function (start, end) {
                return [start, end];
            });
            $(picker).on('apply.daterangepicker', function (ev, picker) {
                picker.updateValues();
                success({
                    start: picker.startDate,
                    end: picker.endDate
                });
            });
        });
        container.appendChild(picker);
        return container;
    }

    dateFilterFunction(headerValue, rowValue, rowData, filterParams) {
        console.log('headerValue', JSON.stringify(headerValue));
        console.log('headerValue.start', JSON.stringify(headerValue.start));
        console.log('headerValue.end', JSON.stringify(headerValue.end));
        console.log('rowValue', rowValue);
        console.log('rowData', rowData);
        console.log('filterParams', JSON.stringify(filterParams));
        console.log('filterParams.fieldName', filterParams.fieldName);
        //  const rowDate = new Date(rowData[filterParams.fieldName + 'Origin']);
        const rowDate = new Date(rowValue);
        console.log('rowDate', rowDate);
        return (new Date(headerValue.start) <= rowDate && rowDate <= new Date(headerValue.end));
    }

    getDateFormat() {
        const formatObj = new Intl.DateTimeFormat(DATEFORMAT.locale).formatToParts(new Date());

        return formatObj
            .map(obj => {
                switch (obj.type) {
                    case "day":
                        return "DD";
                    case "month":
                        return "MM";
                    case "year":
                        return "YYYY";
                    default:
                        return obj.value;
                }
            })
            .join("");
    }

    serializeError(error) {
        return JSON.stringify({
            name: error.name,
            message: error.message,
            stack: error.stack//,
            // ...error
        });
    }

    resizeObserver;
    isTabulatorReady = false;
    isRendered = false;

}