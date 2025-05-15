({
   
    
     OnSubmitted: function(component, event, helper) {
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
        
     },
    
      OnIsSDocstartEdit : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        component.set("v.IsSDocsEditing", true);
    },
    
     OnIsSDocscancelEdit : function(component, event, helper) {
        component.set("v.IsSDocsEditing", false);
    },
    
     OnIsSDocssaveInput : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
        helper.ContentVersionRenamed(component, recid);
    },
    
    OnEmailsSubjectDocuments : function(component, event, helper) {
		var recid = event.getSource().get("v.value");
        component.set("v.EmailsSubject", recid);
        //alert('recid ' + recid);
        
    },
    
     OnEmailsSubjectstartEdit : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        component.set("v.IsEmailsSubject", true);
    },
    
    OnEmailsSubjectcancelEdit : function(component, event, helper) {
        component.set("v.IsEmailsSubject", false);
    },
    
     OnEmailsSubjectsaveInput : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        helper.UpdateEmailSubject(component, recid);
    },
    
    
     OnDocuSignDocuments : function(component, event, helper) {
		var recid = event.getSource().get("v.value");
        component.set("v.EmailDocumentsName", recid);
        //alert('recid ' + recid);
        
    },
    
     OnDocuSignstartEdit : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        component.set("v.IsEmailsEditing", true);
    },
    
    OnDocuSigncancelEdit : function(component, event, helper) {
        component.set("v.IsEmailsEditing", false);
    },
    
     OnDocuSignsaveInput : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        helper.ContentVersionRenamed(component, recid);
    },
    
    OnEmailDocuments : function(component, event, helper) {
		var recid = event.getSource().get("v.value");
        component.set("v.EmailDocumentsName", recid);
        //alert('recid ' + recid);
        
    },
    
     OnEmailstartEdit : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        component.set("v.IsEmailsEditing", true);
    },
    
    OnEmailcancelEdit : function(component, event, helper) {
        component.set("v.IsEmailsEditing", false);
    },
    
     OnEmailsaveInput : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        helper.ContentVersionRenamed(component, recid);
    },
    
     startEdit : function(component, event, helper) {
        component.set("v.IsiMngEditing", true);
    },
    
    cancelEdit : function(component, event, helper) {
        component.set("v.IsiMngEditing", false);
    },
    
     saveInput : function(component, event, helper) {
         var recid = event.getSource().get("v.value");
         //alert(JSON.stringify(recid));
        helper.DocumentRenamed(component, recid);
    },
    
    refreshPage: function(component, event, helper) {
        //window.location.reload();
    },
    
    OnRefresh: function(cmp, event, helper) {
        //window.location.reload();
        //helper.getgetWorkspaceName(component);
        //$A.get('e.force:refreshView').fire(); 
    },
    
    doInit: function (component, event, helper) {
        
        component.set('v.Tablecolumns', [
               {
                    type: 'button-icon',
                    fixedWidth: 40,
                    typeAttributes: {
                        iconName: 'utility:download',
                        name: 'download', 
                        title: 'download',
                        alternativeText: 'download',
                        disabled: false
                    }
                },
            	{
                    type: 'button-icon',
                    fixedWidth: 40,
                    typeAttributes: {
                        iconName: 'utility:delete',
                        name: 'delete', 
                        title: 'delete',
                        alternativeText: 'delete',
                        disabled: false
                    }
                },
            	{
                    type: 'button-icon',
                    fixedWidth: 40,
                    typeAttributes: {
                        iconName: 'utility:preview',
                        name: 'preview', 
                        title: 'preview',
                        alternativeText: 'preview',
                        disabled: false
                    }
                },
                {label: 'Document name', fieldName: 'name__c', 									initialWidth: 250,wrapText: false,sortable: true,type: 'text'},
            	{ label: 'extension', fieldName: 'extension__c', 								initialWidth: 50,wrapText: false,sortable: true,type: 'text'}, 
                { label: 'Folder Name', fieldName: 'Folder_Name__c', 							initialWidth: 180,wrapText: false,sortable: true,type: 'text'}, 
                { label: 'author', fieldName: 'author__c', 										initialWidth: 150,wrapText: false,sortable: true,type: 'text'}, 
                { label: 'create_date', fieldName: 'create_date__c', 							initialWidth: 120,wrapText: false,sortable: true,type: 'date-local',typeAttributes:{month: "2-digit",day: "2-digit"}}
        		]);
        
        //alert('getgetWorkspaceName getgetWorkspaceName' );
        
        helper.getgetWorkspaceName(component); 
        
       
   
    },
    
   OnSyncFolderFilesToiManage: function (component, event, helper)  {
      helper.getiManageFolderDetails(component);        
      //helper.getFolderDetails(component);        
    },
    
    OnChangeAppType: function (component, event, helper) {
        var recid = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        helper.updaterechelper(component, recid, value);
        
    },
   
     OniManageEmails : function( component, event, helper ) {
         component.set('v.IsMultiEmailDocument',false);
         component.set('v.IsDocuSignDocumentId',false);
         component.set('v.IsiManageConfigured',false);
         component.set('v.IsSDocsConfigured',false);
         
        if(component.get('v.IsiManageEmails')!=true) {
        	component.set('v.IsiManageEmails',true);
        } else {
            component.set('v.IsiManageEmails',false);
            component.set('v.tableData',null);
        }
	},
    
    OniManageConfigured : function( component, event, helper ) {
         component.set('v.IsMultiEmailDocument',false);
         component.set('v.IsDocuSignDocumentId',false);
         component.set('v.IsiManageEmails',false);
         component.set('v.IsSDocsConfigured',false);
        
        if(component.get('v.IsiManageConfigured')!=true) {
        	component.set('v.IsiManageConfigured',true);
        } else {
            component.set('v.IsiManageConfigured',false);
            component.set('v.tableData',null);
        }
	},
   
     OnDocuSignConfigured : function( component, event, helper ) {
         
         component.set('v.IsiManageEmails',false);
         component.set('v.IsiManageConfigured',false);
         component.set('v.IsSDocsConfigured',false);
         
        if(component.get('v.IsDocuSignConfigured')!=true) {
        	component.set('v.IsDocuSignConfigured',true)
            component.set('v.iManaged','DocuSign');
            helper.getDocuSignDetails(component, component.get("v.recordId"));
        } else {
            component.set('v.IsDocuSignConfigured',false);
            component.set('v.tableData',null);
        }
	},
    
    OnSDocsConfigured : function( component, event, helper ) {
         
         component.set('v.IsiManageEmails',false);
         component.set('v.IsiManageConfigured',false);
         component.set('v.IsDocuSignDocumentId',false);
        
        if(component.get('v.IsSDocsConfigured')!=true) {
        	component.set('v.IsSDocsConfigured',true)
            component.set('v.iManaged','SDocs');
            helper.getSDocuDetails(component, component.get("v.recordId"));
        } else {
            component.set('v.IsSDocsConfigured',false);
            component.set('v.tableData',null);
        }
	},
    
    OnSDocsItemDetailClick: function(component, event, helper) {
       var recid =  event.target.id;
       component.set('v.SDocsDocumentId',recid);
       helper.getDocuSignDocumentDetailsHelper(component,component.get('v.SDocsDocumentId'));
    },
    
     OnDocuSignItemDetailClick: function(component, event, helper) {
       var recid =  event.target.id;
       component.set('v.DocuSignDocumentId',recid);
       helper.getDocuSignDocumentDetailsHelper(component,component.get('v.DocuSignDocumentId'));
    },
    
     // When a keyword is entered in search box
	searchRecords : function( component, event, helper ) {
        
        if(component.get('v.disabled')!=true) {
        	helper.searchRecordsHelper(component, event, helper, []);
    	}
        if( $A.util.isEmpty(component.get('v.searchString')) ) {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
	},
    
   
    
    PreviewFile: function(cmp, event, helper) {
        var recid =  event.target.id;
		$A.get('e.lightning:openFiles').fire({
		    recordIds: [recid]
		});
    },
   
    OnFolderMoveSelected: function(component, event, helper) {
       var recid =  event.target.id;
       component.set('v.iManageSelectedFolderId',recid);
        if(component.get('v.iManageSelectedFolderId')!='' && component.get('v.iManageSelectedFolderId')!=null){
           helper.getFolderHelper(component); 
        }
    },
    
    OnSelectedFolderSync: function(component, event, helper) {
        //alert('OnSelectedFolderSync createdFolderId ' + component.get('v.createdFolderId'));
        
        if(component.get('v.createdFolderId')!='' && component.get('v.createdFolderId')!=null){
          helper.SyncSubFolder(component);
          helper.SyncSubFolderDocuments(component,component.get('v.createdFolderId'));  
        }
    },
    
    
    
    OndeleteAttachmentsController : function(component,event, helper)  {
        
        var msg ='Are you sure you want to delete this item?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            
        	var contentVersionId = event.getSource().get("v.value");
        	helper.OndeleteDocumentAttachmentsHelper(component,contentVersionId);
    	}
        
    },
    
    
    deleteAttachmentsController : function(component,event, helper)  {
        
        var msg ='Are you sure you want to delete this item?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            
        	var contentVersionId = event.getSource().get("v.value");
        	helper.deleteDocumentAttachmentsHelper(component,contentVersionId);
    	}
        
    },
    
    closeModal: function(component,event,helper){
        component.set('v.IsShow',false);
        component.set('v.IsNew',false);
        component.set('v.IsDeleted',false);
        component.set('v.IsFileShow',false);
    },
    
     closeModel: function(component,event,helper){
        component.set('v.IsShow',false);
        component.set('v.IsNew',false); 
        component.set('v.IsDeleted',false);
        component.set('v.IsFileShow',false);
        component.set('v.IsMoved',false);
        component.set('v.IsEmailAttachedMoved',false);
        component.set('v.IsCheckOut',false);
         
    },
    
    OnNewFolder: function(component,event,helper){
        component.set('v.IsNew',true);
        //helper.getFolderDetails(component);
    },
    
     OnCreateNewFolder: function(component,event,helper){
        
         if(component.get('v.iManageNewFolderName')!='' && component.get('v.iManageNewFolderName')!=null){
             helper.OnCreateiManageFolder(component);
         }
         
         
    },
   
    
    
    
    OnMultiEmailDocument: function(component, event, helper) {
      component.set('v.IsMoved',true);
    },
    
    OnMultiEmailDocumentToiManage: function(component, event, helper) {
         helper.getmultidocmoveHelper(component);
    },
    
     OnDocMove: function(component, event, helper) {
       if(component.get('v.iManageDocumentId')!='' && component.get('v.iManageDocumentId')!=null){
         helper.getdocmoveHelper(component);
       }
    },
    
     OnItemDetailMoveFile: function(component, event, helper) {
       var recid = event.getSource().get("v.value");
       if(component.get('v.iManageDocumentId')!='' && component.get('v.iManageDocumentId')!=null){
          helper.OnDocumentsMoveAccessHelper(component,component.get('v.iManageDocumentId'));  
       }
    },
    
    OnItemDetailPreviewFile: function(component, event, helper) {
       var recid = event.getSource().get("v.value");
       if(component.get('v.iManageDocumentId')!='' && component.get('v.iManageDocumentId')!=null){
           helper.OnItemPreviewDocuments(component,component.get('v.iManageDocumentId'));
       }
        
    },
    
     OnItemDetailDownloadClick: function(component, event, helper) {
         if(component.get('v.iManageDocumentId')!='' && component.get('v.iManageDocumentId')!=null){
       		helper.OnDownloadDocumentsAccessHelper(component,component.get('v.iManageDocumentId'));
         }
    },
    
    
    OnItemDetaiSyncFolderDocuments: function (component, event, helper)  {
        if(component.get('v.iManageDocumentId')!='' && component.get('v.iManageDocumentId')!=null){
        	helper.SyncFolderDocumentsAccessHelper(component,component.get('v.iManageDocumentId'));
        }
    },
    
   OnEmailsearchRecords : function( component, event, helper ) {
        
        if(component.get('v.disabled')!=true) {
        	helper.OnEmailsearchRecordsHelper(component, event, helper, []);
    	}
        if( $A.util.isEmpty(component.get('v.searchString')) ) {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
	},
    
     OnEmailAttachedMove: function(component, event, helper) {
       if(component.get('v.iManageSelectedEmailAttachmentId')!='' && component.get('v.iManageSelectedEmailAttachmentId')!=null){
         helper.getemaildocmoveHelper(component);
       }
    },
    
    OnEmailMoveSelected: function(component, event, helper) {
       var recid =  event.target.id;
       component.set('v.iManageSelectedEmailAttachmentId',recid);
        if(component.get('v.iManageSelectedEmailAttachmentId')!='' && component.get('v.iManageSelectedEmailAttachmentId')!=null){
           helper.getEmailFolderHelper(component); 
        }
    },
    
    OnCheckIn: function(component, event, helper) {
        var recid = event.getSource().get("v.value");
        component.set("v.iManageDocumentId", recid);
        helper.DocumentCheckIn(component,component.get('v.iManageDocumentId')); 
    },
    
    
    OnCheckOut: function(component, event, helper) {
        var recid = event.getSource().get("v.value");
        component.set("v.iManageDocumentId", recid);
        component.set("v.IsCheckOut", true);
    },
    
    OnDocumentCheckOut: function(component, event, helper) {
        if(component.get('v.DocumentCheckOutDueDate')!='' && component.get('v.DocumentCheckOutDueDate')!=null && component.get('v.DocumentCheckOutComment')!='' && component.get('v.DocumentCheckOutComment')!=null){
            helper.DocumentCheckOut(component,component.get('v.iManageDocumentId')); 
        }
    },
    
    

	OnEmailAttachmentMoveFile: function(component, event, helper) {
    	 var recid = event.getSource().get("v.value");
         component.set("v.EmailContentVersionId", recid);
         component.set('v.IsEmailAttachedMoved',true); 
         helper.OnEmailsearchRecordsHelper(component, event, helper, []);
    },
    
    OnEmailAttachmentMoveFileOld: function(component, event, helper) {
        var recid = event.getSource().get("v.value");
        component.set("v.EmailContentVersionId", recid);
        
        component.set("v.isLoading", true);
        var action = component.get("c.GetiManageAccessUsers");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows=='Access'){
                    component.set('v.IsEmailAttachedMoved',true);  
                    helper.OnEmailsearchRecordsHelper(component, event, helper, []);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'Error',
            			message:'iManage Error !' + rows,
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'error',
            			mode: 'pester'
        			});
        		toastEvent.fire();
                }
            }
            
          component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
    },
    
     OnFilesDownloadClick: function(component, event, helper) {
       var recid =  event.getSource().get("v.value");
       window.open('/sfc/servlet.shepherd/version/download/' + recid );
         
    },
    
     OnEmailAttachmentDownloadClick: function(component, event, helper) {
       var recid =  event.getSource().get("v.value");
       window.open('/sfc/servlet.shepherd/version/download/' + recid );
         
    },
    
     OnEmailRedirectClick: function(component, event, helper) {
       var recid =  event.getSource().get("v.value");
       window.open('/lightning/r/EmailMessage/' + recid + '/view');
         
    },
 
     OnEmailItemExpandClick: function(component, event, helper) {
       var recid =  event.getSource().get("v.value");
       helper.getEmailUploaded(component,recid);
         
    },
    
     OnEmailItemDetailClick: function(component, event, helper) {
       var recid =  event.target.id;
       component.set('v.iManagedEmailId',recid);
       component.set('v.IsMultiEmailDocument',false);
       helper.getEmailsAttachmentsHelper(component,recid);
         
    },
    
     OnItemDetailClick: function(component, event, helper) {
       var recid =  event.target.id;
       component.set('v.iManageDocumentId',recid);
       helper.OnDocumentsAccessHelper(component,component.get('v.iManageDocumentId'));
    },
    
     OnDivFunction: function(component,event,helper){
        var EnvelopeId = event.getSource().get("v.value");
     	//alert(EnvelopeId) ;
        
    },
    
    
    OnDocuSignUploadFinished: function (component, event, helper)  {
        var lstDocumentId =  event.getSource().get("v.value");
        component.set("v.ContentVersionId", lstDocumentId);
        helper.getDocuSignUploadFilesFinished(component);
  
      
    },
    
    
    OnUploadFinished: function (component, event, helper)  {
        var lstDocumentId = component.get("v.lstDocumentId");
        var uploadedFiles = event.getParam("files");

        if (uploadedFiles!=undefined) {
			for(var i=0;i<uploadedFiles.length;i++) {
                 if (uploadedFiles[i].size > component.get("v.MAX_FILE_SIZE")) {
                     component.set("v.isLoading", false);
                     component.set("v.ErrorMessage", 'Alert : File size cannot exceed ' + component.get("v.MAX_FILE_SIZE") + ' bytes.\n' + ' Selected file size: ' + uploadedFiles[i].size);
                     return;
        		 }
                
                lstDocumentId.push(uploadedFiles[i].documentId);
                component.set("v.ContentVersionId", uploadedFiles[i].documentId);
            }
        }
      
        helper.getUploadFilesFinished(component);
  
      
    },
    
     OnSelectedFolder : function(component,event,helper) {
        var EnvelopeId =  event.target.id;
        //alert('EnvelopeId ' + EnvelopeId)
        //var EnvelopeId = event.getSource().get("v.value");
        helper.getSelectedFolderDetails(component,EnvelopeId);
        component.set('v.IsShowFolderTables',true);
        
       
	},
    

    handleSelectTreeFolder: function (component, event, helper) {
        //return name of selected tree item
        var selectedName = event.getParam('name');
        
        var path = component.get("v.Path");
        var folderId = selectedName;
        for(var i = 0; i< path.length; i++) {
            if (path[i].id == folderId) {
                path.splice(i+1,path.length - i - 1);
                break;
            }
        }
      
        component.set("v.Path", path);
        helper.getSelectedFolderDetails(component,selectedName);
        component.set('v.IsShowFolderTables',true);
    },
    
     Onhome : function(component,event,helper) {
        component.set('v.IsShowFolderTables',false);
        helper.getWorkSpaceDetails(component);  
        helper.getdoctypeshelper(component);  
        helper.getAllUploadedFiles(component);
        helper.getEmails(component);  
	},
    
   
    
   OnEmails : function(component,event,helper) {
        var EnvelopeId = component.get("recordId");
        component.set('v.iManaged','Emails');   
        component.set('v.iManagedEmailId',EnvelopeId); 
        helper.getSelectedEmailsDetails(component,EnvelopeId);
        component.set("v.isLoading", false);
	},
    
   OnSelectedEmails : function(component,event,helper) {
        var EnvelopeId = event.getParam("SubselectedFolderId");
        component.set('v.iManaged','Emails');   
        component.set('v.iManagedEmailId',EnvelopeId); 
        helper.getEmailsDetailsHelper(component,EnvelopeId);
       component.set("v.isLoading", false);
	},
    
     OnSelectedFolderName : function(component,event,helper) {
        var EnvelopeId = event.getParam("SubselectedFolderId");
        var path = event.getParam("path");
         
        //alert('OnSelectedFolderName EnvelopeId ' + EnvelopeId)
        if(EnvelopeId!=''){
            component.set("v.Path", path);
        	component.set("v.isLoading", false);
            //helper.OnFolderSelectedSyncSubFolderDocumentsFuture(component,EnvelopeId);
        	//helper.OnSelectedSyncSubFolderDocuments(component,EnvelopeId);
            helper.getSelectedFolderDetails(component,EnvelopeId);
            component.set('v.iManaged','Folders');
        	component.set('v.IsShowFolderTables',true);
        }
        
	},

	handleSelectNode : function(component, event, helper) {
        var path = component.get("v.Path");
        var folderId = event.target.dataset.id;
        
        //alert('folderId' + folderId);
        
        for(var i = 0; i< path.length; i++) {
            if (path[i].id == folderId) {
                path.splice(i+1,path.length - i - 1);
                break;
            }
        }
        
       if(folderId!=''){
            component.set("v.Path", path);
        	helper.getSelectedFolderDetails(component,folderId);
        	component.set('v.IsShowFolderTables',true);
        }
        
    },
    
    OnUploadFinished: function (component, event, helper)  {
        var lstDocumentId = component.get("v.lstDocumentId");
        var uploadedFiles = event.getParam("files");
        if (uploadedFiles!=undefined) {
			for(var i=0;i<uploadedFiles.length;i++) {
                
                 if (uploadedFiles[i].size > component.get("v.MAX_FILE_SIZE")) {
                     component.set("v.isLoading", false);
                     component.set("v.ErrorMessage", 'Alert : File size cannot exceed ' + component.get("v.MAX_FILE_SIZE") + ' bytes.\n' + ' Selected file size: ' + uploadedFiles[i].size);
                     return;
        		 }
                lstDocumentId.push(uploadedFiles[i].documentId);
                component.set("v.ContentVersionId", uploadedFiles[i].documentId);
            }
            helper.getUploadDocumentFinished(component);
        }
      
    },
    
    handleUploadFinished: function (component, event, helper)  {
        // This will contain the List of File uploaded data and status
        // MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    	//CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
        
        var lstDocumentId = component.get("v.lstDocumentId");
        var uploadedFiles = event.getParam("files");
		var contentDocumentId = uploadedFiles[0].documentId;
       
        if (uploadedFiles!=undefined) {
			for(var i=0;i<uploadedFiles.length;i++) {
                
                 if (uploadedFiles[i].size > component.get("v.MAX_FILE_SIZE")) {
                     component.set("v.isLoading", false);
                     component.set("v.ErrorMessage", 'Alert : File size cannot exceed ' + component.get("v.MAX_FILE_SIZE") + ' bytes.\n' + ' Selected file size: ' + uploadedFiles[i].size);
                     return;
        		 }
                
                lstDocumentId.push(uploadedFiles[i].documentId);
                component.set("v.ContentVersionId", uploadedFiles[i].documentId);
            }
        }
      
        if(component.get("v.IsDocketing")==true){
            helper.getDocketingActivityUploadedAttachmentToiManageDetails(component);
        } else {
        	helper.getUploadedAttachmentToiManageDetails(component);    
        }
        
        
        helper.getFinishedAttachmentDetails(component);
       
          
        
      
    },
    
   
    OnAttachmentUpload: function(component,event,helper){
        helper.getUploadedAttachmentToiManageDetails(component);
    },
    
   OnAttachmentSync: function(component,event,helper){
        var EnvelopeId = event.getSource().get("v.value");
        component.set("v.ContentVersionId",EnvelopeId);
        helper.getUploadedDocumentToiManageDetails(component);
    },

    
    OnUpload: function(component,event,helper){
        helper.getFinishedAttachmentDetails(component);
        component.set('v.IsShow',true);
    },
    
    OnSyncFolderDocuments: function (component, event, helper)  {
        
        helper.SyncSubFolder(component);
        helper.SyncFolderDocuments(component);
        
        //helper.getDocumentUserssHelper(component);  
        helper.getdoctypeshelper(component);  
        helper.getAllUploadedFiles(component);
        helper.getEmails(component);
        
        
    },
    
    handleCollaborationCheckboxChange: function(component, event, helper) {
        var selectedItems = component.get("v.selectedItems");
        var selectedItemId = event.getSource().get("v.value");
        
        if (event.getSource().get("v.checked")) {
            if (!selectedItems.includes(selectedItemId)) {
                selectedItems.push(selectedItemId);
            }
        } else {
            var index = selectedItems.indexOf(selectedItemId);
            if (index > -1) {
                selectedItems.splice(index, 1);
            }
        }
        
        
        if(selectedItems.length>=1) { 
        	component.set("v.IsCollaboration", true);    
        } else {
            component.set("v.IsCollaboration", false);    
        }
        
        
        component.set("v.selectedfielsItems", selectedItems.join(','));
        component.set("v.selectedItems", selectedItems);
        
        //alert(component.get("v.selectedfielsItems"));
    },
    
    handleCheckboxChange: function(component, event, helper) {
        var selectedItems = component.get("v.selectedItems");
        var selectedItemId = event.getSource().get("v.value");
        
        if (event.getSource().get("v.checked")) {
            if (!selectedItems.includes(selectedItemId)) {
                selectedItems.push(selectedItemId);
            }
        } else {
            var index = selectedItems.indexOf(selectedItemId);
            if (index > -1) {
                selectedItems.splice(index, 1);
            }
        }
        
        
        if(selectedItems.length>1) { 
        	component.set("v.IsMultiEmailDocument", true);    
        } else {
            component.set("v.IsMultiEmailDocument", false);    
        }
        
        
        component.set("v.selectedfielsItems", selectedItems.join(','));
        component.set("v.selectedItems", selectedItems);
    },
    
    
     OnPreviewEmailDocument: function (component, event, helper) {
         var EnvelopeId = event.getSource().get("v.value");
    	 var recid =  event.target.id;
		$A.get('e.lightning:openFiles').fire({
		    recordIds: [EnvelopeId]
		});
         
         
    },
    
     OnSyncSubFolderDocuments: function (component, event, helper)  {
        var EnvelopeId = event.getSource().get("v.value");
        //alert('OnSyncSubFolderDocuments EnvelopeId' + EnvelopeId);
        
        helper.SyncSubFolderDocumentsFuture(component,EnvelopeId);
        helper.SyncSubFolderDocuments(component,EnvelopeId);
        
        
    },
    
  
    
    statusChange : function (component, event, helper) {
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
    		component.set('v.IsNewOCRecommendations',false);
            helper.getData(component);
        } 
    },
    
  OnCancel: function(component, event, helper) {
   	component.set('v.IsShow',false);
    component.set('v.IsNew',false);
    component.set('v.IsNewOCRecommendations',false);
  },
    
    

  OnReassign: function(component, event, helper) {
      //alert(component.get("v.Recommendations"));
   component.set('v.IsNewOCRecommendations',true);
      var Variables = [
          {
              name : 'iPatent',
              type : 'String',
              value : component.get("v.recordId")
          },
          {
              name : 'IsReassignCaseType',
              type : 'Boolean',
              value : component.get("v.IsReassignCaseType")
          }
      ];
      var flowData = component.find("FlowRecommendation");
      flowData.startFlow('Related_Case',Variables);
      
  },
    
  OnNewOCRecommendations: function(component, event, helper) {
      //alert(component.get("v.Recommendations"));
   var IsReassignCaseType=component.get("v.IsReassignCaseType");
   IsReassignCaseType=false;    
   component.set('v.IsNewOCRecommendations',true);
      var Variables = [
          {
              name : 'iPatent',
              type : 'String',
              value : component.get("v.recordId")
          },
          {
              name : 'IsReassignCaseType',
              type : 'Boolean',
              value : IsReassignCaseType
          }
      ];
      var flowData = component.find("FlowRecommendation");
      flowData.startFlow('Related_Case',Variables);
      
  },
  
 
    handleRowAction: function ( component, event, helper ) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var recId = row.Id;
        switch (action.name) {
            case 'download':
                
                if(row.ContentVersionId__c!='' && row.ContentVersionId__c!=null){
                    window.open('/sfc/servlet.shepherd/version/download/' + row.ContentVersionId__c);
                } else {
                    helper.OnDownloadDocuments(component, row.id__c);
                }
                
                break;
            case 'delete':
                //alert('Showing download: ' + JSON.stringify(row));
                component.set('v.IsDeleted',true);
                component.set('v.iManageDocumentId',row.id__c);
                break;
           
           case 'preview':
                
                if(row.ContentVersionId__c!='' && row.ContentVersionId__c!=null){
                    helper.OnPreview(component, row.ContentVersionId__c);
                } else {
                    helper.OnPreviewDocuments(component, row.id__c);
                }
                
                
                break;
                
        }
       
    },
    

   
    
    OnDeletedDocumentsCtrl: function (component, event, helper) {
      helper.OnDeletedDocuments(component,component.get('v.iManageDocumentId'));
    },
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },

    
    onNext: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onPrev: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onFirst: function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onLast: function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.setPageDataAsPerPagination(component);
    },
 
    onPageSizeChange: function(component, event, helper) {        
        helper.preparePagination(component, component.get('v.filteredData'));
    },
 
    onChangeSearchPhrase : function (component, event, helper) {
        if ($A.util.isEmpty(component.get("v.searchPhrase"))) {
            let allData = component.get("v.allData");
            component.set("v.filteredData", allData);
            helper.preparePagination(component, allData);
        }
    },
 
    handleSearch : function (component, event, helper) {
        helper.searchRecordsBySearchPhrase(component);
    },
})