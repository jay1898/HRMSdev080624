global class EmailServiceHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        System.debug('Email Body: ' + email);
        System.debug('From Address: ' + email.fromAddress);
        System.debug('Subject: ' + email.subject);
        System.debug('plainTextBody: ' + email.plainTextBody);
        
        String fromAddress = email.fromAddress;
        String emailBody = email.plainTextBody;
        String emailSubject = email.subject;
        
        List<Candidate__c> candidates = [Select id, Email__c from Candidate__c where Email__c = :fromAddress limit 1];
        System.debug('List of Candidates : ' + candidates);
        
        if(candidates == null){
            result.success = true;
        	return result;
		}

        Candidate__c candidate = candidates[0];
        System.debug('Searched Candidate: ' + candidate);
        
        //Create new task and attach email body into it
        Task toAttachTask = new Task();
        toAttachTask.WhatId = candidate.Id;
        toAttachTask.Subject = emailSubject;
		toAttachTask.Description = emailBody;
        toAttachTask.TaskSubtype = 'Email';
        toAttachTask.Status = 'Open';
        toAttachTask.Priority = 'Normal';
        toAttachTask.ActivityDate = Date.today();
        insert toAttachTask;
        System.debug('Task Attached Successfully to ' + candidate.Id);
        
        // Return True and exit.
        // True confirms program is complete and no emails 
        // should be sent to the sender of the unsubscribe request. 
        result.success = true;
        return result;
    }
}