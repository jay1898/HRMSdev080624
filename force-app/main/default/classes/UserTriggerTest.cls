@isTest
public class UserTriggerTest {
    
    static testMethod void Usertest() 
    {   
        List<Metadata_Control__c> cs = new List<Metadata_Control__c>();
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Gale';
        insert testUser;
        testUser.AOR__C='Strategic America'; 
        Update testUser;
        
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            Cp.AOR__c=bf.Id;
            Cp.Type='AOR';
            insert Cp;
        }
    }
    
    static testMethod void Usertest2() 
    {   
        List<Metadata_Control__c> cs = new List<Metadata_Control__c>();
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Gale';
        insert testUser;
        testUser.AOR__C='Strategic America';
        Update testUser;
        
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            insert Cp;
        }
    }
    static testMethod void Usertest3() 
    {   
        List<Metadata_Control__c> cs = new List<Metadata_Control__c>();
        Profile ReplacementNSales = [Select id from Profile where Name = 'Replacement Sales Management' limit 1];
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Gale';
        insert testUser;
        testUser.AOR__C='Strategic America';
        testUser.ProfileId=ReplacementNSales.id;
        Update testUser;
        
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            insert Cp;
            
        }
    }
    static testMethod void Usertest4() 
    {   
        List<Metadata_Control__c> cs = new List<Metadata_Control__c>();
        Profile ReplacementNSales = [Select id from Profile where Name = 'Replacement Sales Management' limit 1];
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Gale';
        testUser.isActive=true;
        insert testUser;
        testUser.AOR__C='Strategic America';
        testUser.ProfileId=ReplacementNSales.id;
        Update testUser;
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            branch.PCC_Lead_Receiver__c=testUser.id;
            branch.Commercial_Lead_Receiver__c=testUser.id;
            branch.Trade_Lead_Receiver__c=testUser.id;
            insert branch;
            
            Campaign Cp = TestUtil.createCampaign('Test Campaign',branch.Id ,false);
            insert Cp;
            
        }
        testUser.IsActive=false;
        database.update(testUser,false);
        
       
    }
}