public without sharing class ShareObjectSelector {
    String shareObject;
    List<String> fields;
    public ShareObjectSelector(String sObjectShare) {
        this.shareObject = sObjectShare;
        setFields();
    }

    public List<ShareObjectSelectorJSON> selectByParentIdAndUserOrGroupIdAndRowCause(Set<Id> recordIds, Set<Id> userOrGroupIds, Set<String> rowCauses){
		rowCauses.add('Owner');
        List<sObject> shareRecords = Database.query(
            ' SELECT ' + String.join( this.fields, ', ') +
            ' FROM ' + this.shareObject +
            ' WHERE ParentId IN :recordIds ' +
            '   AND UserOrGroupId IN :userOrGroupIds ' +
            '   AND RowCause IN :rowCauses'
        );

        List<ShareObjectSelectorJSON> toReturn = new List<ShareObjectSelectorJSON>();
        for(sObject s : shareRecords){
            ShareObjectSelectorJSON j = new ShareObjectSelectorJSON();
            j.shareObjectRecordId = (Id) s.get('Id') ;
            j.parentId = (Id) s.get('ParentId') ;
            j.userOrGroupId = (Id) s.get('UserOrGroupId') ;
            j.rowCause = String.valueOf( s.get('RowCause') );
            j.accessLevel = String.valueOf( s.get('AccessLevel') );

            j.shareObjectName = this.shareObject;
            
            j.record = s;
            
            toReturn.add( j );
        }
        return toReturn;
    }

	private void setFields(){
        this.fields = new List<String>{
            'Id',
            'ParentId',
            'UserOrGroupId',
            'RowCause',
            'AccessLevel'
        };
	} 
}