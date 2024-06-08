@isTest
public class CybersourcePaymentPageControllerTest {

    @TestSetup
    static void makeData(){
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        accountObj.BillingPostalCode    = '12345'; 
        insert accountObj;
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.MailingPostalCode    = '12345';
        insert contactObj;
        Case caseObj        			= new Case();
        caseObj.Status      			= 'Pending';
        caseObj.Origin      			= 'Email';
        caseObj.ContactId   			= contactObj.Id;
        CaseObj.Business_Segment__c 	= 'Trade';
        insert caseObj;
        Branch__c branchObj 			= new Branch__c(Merchant_Id__c = 'testDev', Branch_Number__c = '123');
        insert branchObj;
        Merchant__c merchantObj 		= new Merchant__c(Access_Key__c = 'test', MerchantEncrypt__c = 'test', Merchant_Id__c = 'testDev', Profile_Id__c = UserInfo.getProfileId(), Secret_Key__c = 'test');
        insert merchantObj;
    }
    

    @isTest
    static void testCyberSourceRedirect() {
        PageReference myVfPage = Page.CybersourcePaymentPage;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('conId',[Select Id from Contact LIMIT 1].Id);
        ApexPages.currentPage().getParameters().put('id',[Select Id from Case LIMIT 1].Id);
        ApexPages.currentPage().getParameters().put('type','Credit');
        ApexPages.currentPage().getParameters().put('amt','10');
        ApexPages.currentPage().getParameters().put('brchId',[Select Id from Branch__c LIMIT 1].Id);
        
        CybersourcePaymentPageController ac = new CybersourcePaymentPageController();
        ac.getCreateSignature();
    }
}