public class clientChildShareObjWrapper implements Schedulable {
    clientControllerBatch childBatch;

    public clientChildShareObjWrapper(clientControllerBatch childBatch) {
        this.childBatch = childBatch;
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(childBatch, 2000);
    }
}