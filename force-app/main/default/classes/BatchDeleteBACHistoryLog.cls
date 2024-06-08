public class BatchDeleteBACHistoryLog implements Database.Batchable<sObject>,Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<DebugLogConfiguration__mdt> DLCMetaDate = [SELECT Id, Number_Of_Days__c, Label FROM DebugLogConfiguration__mdt Where Label = 'Delete BAC history log'];
        Integer noOfDay = Integer.valueOf(DLCMetaDate[0].Number_Of_Days__c);
        //System.debug('@noOfDay@'+ noOfDay);
        Date currentDate=Date.today().adddays(noOfDay*-1);
        return Database.getQueryLocator('SELECT Id, Name, CreatedDate FROM BAC_History__c where createddate < : currentDate order by createddate asc');
    }
    
    public void execute(Database.BatchableContext BC, List<BAC_History__c> scope){
        System.debug('@scope@'+ scope);
        delete scope;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        BatchDeleteBACHistoryLog b = new BatchDeleteBACHistoryLog(); 
        database.executebatch(b,1000);
    }
}