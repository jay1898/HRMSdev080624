public class MockCustomerAddressHTTPResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setBody('{"data":{"getStreetAddressesForPersonById":[{"id":"05785abe-833c-4051-8744-dd4192c8acbf","associationType":"PRIMARY","streets":["10984 West Rd.","90 North"],"city":"Selden","state":"KS","postalCode":"67757","country":"US","isIdentifying":false,"isPrimary":false,"branch":null}]}}');
        return response;
    }
}