@istest
global class GraphqlCalloutErrorMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/json');
        res.setBody('{"errors": [{"message": "example", "extensions": {"type": "invalidTypeVariable", "name": "input"}}]}');
        res.setStatusCode(200);
        return res;
    }
}