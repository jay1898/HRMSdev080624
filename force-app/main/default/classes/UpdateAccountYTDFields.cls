global without sharing class UpdateAccountYTDFields implements Database.Batchable<sObject>,Database.Stateful
{ 
    global Date endDate;
    global Date startDate;
    global string recType='Branch Account';   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year'
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        endDate = (currentFiscalYear.FiscalYearSettings.EndDate);
        startDate = (currentFiscalYear.FiscalYearSettings.StartDate);
        Integer currentYear = Integer.valueOf(currentFiscalYear.FiscalYearSettings.Name);
        FiscalYear__c FY = FiscalYear__c.getOrgDefaults();
        FY.Current_Year__c=currentYear;
        Upsert FY;
        system.debug('EndDate='+endDate);
        system.debug('recType='+recType);
        String query = '';
        if(Test.isRunningTest()){
            query = 'SELECT PY_Sales__c,PPY_Sales__c,YTD_Sales__c,Account_Rank__c,PY_Account_Rank__c,PPY_Account_Rank__c,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c  FROM Account WHERE Fiscal_Year_Start__c=:startDate AND RecordType.Name=:recType';
        }else{
            query = 'SELECT PY_Sales__c,PPY_Sales__c,YTD_Sales__c,Account_Rank__c,PY_Account_Rank__c,PPY_Account_Rank__c,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c FROM Account WHERE  Fiscal_Year_Start__c=:startDate AND RecordType.Name=:recType';
        }
        return Database.getQueryLocator(query);       
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        // process each batch of records    
        
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        Integer currentYear = Integer.valueOf(currentFiscalYear.FiscalYearSettings.Name);
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE AccountId =:scope
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name = 'Branch Account'
                                 AND status in ('Booked', 'Ordered')
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
        
        for(Account acc : scope){
            acc.PPY_Account_Rank__c = acc.PY_Account_Rank__c;
            acc.PY_Account_Rank__c = acc.Account_Rank__c;
            acc.PPY_Account_Status__c = acc.PY_Account_Status__c;
            acc.PY_Account_Status__c = acc.Account_State__c;
            if(mapAcct.containsKey(acc.Id)){
                acc.YTD_Sales__c = mapAcct.get(acc.Id);
                
            }else{
                acc.YTD_Sales__c = 0;
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