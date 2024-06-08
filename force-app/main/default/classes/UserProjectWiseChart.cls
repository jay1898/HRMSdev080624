/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//User Project Wise Chart
public without sharing class UserProjectWiseChart{
    
    @AuraEnabled(cacheable=true)
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
}