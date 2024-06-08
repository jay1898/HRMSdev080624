@isTest
public class UTA2TriggerHandlerTest {
    
    static testMethod void testMethod1() 
    {        
        Account acc = TestUtil.createAccount('Person Account', true);
        
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Id activetypeId = TestUtil.getTerritoryTypeId('Replacement');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, true);           
            
            UserTerritory2Association UTA= TestUtil.createUserTerritory2Association(testUser.Id, t2.id, true);
            
            ServiceResource sr = TestUtil.createServiceResource('Mayank', testUser.Id, branch.Id, bf.Id, false);
            sr.AccountId = acc.Id;
            insert sr;
        } 
    }  
    
    static testMethod void testMethod2() 
    {        
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            Id activetypeId = TestUtil.getTerritoryTypeId('Replacement');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, true);           
            
            UserTerritory2Association UTA= TestUtil.createUserTerritory2Association(testUser.Id, t2.id, true);
            UserTerritory2AssociationTriggerHandler.updateOpportunityContactOwner(new List<UserTerritory2Association>{UTA});
            delete UTA;
        } 
    }  
}