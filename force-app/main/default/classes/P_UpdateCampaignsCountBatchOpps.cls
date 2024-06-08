public class P_UpdateCampaignsCountBatchOpps implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    String queryString = '';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('P_UpdateCampaignsCountBatchOpps invoked');
		//SELECT CampaignId,LastModifiedDate  FROM Opportunity WHERE CampaignId!=null AND LastModifiedDate >2022-04-25T18:00:00.000+0000 AND LastModifiedDate<2022-04-25T19:00:00.000+0000
        String timeOneHourBefore = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'.000+0000\'');
        String timeNow = DateTime.now().addMinutes(120).format('yyyy-MM-dd\'T\'HH:mm:ss\'.000+0000\'');
        
        if(Test.isRunningTest()){
        	this.queryString = 'SELECT CampaignId FROM Opportunity WHERE CampaignId!=null AND LastModifiedDate = LAST_N_DAYS:1 AND HOUR_IN_DAY(LastModifiedDate) > 1 Limit 1';// AND HOUR_IN_DAY(LastModifiedDate) > 1 ';
        } else { 
            this.queryString = 'SELECT CampaignId FROM Opportunity WHERE CampaignId!=null AND LastModifiedDate>= '+timeOneHourBefore+' AND LastModifiedDate<= '+timeNow;
        }
        System.debug('this.queryString --> '+this.queryString);
        return Database.getQueryLocator(this.queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        
        Map<Id, Integer> cIdWithCountOfOpty = new Map<Id, Integer>(); //Campaign Id with the Number of Opportunity
        Map<Id, Decimal> cIdWithCountOfOptyValue = new Map<Id, Decimal>(); //Campaign Id with the SUM of Opty value
        Map<Id, Integer> cIdWithWonCountOfOpty = new Map<Id, Integer>(); //Campaign Id with the Count of Won Optys
        Map<Id, Decimal> cIdWithWonCountOfOptyValue = new Map<Id, Decimal>(); //Campaign Id with the SUM of Won Opty value
        List<Campaign> campToUpsert = new List<Campaign>();// Campaign records to update
        Set<Id> campIds = new Set<Id>();
        System.debug('scope size --> '+scope.size());
        for(Opportunity op : scope) {
            campIds.add(op.CampaignId);
        }
        
        for (AggregateResult ar : [SELECT CampaignId, Count(Id), SUM(Total_BO_price_quotes__c)
                                   FROM Opportunity WHERE CampaignId IN :campIds AND 
                                   StageName='Closed Won'
                                   GROUP BY CampaignId]) 
        {
            cIdWithWonCountOfOpty.put((Id)ar.get('CampaignId'), (Integer)ar.get('expr0'));
            cIdWithWonCountOfOptyValue.put((Id)ar.get('CampaignId'), (Decimal)ar.get('expr1'));
        }
        
        for (AggregateResult ar : [SELECT CampaignId, Count(Id), SUM(Total_Un_Forecasted_Price_Quotes__c)
                                   FROM Opportunity WHERE CampaignId IN :campIds
                                   GROUP BY CampaignId])  
        {
            cIdWithCountOfOpty.put((Id)ar.get('CampaignId'), (Integer)ar.get('expr0'));
            cIdWithCountOfOptyValue.put((Id)ar.get('CampaignId'), (Decimal)ar.get('expr1'));
        }
        
        for(Campaign camp : [SELECT Id, 
                             Number_of_Opportunities_in_Campaign__c, Number_of_Won_Opportunities_in_Campaign__c, 
                             Total_Value_of_Opportunities_in_Campaign__c, Total_Value_of_Won_Opps_in_Campaign__c
                             FROM Campaign
                             WHERE Id IN :campIds]) 
        {
            camp.Number_of_Opportunities_in_Campaign__c = cIdWithCountOfOpty.get(camp.Id);
            camp.Number_of_Won_Opportunities_in_Campaign__c = cIdWithWonCountOfOpty.get(camp.Id);
            camp.Total_Value_of_Opportunities_in_Campaign__c = cIdWithCountOfOptyValue.get(camp.Id);
            camp.Total_Value_of_Won_Opps_in_Campaign__c = cIdWithWonCountOfOptyValue.get(camp.Id);
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