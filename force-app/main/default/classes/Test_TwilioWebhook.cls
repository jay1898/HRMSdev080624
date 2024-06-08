@isTest
private class Test_TwilioWebhook {
    // The testToNumber has to be real due to limitations with inserting new metadata types
    // Note: make sure to set the 'testTopic' to match the 'testToNumber'
    //private static String testToNumber = 'MG5a0b0754fef7b2da2dcbf6c79f5b7f16';
    private static String testClientNumber = '+18005551234';
    private static String testTwilioNumber = '+18005551235';
    private static String testMessageBody = 'Hello';
    private static String testMessageSid = 'SM8dcf6561e2758657ac91016fcf54ec9b';
    private static String testTopic = 'Ad_hoc';

   /*  @isTest
    static void testGoodRequest() {

        TwilioMessage__c message = new TwilioMessage__c();
        message.Direction__c = 'Outbound';
        message.Topic__c = testTopic;
        message.MessageBody__c = testMessageBody;
        message.Phone__c = testClientNumber;
        message.Status__c = 'Success';

        insert message;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        // Set-up the POST body to match what the Twilio Function will send
        Map<String, String> body = new Map<String, String>();
        body.put('To', testTwilioNumber);
        body.put('From', testClientNumber);
        body.put('Body', testMessageBody);

        request.requestURI = '/TwilioSmsWebhook/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(body));

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        TwilioWebhook.handlePost();
        Test.stopTest();

        System.assertEquals(TwilioHttpStatus.OK, response.statusCode, 'Expected 200 OK response, but got: ' + response.statusCode);
    } */

    @isTest
    static void testMissingParameter() {
        String testToNumber = [SELECT Phone__c FROM TwilioSetup__mdt LIMIT 1].Phone__c;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        // Set-up the POST body to match what the Twilio Function will send
        Map<String, String> body = new Map<String, String>();
        body.put('To', testClientNumber);
        body.put('From', testTwilioNumber);
        //body.put('Body', testMessageBody);

        request.requestURI = '/TwilioSmsWebhook/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(body));

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        TwilioWebhook.handlePost();
        Test.stopTest();

        System.assertEquals(TwilioHttpStatus.BAD_REQUEST, response.statusCode, 'Expected 400 BAD REQUEST response, but got: ' + response.statusCode);
    }

    @isTest
    static void testMessageError() {
        String testToNumber = [SELECT Phone__c FROM TwilioSetup__mdt LIMIT 1].Phone__c;
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        // Set-up the POST body to match what the Twilio Function will send
        Map<String, String> body = new Map<String, String>();
        body.put('To', testClientNumber);
        body.put('From', testTwilioNumber);
        body.put('Body', testMessageBody);

        request.requestURI = '/TwilioSmsWebhook/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(body));

        RestContext.request = request;
        RestContext.response = response;

        // Since we haven't sent a message to the number, we can't pull a parent ID for the message

        Test.startTest();
        TwilioWebhook.handlePost();
        Test.stopTest();

        System.assertEquals(TwilioHttpStatus.INTERNAL_SERVER_ERROR, response.statusCode, 'Expected 500 SERVER ERROR response, but got: ' + response.statusCode);
    }
}