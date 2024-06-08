@isTest
global class AddressAssignmentTriggerTest 
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
        
        Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id,abp.Id,false);
        aa.Account__c=acc.Id;
        aa.Primary_Flag__c=true;
        aa.Identifying_Address__c=true;
        insert aa;
        
        list<Address_Assignment__c> aalist=new List<Address_Assignment__c>();
        Address_Assignment__c aa1 = TestUtil.createAddressAssignment(ad.Id,abp.Id,true);
        aa1.Account__c=acc.Id;
        aa1.Primary_Flag__c=true;
        aa1.Address_Usage_Type__c='Bill To';
        aa1.Identifying_Address__c=true;
        update aa1;
    }
    static testMethod void testMethod2() 
    {   
        User u = TestUtil.createUser(true);
        
        Account acc = TestUtil.createBranchAccount('Branch Account', true);
        
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);
        
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
     
        Account_Branch_Profile__c abp = TestUtil.createAccountBranchProfile(acc.Id,branch.Id,true);
        
        Address__c ad = TestUtil.createAddress(true);
        
        Address_Assignment__c aa = TestUtil.createAddressAssignment(ad.Id,abp.Id,false);
        aa.Identifying_Address__c=true;
        insert aa;
        
        list<Address_Assignment__c> aalist=new List<Address_Assignment__c>();
        Address_Assignment__c aa1 = TestUtil.createAddressAssignment(ad.Id,abp.Id,true);
        aa1.Account__c=acc.Id;
        aa1.Primary_Flag__c=true;
        aa1.Address_Usage_Type__c = 'Ship To';
        aa1.Identifying_Address__c=true;
        update aa1;
    }
}