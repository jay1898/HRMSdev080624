@isTest
public class ServicePOSTRescheduleAppointmentsTest 
{
    public static testMethod void testMethod1() 
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
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.Id, true);

        req.requestBody = Blob.valueOf( 'TEst' );
        ServicePOSTRescheduleAppointments.rescheduleAppointments();

        ServicePOSTRescheduleAppointments.Request conReq = new ServicePOSTRescheduleAppointments.Request();
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePOSTRescheduleAppointments.rescheduleAppointments();	

        conReq.type = 'Web';
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePOSTRescheduleAppointments.rescheduleAppointments();	

        conReq.appointmentID = sa.Id ;
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePOSTRescheduleAppointments.rescheduleAppointments();	

        conReq.start = String.valueOf(Datetime.now().addDays(1));
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePOSTRescheduleAppointments.rescheduleAppointments();	

        conReq.comments = 'Test Comment';
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServicePOSTRescheduleAppointments.rescheduleAppointments();	
     	
    }
}