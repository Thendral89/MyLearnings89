/**
* @File Name : mvRecordDeletionController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 6, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 6, 2025 |   | Initial Version
**/

public without sharing class mvRecordDeletionController {
	
	@AuraEnabled
	public static String deleteRecordById(String objectApiName, Id recordId) {
    	try {
        	SObject recordToDelete = Database.query('SELECT Id FROM ' + objectApiName + ' WHERE Id = :recordId');
        	delete recordToDelete;
        	return 'Success';
    	} catch (Exception e) {
        	throw new AuraHandledException('Failed to delete record: ' + e.getMessage());
    	}
	}
}