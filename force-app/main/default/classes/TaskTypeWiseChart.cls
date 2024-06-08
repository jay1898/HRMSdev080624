/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//TaskTypeWiseChart
public without sharing class TaskTypeWiseChart {
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