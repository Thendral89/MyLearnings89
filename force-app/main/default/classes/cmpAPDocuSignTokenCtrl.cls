global with sharing class cmpAPDocuSignTokenCtrl {

    @future(callout=true)
    public static void DocuSignTokenFuture() {
        cmpAPDocuSignTokenCtrl.getToken();
    }
    
   public static List<DocuSignSetting__c> getHeader() {
        List<DocuSignSetting__c> Workdas = [SELECT Id,access_token__c,refresh_token__c,code__c  FROM DocuSignSetting__c LIMIT 1];
        System.debug('Workdas ' + Workdas);
        return Workdas;
    }
  
    
    public static string  setHeader(string Id,string access_token, string refresh_token ) {
        DocuSignSetting__c DocuSign =new DocuSignSetting__c();
		DocuSign.Id = Id;
        DocuSign.access_token__c = access_token;
		DocuSign.refresh_token__c = refresh_token;
		update DocuSign;
        return 'Success';
    }
    
  public class Token {
     public String access_token;
     public String token_type;   
     public String refresh_token;   
     public String expires_in;   
     public String scope;   
  }
    
    
    public static string getRefreshToken() {
      
        try 
        {
            List<DocuSignSetting__c> objCSworkday = cmpAPDocuSignTokenCtrl.getHeader();
            DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
            string apibody='';
            string access_token='';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(objCSDocuSign.TokenUrl__c);
            req.setMethod('POST');  
            req.setCompressed(false);
            req.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
            apibody='grant_type=authorization_code&code='+ objCSworkday[0].code__c  + '';
            req.setBody(apibody);
            req.setHeader('Authorization', objCSDocuSign.Authorization__c );
            req.setHeader('Cache-Control', 'no-store');
			req.setHeader('Pragma', 'no-cache');
    		System.debug(apibody);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                HTTPResponse httpResponse = http.send(req);
                System.debug('httpResponse.getBody()' + httpResponse.getBody());
                
               if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                    Token objResponse = (Token) JSON.deserializeStrict(httpResponse.getBody(),Token.Class);
                    access_token=objResponse.access_token;
                }
                
            }
            
            System.debug('access_token' + access_token);
            return access_token;
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    
    public static string getToken() {
        try 
        {
            List<DocuSignSetting__c> objCSworkday = cmpAPDocuSignTokenCtrl.getHeader();
            DocuSign__c objCSDocuSign = DocuSign__c.getInstance('Default');
            string apibody='';
            string access_token='';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(objCSDocuSign.TokenUrl__c);
            req.setMethod('POST');  
            req.setCompressed(false);
            req.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
            apibody='grant_type=refresh_token&refresh_token='+ objCSworkday[0].refresh_token__c  + '';
            req.setBody(apibody);
            req.setHeader('Authorization', objCSDocuSign.Authorization__c );
            req.setHeader('Cache-Control', 'no-store');
			req.setHeader('Pragma', 'no-cache');
    		System.debug(apibody);
            req.setTimeout(120000);
            Http http = new Http();
            if(!test.isRunningTest()) {
                HTTPResponse httpResponse = http.send(req);
                System.debug('httpResponse.getBody()' + httpResponse.getBody());
                
               if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                    Token objResponse = (Token) JSON.deserializeStrict(httpResponse.getBody(),Token.Class);
                   	setHeader(objCSworkday[0].Id,objResponse.access_token,objResponse.refresh_token);
                    access_token=objResponse.refresh_token;
                }
                
            }
            
            System.debug('access_token' + access_token);
            return access_token;
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    
    
}