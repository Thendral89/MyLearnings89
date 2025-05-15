public with sharing class APPLICATION {
    public final static String PROFILE_PERMISSIONSET_BEGINS_WITH = 'MCCIP';
    public final static String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public final static String PROFILE_DOCKETING_MANAGEMENT = 'Docketing Management';

    public final static String LIGHTNING_CONSOLE_PERMISSION_SET = 'Lightning Console Permission';

    public final static Set<String> PERMISSION_SETS_WITH_PERMISSION_SET_LICENSE = new Set<String>{
        LIGHTNING_CONSOLE_PERMISSION_SET
    };

    public final static String CEM_MEM_TYPE_ANNUITY_SPECIALIST = 'Annuity Specialist';
    public final static String CEM_MEM_TYPE_BACKUP_ATTORNEY = 'Backup Attorney';
    public final static String CEM_MEM_TYPE_CC_LAWFIRM_PERSONNEL = 'CC Law Firm Personnel';
    public final static String CEM_MEM_TYPE_CLIENT_REPRESENTATIVE = 'Client Representative';
    public final static String CEM_MEM_TYPE_COPY_CONTACT = 'Copy Contact';
    public final static String CEM_MEM_TYPE_CORESSPONDENCE_CONTACT = 'Correspondence Contact';
    public final static String CEM_MEM_TYPE_DOCKETER = 'Docketer';
    public final static String CEM_MEM_TYPE_DOCKETING_MANAGEMENT = 'Docketing Management';
    public final static String CEM_MEM_TYPE_IDS_SPECIALIST = 'IDS Specialist';
    public final static String CEM_MEM_TYPE_LEGAL_ASSISTANT = 'Legal Assistant';
    public final static String CEM_MEM_TYPE_MANAGING_SUPERVISING_ATTORNEY = 'Managing (Supervising) Attorney';
    public final static String CEM_MEM_TYPE_ORIGINATING_ATTORNEY = 'Originating Attorney';
    public final static String CEM_MEM_TYPE_OUTSIDE_LEGAL_PERSONNEL = 'Outside Legal Personnel';
    public final static String CEM_MEM_TYPE_PARALEGAL = 'Paralegal';
    public final static String CEM_MEM_TYPE_RESPONSIBLE_BILLING_ATTORNEY = 'Responsible (Billing) Attorney';
    public final static String CEM_MEM_TYPE_WORKING_ATTORNEY = 'Working Attorney';
    public final static String CEM_MEM_TYPE_FOREIGN_ASSOCIATE = 'Foreign Associate';
    public final static String CEM_MEM_TYPE_MANAGING_OFFICE = 'Managing Office';
    public final static String CEM_MEM_TYPE_WORKING_OFFICE = 'Working Office';
    public final static String CEM_MEM_TYPE_BILLING_PARTY = 'Billing Party';
    public final static String CEM_MEM_TYPE_INSTRUCTION_PARTY = 'Instructing Party';
    public final static String CEM_MEM_TYPE_RENEWAL_AGENT = 'Renewal Agent';
    public final static String CEM_MEM_TYPE_ANNUITY_PAYMENT_PROVIDER = 'Annuity Payment Provider';
    public final static String CEM_MEM_TYPE_CLIENT_CONTACT = 'Client Contact';
    public final static String CEM_MEM_TYPE_ANNUITY_PAYMENT_PROVIDER_REP = 'Annuity Payment Provider Rep';
    public final static String CEM_MEM_TYPE_AGENT = 'Agent';
    public final static String CEM_MEM_TYPE_PRINCIPAL = 'Principal';
    public final static String CEM_MEM_TYPE_SECONDARY_CLIENT_CONTACT = 'Secondary Client Contact';
    public final static String CEM_MEM_TYPE_PREFERRED_AGENT = 'Preferred Agent';
    public final static String CEM_MEM_TYPE_OPPONENT_PETITIONER_CLIENT = 'Opponent/Petitioner (Client)';
    public final static String CEM_MEM_TYPE_OPPONENT_PETITIONER_NON_CLIENT = 'Opponent/Petitioner (Non-Client)';
    public final static String CEM_MEM_TYPE_OPPONENT_PETITIONER_REPRESENTATIVE = 'Opponent/Petitioner Representative';
    public final static String CEM_MEM_TYPE_PROPRIETOR_RESPONDENT_OTHER_PARTY_IP_ASSET = 'Proprietor/Respondent (Other Party IP Asset)';
    public final static String CEM_MEM_TYPE_PROPRIETOR_RESPONDENT_REPRESENTATIVE_OTHER_PARTY_IP_ASSET = 'Proprietor/Respondent Representative (Other Party IP Asset)';
    public final static String CEM_MEM_TYPE_AUTHORITY = 'Authority';
    public final static String CEM_MEM_TYPE_OUTSIDE_LEGAL = 'Outside Legal';
    public final static String CEM_MEM_TYPE_OUTSIDE_LAWFIRM = 'Outside Lawfirm';

    public final static Set<String> DEFAULT_PROFILE_WITH_RESTRICTION_ACCESS = new Set<String>{
        PROFILE_SYSTEM_ADMINISTRATOR
        , PROFILE_DOCKETING_MANAGEMENT
    };

    public final static Set<String> DEFAULT_CEM_ROLE_WITH_RESTRICTION_ACCESS = new Set<String>{
        CEM_MEM_TYPE_ORIGINATING_ATTORNEY
        ,CEM_MEM_TYPE_RESPONSIBLE_BILLING_ATTORNEY
    };

    public final static String RESTRICTION_STATUS_TO_GRANT = 'To Be Granted';
    public final static String RESTRICTION_STATUS_TO_ENFORCE = 'To Be Enforced';
    public final static String RESTRICTION_STATUS_ENFORCED = 'Enforced';

    public final static Set<String> RESTRICTION_STATUS_IN_FLIGHT = new Set<String>{
        RESTRICTION_STATUS_TO_GRANT
        ,RESTRICTION_STATUS_TO_ENFORCE
    };

    public final static String RETURN_CODE_DELETED = 'DELETED';
    public final static String RETURN_CODE_CREATED = 'CREATED';
    public final static String RETURN_CODE_UPSERTED = 'UPSERTED';

    public final static Map<String, String> DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'SymphonyLF__Agreement_and_Contract__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Copyright__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Design__c',
        'SymphonyLF__Design_Family__c' => 'SymphonyLF__Design_Family__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__General_Matter__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Mark__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Trademark__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c'
    };

    public final static Map<String, String> DOCKET_ACTIVITY_LOOKUP_FIELD_TO_SOBJECT = new Map<String, String>{};

    static {
        for(String sobjectApiName : DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.keySet()) {
            DOCKET_ACTIVITY_LOOKUP_FIELD_TO_SOBJECT.put(
                DOCKET_ACTIVITY_SOBJECT_TO_LOOKUP.get(sobjectApiName)
                ,sobjectApiName
            );
        }
    }

    public final static Map<String, String> SOBJECT_TO_DOCKET_NUMBER_FIELD = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Design_Family__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Docket_Number__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Docket_Number__c'
    };

    public static Map<String, String> SOBJECT_TO_TITLE_FIELD = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'Name',
        'SymphonyLF__Copyright__c' => 'Name',
        'SymphonyLF__Design__c' => 'Name',
        'SymphonyLF__Design_Family__c' => 'Name',
        'SymphonyLF__Dispute_Opposition__c' => 'Name',
        'SymphonyLF__Entity__c' => 'Name',
        'SymphonyLF__General_Matter__c' => 'Name',
        'SymphonyLF__Mark__c' => 'Name',
        'SymphonyLF__Patent_Family__c' => 'Name',
        'SymphonyLF__Trademark__c' => 'Name',
        'SymphonyLF__Patent__c' => 'Name'
    };


    final static String CEM_IP_MATTER_ALL = 'All';
    final static String CEM_IP_MATTER_PATENT = 'Patent';
    final static String CEM_IP_MATTER_TRADEMARK = 'Trademark';
    final static String CEM_IP_MATTER_DESIGN = 'Design';
    final static String CEM_IP_MATTER_COPYRIGHT = 'Copyright';
    final static String CEM_IP_MATTER_GENERAL_MATTER = 'General Matter';
    final static String CEM_IP_MATTER_AGREEMENT = 'Agreement / Contract';
    final static String CEM_IP_MATTER_DISPUTE = 'Dispute/Opposition';

    public final static Map<String, Set<String>> SOBJECT_TO_CEM_IP_MATTER = new Map<String, Set<String>>{
        'SymphonyLF__Agreement_Contract__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_PATENT
        },
        'SymphonyLF__Copyright__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_COPYRIGHT
        },
        'SymphonyLF__Design__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_DESIGN
        },
        'SymphonyLF__Design_Family__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_DESIGN
        },
        'SymphonyLF__Dispute_Opposition__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_DISPUTE
        },
        'SymphonyLF__General_Matter__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_GENERAL_MATTER
        },
        'SymphonyLF__Mark__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_TRADEMARK
        },
        'SymphonyLF__Patent_Family__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_PATENT
        },
        'SymphonyLF__Trademark__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_TRADEMARK
        },
        'SymphonyLF__Patent__c' => new Set<String>{
            CEM_IP_MATTER_ALL
            , CEM_IP_MATTER_PATENT
        }
    };

    public final static Map<String, String> SOBJECT_TO_MEM_MATTER_LOOKUP_FIELD = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'SymphonyLF__Agreements_Contracts__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Copyright__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Design__c',
        'SymphonyLF__Design_Family__c' => 'SymphonyLF__Design_Family__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Dispute_Opposition__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__General_Matter__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Mark__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Patent_Family__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Trademark__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Patent__c'
    };

    public final static Map<String, String> SOBJECT_TO_JURISDICTION_LOOKUP_FIELD = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Jurisdiction__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Country__c'
    };

    public final static Map<String, String> SOBJECT_TO_CLIENT_ID_FIELD = new Map<String, String>{
        'SymphonyLF__Agreement_Contract__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Copyright__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Design__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Design_Family__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Dispute_Opposition__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__General_Matter__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Mark__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Patent_Family__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Trademark__c' => 'SymphonyLF__Client__c',
        'SymphonyLF__Patent__c' => 'SymphonyLF__Client__c'
    };

    public final static Map<String, String> OLD_TO_NEW_PROFILE_NAME = new Map<String, String>{
        'Attorney' => 'MCCIP Attorney'
        , 'Client' => 'MCCIP Client'
        , 'Docketer' => 'MCCIP Docketer'
        , 'Docketing Management' => 'MCCIP Docketing Management'
        , 'Legal Assistant' => 'MCCIP Legal Assistant'
        , 'Paralegal' => 'MCCIP Paralegal'
        , 'Patent Agent' => 'MCCIP Patent Agent'
        , 'Principal' => 'MCCIP Principal'
        , 'Read Only' => 'MCCIP Read Only'
        , 'Scientific Advisor' => 'MCCIP Scientific Advisor'
        , 'Account and Finance Team' => 'MCCIP Account and Finance Team'
    };
}