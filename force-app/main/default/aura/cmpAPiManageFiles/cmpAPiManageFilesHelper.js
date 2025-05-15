({
    
    UpdateEmailSubject : function (component, DocumentId) {
        component.set("v.isLoading", true);
        //alert(component.get("v.EmailsSubject"));
        
        var action = component.get("c.UpdateEmailSubject");
        action.setParams({ 'PatentId' : DocumentId,
                           'DocumentName' : component.get("v.EmailsSubject") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows=='success') {
                	component.set("v.IsEmailsSubject", false);
                	var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected Email Subject has been updated successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
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
            
            $A.get('e.force:refreshView').fire();
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
    ContentVersionRenamed : function (component, DocumentId) {
        component.set("v.isLoading", true);
        //alert(component.get("v.EmailDocumentsName"));
        
        var action = component.get("c.UpdateDocumentsTitle");
        action.setParams({ 'PatentId' : DocumentId,
                           'DocumentName' : component.get("v.EmailDocumentsName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows=='success') {
                	component.set("v.IsEmailsEditing", false);
                	var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document renamed successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
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
            
            $A.get('e.force:refreshView').fire();
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
   
       DocumentRenamed : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.DocumentsRenamed");
        action.setParams({ 'PatentId' : DocumentId,
                           'DocumentName' : component.get("v.iManagedDocumentsName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows=='success') {
                	component.set("v.IsiMngEditing", false);
                	var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document renamed successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
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
            
            $A.get('e.force:refreshView').fire();
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
     getEmailUploaded : function (component, DocumentId) {
        var action = component.get("c.EmailsDocuSignUpload");
        action.setParams({ 'PatentId' : DocumentId,
                           'recordId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
               
                if(rows=='Success') {
                	var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document uploading to iManage initiated successfully',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
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
         });
         $A.enqueueAction(action);
    },
    
    getSDocuDetails : function (component, DocumentId) {
        var action = component.get("c.getSDocuDetails");
        action.setParams({ 'PatentId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                component.set('v.tableData',rows);
            } else {
                component.set('v.tableData',null);
            }   
         });
         $A.enqueueAction(action);
    },
    
    getDocuSignDetails : function (component, DocumentId) {
        var action = component.get("c.getDocuSignDetails");
        action.setParams({ 'PatentId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                component.set('v.tableData',rows);
            } else {
                component.set('v.tableData',null);
            }   
         });
         $A.enqueueAction(action);
    },
    
    getWorkSpaceDetails : function (component, event, helper) {
        var action = component.get("c.getWorkspaceId");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows.length>0) { 
                  for (var i = 0; i < rows.length; i++) {
                     var row = rows[i];
                     component.set('v.WorkspaceName',row.name__c);
                     component.set('v.WorkspaceId',row.id__c);
                  }
					this.getFolderDetails(component);  
                }
            }
         });
         $A.enqueueAction(action);
         
    },
    
    getFinishedAttachmentDetails : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getFinishedAttachmentDetails");
        action.setParams({ 'PatentId' : component.get("v.iManageFoldersId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set("v.objAttachments", rows);
                
                 if(rows.length>0) { 
                  for (var i = 0; i < rows.length; i++) {
                     var row = rows[i];
                     component.set('v.ContentVersionId',row.ContentDocumentId);
                  }
                }
                
            }
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
    DocumentCheckIn : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.DocumentsCheckIn");
        action.setParams({ 'PatentId' : DocumentId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows=='success') {
                	var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document check-out successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
                    this.getDocumentDetailsHelper(component,component.get('v.iManageDocumentId'));
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
            
            $A.get('e.force:refreshView').fire();
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
   DocumentCheckOut : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.DocumentsCheckOut");
        action.setParams({ 'PatentId' : DocumentId,
                           'comments' : component.get("v.DocumentCheckOutComment"),
                           'due_date' : component.get("v.DocumentCheckOutDueDate") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows=='success') {
                	component.set("v.IsCheckOut", false);
                	var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document check-out successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
                    this.getDocumentDetailsHelper(component,component.get('v.iManageDocumentId'));
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
            
            $A.get('e.force:refreshView').fire();
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
    getemaildocmoveHelper : function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.EmailAttachedMoveToiManage");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'destinationId' : component.get("v.iManageSelectedEmailAttachmentId"),
                           'documentsId' : component.get("v.EmailContentVersionId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 //alert('getemaildocmoveHelper ' + rows);
                
                if(rows=='success'){
                    component.set('v.ObjDocumentDetail',null);
                    this.getEmailsDetailsHelper(component,component.get("v.iManagedEmailId"));
                    this.getEmailsAttachmentsHelper(component,component.get("v.iManagedEmailId"));
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document moved successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire();  
                    component.set('v.IsEmailAttachedMoved',false);
                    
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
                 
            } else {
            	component.set("v.isLoading", false);    
            }
            component.set("v.isLoading", false); 
         });
         $A.enqueueAction(action);
         
    },
    
     getSelectedEmailsDetails : function (component, DocumentId) {
        var action = component.get("c.getiManageEmailsDetail");
        action.setParams({ 'PatentId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                component.set('v.tableData',rows);
                component.set('v.IsiManageDocumentId',true);
            } else {
                component.set('v.tableData',null);
            }   
         });
         $A.enqueueAction(action);
         
    },
    
     getEmailsDetailsHelper : function (component, DocumentId) {
        var action = component.get("c.getEmailsDetail");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set('v.tableData',rows);
                 component.set('v.IsiManageDocumentId',true);
            }
         });
         $A.enqueueAction(action);
         
    },
     
     getEmailsDetailsByIdHelper : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.getEmailsDetail");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set('v.ObjDocumentDetail',rows);
                 component.set('v.IsiManageDocumentId',true);
            } else {
                component.set("v.isLoading", false);
            }
         component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
     getEmailsAttachmentsHelper : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.getEmailAttachedDocuments");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                
                 component.set('v.ObjDocumentDetail',rows);
                 component.set('v.ObjDocumentDetail',rows);
                 component.set('v.IsiManageDocumentId',true);
               
            }
         component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
    OnEmailsearchRecordsHelper : function(component, event, helper, selectedRecords) {    
        //selectedItems
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        component.set('v.recordsList', []);
        component.set('v.iManageSelectedFolderId','');
        component.set("v.IsiManageSelectedFolderId", false);
        var searchString = component.get('v.searchString');
    	var action = component.get('c.GetEmailLibSearchFolders');
        action.setParams({
            'PatentId' : component.get("v.recordId"),
            'searchString' : searchString
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
                   // alert(JSON.stringify(result));
                    component.set('v.recordsList',result);
        		} 
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(selectedRecords) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        		$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
            
        $A.enqueueAction(action);
	},
    
    searchRecordsHelper : function(component, event, helper, selectedRecords) {    
        
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        component.set('v.recordsList', []);
        component.set('v.iManageSelectedFolderId','');
        component.set("v.IsiManageSelectedFolderId", false);
        var searchString = component.get('v.searchString');
    	var action = component.get('c.GetEmailLibSearchFolders');
        action.setParams({
            'PatentId' : component.get("v.recordId"),
            'searchString' : searchString
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
                   // alert(JSON.stringify(result));
                    component.set('v.recordsList',result);
        		} 
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(selectedRecords) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        		$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
            
        $A.enqueueAction(action);
	},
    
    
    getDocumentUserssHelper : function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.GetLibFolderUsers");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set('v.ErrorMessage',rows);
                if(rows=='Access' && component.get("v.WorkspaceId")!='' && component.get("v.WorkspaceId")!=undefined ){
                	this.getFolderDetails(component);   
                }
            }
         	component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
     getEmailFolderHelper : function (component) {
        component.set("v.isLoading", true);
        component.set("v.IsiManageSelectedEmailId", false);
        var action = component.get("c.GetFolder");
        action.setParams({ 'PatentId' : component.get("v.iManageSelectedEmailAttachmentId"),
                           'recordId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                if(rows=='success'){
                    component.set("v.IsiManageSelectedEmailId", true);
                }
            }
         	component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
     getFolderHelper : function (component) {
        component.set("v.isLoading", true);
        component.set("v.IsiManageSelectedFolderId", false);
        var action = component.get("c.GetFolder");
        action.setParams({ 'PatentId' : component.get("v.iManageSelectedFolderId"),
                           'recordId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                if(rows=='success'){
                    component.set("v.IsiManageSelectedFolderId", true);
                }
            }
         	component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
     getmultidocdownloadHelper : function (component) {
        var selectedfielsItems=component.get("v.selectedfielsItems");
        component.set("v.isLoading", true);
        var action = component.get("c.iManageDocketingEmail");
        action.setParams({ 'PatentId' : component.get("v.iManageEmailObjectId"),
                           'iManageDocumentIds' : selectedfielsItems });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                if(rows=='success'){
                   
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Email send process has been initiated, Please wait or check recipient mailbox.',
            			duration:' 0000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire();  
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
                
                 
            } else {
            	component.set("v.isLoading", false);    
            }
         });
        
         component.set("v.isLoading", false);  
         $A.enqueueAction(action);
         
    },
    
    getmultidocmoveHelper : function (component) {
        //alert('component.get("v.selectedfielsItems") ' + component.get("v.selectedfielsItems") );
        var selectedfielsItems=component.get("v.selectedfielsItems");
        component.set("v.isLoading", true);
        var action = component.get("c.MultiDocMovetoFolder");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'destinationId' : component.get("v.iManageSelectedFolderId"),
                           'documentsId' : component.get("v.iManageDocumentId"),
                           'selectedItems' : selectedfielsItems });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                if(rows=='success'){
                    this.getDataFolderWiseSelected(component);
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document moved successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire();  
                    component.set('v.IsMoved',false);
                    component.set("v.isLoading", false); 
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
                
                 
            } else {
            	component.set("v.isLoading", false);    
            }
         });
        
         component.set("v.isLoading", false);  
         $A.enqueueAction(action);
         
    },
    
    getdocmoveHelper : function (component) {
        //selectedItems
        component.set("v.isLoading", true);
        var action = component.get("c.DocMovetoFolder");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'destinationId' : component.get("v.iManageSelectedFolderId"),
                           'documentsId' : component.get("v.iManageDocumentId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                if(rows=='success'){
                    this.getDataFolderWiseSelected(component);
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Selected document moved successfully.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire();  
                    component.set('v.IsMoved',false);
                    component.set("v.isLoading", false); 
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
                
                 
            } else {
            	component.set("v.isLoading", false);    
            }
         });
        
         component.set("v.isLoading", false);  
         $A.enqueueAction(action);
         
    },
    
    OnDocumentsAccessHelper : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.GetLibDocAccessUsers");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                component.set("v.IsiManagedDocumentAccess", rows);
                if(rows=='full_access'){
                    this.getDocumentDetailsHelper(component, DocumentId);   
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
    
     getDocuSignDocumentDetailsHelper : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.getDocuSignDocumentDetail");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set('v.ObjDocumentDetail',rows);
                 component.set('v.IsDocuSignDocumentId',true);
            }
         component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
    },
    
    getDocumentDetailsHelper : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.getDocumentDetail");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set('v.iManagedDocumentsName',rows[0].name);
                 component.set('v.ObjDocumentDetail',rows);
                 component.set('v.IsiManageDocumentId',true);
            }
         component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
    },
    
    
    getData : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getiManageDocumentDetail");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                component.set('v.tableData',rows);
                
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
     OnCreateiManageFolder : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.CreateNewSubFolder");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'foldername' : component.get("v.iManageNewFolderName"),
                           'createdFolderId' : component.get("v.iManageFoldersId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                
                	var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Folder creation process has been initiated.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
                
                	var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "IManage"
                    });
                    navEvt.fire();
                
                 component.set('v.IsNew',false);
                 this.getFolderDetails(component);
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
    OnPreview : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.OnPreview");
        action.setParams({ 'ContentVersionId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 for (var i = 0; i < rows.length; i++) {
                     var row = rows[i];
                     component.set('v.ContentDocumentId',row.ContentDocumentId);
                     component.set('v.ContentDocumenttitle',row.Title);
                 }
                
                $A.get('e.lightning:openFiles').fire({
                    recordIds: [component.get('v.ContentDocumentId')]
                }); 
                
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
    OnDocumentsMoveAccessHelper : function (component, DocumentId) {
        
        if(component.get("v.IsiManagedDocumentAccess")=='full_access'){
            component.set('v.IsMoved',true); 
        }else {
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
        
    },
    
     OnDownloadDocumentsAccessHelper : function (component, DocumentId) {
        if(component.get("v.IsiManagedDocumentAccess")=='full_access'){
            this.OnDownloadDocuments(component, DocumentId); 
        }else {
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
    },
    
     OnDownloadDocuments : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.DownloadDocuments");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 //window.open('/sfc/servlet.shepherd/version/download/' + rows);
            }
         });
         component.set("v.isLoading", false);
         $A.enqueueAction(action);
    },
    
    OnItemPreviewDocuments : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.DocumentsPreview");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 this.OnPreview(component, rows);
            }
         });
         component.set("v.isLoading", false);
         $A.enqueueAction(action);
    },
    
    OnPreviewDocuments : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.DownloadDocuments");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 this.OnPreview(component, rows);
            }
         });
         component.set("v.isLoading", false);
         $A.enqueueAction(action);
    },
    
     OnDeletedDocuments : function (component, DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.DeletedDocuments");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set('v.IsDeleted',false);
                 this.getData(component);
            }
         });
         $A.enqueueAction(action);
         $A.get('e.force:refreshView').fire();
         component.set("v.isLoading", false);
    },
    
     SyncSubFolder : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.UploadedFolders");
        action.setParams({ 'recordId' : component.get("v.recordId"),
                           'createdFoldername' : component.get("v.createdFolderId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
            }
         });
         component.set("v.isLoading", false);
         $A.enqueueAction(action);
    },
    
     SyncSubFolderDocuments : function (component,DocumentId) {
        var action = component.get("c.SyncSubFolderDocuments");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 this.getDataFolderWiseSelected(component);
            }
         });
         $A.enqueueAction(action);
    },
    
    OnSelectedSyncSubFolderDocuments : function (component,DocumentId) {
        var action = component.get("c.SyncSubFolderDocuments");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
            }
         });
         $A.enqueueAction(action);
    },
    
    OnFolderSelectedSyncSubFolderDocumentsFuture : function (component,DocumentId) {
        var action = component.get("c.SyncSubFolderDocumentsFuture");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
            }
         });
         $A.enqueueAction(action);
    },
    
    SyncSubFolderDocumentsFuture : function (component,DocumentId) {
        var action = component.get("c.SyncSubFolderDocumentsFuture");
        action.setParams({ 'PatentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                this.getSubFolderDetailsAfterSyncd(component);
            }
         });
         $A.enqueueAction(action);
    },
    
    SyncFolderDocumentsAccessHelper : function (component, DocumentId) {
        if(component.get("v.IsiManagedDocumentAccess")=='full_access'){
            this.getDataFolderWiseSelected(component); 
        }else {
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
    },
    

    
    SyncFolderDocuments : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.SyncFolderDocuments");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 this.getData(component);
            }
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
     getDataFolderWiseSelected : function (component, event, helper) {
        //component.set("v.isLoading", true);
        var action = component.get("c.getiManageDocumentFoldersDetail");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'createdFolderId' : component.get("v.createdFolderId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                component.set('v.tableData',rows);
            } else {
                component.set('v.tableData',null);
            }
            
         	//component.set("v.isLoading", false);   
         });
         $A.enqueueAction(action);
         
    },
    
    getSelectedFolderDetails : function (component,DocumentId) {
        component.set("v.isLoading", true);
        var action = component.get("c.getselectedfolder");
        action.setParams({ 'PatentId' : DocumentId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows.length>0) { 
                  for (var i = 0; i < rows.length; i++) {
                     var row = rows[i];
                     component.set('v.createdFolderId',row.id__c);
                     component.set('v.iManageFolderName',row.name__c);
                     component.set('v.iManageFoldersId',row.Id);
                     component.set('v.FolderSyncLastModifiedDate',row.LastModifiedDate);
                      
                  }
                    component.set('v.IsiManageDocumentId',false);
                    this.getDataFolderWiseSelected(component);
                }
               
            }
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
    getSubFolderDetailsAfterSyncd : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getimanagefolder");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                component.set('v.objFolders',rows);
            }
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
    },
    
    getFolderDetails : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getimanagefolder");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                component.set('v.objFolders',rows);
                if(rows.length>0) { 
                  for (var i = 0; i < rows.length; i++) {
                     var row = rows[i];
                     component.set("v.IsiManageFolders", true);
                     component.set('v.WorkspaceName',row.iManage_Workspace__r.name__c);
                     component.set('v.WorkspaceId',row.iManage_Workspace__r.id__c);
                  }
                
                } else {
                  	this.getiManageFolderDetails(component);  
                }
                
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
    getEmails : function (component, event, helper) {
        
        var action = component.get("c.getiManageSetting");
        action.setParams({ 'ParentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                if(items.length>0) {
                     for (var i = 0; i < items.length; i++) {
                          var row = items[i];
                         if(row.IsEmail__c==true){
                         	component.set('v.IsEmails',true);    
                         }
                         if(row.IsDocuSign__c==true){
                         	component.set('v.IsDocuSign',true);    
                         }
                         
                         if(row.IsSDocs__c==true){
                         	component.set('v.IsSDocs',true);    
                         }
                         
                     }
                }
            } 
        });
        $A.enqueueAction(action);
    },
    
    getFolderAfterCreatedDetails : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getimanagefolder");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows.length>0) { 
                  for (var i = 0; i < rows.length; i++) {
                     var row = rows[i];
                     component.set('v.createdFolderId',row.id__c);
                     component.set('v.iManageFolderName',row.name__c);
                     component.set('v.iManageFoldersId',row.Id);
                     component.set('v.FolderSyncLastModifiedDate',row.LastModifiedDate);
                     component.set('v.WorkspaceName',row.iManage_Workspace__r.name__c);
                     component.set('v.WorkspaceId',row.iManage_Workspace__r.id__c);
                  }
                 	this.getData(component);
                } 
                 //alert('iManageFoldersId ' +  component.get('v.iManageFoldersId'));
                 
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
    getiManageFolderDetails : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.SearchNewWorkspace");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                if(rows.length>0 && rows!='' && rows!='Not Found') { 
                  this.getFolderAfterCreatedDetails(component);
                } else {
                  this.getAllUploadedDocument(component);
                }
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "IManage"
                });
                //navEvt.fire();
                
            }
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         $A.get('e.force:refreshView').fire();
    },
    
    getdoctypeshelper: function (component, event) {
        if (component.get("v.doctypevalues") != null) {
            var action = component.get("c.getContentiManageDocument");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set("v.doctypevalues", response.getReturnValue());
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    }
                }

            });
            $A.enqueueAction(action);
        }
    },

    
    
     getUploadDocumentFinished : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.UploadDocumentFinished");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'ContentVersionId' : component.get("v.ContentVersionId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set("v.ObjFiles", rows);
                 //alert('UploadDocumentFinished ' + JSON.stringify(rows));
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
     getAllUploadedDocument : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getAttachedDocuments");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set("v.ObjFiles", rows);
                 //alert('getAttachedDocuments ' + JSON.stringify(rows));
            }
         });
         component.set("v.isLoading", false);
         $A.enqueueAction(action);
         
    },
 
        getUploadedAttachmentToiManageDetails : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.UploadDocument");
        action.setParams({ 'createdFolderId' : component.get("v.createdFolderId"),
                           'ContentVersionId' : component.get("v.ContentVersionId"),
                           'iManageFoldersId' : component.get("v.iManageFoldersId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                
                if(component.get('v.ContentVersionId')==rows){
                    component.set('v.IsShow',false);
                    
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Document uploading process has been initiated.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "IManage"
                    });
                    navEvt.fire();
                    
                } else {
                     this.getData(component);
                    this.getFinishedAttachmentDetails(component);
                }
                
                
            }
            
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
    getUploadedDocumentToiManageDetails : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.UploadDocument");
        action.setParams({ 'createdFolderId' : component.get("v.createdFolderId"),
                           'ContentVersionId' : component.get("v.ContentVersionId"),
                           'iManageFoldersId' : component.get("v.iManageFoldersId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                if(component.get('v.ContentVersionId')==rows){
                    component.set('v.IsShow',false);
                    
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Document uploading process has been initiated.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
                    
                }
                
                 this.getData(component);
                 this.getFinishedAttachmentDetails(component);
            }
            
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
    getUploadDocumentDetails : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.UploadDocument");
        action.setParams({ 'createdFolderId' : component.get("v.createdFolderId"),
                           'ContentVersionId' : component.get("v.ContentVersionId"),
                           'iManageFoldersId' : component.get("v.iManageFoldersId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                if(component.get('v.ContentVersionId')==rows){
                    component.set('v.IsShow',false);
                    
                    var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Document uploading process has been initiated.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
                    
                }
                
                 this.getData(component);
            }
            
            component.set("v.isLoading", false);
         });
         $A.enqueueAction(action);
         
    },
    
     getDocuSignUploadFilesFinished : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.DocuSignUpload");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'ContentVersionId' : component.get("v.ContentVersionId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set("v.ObjFiles", rows);
                
                   var toastEvent = $A.get("e.force:showToast");
        			toastEvent.setParams({
            			title : 'success',
            			message:'Document uploading process has been initiated.',
            			duration:' 5000',
            			key: 'info_alt',
            			type: 'success',
            			mode: 'pester'
        			});
        			toastEvent.fire(); 
                
                
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
    getUploadFilesFinished : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.UploadDocumentFinished");
        action.setParams({ 'PatentId' : component.get("v.recordId"),
                           'ContentVersionId' : component.get("v.ContentVersionId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set("v.ObjFiles", rows);
            }
         });
         $A.enqueueAction(action);
         component.set("v.isLoading", false);
    },
    
     getAllUploadedFiles : function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getAttachedDocuments");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set("v.ObjFiles", rows);
            }
         });
         component.set("v.isLoading", false);
         $A.enqueueAction(action);
         
    },
    
    updaterechelper: function (component, recid, value) {
        var action = component.get('c.updatedoctype');
        action.setParams({
            "recid": recid, "value": value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.getAllUploadedFiles(component);
            }
        });
        $A.enqueueAction(action);

    },
    
    OndeleteDocumentAttachmentsHelper : function(component, contentVersionId) {
		var action = component.get('c.deleteAttachment');
        action.setParams({'contentVersionId' : contentVersionId});
        action.setCallback
        (
            this,
            $A.getCallback
            (
                function (response) 
                {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        this.getFinishedAttachmentDetails(component);
                    } 
                    else if (state === "ERROR") 
                    {
                        var errors = response.getError();
                        //alert(JSON.stringify(response.getError()));
                        console.error(errors);
                    }
                }
            )
        );
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
	},
    
    deleteDocumentAttachmentsHelper : function(component, contentVersionId) {
		var action = component.get('c.deleteAttachment');
        action.setParams({'contentVersionId' : contentVersionId});
        action.setCallback
        (
            this,
            $A.getCallback
            (
                function (response) 
                {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        this.getAllUploadedFiles(component);
                    } 
                    else if (state === "ERROR") 
                    {
                        var errors = response.getError();
                        //alert(JSON.stringify(response.getError()));
                        console.error(errors);
                    }
                }
            )
        );
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
	},
    
      sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.tableData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.tableData", data);
    },
    
 sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    callAction: function (component) {
        component.set("v.isLoading", true);
        return new Promise(
            $A.getCallback((resolve, reject) => {
                const action = component.get("c.GetAssignedDisclosure");
                action.setParams({ recordId : component.get("v.recordId") });
                action.setCallback(this, response => {
                    component.set("v.isLoading", false);
                    const state = response.getState();
                    if (state === "SUCCESS") {
                        return resolve(response.getReturnValue());
                    } else if (state === "ERROR") {
                        return reject(response.getError());
                    }
                    return null;
                });
                $A.enqueueAction(action);
            })
        );
    },
 
    preparePagination: function (component, imagesRecords) {
        let countTotalPage = Math.ceil(imagesRecords.length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },
 
    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let filteredData = component.get('v.filteredData');
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (filteredData[x]) {
                data.push(filteredData[x]);
            }
        }
        component.set("v.tableData", data);
    },
 
    searchRecordsBySearchPhrase : function (component) {
        let searchPhrase = component.get("v.searchPhrase");
        if (!$A.util.isEmpty(searchPhrase)) {
            let allData = component.get("v.allData");
            let filteredData = allData.filter(record => record.CommitteeTitle.includes(searchPhrase));
            component.set("v.filteredData", filteredData);
            this.preparePagination(component, filteredData);
        }
    },
})