public class QueryUtils {
    
    public static List<Object> extractValueFromParentOrChild(sObject sObjectToEvaluate, String filterFieldApiName){
        System.debug('filterFieldApiName ' + filterFieldApiName);
        List<Object> output = new List<Object>();
        List<String> fields = filterFieldApiName.split('\\.');
        
        if(fields == null || fields.size() == 0){
            output.add( null );       
        }
        
		sObject temp = sObjectToEvaluate;        
        System.debug('temp' + temp);
        List<sObject> records = new List<sObject>();
        
        Boolean isChildRelationship = isChildRelationship(fields[0]);
        System.debug('isChildRelationship ' + isChildRelationship);
        if(isChildRelationship){
            System.debug('fields[0]' + fields[0]);
            String childRelationshippath = fields[0].replace('__cr', '__r');
            System.debug('childRelationshippath' + childRelationshippath);
            List<sObject> childs = temp.getsObjects(childRelationshippath);
            System.debug('childs' + childs);
            records.addAll(childs);
        }else{
            records.add(temp);
        }
        
        String fieldsPath;
        if(isChildRelationship){
            Integer firstIndex = filterFieldApiName.indexOf('.');
            System.debug('firstIndex' + firstIndex);
            fieldsPath = filterFieldApiName.subString( firstIndex + 1, filterFieldApiName.length() );
		}
        else{
            fieldsPath = filterFieldApiName;
        }
        
        System.debug('fieldsPath' + fieldsPath);
        
        for(sObject record : records){
            System.debug('fieldsPath' + fieldsPath);
            object smallOutput = finalDepthFieldValue(record, fieldsPath);
            output.add(smallOutput);
        }
        return output;
    }
    
    private static Boolean isChildRelationship(String field){
        if(field.endsWith('__cr')){
            return true;
        }
        return false;
    }
    
    
    public static Object finalDepthFieldValue(sObject sObjectToEvaluate, String filterFieldApiName){
        List<String> fields = filterFieldApiName.split('\\.');
        sObject temp = sObjectToEvaluate;
        object finalResult;
        if(fields == null || fields.size() == 0){
            return null;       
        }
            for(Integer i = 0; i < fields.size(); i++){
                if(i == fields.size() - 1){
                    finalResult = temp.get(fields[i]);
                }else{
                    System.debug('<<<<<>>>>>>><<<<>>>>>>><<<<<<>>>>>' + temp.getSObject( fields[i] ));
                   temp = temp.getSObject( fields[i] );
                    if( temp == null ){
                        return null;
                    }
                }
            }
        return finalResult;
    }
}