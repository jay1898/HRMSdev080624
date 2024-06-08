global class CXOneOAuthCtrlMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"1234","sessionId":"123","events":[{"type":"CallContactEvent", "skill" : "test"}]}');
        res.setStatusCode(200);
        return res;
    }
}