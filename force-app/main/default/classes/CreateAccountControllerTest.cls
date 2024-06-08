@isTest
public class CreateAccountControllerTest {
    @isTest
    public static void testMethod1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SearchAddressCalloutMock());
        CreateAccountController.getProjectAddress('XYZ', true);
        CreateAccountController.getAddressDetails('XYZ.com');
        CreateAccountController.getCustomerType('XYZ');
        CreateAccountController.getBranchName(NULL);
        CreateAccountController.getPhoneType();
        CreateAccountController.getPhone('XYZ');
        //CreateAccountController.fetchUserSessionId();
        
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        String reqData = '{"CustomerType":"COMMBUILDER","OrganizationName":"test","FirstName":"","LastName":"","Email":"","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052","county":"Belknap","branchId":"'+branch.Id+'","BillTo":true,"InstallAt":true,"ShipTo":false,"Business":false,"BillToPrimary":true,"InstallAtPrimary":true,"ShipToPrimary":false,"BusinessPrimary":false,"BillToIdentify":true,"InstallAtIdentify":true,"ShipToIdentify":true,"BusinessIdentify":true}';
        String AdditionalAddress = '[{"Address":"101 3Rd St","Address2":"","City":"Abbeville","State":"LA","Zipcode":"70510-6651","county":"Vermilion","displayAddress":"101 3Rd St, , Abbeville LA 70510-6651","BillTo":true,"InstallAt":false,"ShipTo":true,"Business":false,"BillToPrimary":false,"InstallAtPrimary":false,"ShipToPrimary":true,"BusinessPrimary":false,"BillToIdentify":false,"InstallAtIdentify":false,"ShipToIdentify":false,"BusinessIdentify":false}]';
        String searchReq = '{"CustomerType":"COMMBUILDER","OrganizationName":"test","FirstName":"","LastName":"","Email":"","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052"}';
        CreateAccountController.createNewAccount(reqData, AdditionalAddress);
        CreateAccountController.searchExistingAccounts(searchReq);
        
		// String AddressData = '[{"Address":"101 3Rd St","Address2":"","City":"Abbeville","State":"LA","Zipcode":"70510-6651","county":"Vermilionse"}]';
       // CreateAccountController.createUpdateAddress(AddressData,'Vermilionse');
        Test.stopTest();
    }
    @isTest
    public static void testMethod2(){
        Test.startTest();
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        String reqData = '{"CustomerType":"Homeowner","OrganizationName":"test","FirstName":"test","LastName":"testAcc","Email":"test@mail.com","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052","county":"Belknap","branchId":"'+branch.Id+'","BillTo":true,"InstallAt":true,"ShipTo":false,"Business":false,"BillToPrimary":true,"InstallAtPrimary":true,"ShipToPrimary":false,"BusinessPrimary":false,"BillToIdentify":true,"InstallAtIdentify":true,"ShipToIdentify":true,"BusinessIdentify":true}';
        String AdditionalAddress = '[{"Address":"101 3Rd St","Address2":"","City":"Abbeville","State":"LA","Zipcode":"70510-6651","county":"Vermilion","displayAddress":"101 3Rd St, , Abbeville LA 70510-6651","BillTo":true,"InstallAt":false,"ShipTo":true,"Business":false,"BillToPrimary":false,"InstallAtPrimary":false,"ShipToPrimary":true,"BusinessPrimary":false,"BillToIdentify":false,"InstallAtIdentify":false,"ShipToIdentify":false,"BusinessIdentify":false}]';
        CreateAccountController.createNewAccount(reqData, AdditionalAddress);
        String searchReq = '{"CustomerType":"Homeowner","OrganizationName":"test","FirstName":"test","LastName":"testAcc","Email":"test@mail.com","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052"}';
        CreateAccountController.searchExistingAccounts(searchReq);
        Test.stopTest();
    }
    @isTest
    public static void testMethod3(){
        Test.startTest();
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
        //create Account
        Account acc = TestUtil.createBranchAccount('Branch Account', true);
        
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pro_Lowes').getRecordTypeId();
        
        String reqData = '{"currentRecId":"' + acc.Id + '","RecordTypeId":"' + recordTypeId + '","CustomerType":"Lumberyard/ProDealer","OrganizationName":"test","FirstName":"test","LastName":"testAcc","Email":"test@mail.com","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052","county":"Belknap","branchId":"'+branch.Id+'","BillTo":true,"InstallAt":true,"ShipTo":false,"Business":false,"BillToPrimary":true,"InstallAtPrimary":true,"ShipToPrimary":false,"BusinessPrimary":false,"BillToIdentify":true,"InstallAtIdentify":true,"ShipToIdentify":true,"BusinessIdentify":true}';
        String AdditionalAddress = '[{"Address":"101 3Rd St","Address2":"","City":"Abbeville","State":"LA","Zipcode":"70510-6651","county":"Vermilion","displayAddress":"101 3Rd St, , Abbeville LA 70510-6651","BillTo":true,"InstallAt":false,"ShipTo":true,"Business":false,"BillToPrimary":false,"InstallAtPrimary":false,"ShipToPrimary":true,"BusinessPrimary":false,"BillToIdentify":false,"InstallAtIdentify":false,"ShipToIdentify":false,"BusinessIdentify":false}]';
        CreateAccountController.createNewAccount(reqData, AdditionalAddress);
        String searchReq = '{"currentRecId":"' + acc.Id + '","RecordTypeId":"' + recordTypeId + '","CustomerType":"Lumberyard/ProDealer","OrganizationName":"test","FirstName":"test","LastName":"testAcc","Email":"test@mail.com","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052"}';
        CreateAccountController.searchExistingAccounts(searchReq);
        Test.stopTest();
    }
     @isTest
    public static void serviceCreateAccount(){
        
       // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        Branch__c branch1 = TestUtil.createBranch('Test', '640', bf.Id, true);
        Account acc = TestUtil.createBranchAccount('Branch Account', true);        
        Contact contact = TestUtil.createContact(acc.id, 'Test', true);
        case caseObj        = new Case();
        insert caseObj;
        caseObj.AssignedBranch__c = branch.id;
        caseObj.OwnerId     = UserInfo.getUserId();
        caseObj.ContactId = contact.id;
        update caseObj;
        caseObj.OwnerId     = [Select Id from Group where Type = 'Queue' LIMIT 1].Id;
        update caseObj;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SearchAddressCalloutMock());
        CreateAccountController.getProjectAddress('XYZ', true);
        CreateAccountController.getAddressDetails('XYZ.com');
        CreateAccountController.getCustomerType('XYZ');
        CreateAccountController.getBranchName(contact.id);
        CreateAccountController.getPhoneType();
        CreateAccountController.getPhone('XYZ');
        //CreateAccountController.fetchUserSessionId();
        

        
        String reqData = '{"CustomerType":"COMMBUILDER","OrganizationName":"test","FirstName":"","LastName":"","Email":"","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052","county":"Belknap","branchId":"'+branch.Id+'","serviceContactId":"'+contact.Id+'","BillTo":true,"InstallAt":true,"ShipTo":false,"Business":false,"BillToPrimary":true,"InstallAtPrimary":true,"ShipToPrimary":false,"BusinessPrimary":false,"BillToIdentify":true,"InstallAtIdentify":true,"ShipToIdentify":true,"BusinessIdentify":true}';
        String AdditionalAddress = '[{"Address":"101 3Rd St","Address2":"","City":"Abbeville","State":"LA","Zipcode":"70510-6651","county":"Vermilion","displayAddress":"101 3Rd St, , Abbeville LA 70510-6651","BillTo":true,"InstallAt":false,"ShipTo":true,"Business":false,"BillToPrimary":false,"InstallAtPrimary":false,"ShipToPrimary":true,"BusinessPrimary":false,"BillToIdentify":false,"InstallAtIdentify":false,"ShipToIdentify":false,"BusinessIdentify":false}]';
        String searchReq = '{"CustomerType":"COMMBUILDER","OrganizationName":"test","FirstName":"","LastName":"","Email":"","Phone":"452-872-1422","Address":"2 Test St","Address2":"","City":"Belmont","State":"NH","Zipcode":"03220-4052"}';
        CreateAccountController.createNewAccount(reqData, AdditionalAddress);
        CreateAccountController.searchExistingAccounts(searchReq);
        
		// String AddressData = '[{"Address":"101 3Rd St","Address2":"","City":"Abbeville","State":"LA","Zipcode":"70510-6651","county":"Vermilionse"}]';
       // CreateAccountController.createUpdateAddress(AddressData,'Vermilionse');
        Test.stopTest();
    }
}