@isTest
public class TCLeadConvertControllerTest {
    @isTest
    public static void testMethod1(){
        Test.startTest();
        Lead ld = TestUtil.createLead('test', 'demo', false);
        ld.Status = 'Qualified';
        ld.State = 'IN';
        ld.Street = 'test';
        ld.City = 'test';
        ld.PostalCode = 'test';
        ld.Phone = '8969857456';
        insert ld;
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        TCLeadConvertController.getLeadStatus(ld.Id);
        TCLeadConvertController.getPickListValues();
        TCLeadConvertController.getLeadDetails(ld.Id);
        String reqData = '{"CustomerType":"RESBUILDER","OrganizationName":"test","FirstName":"test demo","LastName":"test","Email":null,"Phone":"1212121212","Address":"3 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220","county":"","branchId":"'+branch.Id+'","BillTo":true,"InstallAt":false,"ShipTo":true,"Business":false,"BillToPrimary":true,"InstallAtPrimary":false,"ShipToPrimary":true,"BusinessPrimary":false,"BillToIdentify":true,"InstallAtIdentify":true,"ShipToIdentify":true,"BusinessIdentify":true}';
        String AdditionalAddress = '[]';
        String contactRec = '{"FirstName":"test","LastName":"test","Email":"test@mail.com","Phone":"435-345-3535","Id":null}';
        String OpportunityRec ='{"Name":"test","StageName":"New","Type":"Trade","Market_Segment__c":"SP: Single Family Replacement","closeDate":"2020-09-28"}';
        TCLeadConvertController.convertLead(ld.Id, reqData, AdditionalAddress, contactRec, OpportunityRec);
        Test.stopTest();
    }
    @isTest
    public static void testMethod2(){
        Test.startTest();
        Lead ld = TestUtil.createLead('test', 'demo', true);
        TCLeadConvertController.getLeadStatus(ld.Id);
        TCLeadConvertController.getLeadDetails(ld.Id);
        Test.stopTest();
    }
    @isTest
    public static void testMethod3(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SearchAddressCalloutMock());
        TCLeadConvertController.getProjectAddress('XYZ', true);
        TCLeadConvertController.getAddressDetails('XYZ.com');
        Test.stopTest();
    }
}