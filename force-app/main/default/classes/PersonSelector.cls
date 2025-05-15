public with sharing class PersonSelector {
    private List<String> fields;

    public PersonSelector() {

    }

    public void setFields(List<String> fields){
        this.fields = fields;
    }

    public Map<Id, SymphonyLF__Person__c> selectByIdOrUserIds(Set<Id> recordIds, Set<Id> userIds){
        if( (recordIds == null || recordIds.size() == 0) && (userIds == null || userIds.size() == 0) ){
            return new Map<Id, SymphonyLF__Person__c	>();
        }

        String query = ' SELECT ' + String.join(fields, ', ') +
                ' FROM SymphonyLF__Person__c	' +
                ' WHERE Id IN :recordIds OR SymphonyLF__User__c IN :userIds ';

        return new Map<Id, SymphonyLF__Person__c	>(
            (List<SymphonyLF__Person__c>)
            Database.query(
                query
            )
        );
    }
}