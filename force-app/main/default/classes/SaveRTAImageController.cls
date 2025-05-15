public class SaveRTAImageController {
    public String result { get; private set; }
    
    public PageReference saveImage() {
        String imageUrl = ApexPages.currentPage().getParameters().get('url');
        
        try {
            PageReference pageRef = new PageReference(imageUrl);
            Blob imageBlob = pageRef.getContent();
            
            if (imageBlob != null) {
                ContentVersion cv = new ContentVersion();
                cv.VersionData = imageBlob;
                cv.Title = 'RTA_Image_' + DateTime.now().getTime();
                cv.PathOnClient = 'RTAImage.jpg';
                cv.IsMajorVersion = true;
                
                insert cv;
                
                result = 'Success: ' + cv.Id;
            } else {
                result = 'Failed to retrieve image content';
            }
        } catch(Exception e) {
            result = 'Error: ' + e.getMessage();
        }
        
        return null;
    }
}