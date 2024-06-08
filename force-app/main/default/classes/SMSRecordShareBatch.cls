public without sharing class SMSRecordShareBatch implements Database.Batchable<sObject>,Schedulable {
    
   
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator('Select Id, Opportunity__c,Opportunity__r.OwnerId,Branch__r.AOR__r.Name, Branch__r.Branch_Number__c from TwilioMessage__c');
        
    }
    
    public void execute(Database.BatchableContext BC, List<TwilioMessage__c> twillioList){
        List<Id> listTwillioIds=new List<Id>();
        for(TwilioMessage__c TM : twillioList){
            listTwillioIds.add(TM.Id);
        }
        SMSRecordShare.shareSMSRecordWithETMGroup(listTwillioIds);
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        SMSRecordShareBatch b = new SMSRecordShareBatch(); 
        database.executebatch(b,200);
    }
}