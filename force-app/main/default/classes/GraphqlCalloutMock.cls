@istest
global class GraphqlCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/json');
        res.setBody('{"data": {"example": {"test": "value"}}}');
        res.setStatusCode(200);
        return res;
    }
}