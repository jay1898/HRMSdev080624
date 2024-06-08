@isTest
private class EmailServiceHandlerTest {

    @isTest
    static void testEmailServiceHandler() {
        // Create a test inbound email
        Messaging.InboundEmail testEmail = new Messaging.InboundEmail();
        testEmail.fromAddress = 'test@example.com';
        testEmail.subject = 'Test Subject';
        testEmail.plainTextBody = 'Test Body';

        // Create a test candidate
        Candidate__c testCandidate = new Candidate__c(Email__c = 'test@example.com');
        insert testCandidate;

        // Instantiate the EmailServiceHandler class
        EmailServiceHandler handler = new EmailServiceHandler();

        // Call the handleInboundEmail method
        Messaging.InboundEnvelope testEnvelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(testEmail, testEnvelope);

        // Verify the result
        System.assertEquals(true, result.success, 'Result success should be true');
    }
}