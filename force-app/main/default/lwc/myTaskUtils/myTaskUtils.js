import getTaskDataApex from '@salesforce/apex/MyTaskController.getTaskData';
import getViewsDataApex from '@salesforce/apex/MyTaskController.getViewsData';
import getAdditionalFieldsLabelApex from '@salesforce/apex/MyTaskController.getAdditionalFieldsLabel';
import saveTaskDataApex from '@salesforce/apex/MyTaskController.saveTaskData';
import getPopoverDataApex from '@salesforce/apex/MyTaskController.getPopoverData';
import getTaskFieldsDataApex from '@salesforce/apex/MyTaskController.getTaskFieldsData';
import getPanelInfoApex from '@salesforce/apex/MyTaskController.getPanelInfo';
import deleteTaskRecordsApex from '@salesforce/apex/MyTaskController.deleteTaskRecords';

export {
    getTaskDataApex, 
    getViewsDataApex, 
    getAdditionalFieldsLabelApex,
    saveTaskDataApex,
    getPopoverDataApex,
    getTaskFieldsDataApex,
    getPanelInfoApex,
    deleteTaskRecordsApex
}