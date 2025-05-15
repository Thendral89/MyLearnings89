global with sharing class cmpAPiMngGetDocWrraper {

    global data data;
    global class data {
        global list<results> results{get;set;}
    }
    
	global class results {
		global String database {get;set;} 
		global String document_number {get;set;} 
		global String version {get;set;} 
		global String name {get;set;} 
		global String author {get;set;} 
		global String operator {get;set;} 
		global String type {get;set;} 
		global String class_Z {get;set;} 
		global String edit_date {get;set;} 
		global String system_edit_date {get;set;} 
		global String create_date {get;set;} 
		global String create_profile_date {get;set;} 
		global String retain_days {get;set;} 
		global String size {get;set;} 
		global String is_declared {get;set;} 
		global String declared {get;set;} 
		global String is_related {get;set;} 
		global String default_security {get;set;} 
		global String last_user {get;set;} 
		global String is_in_use {get;set;} 
		global String is_checked_out {get;set;} 
		global String type_description {get;set;} 
		global String class_description {get;set;} 
		global String extension {get;set;} 
		global String content_type {get;set;} 
		global String edit_profile_date {get;set;} 
		global String is_external {get;set;} 
		global String is_external_as_normal {get;set;} 
		global String file_create_date {get;set;} 
		global String file_edit_date {get;set;} 
		global String is_hipaa {get;set;} 
		global String workspace_name {get;set;} 
		global String is_restorable {get;set;} 
		global String id {get;set;} 
		global String in_use {get;set;} 
		global String indexable {get;set;} 
		global String wstype {get;set;} 
		global String iwl {get;set;} 
		global String workspace_id {get;set;} 
    }
    
	
        
}