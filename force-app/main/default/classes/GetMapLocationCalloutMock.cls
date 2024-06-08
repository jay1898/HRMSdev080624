/*
Created By: Sachin Padhiyar
Created Date: 
Purpose: TestEDWDataservice to cover all the test cases for EDWDataservice class.
----------------------------------------------------------------------------------------------
Modified By:
Modified Date.: 
Purpose: 
-----------------------------------------------------------------------------------------------
*/


@isTest
global class GetMapLocationCalloutMock implements HttpCalloutMock{
	// Implement this interface method
    global static HttpResponse respond(HTTPRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"location" : {"lat" : 37.3708778,"lng" : -121.8543263}}');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
       
    }
}