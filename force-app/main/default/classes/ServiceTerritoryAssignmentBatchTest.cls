@isTest
public class ServiceTerritoryAssignmentBatchTest{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    @isTest
    public static void TestServiceTerritoryAssignment(){
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch_Family');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true);   
            //update t2; 
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', false);
            bf.Branch_Family_Number__c = '100';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;
            
            Test.startTest();
            Database.executeBatch(new ServiceTerritoryAssignmentBatch(),2000);
            
            Test.stopTest();
            String jobId = System.schedule('ServiceTerritoryAssignmentBatchTest', CRON_EXP, new ServiceTerritoryAssignmentBatch());
            
        }
    }
    
    @isTest
    public static void TestServiceTerritoryAssignment2(){
        User testUser = TestUtil.createUser(false);
        testUser.AOR__C='Strategic America';
        insert testUser;
        system.runAs(testUser) 
        {
            Id activetypeId = TestUtil.getTerritoryTypeId('Branch');
            Territory2  t2= TestUtil.createTerritory2('100',activetypeId, true);   
            //update t2; 
            
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', false);
            bf.Branch_Family_Number__c = '100';
            insert bf;
            
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, false);
            branch.AOR__C=bf.Id;
            insert branch;
            
            OperatingHours oh = TestUtil.createOpreatingHours('Custom', false);
            oh.TimeZone = 'America/Phoenix';
            insert oh;
            
            //Parent Level Territory
            ServiceTerritory stParent = TestUtil.createParentServiceTerritory('Parent Territory1', oh.Id, branch.Id, false);
            stParent.PostalCode = '10000';
            stParent.IsActive = true;
            insert stParent;
            
            Test.startTest();
            Database.executeBatch(new ServiceTerritoryAssignmentBatch(),2000);
            
            Test.stopTest();
            String jobId = System.schedule('ServiceTerritoryAssignmentBatchTest', CRON_EXP, new ServiceTerritoryAssignmentBatch());
            
        }
    }
}