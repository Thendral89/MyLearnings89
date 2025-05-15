/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-21-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class MyTaskConstants {

    public static final String TASK_OBJECT_NAME = 'Task';
    public static final String MY_TASK_FIELD_SET_NAME = 'My_Tasks';

    private static final Map<String, String> HIGHLIGHTED_PANEL_MAP = new Map<String, String> {
        'myOpen' => 'Open',
        'highPriority' => 'High Priority',
        'overdue' => 'Overdue',
        'todaysTask' => 'Today\'s Tasks',
        'next7Days' => 'Next 7 Days',
        'thisMonth' => 'This Month',
        'completed' => 'Completed'
    };

    private static final Map<String, String> STATIC_QUERY_FILTER_MAP = new Map<String, String> {
        'myOpen' => 'IsClosed = false AND (NOT (Subject LIKE \'Email:%\'))',
        'highPriority' => 'Priority = \'High\' AND IsClosed = false AND (NOT (Subject LIKE \'Email:%\'))',
        'overdue' => 'ActivityDate != null AND ActivityDate < TODAY AND IsClosed = false AND (NOT (Subject LIKE \'Email:%\'))',
        'todaysTask' => 'ActivityDate != null AND ActivityDate = TODAY AND IsClosed = false AND (NOT (Subject LIKE \'Email:%\'))',
        'next7Days' => 'ActivityDate != null AND IsClosed = false AND ActivityDate = NEXT_N_DAYS:7 AND (NOT (Subject LIKE \'Email:%\'))',
        'thisMonth' => 'ActivityDate != null AND IsClosed = false AND ActivityDate = THIS_MONTH AND (NOT (Subject LIKE \'Email:%\'))',
        'completed' => 'IsClosed = true AND (NOT (Subject LIKE \'Email:%\'))'
    };

    private static final Set<String> TASK_QUERY_FIELDS = new Set<String> {
        'ID', 
        'WhatId', 
        'What.Name', 
        'Subject', 
        'Status', 
        'Priority', 
        'ActivityDate',
        'Priority_Color__c',
        'Status_Color__c',
        'Due_In_Days__c',
        'IsClosed',
        'CreatedDate'
    };

    private static final Set<String> FILTER_FIELDS = new Set<String>{
        'Status', 
        'Priority', 
        'ActivityDate',
        'Subject', 
        'Type'
    };

    public static Set<String> getFilterFields() {
        return FILTER_FIELDS;
    }

    public static Set<String> getQueryFields() {
        return TASK_QUERY_FIELDS;
    }

    public static Map<String, String> getStaticQueryFilterMap() {
        return STATIC_QUERY_FILTER_MAP;
    }

    public static String getStaticQueryFilterByKey(String key) {
        return STATIC_QUERY_FILTER_MAP.containsKey(key) ? STATIC_QUERY_FILTER_MAP.get(key) : null;
    }

    public static Map<String, String> getHighlightedPanelMap() {
        return HIGHLIGHTED_PANEL_MAP;
    }

    public static String getHighlightedPanelByKey(String key) {
        return HIGHLIGHTED_PANEL_MAP.containsKey(key) ? HIGHLIGHTED_PANEL_MAP.get(key) : null;
    }
}