@isTest
private class FillAppointmentMissingTimesBatchTest 
{
    static testMethod void testMethod1() 
    {
        Metadata_Control__c cs = new Metadata_Control__c() ;
    	List<Metadata_Control__c> css = [SELECT Id, Service_Territory_Disable_Trigger__c, Service_Resource_Disable_VR__c FROM Metadata_Control__c ];
    	if(css.size() > 0) cs.Id = css[0].Id ;
    	cs.Service_Territory_Disable_Trigger__c = true;
    	cs.Service_Territory_Disable_VR__c = true ; 
    	upsert cs ;

        // Create User
        User usr = TestUtil.createUser(false);
        String[] integrationUser=Label.Integration_UserName.split(' ');
        if(integrationUser.size()>1){
            usr.FirstName=integrationUser[0];
            usr.LastName=integrationUser[1];
        }else if(Label.Integration_UserName!=null && Label.Integration_UserName!=''){
            usr.LastName=Label.Integration_UserName;
        }
        insert usr;
        
        // Update current User title 
        update new User(Id = UserInfo.getUserId(),FirstName=usr.FirstName,LastName=usr.LastName, Title = 'Retail Sales Rep');
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '99999', bf.Id, true);
        
        // Create Opreating Hours
        OperatingHours oh = TestUtil.createOpreatingHours('Custom', true);
        
        // Create Time Slot
        TimeSlot ts = TestUtil.createTimeSlot(oh.Id, true);
        
        // Create Parent Territory
        ServiceTerritory parentST = TestUtil.createParentServiceTerritory('Main SA Appointment Territory Branch', oh.Id, branch.Id, true);
        
        // Create Child Territory under Parent Territory
        ServiceTerritory childST = TestUtil.createChildServiceTerritory('Main Child SA Appointment Zone RT', parentST.Id, oh.Id, false);
        childST.Lead_Receiver__c = UserInfo.getUserId() ;
        insert childST ;
        
        // Create Sub Child Territory under Child Territory
        //ServiceTerritory subChildST = TestUtil.createSubChildServiceTerritory('Main Sub SA Appointment Zipcode ', childST.Id, oh.Id, true);
        
        // Create 1st Service Resource
        //ServiceResource sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);

        ServiceResource sr1 ;
        List<ServiceResource> resources = [SELECT Id, Primary_Branch_Family__c FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() ];
        if(resources.size() > 0 ) sr1 = resources[0];
        if(sr1 == null) 
        {
        	sr1 = TestUtil.createServiceResource('Mayank', UserInfo.getUserId(), branch.Id, bf.Id, true);
        	// Create Service Territory Member for 1st Resource
        	ServiceTerritoryMember stm1 = TestUtil.createServiceTerritoryMember(sr1.Id, childST.Id, true); 
        }
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.Status = 'Scheduled';
        sa.Start_Datetime__c = sa.SchedStartTime ;
        sa.End_Datetime__c = sa.SchedEndTime ;
        insert sa ;

        sa.SchedStartTime = null ;
        sa.SchedEndTime = null ;
        sa.Status = 'Scheduled';
        update sa ; 

        sa.Status = 'Scheduled';
        update sa ;

        System.debug('UAC: sa batch ' + [SELECT Id, SchedStartTime, Status, Start_Datetime__c FROM ServiceAppointment WHERE ID = :sa.Id ] );

        Test.startTest();
	        //delete [SELECT Id FROM AssignedResource WHERE ServiceAppointmentId = sa.Id ];
        	System.schedule('FillAppointmentMissingTimesBatchTest', '0 0 0 3 9 ? 2050', new FillAppointmentMissingTimesBatch(null));
        Test.stopTest() ;
    }
}