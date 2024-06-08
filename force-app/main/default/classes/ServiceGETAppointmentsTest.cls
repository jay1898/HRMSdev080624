@isTest
private class ServiceGETAppointmentsTest 
{
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

        ServiceGETAppointments.Request conReq = new ServiceGETAppointments.Request();
        conReq.oppNo = opp.Opportunity_No__c ;
        conReq.email = ac.PersonEmail ;
        conReq.lastName = ac.LastName ;
        conReq.phoneNumber = ac.PersonMobilePhone ;
        conReq.zipcode = ac.PersonMailingPostalCode ;

        req.requestBody = Blob.valueOf( 'TEst' );
        ServiceGETAppointments.getAppointments();

        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServiceGETAppointments.getAppointments();

        conReq.type = 'Web';
        req.requestBody = Blob.valueOf( JSON.serialize(conReq) );
        ServiceGETAppointments.getAppointments();
        
        req.requestURI = '/SearchAppointments/'+ opp.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        ServiceGETAppointments.getOppAppointments();

    }
}