public with sharing class timeSheetFilterData {
    @AuraEnabled(cacheable=true)
    public static List<Timesheet__c> getTimesheetData(Date selectedDate, List<String> projectNames, List<String> employeeName) {
       
        // Build the dynamic part of the query based on the presence of employeeName and projectNamesList
        System.debug('projectNames@@'+projectNames);
        
        String dynamicQuery = '';
        if (employeeName != null && !employeeName.isEmpty()) {
            dynamicQuery += ' AND Employee__r.NAME IN :employeeName';
        }
        if (!projectNames.isEmpty()) {
            dynamicQuery += ' AND Project_Name__c IN :projectNames';
        }
        if (selectedDate != null) {
            dynamicQuery += ' AND Date__c = :selectedDate';
        }

        // Build the complete query
        String query;
        if (String.isBlank(dynamicQuery)) {
             query = 'SELECT Id, Ticket_No__c, Employee__r.Name, Task_Description__c,Total_Hours__c, Date__c,Project_Name__c  FROM Timesheet__c ORDER BY Employee__r.sequence_number__c ASC NULLS LAST';
        }else {
             query = 'SELECT Id, Ticket_No__c, Employee__r.Name, Task_Description__c,Total_Hours__c, Date__c,Project_Name__c  FROM Timesheet__c';
        }
        
        if (!String.isBlank(dynamicQuery)) {
            query += ' WHERE ' + dynamicQuery.substring(4) + ' ORDER BY Employee__r.sequence_number__c ASC NULLS LAST';

        }
        System.debug('query@@@'+query);
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getEmployeeNames() {
        return [SELECT Id, Name,Default_Active__c FROM Employee__c];
    }
    @AuraEnabled(cacheable=true)
    public static List<Project_Name__c> projectNames() {
        return [SELECT Id, name,Default_Active__c FROM Project_Name__c ];
    }
           
}