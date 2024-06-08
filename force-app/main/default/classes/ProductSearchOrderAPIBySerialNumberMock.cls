global class ProductSearchOrderAPIBySerialNumberMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"B4aFQ3KWQ","scope":"purchased_products_read"},"data":{"getPurchasedProductsBySerialNumber":{"results":[],"pageInfo":{"currentPage":0,"totalPages":0,"totalRecords":0,"nextPage":null,"limit":10,"offset":0}}}');
        res.setStatusCode(200);
        return res;
    }
}