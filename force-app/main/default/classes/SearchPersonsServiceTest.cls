@isTest
private class SearchPersonsServiceTest {

    /*test method for generation of request Body*/
    static testmethod void testGenerateSearchPersonsRequestBody() {
        Graphql_Configuration_Customer_Service__mdt config = [
            SELECT GraphQL_Query__c
            FROM Graphql_Configuration_Customer_Service__mdt
            WHERE DeveloperName = 'Search_Persons'
            LIMIT 1
        ];
        String requestBody;
        Map<String, Object> filters = new Map<String, Object>{ 'name' => 'John Doe' };
        test.startTest();
        requestBody = SearchPersonsService.generateSearchPersonsRequestBody(filters, 10, 0);
        test.stopTest();
        System.assertNotEquals(null, requestBody, 'The request body should not be null');
        System.assert(requestBody.contains('John Doe'), 'The request body should contain the filter value');
        
    }
   /*test method for response from graph*/
    static testmethod void testGenerateSearchPersonsResponse() {
        Graphql_Configuration_Customer_Service__mdt graphConfigMetadata = [
        SELECT GraphQL_Query__c, Endpoint_URL__c
        FROM Graphql_Configuration_Customer_Service__mdt
        WHERE DeveloperName = 'Search_Persons'
        LIMIT 1];
        Map<String, HttpCalloutMock> calloutMockMap = new Map<String, HttpCalloutMock> {
            graphConfigMetadata.Endpoint_URL__c => new MockSearchPersonsHTTPResponse(), 
            'callout:Okta_Auth' => new OktaOAuthCalloutMock()
        };
        Test.setMock(HttpCalloutMock.class, new MultiRequestCalloutMock(calloutMockMap));
        String response;
        Map<String, Object> filters = new Map<String, Object>{ 'name' => 'John Doe' };
        test.startTest();    
        response = SearchPersonsService.generateSearchPersonsResponse(filters, 10, 0);
        system.debug('the response is '+response);
		test.stopTest();
        System.assertNotEquals(null, response, 'The response should not be null');
        
    }
   /*test method for mapping values to VoiceAnswerScreenResponse*/
    static testmethod void testGetCustomerDetails() {
        Test.setMock(HttpCalloutMock.class, new MockSearchPersonsHTTPResponse());
        List<VoiceAnswerScreenResponse.CustDetails> details;
        Map<String, Object> filters = new Map<String, Object>{ 'name' => 'John Doe' };
        test.startTest();    
        details = SearchPersonsService.getCustomerDetails(filters, 10, 0);
        system.debug('the details is '+details);
		test.stopTest();
        System.assertNotEquals(null, details, 'Details list should not be null');
        System.assert(details.size() > 0, 'Details list should not be empty');
        
    }


    /*test method for customer address service from GraphQL*/
    static testmethod void shouldReturnAddressForGivenCustomerId() {
        Graphql_Configuration_Customer_Service__mdt config = [
            SELECT Endpoint_URL__c
            FROM Graphql_Configuration_Customer_Service__mdt
            WHERE DeveloperName = 'Get_Customer_Address'
            LIMIT 1
        ];
        String customerId = 'a1434-4765';
        Map<String, HttpCalloutMock> calloutMockMap = new Map<String, HttpCalloutMock> {
            config.Endpoint_URL__c => new MockCustomerAddressHTTPResponse(), 
            'callout:Okta_Auth' => new OktaOAuthCalloutMock()
        };
        Test.setMock(HttpCalloutMock.class, new MultiRequestCalloutMock(calloutMockMap));
        test.startTest();
        List<GraphQLAddressResponse.getStreetAddressesForPersonById> addressResponse = SearchPersonsService.generateCustomerAddressResponse(customerId);
        test.stopTest();
        System.assert(addressResponse.size() > 0, 'Address should not be empty');
        
    }
}