@isTest
private class ContentVersionTriggerTest {
    @isTest
    static void testContentVersionTrigger() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        System.debug('uaserId@@@@@'+u.Id);
        
        System.runAs(u){
        // Create a test Case record
        Case testCase = new Case(
            Subject = 'Test Case'
        );
        insert testCase;
System.debug('testcasew@@@@@'+testCase.Id);
        // Create a test EmailMessage record
        EmailMessage testEmailMessage = new EmailMessage(
            ToAddress = 'test@example.com',
            TextBody = 'This is a test email (Undelivered)',
            Subject = 'Test Email',
            ParentId = testCase.Id
        );
        insert testEmailMessage;

        // Create a test ContentVersion record for a bounced email
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Bounced Email Content',
            PathOnClient = 'bounced_email.txt',
            VersionData = Blob.valueOf('X-SFDC-User: 0056T000008zPAq X-SFDC-EntityId: '+String.valueOf(testCase.Id).substring(0, 15)+' Email: user@example.com (Undelivered)'),
            FirstPublishLocationId = testEmailMessage.Id,
            Type__c = 'ANSWER'
        );
        insert testContentVersion;
		
         Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId;
 
//Create ContentDocumentLink 
ContentDocumentLink cdl = New ContentDocumentLink();
cdl.LinkedEntityId = testCase.Id;
cdl.ContentDocumentId = conDocId;
cdl.shareType = 'V';
Insert cdl;   
        Test.startTest();

        // Add assertions to verify that email notifications were created and sent
        List<EmailMessage> sentEmails = [SELECT Id, Subject FROM EmailMessage];
        System.assertEquals(1, sentEmails.size(), 'Email notifications not sent.');

        // Add assertions to verify the content of the email notifications
        EmailMessage sentEmail = sentEmails[0];
        //System.assertEquals('Salesforce Bounced Email Notification for Case ' + testCase.CaseNumber, sentEmail.Subject, 'Email subject is incorrect.');
        // Add more assertions to verify the email body, recipient, or other relevant data as needed.

        // Add assertions for OrgWideEmailAddress and other related data if necessary

        Test.stopTest();
    }
    }
}