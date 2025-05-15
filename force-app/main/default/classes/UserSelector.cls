public with sharing class UserSelector {
    private List<String> fields;

    public UserSelector() {

    }

    public void setFields(List<String> fields){
        this.fields = fields;
    }

    public Map<Id, User> selectById(Set<Id> recordIds){
        if(recordIds == null || recordIds.size() == 0){
            return new Map<Id, User>();
        }

        return new Map<Id, User>(
            (List<User>)
            Database.query(
                ' SELECT ' + String.join(fields, ', ') +
                ' FROM User' +
                ' WHERE Id IN :recordIds'
            )
        );
    }
}