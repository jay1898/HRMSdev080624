global class UpdateAccountYTDCountsBatch implements Database.Batchable<sObject>,Database.Stateful
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
        
        String query = 'SELECT Id, YTD_Phone_Calls__c, YTD_Meetings__c, YTD_CEUs__c, YTD_Tasks__c FROM Account WHERE RecordType.Name = :recType';
        return Database.getQueryLocator(query);       
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<String> accIds = new Set<String>();
        
        for(Account accRec : scope){
            accIds.add(accRec.Id);
        }
        
        List<Task> allTaskList = [SELECT Id, WhatId, Type FROM Task WHERE WhatId =:accIds 
                                  AND CreatedDate >=:stdt AND CreatedDate <=:eddt];
        Map<String, eventRecCount> mapAccount = new Map<String, eventRecCount>();
        for(Task tsk : allTaskList){
            if(!mapAccount.containsKey(tsk.WhatId)){
                mapAccount.put(tsk.WhatId, new eventRecCount(0, 0, 0, 0));
            }
            if(tsk.Type == 'Call'){
                mapAccount.get(tsk.WhatId).phoneCalls += 1;
            }
            else if(tsk.Type == 'Meeting' || tsk.Type == 'Virtual Meeting'){
                mapAccount.get(tsk.WhatId).meetings += 1;
            }
            else if(tsk.Type == 'To Do' || tsk.Type == 'Other'){
                mapAccount.get(tsk.WhatId).tasks += 1;
            }
        }
        
        List<Event> allEventList = [SELECT Id, WhatId, Type FROM Event WHERE WhatId =:accIds AND CreatedDate >=:stdt AND CreatedDate <=:eddt];
        for(Event evt : allEventList){
            if(!mapAccount.containsKey(evt.WhatId)){
                mapAccount.put(evt.WhatId,  new eventRecCount(0, 0, 0, 0));
            }
            if(evt.Type == 'Call'){
                mapAccount.get(evt.WhatId).phoneCalls += 1;
            } else if(evt.Type == 'Meeting' ){
                mapAccount.get(evt.WhatId).meetings += 1;
            } else if(evt.Type == 'CEU' ){
                mapAccount.get(evt.WhatId).CEUs += 1;
            }
        }
        List<Account> accToUpdate = new List<Account>();
        for(String accId : accIds){
            Account acc = new Account();
            acc.Id = accId;
            acc.YTD_Phone_Calls__c = mapAccount.containsKey(accId)?mapAccount.get(accId).phoneCalls:0;
            acc.YTD_Meetings__c = mapAccount.containsKey(accId)?mapAccount.get(accId).meetings:0;
            acc.YTD_CEUs__c = mapAccount.containsKey(accId)?mapAccount.get(accId).CEUs:0;
            acc.YTD_Tasks__c = mapAccount.containsKey(accId)?mapAccount.get(accId).tasks:0;
            
            accToUpdate.add(acc);
        }
        
        if(accToUpdate.size() > 0){
            Boolean AccTrigger = AccountTriggerHandler.RUN_TRIGGER;
            AccountTriggerHandler.RUN_TRIGGER = false;
            update accToUpdate; 
            AccountTriggerHandler.RUN_TRIGGER = AccTrigger;
        }
    }
    
    global void finish(Database.BatchableContext bc){    
        System.debug('::UpdateAccountYTDCountsBatch Completed::');
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