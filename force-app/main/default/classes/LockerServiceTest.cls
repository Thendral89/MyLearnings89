@IsTest
public class LockerServiceTest {
    @IsTest
    static void testGenerateUniqueLockId() {
        String tagName = 'TestTag';
        String lockId1 = LockerService.generateUniqueLockId(tagName);
        String lockId2 = LockerService.generateUniqueLockId(tagName);
        Assert.areNotEqual(lockId1, lockId2, 'Lock IDs should be unique');
    }

    @IsTest
    static void testApplyAndReleaseLocksAcrossServices() {
        String lockId = LockerService.generateUniqueLockId('TestLock');
        LockerService.applyLocksAcrossServices(lockId);
        LockerService.releaseLockAcrossServices(lockId);
    }

    @IsTest
    static void testGetMethodApplyLock() {
        List<LockerService.InvocableRequest> requestList = new List<LockerService.InvocableRequest>();
        LockerService.InvocableRequest request = new LockerService.InvocableRequest();
        request.lockIdValue = LockerService.generateUniqueLockId('TestLock');
        request.releaseLock = false;
        requestList.add(request);
        List<LockerService.InvocableReponse> responses = LockerService.get(requestList);
        Assert.areEqual(1, responses.size(), 'Response size should match request size');
    }

    @IsTest
    static void testGetMethodReleaseLock() {
        String lockId = LockerService.generateUniqueLockId('TestLock');
        LockerService.applyLocksAcrossServices(lockId);
        List<LockerService.InvocableRequest> requestList = new List<LockerService.InvocableRequest>();
        LockerService.InvocableRequest request = new LockerService.InvocableRequest();
        request.lockIdValue = lockId;
        request.releaseLock = true;
        requestList.add(request);
        List<LockerService.InvocableReponse> responses = LockerService.get(requestList);
        Assert.areEqual(1, responses.size(), 'Response size should match request size');
    }

    @IsTest
    static void testCustomException() {
        try {
            LockerService lcClass = new LockerService();
            LockerService.get(null);
        } catch (Exception ex) {
            Assert.isTrue(ex instanceof LockerService.CustomException, 'Exception should be CustomException');
        }
    }
}