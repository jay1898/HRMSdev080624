@isTest
public class ServicePostConfirmAppointmentTest {
    static testMethod void testMethod1() 
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
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


        
        req.requestURI = '/ConfirmAppointment/'+ sa.Id;
        req.httpMethod = 'POST';
        RestContext.request = req;
        ServicePOSTConfirmAppointment.confirmAppointment();
        
         req.requestURI = '/ConfirmAppointment/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        ServicePOSTConfirmAppointment.confirmAppointment();
        
        sa.Status = 'Canceled';
        ServiceAppointmentTriggerHandler.Check_Conflict_Overriden = false ;
        sa.ownerid = UserInfo.getUserId();
        ServiceAppointmentTriggerHandler.RUN_TRIGGER = false;
        sa.Lead_Receiver__c = UserInfo.getUserId();
        update sa;
        
        req.requestURI = '/ConfirmAppointment/'+ sa.Id;
        req.httpMethod = 'POST';
        RestContext.request = req;
        ServicePOSTConfirmAppointment.confirmAppointment();        
        
        

    }
}