@IsTest
public class Branch_SA_Campaign_AssignmentBatchTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testMethod void testMethod1(){
        
        User u = TestUtil.createUser(false);
        u.AOR__C='Strategic America';
        insert u;
        
        system.runAs(u) 
        {
            Account acc = TestUtil.createAccount('Person Account', true);
            Branch_Grouping__c bf = TestUtil.createBranchGrouping('Strategic America', true);
            Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);
            Id activetypeId = TestUtil.getTerritoryTypeId('Replacement');
            Territory2  t2= TestUtil.createTerritory2(branch.Id,activetypeId, true);
            
            UserTerritory2Association UTA= TestUtil.createUserTerritory2Association(u.Id, t2.id, false);
            insert UTA;
            Test.startTest();
            Branch_SA_Campaign_AssignmentBatch bObj = new Branch_SA_Campaign_AssignmentBatch();
            Database.executeBatch(bObj, 200);
            System.schedule('Branch_SA_Campaign_AssignmentBatchTest', CRON_EXP, bObj);
            Test.stopTest();
        }
    }
    
}