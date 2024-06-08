@IsTest
public class VoiceAnswerScreenControllerTest {

    @TestSetup
    private static void createData() {
        Account acc = TestUtil.createAccount('Person Account', false);
        acc.PersonMobilePhone = '9999999999';
        acc.Mobile_Idx__c = '9999999999';
        Account acc2 = TestUtil.createBranchAccount('Pella Account', false);
        acc2.ShippingStreet = 'test';
        acc2.ShippingCity = 'test';
        acc2.ShippingState = 'test';
        acc2.ShippingPostalCode = 'test';
        insert new List<Account>{acc, acc2};
        Contact con = TestUtil.createContact(acc2.Id, 'test', false);
        con.Active_SERVICE__c = true;
        con.FirstName = 'test';
        con.Email = 'test@test.com';
        con.MobilePhone = '9999999999';
        con.Mobile_Idx__c = '9999999999';
        insert con;
        Case caseObj = new Case(AccountId = acc.Id, ContactId = con.Id, Purchase_Order__c = '123', Quote_Number__c = 'ABC', Order_Number__c = '456');
        insert caseObj;
    }

    @IsTest
    private static void getCustomerFromPhone() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
        VoiceAnswerScreenResponse resp = VoiceAnswerScreenController.getCustomerDetailsBasedOnPhone('9999999999');
        System.Assert.areEqual(7, resp.custDetailsList.size());
        Test.stopTest();
    }
    
    @IsTest
    private static void getSelectedCustomerDetailsForAccount() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
    	VoiceAnswerScreenResponse resp2 = VoiceAnswerScreenController.getDetailsRelatedToCustomer([Select Id from Account LIMIT 1].Id, null, null, null, null);
        System.Assert.areEqual([Select Id, CaseNumber from Case LIMIT 1].CaseNumber, resp2.caseList[0].CaseNumber);     
        Test.stopTest(); 
    }

    @IsTest
    private static void getSelectedCustomerDetailsForContact() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
        VoiceAnswerScreenResponse resp3 = VoiceAnswerScreenController.getDetailsRelatedToCustomer([Select Id from Contact LIMIT 1].Id,'11111', '11111', '11111', '11111');
        System.Assert.areEqual(null, resp3.caseNo); 
        Test.stopTest(); 
    }
    
    
    @IsTest
    private static void getSelectedCustomerDetailsForContactPO() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
        VoiceAnswerScreenResponse resp3 = VoiceAnswerScreenController.getDetailsRelatedToCustomer([Select Id from Contact LIMIT 1].Id, null, '123', null, null);
        System.Assert.areEqual([Select Id, CaseNumber from Case LIMIT 1].CaseNumber, resp3.caseList[0].CaseNumber);        
        Test.stopTest(); 
    }
    
    
    @IsTest
    private static void getSelectedCustomerDetailsForContactQNO() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
        VoiceAnswerScreenResponse resp3 = VoiceAnswerScreenController.getDetailsRelatedToCustomer([Select Id from Contact LIMIT 1].Id, null, null, 'ABC', null);
        System.Assert.areEqual([Select Id, CaseNumber from Case LIMIT 1].CaseNumber, resp3.caseList[0].CaseNumber);   
		Test.stopTest();         
    }
    
    
    @IsTest
    private static void getSelectedCustomerDetailsForContactONO() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
        VoiceAnswerScreenResponse resp3 = VoiceAnswerScreenController.getDetailsRelatedToCustomer([Select Id from Contact LIMIT 1].Id, null, null, null, '456');
        System.Assert.areEqual([Select Id, CaseNumber from Case LIMIT 1].CaseNumber, resp3.caseList[0].CaseNumber);  
        Test.stopTest(); 
    }
    
    @IsTest
    private static void getCustomerSearch() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
    	VoiceAnswerScreenResponse resp4 = VoiceAnswerScreenController.getContactFromSearch('test', 'test', 'test', '9999999999', 'test@test.com', 'test', 'test', 'test', 'test', null, null, null, null);
        System.Assert.areEqual(null, resp4.caseList);
        Test.stopTest(); 
    }


    @IsTest
    private static void getCustomerSearchWithWildCardPhone() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
        VoiceAnswerScreenResponse resp5 = VoiceAnswerScreenController.getContactFromSearch(null, 'test', 'test', '99999999%', 'test@test.com', 'test', 'test', 'test', 'test', null, null, null, null);
        VoiceAnswerScreenResponse resp6 = VoiceAnswerScreenController.getContactFromSearch(null, 'test', null, null, null, null, null, null, null, '11111', '11111', '11111', '11111');
        System.Assert.areEqual('11111', resp6.orderNo);   
        Test.stopTest(); 
    }
    
    
    @IsTest
    private static void getContactFromAddresInputs() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        Test.startTest();
    	VoiceAnswerScreenResponse resp7 = VoiceAnswerScreenController.getContactFromSearch(null, null, null, null, null, 'test', 'test', 'test', 'test', null, null, null, null);
        VoiceAnswerScreenResponse resp8 = VoiceAnswerScreenController.getContactFromSearch(null, 'test', null, null, null, null, null, null, null, null, null, null, null);
        System.Assert.areEqual('Jason Rall', resp8.custDetailsList[0].custAccountName);
        VoiceAnswerScreenResponse resp9 = VoiceAnswerScreenController.getContactFromSearch(null, 'test', null, null, null, null, null, null, null, [Select Id, CaseNumber from Case LIMIT 1].CaseNumber, null, null, null);
        Test.stopTest(); 
    }    
}