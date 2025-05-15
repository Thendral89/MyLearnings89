import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord,refreshApex } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import sendAnEmailMsg from '@salesforce/apex/mvEmailComposerController.sendAnEmailMsg';
import notifyReviewer from '@salesforce/apex/mvEmailComposerController.notifyReviewer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import hasLegalAssistantPermission from '@salesforce/customPermission/DocketReportExternal_LegalAssistant';
import hasAttorneyOrParalegalPermission from '@salesforce/customPermission/DocketReportExternal_AttorneyOrParalegal';

const FIELDS = [
    'Docket_Report_External__c.From_Address__c',
    'Docket_Report_External__c.To_Address__c',
    'Docket_Report_External__c.CC_Address__c',
    'Docket_Report_External__c.BCC_Address__c',
    'Docket_Report_External__c.Subject__c',
    'Docket_Report_External__c.Email_Content__c',
    'Docket_Report_External__c.Status__c',
    'Docket_Report_External__c.Attorney_Comments__c',
    'Docket_Report_External__c.Name',
    'Docket_Report_External__c.CreatedBy.Email',
    'Docket_Report_External__c.Docketing_Activity__c'
    
  ];
  


export default class DocketReportReview extends LightningElement {
    @api recordId;
    @track comments = '';
    @track showComment = false;
    attachmentIds = [];

    wiredRecordResult;
    record;

    @track showCommentModal = false;

  
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord(result) {
      console.log('recordId->', this.recordId);
        this.wiredRecordResult = result;
        console.log('this.wiredRecordResult:', JSON.stringify(result));
        if (result.data) {
            this.record = result.data;
        }
    }
  
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'ContentDocumentLinks',
        fields: ['ContentDocumentLink.ContentDocumentId']
      }
        
    )
    wiredAttachments({ error, data }) {
      if (data) {
        this.attachmentIds = data.records.map(r => r.fields.ContentDocumentId.value);
      }
    }
  
    get isAttorneyOrParalegal() {
        return hasAttorneyOrParalegalPermission;
    }

    get isLegalAssistant() {
        return hasLegalAssistantPermission;
    }

    get isInitiated() {
        return !(this.record?.fields.Status__c.value === 'Initiated');
    }

    get isRequestedChanges() {
        return !(this.record?.fields.Status__c.value === 'Requested Changes');
    }

  

    handleReviewed() {
        const fields = {
          Id: this.recordId,
          Status__c: 'Reviewed'
        };
        updateRecord({ fields })
          .then(() => this._sendEmail())
          .then(() =>
            this._updateActivityReported('Reported to Client')
          )
          .then(() => {
            this._showToast('Success', 'Marked Reviewed & Email sent', 'success');
          })
          .catch(err => {
            this._showToast('Error', err.body?.message || err.message, 'error');
          });
    }
  
    _sendEmail() {
        const f = this.record.fields;
        console.log('all field:', JSON.stringify(f));
        const activityId = this.record.fields.Docketing_Activity__c.value;
        
        const params = {
            fromAddress:        f.From_Address__c.value,
            toAddressesStr:     f.To_Address__c.value,
            ccAddressesStr:     f.CC_Address__c.value || '',
            bccAddressesStr:    f.BCC_Address__c.value || '',
            subject:            f.Subject__c.value,
            whatId:             activityId,         
            body:               f.Email_Content__c.value,
            contentDocumentIds: this.attachmentIds,
          };

        console.log('emailPayload=>', JSON.stringify(params));
        return sendAnEmailMsg( params )
            .then(result => {
                console.log('sendAnEmailMsg succeeded, returned:', result);
                return result;
            })
            .catch(error => {
                console.error(' sendAnEmailMsg failed:', JSON.stringify(error));
            });
            
    }

    handleRequestedChanges() {
        console.log(' handleRequestedChanges invoked');
        const fields = {
            Id: this.recordId,
            Status__c: 'Requested Changes'
          };
          updateRecord({ fields })
            .then(() =>
              notifyReviewer({
                docketReportId: this.recordId,
                templateName:   'Docket Report Review Request Changes'
              })
            )
            .then(() => {
              this._showToast('Success', 'Requested Changes & Notification sent', 'success');
            })
            .catch(err => this._showToast('Error', err.body?.message || err.message, 'error'));
        
       
    }

    handleSubmitForReview() {
        const fields = {
          Id: this.recordId,
          Status__c: 'Initiated'
        };
        updateRecord({ fields })
          .then(() =>
            notifyReviewer({
              docketReportId: this.recordId,
              templateName:   'Docket Report Review Request'
            })
          )
        //   .then(() =>
        //     this._updateActivityReported('Submitted for Attorney Review')
        //   )
          .then(() => {
            this._showToast('Success', 'Submitted for review & Email sent', 'success');
          })
          .catch(err => this._showToast('Error', err.body?.message || err.message, 'error'));
    }

    handleCommentSubmit(event) {
        event.preventDefault();
        const fields = { ...event.detail.fields };
        fields.Status__c = 'Requested Changes';
        this.template
          .querySelector('lightning-record-edit-form')
          .submit(fields);
    }
    

    handleCommentSuccess() {
        this.showCommentModal = false;
        notifyReviewer({
          docketReportId: this.recordId,
          templateName: 'Docket Report Review Request Changes'
        })
        // .then(() =>
        //     this._updateActivityReported('Requested Changes by Attorney')
        //   )
          .then(() => {
            this._showToast('Success', 'Requested Changes submitted', 'success');
          })
          .catch(err => {
            this._showToast('Error', err.body?.message || err.message, 'error');
          });
    }
    
    openCommentModal() {
        this.showCommentModal = true;
    }
      
      
    closeCommentModal() {
        this.showCommentModal = false;
    }


    _updateActivityReported(newReported) {
        const activityId = this.wiredRecordResult.data.fields
          .Docketing_Activity__c.value;
        if (!activityId) {
          return Promise.resolve();
        }
        const fields = {
          Id: activityId,
          Reported__c: newReported
        };
        return updateRecord({ fields });
      }
  
    _showToast(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message: msg, variant }));
    }
}