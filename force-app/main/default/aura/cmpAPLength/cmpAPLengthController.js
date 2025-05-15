({
	closeModal: function(component,event,helper){
        component.set('v.IsShow',false);
    },
    
    CreateModal: function(component,event,helper){
        component.set('v.IsShow',true);
      
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : "vRichTextBox",
                type : "String",
                value : component.get("v.vRichText")
            }
        ];
        flow.startFlow("cmpAPRichText", inputVariables);
        
    },
    
     statusChange : function (component, event, helper) {
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            component.set('v.IsShow',false);
        } 
    }
    
})