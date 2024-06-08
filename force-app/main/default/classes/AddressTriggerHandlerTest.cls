@isTest
global class AddressTriggerHandlerTest 
{
    static testMethod void testMethod1() 
    {
        
        User u = TestUtil.createUser(true);
        
        Account acc = TestUtil.createAccount('Person Account', true);
        acc.PersonHomePhone='1236525632';
        acc.PersonOtherPhone='1236525632';
        acc.PersonAssistantPhone='1236525632';
        acc.Evening_Phone_Type__c='Home';
        update acc;
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
        
     
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(acc.Id,branch.Id,true);
        
        Address__c ad = TestUtil.createAddress(true);
        
        Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id,abp.Id,true);
        ad.Zipcode__c='A9A 9A9';
        ad.Country__c='CA';
        update ad;
        
    }
}