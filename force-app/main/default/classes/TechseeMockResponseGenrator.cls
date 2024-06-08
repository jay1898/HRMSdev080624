global class TechseeMockResponseGenrator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"accountId":"5fd8761b03c5ea2e8afa1caa","ottExpiration":480,"token":"hdxfvphsvy"}');
        res.setStatusCode(200);
        return res;
    }
}