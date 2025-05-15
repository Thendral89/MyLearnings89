import { LightningElement, wire } from 'lwc';
import { publish, subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import mvPathChannel from '@salesforce/messageChannel/mvPath__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import intakeErrorMessage from '@salesforce/label/c.intakeErrorMessage';

export const makeToastErrorEvent = (error, pageName) => {

    let title = 'Error!';
    let variant = 'error'
    let codeType, message;
    let code = error.code ? error.code : error.status;
    let number = `${code}`.slice(0, 1);

    message = intakeErrorMessage.replace('<PageName>', pageName);

    const event = new ShowToastEvent({ title, message, variant });
    const errorObj = { event, codeType };

    return errorObj;
}

export const getStepNavigation = (props, currentPage) => {

    let rootKey;
    let nextStep;
    let prevStep;
    let nextStepGrp;
    let nav = [];

    let jName = props.progressSteps;
    //jName = isInit ? props.stepGroups : props.progressSteps;
    //console.log('utils prop...' + JSON.stringify(jName));    
    for (var prop in jName) {
        // console.log( "prop is" + prop ); //will give "journeyName"
        // console.log( "prop journeyType is" + props.customer.journeyType ); //will give "journeyName"
        if (prop == props.customer.journeyType) {
            rootKey = prop;
            //console.log('utils rootkey..' + rootKey);
            for (var key in jName[rootKey]) {
                // console.log('utils key-->' + key);
                // console.log('utils currentPage-->' + currentPage);
                if (key === currentPage) {
                    // console.log('utils kep page -->' + key);  
                    // console.log('utils page -->' + JSON.stringify(jName[rootKey][key]));            
                    for (var key1 in jName[rootKey][key]) {
                        //console.log( "key:" + key1 + " --- Value:"+ jName[rootKey][key][key1] );
                        if (key1 == "NextStep") {
                            nextStep = jName[rootKey][key][key1];
                            nav.push({ value: nextStep, key: key1 });
                            //console.log('next step ...' + nextStep);
                        }
                        if (key1 == "StepGroup") {
                            nextStepGrp = jName[rootKey][key][key1];
                            nav.push({ value: nextStepGrp, key: key1 });
                            //getStepGroup(currentPage, nextStepGrp);
                            //console.log('next group...' + nextStepGrp);
                        }
                        if (key1 == "PrevStep") {
                            prevStep = jName[rootKey][key][key1];
                            nav.push({ value: prevStep, key: key1 });
                            //console.log('prev step ...' + prevStep);
                        }
                    }
                    break;
                }
            }
            break;
        }
    }


    return nav;
}

export const getCurrentPage = (props) => {
    console.log('utils props...' + JSON.stringify(props));
    let currentPage;
    let pages = props.pages;
    //console.log('utils active page...' + JSON.stringify(props.pages));
    for (var key in pages.data) {
        //console.log('utils key..' + key + 'journyeType-->' + props.customer.journeyType);
        if (key == props.customer.journeyType) {
            // console.log('utils key..' + key);
            // console.log(pages.data[key]);
            for (var key1 in pages.data[key]) {
                //console.log( "key:" + key1 + " --- Value:"+ pages.data[key][key1] );
                for (var key2 in pages.data[key][key1]) {
                    //console.log( "key2:" + key2 + " --- Value:"+ pages.data[key][key1][key2] );
                    if (key2 == "active" && pages.data[key][key1][key2] == true) {
                        //console.log('active page is...' + key1);
                        currentPage = key1;
                        break;
                    }
                }
            }
        }
    }

    return currentPage;

}

export const getPageByStepGroup = (props, currentPage, stepGroup) => {
    //console.log('utils props...' + JSON.stringify(props));
    let newPage;
    let pages = props.pages;
    let assetType = getAssetType(props.selectedClient.assetType);
    //console.log('utils active page...' + JSON.stringify(props.pages));
    for (var key in pages.data) {
        //console.log('utils key..' + key + 'journyeType-->' + props.customer.journeyType);
        if (key == props.customer.journeyType) {
            // console.log('utils key..' + key);
            // console.log(pages.data[key]);
            for (var key1 in pages.data[key]) {
                // console.log( "key:" + key1 + " --- Value:"+ pages.data[key][key1] );
                var Obj = pages.data[key][key1];
                if (Obj.StepGroup == stepGroup && Obj.isFirstStep
                    && ((assetType && assetType.isPatent)
                        || (assetType && !assetType.isPatent))
                ) {
                    newPage = key1;
                    break;
                }
            }
        }
    }
    // console.log('Curr Page is...' + JSON.stringify(currentPage)); 
    // console.log('New Page is...' + JSON.stringify(newPage)); 
    if (newPage != currentPage) {
        props.changePage2(newPage, currentPage, props.customer.journeyType);
    }
}

export const getChangedJourneyPage = (props, currPage) => {
    //console.log('utils props...' + JSON.stringify(props));
    let currentPage;
    let pages = props.pages;
    //console.log('utils active page...' + JSON.stringify(props.pages));
    for (var key in pages.data) {
        //console.log('utils key..' + key + 'journyeType-->' + props.customer.journeyType);
        if (key != props.customer.journeyType) {
            // console.log('utils key..' + key);
            // console.log(pages.data[key]);
            for (var key1 in pages.data[key]) {
                //console.log( "key:" + key1 + " --- Value:"+ pages.data[key][key1] );
                for (var key2 in pages.data[key][key1]) {
                    //console.log( "key2:" + key2 + " --- Value:"+ pages.data[key][key1][key2] );
                    if (key2 == "active" && pages.data[key][key1][key2] == true && key1 == currPage) {
                        //console.log('active page is...' + key1);
                        currentPage = key1;
                        break;
                    }
                }
            }
        }
    }

    return currentPage;
}

export const evaluateStep = async (props, currentPage, stepType) => {
    let newPage = currentPage;
    switch (currentPage) {
        case mvPatentPages.BASICDETAILS.value:
            newPage = mvPatentPages.BASICDETAILS.value;
            break;
        case mvPatentPages.APPLICANTS.value:
            newPage = mvPatentPages.APPLICANTS.value;
            break;
        case mvPatentPages.INVENTORS.value:
            newPage = mvPatentPages.INVENTORS.value;
            break;
        case mvPatentPages.JURISDICTION.value:
            newPage = mvPatentPages.JURISDICTION.value;
            break;
        case mvPatentPages.REVIEW.value:
            newPage = mvPatentPages.REVIEW.value;
            break;
        default:
            break;
    }
    return newPage;
}

export const getNextStep = async (props, currentPage, _messageContext) => {

    //console.log('-----115-----'+currentPage);
    let validatedCurrentPage = await evaluateStep(props, currentPage, 'next'); //Validates if current page is needed to skip
    let arrayNav = getStepNavigation(props, validatedCurrentPage);
    let nextStep = '';
    //console.log("getNextPage array---" + JSON.stringify(arrayNav));
    for (var i = 0; i < arrayNav.length; i++) {
        if (arrayNav[i].key == 'NextStep') {
            //console.log('Array Nav....' + arrayNav[i].value);
            nextStep = arrayNav[i].value;
            break;
        }
    }

    //console.log('continue to next page...' + JSON.stringify(nextStep));         
    props.changePage2(nextStep, currentPage, props.customer.journeyType);
    try {
        if (getChangedJourneyPage(props, currentPage)) {
            props.updateJourneyTypePage(currentPage, props.customer.journeyType)
        }
    } catch (error) {
        console.log(error);
    }
    let payload = {};
    payload.refreshProgressBar = true;
    //console.log('----131----');
    publish(_messageContext, mvPathChannel, payload);
    //console.log('-----132----');


}

export const getPrevStep = async (props, currentPage, _messageContext) => {

    let validatedCurrentPage = await evaluateStep(props, currentPage, 'prev'); //Validates if current page is needed to skip
    let arrayNav = getStepNavigation(props, validatedCurrentPage);
    let prevStep = '';
    //console.log("getNextPage array---" + JSON.stringify(arrayNav));
    for (var i = 0; i < arrayNav.length; i++) {
        if (arrayNav[i].key == 'PrevStep') {
            //console.log('Array Nav....' + arrayNav[i].value);
            prevStep = arrayNav[i].value;
            break;
        }
    }

    //console.log('continue to prev page...' + JSON.stringify(prevStep));         
    props.changePage2(prevStep, currentPage, props.customer.journeyType);
    try {
        if (getChangedJourneyPage(props, currentPage)) {
            props.updateJourneyTypePage(currentPage, props.customer.journeyType)
        }
    } catch (error) {
        console.log(error);
    }
    let payload = {};
    payload.refreshProgressBar = true;
    publish(_messageContext, mvPathChannel, payload);
}

export const navigateToPage = (props, prevPage, currentPage, _messageContext) => {

    props.changePage2(prevPage, currentPage, props.customer.journeyType);
    let payload = {};
    payload.refreshProgressBar = true;
    console.log('Previous Page: ' + prevPage);
    console.log('Current Page : ' + currentPage);
    console.log('Message Context :  ' + _messageContext);
    publish(_messageContext, mvPathChannel, payload);

}

export const getErrorMessage = async (errorCode, apiName) => {

    try {
        let errorrsp = await getErrorData({ errorCode: errorCode, apiName: apiName });
        return errorrsp;
    }
    catch (error) {
        console.log('error: ', error);
    }

}


//Patent Intake pages
export const mvPatentPages = {
    BASICDETAILS: { value: "Basic Details" },
    APPLICANTS: { value: "Applicants" },
    INVENTORS: { value: "Inventors" },
    JURISDICTION: { value: "Jurisdiction" },
    REVIEW: { value: 'Review' },
}

export const PatentIntakeData = [
    {
        screenName: 'patentIntakeForm',
        sectionName: 'Basic Details',
        isEditable: 'TRUE',
        isValid: 'FALSE',
        isEdited: 'FALSE',
        isDisabled: 'FALSE',
        order: '1',
        isEditing: 'TRUE'
    },
    {
        screenName: 'patentIntakeForm',
        sectionName: 'Applicants',
        isEditable: 'FALSE',
        isValid: 'TRUE',
        isEdited: 'TRUE',
        isDisabled: 'FALSE',
        order: '2',
        isEditing: 'FALSE'
    },
    {
        screenName: 'patentIntakeForm',
        sectionName: 'Inventors',
        isEditable: 'TRUE',
        isValid: 'FALSE',
        isEdited: 'FALSE',
        isDisabled: 'TRUE',
        order: '3',
        isEditing: 'FALSE'
    },
    {
        screenName: 'patentIntakeForm',
        sectionName: 'Jurisdiction',
        isEditable: 'TRUE',
        isValid: 'FALSE',
        isEdited: 'FALSE',
        isDisabled: 'TRUE',
        order: '4',
        isEditing: 'FALSE'
    },
    {
        screenName: 'patentIntakeForm',
        sectionName: 'Review',
        isEditable: 'TRUE',
        isValid: 'FALSE',
        isEdited: 'FALSE',
        isDisabled: 'TRUE',
        order: '5',
        isEditing: 'FALSE'
    },
];