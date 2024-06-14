global class AddLeavesEverymonthScheduler implements Schedulable {
    
  global void execute(SchedulableContext ctx) {
        List<Employee__c> employees = [SELECT Id, Number_of_leaves__c,Username__c,Email__c FROM Employee__c];

        if (employees != null && !employees.isEmpty()) {
            for (Employee__c emp : employees) {
                if (emp != null && emp.Email__c != null && emp.Username__c != null) {
                    emp.Number_of_leaves__c += 1;
                }
            }
            update employees;
            System.debug('Leaves updated successfully.');
        } else {
            System.debug('No Employee records found.');
        }
    }

}