public class cmpAPiManageEventListener implements Queueable {
    private List<cmpAPiManageEvent__e> events;
    public cmpAPiManageEventListener(List<cmpAPiManageEvent__e> events) {
        this.events = events;
    }
    
    public void execute(QueueableContext context) {
        if (!events.isEmpty()) {
            for (cmpAPiManageEvent__e event : events) {
                //cmpAPiManageEventBatch b = new cmpAPiManageEventBatch(); 
                //Database.executeBatch(b,1);
            }
            
        }
    }
}