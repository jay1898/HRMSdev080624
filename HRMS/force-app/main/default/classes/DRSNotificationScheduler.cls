global class DRSNotificationScheduler implements Database.Batchable<SObject>,Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator('select Id,CreatedDate,Employee__c,Total_Clock_In_Hours__c,Employee__r.Email__c,Employee__r.Name,Total_Timesheet_Hours__c from Attendance__c  where Total_Timesheet_Hours__c = 0 and CreatedDate = TODAY' );      
    }
      
    global void execute(Database.BatchableContext context, List<Attendance__c> scope) {
        System.debug('scope@@'+ scope);
        List<Clock_In_Out__c> presentEMP = [select Id,Clock_In_Time__c,Employee__c,Employee__r.Email__c,Employee__r.Name from Clock_In_Out__c where CreatedDate = TODAY];
        Set<Id> presentEmployeeIds = new Set<Id>();
        for (Clock_In_Out__c clockInOut : presentEMP) {
            presentEmployeeIds.add(clockInOut.Employee__c);
            System.debug('Enter For loop 1st@@');
        }
        System.debug('Enter For loop above @@');
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (Attendance__c empData : scope) {
            System.debug('Enter For loop@@');
            if (presentEmployeeIds.contains(empData.Employee__c) && empData.Total_Timesheet_Hours__c == 0 && empData.Employee__r.Email__c != null) {
                System.debug('empData.Total_Clock_In_Hours__c data@@'+ empData.Total_Clock_In_Hours__c);
                System.debug('empData.Total_Timesheet_Hours__c data@@'+ empData.Total_Timesheet_Hours__c);
                System.debug('scopeemail data@@'+ empData.Employee__r.Email__c);
                System.debug('scopename data@@'+ empData.Employee__r.Name);
                String toAddress = empData.Employee__r.Email__c;
                String subject = 'Gentle Reminder: Important Task of Timesheet completion pending!';
                String body = 'Dear, '+empData.Employee__r.Name+',\n\nI hope this message finds you well. This is a friendly reminder to submit your timesheet for the current pay period. As our team relies on accurate and timely timesheet submissions, we kindly request that you complete this task at your earliest convenience.';
                	
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{toAddress});
                email.setSubject(subject);
                email.setPlainTextBody(body);
                emailsToSend.add(email);
            }
        }
        
        if(emailsToSend.size()>0){
            Messaging.sendEmail(emailsToSend);
        } 
    } 
    
    global void finish(Database.BatchableContext context) {
        system.debug('@@Finish Method');
    }
    global void execute(SchedulableContext context) {
        DRSNotificationScheduler batch = new DRSNotificationScheduler();
        Database.executeBatch(batch,100);
    }
    
    
}