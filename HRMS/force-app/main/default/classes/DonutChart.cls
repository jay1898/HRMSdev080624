//Project Wise Chart
public without sharing class DonutChart {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getAllOppsByStage(){ //select Id,Project_Name__c,Total_Hours__c from Timesheet__c
        List<AggregateResult> result =  [SELECT Count(Id) cnt, Project_Name__c, SUM(Total_Hours__c) th FROM  Timesheet__c 
                                         GROUP BY Project_Name__c];
        system.debug('Result'+result);
        List<DataSet> dataSet = new List<DataSet>();
        for(AggregateResult ar : result) {
            String stage =  (String)ar.get('Project_Name__c') ;
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
/*public without sharing class DonutChart {
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getAllOppsByStage(){
        List<Project_Name__c> projects = [SELECT Id, Main_Project_Name__c FROM Project_Name__c WHERE Main_Project_Name__c != null];
        Map<Id, String> projectMap = new Map<Id, String>();
        for (Project_Name__c project : projects) {
            projectMap.put(project.Id, project.Main_Project_Name__c);
        }
		system.debug('projectMap---->'+projectMap);
        List<AggregateResult> result = [
            SELECT Count(Id) cnt, Project__r.Name nm, SUM(Total_Hours__c) th 
            FROM Timesheet__c
            WHERE Project__r.Name != null
            GROUP BY Project__r.Name
        ];

        System.debug('Result Size: ' + result.size()); // Check the size of the result set
        System.debug('Result: ' + result);

        List<DataSet> dataSet = new List<DataSet>();
        for (AggregateResult ar : result) {
            String stage = (String)ar.get('nm');
            system.debug('stage----->'+stage);
            Decimal totalhours = (Decimal)ar.get('th');
            dataSet.add(new DataSet(stage, totalhours));
        }

        System.debug('dataSet: ' + dataSet);
        return dataSet;
    }
    
    public class DataSet {
        public DataSet(String label, Decimal count) {
            this.label = label;
            this.count = count;
        }

        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Decimal count { get; set; }
    }
}*/