({
    
    onSaveDraft: function(component, event, helper) {
        
        
        component.set("v.DisclosureStatus","Draft");
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
        
     },
    
    onChangeTitle : function (component, event, helper) {
        

        var fieldvalue = event.getSource().get("v.value");
        var name = event.getSource().get("v.name");
        var fieldApi='Comment__c';
        var objName='ContentVersion';
      
        
        var action = component.get("c.SRUpdateRecord");
        action.setParams({
            "recordId" 		: name,
        	"fieldApi" 		: fieldApi,
        	"fieldvalue" 	: fieldvalue,
            "objName" 		: objName
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
               //alert(state);
            }
                      
        });
        $A.enqueueAction(action);
        
        
    },
    
   
    
     onButtonPressed: function(component, event, helper) {
      
      //alert("Back");
      component.set("v.DisclosureStatus","Back");
      var actionClicked = event.getSource().getLocalId();
      var navigate = component.get('v.navigateFlow');
      navigate(actionClicked);
        
   },
    
    PreviewFile: function(cmp, event, helper) {
       var recid =  event.target.id;
		$A.get('e.lightning:openFiles').fire({
		    recordIds: [recid]
		});
    },
    
     OnSubmitted: function(component, event, helper) {
         
         if (component.get("v.isFileUploaded") !=true) {
             component.set("v.Error",true);
             return false;
         }
        
         component.set("v.DisclosureStatus","Submitted");
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
        
     },
    
	getAttachedDocumentsController : function(component, event, helper) {
        
        
        helper.getPatentbotsprofilenameHelper(component, component.get('v.linkedEntityId'));
        
        //alert('canViewAllFiles' + component.get('v.canViewAllFiles')  + 'canViewCurrentAttachedFiles' + component.get('v.canViewCurrentAttachedFiles') )
        var canViewAllFiles = component.get('v.canViewAllFiles');
        var canViewCurrentAttachedFiles = component.get('v.canViewCurrentAttachedFiles');
        
        if (canViewAllFiles==true && canViewCurrentAttachedFiles==false) {
        	var linkedEntityId  = component.get('v.linkedEntityId');
            
            if(component.get("v.IsDocuSign")==true){
                helper.getDocuSignHelper(component, linkedEntityId);
            } else {
                helper.getAttachedDocumentsHelper(component, linkedEntityId);
            }
        	
        }
        else if (canViewAllFiles==false && canViewCurrentAttachedFiles==true) {
            var linkedEntityId  = component.get('v.linkedEntityId');
            
            if(component.get("v.IsDocuSign")==true){
                helper.getCurrentDocuSignHelper(component, linkedEntityId, component.get("v.lstDocumentId"));
            } else {
                helper.getCurrentAttachedDocumentsHelper(component, linkedEntityId, component.get("v.lstDocumentId"));
            }
        	
        }
	},
    
    handleUploadFinished: function (component, event, helper)  {
        // This will contain the List of File uploaded data and status
        
        var lstDocumentId = component.get("v.lstDocumentId");
        var uploadedFiles = event.getParam("files");
        
        //alert(uploadedFiles);
        
        if (uploadedFiles!=undefined)
        {
			for(var i=0;i<uploadedFiles.length;i++)            
            {
                lstDocumentId.push(uploadedFiles[i].documentId);
                component.set("v.ContentVersionId", uploadedFiles[i].documentId);
                
            }
        }
        
        var count = component.get("v.count");
        count = count + lstDocumentId.length;
        component.set("v.count",count);
          var searchCompleteEvent = component.getEvent("isUploadEvent");

            searchCompleteEvent.setParams({
            isUploadTrue: true
            }).fire();
            
            var searchCompleteEvent1 = component.getEvent("uploadedfiles");
            searchCompleteEvent1.setParams({
            ListOfUploadedFiles: lstDocumentId,
            count: count
            }).fire();
          //  alert('text');
        component.set("v.lstDocumentId", lstDocumentId);
        
        lstDocumentId = component.get("v.lstDocumentId");
        component.set("v.contentDocumentIds", lstDocumentId.join(","));
        //alert('Ids:' + component.get("v.contentDocumentIds"));
        
        if(component.get('v.contentDocumentIds').length != 0){
            component.set("v.idAvailable","true");
            component.set("v.isFileUploaded",true);
        }
        
        var linkedEntityId  = component.get('v.linkedEntityId');
        //helper.getCurrentAttachedDocumentsHelper(component, linkedEntityId, lstDocumentId);
        
        
        var canViewAllFiles = component.get('v.canViewAllFiles');
        var canViewCurrentAttachedFiles = component.get('v.canViewCurrentAttachedFiles');
       //alert('canViewAllFiles ' + canViewAllFiles + ' canViewCurrentAttachedFiles ' + canViewCurrentAttachedFiles);
        
        if (canViewAllFiles==true && canViewCurrentAttachedFiles==false) {
        	var linkedEntityId  = component.get('v.linkedEntityId');
            
            if(component.get('v.IsPatentbots')==true && component.get('v.ProfileName')=='Platform Outside Counsel') {
            	helper.getPatentbotsHelper(component, linkedEntityId, lstDocumentId);    
            } 
            helper.getAttachedDocumentsHelper(component, linkedEntityId);
            
        	
            
            
            
        }
        else if (canViewAllFiles==false && canViewCurrentAttachedFiles==true) {
            var linkedEntityId  = component.get('v.linkedEntityId');
            
            if(component.get('v.IsPatentbots')==true && component.get('v.ProfileName')=='Platform Outside Counsel'){
            	helper.getPatentbotsHelper(component, linkedEntityId, lstDocumentId);    
            } 
            helper.getCurrentAttachedDocumentsHelper(component, linkedEntityId, component.get("v.lstDocumentId"));
            
        	
       
        }
        
        if (canViewAllFiles==false && canViewCurrentAttachedFiles==false) {
            $A.get('e.force:refreshView').fire();
        }   
        
    },
    deleteAttachmentsController : function(component,event, helper)  {
        
        var msg ='Are you sure you want to delete this item?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
        var contentVersionId = event.getSource().get("v.value");
        var count = component.get("v.count");
        count = count - 1;
        component.set("v.count",count);
        if(component.get("v.count")==0){
        var searchCompleteEvent = component.getEvent("isUploadEvent");
            searchCompleteEvent.setParams({
            isUploadTrue: false
            }).fire();
        }
        
        helper.deleteDocumentAttachmentsHelper(component, contentVersionId);
    }
        
    },
    
    onSubmitButtonPressed: function(component, event, helper) {
       // alert('text-->'+cmp.get("v.comments"));
        var lstDocumentIds = component.get('v.lstDocumentId');
        
        console.log(lstDocumentIds.length);
       /* if(lstDocumentIds.length  === 0){
            component.set("v.ErrorMessage",'Please upload the signed agreement to complete.');
            component.set("v.Error",'true');
        }else*/
        {
            var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                    title: 'Success',
                    message: 'The record has been approved Successfully!',
                    duration: '5000',
                    type: 'success',
                    mode: 'pester'
                });
               toastEvent.fire();  
      // Figure out which action was called
        var actionClicked = event.getSource().getLocalId();
      // Fire that action
      component.set("v.Submit",true);
      var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
        } 
   },

   doFocus : function(component, event, helper) {
    document.getElementById("FOCUSHERE").focus();
   }
    
    
})