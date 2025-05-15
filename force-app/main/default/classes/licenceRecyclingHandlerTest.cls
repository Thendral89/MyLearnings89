@isTest
public class licenceRecyclingHandlerTest {
    static testmethod void licenceRecycling(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='In-house Counsel'];
        User u1 = new User(Alias = 'standtss', Email='standardusers@cisco.com',
        EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='newus900@cisco.com');
        u1.FederationIdentifier = 'newus900@cisco.com';
        insert u1;
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.Phone', u1.name);
        attributes.put('User.Email', u1.Email);
        attributes.put('User.FirstName', u1.FirstName);
        attributes.put('User.LastName', u1.LastName);
        attributes.put('User.Title', u1.Title);
        attributes.put('User.CompanyName', u1.CompanyName);
        attributes.put('User.AboutMe', u1.AboutMe);
        attributes.put('User.Street', u1.Street);
        attributes.put('User.MFAPerformed', 'mfa');
        
        attributes.put('User.State', u1.State);
        attributes.put('User.City', u1.City);
       // attributes.put('User.Zip', u1.Zipcode);
        attributes.put('User.Country', u1.Country);
        attributes.put('User.CallCenter', u1.CallCenterid);
        attributes.put('User.Manager', u1.Managerid);
        attributes.put('User.MobilePhone', u1.MobilePhone);
        attributes.put('User.DelegatedApproverId', u1.DelegatedApproverId);
        
        attributes.put('User.Department', u1.Department);
        attributes.put('User.Division', u1.Division);
        attributes.put('User.EmployeeNumber', u1.EmployeeNumber);
        attributes.put('User.Extension', u1.Extension);
        attributes.put('User.Fax', u1.Fax);
        attributes.put('User.CommunityNickname', u1.CommunityNickname);
        attributes.put('User.LanguageLocaleKey', u1.LanguageLocaleKey);
        attributes.put('User.LocaleSidKey', u1.LocaleSidKey);
        attributes.put('User.Alias', u1.Alias);
        attributes.put('User.TimeZoneSidKey', u1.TimeZoneSidKey);
        attributes.put('User.EmailEncodingKey', u1.EmailEncodingKey);
       // attributes.put('User.UserPermissionsSFContentUser', u1.UserPermissionsSFContentUser);
        attributes.put('User.IsActive', string.valueof(u1.IsActive));
        attributes.put('User.ProfileId', u1.ProfileId);
       // ributes.put('User.LanguageLocaleKey', u1.LanguageLocaleKey);
        attributes.put('User.ReceivesAdminInfoEmails', string.valueof(u1.ReceivesAdminInfoEmails));
        attributes.put('User.ReceivesInfoEmails', string.valueof(u1.ReceivesInfoEmails));
        attributes.put('User.ForecastEnabled', string.valueof(u1.ForecastEnabled));
        attributes.put('User.Username', u1.Username);
        attributes.put('User.FederationIdentifier', u1.FederationIdentifier);
        attributes.put('User.MFAPerformed', 'mfa');
        //system.runAs(u1){
        licenceRecyclingHandler lrh = new licenceRecyclingHandler();
        //lrh.createUser(true,u1,attributes,'abcdef',true);
        lrh.createUser(u1.Id, u1.Id, u1.Id,
        'newus900@cisco.com', attributes, 'test');
        lrh.updateUser(u1.Id, u1.Id,u1.Id, u1.Id,
        'newus900@cisco.com', attributes, 'test');
       // }
    }
    
    static testmethod void licenceRecycling1(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='In-house Counsel'];
        User u1 = new User(Alias = 'standtss', Email='standardusers@testorgs.com',
        EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='newus900@cisco.com');
        u1.FederationIdentifier = 'newus900@cisco.com';
        insert u1;
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.Phone', u1.name);
        attributes.put('User.Alias', u1.Alias);
        attributes.put('User.MFAPerformed', 'mfa');
        
        licenceRecyclingHandler lrh = new licenceRecyclingHandler();
        //lrh.createUser(true,u1,attributes,'abcdef',true);
        lrh.createUser(u1.Id, u1.Id, u1.Id,
        'newus900@cisco.com', attributes, 'test');
        lrh.updateUser(u1.Id, u1.Id,u1.Id, u1.Id,
        'newus900@cisco.com', attributes, 'test');
       // }
    }
    
    static testmethod void licenceRecyclingwithoutmfa(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='In-house Counsel'];
        User u1 = new User(Alias = 'standtss', Email='standardusers@testorgs.com',
        EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='newus900@maxval.com');
        u1.FederationIdentifier = 'newus900@maxval.com';
        insert u1;
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.Phone', u1.name);
        attributes.put('User.Alias', u1.Alias);
        attributes.put('User.MFAPerformed', '');
        
        licenceRecyclingHandler lrh = new licenceRecyclingHandler();
        //lrh.createUser(true,u1,attributes,'abcdef',true);
        lrh.createUser(u1.Id, u1.Id, u1.Id,
        'newus900@maxval.com', attributes, 'test');
        lrh.updateUser(u1.Id, u1.Id,u1.Id, u1.Id,
        'newus900@maxval.com', attributes, 'test');
       // }
    }
   
    
    static testmethod void licenceRecyclingwithmfa(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='In-house Counsel'];
        User u1 = new User(Alias = 'standtss', Email='standardusers@testorgs.com',
        EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='newus901@maxval.com');
        u1.FederationIdentifier = 'newus901@maxval.com';
        insert u1;
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.Phone', u1.name);
        attributes.put('User.Alias', u1.Alias);
        attributes.put('User.MFAPerformed', 'mfa');
        
        licenceRecyclingHandler lrh = new licenceRecyclingHandler();
        //lrh.createUser(true,u1,attributes,'abcdef',true);
        lrh.createUser(u1.Id, u1.Id, u1.Id,
        'newus901@maxval.com', attributes, 'test');
        lrh.updateUser(u1.Id, u1.Id,u1.Id, u1.Id,
        'newus901@maxval.com', attributes, 'test');
       // }
    }
    
    
}