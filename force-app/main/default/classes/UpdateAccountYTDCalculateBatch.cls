global class UpdateAccountYTDCalculateBatch implements Database.Batchable<sObject>,Database.Stateful{ 
    global Date stdt;
    global Date eddt;
    global Integer currentYear;
    global string recType='Branch Account';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        currentYear = Integer.valueOf(currentFiscalYear.FiscalYearSettings.Name);
        
        String query = 'SELECT Id, PY_Sales__c, PPY_Sales__c, YTD_Sales__c, YTD_Associated_Sales__c, YTD_Phone_Calls__c, YTD_Meetings__c, YTD_CEUs__c, YTD_Tasks__c, CurrentFiscalYear__c FROM Account WHERE RecordType.Name = :recType ';
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
        
        System.debug('@@qtAccId_QT : '+qtAccId);
        System.debug('@@qtOppId_QT : '+qtOppId);
        
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
        System.debug('@@mapAccOpp_QT : '+mapAccOpp);
        System.debug('@@stdt : '+stdt);
        System.debug('@@eddt : '+eddt);
        List<Quote> quoteList = [SELECT Id, BookDate__c, Customer_Extended_Price__c, AccountId, OpportunityId FROM Quote
                                 WHERE (AccountId =:qtAccId OR OpportunityId =:associateOppId)
                                 AND Opportunity.RecordType.Name = 'Trade_Comm'
                                 AND Account.RecordType.Name != 'Pella Account'
                                 AND BookDate__c >=: stdt AND BookDate__c <=: eddt];
        System.debug('@@quoteList_QT : '+quoteList.size());
        
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
        System.debug('@@mapAcct_QT : '+mapAcct);
        System.debug('@@mapOpp_QT : '+mapOpp);
        
        //Task and Event Type Count
        List<Task> allTaskList = [SELECT Id, WhatId, Type FROM Task WHERE WhatId =:qtAccId 
                                  AND CreatedDate >=:stdt AND CreatedDate <=:eddt];
        Map<String, eventRecCount> mapAccountTaskEvent = new Map<String, eventRecCount>();
        for(Task tsk : allTaskList){
            if(!mapAccountTaskEvent.containsKey(tsk.WhatId)){
                mapAccountTaskEvent.put(tsk.WhatId, new eventRecCount(0, 0, 0, 0));
            }
            if(tsk.Type == 'Call'){
                mapAccountTaskEvent.get(tsk.WhatId).phoneCalls += 1;
            }
            else if(tsk.Type == 'Meeting' || tsk.Type == 'Virtual Meeting'){
                mapAccountTaskEvent.get(tsk.WhatId).meetings += 1;
            }
            else if(tsk.Type == 'To Do' || tsk.Type == 'Other'){
                mapAccountTaskEvent.get(tsk.WhatId).tasks += 1;
            }
        }
        
        List<Event> allEventList = [SELECT Id, WhatId, Type FROM Event WHERE WhatId =:qtAccId 
                                    AND CreatedDate >=:stdt AND CreatedDate <=:eddt];
        for(Event evt : allEventList){
            if(!mapAccountTaskEvent.containsKey(evt.WhatId)){
                mapAccountTaskEvent.put(evt.WhatId,  new eventRecCount(0, 0, 0, 0));
            }
            if(evt.Type == 'Call'){
                mapAccountTaskEvent.get(evt.WhatId).phoneCalls += 1;
            } else if(evt.Type == 'Meeting' ){
                mapAccountTaskEvent.get(evt.WhatId).meetings += 1;
            } else if(evt.Type == 'CEU' ){
                mapAccountTaskEvent.get(evt.WhatId).CEUs += 1;
            }
        }
        
        
        Map<Id,Account> mapAccList = new Map<Id,Account>();
        for(String accId : qtAccId){
            Account acc = new Account();
            acc.Id = accId;
            
            acc.YTD_Sales__c = mapAcct.containsKey(accId) ? mapAcct.get(accId) : 0;
            
            acc.YTD_Phone_Calls__c = mapAccountTaskEvent.containsKey(accId) ? mapAccountTaskEvent.get(accId).phoneCalls : 0;
            acc.YTD_Meetings__c = mapAccountTaskEvent.containsKey(accId) ? mapAccountTaskEvent.get(accId).meetings : 0;
            acc.YTD_CEUs__c = mapAccountTaskEvent.containsKey(accId) ? mapAccountTaskEvent.get(accId).CEUs : 0;
            acc.YTD_Tasks__c = mapAccountTaskEvent.containsKey(accId) ? mapAccountTaskEvent.get(accId).tasks : 0;
            acc.CurrentFiscalYear__c = currentYear;
            mapAccList.put(acc.Id, acc);
            
            System.debug('@@accYTD_QT : '+acc);
            
        }
        
        for(String accId : mapAccOpp.keySet()){
            Decimal totalYTDAssociate = 0;
            
            for(String oppId : mapAccOpp.get(accId)){
                System.debug('@@oppId_QT : '+oppId);
                System.debug('@@mapAccOpp.get(accId)_QT : '+mapAccOpp.get(accId).size());
                if(mapOpp.containsKey(oppId)){
                    totalYTDAssociate += mapOpp.get(oppId);
                }
            }
            Account acc = new Account();
            acc.Id = accId;
            acc.YTD_Associated_Sales__c = totalYTDAssociate;
            if(!mapAccList.containsKey(acc.Id)){
                mapAccList.put(acc.Id,acc);
            }else{
                mapAccList.get(acc.Id).YTD_Associated_Sales__c = totalYTDAssociate; 
            }
        }
        
        if(mapAccList.keyset().size() > 0){
            Boolean AccTrigger = AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER = false;
            update mapAccList.values(); 
            AccountTriggerHandler.RUN_TRIGGER = AccTrigger;
        }
    }
    
    global void finish(Database.BatchableContext bc){    
        System.debug('::UpdateAccountYTDCalculateBatch Completed::');
    }    
    
    public class eventRecCount{
        public Integer phoneCalls;
        public Integer meetings;
        public Integer CEUs;
        public Integer tasks;
        public eventRecCount(Integer phoneCalls, Integer meetings, Integer CEUs, Integer tasks){
            this.phoneCalls = phoneCalls;
            this.meetings = meetings;
            this.CEUs = CEUs;
            this.tasks = tasks;
        }
    }
}