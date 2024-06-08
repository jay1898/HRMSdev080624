public without sharing class timeSheetFilterData {
     @AuraEnabled(cacheable=true)
    public static List<Timesheet__c> getTimesheetDataWithDateFilter(Date selectedDate, Date selectedToDate, List<String> projectNames, List<String> employeeName) {
       
        // Build the dynamic part of the query based on the presence of employeeName and projectNamesList
        
        String dynamicQuery = '';
        if (employeeName != null && !employeeName.isEmpty()) {
            dynamicQuery += ' AND Employee__r.NAME IN :employeeName';
        }
        if (!projectNames.isEmpty()) {
            dynamicQuery += ' AND Project_Name__c IN :projectNames';
        }
        if (selectedToDate!=null && selectedDate != null) {
            dynamicQuery += ' AND Date__c >= :selectedDate  AND Date__c <= :selectedToDate';
        }
        else if (selectedDate != null) {
            dynamicQuery += ' AND Date__c = :selectedDate';
        }

        // Build the complete query
        String query;
        if (String.isBlank(dynamicQuery)) {
             query = 'SELECT Id, Ticket_No__c, Employee__r.Name, Task_Description__c,Total_Hours__c, Date__c,Project_Name__c  FROM Timesheet__c ORDER BY Employee__r.sequence_number__c ASC NULLS LAST, Date__c DESC,Employee__r.Name ASC';
        }else {
             query = 'SELECT Id, Ticket_No__c, Employee__r.Name, Task_Description__c,Total_Hours__c, Date__c,Project_Name__c  FROM Timesheet__c';
        }
        
        if (!String.isBlank(dynamicQuery)) {
            query += ' WHERE ' + dynamicQuery.substring(4) + ' ORDER BY Employee__r.sequence_number__c ASC NULLS LAST';

        }
        return Database.query(query);
    }

    @AuraEnabled
    public static List<Timesheet__c> getTicketHistory(string EmpId, String selectedTicket, Boolean selectedEntireSheet , String selectedOption) {
        System.debug('selectedOption@@'+selectedOption);
        if (selectedOption == 'exact') {
            if (selectedEntireSheet == true) {
                return [SELECT Id, Date__c, Employee__c, Task_Type__c, Ticket_No__c, Task_Description__c, Total_Hours__c, Employee__r.Name, Component_Change__c FROM Timesheet__c WHERE Ticket_No__c = :selectedTicket   ORDER BY Date__c DESC];
            }
            else {
                return [SELECT Id, Date__c, Employee__c , Task_Type__c, Ticket_No__c, Task_Description__c, Total_Hours__c, Employee__r.Name, Component_Change__c FROM Timesheet__c  WHERE Ticket_No__c = :selectedTicket  AND Employee__c =: EmpId order by Date__c DESC];
            }
        }else {
            if (selectedEntireSheet == true) {
                return [SELECT Id, Date__c, Employee__c, Task_Type__c, Ticket_No__c, Task_Description__c, Total_Hours__c, Employee__r.Name, Component_Change__c FROM Timesheet__c WHERE Ticket_No__c LIKE :('%' + selectedTicket + '%')  ORDER BY Date__c DESC];
            }
            else {
                return [SELECT Id, Date__c, Employee__c , Task_Type__c, Ticket_No__c, Task_Description__c, Total_Hours__c, Employee__r.Name, Component_Change__c FROM Timesheet__c  WHERE Ticket_No__c LIKE :('%' + selectedTicket + '%') AND Employee__c =: EmpId order by Date__c DESC];
            }
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getEmployeeData(string EmpId) {
        return [SELECT Id, Name,Entire_Time_Sheet__c  FROM Employee__c WHERE Id =: EmpId];
    }
    
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
        /*
          if (selectedToDate!=null && selectedDate != null) {
            dynamicQuery += ' AND Date__c >= :selectedDate  AND Date__c <= :selectedToDate';
        }
		    else if (selectedDate != null) {
            dynamicQuery += ' AND Date__c = :selectedDate';
        }*/
        // Build the complete query
        String query;
        if (String.isBlank(dynamicQuery)) {
             query = 'SELECT Id, Ticket_No__c, Employee__r.Name, Task_Description__c,Total_Hours__c, Date__c,Project_Name__c  FROM Timesheet__c ORDER BY Employee__r.sequence_number__c ASC NULLS LAST, Date__c DESC,Employee__r.Name ASC';
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
        return [SELECT Id, Name,Default_Active__c,sequence_number__c FROM Employee__c ORDER BY sequence_number__c ASC];
    }
    @AuraEnabled(cacheable=true)
    public static List<Project_Name__c> projectNames() {
        return [SELECT Id, name,Default_Active__c FROM Project_Name__c ];
    }

    @AuraEnabled
    public static String updateEmployeeRecords(List<String> selectedProjectName, List<String> selectedEmployeName) {
        System.debug('selectedProjectName@@'+selectedProjectName);
        List<Employee__c> employeesToUpdate = [SELECT Id, Name, Default_Active__c, sequence_number__c FROM Employee__c];
        List<Project_Name__c> projectsToUpdate = [SELECT Id, Name, Default_Active__c FROM Project_Name__c];

        Map<String, Integer> projectIndexMap = new Map<String, Integer>();
        for (Integer i = 0; i < selectedEmployeName.size(); i++) {
            projectIndexMap.put(selectedEmployeName[i], i+1);
        }

        for (Employee__c emp : employeesToUpdate) {
            if (selectedEmployeName.contains(emp.Name) && selectedEmployeName.size() != 0) {
                emp.Default_Active__c = true;
                emp.sequence_number__c = projectIndexMap.get(emp.Name);
            } else {
                emp.Default_Active__c = false;
                emp.sequence_number__c = null;
            }
        }
         update employeesToUpdate;

        for (Project_Name__c proj : projectsToUpdate) {
            if (selectedProjectName.contains(proj.Name) && selectedProjectName.size() != 0) {
                proj.Default_Active__c = true;
            } else {
                proj.Default_Active__c = false;
            }
        }
         update projectsToUpdate;

        return 'success';
    } 
}