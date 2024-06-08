@isTest
private class Test_TwilioMessenger {
    static Id testId = Id.valueOf('a468C000000Goz4QAC');
    static String testPhone = '+15551234567';

    @isTest
    /**
     * Tests for TwilioMessenger.formatPhoneE164()
     * Phone numbers not between 10-11 numbers will throw an exception
     */ 
    static void testFormatting() {
        Test.startTest();
        List<String> numbersToFormat = new List<String>();
        numbersToFormat.add('(555) 123-4567');
        numbersToFormat.add('+1 555-123-4567');
        List<String> formattedNumbers = TwilioMessenger.formatPhoneE164(numbersToFormat);
        String format1 = formattedNumbers.get(0);
        String format2 = formattedNumbers.get(1);
        System.assertEquals(format1, testPhone, 'Phone number reformatted incorrectly');
        System.assertEquals(format2, testPhone, 'Phone number reformatted incorrectly');
        Test.stopTest();
    }

    @isTest
    static void testBadFormatting() {
        List<String> failingNumbers = new List<String>();
        failingNumbers.add('1234');
        try {
            List<String> failingFormatted = TwilioMessenger.formatPhoneE164(failingNumbers);
        } catch(IllegalArgumentException e) {
            return;   
        }
        System.assert(false, 'IllegalArgumentException not thrown when bad data provided');
    }
    @isTest
    /**
     * Test for TwilioMessenger.sendSms() where the phone number is formatted correctly
     */
    static void sendSmsGoodNumber() {

        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout());

        Branch__c testBranch = new Branch__c();
        testBranch.Name = 'testBranch';
        testBranch.Branch_Number__c = '002';
        insert testBranch;

        TwilioMessenger.SendSmsParams smsParams = new TwilioMessenger.SendSmsParams();
        smsParams.message = 'Message Body';
        smsParams.recordId = testId;
        smsParams.topic = 'Other';
        smsParams.toNum = testPhone;
        smsParams.branchId = testBranch.Id;

        try {
            Test.startTest();
            TwilioMessenger.sendSms(smsParams);
            Test.stopTest();
        } catch (Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            System.assert(false, 'Correctly formed message did not get the correct API response');
        }
    }

    /**
     * Test for TwilioMessenger.sendNonFutureSms() where the phone number is formatted correctly
     */
    @isTest
    static void sendNonFutureSms() {

        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout());

        Branch__c testBranch = new Branch__c();
        testBranch.Name = 'testBranch';
        testBranch.Branch_Number__c = '002';
        insert testBranch;

        TwilioMessenger.SendSmsParams smsParams = new TwilioMessenger.SendSmsParams();
        smsParams.message = 'Message Body';
        smsParams.recordId = testId;
        smsParams.topic = 'Other';
        smsParams.toNum = testPhone;
        smsParams.branchId = testBranch.Id;

        try {
            Test.startTest();
            TwilioMessenger.sendNonFutureSms(smsParams);
            Test.stopTest();
        } catch (Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            System.assert(false, 'Correctly formed message did not get the correct API response');
        }
    }

    @isTest
    static void smsTestBadNumber() {
        Branch__c testBranch = new Branch__c();
        testBranch.Name = 'testBranch';
        testBranch.Branch_Number__c = '002';
        insert testBranch;

        TwilioMessenger.SendSmsParams smsParams = new TwilioMessenger.SendSmsParams();
        smsParams.message = 'Message Body';
        smsParams.recordId = testId;
        smsParams.topic = 'Other';
        smsParams.toNum = 'BAD_NUMBER';
        smsParams.branchId = testBranch.Id;

        try {
            Test.startTest();
            TwilioMessenger.sendSms(smsParams);
            Test.stopTest();
            System.assert(false, 'Non-E-164 format should raise exception');
        }
        catch (Exception error) {
            System.assert(error.getMessage() != '', 'Error message was empty');
        }

    }

    @isTest(SeeAllData=true)
    /**
     * Tests for TwilioMessenger.sendLightningMessage()
     * These tests are not working as sendLightningMessage is @future - will probably delete
     */
    static void lightningMessageTest() {
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout());

        User user = [SELECT Id from User where Trade_Branch_Number__c != NULL Limit 1];

        if (user == null) {
            System.assert(false, 'No Object in the Database with a Branch Id to test with');
        }

        try {
            Test.startTest();
            TwilioMessenger.sendLightningMessage(testPhone, 'Message Body', 'Other', String.valueOf(user.Id));
            Test.stopTest();
        } catch (Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            System.assert(false, 'Correctly formed message did not get the correct API response');
        }

    }

    /**
     * Test for TwilioMessenger.sendFormattedSms()
     * Apex code coverage is incorrectly calculated as function calls within top-level functions
     * are not followed
     */
    @isTest
    static void testSendFormattedSms() {
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout());

        Branch__c testBranch = new Branch__c();
        testBranch.Name = 'testBranch';
        testBranch.Branch_Number__c = '002';
        insert testBranch;

        TwilioMessenger.SendFormattedSmsParams params = new TwilioMessenger.SendFormattedSmsParams();
        params.formattedNum = testPhone;
        params.fromId = testPhone;
        params.topic = 'Other';
        params.recordId = testId;
        params.message = 'message body';
        params.branchId = testBranch.Id;

        try {
            Test.startTest();
            // Using testPhone for 'from' and 'to' as that is valid within the code
            TwilioMessenger.sendFormattedSms(JSON.serialize(params));
            Test.stopTest();
        } catch (Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            System.assert(false, 'Correctly formed message did not get the correct API response');
        }

    }

    /**
     * Tests for TwilioMessenger.createMessage()
     * createMessage() doesn't return anything so we validate the message was inserted using 
     * the queryMessages() function, and validate that the parent ID was stored in the message
     */
    @isTest(seeAllData=true)
    static void testCreateMessage() {
        Branch__c testBranch = new Branch__c();
        testBranch.Name = 'testBranch';
        testBranch.Branch_Number__c = '002';
        insert testBranch;

        ServiceAppointment appt = [SELECT Id from ServiceAppointment LIMIT 1];

        TwilioMessenger.CreateMessageParams createParams = new TwilioMessenger.CreateMessageParams();
        createParams.direction = 'Outbound';
        createParams.branchId = testBranch.Id;
        createParams.msgBody = 'Message Text';
        createParams.phone = testPhone;
        createParams.recordId = appt.Id;
        createParams.topic = 'Survey';
        createParams.status = 'Success';

        try {
            TwilioMessenger.createMessage(createParams);
        } catch (Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            System.assert(false, 'Message with ServiceAppointment was not successfully inserted');
        }

        Opportunity opp = [SELECT Id from Opportunity LIMIT 1];
        createParams.recordId = opp.Id;

        try {
            TwilioMessenger.createMessage(createParams);
        } catch (Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            System.assert(false, 'Message with Opportunity was not successfully inserted');
        }

        List<TwilioMessage__c> messages = TwilioMessenger.queryMessages(testPhone, 'Survey', String.valueOf(appt.Id));
        System.assert(messages.size() >= 1, 'Messages were not added using insert');

        messages = TwilioMessenger.queryMessages(testPhone, 'Survey', String.valueOf(opp.Id));
        System.assert(messages.size() >= 1, 'Messages were not added using insert');

        Id parentId = TwilioMessenger.getLastOutboundMessage(testPhone, 'Survey').ParentID__c;
        System.assertEquals(parentId, String.valueOf(opp.Id), 'latest parentId was not correct');
    }
    
    @isTest
    /**
     * Tests for TwilioMessenger.getTopicFromSender() and TwilioMessenger.getSenderFromTopic()
     * Note: we can't insert a new record for the TwilioSetup__mdt, so we will attempt to pull one that exists
     * if this fails, ensure that there is at least one pre-populated value in TwilioSetup__mdt
     */
    static void testTwilioSetup(){
        TwilioSetup__mdt firstSetupValue = [SELECT Phone__c, QualifiedAPIName FROM TwilioSetup__mdt LIMIT 1][0];

        Test.startTest();
        String qualifiedApiName = TwilioMessenger.getTopicFromSender(firstSetupValue.Phone__c);
        String senderPhone = TwilioMessenger.getSenderFromTopic(firstSetupValue.QualifiedAPIName);
        Test.stopTest();

        System.assertEquals(qualifiedApiName, firstSetupValue.QualifiedAPIName, 'Issue getting topic from phone');
        System.assertEquals(senderPhone, firstSetupValue.Phone__c, 'Issue getting phone from topic');
    }
    
    @isTest
    /**
     * Tests the getLastOutboundMessage method
     */
    static void testGetLastOutboundMessage() {
        String testNumber = '+18005551234';
        TwilioMessage__c msg = new TwilioMessage__c();
        msg.Phone__c = testNumber;
        msg.Topic__c = 'Ad_hoc';
        msg.Direction__c = 'Outbound';
        msg.MessageBody__c = 'Message Body';
        insert msg;

        TwilioMessage__c lastMessage = TwilioMessenger.getLastOutboundMessage(testNumber, 'Ad_hoc');
        System.assert(lastMessage != null, 'No Message Found after Insert');
    }

    @isTest(SeeAllData=true)
    /**
     * Tests the queryMessages method
     */
    static void testQueryMessages() {
        User user = [Select Id from user LIMIT 1];
        String testNumber = '+18005551234';
        TwilioMessage__c msg = new TwilioMessage__c();
        msg.Phone__c = testNumber;
        msg.Topic__c = 'Ad_hoc';
        msg.Direction__c = 'Outbound';
        msg.MessageBody__c = 'Message Body';
        msg.ParentID__c = user.Id;
        insert msg;

        List<TwilioMessage__c> msgs = TwilioMessenger.queryMessages(testNumber, 'Ad_hoc', user.Id);

        System.assert(msgs.size() > 0, 'No Messages Found directly after insert');
    }

    @isTest
    static void testGetSenderFromTopicNotFound() {
        try {
            String str = TwilioMessenger.getSenderFromTopic('No Topic');
        } catch(Exception e) {
            return;
        }
        System.assert(false, 'Proper Error Not Thrown');
    }

    @isTest
    static void testGetTopicFromSenderNotFound() {
        try {
            String str = TwilioMessenger.getTopicFromSender('No Sender');
        } catch(Exception e) {
            return;
        }
        System.assert(false, 'Proper Error Not Thrown');
    }
}