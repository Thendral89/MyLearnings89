public class CheckListInitialAssignmentHandler {

    public static void initialMEMAssignment(List<SymphonyLF__Matter_Engagement_Model__c> memList, Map<Id,SymphonyLF__Matter_Engagement_Model__c> oldMap){
        Set<String> patentIds = new Set<String>();
        Set<String> designIds = new Set<String>();
        for(SymphonyLF__Matter_Engagement_Model__c mem : memList){
            if(oldMap == null || ( oldMap != null && (oldMap.get(mem.Id).SymphonyLF__Type__c != mem.SymphonyLF__Type__c) || oldMap.get(mem.Id).SymphonyLF__Supervisor_Client_Contact__c != mem.SymphonyLF__Supervisor_Client_Contact__c ) ){
                if(mem.SymphonyLF__Type__c == 'Legal Assistant' || mem.SymphonyLF__Type__c == 'Paralegal'){
                    if(mem.SymphonyLF__Patent__c != null){
                        patentIds.add(mem.SymphonyLF__Patent__c);
                    }
                    if(mem.SymphonyLF__Design__c != null){
                        designIds.add(mem.SymphonyLF__Design__c);
                    }
            	}
            }
            
        }
        
        if(patentIds.isEmpty() && designIds.isEmpty()){
            return;
        }
        
        List<Checklist_Instance__c> checkListInstances = new List<Checklist_Instance__c>();
     
        String checkListInstanceQuery = 'SELECT Id, Checklist__r.Name, Checklist__r.Checklist_Code__c, Patent__c, Design__c, Secretary__c FROM Checklist_Instance__c WHERE Secretary__c = null ';
        if(!patentIds.isEmpty() && !designIds.isEmpty()){
            checkListInstanceQuery += ' AND ( Patent__c IN: patentIds OR Design__c IN: designIds )  ';
        }else if(!patentIds.isEmpty()){
            checkListInstanceQuery += ' AND Patent__c IN: patentIds ';
        }else if(!designIds.isEmpty()){
            checkListInstanceQuery += ' AND Design__c IN: designIds ';
        }
        System.debug('checkListInstanceQuery ' + checkListInstanceQuery);
        checkListInstances =  Database.query(checkListInstanceQuery);
        // checkListInstances =  [SELECT Id, Checklist__r.Name, Checklist__r.Checklist_Code__c, Patent__c, Design__c, Secretary__c FROM Checklist_Instance__c WHERE ( Patent__c IN: patentIds OR Design__c IN: designIds ) AND Secretary__c = null];
        if(checkListInstances.isEmpty()){
            return;
        }
        System.debug(patentIds.size() + ' ----- ' + designIds.size() + designIds) ;
        String memQuery = 'SELECT Id, SymphonyLF__Type__c, SymphonyLF__Patent__c, SymphonyLF__Design__c, SymphonyLF__Assign_to_User__c, SymphonyLF__Assign_to_User__r.SymphonyLF__User__c FROM SymphonyLF__Matter_Engagement_Model__c WHERE (SymphonyLF__Type__c = \'Legal Assistant\' OR SymphonyLF__Type__c = \'Paralegal\') ';
        if(!patentIds.isEmpty() && !designIds.isEmpty()){
            memQuery += ' AND ( SymphonyLF__Patent__c IN: patentIds OR SymphonyLF__Design__c IN: designIds )  ';
        }else if(!patentIds.isEmpty()){
            memQuery += ' AND SymphonyLF__Patent__c IN: patentIds ';
        }else if(!designIds.isEmpty()){
            memQuery += ' AND SymphonyLF__Design__c IN: designIds ';
        }
        memQuery += '  ORDER BY Createddate asc  ';
        System.debug('memQuery ' + memQuery);
        // List<SymphonyLF__Matter_Engagement_Model__c>  memResults = [SELECT Id, SymphonyLF__Type__c, SymphonyLF__Patent__c, SymphonyLF__Design__c, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c FROM SymphonyLF__Matter_Engagement_Model__c WHERE (( SymphonyLF__Patent__c IN: patentIds OR SymphonyLF__Design__c IN: designIds ) AND (SymphonyLF__Type__c = 'Legal Assistant' OR SymphonyLF__Type__c = 'Paralegal')) ORDER BY Createddate asc ];
        List<SymphonyLF__Matter_Engagement_Model__c>  memResults = Database.query(memQuery);
        Map<String, Map<String,String>> patentIdVsSecretaryId = new Map<String, Map<String, String>>();
        Map<String, Map<String,String>> designIdVsSecretaryId = new Map<String, Map<String, String>>();
        for(SymphonyLF__Matter_Engagement_Model__c memRec : memResults){
            if(memRec.SymphonyLF__Patent__c != null){
                
                if(patentIdVsSecretaryId.containskey(memRec.SymphonyLF__Patent__c)){
                    
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' && !(patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).containskey('Legal Assistant') ){
                        (patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).put('Legal Assistant',memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c );
                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal' && !(patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).containskey('Paralegal') ){
                        (patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).put('Paralegal',memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c );
                    }
                }else{
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' ){
                        patentIdVsSecretaryId.put(memRec.SymphonyLF__Patent__c, new Map<String,String>{'Legal Assistant' => memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c});
                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal'){
                        patentIdVsSecretaryId.put(memRec.SymphonyLF__Patent__c, new Map<String,String>{'Paralegal' => memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c});
                    }
                }
            }
            if(memRec.SymphonyLF__Design__c != null){
                
                if(designIdVsSecretaryId.containskey(memRec.SymphonyLF__Design__c)){
                    
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' && !(designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).containskey('Legal Assistant') ){
                        (designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).put('Legal Assistant',memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c );
                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal' && !(designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).containskey('Paralegal') ){
                        (designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).put('Paralegal',memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c );
                    }
                }else{
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' ){
                        designIdVsSecretaryId.put(memRec.SymphonyLF__Design__c, new Map<String,String>{'Legal Assistant' => memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c});
                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal'){
                        designIdVsSecretaryId.put(memRec.SymphonyLF__Design__c, new Map<String,String>{'Paralegal' => memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c});
                    }
                }
            }
        }
        List<Checklist_Instance__c> checkListInstancesUpd = new List<Checklist_Instance__c>();
        for(Checklist_Instance__c instance: checkListInstances){
            if(instance.Secretary__c == null){
                if(instance.Patent__c != null){
                    if(instance.Checklist__r.Checklist_Code__c == 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION' || instance.Checklist__r.Checklist_Code__c == 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION'){   // PCT US Nat Phase or PCT
                        if(patentIdVsSecretaryId.containskey(instance.Patent__c)){
                            if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Paralegal')){
                             instance.Secretary__c =   (patentIdVsSecretaryId.get(instance.Patent__c)).get('Paralegal');
                            }
                        }
                    }else if(instance.Checklist__r.Checklist_Code__c == 'CHECKLIST FOR NEW U.S. APPLICATION'){ // Utility
                        if(patentIdVsSecretaryId.containskey(instance.Patent__c)){
                            if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Legal Assistant')){
                             instance.Secretary__c =  (patentIdVsSecretaryId.get(instance.Patent__c)).get('Legal Assistant');
                            }else if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Paralegal')){
                             instance.Secretary__c =   (patentIdVsSecretaryId.get(instance.Patent__c)).get('Paralegal');
                            }
                        }
                    }else if(instance.Checklist__r.Checklist_Code__c == 'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION' || instance.Checklist__r.Checklist_Code__c == 'CHECKLIST FOR NOTICE OF ALLOWANCE'){ // Patent Provisional or Patent NOA
						if(patentIdVsSecretaryId.containskey(instance.Patent__c)){
                            if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Legal Assistant')){
                             instance.Secretary__c =  (patentIdVsSecretaryId.get(instance.Patent__c)).get('Legal Assistant');
                            }
                        }
                    }
                }else if(instance.Design__c != null){
                    if(instance.Checklist__r.Checklist_Code__c == 'CHECKLIST FOR NEW U.S. DESIGN APPLICATION' || instance.Checklist__r.Checklist_Code__c == 'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE'){   // Design Filling and Design NOA
                        if(designIdVsSecretaryId.containskey(instance.Design__c)){
                            if((designIdVsSecretaryId.get(instance.Design__c)).containskey('Legal Assistant')){
                             instance.Secretary__c =   (designIdVsSecretaryId.get(instance.Design__c)).get('Legal Assistant');
                            }
                        }
                    }
                }
                checkListInstancesUpd.add(instance);
            }
        }
        
        if(!checkListInstancesUpd.isEmpty()){
            UPSERT checkListInstancesUpd;
        }
        
    }
}