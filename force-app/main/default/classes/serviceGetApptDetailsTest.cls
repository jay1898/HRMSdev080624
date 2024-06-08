@isTest
private class serviceGetApptDetailsTest 
{
    static testMethod void testMethod1() 
    {
        
        // Create User
        User usr = TestUtil.createUser(false);
       usr.ProfileId = [Select Id From Profile Where Name='Data Migration'].id;
        insert usr;

        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);

        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('TEst', ac.Id, usr.id, false);
        opp.Opportunity_No__c = '123';
        insert opp ;

        // Create Lead
        Lead lead = TestUtil.createLead('John', 'Soft Assign Placeholder', true); 

        // Create Service Appointment
        ServiceAppointment sa = TestUtil.createServiceAppointment('Soft_Assign', 'Test', ac.Id, opp.Id, lead.id, true);
        
        string StartDateTime= string.valueOf(Datetime.now().addDays(-1));
        string EndDateTime= string.valueOf(Datetime.now().addDays(1));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
       req.requestURI = '/services/apexrest/GetApptDetails?StartDateTime='+StartDateTime+'&EndDateTime='+EndDateTime+'&UserEmail='+usr.Email;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        serviceGetApptDetails.doGet();
      //  system.assertEquals(acctResp.Name, 'Testing');

     /*   ServiceGETAppointments.Request conReq = new ServiceGETAppointments.Request();
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
        ServiceGETAppointments.getAppointments();*/

    }
}