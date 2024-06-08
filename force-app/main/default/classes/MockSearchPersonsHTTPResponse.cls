public class MockSearchPersonsHTTPResponse implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setBody('{"data":{"searchPersons":{"results":[{"id":"c4850240-476b-4ac1-97ac-405b00ff7d8d","displayName":"Sagar Sagar","phoneNumber":null,"email":"sagar.amin+73@trility.io","street":"10984 West Rd. 90 North","city":"Selden","state":"KS","postalCode":"67757"},{"id":"1ffc72e7-5c1c-4f4c-aaed-28efad1a5d42","displayName":"Matt Strauss","phoneNumber":null,"email":null,"street":"10984 West Rd. 90 North","city":"Selden","state":"KS","postalCode":"67757"},{"id":"e65d3cff-1e7e-438d-92c7-504855d41a0b","displayName":"Jason Rall","phoneNumber":"303-557-8291","email":"jrrall@gmail.com","street":"10984 West Rd. 90 North","city":"Selden","state":"KS","postalCode":"67757"},{"id":"f5876cdd-0870-4781-8ad5-b48159c4e7fd","displayName":"Wava Cartwright","phoneNumber":"363-623-9921","email":"Jayda12@yahoo.com","street":"30884 Garnett Burgs","city":"Selden","state":"KS","postalCode":"67757"},{"id":"f5876cdd-0870-4781-8ad5-b48159c4e7fd","displayName":"Wava Cartwright","phoneNumber":"363-623-9921","email":"Jayda12@yahoo.com","street":"30884 Garnett Burgs","city":"Selden","state":"KS","postalCode":"67757"}],"pageInfo":{"currentPage":1,"totalPages":1,"nextPage":null,"totalRecords":5,"limit":10,"offset":0}}}}}');
        return response;
    }
}