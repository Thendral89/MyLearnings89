global with sharing class cmpAPiMngSearchFolderUpdatedWrraper {

	global data data;
	global class data {
		global String default_security;	//inherit
		global String inherited_default_security;	//global
		global String name;	//700-Case Administration
		global String owner;	//SYM_SVC
		global String description;	//700-Case Administration
		global String has_subfolders;
		global String has_documents;
		global String is_content_saved_search;
		global String is_container_saved_search;
		global String database;	//MB_SB
		global String is_external;
		global String is_hidden;
		global String is_external_as_normal;
		global String edit_date;	//2024-01-27T21:13:49Z
		global String effective_security;	//full_access
		global String owner_description;	//Symphony Service Account
		global String view_type;	//document
		global String id;	//MB_SB!97
		global String parent_id;	//MB_SB!90
		global String workspace_id;	//MB_SB!90
		global String workspace_name;	//US01 (206001-6021)
		global String wstype;	//folder
		global String folder_type;	//regular
		global profile profile;
		global owner_info owner_info;
	}
	global class profile {
		global String classw;	//CASEADMIN
		global String class_description;	//Case Administration
		global String custom1;	//206001
        global String custom2;	//6021
        global String custom3;
        global String custom4;	//US
        global String custom5;
        global String custom6;
        global String custom7;	//2
        global String custom8;
        global String custom9;
        global String custom10;	//US01
        
		global String custom1_description;	//Bill Bradley
        global String custom2_description;	//IP Test One
        global String custom3_description;	//IP Test One
        global String custom4_description;	//USPTO
        global String custom5_description;	
        global String custom6_description;	
        global String custom7_description;	//2
        global String custom8_description;	
        global String custom9_description;	
        global String custom10_description;	//USPTO
		
		
	}
	global class owner_info {
		global String allow_logon;
		global String is_external;
	}
	
	public static cmpAPiMngSearchFolderUpdatedWrraper parse(String json){
		return (cmpAPiMngSearchFolderUpdatedWrraper) System.JSON.deserialize(json, cmpAPiMngSearchFolderUpdatedWrraper.class);
	}
        
}