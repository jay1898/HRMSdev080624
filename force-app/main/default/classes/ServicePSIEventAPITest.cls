@isTest
private class ServicePSIEventAPITest {
    static  testmethod void testmethod1()
    {
        string pqmNo  = createTestRecordPost();
        String jsonStr = '{"WhatId": "'+ pqmNo +'",  "Subject": "Test class Exce","Description" : "Test class Execution", "Event_Type__c":"Order Verification", "StartDateTime":"2019-12-01T09:00:00.000Z","EndDateTime" : "2019-12-01T11:00:00.000Z","ShowAs" : "Free","EbsAppointmentId" : "198883"}';  
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServicePSIEventAPIMock()); 
        ServicePSIEvent.postData();
        ServicePSIEvent.postData();
        Test.stopTest();
        
        ServicePSIEvent.Request contReq = (ServicePSIEvent.Request)JSON.deserialize(jsonStr,ServicePSIEvent.Request.class);
        req.requestBody = Blob.valueOf('Invalid JSON');
        ServicePSIEvent.postData();
        
    } 
    
    static  testmethod void testmethodwihtEbsBalnk()
    {
        string pqmNo  = createTestRecordPost();
        String jsonStr = '{"WhatId": "'+ pqmNo +'",  "Subject": "Test class Exce","Description" : "Test class Execution", "Event_Type__c":"Order Verification", "StartDateTime":"2019-12-01T09:00:00.000Z","EndDateTime" : "2019-12-01T11:00:00.000Z","ShowAs" : "Free","EbsAppointmentId" : ""}';  
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServicePSIEventAPIMock()); 
        ServicePSIEvent.postData();
        ServicePSIEvent.postData();
        Test.stopTest();
        
        ServicePSIEvent.Request contReq = (ServicePSIEvent.Request)JSON.deserialize(jsonStr,ServicePSIEvent.Request.class);
        req.requestBody = Blob.valueOf('Invalid JSON');
        ServicePSIEvent.postData();
        
    } 
    
    static  testmethod void testmethodwihtInvalidPQM()
    {
        string pqmNo  = createTestRecordPost();
        String jsonStr = '{"WhatId": "0000",  "Subject": "Test class Exce","Description" : "Test class Execution", "Event_Type__c":"Order Verification", "StartDateTime":"2019-12-01T09:00:00.000Z","EndDateTime" : "2019-12-01T11:00:00.000Z","ShowAs" : "Free","EbsAppointmentId" : "9898"}';  
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServicePSIEventAPIMock()); 
        ServicePSIEvent.postData();
        ServicePSIEvent.postData();
        Test.stopTest();
        
        ServicePSIEvent.Request contReq = (ServicePSIEvent.Request)JSON.deserialize(jsonStr,ServicePSIEvent.Request.class);
        req.requestBody = Blob.valueOf('Invalid JSON');
        ServicePSIEvent.postData();
        
    } 
    
    static  testmethod void testmethodwihtInvalidType()
    {
        string pqmNo  = createTestRecordPost();
        String jsonStr = '{"WhatId": "'+ pqmNo +'",  "Subject": "Test class Exce","Description" : "Test class Execution", "Event_Type__c":"Order", "StartDateTime":"2019-12-01T09:00:00.000Z","EndDateTime" : "2019-12-01T11:00:00.000Z","ShowAs" : "Free","EbsAppointmentId" : "9898"}';  
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServicePSIEventAPIMock()); 
        ServicePSIEvent.postData();
        ServicePSIEvent.postData();
        Test.stopTest();
        
        ServicePSIEvent.Request contReq = (ServicePSIEvent.Request)JSON.deserialize(jsonStr,ServicePSIEvent.Request.class);
        req.requestBody = Blob.valueOf('Invalid JSON');
        ServicePSIEvent.postData();
        
    } 
    
    
    static  testmethod void testmethoddelete()
    {
        String recordId = createTestRecord();
       
        RestRequest request = new RestRequest();
        request.requestUri ='https://pelladev-pellacorp.cs28.force.com/services/apexrest/PSIEvent/'+recordId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        ServicePSIEvent.deleteEvent();
     }
    
    static  testmethod void testmethoddeleterecnotfound()
    {
        string recordId = '1111';
        RestRequest request = new RestRequest();
        request.requestUri ='https://pelladev-pellacorp.cs28.force.com/services/apexrest/PSIEvent/'+recordId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        ServicePSIEvent.deleteEvent();
     }
    
    
    
    static String createTestRecord() 
    {
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), true); 

        // Create test record
        Event evetnTest = new Event(Subject='Test record',Event_Type__c='Installation',Legacy_Event_ID__c = '9898',StartDateTime = System.today(),EndDateTime = System.today()+1 ,ShowAs='Free',WhatId = opp.Id );
        insert evetnTest;
        return evetnTest.Legacy_Event_Id__c;
    }
     static String createTestRecordPost() 
     {
        User usr = new User( ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                    LastName = 'Test', Email = 'test@test23232323.com', Username = 'test2344@test3434.com' + System.currentTimeMillis(),
                    CompanyName = 'TEST', Title = 'title', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US');
        insert usr ;
        
        // Create Account
        Account ac = TestUtil.createAccount('Person Account', true);
        
        // Create Opportunity
        Opportunity opp = TestUtil.createOpportunity('New Opp', ac.Id, UserInfo.getUserId(), true); 
        
        Quote q = TestUtil.createQuote(opp.Id, false);
        q.Quote_Number_PQM__c='8989' ;
        insert q ;

        return q.Quote_Number_PQM__c ;
    }
}