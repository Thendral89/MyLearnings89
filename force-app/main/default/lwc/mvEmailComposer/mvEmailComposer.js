import { LightningElement, api, track, wire } from 'lwc';
import getEmailTemplates from '@salesforce/apex/mvEmailComposerController.getEmailTemplates';
import getCurrentUserEmail from '@salesforce/apex/mvEmailComposerController.getCurrentUserEmail';
import sendAnEmailMsg from '@salesforce/apex/mvEmailComposerController.sendAnEmailMsg';
//import getOrgWideEmails from '@salesforce/apex/mvEmailComposerController.getOrgWideEmails';
import getTemplateDetails from '@salesforce/apex/mvEmailComposerController.getTemplateDetails';
//import CLIENT_ID  from '@salesforce/schema/User.Client_Id__c';
import { getRecord, getRecordUi, createRecord, getFieldValue, updateRecord  } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import getEmailSignature from '@salesforce/apex/mvEmailComposerController.GetEmailSignature';
import getRelatedEmailsForDirectory from '@salesforce/apex/mvEmailComposerController.getRelatedEmailsForDirectory';
import getAddressDetails from '@salesforce/apex/mvEmailComposerController.getAddressDetails';
import getEmailMessageDetails from '@salesforce/apex/mvEmailComposerController.getEmailMessageDetails';
import getForwardAttachment from '@salesforce/apex/mvEmailComposerController.getForwardAttachment';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import getDocumentDetails from '@salesforce/apex/mvEmailComposerController.getDocumentDetails';
import updateEmailMessage from '@salesforce/apex/mvEmailComposerController.updateEmailMessage';

import linkFilesToDocket from '@salesforce/apex/mvEmailComposerController.linkFilesToDocket';
import notifyReviewer from '@salesforce/apex/mvEmailComposerController.notifyReviewer';

import DOCKET_REPORT_OBJECT from '@salesforce/schema/Docket_Report_External__c';
import SUBJECT_FIELD from '@salesforce/schema/Docket_Report_External__c.Subject__c';
import TO_FIELD from '@salesforce/schema/Docket_Report_External__c.To_Address__c';
import CC_FIELD from '@salesforce/schema/Docket_Report_External__c.CC_Address__c';
import BCC_FIELD from '@salesforce/schema/Docket_Report_External__c.BCC_Address__c';
import FROM_FIELD from '@salesforce/schema/Docket_Report_External__c.From_Address__c';
import BODY_FIELD from '@salesforce/schema/Docket_Report_External__c.Email_Content__c';
import STATUS_FIELD from '@salesforce/schema/Docket_Report_External__c.Status__c';
import DOCKET_ACTIVITY from '@salesforce/schema/Docket_Report_External__c.Docketing_Activity__c';
import ASSIGNED_TO_FIELD from '@salesforce/schema/Docket_Report_External__c.Assigned_To__c';
import REPORTED_FIELD from '@salesforce/schema/SymphonyLF__Docketing_Activity__c.Reported__c';

import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';


import { getRelatedListRecords } from 'lightning/uiRelatedListApi';


export default class mvEmailComposer extends NavigationMixin(LightningElement) {
    @api recordId;
    @api emailMessageId;
    
    @api objectType; // Current object type
    @track _actionType;// Action type: 'new', 'reply', 'replyAll', 'forward'
    @api docketId;
    @track isLoading = false;
    @track orgWideEmails = [];
    @track isLoading = true;
    @track fromAddresses = [];
    @track ccAddresses = '';
    @track bccAddresses = '';
    @track subject = '';
    @track body = '';
    @track emailTemplates = [];
    @track selectedTemplate = null;
    @track fromAddress;
    loggedInUserEmail = '';
    //userClientId = '';
    currentTeam = '';
    @track personRecords = [];
    @track toAddresses = '';
    recentEmailRecords = [];
    filteredRecords = [];
    @track templateFolders = [];
    @track filteredTemplates = [];
    @track selectedFolder = null;
    @track selectedTemplate = null;
    @track attachedFiles = [];

    @track showCCField = false;
    @track showBCCField = false;

    @track templateMap = new Map(); // Added???
    @track isDirectoryModalOpen = false;
    @track paralegalEmails = [];
    @track isTemplateVisible = true;
    @track isAttachmentVisible = false;
    @track hasEditedSubject = false;
    @track isSandbox = false;

    @api isInitiatedFromReportExternal = false;

    /* @wire(isSandboxEnvironment)
    wiredSandbox({ error, data }) {
        if (data !== undefined) {
            this.isSandbox = data;
            console.log('Environment:', this.isSandbox ? 'UAT (Sandbox)' : 'Production');
        } else if (error) {
            console.error('Error fetching environment info:', JSON.stringify(error));
        }
    } */

    /* @wire(getOrgWideEmails)
    wiredOrgWideEmails({ error, data }) {
        if (data) {
            console.log('Org-wide emails fetched successfully:', JSON.stringify(data));
            this.orgWideEmails = data;
            this.setFromEmail(); // Set "From" email after fetching org-wide emails
        } else if (error) {
            console.error('Error fetching org-wide emails:', JSON.stringify(error));
        }
    } */

    // Fetch logged-in user's Client ID
    /* @wire(getRecord, { recordId: USER_ID, fields: [CLIENT_ID] })
    wiredUserRecord({ error, data }) {
        if (data) {
            console.log('User record fetched successfully:', JSON.stringify(data));
            this.userClientId = data.fields.Client_Id__c.value;
            this.setFromEmail(); // Set "From" email after fetching user Client ID
        } else if (error) {
            console.error('Error fetching user record:', JSON.stringify(error));
        }
    } */

    /* @wire(getRecordUi, { recordIds: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecordUi({ error, data }) {
        if (data) {
            console.log('Current record data:', JSON.stringify(data));
            if (this.objectType === 'SymphonyIPMExt__Dispute_Opposition__c') {
                this.currentTeam = data.records[this.recordId]?.fields?.Team__c?.value || '';
                console.log('Dispute Opposition Team:', this.currentTeam);
                this.setFromEmail(); // Update email based on the fetched team
            }
        } else if (error) {
            console.error('Error fetching record UI data:', JSON.stringify(error));
        }
    } */

    @api
    set actionType(value) {
        if (this._actionType !== value) {
            this._actionType = value;
            this.initializeEmailComposer();
        }
    }
    get actionType() {
        return this._actionType;
    }

    @track isManageDocSelected = false;
    @track iManageSelectedFileIds = [];
    @track isFlowModalOpen = false;
    @track iManageLinks = '';
    flowApiName = 'cmpAPiManageCollaborationDocument';
    flowInputVariables = [];

    wiredMEMData;
    MEMData=[];
    @track assignedUserIds = [];
    @track selectedAssignedTo = ''; 
    _defaultToAddresses = [];
    _defaultCcAddresses = [];
    // @track isAdmin = false;

    // @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    // _wiredUser({ error, data }) {
    //     if (data) {
    //     const profName = getFieldValue(data, PROFILE_NAME_FIELD);
    //     this.isAdmin = (profName === 'System Administrator');
    //     console.log('this.isAdmin:', this.isAdmin);
    //     } else if (error) {
    //     console.error('Could not load current user profile', error);
    //     }
    // }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'SymphonyLF__Matter_Engagement_Model__r', 
        fields: [ 'SymphonyLF__Matter_Engagement_Model__c.Id'
                , 'SymphonyLF__Matter_Engagement_Model__c.SymphonyLF__Type__c'
                , 'SymphonyLF__Matter_Engagement_Model__c.Is_Active__c'
                , 'SymphonyLF__Matter_Engagement_Model__c.SymphonyLF__Assign_to_User__c'
                , 'SymphonyLF__Matter_Engagement_Model__c.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c'
                , 'SymphonyLF__Matter_Engagement_Model__c.SymphonyLF__Assign_to_User__r.SymphonyLF__Email__c'
                ]
     })
    wiredMatterEngagementListInfo(result) {
        this.wiredMEMData = result;
        const { data, error } = result;
        if (data) {
            this.MEMData = JSON.parse(JSON.stringify(data.records));
            console.log('MEMData: ' , JSON.stringify(this.MEMData));
            if(this.isInitiatedFromReportExternal){
                this._extractActiveAttorneyParalegalUserIds();
                this._populateDefaultToAddresses();
                this._populateDefaultCcAddresses();
            }
        }else if (error) {
            console.error('MEMData Error : ', error);           
            this.MEMData = undefined;
            this.assignedUserIds = [];
            this.toAddresses = [];
            this.ccAddresses = [];
            this._defaultToAddresses = [];
            this._defaultCcAddresses = [];
        }
    }

    _extractActiveAttorneyParalegalUserIds() {
        const raw = this.MEMData
        .filter(rec => {
        const type   = rec.fields['SymphonyLF__Type__c'].value || '';
        const active = rec.fields['Is_Active__c'].value === true;
        return active && (type.includes('Attorney') || type === 'Paralegal');
        })
        .map(rec => {
        const person = rec.fields['SymphonyLF__Assign_to_User__r']?.value;
        return person?.fields['SymphonyLF__User__c']?.value;
        })
        .filter(Boolean);
        this.assignedUserIds = Array.from(new Set(raw));

        console.log('assignedUserIds:', JSON.stringify(this.assignedUserIds));

    }  

    // TO: Correspondence Contact OR Client Representative AND active
    _populateDefaultToAddresses() {
        const raw = this.MEMData
            .filter(rec =>
            rec.fields['Is_Active__c'].value === true &&
            ['Correspondence Contact','Client Representative']
                .includes(rec.fields['SymphonyLF__Type__c'].value)
            )
            .map(rec => {
            const person = rec.fields['SymphonyLF__Assign_to_User__r']?.value;
            if (!person) {
                return undefined;
            }
            return person.fields['SymphonyLF__Email__c']?.value;
            })
            // drop any undefined / null
            .filter(email => Boolean(email));

            this._defaultToAddresses = Array.from(new Set(raw));
            this.toAddresses = [...this._defaultToAddresses];

            console.log('this.toAddresses::', JSON.stringify(this.toAddresses));
            const toInput = this.template.querySelector('c-multi-select-email-input[data-field="toAddresses"]');
                if (toInput) {
                    toInput.value = this.toAddresses;
                }  
    }
    
    // CC: Paralegal OR contains “Attorney” OR Copy Contact OR CC Law Firm Personnel AND active
    _populateDefaultCcAddresses() {
        const raw  = this.MEMData
            .filter(rec =>
                rec.fields['Is_Active__c'].value === true &&
                (
                rec.fields['SymphonyLF__Type__c'].value === 'Paralegal' ||
                rec.fields['SymphonyLF__Type__c'].value.includes('Attorney') ||
                rec.fields['SymphonyLF__Type__c'].value === 'Copy Contact' ||
                rec.fields['SymphonyLF__Type__c'].value === 'CC Law Firm Personnel'
                )
            )
            .map(rec => {
                const person = rec.fields['SymphonyLF__Assign_to_User__r']?.value;
                return person?.fields['SymphonyLF__Email__c']?.value;
            })
            .filter(email => Boolean(email));
        
            this._defaultCcAddresses = Array.from(new Set(raw));

            this.ccAddresses = [...this._defaultCcAddresses];
            console.log('this.ccAddresses::', JSON.stringify(this.ccAddresses));
            const ccInput = this.template.querySelector('c-multi-select-email-input[data-field="ccAddresses"]');
            if (ccInput) {
                ccInput.value = this.ccAddresses;
            }            
    }
  

    handleUserSelection(event) {
        this.selectedAssignedTo = event.detail.recordId || event.detail.value;
    }

    get userPickerFilter() {
        return this.assignedUserIds.length
          ? { criteria: [
              {
                fieldPath: 'Id',
                operator: 'in',
                value: this.assignedUserIds
              }
            ] }
          : {};
    }

    handleManageDocChange(event) {
        try {
            this.isManageDocSelected = event.target.checked;
            if (this.isManageDocSelected) {
                this.flowInputVariables = [
                    {
                        name: 'recordId',
                        type: 'String',
                        value: this.recordId
                    }
                ];
                this.isFlowModalOpen = true;
            }
        } catch (error) {
            console.error('Error in handleManageDocChange:', error);
        }
    }
    

    handleFlowFinish(event) {
        try {
            console.log('Flow Finished Event:', JSON.stringify(event.detail));
            if (event.detail.status === 'FINISHED') {
                this.isFlowModalOpen = false;

                const outputVariables = event.detail.outputVariables || [];
                const selectedFileIds = outputVariables.find(
                    (output) => output.name === 'iManageSelectedFileIds'
                )?.value || [];

                console.log('Selected iManage File IDs:', JSON.stringify(selectedFileIds));

                if (selectedFileIds.length > 0) {
                    this.iManageSelectedFileIds = selectedFileIds.split(',');
                    this.fetchDocumentDetails();
                }
            }
        } catch (error) {
            console.error('Error in handleFlowFinish:', error);
        }
    }

    fetchDocumentDetails() {
        getDocumentDetails({ documentIds: this.iManageSelectedFileIds })
            .then((documents) => {
                if (documents && documents.length > 0) {
                    let documentLinks = documents.map(doc => 
                        `<a href="${doc.iManageFileUrl__c}" target="_blank">${doc.name__c}</a>`
                    ).join('<br/>');

                    this.iManageLinks = 'Attached iManage Documents:<br/>' + documentLinks;
                    this.appendIManageLinks();
                    //this.body = (this.body ? this.body + '<br/><br/>' : '') + 
                    //            'Attached iManage Documents:<br/>' + documentLinks;
                    
                    this.showToast('Success', 'iManage documents added successfully', 'success');
                }
            })
            .catch((error) => {
                console.error('Error fetching document details:', error);
                this.showToast('Error', 'Failed to fetch document details', 'error');
            });
    }

    appendIManageLinks() {
        if (this.iManageLinks) {
            if (this.body.includes(this.iManageLinks)) {
                return;
            }
            this.body = (this.body ? this.body + '<br/><br/>' : '') + this.iManageLinks;
            const ck = this.template.querySelector('c-ckeditor4');
            if (ck) {
                setTimeout(() => {
                    ck.setEditorContent(this.body);
                    ck.focusAtStart();  
                }, 0);
            }
        }
    }

    handleCancelImanage() {
        this.isFlowModalOpen = false;
    }

    setFromEmail() {
        console.log('Setting "From" email...');
        //console.log('Org-wide Emails:', this.orgWideEmails);
        console.log('Logged-in User Email:', this.loggedInUserEmail);
        //console.log('User Client ID:', this.userClientId);
        //console.log('Current Team (if applicable):', this.currentTeam);
        //console.log('Environment:', this.isSandbox ? 'UAT (Sandbox)' : 'Production');

        /* if (!this.orgWideEmails.length || !this.loggedInUserEmail) {
            console.log('Skipping "From" email setup due to missing data.');
            return;
        }

        let defaultEmail = null;
        //const clientId = this.userClientId.toLowerCase();

        // Define email addresses for Production and UAT
        const emailMap = {
            'production': {
                'syngenta_patents': 'global.patents@syngenta.com',
                'syngenta_trademarks': 'global.trademarks@syngenta.com',
                'adama_patents': 'patents.symphony@adama.com',
                'adama_trademarks': 'trademark.symphony@adama.com'
            },
            'sandbox': {
                'syngenta_patents': 'syngentapatents@maxval.com',
                'syngenta_trademarks': 'syngentatrademarks@maxval.com',
                'adama_patents': 'adamapatents@maxval.com',
                'adama_trademarks': 'adamatrademarks@maxval.com'
            }
        };

        // Select appropriate mapping based on environment
        const env = this.isSandbox ? 'sandbox' : 'production';

        if (['symphonyipm__invention_disclosure_new__c', 'symphonyipm__patent__c', 'collection__c', 'symphonyipm__collection__c'].includes(this.objectType?.toLowerCase())) {
            defaultEmail = this.orgWideEmails.find(email =>
                clientId === 'syngenta'
                    ? email.Address === emailMap[env]['syngenta_patents']
                    : email.Address === emailMap[env]['adama_patents']
            );
        } else if (this.objectType === 'SymphonyIPMExt__Dispute_Opposition__c') {
            // Dispute Opposition object
            if (this.currentTeam === 'Patent Team') {
                defaultEmail = this.orgWideEmails.find(email =>
                    clientId === 'syngenta'
                        ? email.Address === emailMap[env]['syngenta_patents']
                        : email.Address === emailMap[env]['adama_patents']
                );
            } else if (this.currentTeam === 'Trademark Team') {
                defaultEmail = this.orgWideEmails.find(email =>
                    clientId === 'syngenta'
                        ? email.Address === emailMap[env]['syngenta_trademarks']
                        : email.Address === emailMap[env]['adama_trademarks']
                );
            }
        }

        // Default to Trademark email if none found
        if (!defaultEmail) {
            defaultEmail = this.orgWideEmails.find(email =>
                clientId === 'syngenta'
                    ? email.Address === emailMap[env]['syngenta_trademarks']
                    : email.Address === emailMap[env]['adama_trademarks']
            );
        }

        console.log('Default Email Selected:', defaultEmail); */

        this.fromAddresses = [
            //{ label: defaultEmail?.Address || 'Org-wide Email', value: defaultEmail?.Address || '' },
            { label: this.loggedInUserEmail, value: this.loggedInUserEmail }
        ];

        this.fromAddress = this.loggedInUserEmail || ''; // Default selected email
        console.log('From Addresses:', JSON.stringify(this.fromAddresses));
        console.log('Selected From Address:', this.fromAddress);
    }
    
    handleEditSubject() {
        this.hasEditedSubject = true;
    }
    get showBottomSubject() {
        if (this.actionType === 'new') {
            return true;
        }
        return this.hasEditedSubject;
    }
    get showTopReadOnlySubject() {
        const isReplyOrForward =
            this.actionType === 'reply' ||
            this.actionType === 'replyAll' ||
            this.actionType === 'forward';

        return isReplyOrForward && !this.hasEditedSubject;
    }

    toggleTemplateVisibility() {
        this.isTemplateVisible = !this.isTemplateVisible;
    }

    toggleAttachmentVisibility() {
        this.isAttachmentVisible = !this.isAttachmentVisible;
    }
    connectedCallback() {
        console.log('docketId:', this.docketId);
        console.log('this.recordId:', this.recordId);
        this.loadCurrentUserEmail();
        this.isLoading = true;
        this.loadEmailTemplates();

        this.initializeEmailComposer();

        //this.getEmailsForCC();
    }

    initializeEmailComposer() {
        console.log('Initializing Email Composer...');
        
        // Reset email fields
        this.resetFields();
    
        // Prepopulate fields based on actionType
        if (this.actionType === 'reply' || this.actionType === 'replyAll' || this.actionType === 'forward') {
            this.fetchOriginalEmail();
        } else {
            this.prepopulateFields();
        }
    }    

    @track syncToIManage = true;
    handleSyncToggle(event) {
        this.syncToIManage = event.target.checked;
        console.log('syncToIManage:', this.syncToIManage);
    }

    toFocusNeeded = false;
    isStyleAdded = false;
    toFocusNeeded = false;
    focusHandlerAdded = false;
    renderedCallback() {
        if (this.toFocusNeeded) {
            const el = this.template.querySelector('[data-id="toField"]');
            if (el) {
                el.focus();
                this.toFocusNeeded = false; // done focusing
            }
        }

        const bodyInputHeight = this.template.querySelector('.customHeight');
        if (bodyInputHeight) {
            setTimeout(() => {
                let editor = bodyInputHeight.shadowRoot.querySelector('.slds-rich-text-editor__output');
                if (editor) {
                    editor.style.minHeight = '500px';
                    editor.style.height = '500px';
                    editor.style.maxHeight = '500px';
                }
            }, 2000);
        }

        const bodyInput = this.template.querySelector('lightning-input-rich-text[data-id="bodyInput"]');
        if (bodyInput && !this.focusHandlerAdded) {
            bodyInput.addEventListener('focus', this.handleBodyFocus.bind(this));
            this.focusHandlerAdded = true;
        }

    }
    handleBodyFocus() {
        try {
            const element = this.template.querySelector(
                'lightning-input-rich-text[data-id="bodyInput"]'
            );
            if (element) {
                const quill = element.getQuill();
                quill.setSelection(0, 0);
            }
        } catch (err) {
            console.warn('Could not move cursor to the top:', err);
        }
    }

    // --------------- REPLY/REPLYALL/FORWARD ---------------
    fetchOriginalEmail() {
        this.isLoading = true;
        getEmailMessageDetails({ emailMessageId: this.emailMessageId })
            .then(async (msg) => {
                if (!msg) {
                    this.prepopulateFields();
                    return;
                }
    
                const originalBody = msg.htmlBody || '';
                const quotedPart = '<br/><br/>--- Original Message ---<br/>' + originalBody;

                let signatureArr = await getEmailSignature();
                let signature = (signatureArr && signatureArr.length)
                    ? signatureArr[0]
                    : '';
    
                if (this.actionType === 'reply') {
                    this.subject = 'Re: ' + (msg.subject || '');
                    if (
                        msg.fromAddress &&
                        msg.fromAddress.toLowerCase() !== this.loggedInUserEmail.toLowerCase()
                    ) {
                        this.toAddresses = [msg.fromAddress];
                    } else {
                        this.toAddresses = [];
                    }
                    this.body =
                        '<p><br/></p>' + 
                        signature +
                        '<br/><br/>' +
                        quotedPart;
                        const ck = this.template.querySelector('.ckEditorLwc');
                        if (ck) {
                            ck.setEditorContent(this.body);
                            ck.focusAtStart();  
                        }
                    //this.focusField('bodyInput');
                }
                else if (this.actionType === 'replyAll') {
                    this.subject = 'Re: ' + (msg.subject || '');
                    const me = this.loggedInUserEmail.toLowerCase();
                    const originalTo = msg.toAddress
                        ? msg.toAddress.split(';').map(a => a.trim()).filter(a => a)
                        : [];
                    const originalCc = msg.ccAddress
                        ? msg.ccAddress.split(';').map(a => a.trim()).filter(a => a)
                        : [];
                
                    const fromAddr = (msg.fromAddress || '').toLowerCase();
                    let finalTo = [];
                    if (fromAddr && fromAddr !== me) {
                        finalTo.push(msg.fromAddress.trim());
                    }
                    finalTo.push(
                        ...originalTo.filter(addr => addr.toLowerCase() !== me)
                    );
                    let finalCc = originalCc.filter(ccAddr => {
                        const ccAddrLower = ccAddr.toLowerCase();
                        return (
                            ccAddrLower !== me &&
                            !finalTo.map(t => t.toLowerCase()).includes(ccAddrLower)
                        );
                    });
                
                    finalTo = [...new Set(finalTo.map(a => a.toLowerCase()))].map(a => a.trim());
                    finalCc = [...new Set(finalCc.map(a => a.toLowerCase()))].map(a => a.trim());
                
                    this.toAddresses = finalTo;
                    this.ccAddresses = finalCc;
                
                    this.body = '<p><br/></p>' + signature + '<br/><br/>' + quotedPart;
                    const ck = this.template.querySelector('.ckEditorLwc');
                    if (ck) {
                        ck.setEditorContent(this.body);
                        ck.focusAtStart();  
                    }
                }
                
                else if (this.actionType === 'forward') {
                    this.subject = 'Fwd: ' + (msg.subject || '');
                    this.toAddresses = [];
                    this.ccAddresses = [];

                    const forwardFiles = await getForwardAttachment({ whatId: this.emailMessageId });
                    this.attachedFiles = forwardFiles.map(f => ({
                        id: f.documentId,
                        name: f.name
                    }));
    
                    this.body =
                        '<p><br/></p>' +
                        signature +
                        '<br/><br/>' +
                        quotedPart;
                        const ck = this.template.querySelector('.ckEditorLwc');
                        if (ck) {
                            ck.setEditorContent(this.body);
                            ck.focusAtStart();  
                        }
                }
            })
            .catch((err) => {
                console.error('Error fetching original email:', err);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    

    async getEmailsForCC() {
        try {
            const searchText = ""; 
            const alreadyAddedPersonsToExclude = []; 

            const emails = await getRelatedEmailsForDirectory({
                recordId: this.recordId,
            });
            console.log('emails in getEmailsForCC=>', JSON.stringify(emails));
            this.paralegalEmails = emails.filter((email) => email.EmailOf === "Paralegal");
            console.log('this.paralegalEmails::', JSON.stringify(this.paralegalEmails));
            if (this.paralegalEmails.length > 0) {
                this.ccAddresses = this.paralegalEmails.map((email) => email.Email);
                const ccInput = this.template.querySelector('c-multi-select-email-input[data-field="ccAddresses"]');
                if (ccInput) {
                    ccInput.value = this.ccAddresses;
                }
                this.showCCField = true;
            }
        } catch (error) {
            console.error("Error fetching emails:", error);
        }
    }

    loadCurrentUserEmail() {
        console.log('Fetching logged-in user email...');
        getCurrentUserEmail()
            .then((email) => {
                if (email) {
                    console.log('Logged-in user email fetched successfully:', email);
                    this.loggedInUserEmail = email;
                    this.setFromEmail(); // Set "From" email after fetching logged-in user email
                } else {
                    console.warn('No email returned for logged-in user.');
                }
            })
            .catch((error) => {
                console.error('Error fetching current user email:', JSON.stringify(error));
            })
            .finally(() => (this.isLoading = false));
    }

    handleRecipientChange(event) {
        const field = event.currentTarget.dataset.field;
        this[field] = event.detail.selectedEmails || [];

        console.log('this[field]=>', JSON.stringify(this[field]));
    }

    handleFileDownload(event) {
        const fileId = event.currentTarget.name;
        window.open(`/sfc/servlet.shepherd/document/download/${fileId}`, '_blank');
    }

    loadEmailTemplates() {
        getEmailTemplates({ recordId: this.recordId })
            .then((response) => {
                console.log(
                    'Email templates fetched successfully:',
                    JSON.stringify(response))
                const templates = response.templates || [];
                const defaultFolderId = response.defaultFolderId;
                this.emailTemplates = templates;
                this.templateFolders = Array.from(
                    new Set(templates.map((template) => template.FolderId))
                ).map((folderId) => {
                    const folderName = templates.find((template) => template.FolderId === folderId)?.Folder?.Name;
                    return { label: folderName, value: folderId };
                });
                if (defaultFolderId) {
                    this.selectedFolder = defaultFolderId;
                    this.filterTemplatesByFolder(defaultFolderId);
                }
            })
            .catch((error) => {
                console.error('Error fetching email templates:', error);
            });
    }
    
    
    handleFolderChange(event) {
        this.selectedFolder = event.target.value;
        this.filterTemplatesByFolder(this.selectedFolder);
        // Populate the template map
        // this.filteredTemplates = this.emailTemplates.filter(
        //     (template) => template.FolderId === this.selectedFolder
        // ).map((template) => ({
        //     label: template.Name,
        //     value: template.Id,
        // }));
    }

    filterTemplatesByFolder(folderId) {
        this.filteredTemplates = this.emailTemplates
            .filter((template) => template.FolderId === folderId)
            .map((template) => ({
                label: template.Name,
                value: template.Id,
            }));
    }

    // Handle template selection
    /* handleTemplateChange(event) {
        this.selectedTemplate = event.target.value;
        
        console.log('selectedTemplate' , event.target.value);
        if (this.selectedTemplate) {
            this.isLoading = true;
            getTemplateDetails({ templateId: this.selectedTemplate, whoId: this.recordId, whatId: this.recordId })
                .then((details) => {
                    console.log('details=>', JSON.stringify(details));
                    this.subject = details.subject;
                    this.body = details.body + '<br/><br/>' + (this.body || '');
                    this.attachedFiles = details.fileAttachments || [];
                })
                .catch((error) => {
                    console.error('Error fetching template details:', error);
                });
            

                getAddressDetails({ templateId: this.selectedTemplate, recordId: this.recordId })
                .then((addressDetails) => {
                    console.log('Address Details:', JSON.stringify(addressDetails));
                    this.toAddresses = [...new Set([...this.toAddresses, ...(addressDetails.to)])];
                    this.ccAddresses = [...new Set([...this.ccAddresses, ...(addressDetails.cc)])];
                    this.bccAddresses = [...new Set([...this.bccAddresses, ...(addressDetails.bcc)])];

                    if (this.ccAddresses.length) {
                        this.showCCField = true;
                    }
                    if (this.bccAddresses.length) {
                        this.showBCCField = true;
                    }
                    
                })
                .catch((error) => {
                    console.error('Error fetching address details:', error);
                })    
                .finally(() => (this.isLoading = false));
        }
    } */

    handleTemplateChange(event) {
        this.selectedTemplate = event.target.value;
        
        console.log('selectedTemplate', event.target.value);
        
        if (this.selectedTemplate) {
            this.isLoading = true;
    
            // Reset fields before loading the new template
            this.subject = '';  
            this.body = '';  
            this.attachedFiles = [];
            console.log('this.recordId', this.recordId);
            if(!this.docketId){
                this.docketId = this.recordId;
            }
            console.log('this.recordId', this.recordId);
            getTemplateDetails({ templateId: this.selectedTemplate, whoId: this.docketId, whatId: this.docketId })
                .then((details) => {
                    console.log('details=>', JSON.stringify(details));
                    this.subject = details.subject;
                    this.body = details.body; // Overwrite previous body instead of appending
                    const ck = this.template.querySelector('.ckEditorLwc');
                        if (ck) {
                            ck.setEditorContent(this.body);
                            ck.focusAtStart();  
                        }
                    this.appendIManageLinks();
                    this.attachedFiles = details.fileAttachments || [];
                })
                .catch((error) => {
                    console.error('Error fetching template details:', error);
                })
                //;
    
            /* getAddressDetails({ templateId: this.selectedTemplate, recordId: this.recordId })
                .then((addressDetails) => {
                    console.log('Address Details:', JSON.stringify(addressDetails));
                    
                    this.toAddresses = [...new Set(addressDetails.to)]; // Reset & set new To addresses
                    this.ccAddresses = [...new Set(addressDetails.cc)];
                    this.bccAddresses = [...new Set(addressDetails.bcc)];
    
                    this.showCCField = this.ccAddresses.length > 0;
                    this.showBCCField = this.bccAddresses.length > 0;
                })
                .catch((error) => {
                    console.error('Error fetching address details:', error);
                }) */
                .finally(() => (this.isLoading = false));
        }
    }
        
    // Set user signature in the body
    setSignature() {
        getEmailSignature()
            .then((signatureArr) => {
                let signature = (signatureArr && signatureArr.length) ? signatureArr[0] : '';
                this.body = '<p><br/></p>' + signature;
            })
            .catch((error) => {
                console.error('Error fetching email signature:', JSON.stringify(error));
            });
    }
    
    // Handle file upload
    handleFileUpload(event) {
        const uploadedFiles = event.detail.files;
        this.attachedFiles = [
            ...this.attachedFiles,
            ...uploadedFiles.map((file) => ({
                id: file.documentId,
                name: file.name,
            })),
        ];
    }

    // Remove file from attachment list
    removeFile(event) {
        const fileId = event.target.name;
        this.attachedFiles = this.attachedFiles.filter((file) => file.id !== fileId);
    }

    // Open Active Directory
    openActiveDirectory() {
        // Logic to open Active Directory and fetch emails
        console.log('Opening Active Directory...');
        this.isDirectoryModalOpen = true;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    // Reset fields when component is disconnected (removed)
    disconnectedCallback() {
        this.resetFields();
    }

    handleSubjectChange(event) {
        this.subject = event.target.value;
        this.hasEditedSubject = true;
        const subjectChangeEvent = new CustomEvent('subjectchange', {
            detail: { subject: this.subject }
        });
        this.dispatchEvent(subjectChangeEvent);
    }


    // Prepopulate fields based on action type
    prepopulateFields() {
        if (this.actionType === 'new') {
            this.setSignature();
           // this.focusField('bodyInput');
        }
    }

    handleToFieldKeydown(event) {
        if (event.key === 'ArrowDown') {
            this.focusField('ccAddresses');
        } else if (event.key === 'ArrowUp') {
            this.focusField('fromAddress');
        }
    }

    
    async sendEmail() {
        console.log('this.recordId in sendEmail:', this.recordId);
        const component = this.template.querySelector('.ckEditorLwc');
        /* if (component) {
            await component.passBackProcessedData(); 
        } */
        if (component) {
            this.body = await new Promise((resolve) => {
                const handler = (event) => {
                    if (event.data?.type === 'change') {
                        window.removeEventListener('message', handler);
                        resolve(event.data.value);
                    }
                };
                window.addEventListener('message', handler);
                component.passBackProcessedData(); 
            });
        }
        this.isLoading = true;
        const emailPayload = {
            fromAddress: this.fromAddress || '', 
            toAddressesStr: (this.toAddresses || []).join(','), 
            ccAddressesStr: (this.ccAddresses || []).join(','),
            bccAddressesStr: (this.bccAddresses || []).join(','),
            subject: this.subject || '', 
            body: this.body || '',
            whatId: this.recordId || '', 
            contentDocumentIds: (this.attachedFiles || []).map((file) => file.id), 
        };

        console.log('emailPayload=>', JSON.stringify(emailPayload));
        sendAnEmailMsg(emailPayload)
            .then((emailMessageId) => {
                console.log('Email sent successfully');
                this.resetFields();
                this.dispatchEvent(
                    new CustomEvent('emailsent', {
                        detail: { message: 'Email sent successfully!' },
                    })
                );
                this.showToast('Success', 'Email sent successfully', 'success');
                console.log('this.syncToIManage', this.syncToIManage);
                console.log('this.emailMessageId', this.emailMessageId);
                if (emailMessageId) {
                    
                    updateEmailMessage({ emailMessageId: emailMessageId, syncToIManage: this.syncToIManage });
                }
            })
            .catch((error) => {
                console.error('Error sending email:', error);
                console.error('Error sending email:', error.message);
            })
            .finally(() => (this.isLoading = false));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }

    //  resetFields() {
    //     this.toAddresses = [];
    //     this.ccAddresses = [];
    //     this.bccAddresses = [];
    //     this.subject = '';
    //     this.body = '';
    //     this.selectedTemplate = null;
    //     this.attachedFiles = [];
    // }

    handleDirectoryValueChange(event) {
        console.log('event.detail::', JSON.stringify(event.detail));  
        const newEmailData = event.detail;

        // Helper function to merge new emails with existing ones without duplicates
        const mergeEmails = (existingEmails, newEmails) => {
            const emailSet = new Set(existingEmails);
            newEmails.forEach(email => emailSet.add(email));
            return Array.from(emailSet);
        };

        // Process the new email data based on type
        newEmailData.forEach(entry => {
            const { type, emails } = entry;

            if (type === 'To') {
                this.toAddresses = mergeEmails(this.toAddresses, emails);
            } else if (type === 'CC') {
                this.ccAddresses = mergeEmails(this.ccAddresses, emails);
            } else if (type === 'BCC') {
                this.bccAddresses = mergeEmails(this.bccAddresses, emails);
            }
        });

        if (this.ccAddresses.length) {
            this.showCCField = true;
        }
        if (this.bccAddresses.length) {
            this.showBCCField = true;
        } 

            // Log the updated values
            console.log('Updated toAddresses:', JSON.stringify(this.toAddresses));
            console.log('Updated ccAddresses:', JSON.stringify(this.ccAddresses));
            console.log('Updated bccAddresses:', JSON.stringify(this.bccAddresses));

        this.isDirectoryModalOpen = false;
    }

    isFromEditable = false; 
    toggleBCCField() {
        this.showBCCField = !this.showBCCField; 
    }

    enableFromEdit() {
        this.isFromEditable = true; 
    }

    handleFromChange(event) {
        console.log('From address changed:', event.target.value);
        this.fromAddress = event.target.value; 
    }

    handleToChange(event) {
        this.toAddresses = event.target.value;
    }

    handleCCChange(event) {
        this.ccAddresses = event.target.value;
    }

    handleBCCChange(event) {
        this.bccAddresses = event.target.value;
    }

    handleBodyChange(event) {
        this.body = event.target.value;
    }

    resetFields() {
        this.fromAddress = '';
        this.toAddresses = '';
        this.ccAddresses = '';
        this.bccAddresses = '';
        this.subject = '';
        this.body = '';
        this.selectedFolder = '';
        this.selectedTemplate = '';
        this.attachedFiles = [];
        this.isFromEditable = false; // Reset 'From' field to non-editable
        this.syncToIManage = true;
    }

    // Directory modal toggle
    isDirectoryModalOpen = false;

    handlePopupClose() {
        this.isDirectoryModalOpen = false;
    }
    
    focusField(dataId) {
        window.setTimeout(() => {
            const el = this.template.querySelector(`[data-id="${dataId}"]`);
            if (el) {
                el.focus();
            }
        }, 0);
    }

    get isSendDisabled() {
        return !this.subject || !this.fromAddress || !this.toAddresses || !this.body;
    }

    get isSendForApprovalDisabled() {
        return !this.subject || !this.fromAddress || !this.toAddresses || !this.body || !this.selectedAssignedTo;
    }

    handleSendForApproval() {
        const fields = {};
        fields[SUBJECT_FIELD.fieldApiName] = this.subject;
        fields[TO_FIELD.fieldApiName]      = (this.toAddresses || []).join(',');
        fields[CC_FIELD.fieldApiName]      = (this.ccAddresses || []).join(',');
        fields[BCC_FIELD.fieldApiName]     = (this.bccAddresses || []).join(',');
        fields[FROM_FIELD.fieldApiName]    = this.fromAddress;
        fields[BODY_FIELD.fieldApiName]    = this.body;
        fields[STATUS_FIELD.fieldApiName]  = 'Initiated';
        fields[DOCKET_ACTIVITY.fieldApiName]  = this.docketId;
        fields[ASSIGNED_TO_FIELD.fieldApiName]  = this.selectedAssignedTo;
    
        const recordInput = {
            apiName: DOCKET_REPORT_OBJECT.objectApiName,
            fields
        };
    
        this.isLoading = true;
        createRecord(recordInput)
            .then(docket => {
                const contentDocIds = this.attachedFiles.map(f => f.id);
                console.log('docketreport.id:', docket.id);
                return linkFilesToDocket({ docketId: docket.id, contentDocIds })
                    .then(() => notifyReviewer({ 
                            docketReportId: docket.id ,
                            templateName:   'Docket Report Review Request'
                    }))
                    // .then(() =>
                    //     updateRecord({
                    //       fields: {
                    //         Id: this.docketId,
                    //         [REPORTED_FIELD.fieldApiName]: 'Submitted for Attorney Review'
                    //       }
                    //     })
                    // )

                    .then(() => docket.id);
            })
            .then(docketReportId => {
                this.showToast('Success', 'Approval request created', 'success');
                this.resetFields();
                this.dispatchEvent(new CustomEvent('close'));
            })
            .catch(error => {
                console.error('Error creating approval or linking files', error);
                this.showToast('Error', error.body?.message || error.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    
}