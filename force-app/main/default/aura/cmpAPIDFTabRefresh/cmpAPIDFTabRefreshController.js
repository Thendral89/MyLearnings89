({
    
    
     invoke: function(component, event, helper){
     
         
    if(component.get("v.IsWindowRefresh")==true) {
        console.log('iff');
        console.log(component.get("v.recordId"));
      if(component.get("v.IsMsgShow")==true) {
          console.log('iff111');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Record has been updated successfully!",
                type: "success"
            });
            toastEvent.fire();
             	$A.get('e.force:refreshView').fire();
             	var urlEvent = $A.get("e.force:navigateToURL");
    			urlEvent.setParams({
      			"url": '/' + component.get("v.recordId")
    			});
      			urlEvent.fire();
             
         } else {
             	$A.get('e.force:refreshView').fire();
             	var urlEvent = $A.get("e.force:navigateToURL");
    			urlEvent.setParams({
      			"url": '/' + component.get("v.recordId")
    			});
      			urlEvent.fire();
             
         }
    } else { 
         
         
         let reloadPage = event.getParam('reloadEventDetail');
         //alert('reloadPage' + reloadPage);
        
         if(reloadPage) {
         let workspaceAPI = component.find("myworkspace")
            workspaceAPI.getFocusedTabInfo().then(function(response){
                component.set("v.focusedTabId",response.tabId);
            })
         }
         
      
        
         if(component.get("v.IsMsgShow")==true){
             console.log('iff222');
         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Record has been updated successfully!",
                type: "success"
            });
            toastEvent.fire();
     	}
         
         
        if(reloadPage) {
            let workspaceAPI = component.find("myworkspace")
            workspaceAPI.getFocusedTabInfo().then(function(response){
                let focusedTabId = response.tabId;
                workspaceAPI.refreshTab({
                    tabId: component.get("v.focusedTabId"),
                    includeAllSubtabs: true
                });
            })
            .catch(function(error){
                console.log(error);
                var urlEvent = $A.get("e.force:navigateToURL");
    			urlEvent.setParams({
      			"url": '/' + component.get("v.recordId")
    			});
      			urlEvent.fire();
            })
        }
         
      $A.get('e.force:refreshView').fire();
    }
    },
    
})