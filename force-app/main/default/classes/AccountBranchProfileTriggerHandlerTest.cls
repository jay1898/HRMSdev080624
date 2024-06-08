@isTest
private class AccountBranchProfileTriggerHandlerTest 
{
    static testMethod void testMethod1() 
    {
    	Account ac = TestUtil.createAccount('Person Account', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);    
    }
}