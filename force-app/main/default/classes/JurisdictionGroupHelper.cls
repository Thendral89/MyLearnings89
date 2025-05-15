/* Copyright © 2022 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, May 2022
 */

 global class JurisdictionGroupHelper 
 {
     @AuraEnabled
     public static JurisdictionDetail GetJurisdictionDetail(string clientId,string assetType)
     {
         JurisdictionDetail jurisdictionDetail = new JurisdictionDetail();
         String strAuditTrailLogText = ''; 
         Boolean status;
         try
         {
             List<SymphonyLF__Client_Jurisdiction_Group__c> jurisdictionGroup = new List<SymphonyLF__Client_Jurisdiction_Group__c>();
             List<SymphonyLF__Country__c> country = new List<SymphonyLF__Country__c>();            
             String jurisdictionGroupQuery = 'SELECT Name, Id, SymphonyLF__Jurisdiction_Group_Name_Hyperlink__c  FROM SymphonyLF__Client_Jurisdiction_Group__c WHERE SymphonyLF__Client__c = :clientId';
             String jurisdictionQuery='';
             if(assetType == 'Agreements')
             {
                 jurisdictionQuery = 'SELECT SymphonyLF__Country_Code__c,Name,Id FROM SymphonyLF__Country__c WHERE SymphonyLF__Active__c=true ORDER BY NAME ASC';
             }
             else
             {
                 jurisdictionQuery = 'SELECT SymphonyLF__Country_Code__c,Name,Id FROM SymphonyLF__Country__c WHERE SymphonyLF__Active__c=true  ORDER BY  NAME ASC';//Sort_Order__c ASC NULLS LAST
             }
             jurisdictionGroup = Database.query(jurisdictionGroupQuery);
             country = Database.query(jurisdictionQuery);
             jurisdictionDetail.jurisdictionGroup = jurisdictionGroup;
             jurisdictionDetail.jurisdictions = country;
             status=true;
             strAuditTrailLogText+='GetJurisdictionDetail executed successfully.';
         } 
         catch (Exception e) 
         {
             status=false;
             strAuditTrailLogText +=' Error:' + e.getMessage() + e.getStacktraceString();
         }
         finally 
         { 
             // Audit record creation
             HelperAudit.updateAudit('JurisdictionGroupHelper', strAuditTrailLogText, status);
         } 
         return jurisdictionDetail;
     }
     @AuraEnabled
     public static JurisdictionDetail GetJurisdictionGroupDetail(List<string> jurisdictionGroupId,List<string> jurisdictionId,string assetType){
         JurisdictionDetail jurisdictionDetail = new JurisdictionDetail();
         String strAuditTrailLogText = ''; 
         Boolean status;
         try 
         {
             List<SymphonyLF__Jurisdiction_Group_Detail__c> jurisdictionList=new List<SymphonyLF__Jurisdiction_Group_Detail__c>();            
             List<SymphonyLF__Country__c> country = new List<SymphonyLF__Country__c>();            
             String query = 'Select Id,SymphonyLF__Jurisdiction__r.Name,SymphonyLF__Jurisdiction__c,SymphonyLF__Jurisdiction_Group__r.Name FROM SymphonyLF__Jurisdiction_Group_Detail__c WHERE SymphonyLF__Jurisdiction_Group__c IN :jurisdictionGroupId ORDER BY NAME ASC';
             if(jurisdictionId != null && jurisdictionId.size() > 0)
             {
                 String jurisdictionQuery='';
                 if(assetType == 'Agreements')
                 {
                     jurisdictionQuery = 'SELECT Id,SymphonyLF__Country_Code__c,Name FROM SymphonyLF__Country__c WHERE SymphonyLF__Active__c=true AND Id IN :jurisdictionId';
                 }
                 else
                 {
                     jurisdictionQuery = 'SELECT Id,SymphonyLF__Country_Code__c,Name FROM SymphonyLF__Country__c WHERE 	SymphonyLF__Active__c=true  AND Id IN :jurisdictionId';
                 }
                 country=Database.query(jurisdictionQuery);
             }
             jurisdictionList=Database.query(query);
             jurisdictionDetail.groupDetail = jurisdictionList;
             jurisdictionDetail.jurisdictions = country;
             status=true;
             strAuditTrailLogText+='GetJurisdictionGroupDetail executed successfully.';
         } 
         catch (Exception e) 
         {
             system.debug('exception-'+e.getMessage());
             status=false;
             strAuditTrailLogText +=' Error:' + e.getMessage() + e.getStacktraceString();
         }
         finally 
         { 
             // Audit record creation
             HelperAudit.updateAudit('JurisdictionGroupHelper', strAuditTrailLogText, status);
         } 
         return jurisdictionDetail;
     }
     @AuraEnabled
     public static List<SymphonyLF__Country__c> GetJurisdictions() 
     {
         List<SymphonyLF__Country__c> jurisdictions=new List<SymphonyLF__Country__c>();
         String strAuditTrailLogText = ''; 
         Boolean status;
         try
         {
             String query = 'SELECT Id,SymphonyLF__Country_Code__c,Name FROM SymphonyLF__Country__c WHERE  SymphonyLF__Active__c=true ORDER BY Sort_Order__c ASC NULLS LAST, NAME ASC';
             jurisdictions=Database.query(query);
             system.debug(jurisdictions);
             status=true;
             strAuditTrailLogText+='GetJurisdictions executed successfully.';
         } 
         catch (Exception e) 
         {
             status=false;
             strAuditTrailLogText +=' Error:' + e.getMessage() + e.getStacktraceString();
         }
         finally 
         { 
             // Audit record creation
             HelperAudit.updateAudit('JurisdictionGroupHelper', strAuditTrailLogText, status);
         } 
         return jurisdictions;
     }
     public class JurisdictionDetail
     {
         @AuraEnabled
         public List<SymphonyLF__Client_Jurisdiction_Group__c> jurisdictionGroup{set;get;}
         @AuraEnabled
         public List<SymphonyLF__Country__c> jurisdictions{set;get;}
         @AuraEnabled
         public List<SymphonyLF__Jurisdiction_Group_Detail__c> groupDetail{set;get;}
     }
 }