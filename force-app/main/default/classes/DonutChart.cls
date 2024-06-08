//Project Wise Chart
public without sharing class DonutChart {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getAllOppsByStage(){ 
        List<AggregateResult> result =  [SELECT Count(Id) cnt, Project_Name__c, SUM(Total_Hours__c) th FROM  Timesheet__c 
                                         GROUP BY Project_Name__c];
        system.debug('Result'+result);
        List<DataSet> dataSet = new List<DataSet>();
        for(AggregateResult ar : result) {
            String stage =  (String)ar.get('Project_Name__c') ;
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