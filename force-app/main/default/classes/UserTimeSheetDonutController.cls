//UserTaskTypeWiseChart
public without sharing class UserTimeSheetDonutController {
    @AuraEnabled(cacheable=true)
    public static List<UserTimeSheetData> getUserTimeSheetDetails(String employeeId) {
        //Timesheet__c Timesheet = [SELECT Id, Employee__c FROM Timesheet__c Where Id =:employeeId];
        Employee__c Employee = [SELECT Id from Employee__c where Id =:employeeId];
        system.debug('employeeId------>'+employeeId);
        //Attendance__c A = [select Id, Date__c from Attendance__c WHERE Date__c = LAST_N_MONTHS:1];
        //system.debug('Attendance'+A);
        List<AggregateResult> result = [SELECT Count(Id) cnt, Task_Type__c, SUM(Total_Hours__c) th
                                        FROM Timesheet__c
                                        WHERE Employee__c = :Employee.Id 
                                         //AND Attendance__c = :A.Id  //Employee__c = :Timesheet.Employee__c //Employee__c = :Employee.Id
                                        GROUP BY Task_Type__c];
        
       
        List<UserTimeSheetData> timeSheetData = new List<UserTimeSheetData>();
        
        for (AggregateResult ar : result) {
            String taskType = (String)ar.get('Task_Type__c');
            Decimal totalHours = (Decimal)ar.get('th');
            
            timeSheetData.add(new UserTimeSheetData(taskType, totalHours));
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
}