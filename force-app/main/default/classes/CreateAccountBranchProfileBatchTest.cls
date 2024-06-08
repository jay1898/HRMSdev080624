@isTest
private class CreateAccountBranchProfileBatchTest 
{
    static testMethod void testMethod1() 
    {
        // Create Account
    	Account ac = TestUtil.createAccount('Person Account', true);

        // Create Branch Family
    	Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);

        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);

        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);

        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);

        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Parent Territory', oh.Id, branch.Id, true);

        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Child', parentST.Id, oh.Id, true);

        // Create 1st Opportunity
		Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), false);
		opp.Zone__c = childST.Id ;
		insert opp ;

		Test.startTest();
			Database.executeBatch(new CreateAccountBranchProfileBatch());
		Test.stopTest(); 
    }
}