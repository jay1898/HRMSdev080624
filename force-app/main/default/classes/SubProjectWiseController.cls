// SubProjectWiseController
public class SubProjectWiseController {
    
    @AuraEnabled(cacheable=true)
    public static List<DataSet> getSubProjectWise() {
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
        
        System.debug('Result Size: ' + result.size()); 
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
    
}