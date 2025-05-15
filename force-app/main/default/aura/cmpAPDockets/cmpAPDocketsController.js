({
    
  OnFlowLoad: function(component, event, helper) {
      var Variables = [
          {
              name : 'recordId',
              type : 'String',
              value : component.get("v.recordId")
          }
      ];
      var flowData = component.find("FlowRecommendation");
      flowData.startFlow('cmpAPDockets',Variables);
      
  },
    
  closeReminerModel: function(component, event, helper) {
      			var actionClicked = event.getSource().getLocalId();
        		var navigate = component.get('v.navigateFlow');
        		navigate(actionClicked);
      
      
  },
    
	statusChange : function (component, event, helper) {
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            var urlEvent = $A.get("e.force:navigateToURL");
    			urlEvent.setParams({
      			"url": '/' + component.get("v.recordId") 
    			});
    		urlEvent.fire();
        } 
    },
    
    
})