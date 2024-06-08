// UpdateAccountYTDBatchTest test class
global without sharing class UpdateAccountYTDStatusBatch implements Database.Batchable<sObject>,Database.Stateful 
{
    global string recType='Branch Account';   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('recType='+recType);
        //startDate=Date.today();
        String query = '';
        if(Test.isRunningTest()){
            query = 'SELECT Id,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c,PY_Sales__C FROM Account WHERE RecordType.Name=:recType and (PY_Account_status__C = \'Customer\' OR PY_Account_status__C = \'Prospect\') ';
        }else{
            query = 'SELECT Id,Account_State__c,PY_Account_Status__c,PPY_Account_Status__c,PY_Sales__C FROM Account WHERE RecordType.Name=:recType and (PY_Account_status__C = \'Customer\' OR PY_Account_status__C = \'Prospect\')  ';
        }
        return Database.getQueryLocator(query);       
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        
        
        for(Account acc : scope){
            if((acc.PY_Account_status__C == 'Customer'|| acc.PY_Account_status__C == 'Prospect') && acc.PY_Sales__C > 500)
            	acc.Account_state__c = 'Customer';
            else if((acc.PY_Account_status__C == 'Customer'|| acc.PY_Account_status__C == 'Prospect') && acc.PY_Sales__C <= 500)
            	acc.Account_state__c = 'Prospect';    
        }
        system.debug('@@'+JSON.serialize(scope));
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