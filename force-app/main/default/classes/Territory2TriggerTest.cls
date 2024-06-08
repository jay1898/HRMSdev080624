@isTest
public class Territory2TriggerTest {
    
    static testMethod void Territorytest() 
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
          
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, true);   
            
            update t2; 
        }
    }
    static testMethod void Territorytest2() 
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

            Branch_Grouping__c bf1 = TestUtil.createBranchGrouping('Strategic America', true);

            Branch__c branch1 = TestUtil.createBranch('Test1', '110', bf1.Id, false);
            branch1.AOR__C=bf1.Id;
            insert branch1;
            
          
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch_Family');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, true);   
            
            t2.Territory_Reference_Number__c = branch1.Id;
            update t2; 
        }
    }
     static testMethod void Territorytest3() 
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

            Branch_Grouping__c bf1 = TestUtil.createBranchGrouping('Strategic America', true);

            Branch__c branch1 = TestUtil.createBranch('Test1', '110', bf1.Id, false);
            branch1.AOR__C=bf1.Id;
            insert branch1;
            
          	Territory2  t1= TestUtil.createTerritory2(branch.Id,TestUtil.getTerritoryTypeId('Branch_Family'), true);   
            Territory2  t2= TestUtil.createTerritory2(branch.Id,TestUtil.getTerritoryTypeId('Branch_Family'), false);   
            t2.DeveloperName = 'Test1';
            t2.Name = 'Test1';
            insert t2;
            
            Territory2  t3= TestUtil.createTerritory2(branch.Id,TestUtil.getTerritoryTypeId('Branch'), false);  
            t3.DeveloperName = 'Test2';
            t3.Name = 'Test2';
            t3.ParentTerritory2Id=t2.id;
            insert t3;
             
            Territory2  t4= TestUtil.createTerritory2(branch.Id,TestUtil.getTerritoryTypeId('Replacement'), false); 
            t4.DeveloperName = 'Test4';
            t4.Name = 'Tes42';
            t4.ParentTerritory2Id=t3.id;
            insert t4;
             
            UserTerritory2Association UTA= TestUtil.createUserTerritory2Association(testUser.Id, t4.id, true);
            ServiceResource sr = TestUtil.createServiceResource('Mayank', testUser.Id, branch.Id, bf.Id, false);
            insert sr;
            t3.ParentTerritory2Id=t1.id;
            update t3;
            
            
        }
    }
}