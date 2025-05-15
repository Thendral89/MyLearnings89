public virtual with sharing class mvSObjectDomain {

    public List<SObject> records {get; private set;}
    public Schema.DescribeSObjectResult sObjectDescribe {get; private set;}
  
    // Useful during unit testing to assert at a more granular and robust level for errors raised during the various trigger events
    public static ErrorFactory Errors {get; private set;}
  
    static {
      Errors = new ErrorFactory();
    }
  
    public mvSObjectDomain(List<SObject> sObjectList) {
      records = sObjectList;
      sObjectDescribe = records.getSObjectType().getDescribe();
    }
  
    public virtual void onApplyDefaults() {}
  
    public virtual void onValidate() {}
  
    public virtual void onValidate(Map<Id, SObject> existingRecords) {}
  
    public virtual void onBeforeInsert() {}
  
    public virtual void onBeforeUpdate(Map<Id, SObject> existingRecords) {}
  
    public virtual void onBeforeDelete() {}
  
    public virtual void onAfterInsert() {}
  
    public virtual void onAfterUpdate(Map<Id, SObject> existingRecords) {}
  
    public virtual void onAfterDelete() {}
  
    public virtual void onAfterUndelete() {}
  
    public virtual void handleBeforeInsert() {
      onApplyDefaults();
      onBeforeInsert();
    }
  
    public virtual void handleBeforeUpdate(Map<Id, SObject> existingRecords) {
      onBeforeUpdate(existingRecords);
    }
  
    public virtual void handleBeforeDelete() {
      onBeforeDelete();
    }
  
    public virtual void handleAfterInsert() {
      onValidate();
      onAfterInsert();
    }
  
    public virtual void handleAfterUpdate(Map<Id, SObject> existingRecords) {
      onValidate(existingRecords);
      onAfterUpdate(existingRecords);
    }
  
    public virtual void handleAfterDelete() {
      onAfterDelete();
    }
  
    public virtual void handleAfterUndelete() {
      onAfterUndelete();
    }
  
    public SObjectType getSObjectType() {
      return sObjectDescribe.getSObjectType();
    }
  
    public List<SObject> getRecords() {
      return records;
    }
  
    public virtual Boolean isTriggerDisabled() {
      return false;
    }
  
    public static void triggerHandler(Type domainClass) {
      if (Trigger.isExecuting) {
        triggerHandler(domainClass, Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.oldMap);
      }
    }
  
    @TestVisible
    private static void triggerHandler(Type domainClass, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete, List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
      Type constructableClass = domainClass.getName().endsWith('Constructor') ? Type.forName(domainClass.getName()) : Type.forName(domainClass.getName() + '.Constructor');
      IConstructable domainConstructor = (IConstructable)constructableClass.newInstance();
      mvSObjectDomain domainObject;
      if (isDelete) {
          domainObject = domainConstructor.construct(oldRecordsMap.values());
      } else {
          domainObject = domainConstructor.construct(newRecords);
      }
  
      if (domainObject.isTriggerDisabled()) {
        return;
      }
  
      if (isBefore) {
        if (isInsert) {
          domainObject.handleBeforeInsert();
        } else if (isUpdate) {
          domainObject.handleBeforeUpdate(oldRecordsMap);
        } else if (isDelete) {
          domainObject.handleBeforeDelete();
        }
      } else {
        if (isInsert) {
          domainObject.handleAfterInsert();
        } else if (isUpdate) {
          domainObject.handleAfterUpdate(oldRecordsMap);
        } else if (isDelete) {
          domainObject.handleAfterDelete();
        } else if (isUndelete) {
          domainObject.handleAfterUndelete();
        }
      }
    }
  
    // Necessary to dynamically instantiate a constructor with a parameter for trigger handling
    public interface IConstructable {
        mvSObjectDomain construct(List<SObject> sObjectList);
    }
  
    // Ensures logging of errors in the Domain context for later assertions in tests
    public String error(String message, SObject record) {
      return Errors.error(this, message, record);
    }
  
    // Ensures logging of errors in the Domain context for later assertions in tests
    public String error(String message, SObject record, SObjectField field) {
      return Errors.error(this, message, record, field);
    }
  
    // Ensures logging of errors in the Domain context for later assertions in tests
    public class ErrorFactory {
      private List<Error> errorList = new List<Error>();
  
      @testVisible
      private ErrorFactory() {}
  
      public String error(String message, SObject record) {
        return error(null, message, record);
      }
  
      private String error(mvSObjectDomain domain, String message, SObject record) {
        ObjectError objectError = new ObjectError();
        objectError.domain = domain;
        objectError.message = message;
        objectError.record = record;
        errorList.add(objectError);
        return message;
      }
  
      public String error(String message, SObject record, SObjectField field) {
        return error(null, message, record, field);
      }
  
      private String error(mvSObjectDomain domain, String message, SObject record, SObjectField field) {
        FieldError fieldError = new FieldError();
        fieldError.domain = domain;
        fieldError.message = message;
        fieldError.record = record;
        fieldError.field = field;
        errorList.add(fieldError);
        return message;
      }
  
      public List<Error> getAll() {
        return errorList.clone();
      }
  
      public void clearAll() {
        errorList.clear();
      }
    }
  
    // Ensures logging of errors in the Domain context for later assertions in tests
    public virtual class FieldError extends ObjectError {
      public SObjectField field;
  
      public FieldError() {}
    }
  
    // Ensures logging of errors in the Domain context for later assertions in tests
    public virtual class ObjectError extends Error {
      public SObject record;
  
      public ObjectError() {}
    }
  
    // Ensures logging of errors in the Domain context for later assertions in tests
    public abstract class Error {
      public String message;
      public mvSObjectDomain domain;
    }
  
    public class DomainException extends Exception {}
  }