global with sharing class cmpAPiMngSearchWrraper {
    global list<data> data{get;set;}
	global class data {
		global String database;	//MB_SB
		global String default_security;	//public
		global String description;	//MB-PT-10001122024-US
		global String edit_date;	//2024-01-15T06:56:02Z
		global String folder_type;	//regular
		global String has_documents;
		global String has_subfolders;
		global String id;	//MB_SB!37
		global String is_container_saved_search;
		global String is_content_saved_search;
		global String is_external;
		global String is_external_as_normal;
		global String is_hidden;
		global String name;	//MB-PT-10001122024-US
		global String owner;	//SYM_SVC
		global String owner_description;	//Symphony Service Account
		global String parent_id;	//MB_SB!5
		global String view_type;	//document
		global String workspace_id;	//MB_SB!5
		global String workspace_name;	//iManage Cloud Monitor
		global String wstype;	//folder
	}
    
    public static cmpAPiMngSearchWrraper parse(String json) {
		return (cmpAPiMngSearchWrraper) System.JSON.deserialize(json, cmpAPiMngSearchWrraper.class);
	}
    
}