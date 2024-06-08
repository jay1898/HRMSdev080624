@isTest
private class GenerateApprovalProcessTest {
     @isTest static void testCreateApprovalProcess() {
        // Set up the mock callout class
        Test.setMock(System.WebServiceMock.class, new MockMetadataPort());

        Test.startTest();
        // Call the method to test
        GenerateApprovalProcess.createApprovalProcess();
        Test.stopTest();

        // Add necessary assertions based on your requirements
    }

    
    
    @isTest static void testHandleSaveResults() {
        MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
        saveResult.success = true;
        GenerateApprovalProcess.handleSaveResults(saveResult);
        
        // Testing error handling
        saveResult = new MetadataService.SaveResult();
        saveResult.success = false;
        saveResult.errors = new List<MetadataService.Error>();
        MetadataService.Error error = new MetadataService.Error();
        error.message = 'Test Error';
        error.statusCode = 'UNKNOWN_EXCEPTION';
        saveResult.errors.add(error);
        
        Boolean exceptionThrown = false;
        try {
            GenerateApprovalProcess.handleSaveResults(saveResult);
        } catch (GenerateApprovalProcess.MetadataServiceExamplesException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Exception was not thrown as expected');
    }

  
private class MockMetadataPort implements WebServiceMock {
    public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) {
        // Create a mock response
        MetadataService.createMetadataResponse_element mockResponse = 
            new MetadataService.createMetadataResponse_element();

        // Assuming a no-argument constructor exists
        MetadataService.SaveResult mockSaveResult = new MetadataService.SaveResult();
        // Set properties if there are setters available
        mockSaveResult.success = true;
        // Add other necessary property settings

        mockResponse.result = new MetadataService.SaveResult[] { mockSaveResult };
        response.put('response_x', mockResponse);
    }
}
}