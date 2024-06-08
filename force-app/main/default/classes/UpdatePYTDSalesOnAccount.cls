global without sharing class UpdatePYTDSalesOnAccount implements Database.Batchable<sObject>, Database.Stateful 
{
    global string recordTypeName='Branch Account';   
    global Date priorYearStartDate;
    global Date priorYearEndDate;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        priorYearStartDate = previousFiscalYear.FiscalYearSettings.StartDate;
        priorYearEndDate = system.today().addYears(-1);

        String query = 'SELECT PYTD_Sales__c FROM Account WHERE RecordType.Name =: recordTypeName AND Id IN'
            + ' (SELECT AccountId FROM Quote WHERE Opportunity.RecordType.Name = \'Trade_Comm\' AND Account.RecordType.Name = \'Branch Account\''
            + ' AND status in (\'Booked\', \'Ordered\') AND BookDate__c >=: priorYearStartDate AND BookDate__c <=: priorYearEndDate)';
        
        return Database.getQueryLocator(query);       
     }

     global void execute(Database.BatchableContext bc, List<Account> scope){
        Period previousFiscalYear = [
            SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate, FiscalYearSettings.EndDate
            FROM Period 
            WHERE Type = 'Year'
            AND StartDate <= TODAY AND EndDate <= TODAY
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        Date startDate = previousFiscalYear.FiscalYearSettings.StartDate;
        Date endDate = system.today().addYears(-1);

        List<Quote> quoteList = [
            SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
            WHERE AccountId =:scope
            AND status in ('Booked', 'Ordered')
            AND BookDate__c >=: startDate 
            AND BookDate__c <=: endDate
            AND Opportunity.RecordType.Name = 'Trade_Comm'
            AND Account.RecordType.Name =: recordTypeName
        ];
        
        Decimal totalAcc = 0;
        Map<String, Decimal> accountTotalMap = new Map<String, Decimal>();
        
        for(Quote quote : quoteList){
            if(!accountTotalMap.containsKey(quote.AccountId)){
                accountTotalMap.put(quote.AccountId, 0);
            }

            totalAcc = accountTotalMap.get(quote.AccountId) + (quote.Customer_Extended_Price__c == null ? 0 : quote.Customer_Extended_Price__c);
            accountTotalMap.put(quote.AccountId, totalAcc);            
        }
        
        for(Account acc : scope){
            if(accountTotalMap.containsKey(acc.Id)){
                acc.PYTD_Sales__c = accountTotalMap.get(acc.Id);
            }
        }
        if(scope.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            
            AccountTriggerHandler.RUN_TRIGGER=false;
            Database.SaveResult[] saveResultList = Database.update(scope, false); 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
            
            List<String> errorMessages = new List<String> ();
            for(Database.SaveResult result : saveResultList) {
                if(!result.isSuccess()) {
                    String accountWithError = result.getId();
                    for (Database.Error error : result.getErrors()) {
                        String message = error.getMessage();
                        errorMessages.add('accountId {' + accountWithError + '}: ' + message);
                    }
                }
            }
            
            if (errorMessages.size() > 0) {
                new ApexDebugLog().createLog(new ApexDebugLog.Error(
                    'UpdatePYTDSalesOnAccount',
                    'Database.update',
                    'There were one or more failures in a batch update. See the list of failures for details',
                    string.join(errorMessages, ', '),
                    null,
                    'Database'
                ));
            }
        }
        
    }    
    global void finish(Database.BatchableContext bc){        
    } 
}