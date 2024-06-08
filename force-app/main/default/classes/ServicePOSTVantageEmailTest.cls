@isTest
private class ServicePOSTVantageEmailTest 
{
    static testMethod void testMethod1() 
    {
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
        
        // Create 2nd Service Resource
        //ServiceResource sr2 = TestUtil.createServiceResource('Usman', usr.Id, branch.Id, bf.Id, true);
        
        // Create 2nd Service Territory Member for 2nd Resource
        //ServiceTerritoryMember stm2 = TestUtil.createServiceTerritoryMember(sr2.Id, childST.Id, true); 
        
        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
        
        // Create 1st Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true); 
        
        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.Status = 'Scheduled';
        insert sa ;
        
        
        // Make JSON 
        String jsonStr = '{"opportunity_id": "'+opp.Id+'","appointment_id": "'+sa.Id+'","sales_rep_id": "'+usr.Id+'","customer_email": "dhruv.javiyasfdc@gmail.com","message": "body of message","links": {"customer": "https://someurl.xn--com-9o0a","sales_rep": "https://someurl.xn--com-9o0a"}}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ServicePOSTVantageEmail.postData();
        Test.stopTest();
    }
    static testMethod void testMethod2() 
    {
        // Make JSON 
        String jsonStr = '{"opportunity_id": "0067j000006xoEP","appointment_id": "08p7j0000004aBG","sales_rep_id": "0053i000002gILh","customer_email": "dhruv.javiyasfdc@gmail.com","message": "body of message","links": {"customer": "https://someurl.xn--com-9o0a","sales_rep": "https://someurl.xn--com-9o0a"}}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ServicePOSTVantageEmail.postData();
        Test.stopTest();
    }
}