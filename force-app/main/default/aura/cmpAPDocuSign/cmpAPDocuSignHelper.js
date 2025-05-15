({
    
      GetReminder : function(component, event, helper) {
        var action = component.get("c.getReminder");
        action.setParams({'recordId': component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                component.set("v.ExpireAfter",rows.ExpireAfter__c);
                component.set("v.ExpireWarn",rows.ExpireWarn__c);
                component.set("v.ReminderDelay",rows.ReminderDelay__c);
                component.set("v.ReminderFrequency",rows.ReminderFrequency__c);
            }
        });
        $A.enqueueAction(action);
    },
    
    
     ValidateDocuSignFields : function(component, event, helper) {
        var action = component.get("c.ValidateDocuSignFields");
        action.setParams({'recordId': component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            //alert(state);
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
            }
        });
        $A.enqueueAction(action);
    },
    
     EditDocumentAttachmentsHelper : function(component, contentVersionId) {
		var action = component.get('c.EditAttachment');
        action.setParams({'attachments' : contentVersionId,
                         'PatentID': component.get("v.recordId") });
        action.setCallback
        (
            this,
            $A.getCallback
            (
                function (response) 
                {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isEditing", false);
                        //this.objDocuSignedAttachmentsHelper(component, component.get("v.recordId"));
                        this.getSupplimentalAttachmentsHelper(component, component.get("v.recordId"));
                        $A.get('e.force:refreshView').fire(); 
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        //alert(JSON.stringify(response.getError()));
                        console.error(errors);
                    }
                }
            )
        );
        $A.enqueueAction(action);
	},
    
    deleteDocumentAttachmentsHelper : function(component, contentVersionId) {
		var action = component.get('c.deleteAttachment');
        action.setParams({'contentVersionId' : contentVersionId,
                         'PatentID': component.get("v.recordId") });
        action.setCallback
        (
            this,
            $A.getCallback
            (
                function (response) 
                {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                        //this.objDocuSignedAttachmentsHelper(component, component.get("v.recordId"));
                        this.getSupplimentalAttachmentsHelper(component, component.get("v.recordId"));
                        $A.get('e.force:refreshView').fire(); 
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        //alert(JSON.stringify(response.getError()));
                        console.error(errors);
                    }
                }
            )
        );
        $A.enqueueAction(action);
	},
    
    sortData: function (component, fieldName, sortDirection) {
        
      var data = component.get("v.Data");
      var reverse = sortDirection !== 'asc';
      data.sort(this.sortBy(fieldName, reverse));
      component.set("v.Data", data);

    },
    
  FetchData : function(component, event, helper) {
        component.set('v.Column', [
            {label: 'Person', fieldName: 'linkName1', type: 'url',  typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, sortable: true,initialWidth: 150},
            {label: 'Email Id', fieldName: 'Email', type: 'text', initialWidth: 200,sortable: true}
        ]);
        
        var action = component.get("c.getEnvelopesInventors");
        action.setParams({'PatentId': component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                component.set('v.Data',rows);
            }
        });
        $A.enqueueAction(action);
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
    
    Manualsave : function (component, fieldApi, fieldValue ){
        var action = component.get("c.UpdateRecord");
        action.setParams({
            "recordId" 		: component.get("v.recordId"),
        	"fieldApi" 		: fieldApi,
        	"fieldvalue" 	: fieldValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
             	//alert('Manualsave ' + result);	
            } 
        });
        $A.enqueueAction(action);
         
    },
    
    ManualDatesave : function (component, fieldApi, fieldValue ){
        var action = component.get("c.UpdateDateRecord");
        action.setParams({
            "recordId" 		: component.get("v.recordId"),
        	"fieldApi" 		: fieldApi,
        	"fieldvalue" 	: fieldValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
             	//alert('ManualDatesave ' + result);	
            }
                      
        });
        $A.enqueueAction(action);
         
    },
    
  UpdateDocuSignRecords : function (component, fieldApi, fieldValue,EnvelopeId ){
     	 //alert(EnvelopeId);
        var action = component.get("c.UpdateDocuSignRecord");
        action.setParams({
            "recordId" 		: EnvelopeId,
        	"fieldApi" 		: fieldApi,
        	"fieldvalue" 	: fieldValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
             //alert(result);	
            }
                      
        });
        $A.enqueueAction(action);
         
    },
    
    OnSection: function(component, event, helper) {
    var showsec=component.get("v.sectionshow");
        if(showsec===false){
            component.set("v.sectionshow",true); 
            component.set("v.sectionhide",false);
        } else {
            component.set("v.sectionshow",false); 
            component.set("v.sectionhide",true); 
        }
    },
    
    loadEnvelopesHelper : function(component, PatentID) {
        var action = component.get('c.getEnvelopes');
        //var PatentID = 'a1x18000000RBQkAAO';
        action.setParams({ 'PatentId' : PatentID });
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.objEnvelopes', result);
                    component.set('v.isReDisabled',false);
                    component.set('v.isStatusDisabled',false);
                    component.set('v.envelopCount', result.length);
                    component.set('v.isDisabled',false);
                    if(result.length > 0) {
                        component.set('v.isRefresh',true);
                        var obj = component.get('v.objEnvelopes');
                        for(var i=0; i< obj.length; i++) {
                            if(obj[i].EnvelopeId__c != null && obj[i].EnvelopeId__c != undefined) {
                                
                                if (obj[i].Status__c == 'created'){
                                    component.set('v.venvelopeId',obj[i].EnvelopeId__c);
                                 }
                                
                                if(obj[i].Error_Occurred__c == true){
                                	component.set('v.showNote',true);
                                }
                            } 
                        }
                    }                    
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
    
    ContentVersionUpdate : function(component, vContentVersionId, vDocuSigned) {
        var action = component.get("c.ContentVersionUpdate");
        action.setParams({'ContentVersionId': vContentVersionId,
                          'DocuSigned': vDocuSigned
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                component.set("v.objSupplimentalAttachments", rows);
            } else if (state === "ERROR") {
                    var errors = response.getError();
                    //alert(JSON.stringify(errors));
                    console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    DeletedDocuSignedId : function(component, vDocuSignedId, vPatentID) {
        var action = component.get("c.DeletedDocuSignedId");
        action.setParams({'DocuSignedId': vDocuSignedId,
                          'PatentID': vPatentID
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                //alert('rows ' + JSON.stringify(rows));
            } else if (state === "ERROR") {
                    var errors = response.getError();
                    //alert('errors ' + errorsJSON.stringify(errors));
                    console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
     SelectDocuSignedFromFiles : function(component, vDocuSignedId, vPatentID) {
        var action = component.get("c.SelectDocuSignedFromFiles");
        action.setParams({'DocuSignedId': vDocuSignedId,
                          'PatentID': vPatentID
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                //alert('rows ' + JSON.stringify(rows));
            } else if (state === "ERROR") {
                    var errors = response.getError();
                    //alert('errors ' + JSON.stringify(errors));
                    console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    SelectDocuSignedId : function(component, vDocuSignedId, vPatentID) {
        var action = component.get("c.SelectDocuSignedId");
        action.setParams({'DocuSignedId': vDocuSignedId,
                          'PatentID': vPatentID
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                //alert('rows ' + JSON.stringify(rows));
            } else if (state === "ERROR") {
                    var errors = response.getError();
                    alert('errors ' + JSON.stringify(errors));
                    console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    UnSelectedPatentInventor : function(component, patentId) {
        
        
        var action = component.get("c.UnSelectedInventors");
        action.setParams({'PatentID': patentId, 'IsPatent': component.get("v.IsPatent") });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                //alert('UnSelectedPatentInventor ' + rows);
            }
        });
        $A.enqueueAction(action);
    },
    
    SelectPatentInventor : function(component, InventorIds) {
        var action = component.get("c.SelectInventors");
        action.setParams({'inventorIds': InventorIds,
                          'PatentID': component.get('v.recordId'),
                           'IsPatent': component.get("v.IsPatent") 
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                //alert('SelectPatentInventor ' + rows);
            }
        });
        $A.enqueueAction(action);
    },
    
    objDocuSignedAttachmentsHelper : function(component, PatentID) {
		var action = component.get('c.GetDocuSigned');
        action.setParams({ 'PatentId' : PatentID });
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    component.set('v.objDocuSignedAttachments', result);
                    //alert(JSON.stringify(result));
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    //alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
	},
    
    getSupplimentalAttachmentsHelper : function(component, PatentID) {
		var action = component.get('c.getSupplimentalAttachments');
        //var PatentID = 'a1x18000000RBQkAAO';
        action.setParams({ 'PatentId' : PatentID });
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    //alert('getSupplimentalAttachments :'+JSON.stringify(response.getReturnValue()));
                    component.set('v.objSupplimentalAttachments', result);
                    var arryAPIValues = [];
                    for (var i = 0; i < result.length; i++) {
                    	var row = result[i];
                        if(row.isChecked == true) {
                            if(row.isFinalDoc != '') {
                               	arryAPIValues.push(row.CVId);
                        		component.set("v.arrSelectedInventorIds", arryAPIValues);
                        		component.set("v.strSelectedInventorIds", arryAPIValues.join(",")); 
                            }
                        }
                	 }  
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    //alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
	},
    
    MultipleSignReminderHelper : function(component, PatentID) {
        
		var action = component.get('c.setReminder');
        action.setParams({ 'recordId' : PatentID, 
                          'ReminderDelay' : component.get('v.ReminderDelay'),
                          'ReminderFrequency' : component.get('v.ReminderFrequency'),
                          'ExpireAfter' : component.get('v.ExpireAfter'),
                          'ExpireWarn' : component.get('v.ExpireWarn')});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS")  {
                    var result = response.getReturnValue();
                    component.set("v.IsReminderShow",false);
                    alert(JSON.stringify(result));
                    
                    		var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"success",
                                "title": "Success!",
                                "message": "Envelope reminder has been intiated successfully"
                            });
                        	toastEvent.fire();
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    alert(JSON.stringify(errors));
                    console.error(JSON.stringify(errors));
                }
            }
        );
        $A.enqueueAction(action);
	},

    
    
    MultipleSignHelper : function(component, PatentID) {
        //alert('MultipleSignHelper ' + component.get('v.IsEnvelopPreview'));
        component.set('v.IsValidatingProgress',true);
        component.set('v.IsPatent',true);
        component.set('v.IsMultipleSignature',true);
        var emailBody = component.get('v.emailBody');
        
        var objSupplimentalAttachments = component.get('v.objSupplimentalAttachments');
        //alert('objSupplimentalAttachments ' + objSupplimentalAttachments);
        
        
		var action = component.get('c.SubmitMultipleSignaturesAPI');
        action.setParams({ 'PatentID' : PatentID, 
                          'SupplimentalAttachments' : objSupplimentalAttachments, 
                          'emailBody' : emailBody,
                          'IsPatent' : component.get('v.IsPatent'),
                          'IsStatus' : component.get('v.IsEnvelopPreview'),
                          'IsMultipleSignatures' : component.get('v.IsMultipleSignature'),
                          'ExpireAfter' : component.get('v.ExpireAfter'),
                          'ExpireWarn' : component.get('v.ExpireWarn'),
                          'ReminderDelay' : component.get('v.ReminderDelay'),
                          'ReminderFrequency' : component.get('v.ReminderFrequency')});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS")  {
                    var result = response.getReturnValue();
                    var patentId = component.get('v.recordId');  
                    //alert(JSON.stringify(result));
                    component.set('v.displayResult', JSON.stringify(result));
                    if (result.split('-')[0]=='Success') {
                        component.set('v.EnvelopPreviewId',result.split('-')[1]);
                        component.set('v.batchInstanceId',result.split('-')[2]);
                        
                      	//alert(component.get('v.batchInstanceId'));
                        
                        this.loadEnvelopesHelper(component, patentId);
                        this.getSupplimentalAttachmentsHelper(component, patentId);
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"success",
                                "title": "Success!",
                                "message": "Envelope request has been intiated successfully"
                            });
                        toastEvent.fire();
                        
                    } else if (result=='01-Attachment') {
                        	component.set('v.isDisabled',false);
                         	component.set('v.IsValidatingProgress',false);
        					component.set('v.IsValidating',true);
        					component.set("v.IsReview", false);
                           var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"error",
                                "duration":"5000",
                                "title": "Error Message!",
                                "message": "Select atleast one Document."
                            });
                        toastEvent.fire();
                        
                    }
                } 
                else if (state === "ERROR") {
                    component.set('v.IsValidatingProgress',false);
                    component.set('v.IsValidating',true);
                    component.set("v.isPreviewModalOpen", false);
                    var errors = response.getError();
                    alert(JSON.stringify(errors));
                    console.error(JSON.stringify(errors));
                }
            }
        );
        $A.enqueueAction(action);
	},
    
	requestForSignHelper : function(component, PatentID) {
        //alert(component.get('v.IsEnvelopPreview'));
        
		var action = component.get('c.submitDocumentForSignatureAPI');
        var objSupplimentalAttachments = component.get('v.objSupplimentalAttachments');
        var emailBody = component.get('v.emailBody');
        action.setParams({ 'PatentID' : PatentID, 
                          'SupplimentalAttachments' : objSupplimentalAttachments, 
                          'emailBody' : emailBody,
                          'IsPatent' : component.get('v.IsPatent'),
                          'IsStatus' : component.get('v.IsEnvelopPreview'),
                          'IsMultipleSignatures' : component.get('v.IsMultipleSignature')});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    var patentId = component.get('v.recordId');                    
                    component.set('v.displayResult', JSON.stringify(result));
                    if (result=='Success') {
                       
                        this.loadEnvelopesHelper(component, patentId);
                        this.getSupplimentalAttachmentsHelper(component, patentId);
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"success",
                                "title": "Success!",
                                "message": "Envelope has been sent successfully"
                            });
                        toastEvent.fire();
                        
                         component.set('v.isDisabled',false);
                         component.set("v.IsReview", false);
                    } else if (result=='01-Attachment') {
                        component.set('v.isDisabled',false);
                        component.set("v.IsReview", false);
                           var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"error",
                                "duration":"5000",
                                "title": "Error Message!",
                                "message": "Select atleast one Document."
                            });
                        toastEvent.fire();
                        
                    }
                } 
                else if (state === "ERROR") 
                {
                    var errors = response.getError();
                    component.set("v.isPreviewModalOpen", false);
                    component.set("v.IsReview", false);
                    //alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
	},
   
    
    getIsReviewBeforeSend : function(component, helper) {
        var IsPatentID='';
        IsPatentID='Patent'; 
        var action = component.get('c.getIsReviewBeforeSend');
        action.setParams({ 'Process' : IsPatentID});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    //alert(rows);
                    component.set('v.IsReviewBeforeSend',rows);
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
    
    getemailbody : function(component, helper) {
        var IsPatentID='';
        IsPatentID='Patent';  
        var action = component.get('c.getemailbody');
        action.setParams({ 'Process' : IsPatentID});
        action.setCallback(this,
            function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    component.set('v.emailBody',rows);
                    //alert(rows);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    //alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
        
    },
    
    
    VewCertificate : function(component, helper, PatentID, envelopeid) {
        var action = component.get('c.getEnvelopecertificates');
        action.setParams({ 'PatentID' : PatentID, 'envelope_id' : envelopeid});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    this.FetchData(component, PatentID);
                 	$A.get('e.force:refreshView').fire();
                } 
                else if (state === "ERROR") 
                {
                    var errors = response.getError();
                    alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
        
    },
   
    ReSendRequestHelper : function(component, helper, PatentID, envelopeid) {
        var action = component.get('c.ReSending');
        var objSupplimentalAttachments = component.get('v.objSupplimentalAttachments');
        action.setParams({ 'envelope_id' : envelopeid});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    var responseVal = JSON.parse(response.getReturnValue());
                    //alert(responseVal.url);
                  	var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams(
                                {
                                    "type":"success",
                                    "title": "Success!",
                                    "message": "Envelope(s) resent successfully"
                                }
                            );
                        toastEvent.fire();
                    
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
   
    OnDocuSignReviewHelper : function(component, EnvelopPreviewId) {
        //alert(EnvelopPreviewId);
        var action = component.get('c.OnDocuSignReview');
        action.setParams({ 'recordId' : EnvelopPreviewId ,
                          'ApexJobId' : component.get('v.batchInstanceId')});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    var responseVal = JSON.parse(response.getReturnValue());
                    
                    if (rows) {
                        
                        try {	
                    	//alert(responseVal.url);
                    	//alert(JSON.stringify(responseVal));
                    	component.set('v.IsValidating',true);
                    	component.set('v.IsValidatingProgress',false);
                    	var eUrl= $A.get("e.force:navigateToURL");
    						eUrl.setParams({
      						"url": responseVal.url
    						});
    					eUrl.fire();
                    	$A.get('e.force:refreshView').fire();
                            
							} catch (e) {
    						console.error(e);
							}
                        
                       
                    }
                    
                } 
                else if (state === "ERROR") {
                    component.set('v.IsValidatingProgress',false);
                    component.set('v.IsValidating',true);
                    component.set("v.isPreviewModalOpen", false);
                    component.set("v.IsReview", false);
                    var errors = response.getError();
                    alert(JSON.stringify(errors));
                    console.error(JSON.stringify(errors));
                }
            }
        );
        $A.enqueueAction(action);
        
        
    },
    
   VewRequestHelper : function(component, helper, PatentID, envelopeid) {
        var action = component.get('c.Sendingview');
        var objSupplimentalAttachments = component.get('v.objSupplimentalAttachments');
        action.setParams({ 'PatentID' : PatentID, 'envelope_id' : envelopeid});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    var responseVal = JSON.parse(response.getReturnValue());
                    //alert(responseVal.url);
                    
                    var eUrl= $A.get("e.force:navigateToURL");
    					eUrl.setParams({
      					"url": responseVal.url
    					});
    				eUrl.fire();
                    
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
    
    rerequestForSignHelper : function(component, helper, PatentID) {
        var action = component.get('c.resubmitDocumentForSignatureAPI');
        //var PatentID = 'a1x18000000RBQkAAO';
        //alert(PatentID);
        var objSupplimentalAttachments = component.get('v.objSupplimentalAttachments');
        action.setParams({ 'PatentID' : PatentID});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    //alert(JSON.stringify(result))
                    component.set('v.displayResult', JSON.stringify(result));
                    if (result=='Success') {
                        this.loadEnvelopesHelper(component, PatentID);
                        
                        
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams(
                                {
                                    "type":"success",
                                    "title": "Success!",
                                    "message": "Envelope(s) deleted successfully"
                                }
                            );
                        toastEvent.fire();
                        
                    }
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
    
    getEnvelopeStatusHelper : function(component, envelopeId) {
		var action = component.get('c.getEnvelopeStatus');
        //var PatentID = 'a1x18000000RBQkAAO';
        action.setParams({ 'envelopeId' : envelopeId });
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    if (result=='Initiated')
                    {
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"success",
                                "title": "Success!",
                                "message": "Getting status is intiated successfully."
                            });
                        toastEvent.fire();
                    }
                    var patentId = component.get('v.recordId');
        			this.loadEnvelopesHelper(component, patentId);
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
    /*pollApex : function(component, patentId, jobID) { 
        console.log('pollApex');
        //this.getJobStatusHelper(component,patentId,jobID);  
        var status = component.get('v.jobStatus');
        console.log('pollApex >'+status);
        //alert(jobID);
        //execute callApexMethod() again after 5 sec each
        if(status !='Completed')
        {
            var pollId = window.setInterval(
                $A.getCallback(function() {                
                    var count = component.get('v.count');
                    count = count+1;
                    component.set('v.count',count);                
                    this.getJobStatusHelper(component,patentId,jobID);
                    console.log(count);
                }), 5000
            );
            $A.enqueueAction(action);
            //console.log(typeof pollId);
            //alert(typeof pollId);
            alert('1:'+component.get('v.pollId')+'>>'+pollId);
            component.set('v.pollId',pollId);
            alert(component.get('v.pollId'));
        }
    },
    getJobStatusHelper : function(component, patentId , jobID) 
    {
        //alert(component.get('v.count'));
        console.log('getJobStatusHelper');
        var action = component.get('c.getJobStatus');
        //var PatentID = 'a1x18000000RBQkAAO';
        action.setParams({ 'batchprocessid' :  jobID});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    console.log('>>'+result);
                    component.set('v.jobMessage','*Batch Process '+result);
                    component.set('v.jobStatus',result);
                    if (result=='Completed')
                    {
                        this.loadEnvelopesHelper(component, component.get('v.recordId'));
                        var pollId = component.get('v.pollId')
                        if(pollId != null)
                        	window.clearInterval(pollId);
                    }
                } 
                else if (state === "ERROR") 
                {
                    var errors = response.getError();
                    alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
	},
    getAllEnvelopesStatusHelper : function(component, patentId) 
    {
		var action = component.get('c.getEnvelopeStatusForAll');
        //var PatentID = 'a1x18000000RBQkAAO';
        action.setParams({ 'PatentID' : component.get('v.recordId') });
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    //alert(result.result);
                    if (result.result=='Initiated')
                    {
                        if(result.batchID!=null)
                        {
                            console.log(result.batchID+'_'+result.result);
                            component.set('v.jobID',result.batchID);
                            component.set('v.jobStatus',result.result);
                            component.set('v.jobMessage','*Batch Process '+result.result);
                            this.pollApex(component, component.get('v.recordId'), result.batchID);
                        }                        	
                        
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"success",
                                "title": "In progress",
                                "message": "Getting status of envelopes job is initiated."
                            });
                        toastEvent.fire();
                    }
                    var patentId = component.get('v.recordId');
                    //setTimeout( $A.getCallback(function() { $A.get('e.force:refreshView').fire(); }), 5000);
        			this.loadEnvelopesHelper(component, component.get('v.recordId'));
                } 
                else if (state === "ERROR") 
                {
                    var errors = response.getError();
                    alert(JSON.stringify(errors));
                    console.error(errors);
                }
            }
        );
        $A.enqueueAction(action);
	},*/
    
    getEnvelopeAttachmentsHelper : function(component, envelopeId) {
        //alert(envelopeId);
		var action = component.get('c.getEnvelopeAttachments');
        //var PatentID = 'a1x18000000RBQkAAO';
        action.setParams({ 'envelopeId' : envelopeId });
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();
                    //(JSON.stringify(result));
                    if (result=='Initiated')
                    {
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"success",
                                "title": "Success!",
                                "message": "Getting status is intiated successfully."
                            });
                        toastEvent.fire();
                    }
                    var patentId = component.get('v.recordId');
        			this.loadEnvelopesHelper(component, patentId);
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
    
    EnvDocumentexecuteBatch : function (cmp,event){
        console.log('executeBatch');
        
        var patentId = cmp.get('v.enveId');
        //alert(patentId);
        
        var action = cmp.get("c.DocuSignSyncedRequest");
        action.setParams({ 'recordId' : patentId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :'+state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The Job has been successfully initiated."
                });
                toastEvent.fire();
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        window.location.reload();
    },
    
    EnvStatusexecuteBatch : function (cmp,event){
        console.log('executeBatch');
        
        var patentId = cmp.get('v.enveId');
        //alert(patentId);
        
        var action = cmp.get("c.getEnvelopeIdStatus");
        action.setParams({ 'PatentID' : patentId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :'+state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The Job has been successfully initiated."
                });
                toastEvent.fire();

                if (state === "SUCCESS"){
                    var interval = setInterval($A.getCallback(function () {
                        var jobStatus = cmp.get("c.getBatchJobStatus");
                        if(jobStatus != null){
                           
                            var jobid = response.getReturnValue().batchID;
                            console.log('Job ID :'+jobid);
                            jobStatus.setParams({ jobID : jobid});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    cmp.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    var progress = cmp.get('v.progress');
                                    cmp.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                	var myJob = cmp.get('v.apexJob');
                                    console.log('>>'+myJob.Status);
                                    if(myJob.Status == 'Completed')
                                    {
                                        console.log('>>>'+myJob.Status);
                                        cmp.set('v.isStatusDisabled',false);
                                        window.location.reload();
                                    }
                                    console.log('>>>>'+myJob.Status);    
                                }
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 2000);
                }
                
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    executeBatch : function (cmp,event){
        console.log('executeBatch');
        
        var patentId = cmp.get('v.recordId');
        var action = cmp.get("c.getEnvelopeStatusForAll");
        action.setParams({ 'PatentID' : patentId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :'+state);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The Job has been successfully initiated."
                });
                toastEvent.fire();

                if (state === "SUCCESS"){
                    var interval = setInterval($A.getCallback(function () {
                        var jobStatus = cmp.get("c.getBatchJobStatus");
                        if(jobStatus != null){
                           
                            var jobid = response.getReturnValue().batchID;
                            console.log('Job ID :'+jobid);
                            jobStatus.setParams({ jobID : jobid});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    cmp.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    var progress = cmp.get('v.progress');
                                    cmp.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                	var myJob = cmp.get('v.apexJob');
                                    console.log('>>'+myJob.Status);
                                    if(myJob.Status == 'Completed')
                                    {
                                        console.log('>>>'+myJob.Status);
                                        cmp.set('v.isStatusDisabled',false);
                                        window.location.reload();
                                    }
                                    console.log('>>>>'+myJob.Status);    
                                }
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 2000);
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
   
    executeEnvelopeIdBatch : function(component, helper, PatentID, envelopeid) {
        var action = component.get('c.getEnvelopeStatusEnvelopeId');
        action.setParams({ 'PatentID' : PatentID, 'envelope_id' : envelopeid});
        action.setCallback
        (
            this,
            function (response) 
            {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    if (rows=='Success') {
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type":"success",
                                "title": "Success!",
                                "message": "Envelope Status Sync successfully"
                            });
                        toastEvent.fire();
                    }
                 this.FetchData(component, PatentID);
                 $A.get('e.force:refreshView').fire();   
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
    
    UpdateEnvelopeIdStatus : function(component, helper, vStatus, envelopeid) {
        var action = component.get('c.EnvelopeIdUpdateStatus');
        action.setParams({ 'Status' : vStatus, 'envelope_id' : envelopeid});
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
    }
    
    
})