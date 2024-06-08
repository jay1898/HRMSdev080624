public without sharing class OppCommAlertBatch implements Database.Batchable<sObject>,Schedulable {
     
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime currentTime=DateTime.now();
        return Database.getQueryLocator('Select Id,contact__c,Opportunity__r.ownerid,Channel__c,contact__r.Email,Communication_Component__r.Email_Template__c,Communication_Component__r.SMS_Template__c,Is_Executed__c,Execution_Time__c,Opportunity_Owner_LastName__c,Opportunity_Owner_FirstName__c From OpportunityCommunication__c where Is_Executed__c=false and Opportunity__r.Is_Communication_Completed__c = false and contact__c!=null and Execution_Time__c <= :currentTime ');
    }
    
    public void execute(Database.BatchableContext BC, List<OpportunityCommunication__c> records){
        try{
            OppCommAlert.sendOppCommAlert(records);
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('OppCommAlert', 'sendOppCommAlert',JSON.serialize(records),ex, 'Internal'));
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        OppCommAlertBatch b = new OppCommAlertBatch(); 
        database.executebatch(b,1);
    }
}