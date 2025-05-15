public class cmpAPEmails {

   @AuraEnabled
   public static void Tracker(string PatentId) {
       List<string> TrackerIds = new List<string>();
       List<string> ObjDocketNumbers = new List<string>();
       List<Related_Email_Tracker__c> RelatedTracker = new List<Related_Email_Tracker__c>();
       string objApiName='';
       
       List<SymphonyLF__Email_Tracker__c> ObjContents = [Select Id,SymphonyLF__Email_Message_Id__c,
                                                         SymphonyLF__Short_Subject__c,
                                                         SymphonyLF__Email_RelatedToId__c,
                                                         SymphonyLF__Related_Object_API_Name__c
                                                         FROM SymphonyLF__Email_Tracker__c 
                                                         Where Id='a0TWF000002TJ6v2AG'];
        if(ObjContents.size()>0){
            for(SymphonyLF__Email_Tracker__c rmail: ObjContents){
                
                
                string input=rmail.SymphonyLF__Short_Subject__c;
        		String cleanedInput = input.replace('[', '').replace(']', '');
        		string[] splitArray = cleanedInput.Split(',');
        		List<string> stringList = new List<string>(splitArray);
                ObjDocketNumbers.addAll(stringList);
                system.debug('ObjDocketNumbers ' + ObjDocketNumbers);
                
                for(Integer i = 0; i < ObjDocketNumbers.size(); i++) { 
                	Related_Email_Tracker__c RelatedTr = new Related_Email_Tracker__c();
                    RelatedTr.RelatedToId__c=rmail.SymphonyLF__Email_RelatedToId__c;
                    RelatedTr.Docket_Number__c=ObjDocketNumbers[i];
                    RelatedTr.Email_Tracker__c=rmail.Id;
                    RelatedTracker.add(RelatedTr);
                }
            }
        }
       
       
       if(RelatedTracker.size()>0)
           insert RelatedTracker;
       

       
       
   }
    
}