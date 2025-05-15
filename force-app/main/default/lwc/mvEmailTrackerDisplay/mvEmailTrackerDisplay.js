import { api, LightningElement, track} from 'lwc';
import getEmailTrackersByEmailMessageId from '@salesforce/apex/mvCollaborationService.getEmailTrackersByEmailMessageId';
import { NavigationMixin } from 'lightning/navigation';

export default class MvEmailTrackerDisplay extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track _emailTrackerList = [];
    @track showSpinner = false;
    @track hasTrackers = false;

    @track statusOptions = [];

    connectedCallback() {
        this.fetchEmailTrackers();
    }

    fetchEmailTrackers() {
        this.showSpinner = true;
        getEmailTrackersByEmailMessageId({ emailMessageId: this.recordId })
            .then((result) => {
                console.log('emailMessageId',this.recordId);
                this._emailTrackerList = result.map((tracker) => {
                    let relatedName = '';
                    if (tracker.Patent__r) {
                        relatedName = tracker.Patent__r.Name;
                    } else if (tracker.SymphonyLF__Client__r) {
                        relatedName = tracker.SymphonyLF__Client__r.Name;
                    } else if (tracker.SymphonyLF__Collection__r) {
                        relatedName = tracker.SymphonyLF__Collection__r.Name;
                    }
    
                    return {
                        ...tracker,
                        relatedName,
                    };
                });
                this.hasTrackers = this._emailTrackerList.length > 0;
            })
            .catch((error) => {
                console.error('Error fetching Email Trackers:', error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
    get formattedEmailTrackerList() {
        return this._emailTrackerList.map(tracker => ({
            ...tracker,
            formattedCreatedDate: tracker.CreatedDate 
                ? this.formatDateTime(tracker.CreatedDate) 
                : ''
        }));
    }
    formatDateTime(dateString) {
        if (!dateString) return '';
    
        const dateObj = new Date(dateString);
        const options = { 
            year: 'numeric', 
            month: 'short', 
            day: 'numeric', 
            hour: '2-digit', 
            minute: '2-digit'
        };
    
        console.log('dateObj.toLocaleString:', dateObj.toLocaleString('en-US', options));
        return dateObj.toLocaleString('en-US', options);
    }

    handleNavigateToTrackerDetail(event) {
        const recordId = event.currentTarget.dataset.recordId;
        if (recordId) {
            const recordPageUrl = `/lightning/r/Record/${recordId}/view`;
            window.open(recordPageUrl, '_blank');
        }
    }

    handleRecordClick(event) {
        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'SymphonyLF__Email_Tracker__c', 
                actionName: 'edit'
            }
        });
    }

    handleNavigateToAssetId(event) {
        const assetId = event.currentTarget.dataset.recordId;
        if (assetId) {
            const recordPageUrl = `/lightning/r/Record/${assetId}/view`;
    
            window.open(recordPageUrl, '_blank');
        }
    }
}