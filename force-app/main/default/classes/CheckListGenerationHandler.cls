public with sharing class CheckListGenerationHandler {
    public CheckListGenerationHandler() {

    }
    public static void initiatePatentCheckList(List<SymphonyLF__Patent__c> patentList, Map<Id, SymphonyLF__Patent__c> oldPatentMap){
        Map<String, Checklist__c> checkListMap = new Map<String, Checklist__c>();
        checkListMap = getCheckListData();
        Map<String, Checklist__c> patentVsCheckList = new Map<String, Checklist__c>();
        if(checkListMap != null && !checkListMap.isEmpty() ){
            for(SymphonyLF__Patent__c record : patentList){
                if(oldPatentMap == null || oldPatentMap.get(record.Id).SymphonyLF__Case_Type__c != record.SymphonyLF__Case_Type__c){
                    if(record.Country_Name__c == 'United States of America' && record.SymphonyLF__Patent_Status__c == 'Application Preparation' && record.SymphonyLF__Case_Type__c == 'PCT National'){
                        patentVsCheckList.put(record.Id, checkListMap.get('CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION'));
    
                    }else if(record.Country_Name__c == 'World Intellectual Property Organization (WIPO)/PCT' && record.SymphonyLF__Patent_Status__c == 'Application Preparation' && ( record.SymphonyLF__Case_Type__c == 'Secondary' || record.SymphonyLF__Case_Type__c == 'Primary')){
                        patentVsCheckList.put(record.Id, checkListMap.get('CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION'));
    
                    }else if(record.Country_Name__c == 'United States of America' && record.SymphonyLF__Patent_Status__c == 'Application Preparation' &&
                             ( record.SymphonyLF__Case_Type__c == 'Continuation' || record.SymphonyLF__Case_Type__c == 'Utility Non-Provisional' || record.SymphonyLF__Case_Type__c == 'Utility Original' || record.SymphonyLF__Case_Type__c == 'Divisional' || record.SymphonyLF__Case_Type__c == 'Continuation-in-Part')) {
                                
                        patentVsCheckList.put(record.Id, checkListMap.get('CHECKLIST FOR NEW U.S. APPLICATION'));
    
                    }else if(record.Country_Name__c == 'United States of America' && record.SymphonyLF__Patent_Status__c == 'Application Preparation' && record.SymphonyLF__Case_Type__c == 'Provisional'){
                        patentVsCheckList.put(record.Id, checkListMap.get('CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION'));
    
                    }
                }   
            }
        }
        
        system.debug('patentVsCheckList ' + patentVsCheckList);
        if(!patentVsCheckList.isEmpty()){
            CheckListGenerationHelper.createCheckListRecord(patentVsCheckList, 'Patent');
        }
        
    }

    public static void initiateDesignCheckList(List<SymphonyLF__Design__c> designList, Map<Id, SymphonyLF__Design__c> oldDesignMap){
        Map<String, Checklist__c> checkListMap = new Map<String, Checklist__c>();
        checkListMap = getCheckListData();
        
        Map<String, Checklist__c> designVsCheckList = new Map<String, Checklist__c>();
        if(checkListMap != null && !checkListMap.isEmpty()){
            for(SymphonyLF__Design__c record : designList){
                if(oldDesignMap == null || oldDesignMap.get(record.Id).SymphonyLF__Case_Type__c != record.SymphonyLF__Case_Type__c){
                    if(record.Jurisdiction_Name__c == 'United States of America' && record.SymphonyLF__Design_Status__c == 'Application Preparation' && record.SymphonyLF__Case_Type__c != null){
                        designVsCheckList.put(record.Id, checkListMap.get('CHECKLIST FOR NEW U.S. DESIGN APPLICATION'));
    
                    }
                }   
            }
        }
        
        system.debug('designVsCheckList ' + designVsCheckList);
        if(!designVsCheckList.isEmpty()){
            CheckListGenerationHelper.createCheckListRecord(designVsCheckList, 'Design');
        }
        
    }

    public static void initiateNOACheckList(List<SymphonyLF__Legal_Event__c> legalEventList, Map<Id, SymphonyLF__Legal_Event__c> oldLegalEventMap){
        Map<String, Checklist__c> checkListMap = new Map<String, Checklist__c>();
        checkListMap = getCheckListData();
        
        Map<String, Checklist__c> designVsCheckList = new Map<String, Checklist__c>();
        Map<String, Checklist__c> patentVsCheckList = new Map<String, Checklist__c>();
        if(checkListMap != null && !checkListMap.isEmpty()){
            
            for(SymphonyLF__Legal_Event__c record : legalEventList){
                if(oldLegalEventMap == null || oldLegalEventMap.get(record.Id).SymphonyLF__Document_Code__c != record.SymphonyLF__Document_Code__c){
                    if(record.SymphonyLF__Patent__c != null && record.Checklist_Jurisdiction__c == 'United States of America'  && record.SymphonyLF__Document_Code__c  == 'NOA'){
                        patentVsCheckList.put(record.SymphonyLF__Patent__c, checkListMap.get('CHECKLIST FOR NOTICE OF ALLOWANCE'));
                    }else if(record.SymphonyLF__Design__c != null && record.Checklist_Jurisdiction__c == 'United States of America'  && record.SymphonyLF__Document_Code__c  == 'NOA'){
                        designVsCheckList.put(record.SymphonyLF__Design__c, checkListMap.get('CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE'));
                    }
                }   
            }
        }
        
        system.debug('designVsCheckList ' + designVsCheckList);
        if(!designVsCheckList.isEmpty() && designVsCheckList.size() > 0){
            CheckListGenerationHelper.createCheckListRecord(designVsCheckList, 'Design');
        }
        if(!patentVsCheckList.isEmpty() && patentVsCheckList.size() > 0){
            CheckListGenerationHelper.createCheckListRecord(patentVsCheckList, 'Patent');
        }
       
    }

  
    private static Map<String, Checklist__c> getCheckListData(){
        Map<String, Checklist__c> checkListMap = new Map<String, Checklist__c>();
        List<Checklist__c> checkList = [SELECT Id,Checklist_Code__c, Name FROM Checklist__c];
        if(!checkList.isEmpty()){
            for(Checklist__c record :checkList){
                checkListMap.put(record.Checklist_Code__c, record);
            }
            return checkListMap;
        }
        return null;
    }
}