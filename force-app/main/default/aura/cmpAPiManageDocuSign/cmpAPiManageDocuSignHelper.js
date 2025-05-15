({
	
     getsubfolderhelper : function (component, DocumentId) {
        var action = component.get("c.iManagedSubFolders");
        action.setParams({ 'ParentId' : DocumentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var rows = response.getReturnValue();
                 component.set('v.list',rows);
            }
         });
         $A.enqueueAction(action);
    }
    
})