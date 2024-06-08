@isTest
public class ErrorScreenControllerTest {
    
    @TestSetup
    static void testSetup(){
            Account accountObj = TestUtil.createBranchAccount('Pella Account', false);
            accountObj.BillingPostalCode = '12345'; 
            accountObj.Account_Alert__c = 'Test Account Alert';
            insert accountObj;
            
        	Contact contactObj = TestUtil.createContact(accountObj.Id, 'test', false);
            contactObj.MailingPostalCode = '12345';
            contactObj.Contact_Alert__c = 'Test Contact Alert';
            insert contactObj;
            
            Case parentCase = new Case();
            parentCase.ContactId = contactObj.Id;
            parentCase.Internal_Comments__c = 'Test Internal Comments';
            parentCase.Status = 'Completed';
            parentCase.Subject = 'Parent Test subject';
            insert parentCase;    
    }

    
    @isTest
    /* To confirm that appropriate message is returned when alert field is populated on Account*/
    private static void retrieveAlertMessageOnAccount(){
        String accId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
            Map<String, List<String>> errorScreenMap = ErrorScreenController.getMessageData(new List<Id>{accId});
            Assert.areEqual(1, errorScreenMap.size(), 'Expected only Account alert');
            Assert.areEqual('Test Account Alert', errorScreenMap.get('Account')[0], 'Expected Account alert');
        Test.stopTest();
    } 
    
    @isTest
    /* To confirm that appropriate message is returned when alert field is populated on Contact*/
    private static void retrieveAlertMessageOnContact(){
        String conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
            Map<String, List<String>> errorScreenMap = ErrorScreenController.getMessageData(new List<Id>{conId});
            Assert.areEqual(2, errorScreenMap.size(), 'Expected 2 alerts by Contact along with parent Account alert');
            Assert.areEqual('Test Account Alert', errorScreenMap.get('Account')[0], 'Expected Account alert string');
            Assert.areEqual('Test Contact Alert', errorScreenMap.get('Contact')[0], 'Expected Contact alert string');
        Test.stopTest();
        
    } 
    
    @isTest
    /* To confirm that appropriate messages are returned when alert fields are populated on Case*/
    private static void retrieveAlertMessageOnCase(){
        String csId = [SELECT Id FROM Case LIMIT 1].Id;
        Test.startTest();
            Map<String, List<String>> errorScreenMap = ErrorScreenController.getMessageData(new List<Id>{csId});
            Assert.areEqual(3, errorScreenMap.size(), 'Expected 3 alerts by Case along with parent record of Contact and Account');
            Assert.areEqual('Test Account Alert', errorScreenMap.get('Account')[0], 'Expected Account alert');
            Assert.areEqual('Test Contact Alert', errorScreenMap.get('Contact')[0], 'Expected Contact alert');
            Assert.areEqual('Test Internal Comments', errorScreenMap.get('Case')[0], 'Expected Case Internal Comments');
        Test.stopTest();
    } 
}