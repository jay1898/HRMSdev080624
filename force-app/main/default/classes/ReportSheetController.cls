/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class ReportSheetController {

    @AuraEnabled
    public static List<AggregateResult> getUniqueTicketHours(String employeeId){
        try {
            List<AggregateResult> totalHours = new List<AggregateResult>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId)) {
                totalHours = [SELECT  Project_Name__c, SUM(Total_Hours__c) hours, Ticket_No__c
                                                    FROM Timesheet__c
                                                    WHERE Employee__c = :employeeId
                                                    GROUP BY Ticket_No__c, Project_Name__c ORDER BY SUM(Total_Hours__c) DESC];
            }
            return totalHours;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, List<Object>> findTicketsAssigningInMultipleProjects(String employeeId) {
        try {
            Map<String, List<Object>> result = new Map<String, List<Object>>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId)) {
                List<AggregateResult> ticketList = [SELECT Project_Name__c, Ticket_No__c, SUM(Total_Hours__c)totalHrs FROM Timesheet__c WHERE Employee__c =: employeeId GROUP BY Project_Name__c, Ticket_No__c ORDER BY SUM(Total_Hours__c) DESC];

                if (ticketList.size() > 0) {
                   for (AggregateResult ar : ticketList) {
                        String key = String.valueOf(ar.get('Ticket_No__c'));
                        if (result.containsKey(key)) {
                            List<Object> valueList = result.get(key);
                            valueList[0] = 'Invalid';
                            valueList[1] = (Decimal)valueList[1] + (Decimal)ar.get('totalHrs');
                            result.put(key, valueList);
                        }
                        else {
                            result.put(key, new List<Object>{ar.get('Project_Name__c'), ar.get('totalHrs')});
                        }
                    }
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AggregateResult> getOnTicketTaskWiseHours(String employeeId, String ticketNumber){
        try {
            List<AggregateResult> taskHours = new List<AggregateResult>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId) || String.isNotBlank(ticketNumber) && !String.isEmpty(ticketNumber)) {
                taskHours = [SELECT  Ticket_No__c, Task_Type__c, SUM(Total_Hours__c) totalTaskHours
                                    FROM  Timesheet__c WHERE Employee__c = :employeeId 
                                    AND Ticket_No__c = :ticketNumber 
                                    GROUP BY Task_Type__c,Ticket_No__c 
                                    ORDER BY SUM(Total_Hours__c) DESC];
            }
            return taskHours;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AggregateResult> getMonthWiseUniqueTicketHours(String employeeId, Integer month, Integer year){
        try {
            List<AggregateResult> monthWiseTaskHours = new List<AggregateResult>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId) || month != null || year != null) {
                monthWiseTaskHours = [SELECT Ticket_No__c, Project_Name__c, SUM(Total_Hours__c) monthwisetotalHours
                                FROM Timesheet__c
                                WHERE Employee__c = :employeeId
                                AND CALENDAR_MONTH(Date__c) = :month AND CALENDAR_YEAR(Date__c) = :year
                                GROUP BY CALENDAR_MONTH(Date__c), CALENDAR_YEAR(Date__c), Ticket_No__c ,Project_Name__c
                                ORDER BY SUM(Total_Hours__c) DESC];
            }
            return monthWiseTaskHours;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, List<Object>> MonthWiseFindTicketsAssigningInMultipleProjects(String employeeId, Integer month, Integer year) {
        try {
            Map<String, List<Object>> result = new Map<String, List<Object>>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId)) {
                List<AggregateResult> ticketList = [SELECT Project_Name__c, Ticket_No__c, SUM(Total_Hours__c)totalHrs FROM Timesheet__c WHERE Employee__c =: employeeId AND CALENDAR_MONTH(Date__c) = :month AND CALENDAR_YEAR(Date__c) = :year GROUP BY Project_Name__c, Ticket_No__c ORDER BY SUM(Total_Hours__c) DESC];

                if (ticketList.size() > 0) {
                   for (AggregateResult ar : ticketList) {
                        String key = String.valueOf(ar.get('Ticket_No__c'));
                        if (result.containsKey(key)) {
                            List<Object> valueList = result.get(key);
                            valueList[0] = 'Invalid';
                            valueList[1] = (Decimal)valueList[1] + (Decimal)ar.get('totalHrs');
                            result.put(key, valueList);
                        }
                        else {
                            result.put(key, new List<Object>{ar.get('Project_Name__c'), ar.get('totalHrs')});
                        }
                    }
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AggregateResult> getMonthWiseProjectHours(String employeeId, Integer month, Integer year){
        try {
            List<AggregateResult> monthWiseProjectHours = new List<AggregateResult>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId) || month != null || year != null) {
                monthWiseProjectHours = [SELECT Project_Name__c, SUM(Total_Hours__c) monthWiseProjectHours
                                FROM Timesheet__c
                                WHERE Employee__c = :employeeId
                                AND CALENDAR_MONTH(Date__c) = :month AND CALENDAR_YEAR(Date__c) = :year
                                GROUP BY CALENDAR_MONTH(Date__c), CALENDAR_YEAR(Date__c), Project_Name__c
                                ORDER BY SUM(Total_Hours__c) DESC];
            }
            return monthWiseProjectHours;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AggregateResult> getMonthWiseTaskTypeHours(String employeeId, Integer month, Integer year){
        try {
            List<AggregateResult> monthWiseTaskTypeHours = new List<AggregateResult>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId) || month != null || year != null) {
                monthWiseTaskTypeHours = [SELECT Task_Type__c, SUM(Total_Hours__c) monthWiseTaskHours
                                FROM Timesheet__c
                                WHERE Employee__c = :employeeId
                                AND CALENDAR_MONTH(Date__c) = :month AND CALENDAR_YEAR(Date__c) = :year
                                GROUP BY CALENDAR_MONTH(Date__c), CALENDAR_YEAR(Date__c), Task_Type__c
                                ORDER BY SUM(Total_Hours__c) DESC];
            }
            return monthWiseTaskTypeHours;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Integer, Decimal> getCurrentYearHoursReports(String employeeId, Integer year){
        try {
            List<AggregateResult> currentYearMonthTotalHours = new List<AggregateResult>();
            Map<Integer, Decimal> result = new Map<Integer, Decimal>();

            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId) || year != null) {
                currentYearMonthTotalHours = [SELECT CALENDAR_MONTH(Date__c) monthName, SUM(Total_Hours__c) monthTotalHours
                                FROM Timesheet__c
                                WHERE Employee__c = :employeeId AND CALENDAR_YEAR(Date__c) = :year
                                GROUP BY CALENDAR_MONTH(Date__c) ORDER BY CALENDAR_MONTH(Date__c)];

                if (currentYearMonthTotalHours.size() > 0) {
                    for (AggregateResult ar : currentYearMonthTotalHours) {
                        result.put(
                            Integer.valueOf(ar.get('monthName')), 
                            (Decimal)ar.get('monthTotalHours')
                        );
                    }
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AggregateResult> getCurrentYearTotalHours(String employeeId, Integer year){
        try {
            List<AggregateResult> currentYearTotalHours = new List<AggregateResult>();
            if (String.isNotBlank(employeeId) && !String.isEmpty(employeeId) || year != null) {
                currentYearTotalHours = [SELECT  SUM(Total_Hours__c) allTotalHours
                                        FROM Timesheet__c
                                        WHERE Employee__c = :employeeId 
                                        AND CALENDAR_YEAR(Date__c) = :year];
            }
            return currentYearTotalHours;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<UserTimeSheetData> getUserProjectWiseChart(String employeeId){
        Employee__c Employee = [SELECT Id from Employee__c where Id =:employeeId];
        system.debug('employeeId------>'+employeeId);
        List<AggregateResult> result = [SELECT Count(Id) cnt, Project_Name__c, SUM(Total_Hours__c) th
                                        FROM Timesheet__c
                                        WHERE Employee__c = :Employee.Id   //Employee__c = :Timesheet.Employee__c //Employee__c = :Employee.Id
                                        GROUP BY Project_Name__c ORDER BY SUM(Total_Hours__c) DESC];
        
        List<UserTimeSheetData> timeSheetData = new List<UserTimeSheetData>();
        
        for (AggregateResult ar : result) {
            String ProjectName = (String)ar.get('Project_Name__c');
            Decimal totalHours = (Decimal)ar.get('th');
            
            timeSheetData.add(new UserTimeSheetData(ProjectName, totalHours));
        }
        
        return timeSheetData;
    }
    
    public class UserTimeSheetData {
        @AuraEnabled
        public String taskType { get; set; }
        
        @AuraEnabled
        public Decimal totalHours { get; set; }
        
        public UserTimeSheetData(String taskType, Decimal totalHours) {
            this.taskType = taskType;
            this.totalHours = totalHours;
        }
    }

    @AuraEnabled
    public static List<DataSet> getallTaskDetails(String employeeId){  //select Id,Project_Name__c,Total_Hours__c from Timesheet__c
        List<AggregateResult> result =  [SELECT Count(Id) cnt, Task_Type__c, SUM(Total_Hours__c) th FROM  Timesheet__c WHERE Employee__c = :employeeId GROUP BY Task_Type__c ORDER BY SUM(Total_Hours__c) DESC];
        List<DataSet> dataSet = new List<DataSet>();
        for(AggregateResult ar : result) {
            String stage =  (String)ar.get('Task_Type__c') ;
            //Integer total =  (Integer)ar.get('cnt');
            decimal totalhours =  (decimal)ar.get('th');
            dataSet.add(new DataSet(stage ,totalhours));
        }
        return dataSet ;
    }
    
    public class DataSet {
        public DataSet(String label ,decimal count){
            this.label  = label ;
            this.count  = count ;
        }
        
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public decimal  count {get;set;}
    }
}