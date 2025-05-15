({
    loadEnvelopesController : function(component,event, helper) {
       
        
        
        //var sPageURL='https://cisco-ad--ciscodev.sandbox.lightning.force.com/c/cmpDocuSignRedirectApp.app?Id=a2K03000001eCBwEAM&envelopeId=391e6962-880d-49b7-bf04-e0225b52e7ec&event=Send';
        
         let urlString = window.location.href;
         let baseURL = urlString.substring(0, urlString.indexOf("/c/"));
         //alert(baseURL);
         var sPageURL = decodeURIComponent(window.location.search.substring(1)); 
         var sURLVariables = sPageURL.split('&');
		 var sParameterName;
         var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
           
            if (sParameterName[0] == 'envelopeId') {
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                component.set('v.envelopeId',sParameterName[1]);
            } else if (sParameterName[0] == 'Id') {
                component.set('v.recordId',sParameterName[1]);
            }
        }
       
        if(component.get('v.envelopeId')!=undefined && component.get('v.envelopeId')!=''){
            helper.ValidateDocuSignFields(component,event,helper); 
        }
        
        if(component.get('v.recordId')!=undefined){
            window.open(baseURL+'/'+component.get('v.recordId'),"_self");
        } else {
            window.open(baseURL+'/',"_self");
        }
        
        
        	
    },
  

})