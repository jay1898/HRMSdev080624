@isTest
private class CreateAssignedResourcesBatchTest 
{
    static testMethod void testMethod1() 
    {
    	// Create User
        User usr = TestUtil.createUser(true);

        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep');

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

        // Create Sub Child Territory under Child Territory
        ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Sub Child', childST.Id, oh.Id, true);

        // Create 1st Service Resource
        ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);

        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 

        // Create 2nd Service Resource
        ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);

        // Create 2nd Service Territory Member for 2nd Resource
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 

        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true);

        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
	
		// Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, true);

        Test.startTest();
	        
        	List<AssignedResource> resources = [SELECT Id FROM AssignedResource WHERE ServiceAppointmentId = :sa.Id ];
        	if(resources.size() > 0) delete resources ;
        	sa.SchedStartTime = Datetime.now(); 
        	sa.SchedEndTime = Datetime.now().addDays(1);
        	update sa; 

        	sa.Status = 'Scheduled';
        	update sa ;
        	 
	        Test.setMock(HttpCalloutMock.class, new ServicePOSTRTAMock()); 
        	System.schedule('CreateAssignedResourcesBatch', '0 0 0 3 9 ? 2022', new CreateAssignedResourcesBatch());
        Test.stopTest() ;    
    }
}