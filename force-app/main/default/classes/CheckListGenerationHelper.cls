public with sharing class CheckListGenerationHelper {
    public CheckListGenerationHelper() {

    }

    public static void createCheckListRecord(Map<String, Checklist__c> matterIdVsChecklistId, String objectName){
        // checklist intance and checklist instance item
        List<Checklist_Instance__c> checkListInstances = new List<Checklist_Instance__c>();
        List<Checklist_Instance_Item__c> checkListInstanceItems = new List<Checklist_Instance_Item__c>();
        List<String> checkListIds = new List<String>();
        Set<String> patentIds = new Set<String>();
        Set<String> designIds = new Set<String>();


        for(String matterId : matterIdVsChecklistId.keyset()){
            if(objectName == 'Patent'){
                patentIds.add(matterId);
            }else if(objectName == 'Design'){
                designIds.add(matterId);
            }
        }
        String memQuery = 'SELECT Id, SymphonyLF__Type__c, SymphonyLF__Patent__c, SymphonyLF__Design__c, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c,SymphonyLF__Assign_to_User__c,SymphonyLF__Assign_to_User__r.SymphonyLF__User__c FROM SymphonyLF__Matter_Engagement_Model__c WHERE (SymphonyLF__Type__c = \'Legal Assistant\' OR SymphonyLF__Type__c = \'Paralegal\') ';
        if(!patentIds.isEmpty() && !designIds.isEmpty()){
            memQuery += ' AND ( SymphonyLF__Patent__c IN: patentIds OR SymphonyLF__Design__c IN: designIds )  ';
        }else if(!patentIds.isEmpty()){
            memQuery += ' AND SymphonyLF__Patent__c IN: patentIds ';
        }else if(!designIds.isEmpty()){
            memQuery += ' AND SymphonyLF__Design__c IN: designIds ';
        }
        memQuery += '  ORDER BY Createddate asc  ';
        System.debug(patentIds.size() + ' ----- ' + designIds.size() + designIds + patentIds) ;
        List<SymphonyLF__Matter_Engagement_Model__c>  memResults = Database.query(memQuery);
        System.debug('memResults ===>'+memResults) ;
        //List<SymphonyLF__Matter_Engagement_Model__c>  memResults = [SELECT Id, SymphonyLF__Type__c, SymphonyLF__Patent__c, SymphonyLF__Design__c, SymphonyLF__Supervisor_Client_Contact__c, SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c FROM SymphonyLF__Matter_Engagement_Model__c WHERE (( SymphonyLF__Patent__c IN: patentIds OR SymphonyLF__Design__c IN: designIds ) AND (SymphonyLF__Type__c = 'Legal Assistant' OR SymphonyLF__Type__c = 'Paralegal')) ORDER BY Createddate asc];
        Map<String, Map<String,String>> patentIdVsSecretaryId = new Map<String, Map<String, String>>();
        Map<String, Map<String,String>> designIdVsSecretaryId = new Map<String, Map<String, String>>();

        for(SymphonyLF__Matter_Engagement_Model__c memRec : memResults){

            String userId = memRec.SymphonyLF__Supervisor_Client_Contact__c != null
                            ? memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c
                            : (memRec.SymphonyLF__Assign_to_User__c != null ? memRec.SymphonyLF__Assign_to_User__r.SymphonyLF__User__c : null);

            if(memRec.SymphonyLF__Patent__c != null){
                
                if(patentIdVsSecretaryId.containskey(memRec.SymphonyLF__Patent__c)){
                    
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' && !(patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).containskey('Legal Assistant') ){
                        //(patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).put('Legal Assistant',memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c );
                        (patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).put('Legal Assistant',userId );

                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal' && !(patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).containskey('Paralegal') ){
                        //(patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).put('Paralegal',memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c );
                        (patentIdVsSecretaryId.get(memRec.SymphonyLF__Patent__c)).put('Paralegal',userId );
                    }
                }else{
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' ){
                        //patentIdVsSecretaryId.put(memRec.SymphonyLF__Patent__c, new Map<String,String>{'Legal Assistant' => memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c});
                        patentIdVsSecretaryId.put(memRec.SymphonyLF__Patent__c, new Map<String,String>{'Legal Assistant' => userId});

                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal'){
                        //patentIdVsSecretaryId.put(memRec.SymphonyLF__Patent__c, new Map<String,String>{'Paralegal' => memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c});
                        patentIdVsSecretaryId.put(memRec.SymphonyLF__Patent__c, new Map<String,String>{'Paralegal' => userId});
                    
                    }
                }
                System.debug('patentIdVsSecretaryId ====>'+patentIdVsSecretaryId);
            }
            if(memRec.SymphonyLF__Design__c != null){
                
                if(designIdVsSecretaryId.containskey(memRec.SymphonyLF__Design__c)){
                    
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' && !(designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).containskey('Legal Assistant') ){
                       // (designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).put('Legal Assistant',memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c );
                        (designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).put('Legal Assistant',userId );

                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal' && !(designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).containskey('Paralegal') ){
                        //(designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).put('Paralegal',memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c );
                        (designIdVsSecretaryId.get(memRec.SymphonyLF__Design__c)).put('Paralegal',userId );
                    }
                }else{
                    if(memRec.SymphonyLF__Type__c == 'Legal Assistant' ){
                       // designIdVsSecretaryId.put(memRec.SymphonyLF__Design__c, new Map<String,String>{'Legal Assistant' => memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c});
                        designIdVsSecretaryId.put(memRec.SymphonyLF__Design__c, new Map<String,String>{'Legal Assistant' => userId});
                    
                    }else if(memRec.SymphonyLF__Type__c == 'Paralegal'){
                       // designIdVsSecretaryId.put(memRec.SymphonyLF__Design__c, new Map<String,String>{'Paralegal' => memRec.SymphonyLF__Supervisor_Client_Contact__r.SymphonyLF__User__c});
                        designIdVsSecretaryId.put(memRec.SymphonyLF__Design__c, new Map<String,String>{'Paralegal' => userId});
                    }
                }
            }
        }

        for(String matterId : matterIdVsChecklistId.keyset()){
            System.debug('patentIdVsSecretaryIdinsideFor ====>'+patentIdVsSecretaryId);
            Checklist_Instance__c instance = new Checklist_Instance__c();
            instance.Checklist__c = matterIdVsChecklistId.get(matterId).Id;
            checkListIds.add(matterIdVsChecklistId.get(matterId).Id);
            instance.Status__c = 'Initial Assignment Checklist In Progress';
            if(objectName == 'Patent'){
                instance.Patent__c = matterId;
                if(matterIdVsChecklistId.get(matterId).Checklist_Code__c == 'CHECKLIST FOR U.S. NATIONAL PHASE APPLICATION' || matterIdVsChecklistId.get(matterId).Checklist_Code__c == 'CHECKLIST FOR PATENT COOPERATION TREATY (PCT) APPLICATION'){   // PCT US Nat Phase or PCT
                    if(patentIdVsSecretaryId.containskey(instance.Patent__c)){
                        if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Paralegal')){
                         instance.Secretary__c =   (patentIdVsSecretaryId.get(instance.Patent__c)).get('Paralegal');
                        }
                    }
                }else if(matterIdVsChecklistId.get(matterId).Checklist_Code__c == 'CHECKLIST FOR NEW U.S. APPLICATION'){ // Utility
                    if(patentIdVsSecretaryId.containskey(instance.Patent__c)){
                        if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Legal Assistant')){
                            instance.Secretary__c =  (patentIdVsSecretaryId.get(instance.Patent__c)).get('Legal Assistant');
                        }else if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Paralegal')){
                            instance.Secretary__c =   (patentIdVsSecretaryId.get(instance.Patent__c)).get('Paralegal');
                        }
                    }
                }else if(matterIdVsChecklistId.get(matterId).Checklist_Code__c == 'CHECKLIST FOR NEW U.S. PROVISIONAL APPLICATION' || matterIdVsChecklistId.get(matterId).Checklist_Code__c == 'CHECKLIST FOR NOTICE OF ALLOWANCE'){ // Patent Provisional or Patent NOA
                    if(patentIdVsSecretaryId.containskey(instance.Patent__c)){
                        if((patentIdVsSecretaryId.get(instance.Patent__c)).containskey('Legal Assistant')){
                         instance.Secretary__c =  (patentIdVsSecretaryId.get(instance.Patent__c)).get('Legal Assistant');
                        }
                    }
                }
            }else if(objectName == 'Design'){
                instance.Design__c = matterId;
                if(matterIdVsChecklistId.get(matterId).Checklist_Code__c == 'CHECKLIST FOR NEW U.S. DESIGN APPLICATION' || matterIdVsChecklistId.get(matterId).Checklist_Code__c == 'CHECKLIST FOR DESIGN NOTICE OF ALLOWANCE'){   // Design Filling and Design NOA
                    if(designIdVsSecretaryId.containskey(instance.Design__c)){
                        if((designIdVsSecretaryId.get(instance.Design__c)).containskey('Legal Assistant')){
                         instance.Secretary__c =   (designIdVsSecretaryId.get(instance.Design__c)).get('Legal Assistant');
                        }
                    }
                }
            }
            checkListInstances.add(instance);
        }

        if(!checkListInstances.isEmpty()){
            system.debug(' before checkListInstances' + checkListInstances);
            Insert checkListInstances;
            system.debug(' after checkListInstances' + checkListInstances);
            Map<String, List<Checklist_Item__c>> checkListItemsMap = new Map<String, List<Checklist_Item__c>>();
            checkListItemsMap = getCheckListItems(checkListIds);
            for(Checklist_Instance__c instance : checkListInstances){
                system.debug('instance.Checklist__c ' + instance.Checklist__c);
                List<Checklist_Item__c> checklistItems = checkListItemsMap.get(instance.Checklist__c);
                if (checklistItems != null && !checklistItems.isEmpty()) {
                    for(Checklist_Item__c item : checklistItems) {
                        Checklist_Instance_Item__c instanceItem = new Checklist_Instance_Item__c();
                        instanceItem.Checklist_Instance__c = instance.Id;
                        instanceItem.Checklist_Section__c = item.Checklist_Section__c;
                        instanceItem.Checklist_Parent_Section__c = item.Checklist_Section__c != null ? item.Checklist_Section__r.Parent_Section__c : null;
                        instanceItem.Checklist_Item__c = item.Id;
                        checkListInstanceItems.add(instanceItem);
                        System.debug('instanceItem ' + instanceItem);
                    }
                }
            }
            if(!checkListInstanceItems.isEmpty()){
                Insert checkListInstanceItems;
            }
        }
        
        
    }

    private static Map<String, List<Checklist_Item__c>> getCheckListItems(List<String> checkListId){

        Map<String, List<Checklist_Item__c>> checkListItemsMap = new Map<String, List<Checklist_Item__c>>();
        // checklist instance lookup and checklist item lookup
        List<Checklist_Item__c> checkListItems = [SELECT Id, Checklist__c,Checklist_Section__c, Checklist_Section__r.Parent_Section__c FROM Checklist_Item__c WHERE Checklist__c IN: checkListId];
        for(Checklist_Item__c item : checkListItems){
            if(checkListItemsMap.containskey(item.Checklist__c)){
                checkListItemsMap.get(item.Checklist__c).add(item);
            }else{
                checkListItemsMap.put(item.Checklist__c, new List<Checklist_Item__c>{item});
            }
        }
        return checkListItemsMap;
    }
}