@isTest
public class CreateAppointmentFromOppBatchTest {
 
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
        
        // Create 2nd Opportunity
        Opportunity opp2 = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), true); 
        
        // Make JSON 
        String jsonStr = '{"recid":"5721184651_20191025185341","firstname":"Usman","lastname":"Ali","address":"ALiTest","address2":"","country":"US","city":"Gujranwala","state":"BA","zip":"37335","dayphone":"1234567890","phonetype":"HOME","email":"usman@test.com","urlstring":"utmsource:pellabranch-eastern-iowa^^utmcampaign:()^^utmmedium:referral^^utmcontent:request-an-appointment^^parentSite:www.pella.com^^EloquaID:44B02C7E0F354D339EE0297A372A8C09^^reqType:web","apptsource":"Web","comments":"Test Comments","destination":"ACE","branchID":100,';
        jsonStr += '"start":"2019-12-01T09:00:00.000Z","end_z":"2019-12-01T11:00:00.000Z","resource":"100105217(0),103834078(0),103574071(0),102588032(0)","notifyemail":1,"consentcall":"Y","consentsms":"Y","apptreqtype":"RT","appttype":"RT","storename":"Test","noOfDoors":12,"noOfWindows":10}';   
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServicePOSTRTAMock()); 
        ServicePOSTRTA.postData();
        
        
        Opportunity Opp1=[SELECT Id,name,Appointment_DateTime__c,Description,Appointment_Type__c,Virtual_Appointment__c
            ,accountId, Account.PersonContactId,Account.PersonContact.MailingPostalCode,Account.PersonContact.MailingCity
            ,Account.PersonContact.MailingState,Account.PersonContact.MailingCountry,type
             FROM Opportunity limit 1];
        opp1.Appointment_DateTime__c=DateTime.now();
        opp1.Appointment_Type__c='Preferred';
        opp1.OwnerId=childST.Lead_Receiver__c;
        update opp1;
        
        CreateAppointmentFromOppBatch b = new CreateAppointmentFromOppBatch(); 
        CreateAppointmentFromOppBatch.oppId=opp.Id;      
        database.executebatch(b,1);
         
        Test.stopTest();
     
    }
    
}