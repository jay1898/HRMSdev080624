public class MultiRequestCalloutMock implements HttpCalloutMock {   
    Map<String, HttpCalloutMock> calloutMockMap;

    public MultiRequestCalloutMock(Map<String, HttpCalloutMock> calloutMockMap) {
        this.calloutMockMap = calloutMockMap;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = calloutMockMap.get(req.getEndpoint());

        return mock.respond(req);
    }
}