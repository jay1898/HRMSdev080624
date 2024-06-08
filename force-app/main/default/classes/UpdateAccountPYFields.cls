global without sharing class UpdateAccountPYFields implements Database.Batchable<sObject>,Database.Stateful
{ 
    global Date endDate;
    global Date startDate;
    global string recType='Branch Account';   
    global Database.QueryLocator start(Database.BatchableContext bc) {
       endDate = Date.valueof('2021-11-27');
       startDate = Date.valueof('2020-11-29');
        
        system.debug('EndDate='+endDate);
        system.debug('recType='+recType);
        String query = '';
        if(Test.isRunningTest()){
            query = 'SELECT PY_Sales__c,PPY_Sales__c,YTD_Sales__c,Account_Rank__c,PY_Account_Rank__c,PPY_Account_Rank__c,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c  FROM Account WHERE RecordType.Name=:recType';
        }else{
            query = 'SELECT PY_Sales__c,PPY_Sales__c,YTD_Sales__c,Account_Rank__c,PY_Account_Rank__c,PPY_Account_Rank__c,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c FROM Account WHERE RecordType.Name=:recType';
        }
        return Database.getQueryLocator(query);       
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        // process each batch of records    
        Date stdt = Date.valueof('2020-11-29');
        Date eddt = Date.valueof('2021-11-27');
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
            
            if(mapAcct.containsKey(acc.Id)){
                acc.PY_Sales__c = mapAcct.get(acc.Id);
                
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