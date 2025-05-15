global with sharing class cmpAPiMngWorkSpaceWrapper {

    global data data;
	global class data {
        global list<results> results{get;set;}
	}
	global class results {
		global String default_security;	//global
		global String name;	//US00 (206001-6021)
		global String owner;	//SYM_SVC
		global String description;	//IP Test One
		global String subtype;	//work
		global String document_number;	//76
		global String version;	//1
		global String has_subfolders;
		global String is_content_saved_search;
		global String is_container_saved_search;
		global String database;	//MB_SB
		global String is_external;
		global String is_hidden;
		global String is_external_as_normal;
		global String owner_description;	//Symphony Service Account
		global String workspace_id;	//MB_SB!121
		global String author;	//SYM_SVC
		global String operator;	//SYM_SVC
		global String type;	//XML
		global String classw;	//WEBDOC
		global String edit_date;	//2024-01-27T21:12:11Z
		global String system_edit_date;	//2024-01-27T21:12:11Z
		global String create_date;	//2024-01-27T21:12:11Z
		global String create_profile_date;	//2024-01-27T21:12:11Z
		global String retain_days;	//365
		global String size;	//1
		global String is_declared;
		global String declared;
		global String location;	//DEFSERVER07:\FILES\MB_SB\SYM_SVC\0\1\76.1
		global String last_user;	//SYM_SVC
		global String is_in_use;
		global String is_checked_out;
		global String custom1;	//206001
		global String custom2;	//6021
        global String custom3;	//6021
		global String custom4;	//US
        global String custom5;	//6021
        global String custom6;	//6021
		global String custom7;	//1
        global String custom8;	//1
        global String custom9;	//1
		global String custom10;	//US00
		global String custom1_description;	//Bill Bradley
		global String custom2_description;	//IP Test One
        global String custom3_description;	//IP Test One
		global String custom4_description;	//USPTO
        global String custom5_description;	//USPTO
        global String custom6_description;	//USPTO
		global String custom7_description;	//1
        global String custom8_description;	//1
        global String custom9_description;	//1
		global String custom10_description;	//USPTO
		global String content_type;	//P
		global String edit_profile_date;	//2024-01-27T21:13:07Z
		global String file_create_date;	//2024-01-27T21:12:11Z
		global String file_edit_date;	//2024-01-27T21:12:11Z
		global String is_hipaa;
		global String in_use;
		global String indexable;
		global String iwl;	//iwl:dms=michaelbest-mobility.imanage.work&&lib=&&num=76&&ver=1
		global String id;	//MB_SB!121
		global String wstype;	//workspace
	}
    
	global static data parse(String json){
		return (data) System.JSON.deserialize(json, data.class);
	}
    
}