public without sharing class AutoLinkSWOWithQuoteBatch  implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<AsyncApexJob> listAA=[Select Id, Status,ApexClassId,ApexClass.Name, NumberOfErrors, 
                                   JobItemsProcessed,TotalJobItems, ExtendedStatus 
                                   From AsyncApexJob 
                                   Where ApexClass.Name='AutoLinkSWOWithQuoteBatch'
                                   And Status in ('Holding','Processing')];
        if(listAA.size()>0){
            return Database.getQueryLocator([SELECT ID,Quote__c,Quote__r.OpportunityId,Quote__r.Opportunity.Work_Order__c FROM WorkOrder Where Quote__c!=null limit 0]); 
        }
        return Database.getQueryLocator([SELECT ID,Quote__c,Quote__r.OpportunityId,Quote__r.Opportunity.Work_Order__c FROM WorkOrder Where Quote__c!=null order by createddate asc ]);
    }
    
    public void execute(Database.BatchableContext BC, List<WorkOrder> listWO){
        Map<Id,Quote> listQuoteToUpdate=new Map<Id,Quote>();
        Map<Id,Opportunity> listOpportunityToUpdate=new Map<Id,Opportunity>();
        for(WorkOrder WO:listWO){
            Quote Q=new Quote();
            Q.Id=WO.Quote__c;
            Q.Work_Order__c=WO.Id;
            listQuoteToUpdate.put(Q.ID,Q);
            
            if(WO.Quote__r.Opportunity.Work_Order__c==null){
                
                Opportunity Opp=new Opportunity();
                Opp.Id=WO.Quote__r.OpportunityId;
                Opp.Work_Order__c=WO.Id;
                listOpportunityToUpdate.put(Opp.ID,Opp);
            }
            
        }
        
        Boolean quoteTrigger=QuoteTriggerHandler.isRecursive;
        QuoteTriggerHandler.isRecursive=true;
        update listQuoteToUpdate.values(); 
        QuoteTriggerHandler.isRecursive=quoteTrigger;
        
        Boolean OppTrigger=OpportunityTriggerHandler.RUN_TRIGGER;
        OpportunityTriggerHandler.RUN_TRIGGER=false;
        update listOpportunityToUpdate.values(); 
        OpportunityTriggerHandler.RUN_TRIGGER=OppTrigger;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        AutoLinkSWOWithQuoteBatch b = new AutoLinkSWOWithQuoteBatch(); 
        database.executebatch(b,100);
    }
}