public with sharing class HelperFileUpload
{
    public static Map<id,List<ContentVersion>> getAttachmentsForDocuments(List<Id> lstLinkedEntityId)
    {
        Map<id,List<ContentVersion>> mapPatentDocumentDocuments = new Map<Id, List<ContentVersion>>();
        try
        {
            //Get list of ContentDocumentIds of PatentDocumentIds
            List<ContentDocumentLink> objContentDocumentLinkList = new List<ContentDocumentLink>();
            List<Id> idContentDocumentLinkList = new List<Id>();
            Map<id, Id> mapPatentDocumentContentDocuments = new Map<Id, Id>();    
            if (lstLinkedEntityId!=null && lstLinkedEntityId.size()>0)
            {
                if(Schema.sObjectType.ContentDocumentLink.isAccessible() && ContentDocumentLink.sObjectType.getDescribe().isAccessible())
                    objContentDocumentLinkList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :lstLinkedEntityId];
                if (objContentDocumentLinkList!= null && objContentDocumentLinkList.size()>0)
                {
                    if (Schema.sObjectType.ContentDocumentLink .fields.ContentDocumentId.isAccessible() && Schema.sObjectType.ContentDocumentLink .fields.LinkedEntityId.isAccessible())
                    {
                        for(ContentDocumentLink objContentDocumentLink : objContentDocumentLinkList)
                        {
                            idContentDocumentLinkList.add(objContentDocumentLink.ContentDocumentId);
                            if (mapPatentDocumentContentDocuments.containsKey(objContentDocumentLink.ContentDocumentId)==false)
                                mapPatentDocumentContentDocuments.put(objContentDocumentLink.ContentDocumentId, objContentDocumentLink.LinkedEntityId);
                        }
                    }
                }
            
                //Get list of ContentVersionIds of ContentDocumentIds
                List<ContentVersion> objContentDocumentList = new List<ContentVersion>();
                
                if(Schema.sObjectType.ContentVersion.isAccessible() && ContentVersion.sObjectType.getDescribe().isAccessible())
                    objContentDocumentList =[SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c FROM ContentVersion WHERE ContentDocumentId IN :idContentDocumentLinkList ORDER BY CreatedDate];
                if (objContentDocumentList!=null && objContentDocumentList.size()>0)
                {
                    for(ContentVersion objContentVersion : objContentDocumentList)
                    {
                        if (Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() && mapPatentDocumentContentDocuments.containsKey(objContentVersion.ContentDocumentId)==true)
                        {
                            Id idPatentDocumentid = mapPatentDocumentContentDocuments.get(objContentVersion.ContentDocumentId);
                            if (mapPatentDocumentDocuments.containsKey(idPatentDocumentid)==false)
                            {
                                List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                                if (lstContentVersion!= null)
                                    lstContentVersion.add(objContentVersion);
                                mapPatentDocumentDocuments.put(idPatentDocumentid, lstContentVersion);
                                
                            }
                            else
                            {
                                List<ContentVersion> lstContentVersion = mapPatentDocumentDocuments.get(idPatentDocumentid);
                                if (lstContentVersion!= null)
                                    lstContentVersion.add(objContentVersion);
                            }
                        }
                    }
                }
            }
            return mapPatentDocumentDocuments;
        }
        catch(Exception exp)
        {
            /*if (SymphonyIPM__AuditTrail__c.sObjectType.getDescribe().isCreateable() &&Schema.sObjectType.SymphonyIPM__AuditTrail__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.isCreateable())
            {
                SymphonyIPM__AuditTrail__c objAuditTrail = new SymphonyIPM__AuditTrail__c();
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Action__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Action__c.isCreateable())
                    objAuditTrail.SymphonyIPM__Action__c = 'Insert';
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__CObjectName__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__CObjectName__c.isCreateable())
                    objAuditTrail.SymphonyIPM__CObjectName__c = 'HelperAttachments - getAttachmentsForDocuments';
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Description__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Description__c.isCreateable())
                    objAuditTrail.SymphonyIPM__Description__c = exp.getMessage() + exp.getStackTraceString() + 'Size:' + lstLinkedEntityId;
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Status__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Status__c.isCreateable())
                    objAuditTrail.SymphonyIPM__Status__c = 'Fail';
                if (SymphonyIPM__AuditTrail__c.sObjectType.getDescribe().isCreateable() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.isAccessible())    
                insert objAuditTrail;
            }*/
            return null;
        }
    }
    public static Map<id,List<ContentVersion>> getCurrentAttachmentsForDocuments(List<Id> lstLinkedEntityId, List<Id> lstDocumentId)
    {
        Map<id,List<ContentVersion>> mapPatentDocumentDocuments = new Map<Id, List<ContentVersion>>();
        try
        {
            
            //Get list of ContentDocumentIds of PatentDocumentIds
            List<ContentDocumentLink> objContentDocumentLinkList = new List<ContentDocumentLink>();
            List<Id> idContentDocumentLinkList = new List<Id>();
            Map<id, Id> mapPatentDocumentContentDocuments = new Map<Id, Id>();    
            if (lstLinkedEntityId!=null && lstLinkedEntityId.size()>0)
            {
                if(Schema.sObjectType.ContentDocumentLink.isAccessible() && ContentDocumentLink.sObjectType.getDescribe().isAccessible())
                    objContentDocumentLinkList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :lstLinkedEntityId AND ContentDocumentId IN :lstDocumentId];
                if (objContentDocumentLinkList!= null && objContentDocumentLinkList.size()>0)
                {
                    if (Schema.sObjectType.ContentDocumentLink .fields.ContentDocumentId.isAccessible() && Schema.sObjectType.ContentDocumentLink .fields.LinkedEntityId.isAccessible())
                    {
                        for(ContentDocumentLink objContentDocumentLink : objContentDocumentLinkList)
                        {
                            idContentDocumentLinkList.add(objContentDocumentLink.ContentDocumentId);
                            if (mapPatentDocumentContentDocuments.containsKey(objContentDocumentLink.ContentDocumentId)==false)
                                mapPatentDocumentContentDocuments.put(objContentDocumentLink.ContentDocumentId, objContentDocumentLink.LinkedEntityId);
                        }
                    }
                }
            
                //Get list of ContentVersionIds of ContentDocumentIds
                List<ContentVersion> objContentDocumentList = new List<ContentVersion>();
                
                if(Schema.sObjectType.ContentVersion.isAccessible() && ContentVersion.sObjectType.getDescribe().isAccessible())
                    objContentDocumentList =[SELECT Id, Title, FileExtension, ContentDocumentId,Document_Code__c,Comment__c FROM ContentVersion WHERE ContentDocumentId IN :idContentDocumentLinkList ORDER BY CreatedDate];
                if (objContentDocumentList!=null && objContentDocumentList.size()>0)
                {
                    for(ContentVersion objContentVersion : objContentDocumentList)
                    {
                        if (Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() && mapPatentDocumentContentDocuments.containsKey(objContentVersion.ContentDocumentId)==true)
                        {
                            Id idPatentDocumentid = mapPatentDocumentContentDocuments.get(objContentVersion.ContentDocumentId);
                            if (mapPatentDocumentDocuments.containsKey(idPatentDocumentid)==false)
                            {
                                List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                                if (lstContentVersion!= null)
                                    lstContentVersion.add(objContentVersion);
                                mapPatentDocumentDocuments.put(idPatentDocumentid, lstContentVersion);
                                
                            }
                            else
                            {
                                List<ContentVersion> lstContentVersion = mapPatentDocumentDocuments.get(idPatentDocumentid);
                                if (lstContentVersion!= null)
                                    lstContentVersion.add(objContentVersion);
                            }
                        }
                    }
                }
            }
            return mapPatentDocumentDocuments;
        }
        catch(Exception exp)
        {
            /*if (SymphonyIPM__AuditTrail__c.sObjectType.getDescribe().isCreateable() &&Schema.sObjectType.SymphonyIPM__AuditTrail__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.isCreateable())
            {
                SymphonyIPM__AuditTrail__c objAuditTrail = new SymphonyIPM__AuditTrail__c();
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Action__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Action__c.isCreateable())
                    objAuditTrail.SymphonyIPM__Action__c = 'Insert';
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__CObjectName__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__CObjectName__c.isCreateable())
                    objAuditTrail.SymphonyIPM__CObjectName__c = 'HelperAttachments - getAttachmentsForDocuments';
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Description__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Description__c.isCreateable())
                    objAuditTrail.SymphonyIPM__Description__c = exp.getMessage() + exp.getStackTraceString() + 'Size:' + lstLinkedEntityId;
                if(Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Status__c.isAccessible() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.fields.SymphonyIPM__Status__c.isCreateable())
                    objAuditTrail.SymphonyIPM__Status__c = 'Fail';
                if (SymphonyIPM__AuditTrail__c.sObjectType.getDescribe().isCreateable() && Schema.sObjectType.SymphonyIPM__AuditTrail__c.isAccessible())    
                insert objAuditTrail;
            }*/
            return null;
        }
    }
}