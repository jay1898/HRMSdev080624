@isTest
global class OktaOAuthCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/json');
        res.setBody('{"access_token": "7cb499cfe4602e87cc6fec9a5c6fdaf6ad018150", "expires_in": "60000", "token_type": "bearer", "scope": "some_scope"}');
        res.setStatusCode(200);
        return res;
    }
}