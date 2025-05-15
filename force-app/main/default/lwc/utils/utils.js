// This contains list of generic methods

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordByQuery from '@salesforce/apex/DynamicSearchRecords.DynamicQueryRecords';
import CheckServiceNowAccess from '@salesforce/apex/SnowFieldVisibility.CheckServiceNowAccess';
export default class Utils {
    static groupBy(arr, property) {  // Function used to group based on property
        return arr.reduce(function(memo, x) {
          if (!memo[x[property]]) { memo[x[property]] = []; }
          memo[x[property]].push(x);
          return memo;
        }, {});
    }
    static _flatten = (nodeValue, flattenedRow, nodeName) => {  //Function used to flatten fields out of a nested structure.
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.' + key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }
    static addFieldInObjList(objList,fieldName,fieldVal){    //Function to add new field in list of objects.
        let returnList=[];
        objList.forEach(rec => {
            let row = JSON.parse(JSON.stringify(rec));
            row[fieldName] = fieldVal;
            returnList.push(row);
        });
        return returnList;
    }
    static IsValidDate(inputDate,checkIsFutureDate)
    { 
        let dateValue = inputDate.value;
        let error = '';
        let IsValidDate = false;
        if(dateValue){
            let Due_Date=new Date(dateValue);
            let today=new Date();
            let difference=Due_Date.getTime()-today.getTime();
            let dayscount=(difference/(1000 * 60 * 60* 24));
            var today1 = new Date();
            var dd = String(today1.getDate()).padStart(2, '0');
            var mm = String(today1.getMonth() + 1).padStart(2, '0'); 
            var yyyy = today1.getFullYear();
            today1 = yyyy + '-' + mm + '-' + dd ;
            var d1 = JSON.stringify(today1);
            var d2 = JSON.stringify(dateValue);
            if(d1 == d2)
            {
                error='';
                IsValidDate = true;
            }
            else if(dayscount<0 && !checkIsFutureDate)
            { 
                error='Date cannot be a past date';
                IsValidDate = false;
            }
            else if(dayscount>0 && checkIsFutureDate)
            {
                error='Date cannot be a future date.';
                IsValidDate = false;
            }
            else
            {
                error='';
                IsValidDate = true;
            }  
        }
       let returnData={};
       returnData.IsValidDate=IsValidDate;
       returnData.error=error;
       return returnData;
    }    
    /* Usage guidelines for these methods: addFieldInObjList & showToast
     * import { LightningElement } from 'lwc';
     * import Utils from 'c/utils';
     * export default class YourComponentName extends LightningElement {
     *     someMethod(){
     *         Utils.addFieldInObjList(Arrays_of_objects,fieldApiName,valueToBeUpdatedInField);
     *         Utils.showToast(this,'Information','Fill all the mandatory fields in the form');
     *         Utils.showToast(this,'Success','Record Successfully Created','success');
     *         Utils.showToast(this,'Error','Something Went Wrong','error','sticky');
     *     }
     * }
     */
    static showToast(cmpCurInstance,title,message,variant='info',mode='dismissible'){  //Function to show toast message with default values of mode and variant
        cmpCurInstance.dispatchEvent(new ShowToastEvent({ 
            title: title,
            message: message,
            variant: variant,
            mode: mode
        }));
    }
     
     /* Usage guidelines for these methods: navigateToHome & navigateToRecordViewPage
     * import { LightningElement } from 'lwc';
     * import { NavigationMixin } from 'lightning/navigation';
     * import Utils from 'c/utils';
     * export default class YourComponentName extends NavigationMixin(LightningElement) {
     *     someMethod(){
     *         Utils.navigateToHome(this,NavigationMixin);
     *         Utils.navigateToRecordViewPage(this,NavigationMixin,someRecordId);
     *     }
     * }
     */
    // added by Aman start
    static navigateToHome(cmpCurInstance,cmpNavigationMixinVar) { // Navigates to home page of the app
        cmpCurInstance[cmpNavigationMixinVar.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
    static navigateToRecordViewPage(cmpCurInstance,cmpNavigationMixinVar,recId) { // Navigates to a custom object record view page
        cmpCurInstance[cmpNavigationMixinVar.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                actionName: 'view'
            }
        });
    }
    static navigateToListView(cmpCurInstance,cmpNavigationMixinVar,objectApiName,filterName='Recent') {// Navigate to the Salesforce object's Recent list view.
        cmpCurInstance[cmpNavigationMixinVar.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'list'
            },
            state: {
                filterName: filterName
            }
        });
    }
    // added by Aman end
    static async checkForExistingFieldName(objectName, fieldName, fieldValue, clientId) { //This method checks if there exists a record in an object with a specific field value for a given field name and client ID. It returns true if such a record exists, and false otherwise.
        const query  = "SELECT Id, " + fieldName + " FROM " + objectName + " WHERE " + fieldName + " = '" + fieldValue + "' AND Client__c = '" + clientId + "'";
        const result = await getRecordByQuery({ query: query });
        return result.length > 0; 
    }
    //added by Aman start
    /**
     * Reduces one or more LDS errors into a string[] of error messages.
     * @param {FetchResponse|FetchResponse[]} errors
     * @return {String[]} Error messages
     */
    static reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // Page level errors
                    else if (error?.body?.pageErrors && error.body.pageErrors.length > 0) {
                        return error.body.pageErrors.map((e) => e.message);
                    }
                    // Field level errors
                    else if (error?.body?.fieldErrors && Object.keys(error.body.fieldErrors).length > 0) {
                        const fieldErrors = [];
                        Object.values(error.body.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML page level errors
                    else if (error?.body?.output?.errors && error.body.output.errors.length > 0) {
                        return error.body.output.errors.map((e) => e.message);
                    }
                    // UI API DML field level errors
                    else if (error?.body?.output?.fieldErrors && Object.keys(error.body.output.fieldErrors).length > 0) {
                        const fieldErrors = [];
                        Object.values(error.body.output.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }
    // Service now helper
        static async getServiceNowAccess(clientId) {
            try {
                console.log('clientId in utils: ' + clientId);
                const response = await CheckServiceNowAccess({ clientId });
                console.log('response from Apex: ' + JSON.stringify(response));
                if (response && response.length === 3) {
                    const sNowIntegrationRequired = response[0];
                    const ipsuClient = response[1];
                    const ipsuUser = response[2];
                    let result = [];
                    let serviceNowEnabled = false;
                    let serviceNowTicketFlag = false;
    
                    if (sNowIntegrationRequired) {
                        if (ipsuClient) {
                            if (ipsuUser) {
                                serviceNowEnabled = true;
                            } else {
                                serviceNowEnabled = false;
                                serviceNowTicketFlag = true;
                            }
                        } else {
                            if (ipsuUser) {
                                serviceNowEnabled = true;
                            } else {
                                serviceNowEnabled = false;
                            }
                        }
                    } else {
                        serviceNowEnabled = false;
                        serviceNowTicketFlag = false;
                    }
                    result.push(serviceNowEnabled);
                    result.push(serviceNowTicketFlag);
                    return result;
                }
            } catch (error) {
                console.error('Error in getServiceNowAccess: ' + error);
                throw error;
            }
        }
    // input param: String strDateToCheck (YYYY-MM-DD)
    static isPastDate(strDateToCheck){
        let strToday = this.getStringDate(new Date());
        return strDateToCheck != null && strDateToCheck < strToday ? true : false;
    }
    static isFutureDate(strDateToCheck){
        let strToday = this.getStringDate(new Date());
        return strDateToCheck != null && strDateToCheck > strToday ? true : false;
    }
    static isSameDate(strDateToCheck){
        let strToday = this.getStringDate(new Date());
        return strDateToCheck != null && strDateToCheck == strToday ? true : false;
    }
    static getStringDate(dt){
        return dt.getFullYear()+'-'+(''+(dt.getMonth()+1)).padStart(2,'0')+'-'+(''+dt.getDate()).padStart(2,'0');
    }
    static jsMonthLastDate = [31,28,31,30,31,30,31,31,30,31,30,31];
    static isLeapYear(year){
        return year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0);
    }
    static addMonths(dt,additionalMonths){
        let month = dt.getMonth() + additionalMonths;
        let finalMonth = month % 12 < 0? (month % 12) + 12 : month % 12;
        let finalYear = dt.getFullYear() + Math.trunc(month/12);
        let finalDate = dt.getDate();
        if (month < 0 && month % 12 !== 0) finalYear--;
        if (this.isLeapYear(finalYear)) this.jsMonthLastDate[1] = 29;
        if (finalDate > this.jsMonthLastDate[finalMonth]) finalDate = this.jsMonthLastDate[finalMonth];
        console.log(finalYear+'-'+finalMonth+'-'+finalDate);
        return new Date(finalYear,finalMonth,finalDate);
    }
    static addDays(dt,additionalDays){
        return new Date(1*dt + additionalDays*24*60*60*1000);
    }
    static shiftToStartOfMonth(dt){
        return new Date(dt.getFullYear(),dt.getMonth(),1);
    }
    static isEmptyObject(obj){
        return JSON.stringify(obj) === '{}';
    }
    static isBlank(str){
        return str==null || (typeof str === 'string' && str.trim()=='') ? true : false;
    }
    // added by Aman end
    static constructAddressString(result)
    {
        let concatAddress = '';
        if (result.Address__c !== undefined) {
            concatAddress = result.Address__c + ',\n';
        }
        if (result.City__c !== undefined) {
            concatAddress += result.City__c + ', ';
        }
        if (result.State__c !== undefined) {
            concatAddress += result.State__c + ',\n';
        }
        if (result.Jurisdiction__c !== undefined) {
            concatAddress += result.Jurisdiction__r.Name + ', ';
        }
        if (result.Zip__c !== undefined) {
            concatAddress += result.Zip__c;
        }
        return concatAddress;
    }
}