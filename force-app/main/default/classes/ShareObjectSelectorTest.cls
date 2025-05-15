@IsTest
public class ShareObjectSelectorTest {
    @IsTest
    static void testSelectByParentIdAndUserOrGroupIdAndRowCause() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User userRecord = new User(
            Alias = 'standtss', 
            Email='standardusers@testorgs.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testings', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = profile.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='newusers90099001@testorg.com'
        );
        INSERT userRecord;
        SymphonyLF__Person__c personRecord = new SymphonyLF__Person__c(
            Name = 'inventors',
            SymphonyLF__Email__c = 'test@gmail.com.com',
            SymphonyLF__User__c = userRecord.Id,
            SymphonyLF__Type__c = 'Client',
            SymphonyLF__Contact_Type__c = 'Author'
        );
        INSERT personRecord;

        SymphonyLF__Person__Share  shareJob = new SymphonyLF__Person__Share (
            UserOrGroupId = userRecord.Id,
            ParentId = personRecord.Id,
            AccessLevel = 'Read',
            RowCause = Schema.SymphonyLF__Person__Share.RowCause.Manual
        );
        INSERT shareJob;
        ShareObjectSelector selector = new ShareObjectSelector('SymphonyLF__Person__Share');
        List<ShareObjectSelectorJSON> results = selector.selectByParentIdAndUserOrGroupIdAndRowCause(
            new Set<Id>{personRecord.Id},
            new Set<Id>{userRecord.Id},
            new Set<String>{'Manual','Owner'}
        );
        Assert.IsNotNull(results, 'The method should have returned a list of ShareObjectSelectorJSON objects.');
    }
}