public class LeadAssignmentBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ID,Zone__c FROM Lead ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> listLead){
        List<Id> listLeadIds=new List<Id>();
        for(Lead lead : listLead){
            if(lead.Zone__c!=null ){
                listLeadIds.add(lead.Id);
            }
        } 
        if(listLeadIds.size()>0 ){
             LeadRecordShare.shareLeadRecordWithETMGroup(listLeadIds);
        }
    }
    
    public void finish(Database.BatchableContext BC){
          
    }
    public void execute(SchedulableContext sc) {
        LeadAssignmentBatch b = new LeadAssignmentBatch(); 
        database.executebatch(b,200);
    }
}