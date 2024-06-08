public class BatchDeletePQMLog implements Database.Batchable<sObject>,Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<DebugLogConfiguration__mdt> DLCMetaDate = [SELECT Id, Number_Of_Days__c, Label FROM DebugLogConfiguration__mdt Where Label = 'Delete Config'];
        Integer noOfDay = Integer.valueOf(DLCMetaDate[0].Number_Of_Days__c);
        //System.debug('@noOfDay@'+ noOfDay);
        Date currentDate=Date.today().adddays(noOfDay*-1);
        return Database.getQueryLocator('SELECT Id, Name, CreatedDate FROM PQM_Quote__c where Is_Executed__c = true and createddate < : currentDate order by createddate asc');
    }
    
    public void execute(Database.BatchableContext BC, List<PQM_Quote__c> scope){
        System.debug('@scope@'+ scope);
        delete scope;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        BatchDeletePQMLog b = new BatchDeletePQMLog(); 
        database.executebatch(b,1000);
    }
}