public class ConflictCheckEmailRemainders_Schedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        ConflictCheckEmailRemainders_Batch batch = new ConflictCheckEmailRemainders_Batch();
        Database.executeBatch(batch, 200);
    }
}