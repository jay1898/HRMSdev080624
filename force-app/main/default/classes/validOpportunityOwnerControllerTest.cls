@isTest
public class validOpportunityOwnerControllerTest {
    public static testMethod void validOpportunityOwnerTest()
    {
        // Create User
        User usr = TestUtil.createUser(true);
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(), Title = 'Retail Sales Rep');
        
        
        User u2 = TestUtil.createUser(false);
        u2.AOR__C='Gale';
        insert u2;
        
        User u1 = TestUtil.createUser(false);
        u1.AOR__C='Gale';
        insert u1;
        
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
        
        // Create 1st Service Resource
        ServiceResource sr3 = TestUtil.createServiceResource('Dhruv', u1.Id, branch.Id, bf.Id, true);
        
        // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        
         // Create Service Territory Member for 1st Resource
        ServiceTerritoryMember stm3 = TestUtil.createServiceTerritoryMember(sr3.Id, childST.Id, true); 
       
        
        // Create 2nd Service Resource
        ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        Test.startTest();
        
         // Create Service Appointment
        ServiceAppointment sa2 = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa2.OwnerId = u1.Id ;
        insert sa2;
        
        
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.OwnerId = usr.Id ;
        insert sa;
        
        sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.OwnerId = usr.Id ;
        insert sa;
        
        sa.Status = 'Scheduled';
        update sa;
        
        opp.Zone__c = childST.Id ;
        update opp ;
        
		
        validOpportunityOwnerController.getValidOwnerList(sa.Id);
        Test.stopTest();
        
    }
}