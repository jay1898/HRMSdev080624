//TaskTypeWiseChart
public without sharing class TaskTypeWiseChart {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getallTaskDetails(){ //select Id,Project_Name__c,Total_Hours__c from Timesheet__c
        List<AggregateResult> result =  [SELECT Count(Id) cnt, Task_Type__c, SUM(Total_Hours__c) th FROM  Timesheet__c GROUP BY Task_Type__c];
        List<DataSet> dataSet = new List<DataSet>();
        for(AggregateResult ar : result) {
            String stage =  (String)ar.get('Task_Type__c') ;
            //Integer total =  (Integer)ar.get('cnt');
            decimal totalhours =  (decimal)ar.get('th');
            dataSet.add(new DataSet(stage ,totalhours));//total,
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