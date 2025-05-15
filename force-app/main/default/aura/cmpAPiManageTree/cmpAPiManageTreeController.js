({
    initialize : function(component, event, helper) {
        if (component.get("v.items").length > 0) {
            //items are already loaded, do nothing
            component.set("v.loading", false);
            return;
        }
       
     if (component.get("v.IsConfigured") ==false) {
        var action = component.get("c.getParentFolder");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.ParentList",items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action);
         
    } else if (component.get("v.IsConfigured") ==true) {
        var action = component.get("c.getConfiguredFolder");
        action.setParams({ 'PatentId' : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.ParentList",items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
    }
        
    },
    
    handleExpandNode : function(component, event, helper) {
        var folderId = event.getSource().get("v.value"),
            expanded = event.target.parentElement.getAttribute("aria-expanded");
        
        if (expanded == "true") {
            event.target.parentElement.setAttribute("aria-expanded", "false");
        } else {
            event.target.parentElement.setAttribute("aria-expanded", "true");
        }
        
        
    },
    
    OnSelectedFolderExpandEigth : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandEigth ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedEighth");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedEighth", false);
        	} else {
            	component.set("v.IsExpandedEighth", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listNine", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpandSeven : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandSeven ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedSeven");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedSeven", false);
        	} else {
            	component.set("v.IsExpandedSeven", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listEighth", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
	OnSelectedFolderExpandSix : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandFive ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedSix");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedSix", false);
        	} else {
            	component.set("v.IsExpandedSix", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listSeven", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpandFive : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandFive ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedFive");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedFive", false);
        	} else {
            	component.set("v.IsExpandedFive", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                alert('listSix ' + JSON.stringify(items));
                
                component.set("v.listSix", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpandFour : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandFour ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedFour");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedFour", false);
        	} else {
            	component.set("v.IsExpandedFour", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listFive", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpandThree : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandThree ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedThree");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedThree", false);
        	} else {
            	component.set("v.IsExpandedThree", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listFour", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpandTwo : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandTwo ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedTwo");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedTwo", false);
        	} else {
            	component.set("v.IsExpandedTwo", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listThree", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpandOne : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpandOne ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedOne");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedOne", false);
        	} else {
            	component.set("v.IsExpandedOne", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listTwo", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpand : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpand ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpanded");
        	if (IsExpanded == true) {
            	component.set("v.IsExpanded", false);
        	} else {
            	component.set("v.IsExpanded", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.listOne", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
    OnSelectedFolderExpandParent : function(component,event,helper) {
         	var EnvelopeId = event.getSource().get("v.value");
        	//alert('OnSelectedFolderExpand ' + EnvelopeId);
        	var IsExpanded = component.get("v.IsExpandedParent");
        	if (IsExpanded == true) {
            	component.set("v.IsExpandedParent", false);
        	} else {
            	component.set("v.IsExpandedParent", true);
        	}
        
        	component.set('v.SubselectedFolderId',EnvelopeId);
            var action = component.get("c.getSubNodes");
        	action.setParams({ 'PatentId' : component.get("v.recordId"),
                           	   'selectedFolderId' : EnvelopeId,
                               'SubselectedFolderId' : EnvelopeId });
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = response.getReturnValue();
                component.set("v.items", items);
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action); 
	},
    
	OnSelectedFolderExpandEvent : function(component,event,helper) {
        var EnvelopeId = event.getSource().get("v.value");
        component.set('v.SubselectedFolderId',EnvelopeId);
        
        var IsExpanded = component.get("v.IsExpanded");
        if (IsExpanded == true) {
            component.set("v.IsExpanded", false);
        } else {
            component.set("v.IsExpanded", true);
        }
        
        var appEvent = $A.get("e.c:cmpAPiManageTreeEvent"); 
        appEvent.setParams({"SubselectedFolderId" : EnvelopeId,
                           "IsExpanded" : component.get("v.IsExpanded"),
                           "selectedFolderId" : component.get("v.selectedFolderId")}); 
        appEvent.fire(); 
        
    },
    
    handleSelectNode : function(component, event, helper) {
        
        var li = event.target.closest('li'),
            id = li.dataset.id,
            items = component.get("v.list");
			component.set("v.iManageFolderId", id);

        var parent = li.closest('li'),
            path = [];
        while(parent != null) {
            path.unshift({title: parent.getAttribute("aria-label"), id: parent.dataset.id });
            parent = parent.parentElement.closest('li');
        }
      
        
        
        var appEvent = component.getEvent("cmpAPiManageTreeEvent"); 
        appEvent.setParams({"SubselectedFolderId" : component.get("v.iManageFolderId"),
                           "IsExpanded" : component.get("v.IsExpanded"),
                           "selectedFolderId" : component.get("v.selectedFolderId"),
                           "path" : path }); 
        appEvent.fire();
		//alert('handleSelectNode appEvent ' + component.get("v.iManageFolderId"));
        
		
        
    },

    refreshFolder : function(component, event, helper) {
        
    }
    
    
})