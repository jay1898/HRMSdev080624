public class OpportunityAssignmentBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ID,Zone__c FROM Opportunity ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> listOpportunity){
        List<Id> listOppIds=new List<Id>();
        for(Opportunity opp : listOpportunity){
            if(Opp.Zone__c!=null ){
                listOppIds.add(opp.Id);
            }
        } 
        if(listOppIds.size()>0 ){
             OpportunityRecordShare.shareOppRecordWithETMGroup(listOppIds);
        }
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        OpportunityAssignmentBatch b = new OpportunityAssignmentBatch(); 
        database.executebatch(b,200);
    }
}