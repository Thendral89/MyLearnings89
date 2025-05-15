global with sharing class AdvanceSearchCloseDockets extends advs.ProcessingExtension {
    global AdvanceSearchCloseDockets() {

    }

    final static Set<String> lookupFieldsToMatter = new Set<String>{
        'SymphonyLF__Agreement_and_Contract__c',
        'SymphonyLF__Copyright__c',
        'SymphonyLF__Design__c',
        'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__General_Matter__c',
        'SymphonyLF__Patent__c',
        'SymphonyLF__Renewal__c',
        'SymphonyLF__Trademark__c'
    };

    global override void processAfterCrud() {
      // Do some post processing here
      Map<String, Object> argumentsMap = (Map<String, Object>) JSON.deserializeUntyped(this.arguments);
      Boolean closeDockets = Boolean.valueOf(argumentsMap.get('closeDockets'));
      String reasonToClose = String.valueOf(argumentsMap.get('reasonToClose'));
      Date closedDate = Date.today();
      Id closedBy = String.valueOf(argumentsMap.get('closedBy'));

      if(closeDockets == false){
        return;
      }

      Set<Id> recordIds = new Set<Id>();
      for(sObject record : this.records){
        recordIds.add(record.Id);
      }

      Set<String> openStatuses = new Set<String>{
        'Open',
        'Action Initiated'
      };

      Set<String> fields = new Set<String>{
        'Id',
        'SymphonyLF__Status__c',
        'SymphonyLF__Reason_to_Close__c',
        'SymphonyLF__Closed_By__c',
        'SymphonyLF__Closed_Date__c',
        'SymphonyLF__Completed_By__c'
      };

      String query = '';
      query += ' SELECT ' + String.join( fields ,', ' );
      query += ' FROM SymphonyLF__Docketing_Activity__c ';
      query += ' WHERE ';
      query += ' SymphonyLF__Status__c IN :openStatuses ';

      List<String> lookupsQuery = new List<String>();
      for(String lookup : lookupFieldsToMatter){
        lookupsQuery.add( lookup + ' IN :recordIds ');
      }
      
      query += ' AND ' + ' ( ' + String.join( lookupsQuery,' OR ' ) + ' ) ';

      List<SymphonyLF__Docketing_Activity__c> dockets = (List<SymphonyLF__Docketing_Activity__c>) Database.query( query );

      if(dockets.size() == 0){
        return;
      }

      Set<Id> docketIds = new Set<Id>();
      for(SymphonyLF__Docketing_Activity__c d : dockets){
        d.SymphonyLF__Status__c = 'Closed';
        d.SymphonyLF__Is_Closed__c = true;
        d.SymphonyLF__Reason_to_Close__c = reasonToClose;
        d.SymphonyLF__Closed_By__c = closedBy;
        d.SymphonyLF__Completed_By__c = closedBy;
        d.SymphonyLF__Closed_Date__c = closedDate;

        docketIds.add(d.Id);
      }
      
      update dockets;

      List<SymphonyLF__Docketing_Activity__c> updatedDockets = [
        SELECT 
          Id, SymphonyLF__Reason_to_Close__c 
        FROM 
          SymphonyLF__Docketing_Activity__c
        WHERE 
          Id IN :docketIds
      ];

      List<SymphonyLF__Docketing_Activity__c> reupdate = new List<SymphonyLF__Docketing_Activity__c>(); // Having to do as OOB is overriding the comments for adjusted expiry MCC-1732
      for(SymphonyLF__Docketing_Activity__c d : updatedDockets){
        if(d.SymphonyLF__Reason_to_Close__c != reasonToClose){
          d.SymphonyLF__Reason_to_Close__c = reasonToClose;

          reupdate.add( d );
        }
      }

      if(reupdate.size() > 0){
        update reupdate;
      }
    }
}