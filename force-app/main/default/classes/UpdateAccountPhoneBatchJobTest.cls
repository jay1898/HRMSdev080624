@isTest
private class UpdateAccountPhoneBatchJobTest 
{
    static testMethod void testMethod1() 
    {
    	User u = TestUtil.createUser(false);
    	u.Alias ='dmigr' ;

    	System.runAs(new User(Id=UserInfo.getUserId()))
    	{
    		insert u ;
    	}

    	System.runAs(u)
    	{
    		// Create Account
	    	Account ac = TestUtil.createBranchAccount('Pella Account', true);

			Account child = TestUtil.createBranchAccount('Branch Account', false);
			child.ParentId = ac.Id ;
			child.Phone = null ;
			Database.DMLOptions dml = new Database.DMLOptions();
	        dml.DuplicateRuleHeader.allowSave = true;
	        dml.DuplicateRuleHeader.runAsCurrentUser = true ; 
	        Database.SaveResult saveResult = Database.insert(child, dml);
    	}

    	String CRON_EXP = '0 0 0 3 9 ? 2022' ;
		Test.startTest();
        	System.schedule('UpdateAccountPhoneBatchJobTest', CRON_EXP, new UpdateAccountPhoneBatchJob());
        Test.stopTest();    
    }
}