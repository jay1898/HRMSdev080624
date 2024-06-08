//Test class : Branch_SA_Campaign_AssignmentBatchTest
public class Branch_SA_Campaign_AssignmentBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(Test.isRunningTest()){
            return Database.getQueryLocator([SELECT Id FROM UserTerritory2Association Order by LastModifiedDate desc LIMIT 1 ]);
        }else{
            return Database.getQueryLocator([SELECT Id FROM UserTerritory2Association ]);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<UserTerritory2Association> listUTA){
        List<String> listRecIds=new List<String>();
        for(UserTerritory2Association UTA : listUTA){
            listRecIds.add(UTA.Id);
        } 
        UserTerritory2AssociationTriggerHandler.shareRecordsWithUTAWithoutFuture(listRecIds); 
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        Branch_SA_Campaign_AssignmentBatch b = new Branch_SA_Campaign_AssignmentBatch(); 
        database.executebatch(b,1);
    }
}