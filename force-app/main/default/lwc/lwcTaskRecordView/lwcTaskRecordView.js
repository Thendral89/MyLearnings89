import { LightningElement, api, track } from 'lwc';
import getTaskById from '@salesforce/apex/TaskFormHelper.getTaskById';
import { NavigationMixin } from 'lightning/navigation';

export default class LwcTaskRecordView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track taskData;
    @track relatedFiles = [];
    @track isLoading = true;

    // connectedCallback() {
    //     this.fetchTaskData();
    // }

    @api updateRecordId(value) {
        console.log('Called task updateRecordId with value: ' + value + ' and recordId: ' + this.recordId + '\n');
        this.recordId = value;
        this.fetchTaskData();
    }
    assignedToName;
    fetchTaskData() {
        if (!this.recordId) {
            this.isLoading = false;
            return;
        }
        console.log('Called task fetchTaskData: ' + this.recordId);
        this.isLoading = true;
        getTaskById({ taskId: this.recordId })
            .then((result) => {
                console.log('Called task result: ' + JSON.stringify(result));
                if (result) {
                    this.taskData = result.task;
                    this.assignedToName = result.task.OwnerId ? result.task.Owner.Name : null;
                    console.log('Called task relatedFiles: ' + JSON.stringify(this.taskData));
                    this.relatedFiles = Array.isArray(result.files) ? result.files : [];
                }
            })
            .catch((error) => {
                console.error('Error fetching task data:', error);
                this.taskData = null;
                this.relatedFiles = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    get hasRelatedFiles() {
        return this.relatedFiles.length > 0;
    }

    get formattedDate() {
        if (this.taskData && this.taskData.CreatedDate) {
            const options = { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
            return new Date(this.taskData.CreatedDate).toLocaleDateString('en-US', options);
        }
        return '';
    }
    get formattedActivityDate() {
        if (this.taskData && this.taskData.ActivityDate) {
            const options = { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
            return new Date(this.taskData.ActivityDate).toLocaleDateString('en-US', options);
        }
        return '';
    }

    previewHandler(event) {
        const fileId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: fileId
            }
        });
    }

    downloadHandler(event) {
        const fileId = event.target.dataset.id;
        // Logic to download file by fileId
    }
}