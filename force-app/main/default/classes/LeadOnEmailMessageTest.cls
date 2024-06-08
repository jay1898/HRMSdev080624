@isTest
public class LeadOnEmailMessageTest {
    @isTest
    static void testTrigger() {
        // Trigger should update Lead records based on EmailMessage data
        Lead lead = new Lead(LastName = 'Test Leadm' ,Email = 'abc@gmail.com', Company = 'abc');
        insert lead;
        
        // Create test data: EmailMessage and Task records
        Task task = new Task(Status = 'Email Response', Description = 'Email Response by Lead Owner', subject = 'task' , Priority = 'Medium', ActivityDate = System.today(), ReminderDateTime = System.now(), WhoId = lead.id);
        insert task;
        
       /* EmailMessage email = new EmailMessage(
            Subject = 'Test Email',
            MessageDate = Date.today()
            
        );
        insert email;
        */
        Test.startTest();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add('abc@gmail.com');        
        mail.setToAddresses(sendTo);
        mail.setSubject('test');
        mail.setHtmlBody('test');
        mail.setTargetObjectId(lead.Id);
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setSaveAsActivity(true);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
        
        
        // Perform DML operation that fires the trigger
    
        Test.stopTest();
        
        // Retrieve the updated Lead record
        //Lead updatedLead = [SELECT Id, Last_sent_date_time__c, Last_opened_date_time__c FROM Lead WHERE Id = :lead.Id];
        
        // Assert that the Lead record was updated as expected
        // System.assertEquals(Date.today(), updatedLead.Last_sent_date_time__c, 'Last_sent_date_time__c should be updated');
        //System.assertEquals(Date.today(), updatedLead.Last_opened_date_time__c, 'Last_opened_date_time__c should be updated');
    }
}