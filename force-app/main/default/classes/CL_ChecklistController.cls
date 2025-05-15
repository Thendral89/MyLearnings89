public with sharing class CL_ChecklistController {
    private static CL_ChecklistService checklistService;

    private static CL_ChecklistService service() {
        if(checklistService == null) {
            checklistService = CL_ChecklistService.instance();
        }
        return checklistService;
    }
    
    @AuraEnabled
    public static object getCheckListConfigData(String checklistInstanceId){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', service().getCheckListConfigData(checklistInstanceId));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
            responseMap.put('lineNumber', e.getLineNumber());

            // Error Logging to be done from here
        }

        return responseMap;
    }

    @AuraEnabled
    public static object getSectionList(String checklistInstanceId){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', service().getSectionList(checklistInstanceId));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
            responseMap.put('lineNumber', e.getLineNumber());

            // Error Logging to be done from here
        }

        return responseMap;
    }

    @AuraEnabled
    public static object getSubSectionList(String checklistInstanceId, String parentSectionId){
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap.put('data', service().getSubSectionList(checklistInstanceId, parentSectionId));
            responseMap.put('isSuccess', true);
        } catch (Exception e) {
            responseMap.put('isSuccess', false);
            responseMap.put('errorMessage', e.getMessage());
            responseMap.put('lineNumber', e.getLineNumber());

            // Error Logging to be done from here
        }

        return responseMap;
    }

}