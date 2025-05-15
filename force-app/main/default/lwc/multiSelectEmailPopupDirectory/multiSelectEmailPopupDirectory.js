import { LightningElement, track, api, wire } from 'lwc';
import getQuickAddMatterEngagementModels from '@salesforce/apex/mvEmailComposerController.getQuickAddMatterEngagementModels';
import searchPersons from '@salesforce/apex/PersonSearchController.searchPersons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MultiSelectEmailPopupDirectory extends LightningElement {
    @api label;
    @api placeholder = 'Enter email or search records';
    @track inputValue = '';
    @track selectedEmails = [];
    @track filteredRecords = [];
    @track showDropdown = false;
    @track noResults = false;
    @track quickAddRecords = [];
    @track selectedEmailsByType = [];
    @track activeIndex = -1;
    @api recordId;
    alreadyAddedPersonsToExclude = [];
    @track selectedType = 'To';
    typeOptions = [
        { label: 'To', value: 'To' },
        { label: 'CC', value: 'CC' },
        { label: 'BCC', value: 'BCC' },
    ];

    @track addedEmails = new Set();

    async connectedCallback() {
        // this.fetchRelatedEmails();
        // this.getrelatedLawFirmEmails();
        await this.fetchQuickAddEmails();
        this.handleClickOutside = this.handleClickOutside.bind(this);
        this.template.addEventListener('mousedown', this.handleClickOutside);
    }

    handleClickOutside(event) {
        const searchContainer = this.template.querySelector('.search-container');
        const dropdown = this.template.querySelector('.enhanced-dropdown');
        const inputElement = this.template.querySelector('.search-bar'); 
        console.log('OUTPUT : searchContainer',JSON.stringify(searchContainer));
        console.log('OUTPUT : dropdown',JSON.stringify(dropdown));
        console.log('OUTPUT : dropdown',JSON.stringify(inputElement));

        // If the click is outside both the search container and the dropdown, hide the dropdown and clear input
        if (
            searchContainer && !searchContainer.contains(event.target) &&
            dropdown && !dropdown.contains(event.target)
        ) {
            console.log('OUTPUT : inside');
            if(inputElement != undefined){
                inputElement.value = '';
            }
            
            this.inputValue = '';  // Clear the search input
            this.showDropdown = false;  // Hide the dropdown
        }
    }

    disconnectedCallback() {
        this.template.removeEventListener('mousedown', this.handleClickOutside);
    }

    async fetchQuickAddEmails() {
        try {
            console.log('Fetching quick add emails for recordId:', this.recordId);
            
            const quickAddList = await getQuickAddMatterEngagementModels({ recordId: this.recordId });
            const relatedEmails = quickAddList.map(record => ({
                name: record.Label,
                email: record.Email,
                emailOf: record.EmailOf,
                initials: this.getInitials(record.Label),
                isDisabled: this.addedEmails.has(record.Email)
            }));

            this.quickAddRecords = [...relatedEmails];

            console.log('Quick Add Records:', JSON.stringify(this.quickAddRecords));

        } catch (error) {
            console.error('Error fetching quick add emails:', error);
        }
    }

    /* async fetchQuickAddEmails() {
        try {
            console.log('this.recordId:', this.recordId);
            const [relatedEmailsResponse, lawFirmEmailsResponse] = await Promise.all([
                getRelatedEmailsForDirectory({ recordId: this.recordId }),
                getRelatedLawFirmForDirectory({ recordId: this.recordId })
            ]);
    
            const relatedEmails = relatedEmailsResponse.map(record => ({
                name: record.Label,
                email: record.Email,
                emailOf: record.EmailOf,
                initials: this.getInitials(record.Label),
                isDisabled: this.addedEmails.has(record.Email)
            }));
    
            const lawFirmEmails = lawFirmEmailsResponse.map(record => ({
                name: record.Label,
                email: record.Email,
                emailOf: record.EmailOf,
                initials: this.getInitials(record.Label),
                isDisabled: this.addedEmails.has(record.Email)
            }));
    
            this.quickAddRecords = [...relatedEmails, ...lawFirmEmails];
    
            console.log('this.quickAddRecords =>', JSON.stringify(this.quickAddRecords));
    
        } catch (error) {
            this.error = error;
            console.error('Error fetching emails:', error);
        }
    } */
    
    getInitials(name) {
        if (!name) return '';
        const parts = name.split(' ');
        return parts.map(part => part.charAt(0).toUpperCase()).join('');
    }

    async handleInputChange(event) {
        const searchText = event.target.value;
        this.inputValue = searchText;
        console.log('searchText=>', searchText);
        if (searchText) {
            await this.fetchEmails(searchText);
        }else if (searchText.length === 0) {
            this.filteredRecords = [];
            this.noResults = false;
            this.showDropdown = false;
        } else {
            this.showDropdown = false;
        }

        this.noResults = this.filteredRecords.length === 0;
        this.showDropdown = true;
    }

    showDropdownOnFocus() {
        try{
            this.noResults = false;
        this.showDropdown = true;
        }catch(err){
            console.log('err msg' + err.message);
            
        }
        
    }

   

    async fetchEmails(searchText) {
        try {
            //let clientId1 = this.userClientId;
            console.log('this.alreadyAddedPersonsToExclude in fetchEmails=>', JSON.stringify(this.alreadyAddedPersonsToExclude));
            this.filteredRecords = [];
            const typeSpecificExclusions = this.alreadyAddedPersonsToExclude
            .filter(item => item.selectedType === this.selectedType)
            .map(item => item.id);
            console.log('typeSpecificExclusions:', JSON.stringify(typeSpecificExclusions));
            const params = {
                searchWord: searchText,
                personRecordsInConsideration: this.toAddresses || []
            };
            let results = await searchPersons({ inputParameters: JSON.stringify(params) });
            //console.log('results lawfirm emails=>', JSON.stringify(results));
            console.log('this.selectedType=>', this.selectedType);
            console.log('Selected Emails By Type in fetchEmails:', JSON.stringify(this.selectedEmailsByType));
            const selectedEmails = this.selectedEmailsByType
            .find(type => type.type === this.selectedType)?.emails || [];
            
            console.log('selectedEmails=>', JSON.stringify(selectedEmails));
            this.filteredRecords = results.map((record) => {
                return {
                    id: person.name,
                    label: person.label,
                    email: person.email,
                    src: person.src || 'standard:user',  // Icon fallback
                    fallbackIconName: person.fallbackIconName || 'standard:user',
                    recordId: record.Id,
                    selected: selectedEmails.includes(record.Email)
                };
            });
            
            this.filteredRecords = [...this.filteredRecords];
            console.log('this.filteredRecords=> after ', JSON.stringify(this.filteredRecords));
            // this.noResults = this.filteredRecords.length === 0;
            // console.log('this.noResults :', this.noResults );
            // this.showDropdown = this.filteredRecords.length > 0;
            // if(this.showDropdown){
            //     this.updateActiveClasses();
            // }
        } catch (error) {
            console.error('Error fetching emails:', error);
        }
    }

    handleKeyDown(event) {
        try{
            const dropdownList = this.template.querySelector('.enhanced-dropdown ul');
            if (event.key === 'ArrowDown') {
                this.activeIndex = Math.min(this.filteredRecords.length - 1, this.activeIndex + 1);
                this.scrollToActive(dropdownList);
            } else if (event.key === 'ArrowUp') {
                this.activeIndex = Math.max(0, this.activeIndex - 1);
                this.scrollToActive(dropdownList);
            } else if (event.key === 'Enter' && this.activeIndex > -1) {
                this.handleSelect({
                    currentTarget: {
                        dataset: {
                            id: this.filteredRecords[this.activeIndex].email,
                            recordId: this.filteredRecords[this.activeIndex].recordId
                        }
                    }
                });
            }
            console.log('OUTPUT : activeindex ',this.activeIndex);
            this.updateActiveClasses();
        }catch(err){
            console.log('err ms ' + err.message);
            
        }
        
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
            computedClass: `slds-listbox__item dropdown__item ${
                index === this.activeIndex ? 'active' : ''
            }`,
        }));
    }

    handleSelect(event) {
        const email = event.currentTarget.dataset.id;
        const id = event.currentTarget.dataset.recordId;
        console.log('Selected Record ID:', id);
        const selectedType = this.selectedType;

        if (id) {
            this.selectedLawFirmMails = this.selectedLawFirmMails || [];
            this.selectedLawFirmMails.push({ id, email, selectedType }); 
            this.selectedLawFirmMails = [...new Set(this.selectedLawFirmMails.map(JSON.stringify))].map(JSON.parse);
            this.alreadyAddedPersonsToExclude.push({ id, selectedType });
            this.alreadyAddedPersonsToExclude = [
                ...new Set(this.alreadyAddedPersonsToExclude.map(item => JSON.stringify(item)))
            ].map(JSON.parse);

            this.filteredRecords = this.filteredRecords.map(record => ({
                ...record,
                selected: record.email === email || record.selected
            }));   

            console.log('this.selectedLawFirmMails=>>>>>>', JSON.stringify(this.selectedLawFirmMails));
            console.log('this.alreadyAddedPersonsToExclude=>>>>>>', JSON.stringify(this.alreadyAddedPersonsToExclude));
            

        }
        console.log('this.selectedLawFirmMails=>', JSON.stringify(this.selectedLawFirmMails));
        
        this.addEmailToGroup(email);

        console.log('alreadyAddedPersonsToExclude in handleSelect:', JSON.stringify(this.alreadyAddedPersonsToExclude));
        // this.inputValue = '';
        // this.showDropdown = false;
    }

    handleQuickAdd(event) {
        const email = event.currentTarget.dataset.id;
        console.log('email=>', email);
        this.addEmailToGroup(email);
    }

    addEmailToGroup(email) {
        console.log('email::',email);
        let group = this.selectedEmailsByType.find(group => group.type === this.selectedType);
        if (!group) {
            group = { type: this.selectedType, emails: [] };
            this.selectedEmailsByType.push(group);
            console.log('this.selectedEmailsByType in addemailtogroup->', JSON.stringify(this.selectedEmailsByType));
        }
        if (!group.emails.includes(email)) {
            group.emails.push(email);
            this.addedEmails.add(email); // Mark email as added
            this.updateQuickAddRecords();
            console.log('this.addedEmails in addEmailToGroup in if=>', JSON.stringify(this.addedEmails));
            console.log('this.selectedEmailsByType in addemailtogroup->>>>>', JSON.stringify(this.selectedEmailsByType));
        }
        console.log('this.addedEmails in addEmailToGroup=>', JSON.stringify(this.addedEmails)); // Properly log the Set
    }

    handleRemove(event) {
        const emailToRemove = event.currentTarget.dataset.email;
        const selectedTypeToRemove = event.currentTarget.dataset.type;
        console.log('emailToRemove=>', emailToRemove);
        console.log('selectedTypeToRemove=>', selectedTypeToRemove);
        this.addedEmails.delete(emailToRemove);
        this.updateQuickAddRecords();
        this.selectedEmailsByType.forEach(group => {
            if (group.type === selectedTypeToRemove) {
                group.emails = group.emails.filter(email => email !== emailToRemove);
            }
        });
        this.selectedEmailsByType = this.selectedEmailsByType.filter(group => group.emails.length > 0);
        const idsToRemove = this.selectedLawFirmMails
        .filter(item => item.email === emailToRemove && item.selectedType === selectedTypeToRemove)
        .map(item => item.id);

        console.log('idsToRemove:', JSON.stringify(idsToRemove));
        // Remove the email entry from alreadyAddedPersonsToExclude based on email and selectedTypeToRemove
        this.alreadyAddedPersonsToExclude = this.alreadyAddedPersonsToExclude.filter(
            item => !(idsToRemove.includes(item.id) && item.selectedType === selectedTypeToRemove)
        );

        this.selectedLawFirmMails = this.selectedLawFirmMails.filter(
            item => !(item.email === emailToRemove && item.selectedType === selectedTypeToRemove)
        );
        this.filteredRecords = this.filteredRecords.map(record => {
            const shouldSelect = idsToRemove.includes(record.recordId); 
            return {
                ...record,
                selected: shouldSelect ? false : record.selected 
            };
        });
        console.log('Updated selectedLawFirmMails:', JSON.stringify(this.selectedLawFirmMails));
        console.log('Updated alreadyAddedPersonsToExclude:', JSON.stringify(this.alreadyAddedPersonsToExclude));

        console.log('this.addedEmails in remove:', JSON.stringify(this.addedEmails));
        
    }

    updateQuickAddRecords() {
        this.quickAddRecords = [...this.quickAddRecords.map(record => ({
            ...record,
            isDisabled: this.addedEmails.has(record.email) 
        }))];
        console.log('Updated quickAddRecords:', JSON.stringify(this.quickAddRecords));
    }

    handleEmailTypeChange(event) {
        this.selectedType = event.detail.value;
        this.inputValue = '';
        this.showDropdown = false;
        this.filteredRecords=[];
    }

    get isDoneDisabled() {
        console.log('this.selectedEmailsByType.length::', this.selectedEmailsByType.length);
        return this.selectedEmailsByType.length === 0;
    }

    handleDone() {
        console.log('Selected Emails By Type:', JSON.stringify(this.selectedEmailsByType));
        this.dispatchEvent(new CustomEvent('emailselected', {
            detail: this.selectedEmailsByType
        }));
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Emails added',
                variant: 'success',
            })
        );
    }

    closePopup() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }
}