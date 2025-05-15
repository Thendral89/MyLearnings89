({
    initialize : function(component, event, helper) {
        if (component.get("v.items").length > 0) {
            component.set("v.loading", false);
            return;
        }
       
        var action = component.get("c.getEmails");
        action.setParams({ 'ParentId' : component.get("v.recordId")});
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
    
  
    handleSelect : function(component, event, helper) {
        var EnvelopeId = event.getParam('name');
        component.set('v.SubselectedFolderId',EnvelopeId);
        
        var IsExpanded = component.get("v.IsExpanded");
        if (IsExpanded == true) {
            component.set("v.IsExpanded", false);
        } else {
            component.set("v.IsExpanded", true);
        }
        
        var appEvent = $A.get("e.c:cmpAPiManagedEmailsEvent"); 
        appEvent.setParams({"SubselectedFolderId" : EnvelopeId,
                           "IsExpanded" : component.get("v.IsExpanded"),
                           "selectedFolderId" : component.get("v.selectedFolderId"),
                           "title" : "Emails" }); 
        appEvent.fire(); 
        
        
    },

     handleExpandNode : function(component, event, helper) {
         var folderId = event.getSource().get("v.value");
         var li = event.target.closest('li');
         var id = li.dataset.id;
         var parent = li.closest('li');
         var expanded = parent.getAttribute("aria-expanded");
         
        if (expanded == "true") {
            parent.setAttribute("aria-expanded", "false");
        } else {
            parent.setAttribute("aria-expanded", "true");
        }
    },
    
     handleSelectNode : function(component, event, helper) {
        component.set("v.loading", true);
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
      
        
        var action = component.get("c.getiManagedId");
        action.setParams({ 'recordId' : id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var iManagedId = response.getReturnValue();
                
                //alert('handleSelectNode EnvelopeId ' + iManagedId)
                
                component.set("v.iManageFolderId", iManagedId);
                var appEvent = component.getEvent("cmpAPiManagedEmailsEvent"); 
        		appEvent.setParams({"SubselectedFolderId" : component.get("v.iManageFolderId"),
                           "IsExpanded" : component.get("v.IsExpanded"),
                           "selectedFolderId" : component.get("v.selectedFolderId"),
                           "path" : path,
                           "title" : "Emails" }); 
        		appEvent.fire();
                
            } 
            
        	component.set("v.loading", false);
        });
        $A.enqueueAction(action);
         
        
		
        
    },
    
    refreshFolder : function(component, event, helper) {
        
    }
    
    
})