public with sharing class TrademarkImageController {
    @AuraEnabled
    public static String fetchContentFromMark(String recordId, String objectApiName){
        String contentId = '';

        if(String.isBlank(recordId)){
           return contentId;
        }

        Id imageId;

        if(objectApiName == 'SymphonyLF__Trademark__c'){
            SymphonyLF__Trademark__c existingMark = [SELECT 
                Id,
                SymphonyLF__TM_Image_ID__c
                FROM
                SymphonyLF__Trademark__c
                WHERE Id = :recordId
            ];
            if( String.isNotBlank(existingMark.SymphonyLF__TM_Image_ID__c) ){
                imageId = existingMark.SymphonyLF__TM_Image_ID__c;
            }
        }
        else if(objectApiName == 'SymphonyLF__Mark__c'){
            SymphonyLF__Mark__c existingMark = [SELECT 
                Id,
                SymphonyLF__TM_Image_ID__c
                FROM
                SymphonyLF__Mark__c
                WHERE Id = :recordId
            ];
            System.debug('existingMark.SymphonyLF__TM_Image_ID__c ' + existingMark.SymphonyLF__TM_Image_ID__c);
            if( String.isNotBlank(existingMark.SymphonyLF__TM_Image_ID__c) ){
                imageId = existingMark.SymphonyLF__TM_Image_ID__c;
            }
        }
        
        System.debug('imageId 1 '+ imageId);
        if(imageId != null){
            System.debug('imageId 2 '+ imageId);
            List<ContentVersion> contentVersions = [
                SELECT Id 
                FROM ContentVersion 
                WHERE ContentDocumentId =: imageId 
                ORDER BY CreatedDate DESC LIMIT 1
            ];

            System.debug('contentVersions '+ contentVersions.size());
            if(contentVersions.size() > 0){
                contentId = String.valueOf(contentVersions[0].Id);
            }
        }
        System.debug('contentId' + contentId);
        return contentId;   
    }
}