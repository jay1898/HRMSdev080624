@isTest
public class SalesRepBioControllerTest 
{
    static  testmethod void testmethod1()
    {
        User usr = TestUtil.createUser(true);
        
        Account ac = TestUtil.createAccount('Person Account', true);
        
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, usr.Id, true);
        
        SalesRepBioController upp = new SalesRepBioController();
        upp.OppId =  opp.Id ;
        System.assert(upp.relatedTo <> null);
        System.assert(upp.OppId <> null);
        
        upp = new SalesRepBioController();
        upp.OppId =  null ;
    }
    
}