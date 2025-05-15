public with sharing class MyTaskController {
    
    @AuraEnabled
    public static Object getViewsData() {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            responseMap.put('data', MyTaskService.getViewsData());
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object getTaskData(List<String> additionalFieldList, String filterVal, String selectedView, String sortBy, String sortDirection) {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            responseMap.put('data', MyTaskService.getTaskData(additionalFieldList, filterVal, selectedView, sortBy, sortDirection));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object saveTaskData(List<Task> taskList) {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            MyTaskService.saveTaskData(taskList);
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object getPanelInfo(String panelKey, String filterVal) {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            responseMap.put('data', MyTaskService.getPanelInfo(panelKey, filterVal));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object getTaskFieldsData() {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            responseMap.put('data', MyTaskService.getTaskFieldsData());
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object getAdditionalFieldsLabel(String additionalFieldOne, String additionalFieldTwo) {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            responseMap.put('data', MyTaskService.getAdditionalFieldsLabel(additionalFieldOne, additionalFieldTwo));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object getPopoverData(String recordId) {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            responseMap.put('data', MyTaskService.getPopoverData(recordId));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static Object deleteTaskRecords(List<String> taskIds) {
        Map<String, Object> responseMap = new Map<string, Object>();
        try {
            MyTaskService.deleteTaskRecords(taskIds);
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
        }

        return responseMap;
    }
}