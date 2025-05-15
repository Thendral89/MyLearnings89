import { LightningElement,wire,api,track } from 'lwc';
import getFiles from '@salesforce/apex/CustomChatterUtility.getFiles';

export default class FileUploaderModal extends LightningElement {
    openFileUploader = false;
    activeTab = 'Recent';
    @track _selectedFilesCount = 0;
    @track selectedFiles = [];
    wiredFilesResults;
    @track filesData;
    @api property;
    @track selectedNavItem = 'Recent';
    showUploadFileProgress = false;
    isLoading = false;
    showSpinner = false;
    

    @wire(getFiles)
    wiredFiles(result) {
        this.isLoading = true;
        this.wiredFilesResults = result;
        const { data, error } = result;
        if (data) {
            this.isLoading = false;
            this.filesData = data;
            console.log('filesData', JSON.stringify(this.filesData));
        }
        if (error) {
            this.isLoading = false;
            console.log('error while getting files', error);
        }
    }

    get acceptedFormats(){
        console.log('property',this.property);
        if(this.property === 'Attach File'){
            return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt'];
        }else if(this.property === 'Add Image'){
            return ['.png', '.jpg', '.jpeg'];
        }
    }
    get navItems() {
        return [
            { label: 'Recent', name: 'Recent' },
            { label: 'Owned by Me', name: 'OwnedByMe' },
            { label: 'Shared with Me', name: 'SharedwithMe' },
        ].map(item => ({
            ...item,
            cssClass: `slds-nav-vertical__item${item.name === this.activeTab ? ' slds-is-active' : ''}`
        }));
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    get selectedFilesCount() {
        return this._selectedFilesCount;
    }

    get isInsertButtonDisabled() {
        return this.selectedFilesCount === 0;
    }

    handleSelectionChange(event) {
        const {selectedFiles,selectedCount} = event.detail;
        this._selectedFilesCount = selectedCount;
        this.selectedFiles = selectedFiles;
    }

    handleNavClick(event) {
        this.activeTab = event.currentTarget.dataset.name;
        this.selectedNavItem = this.activeTab;
        console.log('selectedNavItem in parent',this.selectedNavItem);
        
    }

    handleFilesInsert(){
        this.dispatchEvent(new CustomEvent('insert', {
            detail: {
                type: 'Files',
                data: this.selectedFiles,
            }
        }));
        
        this._selectedFilesCount = 0;
        this.selectedFiles = [];
    }
    handleSearchFiles(event){
        const searchKey = event.target.value;
        if(searchKey){
            this.filesData = this.filesData.filter(file => file.Name.toLowerCase().includes(searchKey.toLowerCase()));
        }else{
            this.wiredFiles(this.wiredFilesResults);
        }

    }
    showLoader(){
        this.showSpinner = true;
    }
    
}