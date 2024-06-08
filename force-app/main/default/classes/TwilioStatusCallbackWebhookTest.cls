@isTest
private class TwilioStatusCallbackWebhookTest {
    // The testToNumber has to be real due to limitations with inserting new metadata types
    // Note: make sure to set the 'testTopic' to match the 'testToNumber'
    //private static String testToNumber = 'MG5a0b0754fef7b2da2dcbf6c79f5b7f16';
    private static String testClientNumber = '+18005551234';
    private static String testTwilioNumber = '+18005551235';
    private static String testMessageBody = 'Hello';
    private static String testMessageSid = 'SM8dcf6561e2758657ac91016fcf54ec9b';
    private static String testTopic = 'Ad_hoc';

  
    @isTest
    static void testMissingParameter() {
        User usr = TestUtil.createUser(true);     	
        // Create Branch Family
        Branch_Grouping__c bf = TestUtil.createBranchGrouping('BranchGrouping', true);        
        // Create Branch
        Branch__c branch = TestUtil.createBranch('Test', '100', bf.Id, true);        
        Account ac = TestUtil.createAccount('Person Account', true);             
        Opportunity opp = TestUtil.createOpportunity('Test', ac.Id, usr.Id, false);
        
        
        
        TwilioMessage__c smsRecord = new TwilioMessage__c();
        smsRecord.Opportunity__c = opp.Id;
        smsRecord.Direction__c = 'Outbound';
        smsRecord.MessageBody__c = 'Test Record';
        smsRecord.Status__c = 'Success';
        smsRecord.Name = 'Test Record';
        smsRecord.Branch__c =branch.Id; 
        smsRecord.MessageSid__c='test';
        insert smsRecord;      
        
        String testToNumber = [SELECT Phone__c FROM TwilioSetup__mdt LIMIT 1].Phone__c;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        // Set-up the POST body to match what the Twilio Function will send
        Map<String, String> body = new Map<String, String>();
        body.put('To', testClientNumber);
        body.put('From', testTwilioNumber);
        body.put('SmsSid', 'test');
        //body.put('Body', testMessageBody);

        request.requestURI = '/TwilioStatusCallbackWebhook/';
        request.httpMethod = 'POST';
        request.addParameter('SmsSid','test');
        request.requestBody = Blob.valueOf(JSON.serialize(body));

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        TwilioStatusCallbackWebhook.handlePost();
        Test.stopTest();

    }

}