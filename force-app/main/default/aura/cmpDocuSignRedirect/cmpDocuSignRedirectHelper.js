({
	 ValidateDocuSignFields : function(component, event, helper) {
        var Status='sent';
        var action = component.get("c.EnvelopeIdUpdateRedirectedStatus");
        action.setParams({'Status': Status,
                          'envelope_id': component.get("v.envelopeId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            //alert(state);
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
                //alert(rows);
            }
        });
        $A.enqueueAction(action);
    },
})