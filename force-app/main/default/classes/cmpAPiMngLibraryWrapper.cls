public class cmpAPiMngLibraryWrapper {
	public List<data> data;
	public class data {
		public String id;
		public String user_id_ex;
		public String full_name;
		public String location;
		public String allow_logon;
		public String email;
		public Integer user_num;
		public String doc_server;
		public String preferred_library;
		public Integer user_nos;
		public String pwd_changed_ts;
		public String password_never_expire;
		public Integer failed_logins;
		public String force_password_change;
		public String is_external;
		public String exch_autodiscover;
		public String edit_date;
		public String wstype;
		public String user_id;
		public String userid;
		public String preferred_database;
		public String login;
		public String pwd_never_expire;
		public String database;
	}

	
	public static cmpAPiMngLibraryWrapper parse(String json) {
		return (cmpAPiMngLibraryWrapper) System.JSON.deserialize(json, cmpAPiMngLibraryWrapper.class);
	}
}