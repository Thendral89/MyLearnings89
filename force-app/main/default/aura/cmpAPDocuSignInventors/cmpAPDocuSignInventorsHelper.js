({
	
    sortData: function (component, fieldName, sortDirection) {
        
      var data = component.get("v.Data");
      var reverse = sortDirection !== 'asc';
      data.sort(this.sortBy(fieldName, reverse));
      component.set("v.Data", data);

    },
    
  sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    EditRecord : function(component, event) {
        var row  = event.getParam('row');  
 		var recordId = row.PersonId; 
        //alert('recordId ' + recordId);
        
        component.set('v.IsShow',true);
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : recordId
            },
            {
                name : "PatentId",
                type : "String",
                value : component.get("v.recordId")
            } 
        ];
        flow.startFlow("cmpAPDocuSignInnovator", inputVariables);
        
    },
    
    DeleteRecord : function(component, event) {
        var row  = event.getParam('row');  
 		var recordId = row.Id; 
        var action = component.get("c.RowActionsDelete");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Deleted successfully!",
                type: "success"
            });
            toastEvent.fire();
        });
       
        $A.enqueueAction(action);
		this.FetchPatentData(component,event); 
        //$A.get('e.force:refreshView').fire();
    },
    
    SelectPatentInventor : function(component, event, helper) {
        var action = component.get("c.SelectInventors");
        action.setParams({'inventorIds': component.get("v.SelectedIds")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            alert(state);
            if (state === "SUCCESS")  {
                var rows = response.getReturnValue();
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
     FetchData : function(component, event, helper) {
       
        component.set('v.Column', [
            {label: 'Person', fieldName: 'linkName1', type: 'url',  initialWidth: 300,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, sortable: true,initialWidth: 150},
            {label: 'Email Id', fieldName: 'Email', type: 'text', initialWidth: 350,sortable: true},
            {type: 'button-icon', initialWidth:50 ,typeAttributes: {
                name:'edit',
                title:'edit',
                disabled:false,
                iconName: 'utility:edit',
                variant:'bare',
                iconPosition: 'left'
              },
            },
            {type: 'button-icon', initialWidth:50 ,typeAttributes: {
                name:'delete',
                title:'delete',
                disabled:false,
                iconName: 'utility:delete',
                variant:'bare',
                iconPosition: 'left'
              },
            },
        ]);
        
        var action = component.get("c.FetchData");
        action.setParams({'patentID': component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === "SUCCESS") 
            {
                var rows = response.getReturnValue();
               
                var patentRecord=result;
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    component.set("v.IsAdminAward", row.IsAdmin);
                    if (rows[i].Name != undefined){
                        row.Name = row.Name;
                        row.linkName1 = '/'+ row.Id;
                    }
                    
                }
               component.set('v.Data',rows);
            }
        });
        $A.enqueueAction(action);
    },
    
    FetchPatentData : function(component, event) {
        
		component.set('v.Column', [
            {label: 'Person', fieldName: 'linkName1', type: 'url',  initialWidth: 300,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, sortable: true,initialWidth: 150},
            {label: 'Email Id', fieldName: 'Email', type: 'text', initialWidth: 350,sortable: true},
            {type: 'button-icon', initialWidth:30 ,typeAttributes: {
                name:'edit',
                title:'edit',
                disabled:false,
                iconName: 'utility:edit',
                variant:'bare',
                iconPosition: 'left'
               	},
           },
           {type: 'button-icon', initialWidth:30 ,typeAttributes: {
                name:'delete',
                title:'delete',
                disabled:false,
                iconName: 'utility:delete',
                variant:'bare',
                iconPosition: 'left'
              },
            },
        ]);
        
        var action = component.get("c.FetchPatentData");
        action.setParams({'patentID': component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === "SUCCESS") 
            {
                var rows = response.getReturnValue();
               
                var patentRecord=result;
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    component.set("v.IsAdminAward", row.IsAdmin);
                    
                    if (rows[i].Name != undefined){
                        row.Name = row.Name;
                        row.linkName1 = '/'+ row.PersonId;
                    }
                    
                }
        
               component.set('v.Data',rows);
            }
        });
        $A.enqueueAction(action);
    }
})