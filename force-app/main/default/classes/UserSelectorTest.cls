@isTest
public class UserSelectorTest {

   @isTest
    static void testSelectById_withEmptyIds() {
        // Step 1: Initialize the UserSelector and set fields
        UserSelector userSelector = new UserSelector();
        userSelector.setFields(new List<String>{'Id', 'Username', 'Email'});
        
        // Step 2: Call the selectById method with an empty set of IDs
        Set<Id> emptyIds = new Set<Id>();
        Map<Id, User> result = userSelector.selectById(emptyIds);
        
        // Step 3: Assert the result is an empty map
        System.assertEquals(0, result.size(), 'The result map should be empty when no IDs are provided.');
    }
    
     @isTest
    static void testSelectById_withNonExistentIds() {
        // Step 1: Initialize the UserSelector and set fields
        UserSelector userSelector = new UserSelector();
        userSelector.setFields(new List<String>{'Id', 'Username', 'Email'});
        
        // Step 2: Call the selectById method with non-existent record IDs
        Set<Id> nonExistentIds = new Set<Id>{'000000000000000AAA', '000000000000000BBB'};
        Map<Id, User> result = userSelector.selectById(nonExistentIds);
        
    }
}