({
	doInit : function(component, event, helper) {
        
      helper.FetchPatentData(component,event); 
        
    },
    
    closeModal: function(component,event,helper){
        component.set('v.IsShow',false);
        $A.get("e.force:closeQuickAction").fire();
    },
    
    NewRecord: function(component,event,helper){
        component.set('v.IsShow',true);
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        flow.startFlow("cmpAPDocuSginedPerson", inputVariables);
        
    },
    
    statusChange : function (component, event, helper) {
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            component.set('v.IsShow',false);
       		helper.FetchPatentData(component,event,helper); 
        } 
    },
    
    
     handleRowAction: function ( component, event, helper ) {
        var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        var recId = row.Id;
        switch ( action.name ) {
            case 'edit':
                helper.EditRecord(component, event);
                break;
            case 'delete':
                helper.DeleteRecord(component, event);
                break;
        }
         
    },
    
      OnSelectedRows : function(component, event, helper) {
        component.set("v.SelectedIds", '');
        component.set("v.strSelectedInventorIds", '');
          
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        component.set("v.SelectedIds", setRows);
          
        var records = component.get("v.SelectedIds");
        var arryAPIValues = [];
        for ( var i = 0; i < records.length; i++ ) {
            arryAPIValues.push(records[i].Id);
            component.set("v.strSelectedInventorIds", arryAPIValues.join(","));
        }
        
          //alert(component.get("v.SelectedIds"));
          //alert(component.get("v.strSelectedInventorIds"));
          
          
    },
   
     handleSort : function(component,event,helper){
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    }
      
})