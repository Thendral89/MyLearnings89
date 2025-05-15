/* Copyright © 2022 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by  Nikhil A, Dec 23
 */
import { LightningElement,api,wire,track} from 'lwc';
import getJurisdictionDetail from  '@salesforce/apex/JurisdictionGroupHelper.GetJurisdictionDetail';
import getJurisdictionGroupDetail from  '@salesforce/apex/JurisdictionGroupHelper.GetJurisdictionGroupDetail';
export default class JurisdictionGroup extends LightningElement 
{
    //@api clientId = 'a365f000000UmhWAAS';
    @api clientId;
    @api jurisdictionDataList = [];
    @api assetType ='';
    jurisdictionGroupValues = [];
    jurisdictionList = [];
    countryList = [];
    initialRecords = [];
    showDataTable = false;
    selectedJurisdictionGroups = [];
    showJurisdictionGroup = false;
    preSelectedRows = [];
    finalSelectedRows = []
    selectedJurisdictions = [];
    dispatchJurisdictionList =[];
    sortBy;
    sortDirection;
    countryValues = [];
    @api tableList = [];
    selectedDatatableItems = [];
    initialPreSelectedRows = [];
    initialJurisdictionGroup = [];
    dataTableHeight="slds-p-top_small variableLength";
    dataListLength = 7;
    column = [{ label: 'Jurisdiction', fieldName: 'SymphonyLF__Jurisdiction__r.Name', wrapText:true,sortable: "true"},
    {label: 'Group Name', fieldName: 'SymphonyLF__Jurisdiction_Group__r.Name', wrapText:true,sortable: "true"}];

    connectedCallback()
    {
        if(this.clientId != null)
        {
            getJurisdictionDetail({clientId:this.clientId,assetType:this.assetType})
            .then((jurisdictionGroupList) => {
                if(jurisdictionGroupList != null && jurisdictionGroupList.jurisdictionGroup != null && jurisdictionGroupList.jurisdictionGroup.length > 0)
                {
                    jurisdictionGroupList.jurisdictionGroup.forEach(row => {
                        const jurisdictionGroupList={};
                        jurisdictionGroupList.label=row.Name;
                        jurisdictionGroupList.value=row.Name;
                        jurisdictionGroupList.key=row.Id;
                        this.jurisdictionGroupValues.push(jurisdictionGroupList);
                    });
                    this.showJurisdictionGroup =true;
                }
                if(jurisdictionGroupList != null && jurisdictionGroupList.jurisdictions != null && jurisdictionGroupList.jurisdictions.length > 0)
                {
                    jurisdictionGroupList.jurisdictions.forEach(row => {
                        const jurisdiction={};
                        jurisdiction.label=row.Name;
                        jurisdiction.value=row.Name;
                        jurisdiction.key=row.Id;
                        this.countryValues.push(jurisdiction);
                    });
                    this.showJurisdictionGroup =true;
                }
                console.log('jurisdictionGroupList : ',JSON.stringify(jurisdictionGroupList));
            })
            .catch((error) => 
            {
                console.log(error);
            });
            if(this.jurisdictionDataList !=  null && this.jurisdictionDataList.length > 0) 
            {
                
                let groupIds = [];
                let jurisdictionIds = [];
                for(let data of this.jurisdictionDataList)
                {
                    if(data.groupId.length > 0 && !groupIds.some(x => x === data.groupId))
                    {
                        groupIds.push(data.groupId);
                        let initialDict={label:'',key:data.groupId,value:''};
                        this.initialJurisdictionGroup.push(initialDict);
                    }
                    if(data.groupId == '' || data.groupId == null)
                        jurisdictionIds.push(data.jurisdictionId);   //Get the Ids of the Jurisdiction Group selected in the UI
                }
                this.preSelectedRows = [];
                this.tableList = [];
                getJurisdictionGroupDetail({jurisdictionGroupId:groupIds,jurisdictionId:jurisdictionIds,assetType:this.assetType})
                .then((jurisdictionDetail) =>{
                    this.selectedJurisdictionGroups = [];
                    this.selectedJurisdictions = [];
                    if(jurisdictionDetail != null && jurisdictionDetail.groupDetail != null && jurisdictionDetail.groupDetail.length > 0)
                    {
                        this.jurisdictionList = [];
                        this.showDataTable = true;
                        for (let row of jurisdictionDetail.groupDetail) 
                        {
                            const jurisdiction={};
                            jurisdiction.label=row.SymphonyLF__Jurisdiction_Group__r.Name;
                            jurisdiction.value=row.SymphonyLF__Jurisdiction_Group__r.Name;
                            jurisdiction.key=row.SymphonyLF__Jurisdiction_Group__c;
                            if(!this.selectedJurisdictionGroups.some(x => x.key === row.SymphonyLF__Jurisdiction_Group__c))
                            {
                                this.selectedJurisdictionGroups.push(jurisdiction);
                            }
                            const flattenedRow = {};   
                            this.newRecords++;            
                            // get keys of a single row — Name, Phone, LeadSource and etc
                            let rowKeys = Object.keys(row);                 
                            //iterate 
                            rowKeys.forEach((rowKey) => {                     
                                //get the value of each key of a single row. John, 999-999-999, Web and etc
                                const singleNodeValue = row[rowKey];                     
                                //check if the value is a node(object) or a string
                                if(singleNodeValue.constructor === Object){                         
                                    //if it's an object flatten it
                                    this._flatten(singleNodeValue, flattenedRow, rowKey)       
                                }else{                         
                                    //if it’s a normal string push it to the flattenedRow array
                                    flattenedRow[rowKey] = singleNodeValue;
                                }                     
                            });
                            
                            flattenedRow.uniqueId = row.SymphonyLF__Jurisdiction_Group__r.Name.replace(/\s+/g, '_') + '_' + row.SymphonyLF__Jurisdiction__c;  // forms a uniqueId for each jurisdictionGroup record as "GroupName__JurisdictionId"
                            if(groupIds.some(x => x === row.SymphonyLF__Jurisdiction_Group__c))
                            {
                                if(this.jurisdictionDataList.some(x => x.jurisdictionId === row.SymphonyLF__Jurisdiction__c))
                                    this.preSelectedRows.push(flattenedRow.uniqueId);
                            }
                            this.jurisdictionList.push(flattenedRow);
                        }
                        this.tableList = this.jurisdictionList;
                    }
                    if(jurisdictionDetail != null && jurisdictionDetail.jurisdictions != null && jurisdictionDetail.jurisdictions.length > 0)
                    {
                        this.showDataTable = true;                       
                        for(let row of jurisdictionDetail.jurisdictions)
                        {
                            const jurisdiction={};
                            jurisdiction.label=row.Name;
                            jurisdiction.value=row.Name;
                            jurisdiction.key=row.Id;
                            this.selectedJurisdictions.push(jurisdiction);
                            let countryKeyValue = {};
                            countryKeyValue['SymphonyLF__Jurisdiction__c'] = row.Id;
                            countryKeyValue['SymphonyLF__Jurisdiction_Group__c'] = '';
                            countryKeyValue['Id'] = '';
                            countryKeyValue['SymphonyLF__Jurisdiction__r.Name'] = row.Name;
                            countryKeyValue['SymphonyLF__Jurisdiction_Group__r.Name'] = '';
                            countryKeyValue['uniqueId'] = row.Id;
                            this.countryList.push(countryKeyValue);                
                            if(jurisdictionIds.some(x => x === row.Id))
                            {
                                if(this.preSelectedRows != null && this.preSelectedRows.length > 0)
                                {
                                    let status = this.preSelectedRows.some(country => country === row.Id); //checks whether the Id is already there in tableList, if not then it will be added to preSelectedRows
                                    if(!status)
                                        this.preSelectedRows=[...this.preSelectedRows,row.Id];
                                }
                                else
                                    this.preSelectedRows.push(row.Id); 
                            }
                        }
                        
                        if(this.tableList != null && this.tableList.length > 0)
                        {
                            this.showDataTable = true;
                            for(let row of this.countryList)
                            {
                                let status = this.tableList.some(country => country.uniqueId === row.uniqueId);
                                if(!status)
                                    this.tableList=[...this.tableList,row];
                            }
                        }
                        else
                        {
                            this.tableList = this.countryList;
                            this.showDataTable = true;
                        }
                    }
                    this.finalSelectedRows = this.preSelectedRows;
                    console.log('countryValues : ',JSON.stringify(this.selectedJurisdictions));
                    if(this.template.querySelector('.jurisdictionGroup') != null && this.selectedJurisdictionGroups != null && this.selectedJurisdictionGroups.length > 0)
                        this.template.querySelector('.jurisdictionGroup').setValues(this.jurisdictionGroupValues,this.selectedJurisdictionGroups);
                    if(this.template.querySelector('.jurisdiction') != null && this.selectedJurisdictions != null && this.selectedJurisdictions.length > 0)
                        this.template.querySelector('.jurisdiction').setValues(this.countryValues,this.selectedJurisdictions);
                    if(this.tableList != null && this.tableList.length > this.dataListLength)
                    {
                        this.dataTableHeight="slds-p-top_small fixedLength"; 
                    }
                    for(let row of this.tableList)
                    {
                        if(this.finalSelectedRows.includes(row.uniqueId))
                        {
                            let dispatchJurisdiction = {};
                            dispatchJurisdiction={jurisdictionName:(row['SymphonyLF__Jurisdiction__r.Name'] != null) ? row['SymphonyLF__Jurisdiction__r.Name']:'',
                            jurisdictionId:(row['SymphonyLF__Jurisdiction__c']!= null) ? row['SymphonyLF__Jurisdiction__c']:'',
                            groupName:(row['SymphonyLF__Jurisdiction_Group__r.Name'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Name']:'',
                            groupId:(row['SymphonyLF__Jurisdiction_Group__r.Id'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Id']:''};
                            this.dispatchJurisdictionList.push(dispatchJurisdiction);
                        }
                    }
                    let uniqueObjArray = [
                        ...new Map(this.dispatchJurisdictionList.map((item) => [item["jurisdictionId"], item])).values(),
                    ];  
                    this.dispatchEvent(new CustomEvent("selection", {                         //dispatch event
                        detail:{selectedJurisdictions:[...uniqueObjArray]}
                    }));
                })
                .catch((error) => 
                {
                    console.log(error);
                });
                
            }
            
        }
    }
    _flatten = (nodeValue, flattenedRow, nodeName) => {        
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }
    handleSelectedJurisdictionGroups(event)
    {
        this.selectedDatatableItems = [];
        this.dispatchJurisdictionList = [];
        let jurisdictionGroupIdList = [];
        let removedItems = [];
        this.selectedJurisdictionGroups = event.detail;
        let tempInitialList = [];
        for(let row of this.initialJurisdictionGroup)
        {
            if(this.selectedJurisdictionGroups != null && this.selectedJurisdictionGroups.length > 0 && this.selectedJurisdictionGroups.some(x => x.key === row.key))
            {
                tempInitialList.push(row);
            }
            else
                removedItems.push(row);
        }
        if(tempInitialList!=null && tempInitialList.length > 0)
        {
            this.initialJurisdictionGroup= [] ;
            this.initialJurisdictionGroup = tempInitialList;
        }
        if(event.detail != null && event.detail.length > 0)
        { 
            
            for(let data of this.selectedJurisdictionGroups)
            {
                if(this.initialJurisdictionGroup != null && this.initialJurisdictionGroup.length > 0)
                {
                    if(!this.initialJurisdictionGroup.some(x => x.key === data.key))
                    {
                        this.initialJurisdictionGroup=[...this.initialJurisdictionGroup,data];
                        jurisdictionGroupIdList.push(data.key);
                    }
                }
                else
                {
                    this.initialJurisdictionGroup.push(data);
                    jurisdictionGroupIdList.push(data.key);
                }
            }
            if(jurisdictionGroupIdList != null && jurisdictionGroupIdList.length > 0)
            {
                getJurisdictionGroupDetail({jurisdictionGroupId:jurisdictionGroupIdList,jurisdictionId:null,assetType:this.assetType})
                .then((jurisdictionDetail) =>{
                    if(jurisdictionDetail != null && jurisdictionDetail.groupDetail != null && jurisdictionDetail.groupDetail.length > 0)
                    {
                        this.jurisdictionList = [];
                        this.showDataTable = true;
                        let selectedIds = [];
                        for (let row of jurisdictionDetail.groupDetail) 
                        {
                            const flattenedRow = {}     
                            this.newRecords++;            
                            // get keys of a single row — Name, Phone, LeadSource and etc
                            let rowKeys = Object.keys(row);                 
                            //iterate 
                            rowKeys.forEach((rowKey) => {                     
                                //get the value of each key of a single row. John, 999-999-999, Web and etc
                                const singleNodeValue = row[rowKey];                     
                                //check if the value is a node(object) or a string
                                if(singleNodeValue.constructor === Object){                         
                                    //if it's an object flatten it
                                    this._flatten(singleNodeValue, flattenedRow, rowKey)       
                                }else{                          
                                    //if it’s a normal string push it to the flattenedRow array
                                    flattenedRow[rowKey] = singleNodeValue;
                                }                     
                            });
                            flattenedRow.uniqueId = row.SymphonyLF__Jurisdiction_Group__r.Name.replace(/\s+/g, '_') + '_' + row.SymphonyLF__Jurisdiction__c;  // forms a uniqueId for each jurisdictionGroup record as "GroupName__JurisdictionId"
                            selectedIds.push(flattenedRow.uniqueId);
                            this.jurisdictionList.push(flattenedRow);
                        }
                        
                        
                        if(this.tableList !=null && this.tableList.length > 0)
                        {
                            this.showDataTable = true;
                            for(let row of this.jurisdictionList)
                            {
                                let status = this.tableList.some(country => country.uniqueId === row.uniqueId); //add jurisdiction if not available in tablelist already
                                if(!status)
                                    this.tableList=[...this.tableList,row];
                            }
                        }
                        else
                            this.tableList = this.jurisdictionList;
                        if(this.preSelectedRows != null && this.preSelectedRows.length > 0)
                        {
                            for(let id of selectedIds)
                            {
                                let status = this.preSelectedRows.some(country => country === id); //checks whether the Id is already there in tableList, if not then it will be added to preSelectedRows
                                if(!status)
                                {
                                        this.preSelectedRows=[...this.preSelectedRows,id];
                                }
                                    
                            }
                        }
                        else
                            this.preSelectedRows = selectedIds;
                        this.initialPreSelectedRows = this.preSelectedRows; 
                        if(this.initialRecords != null && this.initialRecords.length > 0)
                        {
                            this.initialRecords = [];
                            this.initialRecords = this.tableList;
                        }
                        else
                            this.initialRecords = this.tableList;
                        for(let row of this.tableList)
                        {
                            var itemAvailable=this.preSelectedRows.some(x => x==row.uniqueId);
                            if(itemAvailable)
                            {
                                this.selectedDatatableItems.push(row);
                            }
                        }
                        for(let row of this.selectedDatatableItems)
                        {
                            let dispatchJurisdiction = {};
                            dispatchJurisdiction={jurisdictionName:(row['SymphonyLF__Jurisdiction__r.Name'] != null) ? row['SymphonyLF__Jurisdiction__r.Name']:'',
                            jurisdictionId:(row['SymphonyLF__Jurisdiction__c']!= null) ? row['SymphonyLF__Jurisdiction__c']:'',
                            groupName:(row['SymphonyLF__Jurisdiction_Group__r.Name'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Name']:'',
                            groupId:(row['SymphonyLF__Jurisdiction_Group__r.Id'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Id']:''};
                            this.dispatchJurisdictionList.push(dispatchJurisdiction);
                        }
                        let uniqueObjArray = [
                            ...new Map(this.dispatchJurisdictionList.map((item) => [item["jurisdictionId"], item])).values(),
                        ];  
                        this.dispatchEvent(new CustomEvent("selection", {                         //dispatch event
                            detail:{selectedJurisdictions:[...uniqueObjArray]}
                        }));
                    }
                    
                })
                .catch((error) => 
                {
                    console.log(error);
                });
            }
            else if(removedItems != null && removedItems.length > 0)
            {
                const tempList = [];
                for(let item of this.tableList)
                {
                    if(!(removedItems.some(x => x.key === item.SymphonyLF__Jurisdiction_Group__c)))
                    {
                        tempList.push(item);
                    }
                }
                if(tempList != null && tempList.length > 0)
                    this.tableList = [...tempList];
            }
            
        }
        else
        {
            this.initialJurisdictionGroup= [] ;
            const tempList = [];
            for(let item of this.tableList)
            {
                if(!(removedItems.some(x => x.key === item.SymphonyLF__Jurisdiction_Group__c)))
                {
                    tempList.push(item);
                }
            }
            this.tableList = [];
            this.tableList = [...tempList];
            if(this.initialRecords != null && this.initialRecords.length > 0)
            {
                this.initialRecords = [];
                this.initialRecords = this.tableList;
            }
            else
                this.initialRecords = this.tableList;

            this.initialPreSelectedRows=this.preSelectedRows;
            for(let row of this.tableList)
            {
                var itemAvailable=this.preSelectedRows.some(x => x==row.uniqueId);
                if(itemAvailable)
                {
                    this.selectedDatatableItems.push(row);
                }
            }
            for(let row of this.selectedDatatableItems)
            {
                let dispatchJurisdiction = {};
                dispatchJurisdiction={jurisdictionName:(row['SymphonyLF__Jurisdiction__r.Name'] != null) ? row['SymphonyLF__Jurisdiction__r.Name']:'',
                jurisdictionId:(row['SymphonyLF__Jurisdiction__c']!= null) ? row['SymphonyLF__Jurisdiction__c']:'',
                groupName:(row['SymphonyLF__Jurisdiction_Group__r.Name'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Name']:'',
                groupId:(row['SymphonyLF__Jurisdiction_Group__r.Id'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Id']:''};
                this.dispatchJurisdictionList.push(dispatchJurisdiction);
            }
            let uniqueObjArray = [
                ...new Map(this.dispatchJurisdictionList.map((item) => [item["jurisdictionId"], item])).values(),
            ];
            this.dispatchEvent(new CustomEvent("selection", {                         //dispatch event
                detail:{selectedJurisdictions:uniqueObjArray}
            }));
        }
        if(this.tableList == null || this.tableList.length == 0)
            this.showDataTable = false;
        else if(this.tableList.length > this.dataListLength)
        {
            this.dataTableHeight="slds-p-top_small fixedLength"; 
        }  
    }
    handleSelectedJurisdictions(event)
    {
        this.selectedDatatableItems = [];
        this.dispatchJurisdictionList = [];
        if(event.detail != null && event.detail.length > 0)
        {
            let selectedIds = [];
            this.selectedJurisdictions = event.detail;
            let tempCountryList = [];
            tempCountryList=this.countryList;
            let removedItems = [];
            this.countryList =[];
            for(let row of this.selectedJurisdictions)
            {
                selectedIds.push(row.key);
                let countryKeyValue = {};
                countryKeyValue['SymphonyLF__Jurisdiction__c'] = row.key;
                countryKeyValue['SymphonyLF__Jurisdiction_Group__c'] = '';
                countryKeyValue['Id'] = '';
                countryKeyValue['SymphonyLF__Jurisdiction__r.Name'] = row.label;
                countryKeyValue['SymphonyLF__Jurisdiction__r.Id'] = row.key;
                countryKeyValue['SymphonyLF__Jurisdiction_Group__r.Name'] = '';
                countryKeyValue['SymphonyLF__Jurisdiction_Group__r.Id'] = '';
                countryKeyValue['uniqueId'] = row.key;
                this.countryList.push(countryKeyValue);                
                this.showDataTable = true;
            }
            for(let row of tempCountryList)
            {
                if(!this.countryList.some(country => country.uniqueId === row.uniqueId))
                {
                    removedItems.push(row);
                }
            }
            const tempList = [];
            for(let item of this.tableList)
            {
                if(!(removedItems.some(x => x.uniqueId === item.uniqueId)))
                {
                    tempList.push(item);
                }
            }
            if(tempList != null && tempList.length > 0)
                this.tableList = [...tempList];
            for(let id of selectedIds)
            {
                let status = this.tableList.some(x => x.uniqueId === id);
                if(!status)
                    this.preSelectedRows=[...this.preSelectedRows,id];
            }
            if(this.tableList != null && this.tableList.length > 0)
            {
                this.showDataTable = true;
                for(let row of this.countryList)
                {
                    let status = this.tableList.some(country => country.uniqueId === row.uniqueId);
                    if(!status)
                        this.tableList=[...this.tableList,row];
                }
            }
            else
                this.tableList = this.countryList;
            if(this.initialRecords != null && this.initialRecords.length > 0)
            {
                this.initialRecords = [];
                this.initialRecords = this.tableList;
            }
            else
                this.initialRecords = this.tableList;
            this.initialPreSelectedRows=this.preSelectedRows;
        }
        else
        {
            const tempList = [];
            let tempItems = this.tableList;
            for(let item of tempItems)
            {
                if(!(this.countryList.some(x => x.uniqueId === item.uniqueId)))
                {
                    tempList.push(item);
                }
            }
            this.tableList = [];
            this.tableList = [...tempList];
            if(this.initialRecords != null && this.initialRecords.length > 0)
            {
                this.initialRecords = [];
                this.initialRecords = this.tableList;
            }
            else
                this.initialRecords = this.tableList;
            this.initialPreSelectedRows=this.preSelectedRows;
        }
        for(let row of this.tableList)
        {
            var itemAvailable=this.preSelectedRows.some(x => x==row.uniqueId);
            if(itemAvailable)
            {
                this.selectedDatatableItems.push(row);
            }
        }
        for(let row of this.selectedDatatableItems)
        {
            let dispatchJurisdiction = {};
            dispatchJurisdiction={jurisdictionName:(row['SymphonyLF__Jurisdiction__r.Name'] != null) ? row['SymphonyLF__Jurisdiction__r.Name']:'',
            jurisdictionId:(row['SymphonyLF__Jurisdiction__c']!= null) ? row['SymphonyLF__Jurisdiction__c']:'',
            groupName:(row['SymphonyLF__Jurisdiction_Group__r.Name'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Name']:'',
            groupId:(row['SymphonyLF__Jurisdiction_Group__r.Id'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Id']:''};
            this.dispatchJurisdictionList.push(dispatchJurisdiction);
        }
        let uniqueObjArray = [
            ...new Map(this.dispatchJurisdictionList.map((item) => [item["jurisdictionId"], item])).values(),
        ];

        this.dispatchEvent(new CustomEvent("selection", {                         //dispatch event
            detail:{selectedJurisdictions:uniqueObjArray}
        }));
        if(this.tableList == null || this.tableList.length == 0)
            this.showDataTable = false;
        else if(this.tableList.length > this.dataListLength)
        {
            this.dataTableHeight="slds-p-top_small fixedLength"; 
        }
    }
    getSelectedRows(event)
    {
        this.preSelectedRows = [];
        if(event.detail != null && event.detail.selectedRows.length > 0)
        {
            let deselectedRows = [];
            let newselectedRows = [];
            const temp =[];
            const tempVariable =[];
            this.dispatchJurisdictionList = [];
            let selectedRows = event.detail.selectedRows;
            
            for(let row of selectedRows)
            {
                let status = this.finalSelectedRows.some(country => country === row.uniqueId);
                if(!status)
                {
                    newselectedRows.push(row);
                }
            }
            this.selectedDatatableItems = []; 
            selectedRows.forEach(item=>{
                this.preSelectedRows.push(item.uniqueId);
            });
            for(let row of this.tableList)
            {
                let status = selectedRows.some(country => country.uniqueId === row.uniqueId);
                if(!status)
                {
                    deselectedRows.push(row);
                }
            }
            for(let row of deselectedRows)
            {
                let status = selectedRows.some(x => x.SymphonyLF__Jurisdiction__c === row.SymphonyLF__Jurisdiction__c);
                if(status)
                {
                    this.preSelectedRows.forEach(item =>{
                        if(item.includes(row.SymphonyLF__Jurisdiction__c))
                        {
                            temp.push(item);
                        }
                    });
                }
            }
            
            if(temp != null && temp.length > 0)
            {
                let tempList = [];
                tempList = this.preSelectedRows.filter(val => !temp.includes(val));                
                if(tempList != null && tempList.length > 0)
                {
                    this.preSelectedRows = [];
                    this.preSelectedRows = tempList;
                }

            }
            if(newselectedRows != null && newselectedRows.length > 0)
            {
                let newMatchedJurisdiction = [];
                for(let row of newselectedRows)
                {
                    let list = this.tableList.filter(x => x.SymphonyLF__Jurisdiction__c === row.SymphonyLF__Jurisdiction__c);
                    if(list != null && list.length > 0)
                    {
                        list.forEach(item =>{                          
                            newMatchedJurisdiction.push(item.uniqueId);
                        });
                    }
                }
                
                this.preSelectedRows = [ ...this.preSelectedRows,...newMatchedJurisdiction];
            }
            this.finalSelectedRows = this.preSelectedRows;

            for(let row of selectedRows)
            {
                var itemAvailable=this.preSelectedRows.some(x => x==row.uniqueId);
                if(itemAvailable)
                {
                    this.selectedDatatableItems.push(row);
                }
            }
            if(this.initialRecords != null && this.initialRecords.length > 0)
            {
                this.tableList.forEach(item=>{
                    let status = this.initialRecords.some(country => country.uniqueId === item.uniqueId);
                    if(!status)
                        this.initialRecords=[...this.initialRecords,item];
                });
            }
            else
                this.initialRecords = this.tableList;
            
            this.preSelectedRows.forEach(item=>{
                let status = this.initialPreSelectedRows.some(country => country === item);
                if(!status)
                    this.initialPreSelectedRows=[...this.initialPreSelectedRows,item];
            });
            for(let row of deselectedRows)
            {
                let status = this.initialPreSelectedRows.some(x => x === row.uniqueId);
                if(status)
                {
                    this.initialPreSelectedRows.forEach(item =>{
                        if(!item.includes(row.SymphonyLF__Jurisdiction__c))
                        {
                            tempVariable.push(item);
                        }
                    });
                }
            }
            if(tempVariable != null && tempVariable.length > 0)
            {
                this.initialPreSelectedRows=[];
                this.initialPreSelectedRows = [...tempVariable];
            }
            for(let row of this.selectedDatatableItems)
            {
                let dispatchJurisdiction = {};
                dispatchJurisdiction={jurisdictionName:(row['SymphonyLF__Jurisdiction__r.Name'] != null) ? row['SymphonyLF__Jurisdiction__r.Name']:'',
                jurisdictionId:(row['SymphonyLF__Jurisdiction__c']!= null) ? row['SymphonyLF__Jurisdiction__c']:'',
                groupName:(row['SymphonyLF__Jurisdiction_Group__r.Name'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Name']:'',
                groupId:(row['SymphonyLF__Jurisdiction_Group__r.Id'] != null) ? row['SymphonyLF__Jurisdiction_Group__r.Id']:''};
                this.dispatchJurisdictionList.push(dispatchJurisdiction);
            }
            let uniqueObjArray = [
                ...new Map(this.dispatchJurisdictionList.map((item) => [item["jurisdictionId"], item])).values(),
            ];
            this.dispatchEvent(new CustomEvent("selection", {                         //dispatch event
                detail:{selectedJurisdictions:uniqueObjArray}
            }));
        }
        else
        {
            this.dispatchEvent(new CustomEvent("selection", {                         //dispatch event
                detail:{selectedJurisdictions:[]}
            }));
        }
    }
    handleSearch( event ) 
    {
        const searchKey = event.target.value.toLowerCase();
        let tempTableList = this.tableList;
        if ( searchKey ) 
        {
            if (this.tableList)
            {
                let recs = [];
                for (let rec of this.tableList) 
                {
                    let valuesArray = Object.values( rec );
                    for ( let val of valuesArray ) 
                    {
                        let strVal = String( val );
                        if ( strVal ) 
                        {
                            if ( strVal.toLowerCase().includes( searchKey ) ) 
                            {
                                recs.push( rec );
                                break;
                            }
                        }
                    }
                }
                this.tableList = recs;
             }
             else
             {
                this.tableList = [...tempTableList];
             }
        } 
        else 
        {
            this.tableList = [];
            this.tableList = this.initialRecords;
            this.preSelectedRows = [];
            this.preSelectedRows = this.initialPreSelectedRows;
        }        
    }
    get setDatatableHeight() {
        if(this.count==0){//set the minimum height
            return 'height:2rem;';
        }
        else if(this.count>10){//set the max height
                return 'height:50rem;';
        }
        return '';//don't set any height (height will be dynamic)
    }
    handleSortData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) 
    {
        let parseData = JSON.parse(JSON.stringify(this.tableList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
        return isReverse * ((x > y) - (y > x));
        });
        this.tableList = parseData;
    }
}