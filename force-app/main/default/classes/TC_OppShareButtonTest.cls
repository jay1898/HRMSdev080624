@isTest
public class TC_OppShareButtonTest {
    static testMethod void testMethod1() 
    {
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);

        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('TEst', ac.Id, UserInfo.getUserId(), false);
        opp.Opportunity_No__c = '123';
        insert opp ;

        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 

        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, false);
        sa.Status = 'Scheduled';
        insert sa;
        
        Test.startTest();
        TC_OppShareButton.Request sReq = new TC_OppShareButton.Request();
        sReq.recordId = opp.Id;
        TC_OppShareButton.Request[] sReq1= new TC_OppShareButton.Request[]{};
        sReq1.add(sReq);
        TC_OppShareButton.RunOppShare(sReq1);       
        Test.stopTest();        
        

    }
}