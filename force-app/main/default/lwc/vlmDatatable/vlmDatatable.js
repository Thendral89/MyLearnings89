import { LightningElement } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import vlmDatatable from './vlmDatatable.html';

export default class BsDatatable extends LightningDatatable {
    static customTypes = {
        clickableDeleteIcon: {
            template: vlmDatatable,
            standardCellLayout: true,
            typeAttributes: ['contentDocumentId', 'sourceType'],
        }
        // Other types here
    }

    handleOnselectedcommitteeidtypeattribute(event){
        try{
            console.log('Reaching Two');
            let committeeId = event.detail.committeeId;
        }
        catch(err){
            alert("JS Error :: committeeTargetTracking :: handleOnselectedcommitteeid");
            console.error(err);
        }
    }
}