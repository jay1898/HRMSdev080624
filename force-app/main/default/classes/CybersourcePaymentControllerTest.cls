@isTest
public class CybersourcePaymentControllerTest {
    
    @TestSetup
    static void makeData(){
        Account accountObj              = TestUtil.createBranchAccount('Pella Account', false);
        accountObj.BillingPostalCode    = '12345'; 
        insert accountObj;
        Contact contactObj              = TestUtil.createContact(accountObj.Id, 'test', false);
        contactObj.MailingPostalCode    = '12345';
        insert contactObj;
        Case testCase = new Case(Subject='Test',ContactId=contactObj.Id);
        insert testCase;
        Case testCaseWithout = new Case(Subject='Test Without Payment');
        insert testCaseWithout;
        Payment__c testPayment = new Payment__c(Contact__c=contactObj.Id);
        insert testPayment;
        
    }
    
    // confirm that method returns a record if a Contact with a payment exists on the Case
    @isTest
    static void testCheckForExistingPayment(){ 
        list <Case> testCase = [Select Id FROM Case WHERE Subject = 'Test'];
        list <Payment__c> payments = CybersourcePaymentController.checkForExistingPayment(testCase[0].Id);
        system.assert(payments.size() > 0);  
            }
   
    // confirm that the method returns no record if there is no Contact with a payment on the Case
    @isTest
    static void testCheckForNonExistingPayment(){ 
        list <Case> testCase = [Select Id FROM Case WHERE Subject = 'Test Without Payment'];
        list <Payment__c> payments = CybersourcePaymentController.checkForExistingPayment(testCase[0].Id);
        system.assert(payments.size() == 0);  
            }

}