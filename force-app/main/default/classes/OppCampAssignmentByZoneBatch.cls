public class OppCampAssignmentByZoneBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(System.Label.OppCampAssignmentByZoneQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        List<Id> listOppIds=new List<Id>();
        for(Opportunity opp : oppList){
            listOppIds.add(opp.Id);
        }
        CampaignRecordShare.ShareCampWithUserByOpps(listOppIds);
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        OppCampAssignmentByZoneBatch b = new OppCampAssignmentByZoneBatch(); 
        database.executebatch(b,200);
    }
}