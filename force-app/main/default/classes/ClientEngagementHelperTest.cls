@isTest
private class ClientEngagementHelperTest {
    
    @testSetup
    static void setupTestData() {
        
        Configuration__c config = new Configuration__c(
            Name = 'Client Auto Number Starting Point',
            Value__c = '999'
        );
        insert config;
        
        SymphonyLF__Person__c person1 = new SymphonyLF__Person__c(Name='Attorney 1',SymphonyLF__Email__c = 'test001@gmail.com' , SymphonyLF__User__c = UserInfo.getUserId(),SymphonyLF__Type__c = 'Client',SymphonyLF__Contact_Type__c = 'Author');
        SymphonyLF__Person__c person2 = new SymphonyLF__Person__c(Name='Attorney 2',SymphonyLF__Email__c = 'test002@gmail.com' , SymphonyLF__User__c = UserInfo.getUserId(),SymphonyLF__Type__c = 'Client',SymphonyLF__Contact_Type__c = 'Author');
        SymphonyLF__Person__c person3 = new SymphonyLF__Person__c(Name='Attorney 3',SymphonyLF__Email__c = 'test003@gmail.com' , SymphonyLF__User__c = UserInfo.getUserId(),SymphonyLF__Type__c = 'Client',SymphonyLF__Contact_Type__c = 'Author');
        SymphonyLF__Person__c person4 = new SymphonyLF__Person__c(Name='Attorney 4',SymphonyLF__Email__c = 'test004@gmail.com' , SymphonyLF__User__c = UserInfo.getUserId(),SymphonyLF__Type__c = 'Client',SymphonyLF__Contact_Type__c = 'Author');
        INSERT new List<SymphonyLF__Person__c>{person1, person2, person3, person4};

        SymphonyLF__Client__c client1 = new SymphonyLF__Client__c(
            Name = 'Test Client 1',
            Client_Status__c = 'Yet to Engage',
            Managing_Supervising_Attorney__c = person1.Id,
            Originating_Attorney__c = person2.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Classification__c = 'Client',
            SymphonyLF__Master_Company__c = true
        );

        SymphonyLF__Client__c client2 = new SymphonyLF__Client__c(
            Name = 'Test Client 2',
            Client_Status__c = 'Yet to Engage',
            Responsible_Billing_Attorney__c = person3.Id,
            Working_Assigned_Attorney__c = person4.Id,
            SymphonyLF__Entity_Size__c = 'Small',
            SymphonyLF__Client_Classification__c = 'Client',
            SymphonyLF__Master_Company__c = true
        );

        INSERT new List<SymphonyLF__Client__c>{client1, client2};
    }

    @isTest
    static void testProcessClientEngagementModels() {
        List<SymphonyLF__Client__c> clients = [SELECT Id, Client_Status__c,
            Managing_Supervising_Attorney__c, Originating_Attorney__c,
            Responsible_Billing_Attorney__c, Working_Assigned_Attorney__c
            FROM SymphonyLF__Client__c];

        Map<Id, SymphonyLF__Client__c> oldClientMap = new Map<Id, SymphonyLF__Client__c>();
        for (SymphonyLF__Client__c cli : clients) {
            oldClientMap.put(cli.Id, cli);
        }

        for (SymphonyLF__Client__c cli : clients) {
            cli.Client_Status__c = 'Active';
        }
        Test.startTest();
        	update clients;
        Test.stopTest();

        List<SymphonyLF__Client_Engagement_Model__c> engagementRecords = [SELECT Id, SymphonyLF__Client__c, SymphonyLF__Person__c, SymphonyLF__Type__c 
                                                                         FROM SymphonyLF__Client_Engagement_Model__c];
        Assert.areEqual(4, engagementRecords.size(), 'There should be 4 engagement models created');
        Assert.isNotNull(engagementRecords[0].SymphonyLF__Client__c , 'Engagement model should be linked to a client');
    }
}