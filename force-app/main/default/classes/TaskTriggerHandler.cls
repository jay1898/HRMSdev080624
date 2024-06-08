public class TaskTriggerHandler {
    public static void resolveEmailMapping(List<Task> listTask){
        List<Id> listOppCommIds=new List<Id>();
        for(Task tsk : listTask)
        { 
            try
            {
                String subject = String.valueOf(tsk.Subject);
                String description = String.valueOf(tsk.Description) != null? String.valueOf(tsk.Description): '';
                
                if(subject.contains('Unresolved Email')){
                    if(subject.contains('ref: ')){
                        try{
                            if(subject.length() >= (subject.indexOf('ref: '))+20){
                                String recordId = subject.substring(subject.indexOf('ref: ')+5, subject.indexOf('ref: ')+20);
                                if(Schema.OpportunityCommunication__c.SObjectType==((Id)recordId).getSObjectType()){
                                    tsk.WhatId = recordId;
                                    tsk.Subject = subject.substring(17);
                                    listOppCommIds.add(recordId);
                                    system.debug('@@ recordId  :: '+recordId);
                                }
                            }
                        }
                        catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'TaskTrigger', '', tsk.Id, e, 'Integration' ) );}
                    } 
                    else if(description.contains('ref: ')){
                        try{
                            if(description.length() >= (description.indexOf('ref: '))+20){
                                String recordId = description.substring(description.indexOf('ref: ')+5, description.indexOf('ref: ')+20);
                                if(Schema.OpportunityCommunication__c.SObjectType==((Id)recordId).getSObjectType()){
                                    tsk.WhatId = recordId;
                                    tsk.Subject = subject.substring(17);
                                    listOppCommIds.add(recordId);
                                }
                            }
                        }
                        catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error( 'TaskTrigger', '', tsk.Id, e, 'Internal' ) ); }
                    } 
                }
                else if( tsk.WhatId!=null && tsk.WhoId==null && Schema.OpportunityCommunication__c.SObjectType==(tsk.WhatId).getSObjectType()){
                    system.debug('@@ WhatId  :: '+tsk.WhatId);
                    listOppCommIds.add(tsk.WhatId);
                    
                }
            }
            catch(Exception e){ new ApexDebugLog().createLog( new ApexDebugLog.Error('TaskTrigger', '', tsk.Id, e, 'Internal')); }
        }
        
        if(listOppCommIds.size()>0){
            // delete all the Opportunity communication record 
            List<OpportunityCommunication__c> oppCommList=[Select Id,Opportunity__c,Opportunity__r.StageName from OpportunityCommunication__c where Id IN :listOppCommIds];
            Map<Id,Opportunity> oppMap=new Map<ID,Opportunity>();
            for(OpportunityCommunication__c oppCom : oppCommList){
                if(!oppMap.containsKey(oppCom.Opportunity__c)){
                    // update opportunity stage to 1on1
                    Opportunity Opp=new Opportunity();
                    if(oppCom.Opportunity__r.StageName == 'Follow-Up'){
                        Opp.Communication__c='1on1';
                    }else if(oppCom.Opportunity__r.StageName == 'Rehash'){
                        Opp.rehashCommunication__c='1on1';
                    }
                    opp.Communication_1on1_Flag__c=true;
                    Opp.Id=oppCom.Opportunity__c;
                    oppMap.put(oppCom.Opportunity__c,Opp);
                }
            }
            List<OpportunityCommunication__c> listOppCommToDelete=[Select Id,Opportunity__c from OpportunityCommunication__c where Opportunity__c in :oppMap.keySet() and id not in :listOppCommIds and is_executed__c=false];
            delete listOppCommToDelete;
            
            update oppMap.values();
        }
        
        
    }
    //Method to update the EDW Last Modified 
    public static void updateEDWLastModified(List<Task> lstNew,Map<Id,Task> oldMap){
        //Query to fetch all related fileds of Task from metadata
        List<EDW_Object_Mapping__mdt> lstobjTaskMetadta =[select id,Field_Api_Name__c,Source_Object__c from EDW_Object_Mapping__mdt where Source_Object__c='Task'];
        set<String> fieldSet = new Set<String>();
        //dynamically get the fields from the metadata and then use the same for comparison in the trigger. 
        for(EDW_Object_Mapping__mdt fields :lstobjTaskMetadta){
            fieldSet.add(fields.Field_Api_Name__c);
        }
        for(Task objTask: lstNew){
            
            for(string s: fieldSet){
                if(s.indexOf('.') > -1){
                    
                }
                else{
                    if(trigger.oldMap!=null){
                        if(objTask.get(s) != trigger.oldMap.get(objTask.Id).get(s)){
                            objTask.EDW_Last_Modified__c=Datetime.now();
                            break;
                        }
                    }
                    else{
                        if(objTask.get(s)!=null)
                            objTask.EDW_Last_Modified__c=Datetime.now();
                    }
                }
            }
            
            
        }
        
    }
    
    public static void updateOnAccount(List<Task> taskList, Map<Id,Task> oldMap){
       
        
        Set<String> accIds = new Set<String>();
        for(Task tsk : taskList){
            if(tsk.WhatId != null 
               && String.valueOf(tsk.WhatId).startsWith('001')
               && (oldMap == null || oldMap.get(tsk.Id).WhatId != tsk.WhatId || oldMap.get(tsk.Id).Type != tsk.Type))
            {
                accIds.add(tsk.WhatId);
                if(oldMap != null && oldMap.get(tsk.Id).WhatId != null && String.valueOf(oldMap.get(tsk.Id).WhatId).startsWith('001')
                   && (oldMap.get(tsk.Id).WhatId != tsk.WhatId || oldMap.get(tsk.Id).Type != tsk.Type))
                {
                    accIds.add(oldMap.get(tsk.Id).WhatId);
                }
            }
        }
        // made change to resolve 101 SOQL issue
        if(accIds.size()==0) return;
        
         
        Period currentFiscalYear = [SELECT FiscalYearSettings.Name, FiscalYearSettings.StartDate,
                                    FiscalYearSettings.EndDate FROM Period WHERE Type = 'Year' 
                                    AND StartDate <= TODAY AND EndDate >= TODAY];
        Date stdt = currentFiscalYear.FiscalYearSettings.StartDate;
        Date eddt = currentFiscalYear.FiscalYearSettings.EndDate;
        
        List<Task> allTaskList = [SELECT Id, WhatId, Type FROM Task WHERE WhatId =:accIds AND CreatedDate >=:stdt AND CreatedDate <=:eddt];
        Map<String, taskRecCount> mapAccount = new Map<String, taskRecCount>();
        for(Task tsk : allTaskList){
            if(!mapAccount.containsKey(tsk.WhatId)){
                mapAccount.put(tsk.WhatId, new taskRecCount(0, 0, 0));
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
                mapAccount.put(evt.WhatId,  new taskRecCount(0, 0, 0));
            }
            if(evt.Type == 'Call'){
                mapAccount.get(evt.WhatId).phoneCalls += 1;
            } else if(evt.Type == 'Meeting' ){
                mapAccount.get(evt.WhatId).meetings += 1;
            }
        }
        List<Account> accToUpdate = new List<Account>();
        for(String accId : accIds){
            Account acc = new Account();
            acc.Id = accId;
            acc.YTD_Phone_Calls__c = mapAccount.containsKey(accId)?mapAccount.get(accId).phoneCalls:0;
            acc.YTD_Meetings__c = mapAccount.containsKey(accId)?mapAccount.get(accId).meetings:0;
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
    
    public class taskRecCount{
        public Integer phoneCalls;
        public Integer meetings;
        public Integer tasks;
        public taskRecCount(Integer phoneCalls, Integer meetings, Integer tasks){
            this.phoneCalls = phoneCalls;
            this.meetings = meetings;
            this.tasks = tasks;
        }
    }

    public static void createAutoTaskforPIES(List<Task> taskList, Map<Id,Task> oldMap){
        Id piesRT = Schema.SObjectType.Task.RecordTypeInfosByDeveloperName.get('PIES_OV_Install').RecordTypeId;
         Map<Id, Id> mapTaskIdWOId = new Map<Id, Id>(); 
         Map<Id, Id> mapTaskIdSAId = new Map<Id, Id>();
         List<Task> listTask = new List<Task>(); Set<String> setTsIdTsType = New Set<String>();
        for(Task tsk : taskList){
            if(tsk.WhatId != null && tsk.status != oldMap.get(tsk.Id).Status 
               && tsk.Status == 'Completed' && tsk.recordTypeId == piesRT && tsk.Auto_Task__c == TRUE){
                
                mapTaskIdWOId.put(tsk.Id, tsk.WhatId);
                mapTaskIdSAId.put(tsk.Id, tsk.Appointment__c);
                setTsIdTsType.add(tsk.Type);
                listTask.add(tsk);
            }
        }
        if(mapTaskIdWOId.size() > 0){
               PIESAutoTaskOwnerAssignment.createAutoTaskansAssignOwners(mapTaskIdWOId,mapTaskIdSAId,setTsIdTsType,listTask);
        }
        

    }
}