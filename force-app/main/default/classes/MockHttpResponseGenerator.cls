@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://apidev.pella.com/order-enquiry/v1/oms-orders', req.getEndpoint());
        String Body = '[{"OrderNumber":"72120TELEA","OrderStatus":"6","BranchNumber":"079","LineNumber":"010","PoLineNumber":"0","Description":"ADDPRRMCOR020001 - Delivery & Disposal","InvoicedStatus":"X","ReceivedStatus":"N","DeliveredStatus":"","DeliveryDate":"11-NOV-20","LineCreationDate":"16-NOV-20","DeliveryCreationDate":"16-NOV-20","StopAddress1":"5807 Parkview Point Dr","StopAddress2":"","StopCity":"Orlando","StopState":"FL","StopPostalCode":"32821","ProjectAddress1":"5807 Parkview Point Dr","ProjectAddress2":"","ProjectCity":"Orlando","ProjectState":"FL","ProjectPostalCode":"32821","AppointmentStartDate":"","AppointmentEndDate":"","QuoteQuantity":1,"POQuantity":null,"BookedDate":"28-AUG-20","NeedDate":"05-OCT-20","PurchaseDate":"","ReceiptDate":"","ShipDate":"","LastRevisionDate":"","RollupUnitPrice":258.32,"DiscountPct":0,"ListPrice":null,"DACost":null,"RecdStatusLineCount":0}]';
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(Body);
        res.setStatusCode(201);
        return res;
    }
}