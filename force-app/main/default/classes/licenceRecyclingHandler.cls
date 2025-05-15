global with sharing class licenceRecyclingHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    private void handleUser(boolean create, User u, Map<String, String> attributes,
                            String federationIdentifier, boolean isStandard) {
                                /** Debug statements to check Handle user **/
                                system.debug('Inside handleUser  ');
                                system.debug('create  : '+create);
                                system.debug('u  : '+u);
                                system.debug('attributes user detail fields  : '+attributes);
                                system.debug('federationIdentifier  : '+federationIdentifier);
                                system.debug('isStandard  : '+isStandard);
                                
                                
                                if(create && attributes.containsKey('User.Username')) 
                                {
                                   	string mUsername = 'Symphony_'+attributes.get('User.Username');
                                    u.Username = mUsername;
                                    u.Email = attributes.get('User.Username');
                                }
                                
                                if(create) {
                                    if(attributes.containsKey('User.FederationIdentifier')) {
                                        u.FederationIdentifier = attributes.get('User.FederationIdentifier');
                                    } else {
                                        u.FederationIdentifier = federationIdentifier;
                                    }
                                }
                                
                                if(!create && attributes.containsKey('User.Username')) 
                                {
                                    if(attributes.get('User.Username') == u.Username)
                                    {
                                        string mUsername = attributes.get('User.Username');
                                        u.Username = mUsername;  
                                        u.Email = attributes.get('User.Username');
                                    }
                                }
                                
                                
                                
                                if(attributes.containsKey('User.Phone')) {
                                    u.Phone = attributes.get('User.Phone');
                                }
                                                              
                                if(attributes.containsKey('User.Email')) 
                                {
                                    u.Email = attributes.get('User.Email');
                                }
                                
                                if(attributes.containsKey('User.FirstName')) {
                                    u.FirstName = attributes.get('User.FirstName');
                                }
                                if(attributes.containsKey('User.LastName')) {
                                    u.LastName = attributes.get('User.LastName');
                                }
                                if(attributes.containsKey('User.Title')) {
                                    u.Title = attributes.get('User.Title');
                                }
                                if(attributes.containsKey('User.CompanyName')) {
                                    u.CompanyName = attributes.get('User.CompanyName');
                                }
                                if(attributes.containsKey('User.AboutMe')) {
                                    u.AboutMe = attributes.get('User.AboutMe');
                                }
                                if(attributes.containsKey('User.Street')) {
                                    u.Street = attributes.get('User.Street');
                                }
                                if(attributes.containsKey('User.State')) {
                                    u.State = attributes.get('User.State');
                                }
                                if(attributes.containsKey('User.City')) {
                                    u.City = attributes.get('User.City');
                                }
                                if(attributes.containsKey('User.Zip')) {
                                    u.PostalCode = attributes.get('User.Zip');
                                }
                                if(attributes.containsKey('User.Country')) {
                                    u.Country = attributes.get('User.Country');
                                }
                                
                                if(attributes.containsKey('User.CallCenter')) {
                                    u.CallCenterId = attributes.get('User.CallCenter');
                                }
                                if(attributes.containsKey('User.Manager')) {
                                    u.ManagerId = attributes.get('User.Manager');
                                }
                                
                                if(attributes.containsKey('User.MobilePhone')) {
                                    u.MobilePhone = attributes.get('User.MobilePhone');
                                }
                                if(attributes.containsKey('User.DelegatedApproverId')) {
                                    u.DelegatedApproverId = attributes.get('User.DelegatedApproverId');
                                }
                                
                                if(attributes.containsKey('User.Department')) {
                                    u.Department = attributes.get('User.Department');
                                }
                                if(attributes.containsKey('User.Division')) {
                                    u.Division = attributes.get('User.Division');
                                }
                                if(attributes.containsKey('User.EmployeeNumber')) {
                                    u.EmployeeNumber = attributes.get('User.EmployeeNumber');
                                }
                                
                                if(attributes.containsKey('User.Extension')) {
                                    u.Extension = attributes.get('User.Extension');
                                }
                                if(attributes.containsKey('User.Fax')) {
                                    u.Fax = attributes.get('User.Fax');
                                }
                                
                                
                                if(attributes.containsKey('User.CommunityNickname')) {
                                    u.CommunityNickname = attributes.get('User.CommunityNickname');
                                }
                                
                                if(attributes.containsKey('User.ReceivesAdminInfoEmails')) {
                                    String ReceivesAdminInfoEmailsVal = attributes.get('User.ReceivesAdminInfoEmails');
                                    u.ReceivesAdminInfoEmails = '1'.equals(ReceivesAdminInfoEmailsVal) || Boolean.valueOf(ReceivesAdminInfoEmailsVal);
                                }
                                if(attributes.containsKey('User.ReceivesInfoEmails')) {
                                    String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
                                    u.ReceivesInfoEmails = '1'.equals(ReceivesInfoEmailsVal) || Boolean.valueOf(ReceivesInfoEmailsVal);
                                }
                                String uid = UserInfo.getUserId();
                                if(Schema.sObjectType.User.isAccessible())
                                {
                                    User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
                                    if(attributes.containsKey('User.LocaleSidKey')) {
                                        u.LocaleSidKey = attributes.get('User.LocaleSidKey');
                                    } else if(create) {
                                        u.LocaleSidKey = currentUser.LocaleSidKey;
                                    }
                                    if(attributes.containsKey('User.LanguageLocaleKey')) {
                                        u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
                                    } else if(create) {
                                        u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
                                    }
                                    if(attributes.containsKey('User.Alias')) {
                                        u.Alias = attributes.get('User.Alias');
                                    } else if(create) {
                                        String alias = '';
                                        if(u.FirstName == null) {
                                            alias = u.LastName;
                                        } else {
                                            alias = u.FirstName.charAt(0) + u.LastName;
                                        }
                                        /*if(alias.length() > 5) {
											alias = alias.substring(0, 5);
										}*/
                                        u.Alias = 'alias';
                                    }
                                    if(attributes.containsKey('User.TimeZoneSidKey')) {
                                        u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
                                    } else if(create) {
                                        u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
                                    }
                                    if(attributes.containsKey('User.EmailEncodingKey')) {
                                        u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
                                    } else if(create) {
                                        u.EmailEncodingKey = currentUser.EmailEncodingKey;
                                    }
                                }
                                if(attributes.containsKey('User.UserPermissionsSFContentUser')) {
                                    u.UserPermissionsSFContentUser = false;
                                }   else if(create) {
                                    u.UserPermissionsSFContentUser = false;
                                    //u.UserPreferencesContentNoEmail = false;
                                    //u.UserPreferencesContentEmailAsAndWhen = false;
                                    
                                }
                                
                                
                                
                                /*
								* If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
								* If your identity provider sends these User fields as attributes along with Contact 
								* or Account fields, you must modify the logic in this class to update either these 
								* User fields or the Contact and Account fields.
								*/
                                if(attributes.containsKey('User.IsActive')) {
                                    String IsActiveVal = attributes.get('User.IsActive');
                                    u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
                                }
                                                                
                                if((create && !attributes.containsKey('User.ProfileId')) || (create && attributes.containsKey('User.ProfileId')) )  {
                                    system.debug('No Profile Id');
                                    String profileId = 'Docketing Management';
                                    if(Schema.sObjectType.Profile.isAccessible()) {
                                        Profile p = [SELECT Id FROM Profile WHERE Name=:profileId or Id=:profileId];                                        
                                        u.ProfileId = p.Id;
                                    }
                                }
                                
                                System.debug('Status of User-- '+ u.IsActive + create);
                                if(!create && u.IsActive==false){
                                    System.debug('Status of User'+u.IsActive);
                                    u.IsActive = true;
                                    
                                    if(Schema.sObjectType.User.isUpdateable())
                                        update(u);
                                }
                            }
    
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               if(communityId != null || portalId != null) {
                                   handleUser(create, u, attributes, federationIdentifier, false);
                               } else {
                                   handleUser(create, u, attributes, federationIdentifier, true);
                               }
                           }
    
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               User u = new User();
                               handleJit(true, u, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                               return u;
                           }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               User u = [SELECT Id, Username, FirstName, ContactId, IsActive FROM User WHERE Id=:userId];
                               handleJit(false, u, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                           }
}