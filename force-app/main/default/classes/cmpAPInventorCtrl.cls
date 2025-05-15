public class cmpAPInventorCtrl {

     @AuraEnabled
    public static String RowActionsDelete(String recordId) {
        Id id = Id.valueOf(recordId);
        delete id.getSobjectType().newSObject(id);
        return id;
    }
    
    @AuraEnabled
    public static boolean getAccess(string PatentId)  {
        Id profileId=userinfo.getProfileId();
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
		system.debug('ProfileName'+profileName);
        boolean IsCorrections=false;
           if (profileName == 'System Administrator') {
            	IsCorrections=true;
           } else  if (profileName == 'Ops admin') {
            	IsCorrections=true;
           } else {
               IsCorrections=false;
           }
       
        return IsCorrections;
        
        
    }
    
      @auraEnabled
      public static List<APInventorCtrlWrapper> FetchPatentData(string patentID) {
          List<DocuSignReviewer__c> objOptions = new List<DocuSignReviewer__c>();
          List<DocuSignReviewer__c> ObjInnovators = new List<DocuSignReviewer__c>();
          set<string> ObjectId = new set<string>();
          
          List<DocuSignReviewer__c > DocuSignReviewers = [SELECT Id,Inventor_Name__c,Person__c,recordId__c
                                                          FROM DocuSignReviewer__c 
                                                          WHERE recordId__c =:patentID ];
          if(DocuSignReviewers.size()>0){
              for(DocuSignReviewer__c person : DocuSignReviewers ) {
                  DocuSignReviewer__c ObjInnovator = new DocuSignReviewer__c();
                  ObjInnovator.Id = person.Id;
                  ObjInnovator.Inventor_Name__c=person.Inventor_Name__c;
                  ObjInnovator.Person__c = person.Person__c;
                  ObjInnovators.add(ObjInnovator);
              }
          }
         
          if(ObjInnovators.size()>0)
              update ObjInnovators;
          
      		List<APInventorCtrlWrapper> persons = getDocuSignePatentsReviewers(patentID);
            return persons;  
     
    }
    
      @auraEnabled
      public static List<APInventorCtrlWrapper> getDocuSignePatentsReviewers(string patentID) {
          List<APInventorCtrlWrapper> objOptions = new List<APInventorCtrlWrapper>();
          boolean IsAdmin= getAccess(patentID);
        try{
            List<DocuSignReviewer__c > Inventors = [SELECT Id,Inventor_Name__c,Person__c,Email__c
                                                    FROM DocuSignReviewer__c 
                                                    WHERE recordId__c =:patentID ];
             if (Inventors.Size() >0 ) {
                 for(DocuSignReviewer__c person : Inventors ) {
                     APInventorCtrlWrapper objOption = new APInventorCtrlWrapper();
                     objOption.Id = person.Id;
                     objOption.PersonId = person.Person__c;
                     objOption.Name = person.Inventor_Name__c;
                     objOption.Email = person.Email__c; 
                     objOption.IsAdmin=IsAdmin;
                     objOptions.add(objOption);
                 }
             }
            
      
            return objOptions;  
            
        }catch(Exception e){
            return null;
        }
       
    }
    
}