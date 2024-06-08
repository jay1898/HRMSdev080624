@isTest 
public class OppTerrAssignRemoveLogicFilterTest {
    static testMethod void OppTerrAssignDefaultLogicFilter()
    {
        // Create User
        User u = TestUtil.createUser(true);
        
          // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
       
        
        Opportunity opp = TestUtil.createOpportunity('TestOPP', ac.Id, u.Id, true);
        
        OppTerrAssignRemoveLogicFilter filter = new OppTerrAssignRemoveLogicFilter();
        
        Test.startTest();
        
        Map<Id, Id> resultMap = filter.getOpportunityTerritory2Assignments(new List<Id> {opp.Id});
        
        Test.stopTest();
     
 
    }
}