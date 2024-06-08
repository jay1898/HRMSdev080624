@isTest
private class ServicePOSTVantageTest 
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
        String jsonStr = '{"questions":[{"question_id":"f651bf72-b27c-483d-a3bd-978c10079b43","question_text":"Have you done a lot of home improvement projects?","answer_text":"Sometimes","notes":"testnote0"},{"question_id":"3c9f301f-ec5d-425e-8f77-1c2c0b38e43c","question_text":"Did you do the projects yourself?","answer_text":"No","notes":"testnote1"},{"question_id":"ccb39f04-0dac-4af3-a4aa-ed5110201084","question_text":"What types of projects?","answer_text":"Window replacement Door replacement","notes":"testnote2"},{"question_id":"d36c4988-71a2-49c2-8144-f443fa901db4","question_text":"Have you done a lot of research?","answer_text":"Somewhat","notes":""},{"question_id":"dfa95d0e-add0-423a-84ad-a720a97d7e1f","question_text":"What have you learned?","answer_text":"answer here"},{"question_id":"fec6ecfd-fb22-4b1b-9c36-3e4556200688","question_text":"Do you have a specific look or vision in mind? Select all that apply.","answer_text":"Match current","notes":""},{"question_id":"bb1d61f8-6c64-429b-94bc-e19d4b092718","question_text":"Do you have a material in mind for your windows/doors? Select all that apply.","answer_text":"Wood","notes":""},{"question_id":"dd2c33a9-f4a0-43e2-992b-440b6c40e08d","question_text":"What is important to you? Select all that apply.","answer_text":"Matching existing","notes":""},{"question_id":"e685ec4a-560e-4554-887c-5a4895841f3e","question_text":"Final Notes","answer_text":"other notes would go here"}],"appointmentId":"'+sa.Id+'","financing":{"payment_terms":"financing option OR pay_in_full","down_payment":0,"deposit":0,"total_discount":0,"total_price":0,"sale_total":0,"total_install":0,"tax_rate":0}}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ServicePOSTVantage.postData();
        Test.stopTest();
    }
    static testMethod void testMethod2() 
    {
        // Make JSON 
        String jsonStr = '{"question":[{"question_id":"f651bf72-b27c-483d-a3bd-978c10079b43","question_text":"Have you done a lot of home improvement projects?","answer_text":"Sometimes","notes":"testnote0"},{"question_id":"3c9f301f-ec5d-425e-8f77-1c2c0b38e43c","question_text":"Did you do the projects yourself?","answer_text":"No","notes":"testnote1"},{"question_id":"ccb39f04-0dac-4af3-a4aa-ed5110201084","question_text":"What types of projects?","answer_text":"Window replacement Door replacement","notes":"testnote2"},{"question_id":"d36c4988-71a2-49c2-8144-f443fa901db4","question_text":"Have you done a lot of research?","answer_text":"Somewhat","notes":""},{"question_id":"dfa95d0e-add0-423a-84ad-a720a97d7e1f","question_text":"What have you learned?","answer_text":"answer here"},{"question_id":"fec6ecfd-fb22-4b1b-9c36-3e4556200688","question_text":"Do you have a specific look or vision in mind? Select all that apply.","answer_text":"Match current","notes":""},{"question_id":"bb1d61f8-6c64-429b-94bc-e19d4b092718","question_text":"Do you have a material in mind for your windows/doors? Select all that apply.","answer_text":"Wood","notes":""},{"question_id":"dd2c33a9-f4a0-43e2-992b-440b6c40e08d","question_text":"What is important to you? Select all that apply.","answer_text":"Matching existing","notes":""},{"question_id":"e685ec4a-560e-4554-887c-5a4895841f3e","question_text":"Final Notes","answer_text":"other notes would go here"}],"opportunity":"0063i00000B6kIH","financing":{"payment_terms":"financing option OR pay_in_full","down_payment":0,"deposit":0,"total_discount":0,"total_price":0,"sale_total":0,"total_install":0,"tax_rate":0}}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ServicePOSTVantage.postData();
        Test.stopTest();
    }
    static testMethod void testMethod3() 
    {
        // Make JSON 
        String jsonStr = '{"question":[{"question_id":"f651bf72-b27c-483d-a3bd-978c10079b43","question_text":"Have you done a lot of home improvement projects?","answer_text":"Sometimes","notes":"testnote0"},{"question_id":"3c9f301f-ec5d-425e-8f77-1c2c0b38e43c","question_text":"Did you do the projects yourself?","answer_text":"No","notes":"testnote1"},{"question_id":"ccb39f04-0dac-4af3-a4aa-ed5110201084","question_text":"What types of projects?","answer_text":"Window replacement Door replacement","notes":"testnote2"},{"question_id":"d36c4988-71a2-49c2-8144-f443fa901db4","question_text":"Have you done a lot of research?","answer_text":"Somewhat","notes":""},{"question_id":"dfa95d0e-add0-423a-84ad-a720a97d7e1f","question_text":"What have you learned?","answer_text":"answer here"},{"question_id":"fec6ecfd-fb22-4b1b-9c36-3e4556200688","question_text":"Do you have a specific look or vision in mind? Select all that apply.","answer_text":"Match current","notes":""},{"question_id":"bb1d61f8-6c64-429b-94bc-e19d4b092718","question_text":"Do you have a material in mind for your windows/doors? Select all that apply.","answer_text":"Wood","notes":""},{"question_id":"dd2c33a9-f4a0-43e2-992b-440b6c40e08d","question_text":"What is important to you? Select all that apply.","answer_text":"Matching existing","notes":""},{"question_id":"e685ec4a-560e-4554-887c-5a4895841f3e","question_text":"Final Notes","answer_text":"other notes would go here"}],"appointmentId":"0063i00000B6kIH","financing":{"payment_terms":"financing option OR pay_in_full","down_payment":0,"deposit":0,"total_discount":0,"total_price":0,"sale_total":0,"total_install":0,"tax_rate":0}}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ServicePOSTVantage.postData();
        Test.stopTest();
    }
}