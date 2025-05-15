/***************************************************************
* Class Name   : mvWrappers
* Purpose      : Wrappers Class used for denoting
*                all wrappers in a single class
* Created By   : Siva Nekkalapudi
* Created On   : Feb 08, 2025
* Version History  : 
* --------------------------------------------------------------
  No   Date         Changes
* --------------------------------------------------------------
  1    08-FEB-2025  Initial Version
* **************************************************************/
public class mvWrappers {
  public class RecordPermissionWrapper {
      @AuraEnabled
      public Boolean canRead = false;
      @AuraEnabled
      public Boolean canCreate = false;
      @AuraEnabled
      public Boolean canEdit = false;
      @AuraEnabled
      public Boolean canDelete = false;
  }

  public class clientRestrictionsWrapper {
      @AuraEnabled public String symphonyId;
      @AuraEnabled public Id recordId;
      @AuraEnabled public String type;
      @AuraEnabled public String contactName;
      @AuraEnabled public Id contactRecordId;
      @AuraEnabled public String phone;
      @AuraEnabled public String email;
      @AuraEnabled public Id userId;
      @AuraEnabled public String status;
      @AuraEnabled public RecordPermissionWrapper recordPermission;
  }

  public class MatterEngagementModelWrapper {
      @AuraEnabled public String symphonyId;
      @AuraEnabled public Id recordId;
      @AuraEnabled public String cemName;
      @AuraEnabled public Id cemId;
      @AuraEnabled public String type;
      @AuraEnabled public String contactName;
      @AuraEnabled public Id contactRecordId;
      @AuraEnabled public Boolean isDefault;
      @AuraEnabled public Boolean isActive;
      @AuraEnabled public String sequence;
      @AuraEnabled public String phone;
      @AuraEnabled public String email;
      @AuraEnabled public String contactRecordType;
      @AuraEnabled public RecordPermissionWrapper recordPermission;
  }

  public with sharing class ClientEngagementModelWrapper {
      @AuraEnabled public String symphonyId;
      @AuraEnabled public Id recordId;
      @AuraEnabled public String type;
      @AuraEnabled public String contactName;
      @AuraEnabled public Id contactRecordId;
      @AuraEnabled public Id assetIntakePersonnelRecordId;
      @AuraEnabled public Id assetIntakeJurisdictionRelationRecordId;
      @AuraEnabled public Boolean isSelected;
      @AuraEnabled public Boolean isDefault;
      @AuraEnabled public Boolean isActive;
      @AuraEnabled public String ipMatters;
      @AuraEnabled public String jurisdictions;
      @AuraEnabled public String phone;
      @AuraEnabled public String email;
      @AuraEnabled public String contactRecordType;
      @AuraEnabled public DateTime createdDateTime;
      @AuraEnabled public RecordPermissionWrapper recordPermission;
  }

   public class clientAddressWrapper {
      @AuraEnabled public String street;
      @AuraEnabled public String city;
      @AuraEnabled public String stateCode;
      @AuraEnabled public String postal;
      @AuraEnabled public String countryCode;
  }

  public class ObjectPermissionsWrapper {
      @AuraEnabled
      public Boolean canRead = false;
      @AuraEnabled
      public Boolean canCreate = false;
      @AuraEnabled
      public Boolean canEdit = false;
      @AuraEnabled
      public Boolean canDelete = false;
  }

  public class mvPortfolioWrapper {
      @AuraEnabled public String assetTitle;
      @AuraEnabled public String assetType;
      @AuraEnabled public String docketNumber;
      @AuraEnabled public String recordId;
      @AuraEnabled public String assetJurisdiction;
      @AuraEnabled public String assetStatus;
      @AuraEnabled public String assetCaseType;
  }

  public class IntakeWrapper {
      @AuraEnabled public Id clientId;
      @AuraEnabled public String newFamilyName;
      @AuraEnabled public String existingFamilyId;
      @AuraEnabled public String assetType;
      @AuraEnabled public String department;
      @AuraEnabled public String conflictCheckId;
      @AuraEnabled public String contentId;
      @AuraEnabled public String disputeSubType;
      @AuraEnabled public String disputeType;
  }
  

  public class AssetIntakeWrapper{
      @AuraEnabled public Id recordId;
      @AuraEnabled public String recordName;
      @AuraEnabled public Id clientId;
      @AuraEnabled public String clientName;
      @AuraEnabled public Id familyId;
      @AuraEnabled public String familyTitle;
      @AuraEnabled public String familyDocketNumber;
      @AuraEnabled public String status;
      @AuraEnabled public String assetType;
      @AuraEnabled public String currentPage;
      @AuraEnabled public String createdByName;
      @AuraEnabled public Id createdById;
      @AuraEnabled public Id conflictCheckId;
      @AuraEnabled public String conflictCheckName;
      @AuraEnabled public String disputeSubType;
      @AuraEnabled public String disputeType;
      @AuraEnabled public String title;
  }

  public class ApplicantsWrapper{
      @AuraEnabled
      public Id recordId;
      @AuraEnabled
      public String recordName;
      @AuraEnabled
      public Id applicantId;
      @AuraEnabled 
      public String isExistingApplicant;
      @AuraEnabled 
      public String address;
      @AuraEnabled
      public String name;
      @AuraEnabled
      public String clientClassification;
      @AuraEnabled
      public String currencyCode;
      @AuraEnabled
      public Id currencyId;
      @AuraEnabled
      public String entitySize;
      @AuraEnabled public Id assetIntakeJurisdictionRelationRecordId;
      @AuraEnabled
      public Boolean isSelected;
      @AuraEnabled
      public String street;
      @AuraEnabled
      public String city ;
      @AuraEnabled
      public String stateCode;
      @AuraEnabled
      public String postal ;
      @AuraEnabled
      public String countryCode;
  }

  public class InventorsWrapper{
      @AuraEnabled
      public Id recordId;
      @AuraEnabled public String recordName;
      @AuraEnabled public String inventorId;
      @AuraEnabled public String inventorName;
      @AuraEnabled public String isExistingInventor;
      @AuraEnabled public String address;
      @AuraEnabled public string emailAddress;
      @AuraEnabled public string nationality;
      @AuraEnabled public string phoneNumber;
      @AuraEnabled public Id assetIntakeJurisdictionRelationRecordId;
      @AuraEnabled public Boolean isSelected;
      @AuraEnabled
      public String street;
      @AuraEnabled
      public String city ;
      @AuraEnabled
      public String stateCode;
      @AuraEnabled
      public String postal ;
      @AuraEnabled
      public String countryCode;
       @AuraEnabled
      public Boolean primaryInventor ;
      @AuraEnabled
      public Decimal sequence;
  }

  public class AssetIntakeJurisdictionWrapper{
      @AuraEnabled
      public Id assetIntakeId;
      @AuraEnabled
      public Id assetIntakeJurisdictionId;
      @AuraEnabled
      public String recordName;
      @AuraEnabled
      public Id jurisdictionId;
      @AuraEnabled 
      public String jurisdictionName;
      @AuraEnabled 
      public String caseType;
      @AUraEnabled
      public String docketType;
      @AUraEnabled
      public Id assignedToId;
      @AUraEnabled
      public String assignedToName;
      @AUraEnabled
      public String eventName;
      @AUraEnabled
      public Date dueDate;
      @AUraEnabled
      public Date eventDate;
      @AUraEnabled
      public String clientReferenceNumber;

      @AuraEnabled
      public List<ClientEngagementModelWrapper> clientEngagementModels;
      @AuraEnabled 
      public List<ApplicantsWrapper> applicants;
      @AuraEnabled 
      public List<InventorsWrapper> inventors;
      @AuraEnabled 
      public List<ClassesGoodsWrapper> classes;
  }

  public class ClassesGoodsWrapper{
      @AuraEnabled public Id recordId;
      @AuraEnabled public String recordName;

      @AuraEnabled public String className;
      @AuraEnabled public String subclass;
      @AuraEnabled public Id jurisdictionId;
      @AuraEnabled public String jurisdictionName;
      @AuraEnabled public String languages;
      @AuraEnabled public String specification;

      @AuraEnabled public String instanceType;


      @AuraEnabled public Id clientSpecificationId;
      @AuraEnabled public String customMetadataType;

      @AuraEnabled public String isExistingClass;

      @AuraEnabled public Id assetIntakeJurisdictionRelationRecordId;
      @AuraEnabled public Boolean isSelected;
  }

  public class MattersWrapper{
      @AuraEnabled public Id recordId;
      @AuraEnabled public String title;
      @AuraEnabled public String docketNumber;
      @AuraEnabled public String caseType;
      @AuraEnabled public String jurisdiction;
  }

  public class mvDocketWrapper {
      @AuraEnabled public String recordId;
      @AuraEnabled public String recordName;
      @AuraEnabled public String recordStatus;
      @AuraEnabled public String parentRecordId;
      @AuraEnabled public String parentAssetId;
      @AuraEnabled public String assetTitle;
      @AuraEnabled public Date dueDate;
      @AuraEnabled public Date completionDate;
      @AuraEnabled public Date closedDate;
      @AuraEnabled public String docketNumber;
      @AuraEnabled public String docketReporting;
      @AuraEnabled public String docketComments;
      @AuraEnabled public String allComments;
      @AuraEnabled public String assignedToId;
      @AuraEnabled public String assignedTo;
      @AuraEnabled public String docketTrigger;
      @AuraEnabled public String docketAction;
      @AuraEnabled public String docketStatus;
      @AuraEnabled public String reasonToClose;
      @AuraEnabled public String reasonToComplete;
      @AuraEnabled public Boolean isClosed;
      @AuraEnabled public Boolean isCompleted;
      @AuraEnabled public Boolean isOpen;
      @AuraEnabled public Boolean isSelected;

      @AuraEnabled public String assetType;
      @AuraEnabled public String assetApiName;

      @AuraEnabled public List<documentRecord> documentRecords;
  }

  public class documentRecord {
      @AuraEnabled public String documentId;
      @AuraEnabled public String documentType;
      @AuraEnabled public String documentTitle;
  }

  public class docketExternalReportRecord { 
      @AuraEnabled public String recordId;
      @AuraEnabled public String recordName;
      @AuraEnabled public String recordEventName;
      @AuraEnabled public String recordComments;
      @AuraEnabled public String recordStatus;
      @AuraEnabled public String assetDocketNumber;
      @AuraEnabled public String assetId;
      @AuraEnabled public String assetTitle;
      @AuraEnabled public String assignedTo;
      @AuraEnabled public String initiatedBy;
      @AuraEnabled public String initiatedById;
      @AuraEnabled public String reportOutStatus;
      @AuraEnabled public Date initiationDate;
      @AuraEnabled public Date lastModifiedDate;
      @AuraEnabled public Date recordDueDate;  
    }

    public class serviceResponseWrapper{
      @AuraEnabled
      public String serviceName;
      @AuraEnabled
      public String groupBy;
      @AuraEnabled
      public String serviceStatus;
      @AuraEnabled
      public String serviceErrorMessage;
      @AuraEnabled
      public List<sObject> serviceOutput;
      @AuraEnabled
      public String serviceLabels;
      @AuraEnabled
      public String servicequeryString;
      @AuraEnabled
      public List<String> serviceLabelsList;
      @AuraEnabled
      public Map<String,String> serviceIdObjMap;
      @AuraEnabled
      public mvWrappers.ObjectPermissionsWrapper objectPermission;
      @AuraEnabled
      public Map<Id,mvWrappers.RecordPermissionWrapper> recordPermission; 
      @AuraEnabled
      public String childObjectApiName;
      @AuraEnabled 
      public String childObjectLabel;
      @AuraEnabled 
      public String lookupField;
      @AuraEnabled 
      public String actionFields;
      @AuraEnabled 
      public String recordType;
  }
  public class Keyword{
      @AuraEnabled public String keywordName;
      @AuraEnabled public Id associationId;
      @AuraEnabled public Id keywordId;
  }
}