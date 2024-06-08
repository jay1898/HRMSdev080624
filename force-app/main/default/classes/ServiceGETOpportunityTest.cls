@isTest
private class ServiceGETOpportunityTest 
{
    static testMethod void testMethod1(){
        User testUser = TestUtil.createUser(false);
        testUser.EBS_UserName__c = 'SADHWANIR';
        insert testUser;
        system.runAs(testUser) 
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            RestContext.request = req;
            RestContext.response = res;
            
            // Create Account
            Account ac = TestUtil.createAccount('Person Account', false);
            ac.PersonHomePhone = ac.PersonMobilePhone ;
            ac.PersonOtherPhone = ac.PersonMobilePhone ;
            ac.PersonAssistantPhone = ac.PersonMobilePhone ;
            ac.PersonMailingStreet = '2 Test St';
            ac.PersonMailingCity = 'Belmont';
            ac.PersonMailingState = 'NH';
            ac.PersonMailingPostalCode = '03220-4052';
            ac.PersonMailingCountry = 'US';
            insert ac ;
            
            // Create Branch Family
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
            
            // Create Branch
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            
            //Create Address
            Address__c ad = TestUtil.createAddress(true);
            
            // Create Account Branch Profile
            Account_Branch_Profile__c abf = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
            
            // Create Address Assingment
            Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id, abf.Id, true);
            
            OperatingHours oh = TestUtil.createOpreatingHours('TestOp', true);
            
            // Create Parent Territory
            ServiceTerritory sap = TestUtil.createParentServiceTerritory('TestTerritory', oh.Id, branch.Id, true);
            
            // Create Parent Territory
            ServiceTerritory sapChild = TestUtil.createChildServiceTerritory('TestChildTerritory', sap.Id, oh.Id, true);
            
            // Create Opportunity
            Opportunity opp = TestUtil.createOpportunity('TEst-1', ac.Id, UserInfo.getUserId(), false);
            opp.Opportunity_No__c = '123';
            opp.Account_Branch_Profile__c = abf.Id ;
            insert opp ;
            
            // Create Lead
            Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
            
            // Create Service Appointment
            ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
            sa.Status = null ;
            insert sa ;
            sa.Status = 'Scheduled';
            update sa;
            
            //Create Territory
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch_Family');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, false);
            t2.BranchNumber__c = 'Test 1';
            t2.Territory_Reference_Number__c = 'Demo 1';
            t2.TCBranchNumber__c = 'Test Demo 1';
            insert t2;
            
            // Create UserTerritory2Association
            UserTerritory2Association UserTerritoryAssoc = TestUtil.createUserTerritory2Association(testUser.Id, t2.Id , true);
            
            req.requestBody = Blob.valueOf( 'Test' );
            ServiceGETOpportunity.getOpportunities();
            
            ServiceGETOpportunity.Request conReq = new ServiceGETOpportunity.Request();
            req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
            ServiceGETOpportunity.getOpportunities();
            
            conReq.FirstName = ac.FirstName ;
            conReq.LastName = ac.LastName ;
            conReq.address = '2,St,Belmont, NH 03220-4052,US';
            //conReq.username = 'SADHWANIR'; --Rekha
            conReq.username = testUser.name;
            conReq.City = ac.PersonMailingCity ;
            conReq.Postalcode = ac.PersonMailingPostalCode ;
            conReq.Phone = ac.PersonMobilePhone ;
            conReq.businessSegment = sapChild.ParentTerritory.Territory_Type__c;
            req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
            ServiceGETOpportunity.getOpportunities();
            
        }
    }
    
    static testMethod void testMethod2(){
        User testUser = TestUtil.createUser(false);
        testUser.Trade_Branch_Number__c = '998';
        testUser.EBS_UserName__c = 'SADHWANIR';
        insert testUser;
        system.runAs(testUser) 
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            RestContext.request = req;
            RestContext.response = res;
            
            // Create Branch Family
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
            
            // Create Branch
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.T_C_Branch_Number__c = 'Test Demo';
            insert branch;
            
            // Create Account
            Account ac = TestUtil.createBranchAccount('Branch Account', false);
            ac.BillingStreet = '2 Test St';
            ac.BillingCity = 'Belmont';
            ac.BillingState = 'NH';
            ac.BillingPostalCode = '03220-4052';
            ac.BillingCountry = 'US';
            ac.Branch__c = branch.Id;
            ac.branch_number__c = ';998;Test Demo;';//Rekha
            insert ac ;
            
            //Create Address
            Address__c ad = TestUtil.createAddress(true);
            
            // Create Account Branch Profile
            Account_Branch_Profile__c abf = TestUtil.createAccountBranchProfile(ac.Id, branch.Id, true);
            
            // Create Address Assingment
            Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id, abf.Id, false);
            aa.Account__c = ac.Id;
            insert aa;
            
            OperatingHours oh = TestUtil.createOpreatingHours('TestOp', true);
            
            // Create Parent Territory
            ServiceTerritory sap = TestUtil.createParentServiceTerritory('TestTerritory', oh.Id, branch.Id, true);
            
            // Create Parent Territory
            ServiceTerritory sapChild = TestUtil.createChildServiceTerritory('TestChildTerritory', sap.Id, oh.Id, true);
            
            // Create Opportunity
            Opportunity opp = TestUtil.createOpportunity('TEst-Trade', ac.Id, UserInfo.getUserId(), false);
            opp.Opportunity_No__c = '123';
            opp.Account_Branch_Profile__c = abf.Id ;
            opp.Type = 'Trade';
            opp.Zone__c = sapChild.Id;
            insert opp ;
            
            // Create Lead
            Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 
            
            // Create Service Appointment
            ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
            sa.Status = null ;
            insert sa ;
            sa.Status = 'Scheduled';
            update sa;
            
            //Create Territory
            Id activetypeId = TestUtil.getTerritoryTypeId('NRT_Zone');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, false);
            t2.BranchNumber__c = 'Test';
            t2.Territory_Reference_Number__c = 'Demo';
            t2.TCBranchNumber__c = 'Test Demo';
            insert t2;
            
            // Create UserTerritory2Association
            UserTerritory2Association UserTerritoryAssoc = TestUtil.createUserTerritory2Association(testUser.Id, t2.Id , true);
            
            ServiceGETOpportunity.Request conReq = new ServiceGETOpportunity.Request();
            //conReq.FirstName = ac.FirstName ;
            //conReq.LastName = ac.LastName ;
            conReq.organizationName = ac.name;            
            //conReq.address = ac.BillingAddress__c;
            conReq.username = testUser.name;
            //conReq.City = ac.BillingCity ;
            //conReq.Postalcode = ac.BillingPostalCode ;
            //conReq.Phone = ac.Phone ;
            conReq.organizationName = ac.Name;
            conReq.businessSegment = opp.Type;
            req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
            ServiceGETOpportunity.getOpportunities();
            
        }
    }
    
}