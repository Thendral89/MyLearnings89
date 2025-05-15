public class cmpAPiManageCreateCheckInCtrl {

  @AuraEnabled
  public static string iMngCheckIn (string recordId,string access_token, string DocumentId) {
      
      	string apiIds ='';
        string data= '';
        string returnresponse='';
      
        
       
        //String sObjName = myId.getSObjectType().getDescribe().getName();
		string query='';
        string foldername='';
        string Field_API_Name='';
        string Legacy_ID='';
        string workspaceId='';
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            system.debug('data' + data);
            string apibody=data;
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/documents/' + DocumentId +'/lock';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('DELETE');  
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-Auth-Token', access_token);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                 HTTPResponse httpResponse = http.send(req);
                 System.debug('httpResponse.getBody()' + httpResponse.getBody());
                 returnresponse=httpResponse.getBody();
                 access_token='success';
                
            }
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API1','Pending',data); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
        } catch(Exception exp) {
            //System.debug('Error ' + exp.getMessage());
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API1','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',exp.getMessage(),recordId);
        }
       
      
      return access_token;
    }
}