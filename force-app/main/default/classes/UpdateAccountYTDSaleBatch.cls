global class UpdateAccountYTDSaleBatch implements Database.Batchable<sObject>,Database.Stateful
{ 
    global Date stdt;
    global Date eddt;
    global string recType='Branch Account';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        
        String query = 'SELECT Id, PY_Sales__c, PPY_Sales__c, YTD_Sales__c, YTD_Associated_Sales__c FROM Account WHERE RecordType.Name = :recType';
        return Database.getQueryLocator(query);       
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<String> qtAccId = new Set<String>();
        Set<String> qtOppId = new Set<String>();
        Set<String> associateAccId = new Set<String>();
        Set<String> associateOppId = new Set<String>();
        for(Account accRec : scope){
            qtAccId.add(accRec.Id);
        }
        
        for(Opportunity oppRec : [SELECT Id, AccountId FROM Opportunity Where AccountId IN :qtAccId]){
            qtOppId.add(oppRec.Id);
        }
        
        System.debug('@@qtAccIdQT : '+qtAccId);
        System.debug('@@qtOppIdQT : '+qtOppId);
        //Associate account from Opportunity
        List<Associated_Account__c> associateAccs = [SELECT Id, Associated_Account_Name__c, Opportunity__c FROM Associated_Account__c
                                                     WHERE Opportunity__c =:qtOppId];
        for(Associated_Account__c AA : associateAccs){
            if(AA.Associated_Account_Name__c != null){
                associateAccId.add(AA.Associated_Account_Name__c);
            }
        }
        //get all opportunity related to Associate account
        List<Associated_Account__c> associateAccList = [SELECT Id, Associated_Account_Name__c, Opportunity__c FROM Associated_Account__c
                                                        WHERE Associated_Account_Name__c =:associateAccId AND Associated_Account_Name__r.RecordType.Name != 'Pella Account'];
        Map<String, Set<String>> mapAccOpp = new Map<String, Set<String>>();
        for(Associated_Account__c AA : associateAccList){
            if(AA.Opportunity__c != null){
                associateOppId.add(AA.Opportunity__c);
            }
            if(AA.Associated_Account_Name__c != null){
                if(!mapAccOpp.containsKey(AA.Associated_Account_Name__c)){
                    mapAccOpp.put(AA.Associated_Account_Name__c, new Set<String>());
                }
                mapAccOpp.get(AA.Associated_Account_Name__c).add(AA.Opportunity__c);
            }
            
        }
        System.debug('@@mapAccOppQT : '+mapAccOpp);
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE (AccountId =:qtAccId OR OpportunityId =:associateOppId)
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name != 'Pella Account'
                                 //AND Status <> 'Canceled'
                                 AND status in ('Booked', 'Ordered')
                                 AND BookDate__c >=: stdt AND BookDate__c <=: eddt];
        System.debug('@@quoteListQT : '+quoteList.size());
        
        Decimal totalAcc = 0;
        Decimal totalOpp = 0;
        Map<String, Decimal> mapAcct = new Map<String, Decimal>();
        Map<String, Decimal> mapOpp = new Map<String, Decimal>();
        
        for(Quote qt : quoteList){
            if(qtAccId.contains(qt.AccountId)){
                if(!mapAcct.containsKey(qt.AccountId)){
                    mapAcct.put(qt.AccountId, 0);
                }
                totalAcc = mapAcct.get(qt.AccountId) + (qt.Customer_Extended_Price__c == null ? 0 : qt.Customer_Extended_Price__c);
                mapAcct.put(qt.AccountId, totalAcc);
            }
            if(associateOppId.contains(qt.OpportunityId)){
                if(!mapOpp.containsKey(qt.OpportunityId)){
                    mapOpp.put(qt.OpportunityId, 0);
                }
                totalOpp = mapOpp.get(qt.OpportunityId) + (qt.Customer_Extended_Price__c == null ? 0 : qt.Customer_Extended_Price__c);
                mapOpp.put(qt.OpportunityId, totalOpp);
            }
            
        }
        System.debug('@@mapAcctQT : '+mapAcct);
        System.debug('@@mapOppQT : '+mapOpp);
        
        List<Account> accList = new List<Account>();
        for(String accId : qtAccId){
            Account acc = new Account();
            acc.Id = accId;
            if(mapAcct.containsKey(accId)){
                acc.YTD_Sales__c = mapAcct.get(accId);
                
            }else{
                acc.YTD_Sales__c = 0;
            }
            
            accList.add(acc);
            System.debug('@@accYTDQT : '+acc);
            
        }
        if(accList.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update accList; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
        
        accList = new List<Account>();
        for(String accId : mapAccOpp.keySet()){
            Decimal totalYTDAssociate = 0;
            
            
            for(String oppId : mapAccOpp.get(accId)){
                System.debug('@@oppIdQT : '+oppId);
                System.debug('@@mapAccOpp.get(accId)QT : '+mapAccOpp.get(accId).size());
                if(mapOpp.containsKey(oppId)){
                    totalYTDAssociate += mapOpp.get(oppId);
                }
            }
            Account acc = new Account();
            acc.Id = accId;
            acc.YTD_Associated_Sales__c = totalYTDAssociate;
            accList.add(acc);
        }
        if(accList.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update accList; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
    }
    
    global void finish(Database.BatchableContext bc){    
        System.debug('::UpdateAccountYTDSaleBatch Completed::');
    }    
}