@isTest
private class OpportunityToolbarControllerTest 
{
    static testMethod void testMethod1() 
    {
     	// Create Account
    	Account ac = TestUtil.createAccount('Person Account', true);
            
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), true);

        User u = TestUtil.createUser(false);

    	System.runAs(new User(Id=UserInfo.getUserId()))
    	{
    		insert u ;
    	}

    	System.runAs(u)
    	{
    		OpportunityToolbarController.addOpportunityTeam(opp.Id);
    	}

    }
}