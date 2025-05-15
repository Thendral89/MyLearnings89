public class cmpAPiManagFileInvockableCtrl {

    public class Request {
        @InvocableVariable
        public String FileContent;
    }

    public class Response {
        @invocableVariable
        public String csvString;
    }
   
    @future(callout=true)
    public static void FileUploadfuture(string FileContent,string filename, string extension) {
        //FileUpload(FileContent,filename, extension);
    }
    
   @AuraEnabled()
   public static void FileUpload(string FileContent,string filename, string extension) {
       
       string access_token =cmpAPAPIHeaderCtrl.getToken();
       system.debug('FileContent ' + FileContent);
       
       
       // Define the URL for the API endpoint
        String url = 'https://mcciplaw-mobility.imanage.work/api/v2/customers/1/libraries/ACTIVE/folders/ACTIVE!1454607/documents';

        // Define the JSON metadata (profile data)
        String profileJson = '{"doc_profile": {"name":"' + filename + '", "extension":"' + extension+ '", "author":"symphonysandbox", "operator":"symphonysandbox", "type": "' + extension + '", "class": "DOC", "default_security":"public"}, "warnings_for_required_and_disabled_fields":true}';
        
        // Set up the boundary for the multipart request
        String boundary = '7MA4YWxkTrZu0gW';
        
        // Build the multipart form data body
        String body = '';
        body += '--' + boundary + '\r\n';
        body += 'Content-Disposition: form-data; name="profile"\r\n';
        body += 'Content-Type: application/json\r\n\r\n';
        body += profileJson + '\r\n';
        
        body += '--' + boundary + '\r\n';
        body += 'Content-Disposition: form-data; name="file"; filename="' + filename+  '"\r\n';
        body += 'Content-Type: application/octet-stream; charset=ISO-8859-1\r\n\r\n';
       
        body += FileContent + '\r\n'; 
        body += '--' + boundary + '--\r\n';

        system.debug('body ' + body);
       
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setHeader('X-Auth-Token', access_token);
        req.setHeader('Content-Length', String.valueOf(body.length()));
        req.setBody(body);

        // Send the request
        Http http = new Http();
        HTTPResponse res = http.send(req);

        // Handle the response
        if (res.getStatusCode() == 200) {
            System.debug('File uploaded successfully: ' + res.getBody());
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' ' + res.getBody());
        }
       
   }
    
    @invocableMethod(label='iManage File Upload' )
    public static List<Response> execute (List<Request> requests) {
        List<Response> responseList = new List<Response>();
        for (Request cur : requests) {
            
        }
		
        return responseList;
        
  }
    
    
}