@isTest
public class Test_BranchAndCampaignAssignmentBatch {
    static testMethod void testMethod1() 
    {
        Test.startTest();
        BranchAndCampaignAssignmentBatch branchAndCampaign=new BranchAndCampaignAssignmentBatch();
        Database.executeBatch(branchAndCampaign);
        Test.stopTest();    
    }
}