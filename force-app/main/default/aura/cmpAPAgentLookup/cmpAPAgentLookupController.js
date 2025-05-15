({
    // To prepopulate the seleted value pill if value attribute is filled
	doInit : function( component, event, helper ) {
        component.set('v.searchString','');
        if (component.get('v.role')==undefined){
            component.set('v.role','');
         }
        
    
    //alert('selectedId ' + component.get('v.selectedId'));
    
    $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        
     if(component.get('v.FilterFieldValue') =='EP Validation' || component.get('v.FilterFieldValue') =='12 Month (or 6 month) Foreign Filing' || component.get('v.FilterFieldValue') =='PCT National Phase Filing') {
        if(component.get('v.selectedId') !=''){
            component.set('v.DoNotselectedRecords',component.get('v.selectedId'));
            component.set('v.selectedRecords',component.get('v.selectedId'));
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            helper.SelectedRecordsHelper(component, event, helper, component.get('v.DoNotselectedRecords'));
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
     }
     
   
    if(component.get('v.objectName')=='SymphonyIPM__Law_Firm__c' && component.get('v.FilterFieldName') =='IsStrategic_Counsel__c') {
        if(component.get('v.selectedId') !='' && component.get('v.selectedId')!=undefined){
            //alert('SP ' + component.get('v.selectedId'));
            component.set('v.DoNotselectedRecords',component.get('v.selectedId'));
            component.set('v.selectedRecords',component.get('v.selectedId'));
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            helper.SelectedLawFirmRecordsHelper(component, event, helper, component.get('v.DoNotselectedRecords'));
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
     }
        
    
    
     if(component.get('v.FilterFieldValue') !='EP Validation') {
    	//$A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
		if( !$A.util.isEmpty(component.get('v.selectedRecords')) ) {
			helper.searchRecordsHelper(component, event, helper, component.get('v.selectedRecords'));
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
		}
     }
        
	},

     // When a keyword is entered in search box
	OnUnitaryPatent : function( component, event, helper ) {
        
    
        var recordsList = '';
        var selectedRecords =[];
        var selectedDataObj = [];
        var committee_Names = [];
        component.set('v.recordsList', recordsList);
        component.set('v.selectedDataObj', selectedDataObj);
        component.set('v.selectedRecords', selectedRecords);
        component.set("v.selectedId", selectedRecords.join(","));  
        component.set('v.DoNotselectedRecords', selectedRecords);
        component.set('v.selectedName','');
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
      
        
        component.set("v.FilingsfromtheUPC", '');        
        if(component.get('v.FilingaDivisionalApplication') ==''){
        	component.set("v.FilingaDivisionalApplication", '');    
        }
        
        //alert(component.get('v.FilingUnderUnitaryPatent'));
        if(component.get('v.FilingUnderUnitaryPatent')=='No') {
           component.set('v.IsRequired',true); 
        } else if(component.get('v.FilingUnderUnitaryPatent')=='Yes') {
           component.set('v.IsRequired',false);  
        } 
        
        if(component.get('v.disabled')!=true) {
        	//helper.searchRecordsHelper(component, event, helper, []);
    	}
        
	},
    
    // When a keyword is entered in search box
	searchRecords : function( component, event, helper ) {
        
        if(component.get('v.disabled')!=true) {
        	helper.searchRecordsHelper(component, event, helper, []);
    	}
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
		    //helper.searchRecordsHelper(component, event, helper, []);
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
	},

    // When an item is selected
	selectItem : function( component, event, helper ) {
        var selectedrecordId='';
        if(!$A.util.isEmpty(event.currentTarget.id)) {
    		var recordsList = component.get('v.recordsList');
            var selectedRecords = component.get('v.selectedRecords') || [];
            var selectedDataObj = component.get('v.selectedDataObj') || [];
    		var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                recordsList[index].isSelected = recordsList[index].isSelected === true ? false : true;
                selectedrecordId=recordsList[index].value;
                
                if(selectedRecords.includes(recordsList[index].value)) {
                    selectedRecords.splice(selectedRecords.indexOf(recordsList[index].value), 1);
                    var ind = selectedDataObj.findIndex(x => x.value === event.currentTarget.id)
                    if(ind != -1) {selectedDataObj.splice(ind, 1)}
                } else {
                	selectedRecords.push(recordsList[index].value);
                    selectedDataObj.push(recordsList[index]);
                }
            }
            component.set('v.recordsList', recordsList);
            component.set('v.selectedRecords', selectedRecords);
            component.set('v.selectedDataObj', selectedDataObj);
            component.set("v.selectedId", selectedRecords.join(","));
            
            
            
             if(component.get('v.IsMultiple')!=true){
                var rows = component.get('v.selectedRecords');
                 component.set("v.selectedId", event.currentTarget.id);
                if(rows.length>=1){
                   component.set('v.disabled', true); 
                } else {
                  component.set('v.disabled', false);   
                }
            }
            
        var selectedValues = component.get('v.selectedDataObj');
        var committee_Names = [];
        var DoNotselectedRecords = [];
        selectedValues.forEach(function(element, idx, array){
            
            if(component.get('v.FilterFieldValue')=='PCT National Phase Filing' || component.get('v.FilterFieldValue')=='12 Month (or 6 month) Foreign Filing' || component.get('v.FilterFieldValue')=='EP Validation'){
                 committee_Names.push(element.label);
            	 DoNotselectedRecords.push(element.value);
            } else {
                committee_Names.push('<a href="/'+element.value+'" target="_self">'+ element.label+ '</a>');
            	DoNotselectedRecords.push(element.value);
            }
            
        });
            
            component.set('v.selectedName', committee_Names.join(';<br/>'));
            component.set('v.DoNotselectedRecords', DoNotselectedRecords.join(','));
        
         
            helper.SelectedAgentsRecordsHelper(component, event, helper, DoNotselectedRecords);
            
            
        }
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
	},
    
    removePill : function( component, event, helper ){
        var recordId = event.getSource().get('v.name');
        var recordsList = component.get('v.recordsList');
        var selectedRecords = component.get('v.selectedRecords');
        var selectedDataObj = component.get('v.selectedDataObj');
        
        selectedRecords.splice(selectedRecords.indexOf(recordId), 1);
        var index = selectedDataObj.findIndex(x => x.value === recordId)
        if(index != -1) {
            selectedDataObj.splice(index, 1)
        }
        var ind = recordsList.findIndex(x => x.value === recordId)
        if(ind != -1) {
            recordsList[ind].isSelected = false;
        }
        component.set('v.recordsList', recordsList);
        component.set('v.selectedDataObj', selectedDataObj);
        component.set('v.selectedRecords', selectedRecords);
        component.set("v.selectedId", selectedRecords.join(","));
        
       
        
         if(component.get('v.IsMultiple')!=true){
                var rows = component.get('v.selectedRecords');
                component.set("v.selectedId", recordId);
                if(rows.length>=1){
                   component.set('v.disabled', true); 
                } else {
                    component.set('v.disabled', false); 
                }
            }
        
        var selectedValues = component.get('v.selectedDataObj');
        var committee_Names = [];
        var DoNotselectedRecords = [];
        selectedValues.forEach(function(element, idx, array){
            if(component.get('v.FilterFieldValue')=='PCT National Phase Filing' || component.get('v.FilterFieldValue')=='12 Month (or 6 month) Foreign Filing' || component.get('v.FilterFieldValue')=='EP Validation'){
                 committee_Names.push(element.label);
            	 DoNotselectedRecords.push(element.value);
            } else {
                committee_Names.push('<a href="/'+element.value+'" target="_self">'+ element.label+ '</a>');
            	DoNotselectedRecords.push(element.value);
            }
        });
        
         if(component.get('v.FilterFieldValue')=='PCT National Phase Filing' || component.get('v.FilterFieldValue')=='12 Month (or 6 month) Foreign Filing' || component.get('v.FilterFieldValue')=='EP Validation'){
        		component.set('v.selectedName', committee_Names.join(';<br/>'));
        		component.set('v.DoNotselectedRecords', DoNotselectedRecords.join(','));        
            } else {
                component.set('v.selectedName', committee_Names.join(';<br/>'));
        		component.set('v.DoNotselectedRecords', DoNotselectedRecords.join(','));
            }   
        
        
    },
    
    showRecords : function( component, event, helper ){
        var disabled = component.get('v.disabled');
        if(!disabled && !$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
    },

    // To close the dropdown if clicked outside the inputbox.
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
})