@isTest
global class ServicePSIEventAPIMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{ "statuscode": 200,  "Message" : "Success"}]');
        response.setStatusCode(200);
        return response; 
    }
}