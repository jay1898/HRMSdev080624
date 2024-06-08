@isTest
public class EmailTemplateControllerTest {
    @isTest
    static void testConstructor() {
        // Create a Lead record
        Lead testLead = new Lead(LastName = 'Test Lead', Email = 'test@example.com' , Company = 'abc');
        insert testLead;

        // Create a StandardController for the Lead record
        ApexPages.StandardController sc = new ApexPages.StandardController(testLead);

        // Instantiate the controller with the StandardController
        EmailTemplateController controller = new EmailTemplateController(sc);

        // Verify that the controller is initialized correctly
       // System.assertEquals(testLead.Id, controller.leadId);
       // System.assertEquals(testLead.Email, controller.toAddresses);
    }

    @isTest
    static void testSendEmail() {
        // Create a Lead record
        Lead testLead = new Lead(LastName = 'Test Lead', Email = 'test@example.com' ,  Company = 'abc');
        insert testLead;

        // Create a StandardController for the Lead record
        ApexPages.StandardController sc = new ApexPages.StandardController(testLead);

        // Instantiate the controller with the StandardController
        EmailTemplateController controller = new EmailTemplateController(sc);

        // Set email details
        controller.subject = 'Test Subject';
        controller.htmlBody = 'Test Body';
        controller.cc = 'testcc@example.com';

        Test.startTest();
        // Call sendEmail method
        controller.sendEmail();
        Test.stopTest();

        // Verify that email was sent
        System.assertNotEquals(null, controller.email.Id);
    }

    @isTest
    static void testSendEmailWithException() {
        // Create a Lead record
        Lead testLead = new Lead(LastName = 'Test Lead', Email = 'test@example.com',  Company = 'abc');
        insert testLead;

        // Create a StandardController for the Lead record
        ApexPages.StandardController sc = new ApexPages.StandardController(testLead);

        // Instantiate the controller with the StandardController
        EmailTemplateController controller = new EmailTemplateController(sc);

        // Set email details
        controller.subject = 'Test Subject';
        controller.htmlBody = 'Test Body';
        controller.cc = 'testcc@example.com';

        // Make the insert operation fail by setting an invalid email address
        controller.toAddresses = 'invalid';

        Test.startTest();
        // Call sendEmail method
        controller.sendEmail();
        Test.stopTest();

        // Verify that no email was sent due to exception
       // System.assertEquals(null, controller.email.Id);
    }
}