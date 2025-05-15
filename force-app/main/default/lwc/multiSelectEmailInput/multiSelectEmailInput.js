import { LightningElement, api, track } from 'lwc';
import searchPersons from '@salesforce/apex/PersonSearchController.searchPersons';

export default class MultiSelectEmailInput extends LightningElement {
    @api label;
    @api placeholder = 'Enter email or search records';
    @track inputValue = '';
    @track selectedEmails = [];
    @track filteredRecords = [];
    @track showDropdown = false;
    @track noResults = false;
    @track recentEmails = [];
    @track activeIndex = -1;

    @track records = []; 

    @track recentEmailRecords = [
    ];

    @api
    set value(value) {
        this.selectedEmails = Array.isArray(value) ? value : [];
    }
    get value() {
        return this.selectedEmails;
    }

    connectedCallback() {
        this.fetchPersons();
        document.addEventListener('click', this.handleDocumentClick);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleDocumentClick);
    }

    handleDocumentClick = (evt) => {
        if (!this.template.contains(evt.target)) {
            this.showDropdown = false;
        }
    };

    async handleInputChange(event) {
        const searchTerm = event.target.value;
        this.inputValue = searchTerm;
    
        if (!searchTerm) {
            this.filteredRecords = [...this.filteredRecords];
        } else {
            await this.fetchPersons(searchTerm);
        }
    
        this.noResults = this.filteredRecords.length === 0;
        this.showDropdown = true;
    }

    handleSelect(event) {
        const recordId = event.currentTarget.dataset.id;
        const selectedRecord = this.filteredRecords.find((rec) => rec.id === recordId);
    
        if (selectedRecord && !this.selectedEmails.includes(selectedRecord.label)) {
            this.selectedEmails = [...this.selectedEmails, selectedRecord.email];
        }
    
        this.inputValue = '';
        this.showDropdown = false;
        this.dispatchValueChange();
    }

    handleRemove(event) {
        const emailToRemove = event.target.label;
        this.selectedEmails = this.selectedEmails.filter((email) => email !== emailToRemove);
        this.dispatchValueChange();
    }

    handleKeyPress(event) {
        if (event.key === 'Enter' && this.isValidEmail(this.inputValue)) {
            this.selectedEmails = [...this.selectedEmails, this.inputValue];
            this.inputValue = '';
            this.showDropdown = false;
            this.dispatchValueChange();
        }
    }

    handleKeyDown(event) {
        const dropdownList = this.template.querySelector('.enhanced-dropdown ul');
        if (event.key === 'ArrowDown') {
            this.activeIndex = Math.min(this.filteredRecords.length - 1, this.activeIndex + 1);
            this.scrollToActive(dropdownList);
        } else if (event.key === 'ArrowUp') {
            this.activeIndex = Math.max(0, this.activeIndex - 1);
            this.scrollToActive(dropdownList);
        } else if (event.key === 'Backspace' && !this.inputValue && this.selectedEmails.length > 0) {
            this.selectedEmails.pop();
            this.dispatchValueChange();
            event.preventDefault(); // prevent any further action
        } else if (event.key === 'Enter' && this.activeIndex > -1) {
            this.handleSelect({ currentTarget: { dataset: { id: this.filteredRecords[this.activeIndex].id } } });
        }
        this.updateActiveClasses();
    }
    
    scrollToActive(dropdownList) {
        const activeElement = dropdownList.querySelector(`[data-index="${this.activeIndex}"]`);
        if (activeElement) {
            activeElement.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
        }
    }
    
    updateActiveClasses() {
        this.filteredRecords = this.filteredRecords.map((record, index) => ({
            ...record,
            computedClass: `slds-listbox__item enhanced-listbox__item ${
                index === this.activeIndex ? 'active' : ''
            }`,
        }));
    }
    
    renderedCallback() {
        this.adjustDropdownWidth();
    }
    
    adjustDropdownWidth() {
        const input = this.template.querySelector('.email-input');
        const dropdown = this.template.querySelector('.enhanced-dropdown');
        if (input && dropdown) {
            dropdown.style.width = `${input.offsetWidth}px`; // Set dropdown width to match input width
            dropdown.style.left = `${input.offsetLeft}px`; // Adjust left position to start at input
        }
    }

    handleBlur() {
        if (this.isValidEmail(this.inputValue)) {
            this.selectedEmails = [...this.selectedEmails, this.inputValue];
            this.inputValue = '';
        }
        this.showDropdown = false;
    }

    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    dispatchValueChange() {
        const valueChangeEvent = new CustomEvent('valuechange', {
            detail: { selectedEmails: this.selectedEmails },
        });
        this.dispatchEvent(valueChangeEvent);
    }

    // Triggered when the user clicks on the search field
    searchField() {
        if (this.inputValue.length === 0) {
            this.filteredRecords = [...this.filteredRecords];
            this.showDropdown = true;
        }
    }

    async fetchPersons(searchTerm) {
            const params = {
                searchWord: searchTerm,
                personRecordsInConsideration: this.toAddresses || []
            };
        
            console.log('Fetching persons with params:', JSON.stringify(params));
        
            let result = await searchPersons({ inputParameters: JSON.stringify(params) })
                    console.log('Persons fetched successfully:', JSON.stringify(result));
        
                    if (result.length === 0) {
                        console.warn('No persons found for the given search criteria.');
                    }
        
                    // Update records and recent records
                    let personRecords = result.map(person => ({
                        id: person.name,
                        label: person.label,
                        email: person.email,
                        src: person.src || 'standard:user',  // Icon fallback
                        fallbackIconName: person.fallbackIconName || 'standard:user'
                    }));
                    //this.recentEmailRecords = personRecords; // Update recentEmailRecords
                    this.filteredRecords = personRecords;
        }
}