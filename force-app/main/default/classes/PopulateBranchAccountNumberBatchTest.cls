@IsTest
public class PopulateBranchAccountNumberBatchTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void testMethod1(){
        
        Account acc = TestUtil.createBranchAccount('Branch Account', false);
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
        branch.T_C_Branch_Number__c = '180';
        insert branch;
        acc.Branch__c = branch.Id;
        insert acc;
        
        Test.startTest();
        PopulateBranchAccountNumberBatch bObj = new PopulateBranchAccountNumberBatch();
        Database.executeBatch(bObj, 200);
        System.schedule('PopulateBranchAccountNumberBatchTest', CRON_EXP, bObj);
        Test.stopTest();
    }
    static testMethod void testMethod2(){
        
        Account acc = TestUtil.createBranchAccount('Branch Account', true); 
        Test.startTest();
        PopulateBranchAccountNumberBatch bObj = new PopulateBranchAccountNumberBatch();
        Database.executeBatch(bObj, 200);
        System.schedule('PopulateBranchAccountNumberBatchTest', CRON_EXP, bObj);
        Test.stopTest();
    }
}