public with sharing class LockerService {
    static Map<String, Integer> counterByTagName = new Map<String, Integer>();
    private static String lockId;
    private static Boolean lockApplied = false;
    public LockerService() {

    }

    public static String generateUniqueLockId(String tagName){
        Integer counter = 0;
        if(counterByTagName.containsKey(tagName)){
            counter = counterByTagName.get(tagName);
        }
        counter++;
        counterByTagName.put(tagName, counter);

        String uniqueInstanceName = tagName + ' <..> ' + String.valueOf(counter);
        return uniqueInstanceName;
    }

    public static void applyLocksAcrossServices(String lockIdValue){
        if(lockApplied == true){
            return;
        }

        if(String.isNotBlank(lockIdValue)){
            lockId = lockIdValue;
            lockApplied = true;
        }

        if(lockApplied == true){
           applyLock(lockIdValue);
        }
    }

    public static void releaseLockAcrossServices(String lockIdValue){
        if(String.isNotBlank(lockId)){
            if(lockId == lockIdValue){
                lockId = '';
                lockApplied = false;
            }
        }

        if(lockApplied == false){
            releaseLock(lockIdValue);

            if(newLockIdHasBeenApplied(lockIdValue)){
                applyLock(lockId);
            }
        }
    } 

    private static void applyLock(String lock){
        ApexSharingService.addLock(lock);
       // UnitOfWork.addLock(lock);
       // EmailService.addLock(lock);
       // AsynchronousJobsService.addLock(lock);
    }

    private static void releaseLock(String lock){
        // UnitOfWork.removeLock(lock);
        // UnitOfWork.commitWork();

        ApexSharingService.removeLock(lock);
        ApexSharingService.addAndThenRemoveSharesInService();
        ApexSharingService.clearService();

        // EmailService.removeLock(lock);
        // EmailService.sendPreparedEmailsInService();
        // EmailService.clearService();

        // AsynchronousJobsService.removeLock(lock);
        // AsynchronousJobsService.commitAllAsynchronousJobsInService();
        // AsynchronousJobsService.startProcessingJobsAfterExecutionContext();
        // AsynchronousJobsService.clearService();
/*
        QueueableGovernor.removeLock(lock);
        QueueableGovernor.startExecutingQueue();
        QueueableGovernor.clearService();
*/  
    }

    private static Boolean newLockIdHasBeenApplied(String oldLockId){
        if(
            lockApplied == true 
            &&
            (
                lockId != oldLockId
            )
        ){
            return true;
        }

        return false;
    }

    public class CustomException extends Exception{

    }

    @InvocableMethod
    public static List<InvocableReponse> get(List<InvocableRequest> requestList) {
        try{
            String lockIdValue = requestList[0].lockIdValue;
            List<InvocableReponse> results = new List<InvocableReponse>();

            if(requestList[0].releaseLock != null && requestList[0].releaseLock == true){
                LockerService.releaseLockAcrossServices(lockIdValue);
            }
            else{
                LockerService.applyLocksAcrossServices(lockIdValue);
            }

            for(InvocableRequest r : requestList){
                InvocableReponse result = new InvocableReponse();
                results.add(result);
            }
            
            return results;
        }catch(Exception ex){
            throw new CustomException(ex.getStackTraceString() + ' ---> ' + ex.getCause());
        }
    }

    public class InvocableRequest {
        @InvocableVariable 
        public Boolean releaseLock;

        @InvocableVariable 
        public String lockIdValue;
    }

    public class InvocableReponse {
        @InvocableVariable 
        public Boolean lockReleased;
    }
 
}