@isTest
public class OpportunityStatusToEBSTest {
    static testMethod void testMethod1() {
        
        Test.setMock(HttpCalloutMock.class, new EBSRESTCalloutMock());
        
        User u = TestUtil.createUser(true);
        Account acc = TestUtil.createAccount('Person Account', false);
        acc.FirstName = 'Test';
        insert acc;
        
        Opportunity testOpportunity = TestUtil.createOpportunity('New Opp1', acc.Id, u.Id, false);
        testOpportunity.StageName='Closed';
		testOpportunity.Status__c = 'Transferred to Commercial';      
        insert testOpportunity;

        OpportunityStatusToEBS.Request oppr = new OpportunityStatusToEBS.Request();
        oppr.recordId = testOpportunity.Id;
        
        List<OpportunityStatusToEBS.Request> opprList = new List<OpportunityStatusToEBS.Request>();
        opprList.add(oppr);
        
        OpportunityStatusToEBS.SendOpportunityStatusToEBS(opprList);
    }
}