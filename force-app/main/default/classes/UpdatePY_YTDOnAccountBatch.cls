global without sharing class UpdatePY_YTDOnAccountBatch implements Database.Batchable<sObject>,Database.Stateful
{ 
	global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year'
                            AND StartDate <= :Date.valueOf(Label.UpdateYTDFiscalYearDate) AND EndDate >= :Date.valueOf(Label.UpdateYTDFiscalYearDate)];
        Date endDate = (currentFiscalYear.FiscalYearSettings.EndDate);
        Date startDate = (currentFiscalYear.FiscalYearSettings.StartDate);
        
        return Database.getQueryLocator(Label.UpdateYTDQuery);       
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        // process each batch of records		
        
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= :Date.valueOf(Label.UpdateYTDFiscalYearDate) AND EndDate >= :Date.valueOf(Label.UpdateYTDFiscalYearDate)];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;
       
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE AccountId =:scope
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name = 'Branch Account'
                                 AND BookDate__c >=: stdt AND BookDate__c <=: eddt];
        
        Decimal totalAcc = 0;
        Map<String, Decimal> mapAcct = new Map<String, Decimal>();
        
        for(Quote qt : quoteList){
            if(!mapAcct.containsKey(qt.AccountId)){
                mapAcct.put(qt.AccountId, 0);
            }
            totalAcc = mapAcct.get(qt.AccountId) + (qt.Customer_Extended_Price__c == null ? 0 : qt.Customer_Extended_Price__c);
            mapAcct.put(qt.AccountId, totalAcc);            
        }
        String updateFieldName=Label.UpdateYTDFieldName;
        for(Account acc : scope){
            if(mapAcct.containsKey(acc.Id)){
                acc.put(updateFieldName,mapAcct.get(acc.Id));
            }else{
                acc.put(updateFieldName,0);
            }
        }
        if(scope.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update scope; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
    }    
    global void finish(Database.BatchableContext bc){        
    }    
}