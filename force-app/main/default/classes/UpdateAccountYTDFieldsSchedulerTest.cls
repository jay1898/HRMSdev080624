@isTest
public class UpdateAccountYTDFieldsSchedulerTest {
   public static testMethod void testMethod1(){
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        acc.PY_Sales__c = 5;
        acc.PPY_Sales__c = 10;
        acc.YTD_Sales__c = 1; 
        insert acc;
        
        Test.startTest();       
        UpdateAccountYTDFields updateAccYTDField = new UpdateAccountYTDFields();
        updateAccYTDField.endDate = system.TODAY();
        Database.executeBatch(updateAccYTDField);
        system.schedule('Update Account YTD Field Test', '0 0 1 * * ?', new UpdateAccountYTDFieldsScheduler());
       UpdateAccountPYFields updateAccPYField = new UpdateAccountPYFields();
        Database.executeBatch(updateAccPYField);
       UpdateAccountPPYFields updateAccPPYField = new UpdateAccountPPYFields();
        Database.executeBatch(updateAccPPYField);
        Test.stopTest();
    }
}