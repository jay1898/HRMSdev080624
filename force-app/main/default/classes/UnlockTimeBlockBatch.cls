public class UnlockTimeBlockBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
	
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime TBDateTime=DateTime.now().addMinutes(-30);
        return Database.getQueryLocator('SELECT ID FROM RTA_Timeblock__c Where Createddate<= :TBDateTime');
    }
    
    public void execute(Database.BatchableContext BC, List<RTA_Timeblock__c> records){
        try{
            Delete records;
        }
        catch(Exception ex){
          
        } 
    }
    
    public void finish(Database.BatchableContext BC){
       
    }
    public void execute(SchedulableContext sc) {
        UnlockTimeBlockBatch b = new UnlockTimeBlockBatch(); 
        database.executebatch(b,200);
    }
}