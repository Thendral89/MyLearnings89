public with sharing class DatatableLookupHelper {
    @AuraEnabled//(cacheable=true)
    public static SymphonyLF__Office_Agent__c getRecordDetails(String recordId) {
        SymphonyLF__Office_Agent__c lawFirm=new SymphonyLF__Office_Agent__c();
        String strAuditTrailLogText = ''; 
        Boolean status;
        try 
        {
            String query='SELECT Name,Id FROM SymphonyLF__Office_Agent__c where Id=:recordId';            
            lawfirm=Database.query(query);
            system.debug(lawfirm);
            status=true;
            strAuditTrailLogText +='GetRecordDetails executed successfully.';
        } 
        catch (Exception e) {
            status = false;
            strAuditTrailLogText +=' Error:' + e.getMessage() + e.getStacktraceString();
        }
        finally
        {
            // Audit record creation
            HelperAudit.updateAudit('DatatableLookupHelper', strAuditTrailLogText, status);
        }
        return lawfirm; 
    }
    @AuraEnabled//(cacheable=true)
    public static SymphonyLF__Currency__c getCurrencyDetails(String recordId) {
        SymphonyLF__Currency__c curency=new SymphonyLF__Currency__c();
        String strAuditTrailLogText = ''; 
        Boolean status;
        try 
        {
            String query='SELECT Name,Id FROM SymphonyLF__Currency__c where Id=:recordId';            
            curency=Database.query(query);
            system.debug(curency);
            status=true;
            strAuditTrailLogText +='GetCurrencyDetails executed successfully.';
        } 
        catch (Exception e) {
            status = false;
            strAuditTrailLogText +=' Error:' + e.getMessage() + e.getStacktraceString();
        }
        finally
        {
            // Audit record creation
            HelperAudit.updateAudit('DatatableLookupHelper', strAuditTrailLogText, status);
        }
        return curency; 
    }
}