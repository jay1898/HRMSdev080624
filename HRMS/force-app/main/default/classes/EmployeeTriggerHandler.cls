public class EmployeeTriggerHandler {
    
    Public static void updatePasswordResetKey(List<Employee__c> newEmployeeList,Map<Id,Employee__c> oldEmployeeMap){
        for( Employee__c emp: newEmployeeList){
            emp.Password_Reset_Key__c=emp.Username__c;
        }
    }
    
    Public static void sendWelcomeEmail(List<Employee__c> newEmployeeList,Map<Id,Employee__c> oldEmployeeMap){
        EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Welcome Email for Employee' LIMIT 1];
        if (template!=Null) {
            List<Attendance__c> attendanceList = new List<Attendance__c>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Contact con=[SELECT id from contact where email!=Null limit 1]; 
            System.debug('con::>>'+ Json.serialize(con));
            for (Employee__c emp : newEmployeeList) {
                System.debug('emp::>>'+ Json.serialize(emp));
                Attendance__c att = new Attendance__c();
                att.Employee__c = emp.Id; // Set the lookup field to the newly created employee's Id
                att.Date__c = Date.today();
                attendanceList.add(att);
                System.debug('attendanceList::>>'+ Json.serialize(attendanceList));
                // Sending the welcome email to the new employee
                if (emp.Email__c != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(template.Id);
                    mail.setWhatId(emp.Id);
                    mail.setTargetObjectId(con.Id); 
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setToAddresses(new List<String> { emp.Email__c });
                    emails.add(mail);
                }
            }
            if (attendanceList.size() > 0) {
                insert attendanceList;
            }
            if (emails.size() > 0) {
                Messaging.sendEmail(emails);
            }  
        } else {
            System.debug('Email Template not found');
        } 
    }
}