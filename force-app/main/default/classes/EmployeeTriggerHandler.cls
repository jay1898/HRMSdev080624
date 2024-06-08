/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-31-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EmployeeTriggerHandler {
    
    Public static void updatePasswordResetKey(List<Employee__c> newEmployeeList,Map<Id,Employee__c> oldEmployeeMap){
        for( Employee__c emp: newEmployeeList){
            emp.Password_Reset_Key__c=emp.Username__c;
        }
    }
    public static void checkForCircularHierarchy(Map<Id, Employee__c> newEmployeeMap) {
        if (newEmployeeMap == null) {
            return; // Exit the method if the input map is null
        }
        
        for (Employee__c emp : newEmployeeMap.values()) {
            if (emp == null || emp.Manager__c == null) {
                continue; // Skip processing if the employee or their manager is null
            }
            
            Set<Id> visitedEmployeeIds = new Set<Id>();
            Id currentManagerId = emp.Manager__c;
            
            // Traverse up the manager hierarchy to check for circular reference
            while (currentManagerId != null) {
                if (currentManagerId == emp.Id) {
                    // Circular reference found
                    emp.Manager__c.addError('Circular hierarchy detected: An employee cannot report directly or indirectly to themselves.');
                    break;
                }
                
                // Check if we've already visited this manager to avoid infinite loop
                if (visitedEmployeeIds.contains(currentManagerId)) {
                    break;
                }
                
                // Add current manager to the visited set
                visitedEmployeeIds.add(currentManagerId);
                
                // Get the next manager in the hierarchy
                Employee__c manager = [SELECT Id, Manager__c FROM Employee__c WHERE Id = :currentManagerId LIMIT 1];
                if (manager == null) {
                    break; // No further manager in the hierarchy
                }
                
                currentManagerId = manager.Manager__c;
            }
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
                att.Employee__c = emp.Id; 
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
                if(!Test.isRunningTest())
                    Messaging.sendEmail(emails);
            }  
        } else {
            System.debug('Email Template not found');
        } 
    }

   public static void createEmployeeSkillSet(List<Employee__c> newEmployeeList, Map<Id,Employee__c> oldEmployeeMap) {
        Map<Id, Employee__c> empMap = new Map<Id, Employee__c>(newEmployeeList);

        List<Skill_Matrix__c> skillList = [SELECT Id, Name FROM Skill_Matrix__c ];

        if (skillList.size() > 0) {
            List<Skills_Set__c> employeeSkillSetList = new List<Skills_Set__c>();
            for (Id e : empMap.keySet()) {
                for (Skill_Matrix__c sk : skillList) {
                    Skills_Set__c ss = new Skills_Set__c(
                        Employee__c = e,
                        Skill_Matrix__c = sk.Id
                    );
                    employeeSkillSetList.add(ss);
                }
            }

            if (employeeSkillSetList.size() > 0) {
                try {
                    insert employeeSkillSetList;
                } catch (Exception e) {
                    System.debug('Exception while inserting employee skillset' +e.getMessage());
                }
            }
        }
    }
}