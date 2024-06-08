public  without sharing class TradeOpportunityAssignmentBatch  implements Database.Batchable<sObject>,Schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Label.T_C_Opportunity_Share);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> listOpportunity){
        List<Id> listOppIds=new List<Id>();
        for(Opportunity opp : listOpportunity){
            if(Opp.Account.Branch__c!=null ){
                listOppIds.add(opp.Id);
            }
            if(opp.RecordType.DeveloperName=='trade_comm'  && opp.Account.RecordType.DeveloperName=='PersonAccount' && opp.Account_Branch_Profile__r.Branch__r.T_C_Branch_Number__c!=null){
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
        TradeOpportunityAssignmentBatch b = new TradeOpportunityAssignmentBatch(); 
        database.executebatch(b,200);
    }
}