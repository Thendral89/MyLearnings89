import LightningDatatable from 'lightning/datatable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import multiButtonUI from './multiButtonUI.html';
import checkbox from './checkbox.html';
import richTextArea from './richTextArea.html';
import richTextAreaEdit from './richTextAreaEdit.html';
import imageControl from './imageControl.html';
import DatatablePicklistTemplate from './picklistTemplate.html';
import DatatableLookupTemplate from "./lookupTemplate.html";
import filePreview from './filePreview.html'
import pill from './pill.html';

export default class MyTypes extends LightningDatatable {
    static customTypes = {
        multiButtonAction: {
            template: multiButtonUI,
            standardCellLayout: true,
            typeAttributes: ['buttons'],
        },
        richTextArea: {
            template: richTextAreaEdit,
            editTemplate: richTextAreaEdit,
            standardCellLayout: true,
            typeAttributes: ['image','name']
        },
        richTextAreaView: {
            template: richTextArea,
            editTemplate: richTextArea,
            standardCellLayout: true
        },
        image: {
            template: imageControl, 
            standardCellLayout: true,
            typeAttributes: ['name','show']
        },
        checkbox: {
            template: checkbox, 
            standardCellLayout: true,
            typeAttributes: ['label','variant','checked','disabled','rowKey','fieldName','keyField']
        },
        pill:{
            template: pill, 
            standardCellLayout: true,
            typeAttributes: ['className','visible','name']
        },
        filePreview: {
            template: filePreview, 
            standardCellLayout: true,
            typeAttributes: ['show']
        },
        picklist: {
            template: DatatablePicklistTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name','disabled']
        },
        lookup: {
            template: DatatableLookupTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'fieldName', 'object', 'context', 'variant', 'name', 'fields', 'target','disabled']
        }
    } 
}