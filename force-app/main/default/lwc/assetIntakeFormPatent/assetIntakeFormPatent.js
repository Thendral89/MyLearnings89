import { LightningElement, track, api, wire } from "lwc";
import {
    getRecordCreateDefaults,
    generateRecordInputForCreate,
    createRecord,
    updateRecord,
    deleteRecord,
    getRecord,
    getRecords,
    getFieldValue 
} from "lightning/uiRecordApi";

import { CurrentPageReference } from 'lightning/navigation';

import {
    closeTab,
    IsConsoleNavigation,
    EnclosingTabId,
    getFocusedTabInfo,
    setTabLabel,
    openTab,
    openSubtab,
    getTabInfo
} from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';

/* Import Objects and Fields */
import GENERAL_MATTER_OBJECT from "@salesforce/schema/SymphonyLF__General_Matter__c";
import CLIENT_OBJECT from "@salesforce/schema/SymphonyLF__Client__c";
import CONFLICT_CHECK_OBJECT from "@salesforce/schema/Conflict_Check__c";

import CLIENT_JURISDICTION_FIELD from "@salesforce/schema/SymphonyLF__Client__c.Jurisdiction__c";
import CREDIT_STATUS from "@salesforce/schema/SymphonyLF__Client__c.Credit_Status__c";

import CC_CLIENT_REFERENCE_NUMBER from "@salesforce/schema/Conflict_Check__c.Client_Reference_Number__c";
import MATTER_NAME from "@salesforce/schema/Conflict_Check__c.Matter_Name__c";

/* Import the Static Resources for Tabulator and FA Open source libraries*/
import MAXVALTABLECSS from "@salesforce/resourceUrl/MAXVALTABLECSS";
import MAXVALTABLEJS from "@salesforce/resourceUrl/MAXVALTABLEJS";
import FA from "@salesforce/resourceUrl/FA";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";

/* Import Toast Events*/
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Import Apex Classes*/
import getClientEngagementModels from '@salesforce/apex/assetIntakeUtilities.getClientEngagementModelsNoIntakeId';
import submissionGeneralMatter from '@salesforce/apex/assetIntakeUtilities.submissionGeneralMatter';

/* This scoped module imports the current user profile name and User Id */
import profileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';

const PAGINATOR_DEFAULT_SIZE = 25;
const PAGINATOR_SIZE_SELECTOR = [10, 25, 50, 100, 500];
const TABULATOR_BUTTON_ID_PREFIX = 'myButton';

const PERSON_RECORD_TYPE_INTERNAL = 'Internal';
const PERSON_RECORD_TYPE_EXTERNAL = 'External';

export default class AssetIntakeFormPatent extends LightningElement {

}