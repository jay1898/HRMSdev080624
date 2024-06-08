@isTest
private class UserLookupControllerTest {
    
    @isTest
    static void testSearchWithResults() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        
        User testUser = new User(
            Alias = 'standt1',
            Email='standarduser111@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            //RoleId = r.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser111@testorg.com'
        );
        insert testUser;
        
        List<String> userIdList = new List<String>{testUser.Id};
            
            Test.startTest();
        List<LookupSearchResult> results = UserLookupController.search('Test', userIdList);
        Test.stopTest();
    }
    
    @isTest
    static void testSearchWithoutResults() {
        Test.startTest();
        List<LookupSearchResult> results = UserLookupController.search('Nonexistent', new List<String>());
        Test.stopTest();
        
    }
    
    @isTest
    static void testSearchWithEmptyTerm() {
        // Call the search method with an empty search term
        Test.startTest();
        List<LookupSearchResult> results = UserLookupController.search('', new List<String>());
        Test.stopTest();
        
    }
    
    @isTest
    static void testSearchWithNullUserIdList() {
        Test.startTest();
        List<LookupSearchResult> results = UserLookupController.search('Test', null);
        Test.stopTest();
    }
    
}