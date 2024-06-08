@isTest 
public class OppTerrAssignDefaultLogicFilterTest {
    static testMethod void OppTerrAssignDefaultLogicFilter()
    {
        // Create User
        User u = TestUtil.createUser(true);
        
          // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
       
        
        Opportunity opp = TestUtil.createOpportunity('TestOPP', ac.Id, u.Id, true);
        
        OppTerrAssignDefaultLogicFilter filter = new OppTerrAssignDefaultLogicFilter();
        
        Test.startTest();
        
        Map<Id, Id> resultMap = filter.getOpportunityTerritory2Assignments(new List<Id> {opp.Id});
        OppTerrAssignDefaultLogicFilter.Territory2Priority tp = new OppTerrAssignDefaultLogicFilter.Territory2Priority(opp.Id, 1, false);
        
        Test.stopTest();
        
        System.assertEquals(1, resultMap.size());
        System.assertEquals(tp.territory2Id, opp.Id);
        System.assertEquals(1, tp.priority);
        System.assertEquals(false, tp.moreTerritoriesAtPriority);
 
    }
}