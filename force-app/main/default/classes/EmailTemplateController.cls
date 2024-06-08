public  class EmailTemplateController {
    public String leadId { get; set; }
    public Email__c email { get; set; }
    public String toAddresses { get; set; }
    public String subject { get; set; }
    public String htmlBody { get; set; }
    public String cc { get; set; }
    
    public EmailTemplateController() {
        email = new Email__c();
    }
    
    // Constructor to accept StandardController
    public EmailTemplateController(ApexPages.StandardController controller) {
        // Initialize the Lead Id from the StandardController
        leadId = controller.getId();
        email = new Email__c();
        
         Lead leadRecord = [SELECT Id, Email FROM Lead WHERE Id = :leadId LIMIT 1];
        	toAddresses = leadRecord.Email;
    }
    
    
    public PageReference sendEmail() {
        try {
            email.To__c = toAddresses;
            email.Subject__c = subject;
            email.Body__c = htmlBody;
            email.CC__c = cc;
            
            // Associate Lead Id with the Email record
            if (String.isNotBlank(leadId)) {
                email.Lead__c = leadId; 
            }
            
           
            
            // Insert the Email record
            insert email;
            system.debug('email'+ email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            List<String> ccList = new List<String>(); 
            if (String.isNotBlank(email.CC__c)){
                ccList.add(email.CC__c);
            }
            sendTo.add(email.To__c);
            mail.setToAddresses(sendTo);
            mail.setSubject(email.Subject__c);
            mail.setHtmlBody(email.Body__c);
            mail.setCcAddresses(ccList); 
            mail.setTargetObjectId(email.Lead__c);
            mail.setUseSignature(false);
            mail.setBccSender(false);
            mail.setSaveAsActivity(true);
            mail.setReplyTo('createactivity@2bn51q18qosrrg9cgs2yw8keexsmo6fsfjua6257u7mg5rlc61.1s-tlwea2.cs113.apex.sandbox.salesforce.com');
            //system.debug('setTargetObjectId'+ mail.setTargetObjectId(leadId));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            // Clear fields after sending email
            toAddresses = '';
            subject = '';
            htmlBody = '';
            cc = '';
            
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email sent successfully!'));
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
}