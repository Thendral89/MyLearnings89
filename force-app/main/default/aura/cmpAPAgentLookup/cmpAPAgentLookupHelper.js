({
    
    SelectedAgentsRecordsHelper : function(component, event, helper, selectedRecords) {
        component.set('v.message', '');
        var selectedId = [];
        var searchString = component.get('v.searchString');
    	var action = component.get('c.fetchSelectedAgentsRecords');
        action.setParams({'values' : JSON.stringify(selectedRecords)});
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
                    result.forEach(element => {
                        selectedId.push(element.label);
                    });
                    component.set('v.selectedName',selectedId.join(","));
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + '"');
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            
        });
        $A.enqueueAction(action);
        
    },
                        
    EPValidation : function (component){
      	//alert(component.get("v.selectedId"));
        var action = component.get("c.EPValidation");
        action.setParams({
            "recordId" 		: component.get("v.selectedId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set('v.IsEPLocalFirm', result);
             	//alert(result);
             	
            }
                      
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        
    },
    
    FetchEPLawFirm : function (component){
      
           var action = component.get('c.fetchEPLawFirm');
            action.setParams({ "objName" : component.get("v.objectName")});
            action.setCallback(this,function(response){
                var state = response.getState();
                var result = response.getReturnValue();        
                var values = [];
                for (var key in result ) {
                	values.push({value:result[key], key:key});
                }
                //alert(result);
                component.set("v.picklistValues",values);
            });
            $A.enqueueAction(action);
        
    },
    
    
     getDecisionDueDateHelper : function(component, event, helper, selectedRecords) {
    	var action = component.get('c.getdecisionDueDate');
        action.setParams({'recordId' : selectedRecords });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
                     if(result.length > 0) {
                    	result.forEach(element => {
                            component.set('v.DecisionDueDate',element.SymphonyIPM__Due_Date__c);
                        });
                    }
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + '"');
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            
        });
        $A.enqueueAction(action);
        
    },
                        
    SelectedLawFirmRecordsHelper : function(component, event, helper, selectedRecords) {
        component.set('v.message', '');
        component.set('v.recordsList', []);
        var searchString = component.get('v.searchString');
    	var action = component.get('c.fetchSelectedLawFirmRecords');
        action.setParams({'values' : JSON.stringify(selectedRecords)});
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				component.set('v.selectedDataObj', result);
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + '"');
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    SelectedRecordsHelper : function(component, event, helper, selectedRecords) {
        component.set('v.message', '');
        component.set('v.recordsList', []);
        component.set('v.selectedId','');
        var selectedId = [];
        var searchString = component.get('v.searchString');
    	var action = component.get('c.fetchSelectedRecords');
        action.setParams({'values' : JSON.stringify(selectedRecords)});
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
                    
                    result.forEach(element => {
                        selectedId.push(element.value);
                    });
                
    				component.set('v.selectedDataObj', result);
                    component.set('v.selectedId',selectedId.join(","));
                    component.set('v.DoNotselectedRecords',component.get('v.selectedId'));
            		component.set('v.selectedRecords',component.get('v.selectedId'));
                        
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + '"');
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
	searchRecordsHelper : function(component, event, helper, selectedRecords) {    
        
        //alert(JSON.stringify(selectedRecords));
        var DoNotselectedRecords=component.get('v.DoNotselectedRecords')
        
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        component.set('v.message', '');
        component.set('v.recordsList', []);
        var searchString = component.get('v.searchString');
    	var action = component.get('c.fetchRecords');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'searchString' : searchString,
            'values' : JSON.stringify(selectedRecords),
            'FilterFieldName' : component.get('v.FilterFieldName'),
            'FilterFieldValue' : component.get('v.FilterFieldValue'),
            'Role' : component.get('v.role'),
            'FilingUnderUnitaryPatent' : component.get('v.FilingUnderUnitaryPatent'),
            'DoNotselectedRecords' : JSON.stringify(DoNotselectedRecords)
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					if( $A.util.isEmpty(selectedRecords) ) {
                        var selectedRcrds = component.get('v.selectedRecords') || [];
                        for(var i = 0; i < result.length; i++) {
                            if(selectedRcrds.includes(result[i].value))
                                result[i].isSelected = true;
                        }
                        component.set('v.recordsList', result);        
					} else {
                        component.set('v.selectedDataObj', result);
					}
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + '"');
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(selectedRecords) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
	}
})