public class P_UpdateCampaignsCountBatchLeads implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    String queryString = '';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('P_UpdateCampaignsCountBatchLeads invoked');
        String timeOneHourBefore = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'.000+0000\'');
        String timeNow = DateTime.now().addMinutes(120).format('yyyy-MM-dd\'T\'HH:mm:ss\'.000+0000\'');
        
        if(Test.isRunningTest()){
            this.queryString = 'SELECT Campaign__c FROM Lead WHERE Campaign__c!=null AND LastModifiedDate = TODAY AND HOUR_IN_DAY(LastModifiedDate) > 1 LIMIT 1';
        } else {
            this.queryString = 'SELECT Campaign__c FROM Lead WHERE Campaign__c!=null AND LastModifiedDate>= '+timeOneHourBefore+' AND LastModifiedDate<= '+timeNow;
        }
        System.debug('queryString --> '+this.queryString);
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        
        List<Campaign> campToUpsert = new List<Campaign>(); // Campaign records to update
        Map<Id, Integer> cIdWithCountOfLd = new Map<Id, Integer>(); //Campaign Id with Count (Number) of Lead 
        Map<Id, Integer> cIdWithConvCountOfLd = new Map<Id, Integer>(); //Campaign Id with the Number of Converted Leads
        
        Set<Id> campIds = new Set<Id>();
        System.debug('scope size --> '+scope.size());
        for(Lead ld : scope) {
            campIds.add(ld.Campaign__c);
        }
        
        for (AggregateResult ar : [SELECT Campaign__c, Count(Id)
                                   FROM Lead WHERE Campaign__c IN :campIds
                                   GROUP BY Campaign__c])  
        {
            cIdWithCountOfLd.put((Id)ar.get('Campaign__c'), (Integer)ar.get('expr0'));
        }
        
        for (AggregateResult ar : [SELECT Campaign__c, Count(Id)
                                   FROM Lead WHERE Campaign__c IN :campIds and Status='Converted'
                                   GROUP BY Campaign__c])  
        {
            cIdWithConvCountOfLd.put((Id)ar.get('Campaign__c'), (Integer)ar.get('expr0'));
        }
        
        for(Campaign camp : [SELECT Id, Number_Of_Leads_in_Campaign__c, Number_of_Converted_Leads_in_Campaign__c
                             FROM Campaign
                             WHERE Id IN :campIds]) 
        {
            camp.Number_Of_Leads_in_Campaign__c = cIdWithCountOfLd.get(camp.Id);
            camp.Number_of_Converted_Leads_in_Campaign__c = cIdWithConvCountOfLd.get(camp.Id);
            campToUpsert.add(camp);
        }
        if(campToUpsert.size()>0) {
            upsert campToUpsert;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
    public void execute(SchedulableContext sc) {
        
    }
}