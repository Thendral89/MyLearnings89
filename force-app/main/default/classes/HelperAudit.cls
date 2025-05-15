public class HelperAudit 
{
	public static void updateAudit(string objectName, string message, boolean isSuccess)
    {
        if 
		(
            SymphonyLF__AuditTrail__c.sObjectType.getDescribe().isCreateable() 
            &&Schema.sObjectType.SymphonyLF__AuditTrail__c.isAccessible() 
            && Schema.sObjectType.SymphonyLF__AuditTrail__c.isCreateable()
        )
        {
            SymphonyLF__AuditTrail__c objAuditTrail = new SymphonyLF__AuditTrail__c();
            if(Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__Action__c.isAccessible() && Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__Action__c.isCreateable())
                objAuditTrail.SymphonyLF__Action__c = 'Insert';
            if(Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__CObjectName__c.isAccessible() && Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__CObjectName__c.isCreateable())
                objAuditTrail.SymphonyLF__CObjectName__c = objectName;
            if(Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__Description__c.isAccessible() && Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__Description__c.isCreateable())
                objAuditTrail.SymphonyLF__Description__c = message; //exp.getMessage() + exp.getStackTraceString();
            if(Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__Status__c.isAccessible() && Schema.sObjectType.SymphonyLF__AuditTrail__c.fields.SymphonyLF__Status__c.isCreateable())
            {
                if (isSuccess)
                    objAuditTrail.SymphonyLF__Status__c = 'Success';
                else
                    objAuditTrail.SymphonyLF__Status__c = 'Fail';
            }
            if (SymphonyLF__AuditTrail__c.sObjectType.getDescribe().isCreateable() && Schema.sObjectType.SymphonyLF__AuditTrail__c.isAccessible())    
                INSERT objAuditTrail;
        }
    }
}