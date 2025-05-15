({
    
    PreviewFile: function(cmp, event, helper) {
       var recid =  event.target.id;
		$A.get('e.lightning:openFiles').fire({
		    recordIds: [recid]
		});
    },
    
    startEdit : function(component, event, helper) {
        component.set("v.isEditing", true);
    },
    cancelEdit : function(component, event, helper) {
        component.set("v.isEditing", false);
        // Optionally revert to the original value if needed
    },
    
    saveInput : function(component, event, helper) {
        //alert(JSON.stringify(component.get("v.objSupplimentalAttachments")));
        helper.EditDocumentAttachmentsHelper(component, component.get("v.objSupplimentalAttachments"));
    },
    
     deleteAttachmentsController : function(component,event, helper)  {
        
        var msg ='Are you sure you want to delete this item?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
        	var contentVersionId = event.getSource().get("v.value");
            //alert('contentVersionId ' + contentVersionId);
            
        	helper.deleteDocumentAttachmentsHelper(component, contentVersionId);
    	}
        
    },
    
    loadEnvelopesController : function(component,event, helper) {
        component.set("v.IsMultipleSignature",true);
        var IsPatent =component.get('v.IsPatent');
        component.set('v.vPatent',IsPatent);
        var patentId = component.get('v.recordId');
        var IsAdmin =component.get('v.IsAdmin');
        if (IsAdmin == true){
            helper.ValidateDocuSignFields(component,event,helper); 
            helper.loadEnvelopesHelper(component, patentId);
        	helper.getSupplimentalAttachmentsHelper(component, patentId);
        }
       
        helper.FetchData(component, patentId);
        
		if (IsAdmin == true){
        	helper.objDocuSignedAttachmentsHelper(component, patentId);
            helper.getIsReviewBeforeSend(component);
        }
        if (IsAdmin != true){
            component.set('v.sectionhide',false);
            component.set('v.sectionshow',true);
        }
    },
  
    OnIsInnovators: function(component, event, helper) {
        
        var selectedRec = event.getSource().get("v.value");
        var Checked = event.getSource().get("v.checked");
        component.set("v.IsInnovators", Checked);
        
        //alert('DocketNumber ' + component.get("v.DocketNumber"));
        //alert('FilingDate ' + component.get("v.FilingDate"));
        //alert('Application ' + component.get("v.Application"));
        
         if(Checked==true){
            helper.Manualsave(component,'Title__c',component.get("v.Title"));
            helper.Manualsave(component,'Application_No__c',component.get("v.Application"));
            helper.Manualsave(component,'DocketNo__c',component.get("v.DocketNumber"));
            
            if(component.get("v.FilingDate")!=''){
            	helper.ManualDatesave(component,'Filing_Date__c',component.get("v.FilingDate"));    
            }
            
        }
        
        //alert(Checked);
     
    },
 
    OnIsTitle: function(component, event, helper) {
        
        var Checked = event.getSource().get("v.checked");
        component.set("v.IsTitle", Checked);
        //alert('DocketNumber ' + component.get("v.DocketNumber"));
        //alert('FilingDate ' + component.get("v.FilingDate"));
        //alert('Application ' + component.get("v.Application"));
        
        if(Checked==true){
            helper.Manualsave(component,'Title__c',component.get("v.Title"));
            helper.Manualsave(component,'Application_No__c',component.get("v.Application"));
            helper.Manualsave(component,'DocketNo__c',component.get("v.DocketNumber"));
            
            if(component.get("v.FilingDate")!=''){
            	helper.ManualDatesave(component,'Filing_Date__c',component.get("v.FilingDate"));    
            }
            
        }
        
        //alert(Checked);
     
    },
    
    onChangeTitle: function(component, event, helper) { 
        var textarea = component.find("txtTitle").get("v.value");
        helper.Manualsave(component,'Title__c',textarea);
    },
    
    OnApplication: function(component, event, helper) { 
        var textarea = component.find("txtApplication").get("v.value");
        helper.Manualsave(component,'Application_No__c',textarea);
    },
    
    OnFilingDate: function(component, event, helper) { 
        var textarea = component.find("txtApplicationDate").get("v.value");
        helper.ManualDatesave(component,'Filing_Date__c',textarea);
    },
    
    OnDocuSelected: function(component, event, helper) {
        
        var selectedRec = event.getSource().get("v.value");
        var Checked = event.getSource().get("v.checked");
        //alert('selectedRec ' + selectedRec);
        
        if (Checked == true){
           helper.SelectDocuSignedFromFiles(component, selectedRec, component.get('v.recordId')); 
        } else {
           helper.DeletedDocuSignedId(component, selectedRec, component.get('v.recordId'));
        }
        /*
        var selectedInventorId = selectedRec;
        var InventorID=selectedInventorId;
        
        if (Checked == true){
             var arrSelectedInventorIdsValue = component.get("v.arrSelectedInventorIds");
             arrSelectedInventorIdsValue.push(selectedInventorId);
        	 component.set("v.arrSelectedInventorIds", arrSelectedInventorIdsValue);
             component.set("v.strSelectedInventorIds", arrSelectedInventorIdsValue.join(","));
        } else {
            var arrSelectedInventorIdsValue = component.get("v.arrSelectedInventorIds");
			var index = arrSelectedInventorIdsValue.indexOf(selectedInventorId);
        	if (index > -1) {
  				arrSelectedInventorIdsValue.splice(index, 1);
			}
            component.set("v.arrSelectedInventorIds", arrSelectedInventorIdsValue);
            component.set("v.strSelectedInventorIds", arrSelectedInventorIdsValue.join(","));
        }
     */
        
      
    },
    
    OnSignature: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        var Checked = event.getSource().get("v.checked");
        if (Checked == true){
           component.set("v.IsMultipleSignature",true);
        } else {
           component.set("v.IsMultipleSignature",false);
        }
    },
    
     OnEnvelopePreview: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        var Checked = event.getSource().get("v.checked");
        if (Checked == true){
           component.set("v.IsPreview",true);
           component.set("v.IsEnvelopPreview","created"); 
        } else {
           component.set("v.IsPreview",false);
           component.set("v.IsEnvelopPreview","sent");   
        } 
    },
    
    OnDocuSigned: function(component, event, helper) {
        
        var selectedRec = event.getSource().get("v.value");
        var Checked = event.getSource().get("v.checked");
        
        if (Checked == true){
           helper.SelectDocuSignedId(component, selectedRec, component.get('v.recordId')); 
        } else {
           helper.DeletedDocuSignedId(component, selectedRec, component.get('v.recordId'));   
        }
      
        
       
    },
    
    handleSort : function(component,event,helper){
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
   
  OnEmailSection: function(component, event, helper) {
   		var showsec=component.get("v.IsEmailShow");
        if(showsec===false){
            component.set("v.IsEmailShow",true); 
        } else {
            component.set("v.IsEmailShow",false); 
        }
      	
  },
 
     OnEmailReminderSection: function(component, event, helper) {
   		var showsec=component.get("v.IsReminder");
        if(showsec===false){
            component.set("v.IsReminder",true); 
        } else {
            component.set("v.IsReminder",false); 
        }
      	
  },
 	
        
  updatescetion: function(component, event, helper) {
   	helper.OnSection (component, event, helper);
  },
 
  OnupdateStepOne: function(component, event, helper) {
   	
        var showsec=component.get("v.StepOneShow");
        if(showsec===false){
            component.set("v.StepOneShow",true); 
            component.set("v.StepOnehide",false);
        } else {
            component.set("v.StepOneShow",false); 
            component.set("v.StepOnehide",true); 
        }
      
  },
 
    
    
    
    
     OnInstructional: function(component, event, helper) { 
        var textarea = component.find("textInstructional").get("v.value");
        helper.Manualsave(component,'DocuSign_Instructional_text_to_innovator__c',textarea);
        component.set("v.Instructional",textarea);
       
    },
    
    
    
     OnupdateStepTwo: function(component, event, helper) {
   	
        var showsec=component.get("v.StepTwoShow");
        if(showsec===false){
            component.set("v.StepTwoShow",true); 
            component.set("v.StepTwohide",false);
        } else {
            component.set("v.StepTwoShow",false); 
            component.set("v.StepTwohide",true); 
        }
      
  },
    
    OnupdateStepThree: function(component, event, helper) {
   	
        var showsec=component.get("v.StepThreeShow");
        if(showsec===false){
            component.set("v.StepThreeShow",true); 
            component.set("v.StepThreehide",false);
        } else {
            component.set("v.StepThreeShow",false); 
            component.set("v.StepThreehide",true); 
        }
      
  },
    
    
     reloadEnvelopesDocumentController : function(component,event, helper) {
        var patentId = event.getSource().get("v.value");
        console.log('PatentId - '+patentId);
        //alert(patentId);
        component.set('v.isStatusDisabled',true);
        component.set('v.enveId',patentId);
        helper.EnvDocumentexecuteBatch(component,event);
    },
    
    reloadEnvelopesController : function(component,event, helper) {
        var patentId = component.get('v.recordId');
        console.log('PatentId - '+patentId);
        component.set('v.isStatusDisabled',true);
        helper.executeBatch(component,event);
    },
    
     reloadEnvelopesStatusController : function(component,event, helper) {
        var patentId = event.getSource().get("v.value");
        console.log('PatentId - '+patentId);
        component.set('v.isStatusDisabled',true);
        component.set('v.enveId',patentId);
        helper.EnvStatusexecuteBatch(component,event);
    },
    
    rerequestForSignController : function(component,event, helper) {
        component.set('v.isModalOpen',true);
    },
    
     ExpandtooltipHeaderNote: function(component, event, helper) {
         component.set("v.tooltipHeaderNote",true);
    },
    CollapsetooltipHeaderNote: function(component, event, helper) {
         component.set("v.tooltipHeaderNote",false);
    },
    
  
    
    
    
    OnReviewDocusign : function(component,event, helper) { 
        
           component.set("v.IsPreview",true);
           component.set("v.IsEnvelopPreview","created");
           component.set('v.IsValidating',false);
       	   var IsError='';
        
        if(component.get("v.ReminderDelay") == null || component.get("v.ReminderDelay") =='' || component.get("v.ReminderDelay") == undefined) {
            IsError='Error';
        }
        
        if(component.get("v.ReminderFrequency") == null || component.get("v.ReminderFrequency") =='' || component.get("v.ReminderFrequency") == undefined) {
            IsError='Error';
        }
        
        if(component.get("v.ExpireAfter") == null || component.get("v.ExpireAfter") =='' || component.get("v.ExpireAfter") == undefined) {
            IsError='Error';
        }
        
        if(component.get("v.ExpireWarn") == null || component.get("v.ExpireWarn") =='' || component.get("v.ExpireWarn") == undefined) {
            IsError='Error';
        }
        
        
    if(IsError=='') {
        helper.UnSelectedPatentInventor(component, component.get('v.recordId'));
        var contentVersionUpdate = component.get('v.strSelectedInventorIds');
        if(component.get("v.strSelectedInventorIds") != null && component.get("v.strSelectedInventorIds") != undefined) {
            helper.ContentVersionUpdate(component, component.get('v.strSelectedInventorIds'), 'DocuSign');
        }
        
        
        helper.getemailbody(component);
        var rows=component.get('v.emailBody'); 
        component.set('v.emailBody',rows);
        
        console.log('emailBody'+ component.get('v.emailBody'));
        var patentId = component.get('v.recordId');
        component.set('v.isDisabled',true);
        component.set("v.IsReview",true);
        
        
        helper.SelectPatentInventor(component, component.get('v.InnovatorsIds'));
        helper.MultipleSignHelper(component, patentId);
        helper.FetchData(component, patentId);
       
          	
        	try {
            var interval = window.setInterval(
                $A.getCallback(function() {
                    if(component.get('v.IsValidating')==true){
                        component.set('v.IsValidatingProgress',false);
                        component.set("v.isPreviewModalOpen", false);
                        component.set('v.IsbatchInstanceId',false);
                        component.set("v.IsReview",false);
                        clearInterval(interval);
                    } else {
        				helper.OnDocuSignReviewHelper(component,component.get('v.EnvelopPreviewId')); 
                    }
                }), 9000 
            );
                
        	} catch(e) {
    			console.error(e);
			}
        
        }
        
        
        
    },
    
   OnReminder: function(component, event, helper) {
        var envelopeId = event.getSource().get("v.value");
        component.set("v.IsReminderShow",true);  
        component.set("v.envelopeId",envelopeId);  
        helper.GetReminder(component);
    },
    
      requestReminderForSignController : function(component,event, helper) {
         var IsError='';
        
        if(component.get("v.ReminderDelay") == null || component.get("v.ReminderDelay") =='' || component.get("v.ReminderDelay") == undefined) {
            IsError='Error';
        }
        
        if(component.get("v.ReminderFrequency") == null || component.get("v.ReminderFrequency") =='' || component.get("v.ReminderFrequency") == undefined) {
            IsError='Error';
        }
        
        if(component.get("v.ExpireAfter") == null || component.get("v.ExpireAfter") =='' || component.get("v.ExpireAfter") == undefined) {
            IsError='Error';
        }
        
        if(component.get("v.ExpireWarn") == null || component.get("v.ExpireWarn") =='' || component.get("v.ExpireWarn") == undefined) {
            IsError='Error';
        }
        
        
        if(IsError=='') {
            helper.MultipleSignReminderHelper(component, component.get('v.envelopeId'));
            
        }
        
    },
    
    requestForSignController : function(component,event, helper) { 
        
        if (component.get('v.InnovatorsIds') == '') {
          	alert('Please select atleast one Innovator !');
            return false;
        }
      
       
           component.set("v.IsPreview",false);
           component.set("v.IsEnvelopPreview","sent");   
       
        helper.UnSelectedPatentInventor(component, component.get('v.recordId'));
        var contentVersionUpdate = component.get('v.strSelectedInventorIds');
        if(component.get("v.strSelectedInventorIds") != null && component.get("v.strSelectedInventorIds") != undefined) {
            helper.ContentVersionUpdate(component, component.get('v.strSelectedInventorIds'), 'DocuSign');
        }
        
        
        helper.getemailbody(component);
        var rows=component.get('v.emailBody'); 
        component.set('v.emailBody',rows);   
        console.log('emailBody'+component.get('v.emailBody'));
        var patentId = component.get('v.recordId');
        component.set('v.isDisabled',true);
        component.set("v.isPreviewModalOpen", false);
        component.set('v.IsValidatingProgress',false);
        component.set('v.IsValidating',true);
        component.set("v.IsReview", true);
        
        helper.SelectPatentInventor(component, component.get('v.InnovatorsIds'));
        
        if(component.get('v.IsMultipleSignature')==false){
        		helper.requestForSignHelper(component, patentId); 
             	helper.FetchData(component, patentId);
        } else {
        		helper.MultipleSignHelper(component, patentId);
             	helper.FetchData(component, patentId);
        }
        
       
        component.set('v.IsValidatingProgress',false);
        component.set('v.IsValidating',true);
        component.set("v.IsReview", false);
        
    },
    
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    
    OnSent: function(component, event, helper) {
       var patentId = component.get('v.recordId');
       var EnvelopeId = event.getSource().get("v.value");
        console.log('PatentId - '+patentId);
        component.set('v.isStatusDisabled',true);
        helper.executeEnvelopeIdBatch(component, event, patentId, EnvelopeId);
    },
   
   OnDeleted: function(component, event, helper) {
        var patentId = component.get('v.recordId');
        var EnvelopeId = event.getSource().get("v.value");
        //alert(EnvelopeId);
       
        var msg ='Are you sure you want to delete this DocuSign Envelope?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
       	 	helper.UpdateDocuSignRecords(component,'Status__c','Cancelled',EnvelopeId);
        	helper.FetchData(component);
      }
    },
    
    
    
    OnCertificate : function(component,event,helper) {
        var EnvelopeId = event.getSource().get("v.value");
        var patentId = component.get('v.recordId');
        
        var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"type": "success",
                    	"title": "Success!",
                    	"message": "The Job has been successfully initiated."
                	});
                	toastEvent.fire();
        
        helper.VewCertificate(component, helper, patentId,EnvelopeId);
        
	},
    
    ViewDocuments: function(component, event, helper) {
        // Set isModalOpen attribute to true
        //component.set("v.isModalOpen", true);
    },
    
    OnCreated : function(component,event,helper) {
        var EnvelopeId = event.getSource().get("v.value");
        var patentId = component.get('v.recordId');
        helper.VewRequestHelper(component, helper, patentId,EnvelopeId);
        
	},
    
    OnReSend : function(component,event,helper) {
        var EnvelopeId = event.getSource().get("v.value");
        var patentId = component.get('v.recordId');
        helper.ReSendRequestHelper(component, helper, patentId,EnvelopeId);
        
	},
    
    
   
    OnDocuments : function(component,event,helper) {
      var action = component.get('c.getEnvelopeDocuments');
        var envelopeid ='7b50558d-73ba-43d2-94c8-b735bc14edfb';
        var documentId = '1';
        var envelopeSFId='a3r030000004ZvyAAE';
        var fileName='Assignment.pdf';
        
        action.setParams({ 'envelopeId' : envelopeid,
                          'envelopeSFId' : envelopeSFId,
                          'documentId' : documentId,
                          'fileName' : fileName});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    alert(rows);
                } 
                else if (state === "ERROR") 
                {
                    var errors = response.getError();
                    //alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
	},
    
    OpenViewModel: function(component, event, helper) {
        var envelopeid=component.get('v.venvelopeId');
        var patentId = component.get('v.recordId');
        helper.VewRequestHelper(component, helper, patentId,envelopeid);
    },
    
    OnBack: function(component, event, helper) {
       component.set('v.IsbatchInstanceId',false);
    },
    
    openPreviewModel: function(component, event, helper) {
        
        if (component.get('v.InnovatorsIds') == '') {
          	alert('Please select atleast one Innovator !');
            return false;
        }
        
        if (component.get('v.FilingDate') == '' && component.get('v.Application') != '') {
            return false;
        }
        
        if (component.get('v.Application') == '' && component.get('v.FilingDate') != '') {
            return false;
        }
        
		helper.getemailbody(component);
        helper.GetReminder(component);
        
        var rows=component.get('v.emailBody');
        component.set('v.emailBody',rows);
        component.set("v.isPreviewModalOpen", true);
    },
    
    OnIsbatchInstanceId: function(component, event, helper) {
       
        	// Set isModalOpen attribute to false  
        	component.set("v.isModalOpen", false);
            component.set('v.IsbatchInstanceId',false);
        	// Set isPreviewModalOpen attribute to false  
        	component.set("v.isPreviewModalOpen", false);
        	component.set('v.IsValidating',true);
        	component.set('v.IsValidatingProgress',false);
        	component.set("v.IsReview",false);    
       
    },
    
    closeReminerModel: function(component, event, helper) {
       component.set("v.IsReminderShow", false);
            
    },
    
    closeModel: function(component, event, helper) {
        //alert('InnovatorsIds' + component.get('v.InnovatorsIds'));
        
        if(component.get('v.IsValidating')==false){
            component.set('v.IsbatchInstanceId',true);
        } else {
        	// Set isModalOpen attribute to false  
        	component.set("v.isModalOpen", false);
            component.set("v.IsReminderShow", false);
            component.set('v.IsbatchInstanceId',false);
        	// Set isPreviewModalOpen attribute to false  
        	component.set("v.isPreviewModalOpen", false);
        	component.set('v.IsValidating',true);
        	component.set('v.IsValidatingProgress',false);
        	component.set("v.IsReview",false);    
        }
        
        
        
           
            
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        var patentId = component.get('v.recordId');
        component.set('v.isReDisabled',true);
        component.set('v.showNote',false);
        helper.rerequestForSignHelper(component, helper, patentId);
        component.set("v.isModalOpen", false);
    },
    
    getEnvelopeStatusController : function(component,event, helper) {
        var EnvelopeId = event.getSource().get("v.value");
        helper.getEnvelopeStatusHelper(component, EnvelopeId);
    },
    /*getAllEnvelopesStatusController : function(component,event, helper) 
    {
        var patentId = component.get('v.recordId');
        helper.getAllEnvelopesStatusHelper(component, patentId);
    },*/
    getEnvelopeAttachmentsController : function(component,event, helper) {
        var EnvelopeId = event.getSource().get("v.value");
        helper.getEnvelopeAttachmentsHelper(component, EnvelopeId);
        //alert(EnvelopeId);
    }
})