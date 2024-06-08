@isTest
public class SelfGenRTAControllerTest {
    @isTest
    public static void SelfGenRTAMethod(){
        
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
        
        
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', false); 
        lead.PostalCode ='37335';
        lead.Zone__c=childST.Id;
        lead.Status = 'Qualified';
        lead.Street = 'test';
        lead.City = 'test';
        lead.State = 'IN';
        lead.Phone = '9876543210';
        lead.Appointment_Type__c='NRT';
        
        insert lead;
        
        String requestData='{';
        requestData+='"FirstName":"Test2",';
        requestData+='"LastName":"Test2",';
        requestData+='"Email":"Test2879@mail.com",';
        requestData+='"Phone":"1232525252",';
        requestData+='"PhoneType":"Home",';
        requestData+='"Address":"Test2",';
        requestData+='"Address2":"Test2",';
        requestData+='"City":"Test2",';
        requestData+='"State":"CS",';
        requestData+='"Zipcode":"37335",';
        requestData+='"ProjectDetail":"Test2",';
        requestData+='"StartDateTime":"'+DateTime.now().format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'')+'",';
        requestData+='"EndDateTime":"'+DateTime.now().addHours(1).format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'')+'",';
        requestData+='"noOfDoors":"1",';
        requestData+='"noOfWindows":"1"';
        requestData+='}';
        
        Test.startTest();
        SelfGenRTAController.validateTimeBlock(requestData); 
        SelfGenRTAController.submitRTARequest(requestData);
        Test.stopTest();
    }
}