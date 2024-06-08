global without sharing class EmployeeOrganizationTree {
@AuraEnabled(cacheable=true)
    public static List<EmployeeWrapper> getEmployees() {
        Map<Id, EmployeeWrapper> empMap = new Map<Id, EmployeeWrapper>();
        List<EmployeeWrapper> topLevelEmployees = new List<EmployeeWrapper>();
        List<Employee__c> empList = [SELECT Id, Name, Manager__c, Manager__r.Name, Role__c FROM Employee__c];

        for (Employee__c emp : empList) {
            empMap.put(emp.Id, new EmployeeWrapper(emp));
        }
        System.debug('empMap'+empMap);
        for (EmployeeWrapper wrap : empMap.values()) {
           System.debug('wrap'+wrap);
            Employee__c emp = wrap.employee;
            if (emp.Manager__c != null && empMap.containsKey(emp.Manager__c)) {
                EmployeeWrapper managerWrap = empMap.get(emp.Manager__c);
                if (managerWrap.subordinates == null) {
                    managerWrap.subordinates = new List<EmployeeWrapper>();
                }
                managerWrap.subordinates.add(wrap);
            } else {
                topLevelEmployees.add(wrap);
            }
        }
        return topLevelEmployees;
    }

    public class EmployeeWrapper {
        @AuraEnabled public Employee__c employee;
        @AuraEnabled public List<EmployeeWrapper> subordinates;

        public EmployeeWrapper(Employee__c emp) {
            this.employee = emp;
            this.subordinates = new List<EmployeeWrapper>();
        }
    }
}