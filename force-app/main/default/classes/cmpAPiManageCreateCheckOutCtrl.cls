public class cmpAPiManageCreateCheckOutCtrl {

  @AuraEnabled
  public static string iMngCheckOut(string access_token,string comments,string due_date, string DocumentId,string recordId) {
      
      	string apiIds ='';
      	string Bytedance_IDF_ID='';
        string data= '';
        string returnresponse='';
      	string API5data='';
        string workspaceId='';
      
        Id myId=recordId;
        String sObjName = myId.getSObjectType().getDescribe().getName();
		string query='';
        string foldername='';
        string Field_API_Name='';
        string Legacy_ID='';
        
      
        try {
            List<iManageAPIs__mdt> objCSworkday = cmpAPAPIHeaderCtrl.getiManageHeader();
            workspaceId=cmpAPAPIHeaderCtrl.getworkspaceId(objCSworkday[0].workspaces__c);
            data='';
            data+=' {';
  			data+=' "appname" : "pdfDocs",';
  			data+=' "comments": "' + comments +'",';
  			data+=' "due_date": "' + due_date +  '"';
			data+=' }';
            
            system.debug('data' + data);
            string apibody=data;
            HttpRequest req = new HttpRequest();
            string dataurl=objCSworkday[0].DataUrl__c + '/customers/'+ objCSworkday[0].customers__c +'/libraries/' + objCSworkday[0].libraries__c +'/documents/' + DocumentId +'/checkout';
            system.debug(dataurl);
            req.setEndpoint(dataurl);
            req.setMethod('POST');  
            req.setBody(apibody);
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
            
            apiIds = cmpAPAPIHeaderCtrl.APIInsert('API2','Pending',data); 
            if(access_token=='success'){
            	cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Success',returnresponse,recordId); 
            } else {
                cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
            }
            
        } catch(Exception exp) {
            System.debug('Error ' + exp.getMessage());
            apiIds=cmpAPAPIHeaderCtrl.APIInsert('API2','Pending',data);
            cmpAPAPIHeaderCtrl.APIUpdate(apiIds,'Pending',returnresponse,recordId);
        }
       
      
      return access_token;
    }
}