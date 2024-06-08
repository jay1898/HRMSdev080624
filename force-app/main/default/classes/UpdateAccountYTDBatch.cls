global without sharing class UpdateAccountYTDBatch implements Database.Batchable<sObject>,Database.Stateful 
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
        //startDate=Date.today();
        String query = '';
        if(Test.isRunningTest()){
            startDate=Date.today();
            query = 'SELECT Id, PY_Sales__c,PPY_Sales__c,YTD_Sales__c,YTD_Associated_Sales__c,PY_Associated_Sales__c,PPY_Associated_Sales__c,Account_Rank__c,PY_Account_Rank__c,PPY_Account_Rank__c,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c  FROM Account WHERE Fiscal_Year_Start__c=:startDate AND RecordType.Name=:recType';
        }else{
            query = 'SELECT Id, PY_Sales__c,PPY_Sales__c,YTD_Sales__c,YTD_Associated_Sales__c,PY_Associated_Sales__c,PPY_Associated_Sales__c,Account_Rank__c,PY_Account_Rank__c,PPY_Account_Rank__c,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c FROM Account WHERE  Fiscal_Year_Start__c=:startDate AND RecordType.Name=:recType';
        }
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
        
        // process each batch of records    
        
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        Integer currentYear = Integer.valueOf(currentFiscalYear.FiscalYearSettings.Name);
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE (AccountId =:qtAccId OR OpportunityId =:associateOppId)
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name != 'Pella Account'
                                 AND status in ('Booked', 'Ordered')
                                 AND BookDate__c >=: stdt AND BookDate__c <=: eddt];
        
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
        
        for(Account acc : scope){
            acc.PPY_Account_Rank__c = acc.PY_Account_Rank__c;
            acc.PY_Account_Rank__c = acc.Account_Rank__c;
            acc.PPY_Account_Status__c = acc.PY_Account_Status__c;
            acc.PY_Account_Status__c = acc.Account_State__c;
            acc.PPY_Sales__c = acc.PY_Sales__c;
            acc.PY_Sales__c = acc.YTD_Sales__c;
            acc.Account_Plan_Approved__c=false;
            acc.Potential_Sales__c=0;
            acc.PPY_Associated_Sales__c = acc.PY_Associated_Sales__c;
            acc.PY_Associated_Sales__c = acc.YTD_Associated_Sales__c;
            acc.YTD_Associated_Sales__c=0;
            if(mapAcct.containsKey(acc.Id)){
                acc.YTD_Sales__c = mapAcct.get(acc.Id);
                
            }else{
                acc.YTD_Sales__c = 0;
            }
        }
        system.debug('@@'+JSON.serialize(scope));
        if(scope.size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update scope; 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
		
		Map<Id,Account> accMapUpdate = new Map<Id,Account>();
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
            accMapUpdate.put(acc.Id,acc);
        }
        if(accMapUpdate.keyset().size() > 0){
            Boolean AccTrigger=AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER=false;
            update accMapUpdate.values(); 
            AccountTriggerHandler.RUN_TRIGGER=AccTrigger;
        }
		 
    }    
    global void finish(Database.BatchableContext bc){        
    }    
}