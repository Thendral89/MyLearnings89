import { LightningElement, api, track } from 'lwc';

export default class FilesDataComponent extends LightningElement {

    @track isSelected = false;
    @track showTooltip = false;
    @track processedFiles = [];
    @track selectedFilesCount = 0;
    _property;
    _selectedNavItem = 'Recent';
    originalFiles;
   
    connectedCallback(){
        console.log('filesDataComponent connectedCallback'+JSON.stringify(this.processedFiles));
    }

    @api
    get filesData() {
        console.log('filesData getter' + JSON.stringify(this.processedFiles));
        return this.processedFiles;
    }
    
    set filesData(value) {
        if (value) {
            // Store the original unfiltered files
            this.originalFiles = value;
            this.updateProcessedFiles();
        }
    }

    @api
    get property() {
        return this._property;
    }
    
    set property(value) {
        this._property = value;
        this.updateProcessedFiles();
    }
    
    @api
    get selectedNavItem(){
        console.log('Getting selectedNavItem:', this._selectedNavItem);
        return this._selectedNavItem;
    }
    
    set selectedNavItem(value){
        console.log('Setter value:', value);
        this._selectedNavItem = value;
        console.log('After setting, _selectedNavItem:', this._selectedNavItem);
        this.updateProcessedFiles();
    }
  
    updateProcessedFiles() {
        if (this.originalFiles) {
            // First, filter based on property (image or all files)
            let filteredFiles = this.originalFiles.filter(file => 
                this.property === 'Attach File' || 
                (this.property === 'Add Image' && 
                 ['PNG', 'JPEG', 'JPG'].includes(file.FileType.toUpperCase()))
            );
    
            // Sort files in descending order by date
            filteredFiles.sort((a, b) => {
                const dateA = new Date(a.Date);
                const dateB = new Date(b.Date);
                return dateB.getTime() - dateA.getTime();
            });
            
            if (this.selectedNavItem === 'Recent') {
                filteredFiles = filteredFiles.slice(0, 5);
            }
            
            this.processedFiles = filteredFiles.map(file => ({
                ...file,
                selected: false,
                buttonIconName: 'utility:add',
                buttonIconVariant: 'border-filled'
            }));
        }
    }
    
    handleCheckboxChange(event) {
        const fileId = event.currentTarget.dataset.id;
        
        this.processedFiles = this.processedFiles.map(file => {
            if (file.Id === fileId) {
                const newSelected = !file.selected;
                return {
                    ...file,
                    selected: newSelected,
                    buttonIconName: newSelected ? 'utility:check' : 'utility:add',
                    buttonIconVariant: newSelected ? 'brand' : 'border-filled'
                };
            }
            return file;
        });

        // Update the count of selected files
        // Update count and notify parent
        this.selectedFilesCount = this.processedFiles.filter(file => file.selected).length;
        console.log('selectedFilesCount: ' + this.selectedFilesCount);
        
        this.dispatchEvent(new CustomEvent('selectionchange', {
            detail: {
                selectedFiles: this.processedFiles.filter(file => file.selected),
                selectedCount: this.selectedFilesCount
            }
        }));
    }
}