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
global class MapLocationCalloutMock implements HttpCalloutMock{
	// Implement this interface method
    global static HttpResponse respond(HTTPRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/json');
        res.setBody('{"message": "OK"}');
        res.setStatusCode(200);
        res.setStatus('success');
        system.debug('res==>'+res);
        return res;
       
    }
}