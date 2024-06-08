public without sharing class AccountPhoneUpdateBatch implements Database.Batchable<sObject>,Schedulable {
     
    public Database.QueryLocator start(Database.BatchableContext BC){
       
        return Database.getQueryLocator(System.Label.AccountPhoneUpdateQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> listAccRecs){
        List<Account> listAcc=new List<Account>();
        for(Account ac:listAccRecs){
            Boolean isPhoneFound = false;
            String Phone='';
            if(String.isNotBlank(ac.PersonHomePhone) && !isPhoneFound ) { Phone = ServiceUtil.formatPhone(ac.PersonHomePhone); isPhoneFound = true; } 
            if(String.isNotBlank(ac.PersonMobilePhone) && !isPhoneFound ) { Phone = ServiceUtil.formatPhone(ac.PersonMobilePhone); isPhoneFound = true; } 
            if(String.isNotBlank(ac.PersonOtherPhone) && !isPhoneFound ) { Phone = ServiceUtil.formatPhone(ac.PersonOtherPhone); isPhoneFound = true; }   
            if(String.isNotBlank(ac.PersonAssistantPhone) && !isPhoneFound ) { Phone = ServiceUtil.formatPhone(ac.PersonAssistantPhone); isPhoneFound = true; }    
            if(Phone!='' && ac.Phone!=Phone){
                ac.phone=phone;
                listAcc.add(ac);
            }
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.update(listAcc, dml); 
       
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        AccountPhoneUpdateBatch b = new AccountPhoneUpdateBatch(); 
        database.executebatch(b,10);
    }
}