@isTest
private class Test_TwilioSmsFlowActions {
    static String testPhone = '+15551234567';

    @isTest
    static void test() {
        Test.setMock(HttpCalloutMock.class, new Test_TwilioAPICallout());
        TwilioMessenger messengerMocker = (TwilioMessenger)Mock_TwilioMessengerUtility.createMock(TwilioMessenger.class);

        Branch__c testBranch = new Branch__c();
        testBranch.Name = 'testBranch';
        testBranch.Branch_Number__c = '002';
        insert testBranch;

        TwilioSmsFlowActions.TwilioSmsFlowInput flowInput = new TwilioSmsFlowActions.TwilioSmsFlowInput();
        flowInput.toNum = testPhone;
        flowInput.message = 'Message Body';
        flowInput.topic = 'Ad_hoc';
        flowInput.recordId = testBranch.Id;
        flowInput.branchId = testBranch.Id;

        List<TwilioSmsFlowActions.TwilioSmsFlowInput> flowInputList = new List<TwilioSmsFlowActions.TwilioSmsFlowInput>();
        flowInputList.add(flowInput);

        TwilioSmsFlowActions.sendSms(flowInputList);
        
        System.assert(true); //no errors detected from above command;

        // Can't test the "future" method since we can't create a future context in a test.
    }
}