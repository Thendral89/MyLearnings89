public class UpdateTermNameOnDocketingRules implements Database.Batchable<SObject>, Database.Stateful {

    public string assetName='';
    public UpdateTermNameOnDocketingRules(String assetType){
        assetName = assetType;
    }
    Public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query to fetch all Docketing Rule records that meet the criteria
        String query = 'SELECT SymphonyLF__Asset_Type__c, SymphonyLF__Country_Code__c, Id, ' +
            'SymphonyLF__Jurisdiction__c, SymphonyLF__Life_Cycle_Stage__c, Name, SymphonyLF__Term_Name__c ' +
            'FROM SymphonyLF__Docketing_Rule__c ' +
            'WHERE SymphonyLF__Asset_Type__c = :assetName ' +
            'AND SymphonyLF__Life_Cycle_Stage__c = \'Renewals\' ' +
            'AND (Name LIKE \'1%\' OR Name LIKE \'2%\' OR Name LIKE \'3%\' OR Name LIKE \'4%\' OR ' +
            'Name LIKE \'5%\' OR Name LIKE \'6%\' OR Name LIKE \'7%\' OR Name LIKE \'8%\' OR Name LIKE \'9%\')';
        return Database.getQueryLocator(query);
    }
   
    Public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<SymphonyLF__Docketing_Rule__c> updtrule = new List<SymphonyLF__Docketing_Rule__c>();
       
        for (SObject obj : scope) {
            SymphonyLF__Docketing_Rule__c d = (SymphonyLF__Docketing_Rule__c) obj; // Cast to the specific object type
            // Extract all numeric parts from d.Name (handle decimal values by splitting at the first decimal point)
            String numericPart ='';
            List<String> numericValues = new List<String>();
            if(d.Name.Contains('.')){
                numericPart = d.Name.replaceAll('[^\\d.]', ''); // Allow dash for range (e.g., '9-13')
                numericValues = numericPart.split('\\.');
               
            }
            else{
                numericPart = d.Name.replaceAll('[^\\d-]', '');
                numericValues = numericPart.split('-');
            }
            if (numericValues.size() == 1) {
                // Only one number found, subtract 1 and append it as "Year <number>"
                Integer year = Integer.valueOf(numericValues[0]) - 1;
                d.SymphonyLF__Term_Name__c = 'Year ' + year;
               
            }
             else if (d.Name.Contains('.') && numericValues.size() >= 1) {
                // If decimal value exists, take only the first part as the year
                d.SymphonyLF__Term_Name__c = 'Year ' + numericValues[0];
            }
            else if ( d.Name.Contains('-') && numericValues.size() == 2) {
                // If two numbers found (indicating a range)
                Integer startYear = Integer.valueOf(numericValues[0]);
                Integer endYear = Integer.valueOf(numericValues[1]);
                d.SymphonyLF__Term_Name__c = 'Year ' + startYear + '-' + endYear;
               
            }
            updtrule.add(d);
        }
       
        if (!updtrule.isEmpty()) {
            update updtrule; // Perform the update
        }
    }
   
    Public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed.');
    }
}