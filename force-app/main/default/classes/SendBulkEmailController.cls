public class SendBulkEmailController {
    public List<LeadWrapper> leadWrappers { get; set; }
    public String emailSubject { get; set; }
    public String emailBody { get; set; }
     public Boolean isEmailSent { get; set; }
    
    public SendBulkEmailController() {
        leadWrappers = new List<LeadWrapper>();
        // Populate leadWrappers with Lead records
        List<Lead> leads = [SELECT Id, Name, Email FROM Lead where Do_Not_Mail__c = false and Email != null  order by CreatedDate Desc LIMIT 5000 ]; // Limiting to 10 leads for demonstration
        for (Lead lead : leads) { 
            leadWrappers.add(new LeadWrapper(lead));
        }
    }
    
   public void sendEmails() {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
	 Boolean hasSelectedLeads = false;
    // Loop through selected leads and send email to each
    for(LeadWrapper leadWrapper : leadWrappers) {
        if (leadWrapper.isSelected) {
			hasSelectedLeads = true;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { leadWrapper.lead.Email });
            email.setSubject(emailSubject);
            email.setPlainTextBody(emailBody);
            // Set the target object ID to the Lead ID
            email.setTargetObjectId(leadWrapper.lead.Id);
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setSaveAsActivity(true);
            email.setReplyTo('createactivity@2bn51q18qosrrg9cgs2yw8keexsmo6fsfjua6257u7mg5rlc61.1s-tlwea2.cs113.apex.sandbox.salesforce.com');
			  emails.add(email);
             if (hasSelectedLeads) {
            Messaging.sendEmail(emails);
            isEmailSent = true; // Set the property to true after emails are sent
 clearFields();
        }
             
        }
    }
       
  
     

    // Send emails
   // Messaging.sendEmail(emails);
}
 private void clearFields() {
        emailSubject = '';
        emailBody = '';
        for (LeadWrapper leadWrapper : leadWrappers) {
            leadWrapper.isSelected = false;
        }
    }
    
    // Method to select all leads
    public void selectAll() {
        for(LeadWrapper leadWrapper : leadWrappers) {
            leadWrapper.isSelected = true;
        }
    }
    
    // Method to deselect all leads
    public void deselectAll() {
        for(LeadWrapper leadWrapper : leadWrappers) {
            leadWrapper.isSelected = false;
        }
    }
    
    // Wrapper class to handle checkbox selection
    public class LeadWrapper {
        public Lead lead { get; set; }
        public Boolean isSelected { get; set; }
        
        public LeadWrapper(Lead l) {
            lead = l;
            isSelected = false;
        }
    }
}