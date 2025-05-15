public with sharing class IManageProxyController {
    @AuraEnabled  // IManageProxyController.uploadToIManage('MyImage.png', '', 'ACTIVE', 'ACTIVE!1453263');
    public static String uploadToIManage(String fileName, String base64Data, String libraryId, String folderId) {
        List<ContentVersion> file = [SELECT Id, VersionData FROM ContentVersion WHERE Id = '068Wr0000047n4vIAA'];
        Http http = new Http();

        String fullFolderId = folderId;
        
        String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
        String lineEnd = '\r\n';
        String twoHyphens = '--';

        String metadata2 = JSON.serialize(new Map<String, Object>{
            'name' => fileName,
            'extension' => 'png',
            'author' => 'symphonysandbox',
            'operator' => 'symphonysandbox',
            'type' => 'png',
            'default_security' => 'public',
            'workspace_id' => libraryId
            ,'class' => 'DOC'
        });

       String metadataJson = '{"doc_profile": ' + metadata2 +', "warnings_for_required_and_disabled_fields":true}';

      //  Blob fileBlob = file[0].VersionData;

        // Build multipart body
        String part1 = twoHyphens + boundary + lineEnd +
        'Content-Disposition: form-data; name="metadata"' + lineEnd +
        'Content-Type: application/json' + lineEnd + lineEnd +
        metadataJson + lineEnd;

        String part2Header = twoHyphens + boundary + lineEnd +
            'Content-Disposition: form-data; name="file"; filename="' + fileName + '"' + lineEnd +
            'Content-Type: application/octet-stream' + lineEnd + lineEnd;

        String part3 = lineEnd + twoHyphens + boundary + twoHyphens + lineEnd;

        Blob part1Blob = Blob.valueOf(part1);
        Blob part2HeaderBlob = Blob.valueOf(part2Header);
        Blob fileBlob = EncodingUtil.base64Decode(base64Data);
        Blob part3Blob = Blob.valueOf(part3);

        // Combine all parts via hex
        String fullHex = EncodingUtil.convertToHex(part1Blob) +
                        EncodingUtil.convertToHex(part2HeaderBlob) +
                        EncodingUtil.convertToHex(fileBlob) +
                        EncodingUtil.convertToHex(part3Blob);

        Blob finalBody = EncodingUtil.convertFromHex(fullHex);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://mcciplaw-mobility.imanage.work/api/v2/customers/1/libraries/' +
                        libraryId + '/folders/' + fullFolderId + '/documents');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getAccessToken());
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setBodyAsBlob(finalBody);


        HttpResponse res = http.send(req);
        System.debug('status code ' + res.getStatusCode() + ' and body ' + res.getBody() + ' and message ' + res.getHeader( 'Content-Type' ));
        return res.getBody();
    }

    private static String getAccessToken() {
        // TODO: Replace with real OAuth token logic
        return 'HneQdZLr+c7fofatK1YyLIRJxCUYKTsOsQCdB8fj8ucTKC+ch8fL0eeRReXkS2CO';
    }
}